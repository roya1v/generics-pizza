//
//  OrdersController.swift
//  
//
//  Created by Mike S. on 16/03/2023.
//

import Fluent
import Vapor
import GenericsModels

final class OrdersController: RouteCollection {

    private var clients = [UUID: WebSocket]()
    private var admins = [WebSocket]()

    func boot(routes: RoutesBuilder) throws {
        let order = routes.grouped("order")
        order.post("check_price", use: checkPrice)
        let authenticated = order.grouped(UserToken.authenticator())
        authenticated.get("current", use: getCurrent)
        authenticated.get("history", use: getHistory)
        order.post(use: new)

        order.grouped("activity").grouped(":orderId").webSocket(onUpgrade: orderActivity)
        order.grouped("activity").grouped(UserToken.authenticator()).webSocket(onUpgrade: adminActivity)
    }

    /// Get currently unfinished orders
    func getCurrent(req: Request) async throws -> [OrderModel] {
        try req.auth.require(User.self)
        return try await Order.query(on: req.db)
            .filter(\.$state != .finished)
            .with(\.$items) { $0.with(\.$item) }
            .all()
            .map { $0.getContent() }
    }

    /// Get all finished orders
    func getHistory(req: Request) async throws -> [OrderModel] {
        try req.auth.require(User.self)
        return try await Order.query(on: req.db)
            .filter(\.$state == .finished)
            .with(\.$items) { $0.with(\.$item) }
            .all()
            .map { $0.getContent() }
    }

    /// Check price for order
    func checkPrice(req: Request) async throws -> [Subtotal] {
        let sum = try req.content.decode(OrderModel.self).items.reduce(0, {$0 + $1.price})
        return [
            .init(name: "Subtotal", value: sum),
            .init(name: "Delivery", value: 1299),
            .init(name: "Total", value: sum + 1299, isSecondary: false)
        ]
    }

    /// Make a new order
    func new(req: Request) async throws -> OrderModel {
        let orderModel = try req.content.decode(OrderModel.self)

        let order = Order(state: .new)
        try await order.save(on: req.db)

        let items = orderModel.items.map { OrderItem(item: $0.id!) }
        try await order.$items.create(items, on: req.db)

        try await order.$items.load(on: req.db)
        for item in order.items {
            try await item.$item.load(on: req.db)
        }
        for admin in admins {
            try? await admin.send(OrderMessage.newOrder(order: order.getContent()).encode() ?? "")
        }

        return order.getContent()
    }

    /// Connect to order activity as a customer
    func orderActivity(req: Request, ws: WebSocket) async {
        guard let order = try? await Order.find(req.parameters.get("orderId"), on: req.db) else {
            try? await ws.close()
            return
        }
        clients[order.id!] = ws
        ws.onClose.whenComplete { [weak self] _ in
            self?.clients.removeValue(forKey: order.id!)
        }
    }

    /// Connect to order activity as an admin
    func adminActivity(req: Request, ws: WebSocket) async {
        do {
            try req.auth.require(User.self)
        } catch {
            try? await ws.send(error.localizedDescription)
            try? await ws.close()
            return
        }

        admins.append(ws)

        try? await Order.query(on: req.db)
            .filter(\.$state != .finished)
            .with(\.$items) { $0.with(\.$item) }
            .all()
            .map { $0.getContent() }
            .forEach({ order in
                ws.send(OrderMessage.newOrder(order: order).encode() ?? "")
            })

        ws.onText { ws, text in
            let message = try? OrderMessage.decode(from: text)
            switch message {
            case .newOrder:
                fatalError()
            case .update(let id, let state):
                if let order = try? await Order.find(id, on: req.db) {
                    order.state = state
                    try? await order.save(on: req.db)
                    if let client = self.clients[id] {
                        try? await client.send(text)
                    }
                    try? await ws.send(text)
                }
            case .accepted:
                fatalError()
            case .none:
                fatalError()
            }
        }
    }
}

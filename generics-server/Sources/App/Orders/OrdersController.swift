//
//  OrdersController.swift
//  
//
//  Created by Mike S. on 16/03/2023.
//

import Fluent
import Vapor
import GenericsModels

class OrdersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let order = routes.grouped("order")
        let authenticated = order.grouped(UserToken.authenticator())
        authenticated.grouped("current").get(use: getCurrent)
        order.post(use: new)

        order.grouped("activity").grouped(":orderId").webSocket(onUpgrade: orderActivity)
        order.grouped("activity").grouped(UserToken.authenticator()).webSocket(onUpgrade: adminActivity)
    }

    func getCurrent(req: Request) async throws -> [OrderModel] {
        try req.auth.require(User.self)
        return try await Order.query(on: req.db)
            .filter(\.$state != .finished)
            .with(\.$items) { $0.with(\.$item) }
            .all()
            .map { $0.getContent() }
    }

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
        return order.getContent()
    }

    var clients = [UUID: WebSocket]()

    func orderActivity(req: Request, ws: WebSocket) async {
        guard let order = try? await Order.find(req.parameters.get("orderId"), on: req.db) else {
            try? await ws.close()
            return
        }
        clients[order.id!] = ws
        ws.onClose.whenComplete { [weak self] result in
            self?.clients.removeValue(forKey: order.id!)
        }
    }

    func adminActivity(req: Request, ws: WebSocket) async {
        do {
            try req.auth.require(User.self)
        } catch {
            try? await ws.send(error.localizedDescription)
            try? await ws.close()
            return
        }

        ws.onText { ws, text in
            if let command = OrderMessages.parse(from: text) {
                switch command {
                case .update(let message):
                    if let client = self.clients[message.id] {
                        client.send(command.encode())
                    }
                }
            }
        }
    }
}

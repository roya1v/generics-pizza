//
//  OrdersController.swift
//  
//
//  Created by Mike S. on 16/03/2023.
//

import Fluent
import Vapor
import SharedModels

typealias CustomerMessenger = Messenger<CustomerFromServerMessage, CustomerFromServerMessage>
typealias RestaurantMessenger = Messenger<RestaurantToServerMessage, RestaurantFromServerMessage>

final class OrdersController: RouteCollection {

    private var clients = [UUID: CustomerMessenger]()
    private var restaurant: RestaurantMessenger?
    private var drivers = [WebSocket]()

    func boot(routes: RoutesBuilder) throws {
        let order = routes.grouped("order")
        order.post("check_price", use: checkPrice)
        let authenticated = order.grouped(UserTokenEntry.authenticator())
        authenticated.get("current", use: getCurrent)
        authenticated.get("history", use: getHistory)
        order.post(use: new)

        order.grouped("activity").grouped(":orderId").webSocket(onUpgrade: orderActivity)
        order.grouped("activity").grouped(UserTokenEntry.authenticator()).webSocket(onUpgrade: restaurantActivity)
        order.grouped("activity").grouped("driver").webSocket(onUpgrade: driverActivity)
    }

    /// Get currently unfinished orders
    func getCurrent(req: Request) async throws -> [OrderModel] {
        try req.auth.require(UserEntry.self)
        return try await OrderEntry.query(on: req.db)
            .filter(\.$state != .finished)
            .with(\.$items) { $0.with(\.$item) }
            .all()
            .map { $0.getContent() }
    }

    /// Get all finished orders
    func getHistory(req: Request) async throws -> [OrderModel] {
        try req.auth.require(UserEntry.self)
        return try await OrderEntry.query(on: req.db)
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

        let order = OrderEntry(state: .new)
        try await order.save(on: req.db)

        let items = orderModel.items.map { OrderItemEntry(item: $0.id!) }
        try await order.$items.create(items, on: req.db)

        try await order.$items.load(on: req.db)
        for item in order.items {
            try await item.$item.load(on: req.db)
        }
        try? await restaurant?.send(message: .newOrder(order.getContent()))

        return order.getContent()
    }

    /// Connect to order activity as a customer
    func orderActivity(req: Request, ws: WebSocket) async {
        guard let order = try? await OrderEntry.find(req.parameters.get("orderId"), on: req.db) else {
            try? await ws.close()
            return
        }
        clients[order.id!] = .init(ws: ws, eventLoop: req.eventLoop)
        ws.onClose.whenComplete { [weak self] _ in
            self?.clients.removeValue(forKey: order.id!)
        }
    }

    /// Connect to order activity as a restaurant
    func restaurantActivity(req: Request, ws: WebSocket) async {
        do {
            try req.auth.require(UserEntry.self)
        } catch {
            try? await ws.send(error.localizedDescription)
            try? await ws.close()
            return
        }

        restaurant = .init(ws: ws, eventLoop: req.eventLoop)

        try? await OrderEntry.query(on: req.db)
            .filter(\.$state != .finished)
            .with(\.$items) { $0.with(\.$item) }
            .all()
            .map { $0.getContent() }
            .forEach({ order in
                try? restaurant!.send(message: .newOrder(order))
            })

        restaurant!.onMessage { message in
            Task {
                switch message {
                case .update(let id, let state):
                    if let order = try? await OrderEntry.find(id, on: req.db) {
                        order.state = state
                        try? await order.save(on: req.db)
                        if let client = self.clients[id] {
                            try? await client.send(message: .newState(state))
                        }
                    }
                }
            }
        }
    }

    /// Connect to order activity as a driver
    func driverActivity(req: Request, ws: WebSocket) async {
        do {
            try req.auth.require(UserEntry.self)
        } catch {
            try? await ws.send(error.localizedDescription)
            try? await ws.close()
            return
        }

        drivers.append(ws)

        ws.onText { ws, text in

        }
    }
}

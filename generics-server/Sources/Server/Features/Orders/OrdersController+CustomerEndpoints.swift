//
//  OrdersClientController.swift
//  
//
//  Created by Mike S. on 19/11/2023.
//

import Fluent
import Vapor
import SharedModels

extension OrdersController {

    /// Check price for an order.
    func checkPrice(req: Request) async throws -> [SubtotalModel] {
        let sum = try req.content.decode(OrderModel.self).items.reduce(0, {$0 + $1.price})
        return [
            .init(name: "Subtotal", value: sum),
            .init(name: "Total", value: sum, isSecondary: false)
        ]
    }

    /// Check which restaurant serves which location
    func checkRestaurantLocation(req: Request) async throws -> AddressModel {
        throw Abort(.notImplemented)
    }

    /// Create a new order.
    func new(req: Request) async throws -> OrderModel {
        guard let restaurant else {
            throw Abort(.notAcceptable, reason: "Restaurant is offline.")
        }
        let orderModel = try req.content.decode(OrderModel.self)

        let address: String?
        switch orderModel.type {
        case .delivery(let orderAddress):
            address = orderAddress
        case .pickUp:
            address = nil
        }

        let order = OrderEntry(state: .new, address: address)
        try await order.save(on: req.db)

        let items = orderModel.items.map { OrderItemEntry(item: $0.id!) }
        try await order.$items.create(items, on: req.db)

        try await order.$items.load(on: req.db)
        for item in order.items {
            try await item.$item.load(on: req.db)
        }

        try await restaurant.send(message: .newOrder(order.toSharedModel()))
        req.logger.debug("New incomming order: \(order.toSharedModel())")

        return order.toSharedModel()
    }

    /// Connect to order activity as a customer.
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
}

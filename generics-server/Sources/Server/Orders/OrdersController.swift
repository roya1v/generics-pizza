//
//  OrdersController.swift
//  
//
//  Created by Mike S. on 16/03/2023.
//

import Fluent
import Vapor
import SharedModels

// Hardcoded single restaurant for now
fileprivate let restaurantLocation = AddressModel(coordinate: .init(latitude: 52.23052266504451, longitude: 21.006914615520103),
                                                  details: "Śródmieście Północne, Warszawa")

typealias CustomerMessenger = Messenger<CustomerFromServerMessage, CustomerFromServerMessage>
typealias RestaurantMessenger = Messenger<RestaurantToServerMessage, RestaurantFromServerMessage>
typealias DriverMessenger = Messenger<DriverToServerMessage, DriverFromServerMessage>

final class OrdersController: RouteCollection {

    private var clients = [UUID: CustomerMessenger]()
    private var restaurant: RestaurantMessenger?
    private var drivers = [DriverMessenger]()

    func boot(routes: RoutesBuilder) throws {
        let order = routes.grouped("order")
        order.post("check_price", use: checkPrice)
        order.post("check_location", use: checkRestaurantLocation)
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
            .with(\.$address)
            .all()
            .toSharedModels()
    }

    /// Get all finished orders
    func getHistory(req: Request) async throws -> [OrderModel] {
        try req.auth.require(UserEntry.self)
        return try await OrderEntry.query(on: req.db)
            .filter(\.$state == .finished)
            .with(\.$items) { $0.with(\.$item) }
            .with(\.$address)
            .all()
            .toSharedModels()
    }

    /// Check price for order
    func checkPrice(req: Request) async throws -> [SubtotalModel] {
        let sum = try req.content.decode(OrderModel.self).items.reduce(0, {$0 + $1.price})
        return [
            .init(name: "Subtotal", value: sum),
            .init(name: "Delivery", value: 1299),
            .init(name: "Total", value: sum + 1299, isSecondary: false)
        ]
    }

    /// Check which restaurant serves which location
    func checkRestaurantLocation(req: Request) async throws -> AddressModel {
        // Hardcoded single restaurant for now
        return restaurantLocation
    }

    /// Make a new order
    func new(req: Request) async throws -> OrderModel {
        guard let restaurant else {
            throw Abort(.notAcceptable, reason: "Restaurant is offline.")
        }
        let orderModel = try req.content.decode(OrderModel.self)

        let address = orderModel.address.toEntry()
        try await address.save(on: req.db)

        let order = OrderEntry(state: .new, addressId: address.id!)
        try await order.save(on: req.db)

        let items = orderModel.items.map { OrderItemEntry(item: $0.id!) }
        try await order.$items.create(items, on: req.db)

        try await order.$items.load(on: req.db)
        for item in order.items {
            try await item.$item.load(on: req.db)
        }

        //let address = orderModel.address.toEntry()

        try await order.$address.load(on: req.db)

        try await restaurant.send(message: .newOrder(order.toSharedModel()))
        req.logger.debug("New incomming order: \(order.toSharedModel())")

        return order.toSharedModel()
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
        req.logger.debug("New restaurant joined.")

        try? await OrderEntry.query(on: req.db)
            .filter(\.$state != .finished)
            .with(\.$items) { $0.with(\.$item) }
            .with(\.$address)
            .all()
            .toSharedModels()
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

                        // TODO: Change the moment for driver search. Change the way the driver is selected.
                        if state == .readyForDelivery,
                           let driver = self.drivers.first {
                            try await order.$address.load(on: req.db)
                            try? await driver.send(message: .offerOrder(fromAddress: restaurantLocation,
                                                                        toAddress: order.address.toSharedModel(),
                                                                        reward: 9999))
                            req.logger.debug("Order ready for pick-up!")
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

        let messenger = DriverMessenger(ws: ws, eventLoop: req.eventLoop)
        drivers.append(messenger)
        req.logger.debug("New driver joined.")

        messenger.onMessage { message in
            switch message {
            case .locationUpdated(_, _):
                break
            case .acceptOrder:
                req.logger.debug("Driver accepted order.")
            case .declineOrder:
                req.logger.debug("Driver declined order.")
            }
        }
    }
}

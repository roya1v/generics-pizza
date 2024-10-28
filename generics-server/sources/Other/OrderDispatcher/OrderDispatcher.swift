import Foundation
import Vapor
import SharedModels

class OrderDispatcher {

    enum DispatchError: Error {
        case noRestaurant
        case noDrivers
        case noSuchOrder
    }

    var customers = [OrderModel.ID: CustomerMessenger]()
    var restaurant: RestaurantMessenger?
    var orders = [OrderModel.ID: OrderModel]()

    var updateInDb: (OrderModel) async throws -> Void
    private let logger: Logger

    init(logger: Logger, dbHandler: @escaping (OrderModel) async throws -> Void) {
        self.logger = logger
        self.updateInDb = dbHandler
    }

    func restaurantJoined(_ messenger: RestaurantMessenger) {
        restaurant = messenger
        messenger.onMessage(newRestaurantMessage)
    }

    func customerJoined(_ messenger: CustomerMessenger, forId id: OrderModel.ID) throws {
        guard let order = orders[id] else {
            throw DispatchError.noSuchOrder
        }
        Task {
            try? messenger.send(message: .newState(order.state!))
            customers[id] = messenger
        }
    }

    func placeOrder(_ order: OrderModel) throws {
        guard let restaurant else {
            throw DispatchError.noRestaurant
        }
        logger.debug("New incomming order: \(order)")
        try restaurant.send(message: .newOrder(order))
        orders[order.id] = order
    }

    private func newRestaurantMessage(_ message: RestaurantToServerMessage) {
        switch message {
        case .update(let orderId, let state):
            switch state {
            case .new:
                fatalError()
            case .inProgress, .readyForDelivery, .inDelivery, .finished:
                guard let order = orders[orderId] else {
                    return
                }
                let updatedOrder = OrderModel(id: order.id,
                                             createdAt: order.createdAt,
                                             items: order.items,
                                             state: state,
                                             destination: order.destination)
                orders[orderId] = updatedOrder
                Task {
                    try? await updateInDb(updatedOrder)
                }
                notifyCustomer(orderId: orderId, newState: state)
            }
        }
    }

    private func notifyCustomer(orderId: OrderModel.ID, newState: OrderModel.State) {
        if let customer = customers[orderId] {
            try? customer.send(message: .newState(newState))
        }
    }
}

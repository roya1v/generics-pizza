import Foundation
import Vapor
import SharedModels

class OrderDispatcher {

    enum DispatchError: Error {
        case noRestaurant
        case noDrivers
    }

    var clients = [OrderModel.ID: CustomerMessenger]()
    var restaurant: RestaurantMessenger?
    var drivers = [DriverMessenger]()
    var orders = [OrderModel]()


    func restaurantJoined(_ messenger: RestaurantMessenger) {
        restaurant = messenger
        messenger.onMessage(newRestaurantMessage)
    }

    func placeOrder(_ order: OrderModel) throws {
        guard let restaurant else {
            throw DispatchError.noRestaurant
        }

        try restaurant.send(message: .newOrder(order))
        orders.append(order)
    }

    private func newRestaurantMessage(_ message: RestaurantToServerMessage) {
        switch message {
        case .update(let orderId, let state):
            switch state {
            case .new:
                fatalError()
            case .inProgress:
                // Update orders array
                notifyClient(orderId: orderId, newState: state)
            case .readyForDelivery:
                // Update orders array
                notifyClient(orderId: orderId, newState: state)
                // TODO: Find the specific order
                dispatchDriver(order: orders.first!)
            case .inDelivery:
                // Restaurants can't pickup orders
                fatalError()
            case .finished:
                // Restaurants can't deliver orders
                notifyClient(orderId: orderId, newState: state)
            }
        }
    }

    private func newDriverMessage(_ message: DriverToServerMessage) {
        switch message {
        case .acceptOrder(let id):
            // Update orders array
            notifyClient(orderId: id, newState: .inDelivery)
        case .delivered(let id):
            // Update orders array
            notifyClient(orderId: id, newState: .finished)
        }
    }

    private func notifyClient(orderId: OrderModel.ID, newState: OrderModel.State) {
        if let client = clients[orderId] {
            try? client.send(message: .newState(newState))
        }
    }

    private func dispatchDriver(order: OrderModel) {
        // TODO: Add fair driver dispatching
        guard let driver = drivers.shuffled().first else {
            fatalError("We need to implement retries")
        }
        try? driver.send(message: .offerOrder(order))
    }
}

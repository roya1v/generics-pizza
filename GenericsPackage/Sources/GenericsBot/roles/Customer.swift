import ArgumentParser
import Foundation
import GenericsCore
import SharedModels

private let menuRepository = buildMenuRepository(url: baseUrl)
private let orderRepository = buildOrderRepository(url: baseUrl)

struct Customer: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "A bot that behaives like a customer.")

    @Flag(name: [.customLong("track")])
    var shouldTrack: Bool = false

    @Flag(name: [.customLong("delivery")])
    var delivery: Bool = false

    func run() async throws {
        let order = try await placeOrder()

        if shouldTrack {
            for await message in orderRepository.trackOrder(order).assertNoFailure().stream {
                print("New message from server:")
                switch message {
                case .accepted:
                    print("\t - Order accepted")
                case .newState(let state):
                    switch state {
                    case .new:
                        print("\t - Order accepted")
                    case .inProgress:
                        print("\t - Order is being prepared")
                    case .readyForDelivery:
                        print("\t - Order is ready for delivery")
                    case .inDelivery:
                        print("\t - Order is being delivered")
                    case .finished:
                        print("\t - Order has been delivered")
                        return
                    }
                }
            }
        }
    }

    private func placeOrder() async throws -> OrderModel {
        print("Fetching menu:")
        let menuItems = try await menuRepository.fetchMenu()
        print("Fetched \(menuItems.count) items")

        print("Choosing random item for oder:")
        let item = menuItems.shuffled().first!
        print(item)

        let destination: OrderModel.Destination

        if delivery {
            destination = .delivery(
                .init(
                    street: "Bagno 2c",
                    floor: 0,
                    appartment: "2",
                    comment: "Intercom doesn't work",
                    coordinates: .init(
                        latitude: 52.2358652,
                        longitude: 21.0055067
                    )
                )
            )
        } else {
            destination = .pickUp
        }

        print("Placing order...")
        return try await orderRepository.placeOrder(
            for: [OrderModel.Item(menuItem: item, count: 1)],
            destination: destination
        )
    }
}

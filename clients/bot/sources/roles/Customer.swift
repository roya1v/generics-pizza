import ArgumentParser
import Foundation
import GenericsCore
import SharedModels
@preconcurrency import Combine

struct Customer: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "A bot that behaives like a customer.")

    @Flag(name: [.customLong("track")])
    var shouldTrack: Bool = false

    @Flag(name: [.customLong("delivery")])
    var delivery: Bool = false

    func run() async throws {
        let menuRepository = buildMenuRepository(url: baseUrl)

        print("Fetching menu:")
        let menuItems = try await menuRepository.fetchMenu()
        print("Fetched \(menuItems.count) items")

        print("Choosing random item for oder:")
        let item = menuItems.shuffled().first!
        print(item)

        let orderRepository = buildOrderRepository(url: baseUrl)

        let destination: OrderModel.Destination

        if delivery {
            destination = .delivery(
                .init(
                    street: "",
                    floor: 1,
                    appartment: "",
                    comment: "",
                    coordinates: .init(
                        latitude: 0.0,
                        longitude: 0.0
                    )
                )
            )
        } else {
            destination = .pickUp
        }

        print("Placing order...")
        let order = try await orderRepository.placeOrder(
            for: [OrderModel.Item(menuItem: item, count: 1)],
            destination: destination
        )
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
                    }
                }
            }
        }
    }
}

extension Publisher where Failure == Never {
    public var stream: AsyncStream<Output> {
        AsyncStream { continuation in
            let cancellable = self.sink { _ in
                continuation.finish()
            } receiveValue: { value in
                continuation.yield(value)
            }
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}

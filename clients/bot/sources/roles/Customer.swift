import ArgumentParser
import Foundation
import GenericsCore
import SharedModels

struct Customer: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "A bot that behaives like a customer.")

    @Flag(name: [.customLong("track")])
    var shouldTrack: Bool = false

    func run() async throws {
        let menuRepository = buildMenuRepository(url: baseUrl)

        print("Fetching menu:")
        let menuItems = try await menuRepository.fetchMenu()
        print("Fetched \(menuItems.count) items")

        print("Choosing random item for oder:")
        let item = menuItems.shuffled().first!
        print(item)

        let orderRepository = buildOrderRepository(url: baseUrl)

        print("Placing order...")
        let order = try await orderRepository.placeOrder(
            for: [OrderModel.Item(menuItem: item, count: 1)],
            destination: .pickUp
        )
        if shouldTrack {
            let cancellable = try await orderRepository.trackOrder(order)
                .sink { _ in

                } receiveValue: { message in
                    print(message)
                }
            try await Task.sleep(for: .seconds(99999999))
        }
    }
}


import ArgumentParser
import Foundation
import GenericsCore
import SharedModels

struct TestingDriverApp: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Create all the bots to test the driver app"
    )

    func run() async throws {
        print("Login:")
        let login = readLine(strippingNewline: true)!
        print("Password:")
        let password = readLine(strippingNewline: true)!

        let restaurant = try await RestaurantBot(login: login, password: password)
        restaurant.startAcceptingOrders()

        while true {
            let customer = CustomerBot()
            try await customer.makeRandomOrder()
        }
    }
}

struct RestaurantBot {

    private let repository: OrderRestaurantRepository

    init(login: String, password: String, speedMultiplier: Int = 1) async throws {
        print("[Restaurant] Trying to log in...")
        let authService = AuthenticationService(baseURL: baseUrl)

        repository = buildOrderRestaurantRepository(
            url: baseUrl,
            authenticationProvider: InMemoryAuthenticationProvider(
                token: try await authService.login(email: login, password: password)
            )
        )
    }

    func startAcceptingOrders() {
        Task {
            for await message in repository.getFeed().assertNoFailure().stream {
                switch message {
                case .newOrder(let order):
                    handleOrder(order)
                }
            }
        }
    }

    private func handleOrder(_ order: OrderModel) {
        guard let id = order.id else {
            print("Order without id, this shouldn't happen")
            return
        }
        print("Handling order with Id: \(id)")
        for item in order.items {
            print("\t - \(item.menuItem.title) x\(item.count)")
        }
        Task {
            try? await Task.sleep(for: .seconds(5))
            try? await repository.send(message: .update(orderId: id, state: .inProgress))
            print("Setting order \(id) to \"in progress\"")
            try? await Task.sleep(for: .seconds(5))
            try? await repository.send(message: .update(orderId: id, state: .readyForDelivery))
            print("Setting order \(id) to \"ready for delivery\"")
//            try? await Task.sleep(for: .seconds(5))
//            try? await repository.send(message: .update(orderId: id, state: .inDelivery))
//            print("Setting order \(id) to \"in delivery\"")
//            try? await Task.sleep(for: .seconds(5))
//            try? await repository.send(message: .update(orderId: id, state: .finished))
            print("Setting order \(id) to \"finished\"")
        }
    }
}

struct CustomerBot {

    private let menuRepository = buildMenuRepository(url: baseUrl)
    private let orderRepository = buildOrderRepository(url: baseUrl)

    func makeRandomOrder() async throws {
        print("Fetching menu:")
        let menuItems = try await menuRepository.fetchMenu()
        print("Fetched \(menuItems.count) items")

        print("Choosing random item for oder:")
        let item = menuItems.shuffled().first!
        print(item)

        let destination: OrderModel.Destination

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

        print("Placing order...")
        let order = try await orderRepository.placeOrder(
            for: [OrderModel.Item(menuItem: item, count: 1)],
            destination: destination
        )

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

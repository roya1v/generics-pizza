import ArgumentParser
import Foundation
import GenericsCore
import SharedModels

struct Restaurant: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "A bot that behaives as the restaurant.")

    func run() async throws {
        print("Login:")
        let login = readLine(strippingNewline: true)!
        print("Password:")
        let password = readLine(strippingNewline: true)!

        print("Trying to log in...")
        let authService = AuthenticationService(baseURL: baseUrl)
        let token: String
        do {
            token = try await authService
                .login(email: login, password: password)
        } catch {
            print("Error while logging in: \(error)")
            return
        }

        let orderRepository = buildOrderRestaurantRepository(
            url: baseUrl,
            authenticationProvider: InMemoryAuthenticationProvider(
                token: token
            )
        )

        let cancellable = orderRepository
            .getFeed()
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { message in
                switch message {
                case .newOrder(let order):
                    handleOrder(order, orderRepository: orderRepository)
                }
            }

        try await Task.sleep(for: .seconds(9_999_999))
    }

    private func handleOrder(_ order: OrderModel,
                             orderRepository: OrderRestaurantRepository) {
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
            try? await orderRepository.send(message: .update(orderId: id, state: .inProgress))
            print("Setting order \(id) to \"in progress\"")
            try? await Task.sleep(for: .seconds(5))
            try? await orderRepository.send(message: .update(orderId: id, state: .readyForDelivery))
            print("Setting order \(id) to \"ready for delivery\"")
            try? await Task.sleep(for: .seconds(5))
            try? await orderRepository.send(message: .update(orderId: id, state: .inDelivery))
            print("Setting order \(id) to \"in delivery\"")
            try? await Task.sleep(for: .seconds(5))
            try? await orderRepository.send(message: .update(orderId: id, state: .finished))
            print("Setting order \(id) to \"finished\"")
        }
    }
}

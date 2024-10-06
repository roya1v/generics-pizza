import ArgumentParser
import Foundation
import GenericsCore

struct Restaurant: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "A bot that behaives as the restaurant.")

    func run() async throws {
        let authService = AuthenticationService(baseURL: baseUrl)
        let token = try await authService.login(email: "login", password: "password")
        let orderRepository = buildOrderRestaurantRepository(
            url: baseUrl, authenticationProvider: InMemoryAuthenticationProvider(token: token))

        let cancellable =
            try await orderRepository
            .getFeed()
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { message in
                switch message {
                case .newOrder(let order):
                    Task {
                        let id = order.id!
                        try? await Task.sleep(for: .seconds(5))
                        try? await orderRepository.send(message: .update(orderId: id, state: .inProgress))
                        try? await Task.sleep(for: .seconds(5))
                        try? await orderRepository.send(message: .update(orderId: id, state: .readyForDelivery))
                        try? await Task.sleep(for: .seconds(5))
                        try? await orderRepository.send(message: .update(orderId: id, state: .inDelivery))
                        try? await Task.sleep(for: .seconds(5))
                        try? await orderRepository.send(message: .update(orderId: id, state: .finished))
                    }
                }
            }

        try await Task.sleep(for: .seconds(9_999_999))
    }
}

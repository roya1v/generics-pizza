import ArgumentParser
import Foundation
import GenericsCore
import SwiftlyHttp

let baseUrl = "http://localhost:8080"

class Test: AuthenticationProvider {

    private let token: String

    init(token: String) {
        self.token = token
    }

    func getAuthentication() throws -> SwiftlyHttp.Authentication {
        return .bearer(token: token)
    }
}

@main
struct Restaurant: AsyncParsableCommand {

    func run() async throws {
        let authService = AuthenticationService(baseURL: baseUrl)
        let token = try await authService.login(email: "login", password: "password")
        let orderRepository = buildOrderRestaurantRepository(
            url: baseUrl, authenticationProvider: Test(token: token))

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

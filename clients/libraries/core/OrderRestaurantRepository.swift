import Combine
import Foundation
import SharedModels
import SwiftlyHttp

public func buildOrderRestaurantRepository(
    url: String,
    authenticationProvider: some AuthenticationProvider
) -> OrderRestaurantRepository {
    OrderRestaurantRepositoryImpl(baseURL: url, authenticationProvider: authenticationProvider)
}

public protocol OrderRestaurantRepository {
    func getFeed() -> AnyPublisher<RestaurantFromServerMessage, Error>
    func send(message: RestaurantToServerMessage) async throws
    func getHistory() async throws -> [OrderModel]
}

final class OrderRestaurantRepositoryImpl: OrderRestaurantRepository {

    private var socket: SwiftlyWebSocketConnection?
    private let baseURL: String
    private let authenticationProvider: AuthenticationProvider

    init(baseURL: String, authenticationProvider: some AuthenticationProvider) {
        self.baseURL = baseURL
        self.authenticationProvider = authenticationProvider
    }

    // MARK: - OrderRestaurantRepository

    func getFeed() -> AnyPublisher<RestaurantFromServerMessage, Error> {
        return Future { fulfill in
            Task {
                self.socket = try await SwiftlyHttp(baseURL: "ws://localhost:8080")!
                    .add(path: "order")
                    .add(path: "activity")
                    .websocket()

                if case let .bearer(token) = try? self.authenticationProvider.getAuthentication() {
                    try await self.socket?.send(message: .string(token))
                }
                fulfill(.success(self.socket!
                    .messagePublisher
                    .compactMap({
                        if case let .string(message) = $0 {
                            return message.data(using: .utf8)
                        } else {
                            return nil
                        }
                    })
                    .decode(type: RestaurantFromServerMessage.self, decoder: JSONDecoder())
                    .eraseToAnyPublisher()))

            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }

    func send(message: RestaurantToServerMessage) async throws {
        let data = try JSONEncoder().encode(message)
        let text = String(decoding: data, as: UTF8.self)
        try await socket!.send(message: .string(text))
    }

    func getHistory() async throws -> [SharedModels.OrderModel] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "order")
            .add(path: "history")
            .method(.get)
            .authentication({
                try? self.authenticationProvider.getAuthentication()
            })
            .decode(to: [OrderModel].self)
            .set(jsonDecoder: decoder)
            .perform()
    }

    private func getCurrentOrders() async throws -> [OrderModel] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "order")
            .add(path: "current")
            .method(.get)
            .authentication({
                try? self.authenticationProvider.getAuthentication()
            })
            .decode(to: [OrderModel].self)
            .set(jsonDecoder: decoder)
            .perform()
    }
}

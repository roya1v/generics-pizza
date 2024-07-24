//
//  OrderRestaurantRepository.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 29/03/2023.
//

import Foundation
import Combine
import SharedModels
import clients_libraries_SwiftlyHttp

public func buildOrderRestaurantRepository(url: String,
                                           authenticationProvider: some AuthenticationProvider) -> OrderRestaurantRepository {
    OrderRestaurantRepositoryImpl(baseURL: url, authenticationProvider: authenticationProvider)
}

public protocol OrderRestaurantRepository {
    func getFeed() async throws -> AnyPublisher<RestaurantFromServerMessage, Error>
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

    func getFeed() async throws -> AnyPublisher<RestaurantFromServerMessage, Error> {
        let currentOrders = try await getCurrentOrders()

        socket = try await SwiftlyHttp(baseURL: "ws://localhost:8080")!
            .add(path: "order")
            .add(path: "activity")
            .websocket()

        if case let .bearer(token) = try? authenticationProvider.getAuthentication() {
            try await socket?.send(message: .string(token))
        }

        return socket!
            .messagePublisher
            .compactMap({
                if case let .string(message) = $0 {
                    return message.data(using: .utf8)
                } else {
                    return nil
                }
            })
            .decode(type: RestaurantFromServerMessage.self, decoder: JSONDecoder())
            .prepend(currentOrders.map { .newOrder($0) })
            .eraseToAnyPublisher()
    }

    func send(message: RestaurantToServerMessage) async throws {
        let data = try JSONEncoder().encode(message)
        let text = String(data: data, encoding: .utf8)
        try await socket?.send(message: .string(text ?? ""))
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

//
//  OrderRestaurantRepository.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 29/03/2023.
//

import Foundation
import Combine
import SharedModels
import SwiftlyHttp

public func buildOrderRestaurantRepository(url: String) -> OrderRestaurantRepository {
    OrderRestaurantRepositoryImpl(baseURL: url)
}

public func mockOrderRestaurantRepository() -> OrderRestaurantRepository {
    OrderRestaurantRepositoryMck()
}

public protocol OrderRestaurantRepository {
    func getFeed() async throws -> AnyPublisher<OrderMessage, Error>
    func send(message: OrderMessage) async throws
    var authDelegate: AuthorizationDelegate? { get set}
}

final class OrderRestaurantRepositoryImpl: OrderRestaurantRepository {

    var authDelegate: AuthorizationDelegate?

    private var socket: SwiftlyWebSocketConnection?
    private let feed = PassthroughSubject<OrderMessage, Never>()

    private let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    // MARK: - OrderRestaurantRepository

    func getFeed() async throws -> AnyPublisher<OrderMessage, Error> {
        let currentOrders = try await getCurrentOrders()
        currentOrders.forEach { order in
            feed.send(.newOrder(order: order))
        }

        socket = try await SwiftlyHttp(baseURL: "ws://localhost:8080")!
            .add(path: "order")
            .add(path: "activity")
            .authorizationDelegate(authDelegate!)
            .websocket()

        return socket!
            .messagePublisher
            .compactMap({
                if case let .string(message) = $0 {
                    return message
                } else {
                    return nil
                }
            })
            .tryMap(OrderMessage.decode)
            .prepend(currentOrders.map { .newOrder(order: $0) })
            .eraseToAnyPublisher()
    }

    func send(message: OrderMessage) async throws {
        try await socket?.send(message: .string(message.encode() ?? ""))
    }

    private func getCurrentOrders() async throws -> [OrderModel] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "order")
            .add(path: "current")
            .method(.get)
            .authorizationDelegate(authDelegate!)
            .decode(to: [OrderModel].self)
            .set(jsonDecoder: decoder)
            .perform()
    }
}

final class OrderRestaurantRepositoryMck: OrderRestaurantRepository {

    var authDelegate: AuthorizationDelegate?

    func getFeed() async throws -> AnyPublisher<OrderMessage, Error> {
        return PassthroughSubject().eraseToAnyPublisher()
    }

    func send(message: OrderMessage) async throws {
    }
}

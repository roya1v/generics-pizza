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
    func getFeed() async throws -> AnyPublisher<RestaurantFromServerMessage, Error>
    func send(message: RestaurantToServerMessage) async throws
    var authDelegate: AuthorizationDelegate? { get set}
}

final class OrderRestaurantRepositoryImpl: OrderRestaurantRepository {

    var authDelegate: AuthorizationDelegate?

    private var socket: SwiftlyWebSocketConnection?

    private let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    // MARK: - OrderRestaurantRepository

    func getFeed() async throws -> AnyPublisher<RestaurantFromServerMessage, Error> {
        let currentOrders = try await getCurrentOrders()

        socket = try await SwiftlyHttp(baseURL: "ws://localhost:8080")!
            .add(path: "order")
            .add(path: "activity")
            .authorizationDelegate(authDelegate!)
            .websocket()

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

    func getFeed() async throws -> AnyPublisher<RestaurantFromServerMessage, Error> {
        return PassthroughSubject().eraseToAnyPublisher()
    }

    func send(message: RestaurantToServerMessage) async throws {
    }
}

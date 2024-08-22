//
//  OrderRepository.swift
//  GenericsApp
//
//  Created by Mike S. on 21/03/2023.
//

import Foundation
import SharedModels
import clients_libraries_SwiftlyHttp
import Combine

public func buildOrderRepository(url: String) -> OrderRepository {
    OrderRepositoryImpl(baseURL: url)
}

public enum OrderError: Error {
    case noAddress
}

public protocol OrderRepository {
    func checkPrice(for items: [MenuItem]) async throws -> [SubtotalModel]
    func placeOrder(for items: [MenuItem]) async throws -> AnyPublisher<CustomerFromServerMessage, Error>
}

final class OrderRepositoryImpl: OrderRepository {

    private var socket: SwiftlyWebSocketConnection?
    private let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    // MARK: - OrderRepository

    func checkPrice(for items: [MenuItem]) async throws -> [SubtotalModel] {
        return try await getRequest()
            .add(path: "check_price")
            .body(OrderModel(createdAt: nil, items: items, type: .pickUp))
            .decode(to: [SubtotalModel].self)
            .perform()
    }

    func placeOrder(for items: [MenuItem]) async throws -> AnyPublisher<CustomerFromServerMessage, Error> {
        let order = try await makeOrderRequest(items: items)

        socket = try await SwiftlyHttp(baseURL: "ws://localhost:8080")!
            .add(path: "order")
            .add(path: "activity")
            .add(path: order.id!.uuidString)
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
            .decode(type: CustomerFromServerMessage.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    private func makeOrderRequest(items: [MenuItem]) async throws -> OrderModel {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try await getRequest()
            .body(OrderModel(createdAt: nil, items: items, type: .pickUp))
            .decode(to: OrderModel.self)
            .set(jsonDecoder: decoder)
            .perform()
    }

    private func getRequest() -> SwiftlyHttp {
        SwiftlyHttp(baseURL: baseURL)!
            .add(path: "order")
            .method(.post)
    }
}

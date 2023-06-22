//
//  OrderRepository.swift
//  GenericsApp
//
//  Created by Mike S. on 21/03/2023.
//

import Foundation
import GenericsModels
import SwiftlyHttp
import Combine

public func buildOrderRepository(url: String) -> OrderRepository {
    OrderRepositoryImpl(baseURL: url)
}

public func mockOrderRepository() -> OrderRepository {
    OrderRepositoryMck()
}

public protocol OrderRepository {
    func add(item: MenuItem)
    func checkPrice() async throws -> [SubtotalModel]
    func placeOrder() async throws -> AnyPublisher<OrderMessage, Error>
    var items: [MenuItem] { get }
}

final class OrderRepositoryImpl: OrderRepository {

    var items = [MenuItem]()

    private var socket: SwiftlyWebSocketConnection?
    private let messages = PassthroughSubject<OrderMessage, Never>()
    private let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
        if let data = UserDefaults.standard.data(forKey: "order-items") {
            items = (try? PropertyListDecoder().decode([MenuItem].self, from: data)) ?? []
        }
    }

    func add(item: MenuItem) {
        items.append(item)
        if let data = try? PropertyListEncoder().encode(items) {
            UserDefaults.standard.setValue(data, forKey: "order-items")
        }
    }

    func checkPrice() async throws -> [SubtotalModel] {
        try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "order")
            .add(path: "check_price")
            .method(.post)
            .body(OrderModel(createdAt: nil, items: items))
            .decode(to: [SubtotalModel].self)
            .perform()
    }

    func placeOrder() async throws -> AnyPublisher<OrderMessage, Error> {
        let order = try await makeOrderRequest()

        socket = SwiftlyHttp(baseURL: "ws://localhost:8080")!
            .add(path: "order")
            .add(path: "activity")
            .add(path: order.id!.uuidString)
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
            .eraseToAnyPublisher()
    }

    private func makeOrderRequest() async throws -> OrderModel {
        let response = try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "order")
            .method(.post)
            .body(OrderModel(createdAt: nil, items: items))
            .perform()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(OrderModel.self, from: response.0)
    }
}

final class OrderRepositoryMck: OrderRepository {
    func add(item: MenuItem) {
    }

    func checkPrice() async throws -> [SubtotalModel] {
        fatalError()
    }

    func placeOrder() async throws -> AnyPublisher<OrderMessage, Error> {
        fatalError()
    }

    var items: [MenuItem] = [
        .init(id: .init(), title: "Margarita simplita", description: "Tomatoe souce, cheese and weird leaves", price: 100),
        .init(id: .init(), title: "Pepperoni Meroni", description: "Tomatoe souce, cheese and weird leaves", price: 100),
        .init(id: .init(), title: "Super pepperoni", description: "Tomatoe souce, cheese and weird leaves", price: 100)
    ]
}

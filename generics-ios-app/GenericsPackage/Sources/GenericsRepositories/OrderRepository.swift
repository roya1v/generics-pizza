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
    var items: [MenuItem] { get }
    func add(item: MenuItem)
    func checkPrice() async throws -> [SubtotalModel]
    func placeOrder() async throws -> AnyPublisher<OrderMessage, Error>
}

final class OrderRepositoryImpl: OrderRepository {
    private var socket: SwiftlyWebSocketConnection?
    private let messages = PassthroughSubject<OrderMessage, Never>()
    private let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
        if let data = UserDefaults.standard.data(forKey: "order-items") {
            items = (try? PropertyListDecoder().decode([MenuItem].self, from: data)) ?? []
        }
    }

    // MARK: - OrderRepository

    var items = [MenuItem]()

    func add(item: MenuItem) {
        items.append(item)
        if let data = try? PropertyListEncoder().encode(items) {
            UserDefaults.standard.setValue(data, forKey: "order-items")
        }
    }

    func checkPrice() async throws -> [SubtotalModel] {
        try await getRequest()
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
        let response = try await getRequest()
            .method(.post)
            .body(OrderModel(createdAt: nil, items: items))
            .perform()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(OrderModel.self, from: response.0)
    }

    private func getRequest() -> SwiftlyHttp {
        SwiftlyHttp(baseURL: baseURL)!
            .add(path: "order")
    }
}

final class OrderRepositoryMck: OrderRepository {

    var items: [MenuItem] = [
        .init(id: .init(), title: "Margarita simplita", description: "Tomatoe souce, cheese and weird leaves", price: 100),
        .init(id: .init(), title: "Pepperoni Meroni", description: "Tomatoe souce, cheese and weird leaves", price: 100),
        .init(id: .init(), title: "Super pepperoni", description: "Tomatoe souce, cheese and weird leaves", price: 100)
    ]

    var addImplementation: ((MenuItem) -> Void)?
    func add(item: MenuItem) {
        addImplementation?(item)
    }

    var checkPriceImplementation: (() async throws -> [SubtotalModel])?
    func checkPrice() async throws -> [SubtotalModel] {
        if let checkPriceImplementation {
            return try await checkPriceImplementation()
        } else {
            fatalError()
        }
    }

    var placeOrderImplementation: (() async throws -> AnyPublisher<OrderMessage, Error>)?
    func placeOrder() async throws -> AnyPublisher<OrderMessage, Error> {
        if let placeOrderImplementation {
            return try await placeOrderImplementation()
        } else {
            fatalError()
        }
    }
}

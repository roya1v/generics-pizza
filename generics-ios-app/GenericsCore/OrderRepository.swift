//
//  OrderRepository.swift
//  GenericsApp
//
//  Created by Mike S. on 21/03/2023.
//

import Foundation
import SharedModels
import SwiftlyHttp
import Combine

public func buildOrderRepository(url: String) -> OrderRepository {
    OrderRepositoryImpl(baseURL: url)
}

public func mockOrderRepository() -> OrderRepository {
    OrderRepositoryMck()
}

public enum OrderError: Error {
    case noAddress
}

public protocol OrderRepository {
    var items: [MenuItem] { get }
    var address: AddressModel? { get set }
    func add(item: MenuItem)
    func checkPrice() async throws -> [SubtotalModel]
    func checkRestaurantLocation(for location: MapPointModel) async throws -> AddressModel
    func placeOrder() async throws -> AnyPublisher<CustomerFromServerMessage, Error>
}

final class OrderRepositoryImpl: OrderRepository {
    private var socket: SwiftlyWebSocketConnection?
    private let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
        if let data = UserDefaults.standard.data(forKey: "order-items") {
            items = (try? PropertyListDecoder().decode([MenuItem].self, from: data)) ?? []
        }
    }

    // MARK: - OrderRepository

    private(set) var items = [MenuItem]()

    var address: AddressModel?

    func add(item: MenuItem) {
        items.append(item)
        if let data = try? PropertyListEncoder().encode(items) {
            UserDefaults.standard.setValue(data, forKey: "order-items")
        }
    }

    func checkPrice() async throws -> [SubtotalModel] {
        guard let address else {
            throw OrderError.noAddress
        }
        return try await getRequest()
            .add(path: "check_price")
            .body(OrderModel(createdAt: nil, items: items, address: address))
            .decode(to: [SubtotalModel].self)
            .perform()
    }

    func placeOrder() async throws -> AnyPublisher<CustomerFromServerMessage, Error> {
        guard address != nil else {
            throw OrderError.noAddress
        }

        let order = try await makeOrderRequest()

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

    func checkRestaurantLocation(for location: MapPointModel) async throws -> AddressModel {
        try await getRequest()
            .add(path: "check_location")
            .body(location)
            .decode(to: AddressModel.self)
            .perform()
    }

    private func makeOrderRequest() async throws -> OrderModel {
        let response = try await getRequest()
            .body(OrderModel(createdAt: nil, items: items, address: address!))
            .perform()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(OrderModel.self, from: response.0)
    }

    private func getRequest() -> SwiftlyHttp {
        SwiftlyHttp(baseURL: baseURL)!
            .add(path: "order")
            .method(.post)
    }
}

final class OrderRepositoryMck: OrderRepository {

    var address: AddressModel?

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

    var placeOrderImplementation: (() async throws -> AnyPublisher<CustomerFromServerMessage, Error>)?
    func placeOrder() async throws -> AnyPublisher<CustomerFromServerMessage, Error> {
        if let placeOrderImplementation {
            return try await placeOrderImplementation()
        } else {
            fatalError()
        }
    }

    func checkRestaurantLocation(for location: SharedModels.MapPointModel) async throws -> AddressModel {
        fatalError()
    }
}

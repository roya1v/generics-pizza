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
    func remove(item: MenuItem)
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
    
    func remove(item: SharedModels.MenuItem) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
        }

        if let data = try? PropertyListEncoder().encode(items) {
            UserDefaults.standard.setValue(data, forKey: "order-items")
        }
    }

    func checkPrice() async throws -> [SubtotalModel] {
        //TODO: Make address optional
        return try await getRequest()
            .add(path: "check_price")
            .body(OrderModel(createdAt: nil, items: items))
            .decode(to: [SubtotalModel].self)
            .perform()
    }

    func placeOrder() async throws -> AnyPublisher<CustomerFromServerMessage, Error> {
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
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try await getRequest()
            .body(OrderModel(createdAt: nil, items: items))
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

final class OrderRepositoryMck: OrderRepository {

    var address: AddressModel?

    var items: [MenuItem] = [
        .init(id: .init(), title: "Margarita simplita", description: "Tomatoe souce, cheese and weird leaves", price: 1299),
        .init(id: .init(), title: "Pepperoni Meroni", description: "Tomatoe souce, cheese and weird leaves", price: 1299),
        .init(id: .init(), title: "Super pepperoni", description: "Tomatoe souce, cheese and weird leaves", price: 1299)
    ]

    var addImplementation: ((MenuItem) -> Void)?
    func add(item: MenuItem) {
        addImplementation?(item)
    }

    func remove(item: SharedModels.MenuItem) {

    }

    var checkPriceImplementation: (() async throws -> [SubtotalModel])?
    func checkPrice() async throws -> [SubtotalModel] {
        if let checkPriceImplementation {
            return try await checkPriceImplementation()
        } else {
            return [
                .init(name: "Margarita simplita", value: 1299),
                .init(name: "Pepperoni Meroni", value: 1299),
                .init(name: "Super pepperoni", value: 1299),
                .init(name: "Total", value: 3897, isSecondary: false)
            ]
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

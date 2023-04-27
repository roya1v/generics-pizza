//
//  OrderRepository.swift
//  GenericsApp
//
//  Created by Mike S. on 21/03/2023.
//

import Foundation
import GenericsModels
import GenericsHttp
import Combine

public func buildOrderRepository(url: String) -> OrderRepository {
    OrderRepositoryImpl(baseURL: url)
}

public func mockOrderRepository() -> OrderRepository {
    OrderRepositoryMck()
}

public protocol OrderRepository {
    func add(item: MenuItem)
    func placeOrder() async throws -> AnyPublisher<OrderMessage, Never>
    var items: [MenuItem] { get }
}

final class OrderRepositoryImpl: OrderRepository {

    var items = [MenuItem]()

    private var socket: URLSessionWebSocketTask?
    private let messages = PassthroughSubject<OrderMessage, Never>()
    private let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    func add(item: MenuItem) {
        items.append(item)
    }

    func placeOrder() async throws -> AnyPublisher<OrderMessage, Never> {
        let order = try await makeOrderRequest()

        socket = URLSession.shared
            .webSocketTask(with: URL(string: "ws://localhost:8080/order/activity/\(order.id!.uuidString)")!)


        receive()
        socket?.resume()
        return messages.eraseToAnyPublisher()
    }

    private func receive() {
        socket?.receive(completionHandler: { result in
            print(result)
            switch result {
            case .success(let success2):
                switch success2 {
                case .string(let data):
                    let message = try! OrderMessage.decode(from: data)
                    self.messages.send(message)
                default:
                    return
                }
            case .failure(_):
                return
            }
            self.receive()
        })
    }

    private func makeOrderRequest() async throws -> OrderModel {
        let response = try await GenericsHttp(baseURL: baseURL)!
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

    func placeOrder() async throws -> AnyPublisher<OrderMessage, Never> {
        fatalError()
    }

    var items: [MenuItem] = [
        .init(id: .init(), title: "Margarita simplita", description: "Tomatoe souce, cheese and weird leaves"),
        .init(id: .init(), title: "Pepperoni Meroni", description: "Tomatoe souce, cheese and weird leaves"),
        .init(id: .init(), title: "Super pepperoni", description: "Tomatoe souce, cheese and weird leaves")
    ]
}
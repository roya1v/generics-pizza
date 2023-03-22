//
//  OrderRepository.swift
//  GenericsApp
//
//  Created by Mike S. on 21/03/2023.
//

import Foundation
import GenericsModels
import GenericsHttp
import Factory
import Combine

extension Container {
    static let orderRepository = Factory(scope: .singleton) { OrderRepositoryImpl() as OrderRepository }
}

protocol OrderRepository {
    func add(item: MenuItem)
    func placeOrder() async throws -> AnyPublisher<String, Never>
}

final class OrderRepositoryImpl: OrderRepository {

    var items = [MenuItem]()

    private var socket: URLSessionWebSocketTask?

    private let messages = PassthroughSubject<String, Never>()

    func add(item: MenuItem) {
        items.append(item)
    }

    func placeOrder() async throws -> AnyPublisher<String, Never> {
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
                    if let type = OrderMessageType.decode(from: data) {
                        switch type {
                        case .update:
                            self.messages.send(data)
                        case .accepted:
                            return
                        case .newOrder:
                            return
                        }
                    }
                default:
                    return
                }
            case .failure(let failure):
                return
            }
            self.receive()
        })
    }

    private func makeOrderRequest() async throws -> OrderModel {
        let response = try await GenericsHttp(baseURL: "http://localhost:8080")!
            .add(path: "order")
            .method(.post)
            .body(OrderModel(items: items))
            .perform()

        return try JSONDecoder().decode(OrderModel.self, from: response.0)
    }
}

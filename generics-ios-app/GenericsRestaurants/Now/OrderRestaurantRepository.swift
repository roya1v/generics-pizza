//
//  OrderRestaurantRepository.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 29/03/2023.
//

import Foundation
import Combine
import GenericsModels
import Factory
import GenericsHttp

extension Container {
    static let orderRepository = Factory(scope: .singleton) { OrderRestaurantRepositoryImpl() as OrderRestaurantRepository }
}

protocol OrderRestaurantRepository {
    func getFeed() async throws -> AnyPublisher<OrderMessage, Never>
    func send(message: OrderMessage) async throws
    var authDelegate: AuthorizationDelegate? { get set}
}


final class OrderRestaurantRepositoryImpl: OrderRestaurantRepository {

    private let feed = PassthroughSubject<OrderMessage, Never>()

    var authDelegate: AuthorizationDelegate?

    private var socket: URLSessionWebSocketTask?

    func getFeed() async throws -> AnyPublisher<OrderMessage, Never> {
        let currentOrders = try await getCurrentOrders()
        currentOrders.forEach { order in
            feed.send(.newOrder(order: order))
        }

        var req = URLRequest(url: URL(string: "ws://localhost:8080/order/activity/")!)



        var auth = try authDelegate?.getAuthorization()

        switch auth {
        case .basic(_, _):
            fatalError()
        case .bearer(let token):
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        default:
            fatalError()
        }

        socket = URLSession.shared
            .webSocketTask(with: req)


        receive()
        socket?.resume()
        return feed.eraseToAnyPublisher()

        return feed.eraseToAnyPublisher()
    }

    func send(message: OrderMessage) async throws {
        try await socket?.send(.string(message.encode() ?? ""))
    }

    private func receive() {
        socket?.receive(completionHandler: { result in
            print(result)
            switch result {
            case .success(let success2):
                switch success2 {
                case .string(let data):
                    let message = try! OrderMessage.decode(from: data)
                    self.feed.send(message)
                default:
                    return
                }
            case .failure(let failure):
                return
            }
            self.receive()
        })
    }

    private func getCurrentOrders() async throws -> [OrderModel] {
        let response = try await GenericsHttp(baseURL: "http://localhost:8080")!
            .add(path: "order")
            .add(path: "current")
            .method(.get)
            .authorizationDelegate(authDelegate!)
            .perform()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([OrderModel].self, from: response.0)
    }
}

final class OrderRestaurantRepositoryMck: OrderRestaurantRepository {
    func getFeed() async throws -> AnyPublisher<OrderMessage, Never> {
        return Just<OrderMessage>(.newOrder(order: .init(id: UUID(), createdAt: .now, items: [], state: .new))).eraseToAnyPublisher()
    }

    func send(message: OrderMessage) async throws {

    }

    var authDelegate: AuthorizationDelegate?
}

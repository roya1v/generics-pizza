import Combine
import Foundation
import SharedModels
import SwiftlyHttp

public func buildOrderRepository(url: String) -> OrderRepository {
    OrderRepositoryImpl(baseURL: url)
}

public enum OrderError: Error {
    case noAddress
}

public protocol OrderRepository {
    func checkPrice(for items: [OrderModel.Item], destination: OrderModel.Destination) async throws
        -> [SubtotalModel]
    func placeOrder(for items: [OrderModel.Item], destination: OrderModel.Destination) async throws
        -> OrderModel
    func trackOrder(_ order: OrderModel) -> AnyPublisher<CustomerFromServerMessage, Error>
}

final class OrderRepositoryImpl: OrderRepository {

    private var socket: SwiftlyWebSocketConnection?
    private let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    // MARK: - OrderRepository

    func checkPrice(for items: [OrderModel.Item], destination: OrderModel.Destination) async throws
        -> [SubtotalModel] {
        return try await getRequest()
            .add(path: "check_price")
            .body(OrderModel(createdAt: nil, items: items, destination: destination))
            .decode(to: [SubtotalModel].self)
            .perform()
    }

    func placeOrder(for items: [OrderModel.Item], destination: OrderModel.Destination) async throws
        -> OrderModel {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try await getRequest()
            .body(OrderModel(createdAt: nil, items: items, destination: destination))
            .decode(to: OrderModel.self)
            .set(jsonDecoder: decoder)
            .perform()
    }

    func trackOrder(_ order: OrderModel) -> AnyPublisher<CustomerFromServerMessage, Error> {
        Future { fulfill in
            Task {
                self.socket = try await SwiftlyHttp(baseURL: "ws://localhost:8080")!
                    .add(path: "order")
                    .add(path: "activity")
                    .add(path: order.id!.uuidString)
                    .websocket()

                fulfill(.success(self.socket!
                    .messagePublisher
                    .compactMap({
                        if case let .string(message) = $0 {
                            return message.data(using: .utf8)
                        } else {
                            return nil
                        }
                    })
                    .decode(type: CustomerFromServerMessage.self, decoder: JSONDecoder())
                    .eraseToAnyPublisher()))

            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }

    private func getRequest() -> SwiftlyHttp {
        SwiftlyHttp(baseURL: baseURL)!
            .add(path: "order")
            .method(.post)
    }
}

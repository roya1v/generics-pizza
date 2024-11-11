import Combine
import Foundation
import SharedModels
import SwiftlyHttp

public func buildDriverRepository(
    url: String,
    authenticationProvider: some AuthenticationProvider
) -> DriverRepository {
    DriverRepositoryImpl(baseURL: url, authenticationProvider: authenticationProvider)
}

public protocol DriverRepository {
    func getFeed() -> AnyPublisher<DriverFromServerMessage, Error>
    func send(_ message: DriverToServerMessage) async throws
}

public enum DriverFeedError: Error {
    case unknownMessage(URLSessionWebSocketTask.Message)
}

final class DriverRepositoryImpl: DriverRepository {
    private let baseURL: String
    private let authenticationProvider: AuthenticationProvider

    private var socket: SwiftlyWebSocketConnection?

    init(
        baseURL: String,
        authenticationProvider: AuthenticationProvider
    ) {
        self.baseURL = baseURL
        self.authenticationProvider = authenticationProvider
    }

    func getFeed() -> AnyPublisher<DriverFromServerMessage, Error> {
        return Future { fulfill in
            Task {
                self.socket = try await SwiftlyHttp(baseURL: "ws://localhost:8080")!
                    .add(path: "order")
                    .add(path: "activity")
                    .add(path: "driver")
                    .websocket()

                if case let .bearer(token) = try? self.authenticationProvider.getAuthentication() {
                    try await self.socket?.send(message: .string(token))
                }
                fulfill(.success(self.socket!
                    .messagePublisher
                    .compactMap({
                        if case let .string(message) = $0 {
                            return message.data(using: .utf8)
                        } else {
                            return nil
                        }
                    })
                        .decode(type: DriverFromServerMessage.self, decoder: JSONDecoder())
                        .eraseToAnyPublisher()))

            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }

    func send(_ message: DriverToServerMessage) async throws {
        let data = try JSONEncoder().encode(message)
        let string = String(decoding: data, as: UTF8.self)
        try await socket?.send(message: .string(string))
    }
}

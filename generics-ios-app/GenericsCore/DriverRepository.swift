//
//  DriverRepository.swift
//  GenericsDriver
//
//  Created by Mike S. on 16/08/2023.
//

import Foundation
import SwiftlyHttp
import Combine
import SharedModels

public func buildDriverRepository(url: String,
                                  authenticationRepository: AuthenticationRepository) -> DriverRepository {
    DriverRepositoryImpl(baseURL: url, authenticationRepository: authenticationRepository)
}

public func mockDriverRepository() -> DriverRepository {
    fatalError("Not yet implemented")
}

public protocol DriverRepository {
    func getFeed() async throws -> AnyPublisher<DriverFromServerMessage, Error>
    func send(_ message: DriverToServerMessage) async throws
}

public enum DriverFeedError: Error {
    case unknownMessage(URLSessionWebSocketTask.Message)
}

final class DriverRepositoryImpl: DriverRepository {
    private let baseURL: String
    private let authenticationRepository: AuthenticationRepository

    private var socket: SwiftlyWebSocketConnection?

    init(baseURL: String,
         authenticationRepository: AuthenticationRepository) {
        self.baseURL = baseURL
        self.authenticationRepository = authenticationRepository
    }

    func getFeed() async throws -> AnyPublisher<DriverFromServerMessage, Error> {
        if socket == nil {
            socket = try await SwiftlyHttp(baseURL: baseURL)!
                .add(path: "order")
                .add(path: "activity")
                .add(path: "driver")
                .authentication({
                    return try? self.authenticationRepository.getAuthentication()
                })
                .websocket()
        }

        return socket!
            .messagePublisher
            .tryMap({
                if case let .string(message) = $0,
                   let data = message.data(using: .utf8) {
                    return data
                } else {
                    throw DriverFeedError.unknownMessage($0)
                }
            })
            .decode(type: DriverFromServerMessage.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    func send(_ message: DriverToServerMessage) async throws {
        let data = try JSONEncoder().encode(message)
        let string = String(data: data, encoding: .utf8)!
        try await socket?.send(message: .string(string))
    }
}

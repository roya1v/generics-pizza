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
import GenericsCore

final class DriverRepository {

    private let authenticationRepository: AuthenticationRepository
    private var socket: SwiftlyWebSocketConnection?

    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }

    func getFeed() async throws -> AnyPublisher<DriverFromServerMessage, Error> {
        if socket == nil {
            socket = try await SwiftlyHttp(baseURL: "ws://localhost:8080")!
                .add(path: "order")
                .add(path: "activity")
                .add(path: "driver")
                .authorization({
                    return try? self.authenticationRepository.getAuthorization()
                })
                .websocket()
        }

        return socket!
            .messagePublisher
            .compactMap({
                if case let .string(message) = $0 {
                    return message.data(using: .utf8)
                } else {
                    return nil
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

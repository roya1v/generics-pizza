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

final class DriverRepository {

    private var socket: SwiftlyWebSocketConnection?

    func getFeed() async throws -> AnyPublisher<DriverFromServerMessage, Error> {
        if socket == nil {
            socket = try await SwiftlyHttp(baseURL: "ws://localhost:8080")!
                .add(path: "order")
                .add(path: "activity")
                .add(path: "driver")
                //.authorizationDelegate(authDelegate!)
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

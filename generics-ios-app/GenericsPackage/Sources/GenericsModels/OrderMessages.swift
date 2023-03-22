//
//  OrderMessages.swift
//  
//
//  Created by Mike S. on 21/03/2023.
//

import Foundation

public enum OrderMessageType: String, Codable {
    case update
    case accepted
    case newOrder

    public static func decode(from text: String) -> OrderMessageType? {
        if let data = text.data(using: .utf8),
           let basicMessage = try? JSONDecoder().decode(BasicOrderMessage.self, from: data) {
            return basicMessage.type
        } else {
            return nil
        }
    }
}

public protocol OrderMessage: Codable {
    var type: OrderMessageType { get }
}

public extension OrderMessage {
    static func decodeMessage(from text: String) -> Self? {
        if let data = text.data(using: .utf8),
           let message = try? JSONDecoder().decode(Self.self, from: data) {
            return message
        } else {
            return nil
        }
    }

    func encode() -> String? {
        if let data = try? JSONEncoder().encode(self),
           let string = String(data: data, encoding: .utf8) {
            return string
        } else {
            return nil
        }
    }
}

public struct BasicOrderMessage: OrderMessage {
    public let type: OrderMessageType

    public static func accepted() -> Self {
        .init(type: .accepted)
    }
}

public struct UpdateMessage: OrderMessage {
    public let id: UUID
    public let state: OrderState
    public var type: OrderMessageType = .update

    public init(id: UUID, state: OrderState) {
        self.id = id
        self.state = state
    }
}

public struct NewOrder: OrderMessage {
    public var type: OrderMessageType = .newOrder
    public let order: OrderModel

    public init(order: OrderModel) {
        self.order = order
    }
}

//
//  OrderMessages.swift
//  
//
//  Created by Mike S. on 21/03/2023.
//

import Foundation

public enum OrderMessage {
    case newOrder(order: OrderModel)
    case update(id: UUID, state: OrderState)
    case accepted


    public static func decode(from text: String) throws -> OrderMessage {
        guard let type = OrderMessageType.decode(from: text) else {
            fatalError()
        }

        switch type {
        case .update:
            let message = UpdateMessage.decodeMessage(from: text)!
            return .update(id: message.id, state: message.state)
        case .accepted:
            return .accepted
        case .newOrder:
            let message = NewOrder.decodeMessage(from: text)!
            return .newOrder(order: message.order)
        }
    }

    public func encode() -> String? {
        switch self {
        case .newOrder(let order):
            return NewOrder(order: order).encode()
        case .update(let id, let state):
            return UpdateMessage(id: id, state: state).encode()
        case .accepted:
            return BasicOrderMessage.accepted().encode()
        }
    }
}

enum OrderMessageType: String, Codable {
    case update
    case accepted
    case newOrder

    static func decode(from text: String) -> OrderMessageType? {
        if let data = text.data(using: .utf8),
           let basicMessage = try? JSONDecoder().decode(BasicOrderMessage.self, from: data) {
            return basicMessage.type
        } else {
            return nil
        }
    }
}

 protocol OrderMessageInternal: Codable {
    var type: OrderMessageType { get }
}

extension OrderMessageInternal {
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

public struct BasicOrderMessage: OrderMessageInternal {
    let type: OrderMessageType

    static func accepted() -> Self {
        .init(type: .accepted)
    }
}

struct UpdateMessage: OrderMessageInternal {
    let id: UUID
    let state: OrderState
    var type: OrderMessageType = .update

    init(id: UUID, state: OrderState) {
        self.id = id
        self.state = state
    }
}

struct NewOrder: OrderMessageInternal {
    var type: OrderMessageType = .newOrder
    let order: OrderModel

    init(order: OrderModel) {
        self.order = order
    }
}

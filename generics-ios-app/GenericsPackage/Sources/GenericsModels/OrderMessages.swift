//
//  OrderMessages.swift
//  
//
//  Created by Mike S. on 21/03/2023.
//

import Foundation

public struct UpdateMessage: Codable {
    public init(id: UUID, state: OrderState) {
        self.id = id
        self.state = state
    }

    public let id: UUID
    public let state: OrderState
}

public enum OrderMessages {
    case update(message: UpdateMessage)
    case accepted

}

public extension OrderMessages {

    private var messagePrefix: String {
        switch self {
        case .update(_):
            return "update-"
        case .accepted:
            return "accepted"
        }
    }

    static func parse(from message: String) -> OrderMessages? {
        if message.hasPrefix("update-") {
            var data = message
            data.removeFirst(7)
            let test = try! JSONDecoder().decode(UpdateMessage.self, fromString: data)
            return .update(message: test)
        }
        return nil
    }

    func encode() -> String {
        let encoder = JSONEncoder()
        switch self {
        case .update(let message):
            return "update-\(try! encoder.encodeToString(message))"
        case .accepted:
            return messagePrefix
        }
    }
}

fileprivate extension JSONDecoder {
    func decode<T>(_ type: T.Type, fromString string: String) throws -> T where T : Decodable {
        let data = string.data(using: .utf8)
        return try decode(type, from: data!)
    }
}

fileprivate extension JSONEncoder {
    func encodeToString<T>(_ value: T) throws -> String where T : Encodable {
        let data = try encode(value)
        return String(data: data, encoding: .utf8)!
    }
}

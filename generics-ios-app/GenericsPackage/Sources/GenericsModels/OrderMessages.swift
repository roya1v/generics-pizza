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


}

public extension OrderMessages {
    static func parse(from message: String) -> OrderMessages? {
        if message.hasPrefix("update-") {
            var data = message
            data.removeFirst(7)
            let test = try! JSONDecoder().decode(UpdateMessage.self, from: data.data(using: .utf8)!)
            return .update(message: test)
        }
        return nil
    }

    func encode() -> String {
        let encoder = JSONEncoder()
        switch self {
        case .update(let message):
            return "update-\(String(data: try! encoder.encode(message), encoding: .utf8)!)"
        }
    }
}

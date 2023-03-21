//
//  OrderModel.swift
//  
//
//  Created by Mike S. on 20/03/2023.
//

import Foundation

public struct OrderModel: Codable, Identifiable {
    public init(id: UUID? = nil, items: [MenuItem], state: OrderState? = nil) {
        self.id = id
        self.items = items
        self.state = state
    }

    public let id: UUID?
    public let items: [MenuItem]
    public let state: OrderState?
}

public enum OrderState: String, Codable {
    case new
    case inProgress
    case readyForDelivery
    case inDelivery
    case finished
}

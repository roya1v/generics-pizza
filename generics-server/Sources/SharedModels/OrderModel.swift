//
//  OrderModel.swift
//  
//
//  Created by Mike S. on 20/03/2023.
//

import Foundation

public struct OrderModel: Codable, Identifiable, Equatable {
    public init(id: UUID? = nil,
                createdAt: Date? = nil,
                items: [MenuItem],
                state: OrderState? = nil,
                type: OrderType) {
        self.id = id
        self.createdAt = createdAt
        self.items = items
        self.state = state
        self.type = type
    }

    public let id: UUID?
    public let createdAt: Date?
    public let items: [MenuItem]
    public let state: OrderState?
    public let type: OrderType
}

public enum OrderState: String, Codable {
    case new
    case inProgress
    case readyForDelivery
    case inDelivery
    case finished
}

public enum OrderType: Codable, Equatable {
    case delivery(address: String)
    case pickUp
}

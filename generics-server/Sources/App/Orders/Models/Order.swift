//
//  Order.swift
//  
//
//  Created by Mike S. on 16/03/2023.
//

import Fluent
import Vapor
import GenericsModels

final class Order: Model, Content {
    static var schema = "orders"

    @ID(key: .id)
    var id: UUID?

    @Enum(key: "state")
    var state: OrderState

    @Children(for: \.$order)
    var items: [OrderItem]

    init() { }

    public init(id: UUID? = nil, state: OrderState) {
        self.id = id
        self.state = state
    }
}

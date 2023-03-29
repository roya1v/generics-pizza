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

    func getContent() -> OrderModel {
        .init(id: id, items: items.map { $0.item.getContent() }, state: state)
    }
}

extension Order: Hashable {
    static func == (lhs: Order, rhs: Order) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension OrderModel: Content {
    
}
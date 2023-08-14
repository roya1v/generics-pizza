//
//  Order.swift
//  
//
//  Created by Mike S. on 16/03/2023.
//

import Fluent
import Vapor
import GenericsModels

final class OrderEntry: Model, Content {
    static var schema = "orders"

    @ID(key: .id)
    var id: UUID?

    @Timestamp(key: "created_at", on: .create, format: .unix)
    var createdAt: Date?

    @Enum(key: "state")
    var state: OrderState

    @Children(for: \.$order)
    var items: [OrderItemEntry]

    init() { }

    public init(id: UUID? = nil, state: OrderState) {
        self.id = id
        self.state = state
    }

    func getContent() -> OrderModel {
        .init(id: id, createdAt: createdAt, items: items.map { $0.item.getContent() }, state: state)
    }
}

extension OrderEntry: Hashable {
    static func == (lhs: OrderEntry, rhs: OrderEntry) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension OrderModel: Content {

}

//
//  Order.swift
//  
//
//  Created by Mike S. on 16/03/2023.
//

import Fluent
import Vapor
import SharedModels

final class OrderEntry: Model {
    static var schema = "orders"

    @ID(key: .id)
    var id: UUID?

    @Timestamp(key: "created_at", on: .create, format: .unix)
    var createdAt: Date?

    @Enum(key: "state")
    var state: OrderState

    @Children(for: \.$order)
    var items: [OrderItemEntry]

    @Field(key: "address")
    var address: String?

    init() { }

    public init(id: UUID? = nil, state: OrderState, address: String?) {
        self.id = id
        self.state = state
        self.address = address
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

extension OrderEntry: SharedModelRepresentable {
    func toSharedModel() -> OrderModel {
        .init(id: id,
              createdAt: createdAt,
              items: items.map { $0.item.toSharedModel() },
              state: state,
              type: address != nil ? .delivery(address: address!) : .pickUp)
    }
}

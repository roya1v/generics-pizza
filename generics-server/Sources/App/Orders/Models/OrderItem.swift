//
//  OrderItem.swift
//  
//
//  Created by Mike S. on 19/03/2023.
//

import Fluent
import Vapor
import GenericsModels

final class OrderItem: Model, Content {
    static var schema = "ordered_items"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "menu_item")
    var item: MenuEntry

    @Parent(key: "order")
    var order: Order

    init() { }
}

//
//  MenuEntry.swift
//  
//
//  Created by Mike Shevelinsky on 01/02/2023.
//

import Fluent
import Vapor
import SharedModels

final class MenuEntry: Model {
    static var schema = "menu"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "description")
    var description: String

    @Field(key: "image_url")
    var imageUrl: String?

    @Field(key: "price")
    var price: Int

    init() { }

    init(id: UUID? = nil,
         title: String,
         description: String,
         price: Int,
         imageUrl: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.imageUrl = imageUrl
    }
}

extension MenuEntry: SharedModelRepresentable {
    func toSharedModel() -> MenuItem {
        .init(id: id, title: title, description: description, price: price)
    }
}

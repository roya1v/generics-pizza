//
//  MenuEntry.swift
//  
//
//  Created by Mike Shevelinsky on 01/02/2023.
//

import Fluent
import Vapor

final class MenuEntry: Model, Content {
    static var schema = "menu"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "description")
    var description: String

    @Field(key: "image_url")
    var imageUrl: String?

    init() { }

    init(id: UUID? = nil,
         title: String,
         description: String,
         imageUrl: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
    }
}

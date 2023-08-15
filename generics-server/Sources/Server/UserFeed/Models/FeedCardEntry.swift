//
//  FeedCardEntry.swift
//  
//
//  Created by Mike S. on 23/07/2023.
//

import Fluent
import Vapor

final class FeedCardEntry: Model, Content {
    static var schema = "feed_cards"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String?

    @Field(key: "subtitle")
    var subtitle: String?

    @Field(key: "cta")
    var cta: String?

    @Field(key: "image")
    var image: String?

    init() { }

    init(title: String? = nil,
         subtitle: String? = nil,
         cta: String? = nil,
         image: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.cta = cta
        self.image = image
    }
}

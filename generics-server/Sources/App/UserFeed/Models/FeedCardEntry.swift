//
//  FeedCard.swift
//  
//
//  Created by Mike S. on 23/07/2023.
//

import Fluent
import Vapor

final class FeedCard: Model, Content {
    static var schema = "feed_cards"

    @ID(key: .id)
    var id: UUID?



    init() { }
}

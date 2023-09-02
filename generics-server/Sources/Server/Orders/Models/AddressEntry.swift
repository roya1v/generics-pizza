//
//  AddressEntry.swift
//  
//
//  Created by Mike S. on 02/09/2023.
//

import Fluent
import Vapor

final class AddressEntry: Model {
    static var schema = "addresses"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "details")
    var details: String?

    init() { }
}

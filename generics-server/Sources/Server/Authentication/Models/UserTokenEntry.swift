//
//  UserTokenEntry.swift
//  
//
//  Created by Mike Shevelinsky on 13/02/2023.
//

import Fluent
import Vapor

final class UserTokenEntry: Model, Content {
    static let schema = "user_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "value")
    var value: String

    @Parent(key: "user_id")
    var user: UserEntry

    init() { }

    init(id: UUID? = nil, value: String, userID: UserEntry.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}

// MARK: - ModelTokenAuthenticatable

extension UserTokenEntry: ModelTokenAuthenticatable {
    static let valueKey = \UserTokenEntry.$value
    static let userKey = \UserTokenEntry.$user

    var isValid: Bool {
        true
    }
}

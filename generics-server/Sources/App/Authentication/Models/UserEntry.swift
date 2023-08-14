//
//  UserEntry.swift
//  
//
//  Created by Mike Shevelinsky on 13/02/2023.
//

import Fluent
import Vapor

final class UserEntry: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String

    @Enum(key: "access")
    var access: AccessLevel

    init() { }

    init(id: UUID? = nil,
         email: String,
         passwordHash: String,
         access: AccessLevel = .client) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
        self.access = access
    }

    func generateToken() throws -> UserTokenEntry {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }

    struct Create: Content {
        var email: String
        var password: String
        var confirmPassword: String
    }
}

enum AccessLevel: String, Content {
    case client
    case employee
    case admin
}

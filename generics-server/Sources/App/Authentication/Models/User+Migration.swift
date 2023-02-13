//
//  User+Migration.swift
//  
//
//  Created by Mike Shevelinsky on 13/02/2023.
//

import Fluent
import Vapor

extension User {
    struct Migration: AsyncMigration {
        var name: String { "CreateUser" }

        func prepare(on database: Database) async throws {
            try await database.schema("users")
                .id()
                .field("email", .string, .required)
                .field("password_hash", .string, .required)
                .field("access", .string, .required)
                .unique(on: "email")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("users").delete()
        }
    }
}

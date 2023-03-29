//
//  Order+Migration.swift
//  
//
//  Created by Mike S. on 19/03/2023.
//

import Fluent
import Vapor

extension Order {
    struct Migration: AsyncMigration {
        var name: String { "CreateOrder" }

        func prepare(on database: Database) async throws {
            try await database.schema("orders")
                .id()
                .field("state", .string, .required)
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("orders").delete()
        }
    }
}
//
//  OrderEntry+Migration.swift
//  
//
//  Created by Mike S. on 19/03/2023.
//

import Fluent
import Vapor

extension OrderEntry {
    struct Migration: AsyncMigration {
        var name: String { "CreateOrder" }

        func prepare(on database: Database) async throws {
            try await database.schema("orders")
                .id()
                .field("state", .string, .required)
                .field("created_at", .double)
                .field("address_id", .uuid, .required, .references("addresses", "id"))
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("orders").delete()
        }
    }
}

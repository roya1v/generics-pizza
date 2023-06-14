//
//  MenuEntry+Migration.swift
//  
//
//  Created by Mike Shevelinsky on 16/02/2023.
//

import Fluent
import Vapor

extension MenuEntry {
    struct Migration: AsyncMigration {
        var name: String { "CreateMenu" }

        func prepare(on database: Database) async throws {
            try await database.schema("menu")
                .id()
                .field("title", .string, .required)
                .field("description", .string, .required)
                .field("price", .int, .required)
                .field("image_url", .string)
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("menu").delete()
        }
    }
}

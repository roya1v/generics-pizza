//
//  AddressEntry+Migration.swift
//  
//
//  Created by Mike S. on 02/09/2023.
//

import Fluent
import Vapor

extension AddressEntry {
    struct Migration: AsyncMigration {
        var name: String { "CreateAddress" }

        func prepare(on database: Database) async throws {
            try await database.schema(AddressEntry.schema)
                .id()
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema(AddressEntry.schema).delete()
        }
    }
}

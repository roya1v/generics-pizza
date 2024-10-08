import Fluent
import Vapor

extension AddressEntry {
    struct Migration: AsyncMigration {
        var name: String { "CreateAddress" }

        func prepare(on database: Database) async throws {
            try await database.schema(AddressEntry.schema)
                .id()
                .field("details", .string)
                .field("latitude", .double, .required)
                .field("longitude", .double, .required)
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema(AddressEntry.schema).delete()
        }
    }
}

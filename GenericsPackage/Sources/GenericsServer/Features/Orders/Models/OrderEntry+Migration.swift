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
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("orders").delete()
        }
    }
}

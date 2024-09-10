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
                .field("is_hidden", .bool, .required)
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("menu").delete()
        }
    }
}

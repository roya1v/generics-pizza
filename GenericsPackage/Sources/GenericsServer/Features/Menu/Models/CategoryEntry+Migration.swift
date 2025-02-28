import Fluent
import Vapor

extension CategoryEntry {
    struct Migration: AsyncMigration {
        var name: String { "CreateCategories" }

        func prepare(on database: Database) async throws {
            try await database.schema("categories")
                .id()
                .field("name", .string, .required)
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("categories").delete()
        }
    }
}

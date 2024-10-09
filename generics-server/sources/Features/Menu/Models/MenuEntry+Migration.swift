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
                .field("is_hidden", .bool, .required)
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("menu").delete()
        }
    }

    struct AddCategoriesMigration: AsyncMigration {
        let name = "AddCategories"

        func prepare(on database: Database) async throws {
            try await database.schema("menu")
                .field("category_id", .uuid, .references("categories", "id"))
                .update()
        }

        func revert(on database: Database) async throws { }
    }
}

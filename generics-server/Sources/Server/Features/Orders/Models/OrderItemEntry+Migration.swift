import Fluent
import Vapor

extension OrderItemEntry {
    struct Migration: AsyncMigration {
        var name: String { "CreateOrderItem" }

        func prepare(on database: Database) async throws {
            try await database.schema("order_items")
                .id()
                .field("count", .int8, .required)
                .field("menu_item", .uuid, .required, .references("menu", "id"))
                .field("order", .uuid, .required, .references("orders", "id"))
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("order_items").delete()
        }
    }
}

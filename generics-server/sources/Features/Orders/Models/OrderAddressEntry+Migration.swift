import Fluent
import Vapor

extension OrderAddressEntry {
    struct Migration: AsyncMigration {
        var name: String { "CreateOrderAddress" }

        func prepare(on database: Database) async throws {
            try await database.schema(OrderAddressEntry.schema)
                .id()
                .field("latitude", .double, .required)
                .field("longitude", .double, .required)
                .field("street", .string, .required)
                .field("floor", .int)
                .field("appartment", .string)
                .field("comment", .string)
                .field("order_id", .uuid, .required, .references("orders", "id"))
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema(OrderAddressEntry.schema).delete()
        }
    }
}

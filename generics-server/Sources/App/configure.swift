import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) throws {
    app.databases.use(.postgres(configuration: SQLPostgresConfiguration(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_NAME") ?? "vapor_database",
            tls: .prefer(try .init(configuration: .clientDefault)))
        ), as: .psql)

    app.migrations.add(UserEntry.Migration())
    app.migrations.add(UserTokenEntry.Migration())
    app.migrations.add(MenuEntry.Migration())
    app.migrations.add(OrderEntry.Migration())
    app.migrations.add(OrderItemEntry.Migration())

    try routes(app)
}

import Fluent
import FluentPostgresDriver
import Vapor

import SotoS3

func getDatabase() throws -> DatabaseConfigurationFactory {
    .postgres(configuration: SQLPostgresConfiguration(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    )
}

func getS3(for app: Application) -> S3 {
    let awsClient = AWSClient(
        credentialProvider: .static(
            accessKeyId: Environment.get("AWS_ACCESS_KEY_ID") ?? "vapor_access_key_id",
            secretAccessKey: Environment.get("AWS_SECRET_ACCESS_KEY") ?? "vapor_secret_access_key"
        ),
        httpClientProvider: .shared(app.http.client.shared),
        logger: app.logger)

    let host = Environment.get("AWS_S3_HOST") ?? "localhost"
    let port = Environment.get("AWS_S3_PORT") ?? "9000"
    return S3(client: awsClient, endpoint: "http://\(host):\(port)")
}

public func configure(_ app: Application) async throws {
    app.databases.use(try getDatabase(), as: .psql)
    app.s3 = getS3(for: app)

    app.migrations.add(UserEntry.Migration())
    app.migrations.add(UserTokenEntry.Migration())
    app.migrations.add(MenuEntry.Migration())
    app.migrations.add(CategoryEntry.Migration())
    app.migrations.add(OrderEntry.Migration())
    app.migrations.add(OrderItemEntry.Migration())

    app.migrations.add(MenuEntry.AddCategoriesMigration())

    // Should find a way to put that into migrations maybe?
    if !((try await app.s3.listBuckets()).buckets?.contains(where: { $0.name == "menu-images"}) ?? true) {
        app.logger.debug("Didn't find a 'menu-images' S3 bucket, so creating one.")
        _ = try await app.s3.createBucket(.init(bucket: "menu-images"))
    }

    app.routes.defaultMaxBodySize = "10MB"

    try routes(app)
}

// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "generics-server",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "SharedModels", targets: ["SharedModels"])
    ],
    dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.90.0"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
    .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
    .package(url: "https://github.com/kylef/PathKit", from: "1.0.1"),
    .package(url: "https://github.com/soto-project/soto.git", from: "6.0.0")

],
    targets: [
        .executableTarget(
            name: "Server",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .target(name: "SharedModels"),
                .product(name: "PathKit", package: "PathKit"),
                .product(name: "SotoS3", package: "soto")
            ],
            swiftSettings: [
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ],
            plugins: []
        ),
        .target(
            name: "SharedModels",
            dependencies: []
        )
    ]
)

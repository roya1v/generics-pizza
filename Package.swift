// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "generics-pizza",
    platforms: [.macOS("14.0"), .iOS("16.4")],
    dependencies: [
        .package(url: "https://github.com/Matejkob/swift-spyable.git", from: "0.2.0"),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.3.2"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.90.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/kylef/PathKit", from: "1.0.1"),
        .package(url: "https://github.com/soto-project/soto.git", from: "6.0.0"),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.15.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0")
    ],
    targets: [
        // We build it for Docker from here and not using bazel
        // because: https://github.com/cgrindel/rules_swift_package_manager/issues/1174
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
            path: "generics-server/sources",
            swiftSettings: [
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(
            name: "SharedModels",
            dependencies: [],
            path: "shared-models/sources"
        )
    ]
)

// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GenericsPackage",
    platforms: [.macOS("14.0"), .iOS("16.4")],
    products: [
        .library(name: "GenericsCore", targets: ["GenericsCore"]),
        .library(name: "GenericsHelpers", targets: ["GenericsHelpers"]),
        .library(name: "SwiftlyHttp", targets: ["SwiftlyHttp"]),
        .library(name: "SharedModels", targets: ["SharedModels"]),
        .library(name: "GenericsUI", targets: ["GenericsUI"]),
        .library(name: "AuthLogic", targets: ["AuthLogic"]),
    ],
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
            name: "GenericsServer",
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
            ]
        ),
        .executableTarget(
            name: "GenericsBot",
            dependencies: [
                "SwiftlyHttp",
                "SharedModels",
                "GenericsCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(
            name: "SharedModels",
            dependencies: []
        ),
        .target(
            name: "GenericsCore",
            dependencies: [
                .product(name: "Spyable", package: "swift-spyable"),
                .product(name: "Factory", package: "Factory"),
                "SwiftlyHttp",
                "SharedModels"
            ]
        ),
        .target(
            name: "GenericsHelpers",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "SwiftlyHttp",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "GenericsUI",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AuthLogic",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "GenericsCore"
            ]
        ),
        .testTarget(
            name: "AuthLogicTests",
            dependencies: [
                "GenericsCore",
                "AuthLogic",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Factory", package: "Factory"),
            ]
        )
    ]
)

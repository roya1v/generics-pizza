// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "generics-shared",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(
            name: "GenericsCore",
            targets: ["GenericsCore"]),
        .library(
            name: "GenericsHelpers",
            targets: ["GenericsHelpers"]),
        .library(
            name: "GenericsUI",
            targets: ["GenericsUI"]),
        .library(
            name: "GenericsUIKit",
            targets: ["GenericsUIKit"]),
        .library(
            name: "CustomerMenu",
            targets: ["CustomerMenu"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Matejkob/swift-spyable.git", from: "0.2.0"),
        .package(url: "https://github.com/roya1v/SwiftlyHttp", branch: "main"),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.3.2"),
        .package(path: "../generics-server")
    ],
    targets: [
        .target(
            name: "GenericsCore", dependencies: [.product(name: "Spyable", package: "swift-spyable"),
                                                 .product(name: "SwiftlyHttp", package: "SwiftlyHttp"),
                                                 .product(name: "SharedModels", package: "generics-server"), .product(name: "Factory", package: "Factory")]),
        .target(
            name: "GenericsHelpers", dependencies: [.product(name: "Spyable", package: "swift-spyable"),
                                                    .product(name: "SwiftlyHttp", package: "SwiftlyHttp"),
                                                    .product(name: "SharedModels", package: "generics-server")]),
        .target(
            name: "GenericsUI", dependencies: [.product(name: "Spyable", package: "swift-spyable"),
                                                 .product(name: "SwiftlyHttp", package: "SwiftlyHttp"),
                                                 .product(name: "SharedModels", package: "generics-server")]),
        .target(
            name: "GenericsUIKit", dependencies: [.product(name: "Spyable", package: "swift-spyable"),
                                                 .product(name: "SwiftlyHttp", package: "SwiftlyHttp"),
                                                 .product(name: "SharedModels", package: "generics-server"), "GenericsUI"]),
        .target(
            name: "CustomerMenu", dependencies: [.product(name: "Spyable", package: "swift-spyable"),
                                                 .product(name: "SwiftlyHttp", package: "SwiftlyHttp"),
                                                 .product(name: "SharedModels", package: "generics-server"), "GenericsUI", "GenericsCore"]),
        .testTarget(
            name: "GenericsCoreTests",
            dependencies: ["GenericsCore", "GenericsHelpers"]),
    ]
)

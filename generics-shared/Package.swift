// swift-tools-version: 5.9

import PackageDescription


let features = [
    "CustomerMenu",
    "CustomerCart"
]

let featureDependencies: [Target.Dependency] = [
    .product(name: "SharedModels", package: "generics-server"),
    "GenericsUI",
    "GenericsCore",
    "GenericsHelpers",
    .product(name: "Factory", package: "Factory")
]

let otherTargets: [Target] = [
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
    .testTarget(
        name: "GenericsCoreTests",
        dependencies: ["GenericsCore", "GenericsHelpers"]),
    .testTarget(
        name: "Tests",
        dependencies: ["GenericsCore", "GenericsHelpers", "GenericsUI",
                       .product(name: "Factory", package: "Factory"),
                       .product(name: "SharedModels", package: "generics-server"), "CustomerMenu", "CustomerCart"], path: "Sources/Features/Tests"),
]

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
            targets: ["GenericsUIKit"])
    ] + features.map {
        .library(name: $0, targets: [$0])
    },
    dependencies: [
        .package(url: "https://github.com/Matejkob/swift-spyable.git", from: "0.2.0"),
        .package(url: "https://github.com/roya1v/SwiftlyHttp", branch: "main"),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.3.2"),
        .package(path: "../generics-server")
    ],
    targets: otherTargets + features.map {
        .target(name: $0,
                dependencies: featureDependencies,
                path: "Sources/Features/" + $0)
    }
)

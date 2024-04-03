// swift-tools-version: 5.9

import PackageDescription


let features = [
    "CustomerMenu",
    "CustomerCart"
]

// Dependencies

let Spyable = Target.Dependency.product(name: "Spyable", package: "swift-spyable")
let SwiftlyHttp = Target.Dependency.product(name: "SwiftlyHttp", package: "SwiftlyHttp")
let Factory = Target.Dependency.product(name: "Factory", package: "Factory")
let SharedModels = Target.Dependency.product(name: "SharedModels", package: "generics-server")

let featureDependencies: [Target.Dependency] = [
    SharedModels,
    "GenericsUI",
    "GenericsCore",
    "GenericsHelpers",
    Factory
]

let otherTargets: [Target] = [
    .target(
        name: "GenericsCore",
        dependencies: [
            Spyable,
            SwiftlyHttp,
            SharedModels,
            Factory
        ]
    ),
    .target(
        name: "GenericsHelpers",
        dependencies: [
            Spyable,
            SwiftlyHttp,
            SharedModels
        ]
    ),
    .target(
        name: "GenericsUI",
        dependencies: []
    ),
    .target(
        name: "GenericsUIKit",
        dependencies: [
            "GenericsUI"
        ]
    ),
    .testTarget(
        name: "Tests",
        dependencies: [
            "GenericsCore",
            "GenericsHelpers",
            "GenericsUI",
            Factory,
            SharedModels,
            "CustomerMenu",
            "CustomerCart"
        ],
        path: "Sources/Features/Tests"
    ),
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
    ] + features.map { .library(name: $0, targets: [$0]) },
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

// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "GenericsPackage",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(
            name: "GenericsModels",
            targets: ["GenericsModels"]),
        .library(
            name: "GenericsRepositories",
            targets: ["GenericsRepositories"])
    ],
    dependencies: [
        .package(url: "https://github.com/roya1v/SwiftlyHttp", branch: "main")
    ],
    targets: [
        .target(
            name: "GenericsModels",
            dependencies: []),
        .target(
            name: "GenericsRepositories",
            dependencies: ["GenericsModels", "SwiftlyHttp"]),
    ]
)

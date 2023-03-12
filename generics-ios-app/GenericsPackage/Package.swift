// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GenericsPackage",
    platforms: [.iOS(.v15), .macOS(.v13)],
    products: [
        .library(
            name: "GenericsHttp",
            targets: ["GenericsHttp"]),
        .library(
            name: "GenericsUIKit",
            targets: ["GenericsUIKit"]),
        .library(
            name: "GenericsModels",
            targets: ["GenericsModels"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "GenericsHttp",
            dependencies: []),
        .target(
            name: "GenericsUIKit",
            dependencies: []),
        .target(
            name: "GenericsModels",
            dependencies: []),
    ]
)

// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GenericsPackage",
    platforms: [.iOS(.v13), .macOS(.v13)],
    products: [
        .library(
            name: "GenericsHttp",
            targets: ["GenericsHttp"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "GenericsHttp",
            dependencies: []),
    ]
)

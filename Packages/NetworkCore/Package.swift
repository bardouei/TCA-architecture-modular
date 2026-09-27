// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkCore",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(
            name: "NetworkCore",
            targets: ["NetworkCore"]
        ), 
    ],
    dependencies: [
        .package(path: "../BaseCore")
    ],
    targets: [
        .target(
            name: "NetworkCore",
            dependencies: ["BaseCore"]
        ),
        .testTarget(
            name: "NetworkCoreTests",
            dependencies: ["NetworkCore"]
        ),
    ]
)

// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BaseCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "BaseCore",
            targets: ["BaseCore"]
        ),
    ],
    targets: [
        .target(
            name: "BaseCore"
        ),
        .testTarget(
            name: "BaseCoreTests",
            dependencies: ["BaseCore"]
        ),
    ]
)

// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DomainCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DomainCore",
            targets: ["DomainCore"]
        ),
    ],
    targets: [
        .target(
            name: "DomainCore"
        ),
        .testTarget(
            name: "DomainCoreTests",
            dependencies: ["DomainCore"]
        ),
    ]
)

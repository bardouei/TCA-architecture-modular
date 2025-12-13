// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StorageCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "StorageCore",
            targets: ["StorageCore"]
        ),
    ],
    targets: [
        .target(
            name: "StorageCore"
        ),
        .testTarget(
            name: "StorageCoreTests",
            dependencies: ["StorageCore"]
        ),
    ]
)

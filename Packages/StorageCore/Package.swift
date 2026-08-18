// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StorageCore",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(
            name: "StorageCore",
            targets: ["StorageCore"]
        ),
    ],
    targets: [
        .target(
            name: "StorageCore",
            resources: [
                .process("Infrastructure/CoreData/CoreDataModel.xcdatamodeld")
            ]
        ),
        .testTarget(
            name: "StorageCoreTests",
            dependencies: ["StorageCore"]
        ),
    ]
)

// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureHome",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "FeatureHome",
            targets: ["FeatureHome"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.23.0"),
        .package(path: "../NetworkCore"),
        .package(path: "../StorageCore")
    ],
    targets: [
        .target(
            name: "FeatureHome",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "NetworkCore",
                "StorageCore"
            ]
        ),
        .testTarget(
            name: "FeatureHomeTests",
            dependencies: ["FeatureHome"]
        ),
    ]
)

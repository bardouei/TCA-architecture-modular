// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureSplash",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "FeatureSplash",
            targets: ["FeatureSplash"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.23.0")
    ],
    targets: [
        .target(
            name: "FeatureSplash",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        )
    ]
)

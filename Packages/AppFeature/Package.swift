// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppFeature",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.23.0"),
        .package(path: "../NetworkCore"),
        .package(path: "../StorageCore"),
        .package(path: "../DomainCore"),
        .package(path: "../FeatureSplash"),
        .package(path: "../FeatureHome")
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "NetworkCore",
                "StorageCore",
                "DomainCore",
                "FeatureSplash",
                "FeatureHome"
            ]
        )
    ]
)

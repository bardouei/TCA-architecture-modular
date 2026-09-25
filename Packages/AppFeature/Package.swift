// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppFeature",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "AppClipFeature", targets: ["AppClipFeature"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "1.26.2"
        ),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "1.17.1"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", exact: "1.13.0"),
        .package(path: "../FeatureSplash"),
        .package(path: "../FeatureHome"),
        .package(path: "../NetworkCore"),
        .package(path: "../StorageCore"),
        .package(path: "../DesignSystem"),
        .package(path: "../DomainCore"),
        .package(path: "../TCAAdapters")
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                "FeatureSplash",
                "FeatureHome",
                "NetworkCore",
                "StorageCore",
                "DesignSystem",
                "DomainCore",
                "AppClipFeature"
            ]
        ),
        .target(
            name: "AppClipFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "AppDependencies", package: "TCAAdapters"),
                "DomainCore",
                "NetworkCore"
            ]
        ),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: [
                "AppFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ]
        ),
        .testTarget(
            name: "AppClipFeatureTests",
            dependencies: [
                "AppClipFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ]
        )
    ]
)

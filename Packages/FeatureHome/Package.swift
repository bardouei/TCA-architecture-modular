// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureHome",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(
            name: "FeatureHome",
            targets: ["FeatureHome"]
        ),
        .library(
            name: "PostDetailFeature",
            targets: ["PostDetailFeature"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "1.26.2"
        ),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "1.17.1"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", exact: "1.13.0"),
        .package(path: "../NetworkCore"),
        .package(path: "../TCAAdapters"),
        .package(path: "../DomainCore"),
        .package(path: "../DesignSystem")
    ],
    targets: [

        // 🔹 PostDetailFeature target
        .target(
            name: "PostDetailFeature",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(name: "Dependencies", package: "swift-dependencies"),
                "DomainCore"
            ],
            path: "Sources/PostDetailFeature"
        ),

        // 🔹 Home Feature target
        .target(
            name: "FeatureHome",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(name: "Dependencies", package: "swift-dependencies"),
                "NetworkCore",
                .product(name: "AppDependencies", package: "TCAAdapters"),
                "DomainCore",
                "PostDetailFeature",
                "DesignSystem"
            ],
            path: "Sources/FeatureHome"
        ),
        .testTarget(
            name: "FeatureHomeTests",
            dependencies: [
                "FeatureHome",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ]
        )
    ]
)

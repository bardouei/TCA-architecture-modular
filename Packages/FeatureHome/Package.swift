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
            from: "1.23.0"
        ),
        .package(path: "../NetworkCore"),
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
                "NetworkCore",
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
                )
            ]
        )
    ]
)

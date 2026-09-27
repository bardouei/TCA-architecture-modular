// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppFeature",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "1.26.2"
        ),
        .package(path: "../NetworkCore"),
        .package(path: "../StorageCore"),
        .package(path: "../DesignSystem"),
        .package(path: "../DomainCore"),
        .package(path: "../AppDependencies")
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "AppDependencies", package: "AppDependencies"),
                "NetworkCore",
                "StorageCore",
                "DesignSystem",
                "DomainCore"
            ]
        ),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: [
                "AppFeature",
                "DomainCore",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        )
    ]
)

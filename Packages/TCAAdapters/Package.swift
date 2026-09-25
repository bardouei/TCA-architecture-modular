// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TCAAdapters",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(
            name: "AppDependencies",
            targets: ["AppDependencies"]
        ),
        .library(
            name: "TCAAdapters",
            targets: ["AppDependencies"]
        ),
    ],
    dependencies: [
        // ✅ TCA
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "1.26.2"
        ),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "1.17.1"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", exact: "1.13.0"),

        // ✅ Coreها
        .package(path: "../NetworkCore"),
        .package(path: "../StorageCore")
    ],
    targets: [
        .target(
            name: "AppDependencies",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(name: "Dependencies", package: "swift-dependencies"),
                "NetworkCore",
                "StorageCore"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TCAAdaptersTests",
            dependencies: [
                "AppDependencies",
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ],
            path: "Tests/TCAAdaptersTests"
        ),
    ]
)

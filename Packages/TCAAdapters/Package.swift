// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TCAAdapters",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(
            name: "TCAAdapters",
            targets: ["TCAAdapters"]
        ),
    ],
    dependencies: [
        // ✅ TCA
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.23.0"
        ),

        // ✅ Coreها
        .package(path: "../NetworkCore")
    ],
    targets: [
        .target(
            name: "TCAAdapters",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                "NetworkCore"
            ]
        ),
        .testTarget(
            name: "TCAAdaptersTests",
            dependencies: ["TCAAdapters"]
        ),
    ]
)

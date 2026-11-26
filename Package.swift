// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "BF16",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "BF16",
            targets: ["BF16"]
        ),
    ],
    targets: [
        .target(
            name: "BF16"
        ),
        .testTarget(
            name: "BF16Tests",
            dependencies: ["BF16"]
        ),
    ]
)

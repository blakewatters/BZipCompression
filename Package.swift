// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "BZipCompression",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "BZipCompression",
            targets: ["BZipCompression"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/dong2810/BZipCompression.git", from: "0.4.0"),
    ],
    targets: [
        .target(
            name: "BZipCompression",
            dependencies: [
                "BZipCompression",
            ],
            path: "Code"
        ),
        .testTarget(
            name: "BZipCompressionTests",
            dependencies: ["BZipCompression"]
        ),
    ]
)

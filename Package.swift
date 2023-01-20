// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "PaylikeEngine",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(name: "PaylikeEngine", targets: ["PaylikeEngine"]),
    ],
    dependencies: [
        .package(url: "git@github.com:paylike/swift-luhn.git", .upToNextMajor(from: "0.1.0")),
        .package(url: "git@github.com:paylike/swift-client.git", .upToNextMajor(from: "0.1.0"))
    ],
    targets: [
        .target(
            name: "PaylikeEngine",
            dependencies: [
                .product(name: "PaylikeLuhn", package: "swift-luhn"),
                .product(name: "PaylikeClient", package: "swift-client")
            ]),
        .testTarget(
            name: "PaylikeEngineTests",
            dependencies: [
                "PaylikeEngine",
                .product(name: "PaylikeLuhn", package: "swift-luhn"),
                .product(name: "PaylikeClient", package: "swift-client")
            ]),
    ],
    swiftLanguageVersions: [.v5]
)

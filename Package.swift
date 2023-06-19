// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "PaylikeEngine",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(name: "PaylikeEngine", targets: ["PaylikeEngine"]),
    ],
    dependencies: [
        .package(url: "https://github.com/paylike/swift-luhn", .upToNextMajor(from: "0.2.0")),
        .package(url: "https://github.com/paylike/swift-client", .upToNextMajor(from: "0.2.0")),
        .package(url: "https://github.com/httpswift/swifter", .upToNextMajor(from: "1.5.0"))
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
                .product(name: "Swifter", package: "swifter")
            ]),
    ],
    swiftLanguageVersions: [.v5]
)

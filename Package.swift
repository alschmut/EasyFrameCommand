// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "easy-frame",
    platforms: [.macOS(.v10_15)],
    dependencies: [
        .package(url: "https://github.com/ainame/FrameKit", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.5.0"),
    ],
    targets: [
        .executableTarget(name: "easy-frame", dependencies: [
            .product(name: "FrameKit", package: "FrameKit"),
            .product(name: "ArgumentParser", package: "swift-argument-parser")
        ]),
    ],
    swiftLanguageModes: [.v5]
)

// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "XCServerCoreData",
    products: [
        .library(name: "XCServerCoreData", targets: ["XCServerCoreData"])
    ],
    dependencies: [
        .package(url: "https://github.com/richardpiazza/CodeQuickKit.git", from: "6.4.1"),
        .package(url: "https://github.com/richardpiazza/XCServerAPI.git", from: "5.0.0")
    ],
    targets: [
        .target(name: "XCServerCoreData", dependencies: ["CodeQuickKit", "XCServerAPI"], path: "Sources"),
        .testTarget(name: "XCServerCoreDataTests", dependencies: ["XCServerCoreData"], path: "Tests")
    ]
)

// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Pattern Lock Control for SwiftUI applications

import PackageDescription

let package = Package(
    name: "cnl-patternlock",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "cnl-patternlock",
            targets: ["cnl-patternlock"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "cnl-patternlock"),

    ]
)

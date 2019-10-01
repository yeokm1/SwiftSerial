// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSerialExample",
    dependencies: [
        .package(url: "https://github.com/yeokm1/SwiftSerial.git", from: "0.1.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftSerialExample",
            dependencies: ["SwiftSerial"],
            path: "Sources"
        ),
    ]
)

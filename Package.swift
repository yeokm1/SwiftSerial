// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "SwiftSerial",
    
    products: [
        .library(name: "SwiftSerial", targets: ["SwiftSerial"])
    ],
    targets: [
        .target(name: "SwiftSerial",
                path: "Sources"),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)

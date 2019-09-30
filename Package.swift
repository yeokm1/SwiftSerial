// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSerial",
	products: [
		.library(name: "SwiftSerial", targets: ["SwiftSerial"]),
	],
	dependencies: [],
	targets: [
		.target(
			name: "SwiftSerial",
			dependencies: [],
			path: "Sources"
		),
	]
)

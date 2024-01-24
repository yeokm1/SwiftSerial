// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SwiftSerial",
	platforms: [
		.macOS(.v10_15),
	],
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

import PackageDescription

let package = Package(
    name: "SwiftSerialIM",
    dependencies: [
    	.Package(url: "https://github.com/yeokm1/SwiftSerial.git", majorVersion: 0)
	]
)

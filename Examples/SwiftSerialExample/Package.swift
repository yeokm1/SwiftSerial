import PackageDescription

let package = Package(
    name: "SwiftSerialExample",
    dependencies: [
    	.Package(url: "https://github.com/yeokm1/SwiftSerial.git", majorVersion: 0)
	]
)

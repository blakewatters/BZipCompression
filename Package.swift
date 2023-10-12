// swift-tools-version:5.7.1
import PackageDescription

let package = Package(
	name: "BZipCompression",
	defaultLocalization: "en",
	platforms: [.iOS(.v14)],
	products: [
		.library(
			name: "BZipCompression",
			targets: ["BZipCompression"]),
	],
	targets: [
		.target(
			name: "BZipCompression",
			path: "BZipCompression",
			publicHeadersPath: "")
	]
)

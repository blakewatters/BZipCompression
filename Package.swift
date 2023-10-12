import PackageDescription

let package = Package(
	name: "BZipCompression",
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

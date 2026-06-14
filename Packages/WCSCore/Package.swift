// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "WCSCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "WCSCore", targets: ["WCSCore"])
    ],
    targets: [
        .target(name: "WCSCore"),
        .testTarget(name: "WCSCoreTests", dependencies: ["WCSCore"])
    ]
)

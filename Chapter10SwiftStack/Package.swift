// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Chapter10SwiftStack",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "TGNNCore", targets: ["TGNNCore"]),
        .executable(name: "SwiftTrainTGNN", targets: ["SwiftTrainTGNN"]),
        .executable(name: "VaporBackend", targets: ["VaporBackend"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.100.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "TGNNCore",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "SwiftTrainTGNN",
            dependencies: [
                "TGNNCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            resources: [
                .copy("../../Resources/king_county_sample.csv")
            ]
        ),
        .executableTarget(
            name: "VaporBackend",
            dependencies: [
                "TGNNCore",
                .product(name: "Vapor", package: "vapor")
            ],
            resources: [
                .copy("../../Resources/king_county_sample.csv")
            ]
        ),
        .testTarget(
            name: "TGNNCoreTests",
            dependencies: ["TGNNCore"]
        )
    ]
)

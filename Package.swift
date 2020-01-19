// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "TransformCoding",
    products: [
        .library(
            name: "TransformCoding",
            targets: ["TransformCoding"]),
    ],
    targets: [
        .target(
            name: "TransformCoding",
            dependencies: []),
        .testTarget(
            name: "TransformCodingTests",
            dependencies: ["TransformCoding"]),
    ]
)

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OpAdxSdk",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "OpAdxSdk",
            targets: ["OpAdxSdk"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "OpAdxSdk",
            path: "OpAdxSdk.xcframework"
        ),
    ]
)

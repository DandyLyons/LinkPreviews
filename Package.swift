// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LinkPreviews",
    platforms: [.iOS(.v15), .macCatalyst(.v15), .macOS(.v12), .tvOS(.v15), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "LinkPreviews",
            targets: ["LinkPreviews"]),
        
        .library(
            name: "OGLinkPreviews",
            targets: ["OGLinkPreviews"]),
    ],
    dependencies: [
        .package(url: "https://github.com/satoshi-takano/OpenGraph.git", from: "1.6.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LinkPreviews",
            dependencies: [
            ],
            swiftSettings: [
//                .swiftLanguageMode(.v5),
            ]
        ),
        .target(
            name: "OGLinkPreviews",
            dependencies: [
                .product(name: "OpenGraph", package: "opengraph")
            ],
            swiftSettings: [
            ]
        ),

    ]
)

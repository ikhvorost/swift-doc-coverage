// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDocCoverage",
    platforms: [
        .macOS(.v10_14),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "0.50600.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "SwiftDocCoverage",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "SwiftDocCoverageTests",
            dependencies: ["SwiftDocCoverage"],
            resources: [
                .copy("Resources")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)

// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-doc-coverage",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    .executable(name: "swift-doc-coverage", targets: ["swift-doc-coverage"]),
    .library(name: "SwiftDocCoverage", targets: ["SwiftDocCoverage"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", from: "509.1.1"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
  ],
  targets: [
    .executableTarget(
      name: "swift-doc-coverage",
      dependencies: [
        .target(name: "SwiftDocCoverage"),
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]
    ),
    .target(
      name: "SwiftDocCoverage",
      dependencies: [
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftParser", package: "swift-syntax"),
      ]
    ),
    .testTarget(
      name: "SwiftDocCoverageTests",
      dependencies: ["swift-doc-coverage"],
      resources: [
        .copy("Resources")
      ]
    )
  ],
  swiftLanguageVersions: [.v5]
)

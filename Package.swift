// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-doc-coverage",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .library(name: "SwiftSource", targets: ["SwiftSource"]),
    .executable(name: "swift-doc-coverage", targets: ["swift-doc-coverage"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", from: "603.0.1"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.7.1")
  ],
  targets: [
    .target(
      name: "SwiftSource",
      dependencies: [
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftParser", package: "swift-syntax"),
      ]
    ),
    .executableTarget(
      name: "swift-doc-coverage",
      dependencies: [
        .target(name: "SwiftSource"),
        .product(name: "ArgumentParser", package: "swift-argument-parser")
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
  swiftLanguageModes: [.v6]
)

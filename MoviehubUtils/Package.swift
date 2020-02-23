// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MoviehubUtils",
  platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13)],
  products: [
    .library(
      name: "MoviehubUtils",
      targets: ["MoviehubUtils"]
    )
  ],
  targets: [
    .target(
      name: "MoviehubUtils",
      dependencies: []
    ),
    .testTarget(
      name: "MoviehubUtilsTests",
      dependencies: ["MoviehubUtils"]
    )
  ]
)
// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MoviehubStyleguide",
  platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13)],
  products: [
    .library(
      name: "MoviehubStyleguide",
      targets: ["MoviehubStyleguide"]
    )
  ],
  targets: [
    .target(
      name: "MoviehubStyleguide",
      dependencies: []
    ),
    .testTarget(
      name: "MoviehubStyleguideTests",
      dependencies: ["MoviehubStyleguide"]
    )
  ]
)

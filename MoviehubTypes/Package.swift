// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MoviehubTypes",
  products: [
    .library(
      name: "MoviehubTypes",
      targets: ["MoviehubTypes"])
  ],
  targets: [
    .target(
      name: "MoviehubTypes",
      dependencies: []),
    .testTarget(
      name: "MoviehubTypesTests",
      dependencies: ["MoviehubTypes"])
  ]
)

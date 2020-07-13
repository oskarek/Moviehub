// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MoviehubAPI",
  platforms: [.iOS(.v13)],
  products: [
    .library(
      name: "MoviehubAPI",
      targets: ["MoviehubAPI"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: .init(0, 6, 0)),
    .package(path: "../MoviehubTypes"),
    .package(path: "../MoviehubUtils")
  ],
  targets: [
    .target(
      name: "MoviehubAPI",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "MoviehubTypes",
        "MoviehubUtils"
      ]
    ),
    .testTarget(
      name: "MoviehubAPITests",
      dependencies: ["MoviehubAPI", "MoviehubTypes"]
    )
  ]
)

// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MoviehubAPI",
  platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13)],
  products: [
    .library(
      name: "MoviehubAPI",
      targets: ["MoviehubAPI"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: .init(0, 4, 0)),
    .package(url: "https://github.com/pointfreeco/swift-overture.git", from: .init(0, 5, 0)),
    .package(path: "../MoviehubTypes"),
    .package(path: "../MoviehubUtils")
  ],
  targets: [
    .target(
      name: "MoviehubAPI",
      dependencies: [
        "ComposableArchitecture",
        "Overture",
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

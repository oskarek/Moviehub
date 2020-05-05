// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MoviehubSearch",
  platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13)],
  products: [
    .library(
      name: "MoviehubSearch",
      targets: ["MoviehubSearch"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: .init(0, 1, 0)),
    .package(url: "https://github.com/pointfreeco/swift-overture.git", from: .init(0, 5, 0)),
    .package(path: "../MoviehubAPI"),
    .package(path: "../MoviehubStyleguide"),
    .package(path: "../MoviehubTypes"),
    .package(path: "../MoviehubUtils")
  ],
  targets: [
    .target(
      name: "MoviehubSearch",
      dependencies: [
        "MoviehubAPI",
        "ComposableArchitecture",
        "MoviehubStyleguide",
        "MoviehubTypes",
        "MoviehubUtils"
      ]
    ),
    .testTarget(
      name: "MoviehubSearchTests",
      dependencies: ["Overture", "MoviehubSearch", "ComposableArchitectureTestSupport"]
    )
  ]
)

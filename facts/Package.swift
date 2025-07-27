// swift-tools-version: 6.0

import PackageDescription

let lint = Target.PluginUsage.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")

let package = Package(
  name: "FactsAPI",
  platforms: [.iOS(.v18),.macOS(.v15)],
  products: [
    .executable(name: "FactsAPI", targets: ["FactsAPI"]),
    .library(name: "FactsAPIClient", targets: ["FactsAPIClient"])
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor", from: "4.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),
    .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.1.0"),
  ],
  targets: [
    .executableTarget(
      name: "FactsAPI",
      dependencies: [.product(name: "Vapor", package: "vapor")],
      resources: [.process("res/")],
      plugins: [lint]
    ),
    .testTarget(name: "FactsAPITests", dependencies: ["FactsAPI", .product(name: "VaporTesting", package: "vapor")]),
    .target(
      name: "FactsAPIClient",
      dependencies: [.product(name: "Dependencies", package: "swift-dependencies")],
      plugins: [lint]
    ),
    .testTarget(name: "FactsAPIClientTests", dependencies: ["FactsAPIClient"], path: "Tests/FactsAPIClientTests")
  ]
)


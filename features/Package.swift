// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "Features",
  defaultLocalization: "en",
  platforms: [.iOS(.v18), .macOS(.v15)],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.0.0"),
    .package(url: "https://github.com/liamnichols/xcstrings-tool-plugin.git", from: "1.0.0"),
    .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.1.0"),
    .package(path: "../library"),
    .package(path: "../extensions")
  ]
)

let tca = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
let xcstrings = Target.Dependency.product(name: "XCStringsToolPlugin", package: "xcstrings-tool-plugin")

let ext = Target.Dependency.product(name: "Extensions", package: "extensions")
let swiftuiExt = Target.Dependency.product(name: "SwiftUIExtensions", package: "extensions")
let comps = Target.Dependency.product(name: "SwiftUIComponents", package: "library")
let types = Target.Dependency.product(name: "Types", package: "library")
let calc = Target.Dependency.product(name: "Calculate", package: "library")
let code = Target.Dependency.product(name: "Code", package: "library")
let facts = Target.Dependency.product(name: "FactsAPIClient", package: "facts")

let lint = Target.PluginUsage.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")

let libs: [Target] = [
  .target(name: "App", dependencies: [
    tca, comps, xcstrings, "Dashboard", "History", "Statistic", "Fact", "Info", "Transfer"
  ], plugins: [lint]),
  .target(name: "Dashboard", dependencies: [tca, ext, swiftuiExt, comps, types, calc, xcstrings], plugins: [lint]),
  .target(name: "History", dependencies: [tca, ext, comps, types, calc, xcstrings], plugins: [lint]),
  .target(name: "Statistic", dependencies: [tca, ext, swiftuiExt, comps, types, calc, xcstrings], plugins: [lint]),
  .target(name: "Fact", dependencies: [tca, ext, xcstrings], plugins: [lint]),
  .target(name: "Info", dependencies: [tca, ext, swiftuiExt, xcstrings], plugins: [lint]),
  .target(name: "Transfer", dependencies: [tca, ext, swiftuiExt, comps, types, code, xcstrings], plugins: [lint]),
]

package.targets = libs + [
  .testTarget(
    name: "FeaturesTest",
    dependencies: libs.map { .byName(name: $0.name) },
    path: "Test",
    plugins: [lint]
  )
]

package.products = libs.map { .library(name: $0.name, targets: [$0.name]) }

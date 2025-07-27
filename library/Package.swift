// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "Library",
  defaultLocalization: "en",
  platforms: [.iOS(.v18), .macOS(.v15)],
  dependencies: [
    .package(path: "../extensions"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),
    .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.1.0"),
    .package(url: "https://github.com/liamnichols/xcstrings-tool-plugin.git", from: "1.2.0"),
  ]
)

let deps = Target.Dependency.product(name: "Dependencies", package: "swift-dependencies")
let xcstrings = Target.Dependency.product(name: "XCStringsToolPlugin", package: "xcstrings-tool-plugin")

let ext = Target.Dependency.product(name: "Extensions", package: "Extensions")

let lint = Target.PluginUsage.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")

let libs: [Target] = [
  .target(name: "SwiftUIComponents", dependencies: [deps, ext, xcstrings, "Types"], plugins: [lint]),
  .target(name: "Types", dependencies: [deps, ext], plugins: [lint]),
  .target(name: "Calculate", dependencies: [deps, ext, "Types"], plugins: [lint]),
  .target(name: "Code", dependencies: [deps], plugins: [lint])
]

package.targets = libs + [
  .testTarget(
    name: "LibraryTest",
    dependencies: libs.map { .byName(name: $0.name) },
    path: "Test",
    plugins: [lint]
  )
]

package.products.append(contentsOf: libs.map { .library(name: $0.name, targets: [$0.name]) })

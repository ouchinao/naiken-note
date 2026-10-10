// swift-tools-version: 6.0
import PackageDescription

let swiftLint: Target.PluginUsage = .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")

let package = Package(
    name: "NaikenKit",
    defaultLocalization: "ja",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.58.0"),
    ],
    targets: [
        .target(
            name: "Domain",
            resources: [.process("Resources")],
            plugins: [swiftLint]
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"],
            plugins: [swiftLint]
        ),
    ]
)

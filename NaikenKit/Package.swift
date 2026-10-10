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
        .library(name: "Data", targets: ["Data"]),
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
        .target(
            name: "Data",
            dependencies: ["Domain"],
            plugins: [swiftLint]
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"],
            plugins: [swiftLint]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data", "Domain"],
            plugins: [swiftLint]
        ),
    ]
)

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
        .library(name: "Platform", targets: ["Platform"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "Features", targets: ["Features"]),
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
        .target(
            name: "Platform",
            dependencies: ["Domain"],
            plugins: [swiftLint]
        ),
        .target(
            name: "DesignSystem",
            plugins: [swiftLint]
        ),
        .target(
            name: "Features",
            dependencies: ["Domain", "DesignSystem"],
            resources: [.process("Resources")],
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
        .testTarget(
            name: "PlatformTests",
            dependencies: ["Platform", "Domain"],
            plugins: [swiftLint]
        ),
        .testTarget(
            name: "FeaturesTests",
            dependencies: ["Features", "Domain"],
            plugins: [swiftLint]
        ),
    ]
)

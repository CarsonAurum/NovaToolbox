// swift-tools-version: 6.1
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "NovaToolbox",
    products: [
        .library(
            name: "NovaToolbox",
            targets: ["NovaToolbox"]
        ),
        .library(name: "NovaMacros", targets: ["NovaMacros"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", branch: "main")
    ],
    targets: [
        .macro(
            name: "NovaMacrosImplementation",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(name: "NovaMacros", dependencies: ["NovaMacrosImplementation"]),
        .target(name: "NovaToolbox"),
        .testTarget(name: "NovaToolboxTests", dependencies: ["NovaToolbox"]),
    ]
)

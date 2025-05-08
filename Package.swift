// swift-tools-version: 6.0
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "NovaToolbox",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "NovaToolbox",
            targets: ["NovaToolbox"]
        ),
        .library(
            name: "NovaMacros",
            targets: ["NovaMacros"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", branch: "main")
    ],
    targets: [
        .target(name: "NovaMacros", dependencies: ["NovaMacrosImplementation"]),
        .macro(
            name: "NovaMacrosImplementation",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
            ] 
        ),
        .target(name: "NovaToolbox"),
        .testTarget(name: "NovaToolboxTests", dependencies: ["NovaToolbox"]),
    ]
)

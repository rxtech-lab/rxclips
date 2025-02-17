// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "JSEngine",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "JSEngine",
            targets: ["JSEngine"]
        ),
    ],
    dependencies: [
        .package(path: "../Common"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
    ],
    targets: [
        .macro(
            name: "JSEngineMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "JSEngineMacro", dependencies: ["JSEngineMacros"]),
        .target(
            name: "JSEngine", dependencies: ["Common"]
        ),
        .testTarget(
            name: "JSEngineTests",
            dependencies: ["JSEngine"]
        ),
        .testTarget(
            name: "JSEngineMicroTests",
            dependencies: [
                "JSEngineMicroMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

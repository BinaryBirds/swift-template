// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "swift-template",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "swift-template-cli", targets: ["SwiftTemplateCli"]),
        .library(name: "SwiftTemplate", targets: ["SwiftTemplate"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/console-kit", from: "4.1.0"),
        .package(url: "https://github.com/binarybirds/path-kit", from: "1.0.0"),
        .package(url: "https://github.com/binarybirds/shell-kit", from: "1.0.0"),
        .package(url: "https://github.com/binarybirds/git-kit", from: "1.0.0"),
        .package(url: "https://github.com/binarybirds/build-kit", from: "1.0.0"),
    ],
    targets: [
        .target(name: "SwiftTemplateCli", dependencies: [
            .product(name: "ConsoleKit", package: "console-kit"),
            .target(name: "SwiftTemplate")
        ]),
        .target(name: "SwiftTemplate", dependencies: [
            .product(name: "PathKit", package: "path-kit"),
            .product(name: "ShellKit", package: "shell-kit"),
            .product(name: "GitKit", package: "git-kit"),
            .product(name: "BuildKit", package: "build-kit"),
        ]),
        .testTarget(name: "SwiftTemplateTests", dependencies: ["SwiftTemplate"]),
    ]
)

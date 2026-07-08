// swift-tools-version:6.2
import PackageDescription

// NOTE: https://github.com/swift-server/swift-http-server/blob/main/Package.swift
let defaultSwiftSettings: [SwiftSetting] = [
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0441-formalize-language-mode-terminology.md
    .swiftLanguageMode(.v6),
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0444-member-import-visibility.md
    .enableUpcomingFeature("MemberImportVisibility"),
    // https://forums.swift.org/t/experimental-support-for-lifetime-dependencies-in-swift-6-2-and-beyond/78638
    .enableExperimentalFeature("Lifetimes"),
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    // https://github.com/swiftlang/swift/pull/65218
    .enableExperimentalFeature("AvailabilityMacro=swiftTemplate:macOS 15, iOS 18, watchOS 9, tvOS 11, visionOS 2"),
]

let package = Package(
    name: "swift-template",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        .executable(name: "swift-template", targets: ["SwiftTemplateCli"]),
        .library(name: "SwiftTemplate", targets: ["SwiftTemplate"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.8.2"),
        .package(url: "https://github.com/apple/swift-system", exact: "1.7.2"),
        .package(url: "https://github.com/swiftlang/swift-subprocess", exact: "0.5.0"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftTemplateCli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Subprocess", package: "swift-subprocess"),
                .target(name: "SwiftTemplate")
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .target(
            name: "SwiftTemplate",
            dependencies: [
                .product(name: "SystemPackage", package: "swift-system"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .testTarget(
            name: "SwiftTemplateTests",
            dependencies: ["SwiftTemplate"],
            swiftSettings: defaultSwiftSettings
        ),
    ]
)

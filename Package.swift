// swift-tools-version:6.3
import PackageDescription

let package = Package(
    name: "fluent-kit",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "FluentKit", targets: ["FluentKit"]),
        .library(name: "FluentBenchmark", targets: ["FluentBenchmark"]),
        .library(name: "FluentSQL", targets: ["FluentSQL"]),
        .library(name: "XCTFluent", targets: ["XCTFluent"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.97.1"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.12.0"),
        .package(url: "https://github.com/vapor/sql-kit.git", from: "3.36.0"),
        .package(url: "https://github.com/apple/swift-distributed-tracing.git", from: "1.4.1"),
        .package(url: "https://github.com/apple/swift-service-context.git", from: "1.3.0"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.11.0"),
    ],
    targets: [
        .target(
            name: "FluentKit",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SQLKit", package: "sql-kit"),
                .product(name: "Tracing", package: "swift-distributed-tracing"),
                .product(name: "ServiceContextModule", package: "swift-service-context"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "FluentBenchmark",
            dependencies: [
                .target(name: "FluentKit"),
                .target(name: "FluentSQL"),
                .product(name: "SQLKit", package: "sql-kit"),
                .product(name: "SQLKitBenchmark", package: "sql-kit"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "FluentSQL",
            dependencies: [
                .product(name: "SQLKit", package: "sql-kit"),
                .target(name: "FluentKit"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "XCTFluent",
            dependencies: [
                .product(name: "NIOEmbedded", package: "swift-nio"),
                .target(name: "FluentKit"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "FluentKitTests",
            dependencies: [
                .target(name: "FluentBenchmark"),
                .target(name: "FluentSQL"),
                .target(name: "XCTFluent"),
                .product(name: "InMemoryTracing", package: "swift-distributed-tracing")
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
    // .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    // .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("ImmutableWeakCaptures"),
] }

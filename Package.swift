// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "A11yContractKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(name: "A11yContractCore", targets: ["A11yContractCore"]),
        .library(name: "A11yContractUIKit", targets: ["A11yContractUIKit"]),
        .library(name: "A11yContractSwiftUI", targets: ["A11yContractSwiftUI"]),
        .library(name: "A11yContractReporter", targets: ["A11yContractReporter"]),
        .library(name: "A11yContractTesting", targets: ["A11yContractTesting"]),
        .executable(name: "a11y-contract", targets: ["A11yContractCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "A11yContractCore",
            path: "Sources/A11yContractCore"
        ),
        .target(
            name: "A11yContractReporter",
            dependencies: ["A11yContractCore"],
            path: "Sources/A11yContractReporter"
        ),
        .target(
            name: "A11yContractUIKit",
            dependencies: ["A11yContractCore"],
            path: "Sources/A11yContractUIKit"
        ),
        .target(
            name: "A11yContractSwiftUI",
            dependencies: ["A11yContractCore"],
            path: "Sources/A11yContractSwiftUI"
        ),
        .target(
            name: "A11yContractTesting",
            dependencies: [
                "A11yContractCore",
                "A11yContractReporter",
                "A11yContractUIKit",
            ],
            path: "Sources/A11yContractTesting"
        ),
        .executableTarget(
            name: "A11yContractCLI",
            dependencies: [
                "A11yContractCore",
                "A11yContractReporter",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/A11yContractCLI",
            linkerSettings: [
                .linkedFramework("Foundation"),
            ]
        ),
        .testTarget(
            name: "A11yContractCoreTests",
            dependencies: ["A11yContractCore"],
            path: "Tests/A11yContractCoreTests"
        ),
        .testTarget(
            name: "A11yContractReporterTests",
            dependencies: ["A11yContractReporter", "A11yContractCore"],
            path: "Tests/A11yContractReporterTests"
        ),
        .testTarget(
            name: "A11yContractUIKitTests",
            dependencies: ["A11yContractUIKit", "A11yContractCore", "A11yContractReporter"],
            path: "Tests/A11yContractUIKitTests"
        ),
        .testTarget(
            name: "A11yContractTestingTests",
            dependencies: ["A11yContractTesting"],
            path: "Tests/A11yContractTestingTests"
        ),
    ]
)

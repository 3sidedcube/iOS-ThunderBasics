// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ThunderBasics",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ThunderBasics",
            targets: ["ThunderBasics"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ThunderBasics",
            dependencies: [
                .target(name: "iOS", condition: .when(platforms: [.iOS]))
            ],
            path: "Sources/Common",
            exclude: ["Info.plist"],
            resources: [
                .process("Locale Language Codes/iso639_2.bundle")
            ],
            linkerSettings: [
                .linkedFramework("UIKit", .when(platforms: [.iOS]))
            ]),
        .target(
            name: "iOS",
            path: "Sources/iOS",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "ThunderBasicsTests",
            dependencies: ["ThunderBasics"],
            path: "Tests",
            exclude: ["Info.plist"],
            resources: [
                .process("Resources/Images")
            ]),
    ]
)

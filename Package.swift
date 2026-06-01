// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SlackActivityMenu",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "SlackActivityMenu", targets: ["SlackActivityMenu"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle.git", from: "2.9.2"),
    ],
    targets: [
        .target(name: "SlackActivityCore"),
        .executableTarget(
            name: "SlackActivityMenu",
            dependencies: [
                "SlackActivityCore",
                .product(name: "Sparkle", package: "Sparkle"),
            ]
        ),
        .testTarget(
            name: "SlackActivityCoreTests",
            dependencies: ["SlackActivityCore"]
        ),
    ]
)

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
    targets: [
        .target(name: "SlackActivityCore"),
        .executableTarget(
            name: "SlackActivityMenu",
            dependencies: ["SlackActivityCore"]
        ),
        .testTarget(
            name: "SlackActivityCoreTests",
            dependencies: ["SlackActivityCore"]
        ),
    ]
)

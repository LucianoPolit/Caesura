// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Caesura",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "Caesura",
            targets: ["Caesura"]
        ),
        .library(
            name: "CaesuraUI",
            targets: ["CaesuraUI"]
        ),
        .library(
            name: "CaesuraStandardAction",
            targets: ["CaesuraStandardAction"]
        ),
        .library(
            name: "CaesuraMiddlewares",
            targets: ["CaesuraMiddlewares"]
        ),
        .library(
            name: "ReRxCaesura",
            targets: ["ReRxCaesura"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/ReSwift/ReSwift.git",
            .upToNextMajor(from: "5.0.0")
        ),
        .package(
            url: "https://github.com/devxoul/Then.git",
            .upToNextMajor(from: "2.7.0")
        ),
        .package(
            url: "https://github.com/svdo/ReRxSwift.git",
            .upToNextMajor(from: "2.2.2")
        ),
        .package(
            url: "https://github.com/Quick/Nimble.git",
            .upToNextMajor(from: "7.0.0")
        )
    ],
    targets: [
        .target(
            name: "Caesura",
            dependencies: [
                "ReSwift",
                "Then"
            ],
            path: "Source",
            sources: [
                "Core"
            ]
        ),
        .target(
            name: "CaesuraUI",
            dependencies: [
                "Caesura"
            ],
            path: "Source",
            sources: [
                "UI"
            ]
        ),
        .target(
            name: "StandardAction",
            dependencies: [
                "ReSwift"
            ],
            path: "Source/StandardAction",
            sources: [
                "StandardAction.swift",
                "StandardActionConvertible.swift",
                "StandardActionStore.swift"
            ]
        ),
        .target(
            name: "CaesuraStandardAction",
            dependencies: [
                "Caesura",
                "StandardAction"
            ],
            path: "Source/StandardAction",
            exclude: [
                "StandardAction.swift",
                "StandardActionConvertible.swift",
                "StandardActionStore.swift"
            ]
        ),
        .target(
            name: "CaesuraMiddlewares",
            dependencies: [
                "Caesura",
                "CaesuraStandardAction"
            ],
            path: "Source/Middlewares"
        ),
        .target(
            name: "ReRxCaesura",
            dependencies: [
                "Caesura",
                "ReRxSwift"
            ],
            path: "Source/ReRxSwift"
        ),
        .testTarget(
            name: "CaesuraTests",
            dependencies: [
                "Nimble",
                "Caesura"
            ],
            path: "Tests",
            exclude: ["UI"]
        )
    ]
)

// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "libgit2.swift",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Git",
            targets: ["Git"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Git",
            swiftSettings: [
                .define("GIT_EXPERIMENTAL_SHA256"),
                .define("GIT_WIN32", .when(platforms: [.windows])),
            ]),
        .testTarget(
            name: "GitTests",
            dependencies: ["Git"]
        ),
    ]
)

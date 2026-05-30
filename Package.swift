// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "EagerBeaver",
    products: [
        .library(name: "EagerBeaver", targets: ["EagerBeaver"])
    ],
    targets: [
        .target(name: "EagerBeaver"),
        .testTarget(name: "EagerBeaverTests", dependencies: ["EagerBeaver"])
    ]
)

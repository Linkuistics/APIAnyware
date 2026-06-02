// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "APIAnywareMacOS",
    platforms: [.macOS(.v14)],
    products: [
        // Every target is fully self-contained (ADR-0011, hermetic isolation):
        // it absorbs the native pieces it uses and shares no common substrate.
        // APIAnywareCommon (and the inert Gerbil stub) were deleted once chez —
        // the last real consumer — de-shared.
        .library(name: "APIAnywareRacket", type: .dynamic, targets: ["APIAnywareRacket"]),
        .library(name: "APIAnywareChez", type: .dynamic, targets: ["APIAnywareChez"]),
    ],
    targets: [
        .target(name: "APIAnywareRacket"),
        .target(name: "APIAnywareChez"),
        .testTarget(name: "APIAnywareRacketTests", dependencies: ["APIAnywareRacket"]),
        .testTarget(name: "APIAnywareChezTests", dependencies: ["APIAnywareChez"]),
    ]
)

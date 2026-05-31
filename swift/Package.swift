// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "APIAnywareMacOS",
    platforms: [.macOS(.v14)],
    products: [
        // APIAnywareRacket is fully self-contained (ADR-0011, hermetic isolation):
        // it absorbs the Common pieces it uses and has no APIAnywareCommon dependency.
        // Chez/Gerbil still statically embed APIAnywareCommon until they de-share in
        // their own groves; Common is physically deleted by whichever de-shares last.
        .library(name: "APIAnywareRacket", type: .dynamic, targets: ["APIAnywareRacket"]),
        .library(name: "APIAnywareChez", type: .dynamic, targets: ["APIAnywareChez"]),
        .library(name: "APIAnywareGerbil", type: .dynamic, targets: ["APIAnywareGerbil"]),
    ],
    targets: [
        .target(name: "APIAnywareCommon"),
        .target(name: "APIAnywareRacket"),
        .target(name: "APIAnywareChez", dependencies: ["APIAnywareCommon"]),
        .target(name: "APIAnywareGerbil", dependencies: ["APIAnywareCommon"]),
        .testTarget(name: "APIAnywareCommonTests", dependencies: ["APIAnywareCommon"]),
        .testTarget(name: "APIAnywareRacketTests", dependencies: ["APIAnywareRacket"]),
    ]
)

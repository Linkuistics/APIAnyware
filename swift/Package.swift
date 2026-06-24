// swift-tools-version: 6.2

import PackageDescription

// All four target adapters have now split out of this shared umbrella into their
// own per-target manifests at targets/<t>/adapters/macos/Package.swift — racket
// (move-racket-material-k11), chez (k12), gerbil (k13), and sbcl
// (move-sbcl-material-k14, the last). SwiftPM forbids a target path outside the
// package root, so the relocated §18 adapter sources cannot be referenced from
// here. APIAnywareCommon (and the inert Gerbil stub) were deleted once chez — the
// last real consumer — de-shared (ADR-0011, hermetic isolation).
//
// This umbrella is now empty: it owns no targets or products. The shared-seam
// leaf (shared-seam-k15) drops this manifest and the emptied swift/ tree wholesale.
let package = Package(
    name: "APIAnywareMacOS",
    platforms: [.macOS(.v26)],
    products: [],
    targets: []
)

// swift-tools-version: 6.2

import PackageDescription

// Per-target manifest for the Chez macOS adapter. Chez left the shared
// `swift/Package.swift` umbrella in move-chez-material-k12: SwiftPM forbids a
// target path outside the package root, so once the adapter sources moved into
// the §18 target tree they could no longer be referenced from `swift/`. This
// manifest owns the relocated sources directly (paths are in-root: `sources/`,
// `tests/`). The shared umbrella still carries gerbil/sbcl until they move.
let package = Package(
    name: "APIAnywareChez",
    // Deployment target raised to macOS 26 (the host SDK floor) so the
    // Swift-native method/init trampoline residual compiles without per-decl
    // @available gates (ADR-0030, spec §8.8): a @_cdecl is a plain global
    // function, so swiftc requires every API it calls to be available at the
    // package's minimum — raising the floor clears the bulk of the availability
    // errors the IR cannot gate. The dylib is a HOST tool (VM golden
    // macos-tahoe/26), never a shippable app. Requires tools-version ≥ 6.1 for
    // `.v26`.
    platforms: [.macOS(.v26)],
    products: [
        // Fully self-contained (ADR-0011, hermetic isolation): the dylib absorbs
        // the native pieces it uses and shares no common substrate.
        .library(name: "APIAnywareChez", type: .dynamic, targets: ["APIAnywareChez"]),
    ],
    targets: [
        .target(name: "APIAnywareChez", path: "sources"),
        .testTarget(
            name: "APIAnywareChezTests",
            dependencies: ["APIAnywareChez"],
            path: "tests"
        ),
    ]
)

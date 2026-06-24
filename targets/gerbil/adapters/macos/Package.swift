// swift-tools-version: 6.2

import PackageDescription

// Per-target manifest for the Gerbil macOS adapter. Gerbil left the shared
// `swift/Package.swift` umbrella in move-gerbil-material-k13: SwiftPM forbids a
// target path outside the package root, so once the adapter sources moved into
// the §18 target tree they could no longer be referenced from `swift/`. This
// manifest owns the relocated sources directly (paths are in-root: `sources/`,
// `tests/`). The shared umbrella still carries sbcl until it moves.
let package = Package(
    name: "APIAnywareGerbil",
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
        // Gerbil's Swift-native trampoline dylib (ADR-0029): the deliberate
        // ADR-0017 deviation. Gerbil's ObjC native core stays in `gsc`; this
        // dylib carries ONLY the Swift-native trampoline + hermetic helpers
        // (ADR-0011 hermetic isolation — it shares no common substrate).
        .library(name: "APIAnywareGerbil", type: .dynamic, targets: ["APIAnywareGerbil"]),
    ],
    targets: [
        .target(name: "APIAnywareGerbil", path: "sources"),
        .testTarget(
            name: "APIAnywareGerbilTests",
            dependencies: ["APIAnywareGerbil"],
            path: "tests"
        ),
    ]
)

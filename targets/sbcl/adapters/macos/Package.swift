// swift-tools-version: 6.2

import PackageDescription

// Per-target manifest for the SBCL macOS adapter. SBCL left the shared
// `swift/Package.swift` umbrella in move-sbcl-material-k14 — the last of the four
// targets to split out (racket k11, chez k12, gerbil k13 preceded it): SwiftPM
// forbids a target path outside the package root, so once the adapter sources
// moved into the §18 target tree they could no longer be referenced from
// `swift/`. This manifest owns the relocated sources directly (paths are in-root:
// `sources/`, `tests/`).
let package = Package(
    name: "APIAnywareSbcl",
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
        // SBCL's SOLE native compilation unit (ADR-0038): a Lisp compiles neither
        // ObjC nor Swift inline, so this dylib is broader than gerbil's
        // trampoline-only one — it also hosts the foreign→main CallbackBounce
        // (ADR-0035) and the SubclassSynth IMP installer (ADR-0034 §5). The MOP
        // object model stays in Lisp; "trampoline-only" holds in *that* sense.
        // Fully self-contained (ADR-0011, hermetic isolation): the dylib absorbs
        // the native pieces it uses and shares no common substrate.
        .library(name: "APIAnywareSbcl", type: .dynamic, targets: ["APIAnywareSbcl"]),
    ],
    targets: [
        .target(name: "APIAnywareSbcl", path: "sources"),
        .testTarget(
            name: "APIAnywareSbclTests",
            dependencies: ["APIAnywareSbcl"],
            path: "tests"
        ),
    ]
)

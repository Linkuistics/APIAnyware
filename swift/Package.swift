// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "APIAnywareMacOS",
    // Deployment target raised to macOS 26 (the host SDK floor) so the
    // Swift-native method/init trampoline residual compiles without per-decl
    // @available gates (ADR-0030, spec §8.8): a @_cdecl is a plain global
    // function, so swiftc requires every API it calls to be available at the
    // package's minimum — raising the floor clears the bulk of the
    // availability errors that the IR cannot gate (provenance: null, or the
    // owning type's availability exceeding the method's). Package-wide platform
    // ⇒ sbcl inherits the bump; acceptable because the dylib is a
    // HOST tool (VM golden macos-tahoe/26), never a shippable app. Requires
    // swift-tools-version ≥ 6.1 to expose `.v26`.
    platforms: [.macOS(.v26)],
    products: [
        // Every target is fully self-contained (ADR-0011, hermetic isolation):
        // it absorbs the native pieces it uses and shares no common substrate.
        // APIAnywareCommon (and the inert Gerbil stub) were deleted once chez —
        // the last real consumer — de-shared.
        //
        // Racket left this umbrella in move-racket-material-k11, chez in
        // move-chez-material-k12, and gerbil in move-gerbil-material-k13: each
        // adapter now lives in the §18 target tree with its own manifest at
        // targets/<t>/adapters/macos/Package.swift (SwiftPM forbids a target
        // path outside the package root, so the relocated sources cannot be
        // referenced from here). sbcl follows in its own leaf — until then this
        // umbrella carries only sbcl.
        //
        // SBCL's SOLE native compilation unit (ADR-0038): a Lisp compiles neither
        // ObjC nor Swift inline, so this dylib is broader than gerbil's
        // trampoline-only one — it also hosts the foreign→main CallbackBounce
        // (ADR-0035) and the SubclassSynth IMP installer (ADR-0034 §5). The MOP
        // object model stays in Lisp; "trampoline-only" holds in *that* sense.
        .library(name: "APIAnywareSbcl", type: .dynamic, targets: ["APIAnywareSbcl"]),
    ],
    targets: [
        .target(name: "APIAnywareSbcl"),
        .testTarget(name: "APIAnywareSbclTests", dependencies: ["APIAnywareSbcl"]),
    ]
)

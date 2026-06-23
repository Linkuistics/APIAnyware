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
    // ⇒ chez/gerbil inherit the bump; acceptable because all three dylibs are
    // HOST tools (VM golden macos-tahoe/26), never shippable apps. Requires
    // swift-tools-version ≥ 6.1 to expose `.v26`.
    platforms: [.macOS(.v26)],
    products: [
        // Every target is fully self-contained (ADR-0011, hermetic isolation):
        // it absorbs the native pieces it uses and shares no common substrate.
        // APIAnywareCommon (and the inert Gerbil stub) were deleted once chez —
        // the last real consumer — de-shared.
        .library(name: "APIAnywareRacket", type: .dynamic, targets: ["APIAnywareRacket"]),
        .library(name: "APIAnywareChez", type: .dynamic, targets: ["APIAnywareChez"]),
        // Gerbil's Swift-native trampoline dylib (ADR-0029): the deliberate
        // ADR-0017 deviation. Gerbil's ObjC native core stays in `gsc`; this
        // dylib carries ONLY the Swift-native trampoline + hermetic helpers.
        .library(name: "APIAnywareGerbil", type: .dynamic, targets: ["APIAnywareGerbil"]),
        // SBCL's SOLE native compilation unit (ADR-0038): a Lisp compiles neither
        // ObjC nor Swift inline, so this dylib is broader than gerbil's
        // trampoline-only one — it also hosts the foreign→main CallbackBounce
        // (ADR-0035) and the SubclassSynth IMP installer (ADR-0034 §5). The MOP
        // object model stays in Lisp; "trampoline-only" holds in *that* sense.
        .library(name: "APIAnywareSbcl", type: .dynamic, targets: ["APIAnywareSbcl"]),
    ],
    targets: [
        .target(name: "APIAnywareRacket"),
        .target(name: "APIAnywareChez"),
        .target(name: "APIAnywareGerbil"),
        .target(name: "APIAnywareSbcl"),
        .testTarget(name: "APIAnywareRacketTests", dependencies: ["APIAnywareRacket"]),
        .testTarget(name: "APIAnywareChezTests", dependencies: ["APIAnywareChez"]),
        .testTarget(name: "APIAnywareGerbilTests", dependencies: ["APIAnywareGerbil"]),
        .testTarget(name: "APIAnywareSbclTests", dependencies: ["APIAnywareSbcl"]),
    ]
)

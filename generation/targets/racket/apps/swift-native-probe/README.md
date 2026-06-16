# Swift-Native Probe (racket)

A verification **probe**, not a portfolio sample app. It proves the complete-API
**Swift-native trampoline** mechanism (ADR-0025 / ADR-0027) works end-to-end in a
real GUI app — the project done-bar that the in-process CLI smoke does not satisfy.

It opens an AppKit window showing two Swift-native CreateML decls, each reached
**only** through `libAPIAnywareRacket`'s `@_cdecl` trampolines (`_aw-lib`), never
the framework dylib:

| Kind | Swift decl | Trampoline entry |
|---|---|---|
| free function | `CreateML.timestampSeed() -> Int` | `aw_racket_swift_CreateML_timestampSeed` |
| constant | `CreateML.MLCreateErrorDomain: String` | `aw_racket_swift_const_CreateML_MLCreateErrorDomain` |

Both carry `objc_exposed: false` and have no C symbol in `CreateML.framework`, so a
window that renders their live values is unambiguous evidence the Swift-native path
is bound (spec `docs/specs/2026-06-15-racket-trampoline.md` §6a/§6b).

## Run / verify

GUI testing uses TestAnyware (never run apps from the CLI — see the apps README).
The repeatable recipe and the VM-verify evidence are in spec §6b; the captured
screenshot is at `../../test-results/swift-native-probe/screenshot.png`.

Build the bundle: `cargo run --example bundle_app -p apianyware-macos-bundle-racket -- swift-native-probe`.

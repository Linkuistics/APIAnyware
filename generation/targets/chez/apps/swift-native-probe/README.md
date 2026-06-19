# Swift-Native Probe (chez)

A verification **probe**, not a portfolio sample app. It proves the complete-API
**Swift-native trampoline** mechanism (ADR-0025 / ADR-0027, ported to chez in
ADR-0028) works end-to-end in a real GUI app — the project done-bar that the
in-process CLI smoke (`runtime/tests/smoke-swift-trampoline.sls`) does not satisfy.

It opens an AppKit window showing two Swift-native CreateML decls, each reached
**only** through `libAPIAnywareChez`'s `@_cdecl` trampolines, never the framework
dylib:

| Kind | Swift decl | Trampoline entry |
|---|---|---|
| free function | `CreateML.timestampSeed() -> Int` | `aw_chez_swift_CreateML_timestampSeed` |
| constant | `CreateML.MLCreateErrorDomain: String` | `aw_chez_swift_const_CreateML_MLCreateErrorDomain` |

Both carry `objc_exposed: false` and have no C symbol in `CreateML.framework`, so a
window that renders their live values is unambiguous evidence the Swift-native path
is bound (spec `docs/specs/2026-06-15-racket-trampoline.md` §6a; chez slice §6c).

Per ADR-0015 the chez `String` coercion is **Scheme-side**: the constant trampoline
returns an `id` (NSString) and `(apianyware createml constants)` coerces it with the
existing `aw-string-result` — no native string bridge (the racket↔chez divergence
the 060 brief flags). This is the chez counterpart of the racket probe
(`generation/targets/racket/apps/swift-native-probe/`).

## Run / verify

GUI testing uses TestAnyware (never run apps from the CLI — see the apps README and
`feedback-use-testanyware`). The captured VM-verify screenshot is at
`../../test-results/swift-native-probe/screenshot.png`.

Build the standalone bundle (compiles the whole closure):
`cargo run --example bundle_app -p apianyware-macos-bundle-chez -- swift-native-probe`.

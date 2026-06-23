# Swift-Native Method Probe (chez)

A verification **probe**, not a portfolio sample app. The method-frontier sibling of
`swift-native-probe`: it proves the receiver-handle **method** trampoline mechanism
(ADR-0030, ported to chez in ADR-0031, spec `docs/specs/2026-06-15-racket-trampoline.md`
§8/§9) works end-to-end in a real GUI app — the project done-bar that the in-process
CLI smoke (`runtime/tests/smoke-swift-method.sls`) does not satisfy.

It opens an AppKit window showing two Swift-native (`objc_exposed: false`) method
exemplars, each reached **only** through `libAPIAnywareChez`'s `@_cdecl` trampolines,
never the framework dylib:

| Population | Swift decls | Trampoline entries |
|---|---|---|
| B — value-struct methods | `Foundation.IndexSet`: `init(integer:)` → `insert(_:)` → `contains(_:)` | `aw_chez_swift_init_Foundation_IndexSet_*`, `aw_chez_swift_m_Foundation_IndexSet_{insert,contains}_*` |
| A — async method | `Foundation.URLSession.data(from:)` | `aw_chez_swift_m_Foundation_URLSession_data_*` |

- **pop-B** exercises the D2 init producer + D3 **mutating write-back** on one boxed
  `AwChezValueBox` receiver: after `insert!(7)`, the *same* handle reports
  `contains 7 = #t` while still reporting `contains 5 = #t`.
- **pop-A** exercises the chez async-via-callback runtime (`async-bridge.sls`, R4):
  `data(from: file://…)` runs off the main thread and the completion fills the
  byte-count label on the main thread (the MainActor hop, drained by
  `nsapplication-run`). This is the first chez async path — chez had an empty async
  bucket for free functions (ADR-0028 §4).

Per ADR-0015 the chez marshalling is **Scheme-side** (the racket↔chez divergence): the
receiver is boxed/unboxed through `AwChezValueBox` and the object-ref URL param is
unwrapped with `coerce-arg`, mirroring the chez free-function coercers — no native
bridge. A window that renders both live values is unambiguous evidence the Swift-native
method path is bound (spec §8.8, ADR-0030 §B6 / ADR-0031).

This is the chez counterpart of the racket probe
(`generation/targets/racket/apps/swift-native-method-probe/`); it reuses the same two
030 known-good exemplars (D7).

## Run / verify

GUI testing uses TestAnyware (never run apps from the CLI — see the apps README and
`feedback-use-testanyware`). The captured VM-verify evidence is at
`../../test-results/swift-native-method-probe/screenshot.png` (golden `macos-tahoe`).

Build the standalone open-world bundle (compiles the whole closure, ADR-0009):
`cargo run --example bundle_app -p apianyware-bundle-chez -- swift-native-method-probe`.

Run unbundled (CLI banner only — GUI verification is the VM):
```
chez --libdirs generation/targets/chez \
     --script generation/targets/chez/apps/swift-native-method-probe/swift-native-method-probe.sls
```

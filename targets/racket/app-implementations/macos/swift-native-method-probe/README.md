# Swift-Native Method Probe (racket)

A verification **probe**, not a portfolio sample app. The method-frontier sibling of
`swift-native-probe`: it proves the receiver-handle **method** trampoline mechanism
(ADR-0030, spec `targets/racket/docs/design/2026-06-15-racket-trampoline.md` §8/§9) works end-to-end
in a real GUI app — the project done-bar that the in-process CLI smoke does not satisfy.

It opens an AppKit window showing two Swift-native (`objc_exposed: false`) method
exemplars, each reached **only** through `libAPIAnywareRacket`'s `@_cdecl` trampolines
(`_aw-lib`), never the framework dylib:

| Population | Swift decls | Trampoline entries |
|---|---|---|
| B — value-struct methods | `Foundation.IndexSet`: `init(integer:)` → `insert(_:)` → `contains(_:)` | `aw_racket_swift_init_Foundation_IndexSet_*`, `aw_racket_swift_m_Foundation_IndexSet_{insert,contains}_*` |
| A — async method | `Foundation.URLSession.data(from:)` | `aw_racket_swift_m_Foundation_URLSession_data_*` |

- **pop-B** exercises the D2 init producer + D3 **mutating write-back** on one boxed
  receiver: after `insert!(7)`, the *same* handle reports `contains 7 = #t`.
- **pop-A** exercises the async-bridge callback runtime: `data(from: file://…)` runs
  off the main thread and the completion fills the byte-count label on the main thread.

A window that renders both live values is unambiguous evidence the Swift-native method
path is bound (spec §8.8, ADR-0030 §B6).

## Run / verify

GUI testing uses TestAnyware (never run apps from the CLI — see the apps README).
The captured VM-verify evidence is at
`../../test-results/swift-native-method-probe/screenshot.png` (golden `macos-tahoe`).

Build the bundle:
`cargo run --example bundle_app -p apianyware-bundle-racket -- swift-native-method-probe`

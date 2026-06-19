# Swift-Native Method Probe (gerbil)

A verification **probe**, not a portfolio sample app. The method-frontier sibling of
`swift-native-probe`: it proves the receiver-handle **method** trampoline mechanism
(ADR-0030 pioneered in racket, ported to gerbil in ADR-0032, spec
`docs/specs/2026-06-15-racket-trampoline.md` §method) works end-to-end in a real GUI
app — the project done-bar that the in-process CLI smoke
(`runtime/tests/smoke-swift-method.ss`) does not satisfy.

It opens an AppKit window showing two Swift-native (`objc_exposed: false`) method
exemplars, each reached **only** through `libAPIAnywareGerbil`'s `@_cdecl` trampolines
(bound via `define-c-lambda`, the ADR-0017 idiom), never the framework dylib:

| Population | Swift decls | Trampoline entries |
|---|---|---|
| B — value-struct methods | `Foundation.IndexSet`: `init(integer:)` → `insert(_:)` → `contains(_:)` | `aw_gerbil_swift_init_Foundation_IndexSet_*`, `aw_gerbil_swift_m_Foundation_IndexSet_{insert,contains}_*` |
| A — async method | `Foundation.URLSession.data(from:)` | `aw_gerbil_swift_m_Foundation_URLSession_data_*` |

- **pop-B** exercises the D2 init producer + D3 **mutating write-back** on one boxed
  `AwGerbilValueBox` receiver (a raw opaque handle — no ObjC class to wrap to, ADR-0032
  §4): after `insert!(7)`, the *same* handle reports `contains 7 = #t` while still
  reporting `contains 5 = #t`.
- **pop-A** exercises the gerbil async-via-callback runtime (`async-bridge.ss`, R4):
  `data(from: file://…)` runs off the main thread and the completion fills the
  byte-count label on the main thread (the MainActor hop, drained by
  `nsapplication-run`). This is the **first gerbil async path** — gerbil had an empty
  async bucket for free functions (ADR-0029 §5, ADR-0032 §5).

Per ADR-0015 the gerbil marshalling is **Scheme-side**: the receiver coerces to its
raw handle pointer via `(->ptr self)` and the object-ref URL param is an `id`. gerbil's
substantive divergence from chez (ADR-0029 §2 / ADR-0032 §2) is that object returns
`wrap` to their exact bound type via the ADR-0020 `register-objc-class!` registry; the
IndexSet value-struct handle has no ObjC class, so it stays a raw opaque box. A window
that renders both live values is unambiguous evidence the Swift-native method path is
bound (spec §method, ADR-0032 §Consequences).

Unlike chez (which `dlopen`s `libAPIAnywareChez`), gerbil **links** the dylib at
`gxc -exe` time (`-lAPIAnywareGerbil`, ADR-0029 §4), so the symbols resolve at image
load. `bundle-gerbil` vendors + relocates the dylib into `Contents/Frameworks/` by the
*same* path that already relocates openssl@3 (ADR-0029 §3), so `otool -L` on the
bundled exe shows only `/usr/lib/*`, system frameworks, and `@executable_path/..`.

This is the gerbil counterpart of the racket / chez probes
(`generation/targets/{racket,chez}/apps/swift-native-method-probe/`); it reuses the
same two 030 known-good exemplars (D7).

## Run / verify

GUI testing uses TestAnyware (never run apps from the CLI — see the apps README and
`feedback-use-testanyware`). The captured VM-verify evidence is at
`../../test-results/swift-native-method-probe/screenshot.png` (golden `macos-tahoe`).

Build the standalone bundle (compiles the whole closure, links + relocates the dylib):

```
SDKROOT=macosx cargo run -p apianyware-macos-generate -- --target gerbil
(cd swift && SDKROOT=macosx swift build -c release --product APIAnywareGerbil)
cargo run --example bundle_app -p apianyware-macos-bundle-gerbil -- swift-native-method-probe
```

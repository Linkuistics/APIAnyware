# Swift-Native Probe — Chez Test Report

**Date:** 2026-06-18
**Status:** PASS
**Leaf:** `add-swift-native-api-coverage/060/020` (closes the chez slice)

A verification **probe**, not a portfolio app: proves the complete-API
Swift-native **trampoline** mechanism (ADR-0025 / ADR-0027, ported to chez in
ADR-0028) works end-to-end in a real GUI app — the project done-bar that the
in-process CLI smoke (`runtime/tests/smoke-swift-trampoline.sls`) does not satisfy.

## Cold full rerun (the residual reproduces from a cold collect)

`collect` (284 frameworks, 0 errors) → `analyze` (0 verification failures across
284, LLM annotations replayed from the git-tracked `analysis/ir/llm-annotations/`)
→ `generate --target chez` → `swift build`. The chez residual classification
**reproduced exactly** — identical to racket's (same shared IR), so the counts are
a deterministic function of the SDK, not stale local IR:

| | count |
|---|---|
| function trampolines | **51** |
| constant trampolines | **7** |
| deferred `closure_param` | 6 |
| deferred `nonbridged_struct_param` | 10 |
| deferred `unnameable_param` | 4 |
| `unbindable_generic_free_function` | 34 |

No ObjC regression: `cargo test --workspace` **961 passed / 0 failed**. The chez
CLI smoke (`smoke-swift-trampoline.sls`) passed **3/3** against the freshly built
`libAPIAnywareChez.dylib` and is now registered in the runtime README's "Verifying
the runtime" harness as the permanent trampoline regression guard (the chez analog
of racket 050's `RUNTIME_LOAD_TEST` registration).

## Build (standalone open-world `.app`, ADR-0009)

`cargo run --example bundle_app -p apianyware-macos-bundle-chez -- swift-native-probe`.
Output: `Swift Native Probe.app`, **3.1 MB** tarball, bundle id
`com.linkuistics.SwiftNativeProbe`. The whole closure (incl. the `createml`
trampoline bindings) compiles into `Contents/Resources/swift-native-probe.boot`;
`Contents/Resources/lib/libAPIAnywareChez.dylib` is the embedded trampoline dylib.
The whole-program compile succeeding *is* the chez load-verification — it caught one
real bug during the port (an internal `define` placed after body expressions →
"invalid context for definition"), fixed before VM-verify.

## VM verify (no-Chez bar)

Golden `testanyware-golden-macos-tahoe`. Uploaded the 3.1 MB tarball (md5-verified
`5bac84dd…`), `xattr -dr com.apple.quarantine`, disabled click-to-show-desktop,
launched via `open -n`. Results:

- [x] Window appears, titled **"Swift-Native API Coverage"**, 560×272, centred.
- [x] Menu bar reads **"Swift Native Probe"** (standalone model — no `execv` into a
      system chez).
- [x] **`CreateML.timestampSeed()` → `1781740880061`** — a live, time-derived `Int`
      returned through `aw_chez_swift_CreateML_timestampSeed`.
- [x] **`CreateML.MLCreateErrorDomain` → `com.apple.CreateML`** — a Swift-native
      `String` constant, Scheme-side coerced (ADR-0015) from the `id` the
      `aw_chez_swift_const_…` trampoline returns.
- [x] Launch log prints both values (`/tmp/probe.log`): the trampolines bind and run
      before the UI draws.
- [x] Polish (`feedback-sample-apps-perfect`): heading + two aligned rows with blue
      accent values + a two-line secondary-label footer; no artifacts, intentional
      layout — not just a window.

Both symbols carry `objc_exposed: false` and have **no** C symbol in
`CreateML.framework`; rendering their live values is unambiguous evidence the
Swift-native path is bound through `libAPIAnywareChez`'s `@_cdecl` trampolines.

- `screenshot.png` — the probe window (primary evidence).
- `screenshot-desktop.png` — full desktop (menu-bar app identity + dock context).

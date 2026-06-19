# Swift-Native Method Probe — Gerbil Test Report

**Date:** 2026-06-20
**Status:** PASS
**Leaf:** `add-swift-native-method-coverage/050-gerbil/020-rerun-verify` (last leaf → grove ready to finish)

A verification **probe**, not a portfolio app: proves the receiver-handle **method**
trampoline mechanism (ADR-0030 pioneered in racket, ported to gerbil in ADR-0032,
spec §method) works end-to-end in a real GUI app — the project done-bar that the
in-process CLI smoke (`runtime/tests/smoke-swift-method.ss`) does not satisfy. The
method-frontier sibling of `swift-native-probe` (free functions/constants, ADR-0029).

## Cold full rerun (the residual reproduces from a cold collect)

`collect` (284 frameworks, **0 errors**) → `analyze` (**284 enriched / 0 verification
failures**, LLM annotations replayed from the git-tracked
`analysis/ir/llm-annotations/`) → `generate --target gerbil` → `swift build -c release
--product APIAnywareGerbil` (**0 errors**, B5 `@MainActor` warnings carry by design).
Regeneration is byte-identical to the committed tree (SwiftPM skipped the recompile —
determinism). The gerbil residual classification **reproduced racket's and chez's
exactly** (the §6d invariant — a deterministic function of the shared IR, only the
`aw_gerbil_swift_*` entry prefix differs):

| | count |
|---|---|
| function trampolines | **51** |
| constant trampolines | **7** |
| init trampolines | **576** |
| method trampolines | **554** |
| deferred `actor_isolated` | 27 |
| deferred `nonbridged_struct_param` | 3169 |
| deferred `static_method` | 1106 |
| deferred `closure_param` | 68 |
| `unbindable_generic_method` | 5567 |
| `unbindable_generic_free_function` | 34 |

(plus the byte-identical tail: 1 argument_shape_mismatch, 1 async_scalar_return, 2
compile_time_constant_param, 2 generic_inference_failure, 4 immutable_inout_argument,
2 inaccessible_decl, 6 module_member_missing, 1 noncopyable_receiver, 12
nullable_scalar_return, 2 unknown_availability, 106 unnameable_param, 4
unresolved_member_type — 1188 entries total.)

No ObjC regression: `cargo test --workspace` **green** (incl. the `bundle-gerbil`
swift-dylib relocation tests; the known `computes_hello_window_closure` env-flake
passed this run). The new `emit-gerbil/tests/runtime_load_test.rs`
(`runtime_swift_method_roundtrip`) is wired as the §6b permanent regression guard
(gerbil analogue of chez's `runtime_load_test.rs`), skip-as-pass without
`RUNTIME_LOAD_TEST=1`. The gerbil smoke harness (`run-smokes.sh`) now **chains the
Swift-native method smoke** (`run-swift-method-smoke.sh`) alongside the existing
free-function trampoline smoke — the permanent CLI guard exercising the
receiver-handle bindings (init producer D2 + mutating write-back D3) and the first
gerbil async path.

**Stale-golden fix (the cold rerun's payoff).** With the enriched IR materialised,
the previously-skipped `snapshot_gerbil_foundation_subset` golden test ran and caught
a stale golden: `NSArray.makeIterator` was recorded as a **broken `objc_msgSend`**
(the charter-#4 latent bug — `makeIterator` is `objc_exposed: false`) instead of the
`aw_gerbil_swift_m_Foundation_NSArray_makeIterator` trampoline. Regenerated with
`UPDATE_GOLDEN=1`; the diff is exactly the new Swift-native method/init sections +
the population-B value-struct module re-exports (ADR-0032 §4), no unexpected drift.

## Build (standalone self-contained `.app`, ADR-0009)

`cargo run --example bundle_app -p apianyware-macos-bundle-gerbil -- swift-native-method-probe`.
Output: `Swift Native Method Probe.app`, bundle id `com.linkuistics.SwiftNativeMethodProbe`.
The `gxc -exe` binary embeds the whole Gerbil/Gambit runtime; the app exe links
`-lAPIAnywareGerbil` (ADR-0029 §4: linked, not dlopen'd like chez). `bundle-gerbil`
vendored + relocated the dylib into `Contents/Frameworks/` by the **same** path that
relocates openssl@3 (ADR-0029 §3).

**`otool -L` self-containment passes.** The bundled exe shows only `/usr/lib/*`,
system frameworks, and `@executable_path/../Frameworks/*` (libAPIAnywareGerbil,
libssl.3, libcrypto.3) — no `/opt/homebrew/*`, no dangling `@rpath`.

## VM verify (no-Gerbil bar)

Golden `testanyware-golden-macos-tahoe`. Standalone bundle needs no toolchain
provisioning (the exe embeds the runtime, ADR-0009): uploaded the 23 MB tarball
(md5-verified `b2559250…`), `xattr -dr com.apple.quarantine`, disabled
click-to-show-desktop, launched via `open -n`. Results:

- [x] Window appears, titled **"Swift-Native Method Frontier"**, 620×292, centred.
- [x] Menu bar reads **"Swift Native Method Probe"** (CFBundleName — the standalone native exe).
- [x] **pop-B IndexSet** (value-struct, `objc_exposed: false`): `init(5) -> insert!(7):
      contains 7 = #t (was #f), contains 5 = #t` — the D2 init producer + D3 mutating
      write-back on **one** boxed `AwGerbilValueBox` handle, all through
      `aw_gerbil_swift_{init,m}_Foundation_IndexSet_*`. The same handle observing the
      inserted member while preserving the original is live proof of the write-back.
- [x] **pop-A URLSession.data(from: file://…)** (async method, `objc_exposed: false`):
      `-> delivered a real (Data, URLResponse) -- 59 expected bytes` — the **first
      gerbil async path** (ADR-0032 §5): the generated binding drives `async-bridge.ss`,
      the completion fires on the main thread (the MainActor hop, drained by
      `nsapplication-run`) and fills the byte-count label.
- [x] Polish (`feedback-sample-apps-perfect`): heading + two aligned rows with blue
      accent values + a two-line secondary-label footer; intentional layout.

Both decls carry `objc_exposed: false` and have **no** C symbol in
`Foundation.framework`; rendering their live values is unambiguous evidence the
Swift-native **method** path is bound through `libAPIAnywareGerbil`'s receiver-handle
`@_cdecl` trampolines — the thing `gsc` structurally cannot do.

- `screenshot.png` — the probe window (primary evidence).
- `screenshot-desktop.png` — full desktop (menu-bar app identity + dock context).

## N1 measurement (build-time finding, re-confirmed)

The added `swift build` is **immaterial**, as ADR-0029 found for free functions and
ADR-0032 carried forward. The whole `APIAnywareGerbil` module — all **1188**
trampolines incl. the new 576 init + 554 method + async `@_cdecl`s — compiles as one
whole-module TU in **~2 s** and links in single-digit seconds. It lives in a separate
toolchain (`swiftc`) that never touches the `gsc`/`gxc` generics path, so the ADR-0023
generics cost (the ~325 s parallel shard compile observed in this bundle) is provably
unchanged. The method/init/async additions are pure, small addition — N1 stays closed.

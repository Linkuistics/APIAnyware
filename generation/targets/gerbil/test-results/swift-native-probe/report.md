# Swift-Native Probe — Gerbil Test Report

**Date:** 2026-06-18
**Status:** PASS
**Leaf:** `add-swift-native-api-coverage/070/030` (closes the gerbil slice → the grove)

A verification **probe**, not a portfolio app: proves the complete-API
Swift-native **trampoline** mechanism (ADR-0025 / ADR-0027, ported to gerbil in
ADR-0029 — the deliberate ADR-0017 deviation) works end-to-end in a real GUI app —
the project done-bar that the in-process CLI smoke
(`runtime/tests/smoke-swift-trampoline.ss`) does not satisfy.

## Cold full rerun (the residual reproduces from a cold collect)

`collect` (284 frameworks, 0 errors, 48s) → `analyze` (0 verification failures
across 284, LLM annotations replayed from the git-tracked
`analysis/ir/llm-annotations/`, 8s) → `generate --target gerbil` → `swift build`.
The gerbil residual classification **reproduced exactly** — identical to racket's
and chez's (same shared IR, the `objc_exposed` fact), so the counts are a
deterministic function of the SDK, not stale local IR:

| | count |
|---|---|
| function trampolines | **51** |
| constant trampolines | **7** |
| deferred `closure_param` | 6 |
| deferred `nonbridged_struct_param` | 10 |
| deferred `unnameable_param` | 4 |
| `unbindable_generic_free_function` | 34 |

No ObjC regression: `cargo test --workspace` **985 passed / 0 failed** (incl. the
new `bundle-gerbil` swift-dylib relocation tests). The gerbil smoke harness
(`run-smokes.sh`) is green, and now **chains the Swift-native trampoline smoke**
(`smoke-swift-trampoline.ss`) as the permanent regression guard — the gerbil analog
of racket's `RUNTIME_LOAD_TEST` / chez's smoke registration. The guard exercises the
trampoline require-shape (the `define-c-lambda` bindings resolving against
`libAPIAnywareGerbil`) and the constant-trampoline round-trip at module init.

## Build (standalone self-contained `.app`, ADR-0009)

`cargo run --example bundle_app -p apianyware-macos-bundle-gerbil -- swift-native-probe`.
Output: `Swift Native Probe.app`, bundle id `com.linkuistics.SwiftNativeProbe`. The
`gxc -exe` binary embeds the whole Gerbil/Gambit runtime; the build order is the
ADR-0029 one — `generate → swift build → gxc` — and the app exe links
`-lAPIAnywareGerbil` (ADR-0029 §4: linked, not dlopen'd like chez). `bundle-gerbil`
vendored + relocated the dylib into `Contents/Frameworks/` by the **same** path that
already relocates openssl@3 (ADR-0029 §3 — no new mechanism).

**`otool -L` self-containment passes.** The bundled exe shows only `/usr/lib/*`,
system frameworks, and `@executable_path/../Frameworks/*`:

```
@executable_path/../Frameworks/libAPIAnywareGerbil.dylib   <- the Swift trampoline dylib, relocated
@executable_path/../Frameworks/libssl.3.dylib              <- openssl@3 (Gerbil stdlib)
@executable_path/../Frameworks/libcrypto.3.dylib
/usr/lib/*, /System/Library/Frameworks/{AppKit,Foundation,CreateML}  <- system
```

No `/opt/homebrew/*` and no `@rpath` left dangling — the `@rpath/libAPIAnywareGerbil.dylib`
link command was rewritten to `@executable_path/..` by `relocate_swift_dylib`.

## VM verify (no-Gerbil bar)

Golden `testanyware-golden-macos-tahoe`. Standalone bundle needs no toolchain
provisioning (the exe embeds the runtime, ADR-0009): uploaded the 23 MB tarball
(md5-verified `c4bb0318…`), `xattr -dr com.apple.quarantine`, disabled
click-to-show-desktop, launched via `open -n`. Results:

- [x] Window appears, titled **"Swift-Native API Coverage"**, 560×272, centred.
- [x] Menu bar reads **"Swift Native Probe"** (CFBundleName — the standalone native exe).
- [x] **`CreateML.timestampSeed()` → `1781763860100`** — a live, time-derived `Int`
      returned through `aw_gerbil_swift_CreateML_timestampSeed`, bound by `define-c-lambda`.
- [x] **`CreateML.MLCreateErrorDomain` → `com.apple.CreateML`** — a Swift-native
      `String` constant, Scheme-side coerced (ADR-0015) from the `id` the
      `aw_gerbil_swift_const_…` trampoline returns (no native string bridge).
- [x] Polish (`feedback-sample-apps-perfect`): heading + two aligned rows with blue
      accent values + a two-line secondary-label footer; intentional layout, not just a window.

Both symbols carry `objc_exposed: false` and have **no** C symbol in
`CreateML.framework`; rendering their live values is unambiguous evidence the
Swift-native path is bound through `libAPIAnywareGerbil`'s `@_cdecl` trampolines —
the thing `gsc` structurally cannot do.

- `screenshot.png` — the probe window (primary evidence).
- `screenshot-desktop.png` — full desktop (menu-bar app identity + dock context).

## N1 measurement (the build-time finding, quantified — appended to ADR-0029)

| | wall-clock |
|---|---|
| `swift build -c release --product APIAnywareGerbil` (cold, after `swift package clean`) | **3.96s** (84 KB dylib) |
| same, warm/no-op rebuild | 0.34s |
| gerbil generics compile (113 shards, cold parallel — ADR-0023, the gxc path) | **291.5s**, *unchanged* by the dylib |

The added `swift build` step is **~4s of pure addition**, orthogonal to and dwarfed
by the ~292s generics compile that dominates gerbil's cold build. The dylib lives in
a **separate toolchain** (`swiftc`) that never touches the `gsc`/`gxc` generics path,
so the ADR-0023 cost is provably unchanged. N1's hypothesised build-time *win* does
**not** hold — there is nothing in `gsc` to offload (the trampoline is new work that
never flowed through it). The dylib is justified by **necessity** (only Swift can call
the Swift ABI), not by a build-time gain. N1 closed honestly.

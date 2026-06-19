# 050-gerbil — brief

Inherit node. Decomposed (2026-06-19) per the leaf's Notes / D6. gerbil is the
**third and last** Swift-trampoline-for-methods target — a horizontal port of the
`030-racket` design (ADR-0030 + spec §method) as already re-spelled for chez
(ADR-0031), **not** a rediscovery. The hard design work (async callback form R4,
the swift-residual close B1–B5) is done in racket and confirmed reproducible by
chez through the shared IR. gerbil's divergences are exactly the ones ADR-0029
already recorded for free functions: a **trampoline-only Swift dylib** (only Swift
calls the Swift ABI), `define-c-lambda` binding (not chez's `foreign-procedure`),
returned objects **wrapped to their exact bound type** via the ADR-0020
`register-objc-class!` registry, **no lazy-load forcing reference** (dylib linked at
`gxc -exe` time ⇒ symbols resolve at image load, ADR-0029 §4), and a
`bundle-gerbil` relocation of the dylib into `Contents/Frameworks/`. Two leaves:

- **`010-build`** — port the method machinery into `emit-gerbil`: `MethodTrampoline`
  + `InitProducer` codegen mirroring chez's `trampoline.rs`, receiver unbox A/B
  (value box / `Unmanaged` class), init producers (D2) wrapping the **owner** through
  the ADR-0020 registry, mutating write-back (D3), object-ref params (R1),
  async-via-callback (D5/R4) over a **new** gerbil async surface (gerbil's free-fn
  async bucket was empty, exactly as chez's was ⇒ first gerbil async path), charter-#4
  routing fix in gerbil `emit_class.rs` (`objc_exposed` branch: suppress + count), and
  the swift-residual close (re-attribution B2, owner-availability fold B3,
  `KNOWN_UNBINDABLE` keyed by the **gerbil** `aw_gerbil_swift_*` entry name B4; B1
  `.macOS(.v26)` floor is package-wide already). Dylib gains the method/init/async
  `@_cdecl`s; `OpaqueHandle.swift` value box → `var` (D3) + a new `AsyncBridge.swift`.
  Runtime `swift-trampoline.ss` method/init binding shapes + a new `async-bridge.ss`.
  In-process/CLI smoke of both exemplars. Lands the thin ADR (the "0029-for-methods",
  mirroring how ADR-0031 mirrored ADR-0030) + co-located docs. Residual must reproduce
  racket's/chez's counts (§6d invariant).
- **`020-rerun-verify`** — full cold pipeline rerun (`collect`→`analyze`→`generate
  --target gerbil`→`swift build`→`gxc`), `cargo test --workspace` green (incl.
  `bundle-gerbil` dylib-relocation tests), CLI smoke chained into `run-smokes.sh` as
  the permanent regression guard, residual-count reproduction from cold collect, and
  VM-verify both exemplars (recovered async method + population-B init→method) live in
  a bundled self-contained `.app` (ADR-0009, `otool -L` clean), screenshot in
  `test-results/`. N1 (added swift-build cost) re-measured if material. On close the
  grove is ready to **finish**.

The original leaf's contract (Goal / Context / Done-when / Notes) is retained below;
the two leaves partition it.

## Goal

Port the receiver-handle method trampoline (pioneered in `030-racket`) to the
**gerbil** target — the last target — with its own thin structural ADR (the
"0029-for-methods", mirroring ADR-0029). Rerun + VM-verify.

## Context

Blocks on `020-method-recovery` (shared IR) and `030-racket` (the pioneered design +
ADR + spec). gerbil's free-function trampoline path: ADR-0029 (gerbil grows a
trampoline-only Swift dylib because only Swift can call the Swift ABI; `define-c-lambda`
binding, dylib **linked** at `gxc -exe` time, relocated by `bundle-gerbil` into
`Contents/Frameworks/`). The method receiver adds pointer/scalar args over that
existing dylib-call path (D6) — no new seam expected; the dylib just gains the
method/init `@_cdecl`s.

## Done when

- gerbil method-trampoline codegen + emitter routing port the 030 design: receiver
  unbox, initializer producers, mutating write-back, async-via-`await`, charter-#4
  `objc_exposed` branch (suppress + count).
- Residual method classification **reproduces identically to racket's and chez's**
  (the §6d invariant), counts reported.
- Full cold rerun (`collect`→`analyze`→`generate --target gerbil`→`swift build`→`gxc`)
  + `cargo test --workspace` green (incl. any `bundle-gerbil` dylib-relocation tests) +
  gerbil `run-smokes.sh` chains the Swift-native-method smoke as a permanent guard.
- **VM-verified:** the gerbil `swift-native-probe` (or equivalent) shows the
  exemplars — incl. a recovered async method + a population-B init→method — live in a
  standalone self-contained `.app` (ADR-0009); bundled exe `otool -L` clean;
  screenshot in `test-results/`. N1 (added swift-build cost) re-measured if material.
- Thin ADR (gerbil deviations) + co-located target docs.

## Notes

gerbil-only (ADR-0011). Last target — on close, the grove's "propagate to all
targets, each VM-verified" done-bar is met and the grove is ready to **finish**.
Reuse the 030 known-good exemplars (D7). Measure-first; likely `leaf-decompose` into
build + rerun-verify when picked.

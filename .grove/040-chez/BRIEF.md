# 040-chez — brief

Inherit node. Decomposed (2026-06-19) per the leaf's Notes / D6. chez is the
**second** Swift-trampoline-for-methods target — a horizontal port of the
`030-racket` design (ADR-0030 + spec §method), not a rediscovery. The hard design
work (async callback form R4, the 955-error swift-residual close B1–B5) is already
done in racket; chez inherits it through the shared IR. The divergences are the same
ones ADR-0028 already recorded for free functions: Scheme-side marshalling (ADR-0015)
vs racket's native coercers, `foreign-procedure` vs `get-ffi-obj`, and the
lazy-instantiation forcing reference (ADR-0028 §3). Two leaves:

- **`010-build`** — port the method machinery into `emit-chez`: `MethodTrampoline`
  + `InitProducer` codegen mirroring racket's `trampoline.rs`, receiver unbox A/B
  (`AwChezValueBox` value / `Unmanaged` class), init producers (D2), mutating
  write-back (D3), object-ref params (R1), async-via-callback (D5/R4) over the chez
  async surface, charter-#4 routing fix in chez `emit_class.rs` (`objc_exposed`
  branch: suppress + count), and the full swift-residual close (re-attribution,
  owner-availability fold, `KNOWN_UNBINDABLE` keyed by chez entry name). Runtime
  `swift-trampoline.sls` method/init/async support + `OpaqueHandle.swift` `var`
  write-back. In-process/CLI smoke of both exemplars. Lands the thin ADR
  (the "0030-for-chez", mirroring how ADR-0028 mirrored ADR-0027) + co-located docs.
  Residual must reproduce racket's counts (§6c invariant).
- **`020-rerun-verify`** — full cold pipeline rerun (`collect`→`analyze`→`generate
  --target chez`→`swift build`), `cargo test --workspace` green, CLI smoke
  registered as the permanent regression guard, residual-count reproduction from
  cold collect, and VM-verify both exemplars (recovered async method + population-B
  init→method) live in a bundled `.app` (ADR-0009), screenshot in `test-results/`.

The original leaf's contract (Goal / Context / Done-when / Notes) is retained below;
the two leaves partition it.

## Goal

Port the receiver-handle method trampoline (pioneered in `030-racket`) to the **chez**
target, with its own thin structural ADR (the "0028-for-methods", mirroring how
ADR-0028 mirrored ADR-0027). Rerun + VM-verify.

## Context

Blocks on `020-method-recovery` (shared IR) and `030-racket` (the pioneered design +
ADR + spec). chez's free-function trampoline path: ADR-0028 (shared-source-call); chez
reaches the Swift trampoline dylib through its static-FFI seam, Scheme-side coercion
(ADR-0015). No new FFI seam is expected — the receiver is just more pointer/scalar
args over the existing trampoline-call path (D6).

## Done when

- chez method-trampoline codegen + emitter routing port the 030 design: receiver
  unbox, initializer producers, mutating write-back, async-via-`await`, charter-#4
  `objc_exposed` branch (suppress + count the deferred bucket).
- Residual method classification **reproduces identically to racket's** (same shared
  IR ⇒ same residual — the §6c invariant), counts reported.
- Full cold rerun (`collect`→`analyze`→`generate --target chez`→`swift build`) +
  `cargo test --workspace` green + chez CLI smoke registered as the permanent
  regression guard.
- **VM-verified:** the chez `swift-native-probe` (or equivalent) shows the §6a-style
  exemplars — incl. a recovered async method + a population-B init→method — live in a
  standalone `.app` (ADR-0009), screenshot in `test-results/`.
- Thin ADR (the chez deviations from the racket method ADR) + co-located target docs.

## Notes

chez-only (ADR-0011). Reuse the 030 known-good exemplars (D7). Measure-first; likely
`leaf-decompose` into build + rerun-verify when picked.

# 040-chez

**Kind:** work (inherit — decompose into build + rerun/verify when picked)

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

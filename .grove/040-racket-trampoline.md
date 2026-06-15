# 040-racket-trampoline

**Kind:** design+build (decompose if needed)

## Goal

The D1 vertical-slice core on the **racket** pioneer (D2): make the recovered
trampoline-residual actually bindable end-to-end. Extend `libAPIAnywareRacket` to
**vend C-ABI re-exports** (the trampolines) for the residual, and have the racket
emitter emit the thin ffi2 bindings that call them.

## Context

Depends on 030 (the IR boundary contract: which decls are `Trampoline` vs
`Direct`). Residual in D1 scope = top-level `s:` Swift functions/constants +
pointer-valued constants. `libAPIAnywareRacket` is the deepest native lib
(ADR-0013 generated typed native dispatch); the trampoline extends it.

## Done when

- `libAPIAnywareRacket` exposes a C-ABI entry per residual decl, implemented by
  calling the Swift-ABI API across the Swift boundary (Swift can call `s:` APIs).
- Racket emitter emits thin ffi2 bindings to those entries; pointer-valued
  constants emitted via their trampoline (not as literals).
- Builds green; a smoke binding for at least one real Swift-native function +
  one pointer constant resolves and runs.

## Notes

- Likely its own ADR for the racket trampoline *structure* (per D3, impl ADRs are
  separate from the model ADR-0025).
- Watch ADR-0011: this is racket-only; the per-target-vs-shared-source question is
  deferred to 060 (chez), revisited only if duplication bites.

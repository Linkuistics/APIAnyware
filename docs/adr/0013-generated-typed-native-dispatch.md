# Generated typed native dispatch (one entry per signature), not generic dispatch

**Status:** accepted

The `racket` target dispatches Objective-C methods through **native dispatch
entry points generated per distinct method signature from the API analysis**,
called from a thin Racket ffi2 binding — rather than through in-Racket
`objc_msgSend`/`tell`, a generic NSInvocation dispatcher, or a generic libffi
dispatcher.

This is the first concrete application of **ADR-0010** (the per-target native
library *is* the binding) to the hot path, under the grove directive to optimise
so the target language never has to consider the FFI boundary, paying with
generated native code rather than interpreted scripting code.

## Context

arm64 forbids calling `objc_msgSend` variadically: each call site must cast it to
a concrete `@convention(c)` function pointer matching the exact ABI shape. So any
*typed* native dispatch needs one compiled entry per distinct signature. Measured
over the golden subset: **160 distinct ABI shapes / 213 IR-level signatures**
across 814 call sites, long tail of ~90 single-use shapes; the full macOS surface
is larger and open-ended.

## Considered options (measured; ns/call, arm64, Racket v9.2 [cs], two runs avg)

| mechanism | scalar | id→id | struct ret | 2×float |
|---|--:|--:|--:|--:|
| in-Racket `tell` (all-object macro path) | ~90 | ~93 | n/a | ~110 |
| in-Racket typed `get-ffi-obj` msgSend (status quo, typed shapes) | ~10 | ~12 | ~90 | ~12 |
| native NSInvocation (generic) | ~680 | — | — | — |
| native libffi (generic, CIF cached) | ~19 | ~22 | ~26 | ~27 |
| **generated typed (per signature)** | **~5** | **~6** | **~11** | **~6** |

- **`tell` / typed `get-ffi-obj`:** keep dispatch + marshalling interpreted in
  Racket; 2–8× slower. The typed `get-ffi-obj` row is the honest status quo for
  the typed shapes a generated entry would replace.
- **NSInvocation:** ~7× slower than `tell`. Rejected.
- **libffi:** the obvious generic dispatcher (one function for all shapes) — the
  right answer *if signatures were unknown at build time*. They are not. Measured,
  it does **not** beat the typed status quo (it is *slower* on scalar/pointer/
  float, 19–27 vs 10–12 ns, beating it only on struct returns) and is ~3–4×
  slower than generating, because it interprets an `ffi_cif` every call. Kept only
  as the escape hatch for any signature the emitter cannot type statically.
- **Generated typed (chosen):** fastest — ~5–6 ns (~2× the typed status quo,
  ~15× `tell`) and **~8× faster on struct returns** (11 vs 90 ns, where Racket
  pays to marshal a CGRect). The "combinatorial table" objection dissolves
  because the table is **generated and regenerated from the IR, never
  hand-written**: the API analysis enumerates every signature, so we trade a
  generic dispatcher's unused runtime generality for compile-time ABI
  specialisation.

## Decision

Generate one typed native dispatch entry per distinct method signature; the
emitter emits a thin Racket ffi2 binding that calls it. The generated entries do
dispatch and, per the marshalling-depth spectrum (design spec §3), as much
argument/result marshalling and lifetime handling as the IR types warrant — so
the Racket wrapper trends toward a single coercion-free ffi2 call.

## Consequences

- **`emit_class.rs` stops open-coding `objc_msgSend`**; a new native dispatch
  generator consumes the signatures `shared_signatures.rs` already dedups.
- **`MessageSend.swift` (`aw_common_msg_*`) is deleted** — it was unused dead
  code and is superseded.
- **A libffi fallback path is retained** for any statically un-typable signature.
- **Per-call dispatch is not the GUI-app bottleneck**, so the primary win is
  architectural (thin scripting seam, ADR-0010); the 2–8× speedup is a guaranteed
  by-product. The choice is justified on the architecture + zero-maintenance
  grounds, with performance confirming rather than driving it.
- Evidence and repro: `docs/research/2026-05-31-racket-ffi2-spike/FINDINGS.md`;
  full rationale: `docs/specs/2026-05-31-racket-native-binding-design.md`.
- Applies the **ADR-0010** economics (generated bespoke native code per target)
  and is **target-local** under **ADR-0011** (lives in `APIAnywareRacket`).

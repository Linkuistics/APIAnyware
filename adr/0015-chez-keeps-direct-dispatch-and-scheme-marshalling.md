# Chez keeps direct `foreign-procedure` dispatch and Scheme-side marshalling

Adopting **ADR-0010** (the per-target native library *is* the binding), the
`racket` target relocated outbound ObjC dispatch and value marshalling into
generated native entry points (**ADR-0013**), because Racket's FFI crossing was
interpreted/macro-heavy and a native typed entry was measurably 2–8× faster. The
obvious expectation is that `chez` should mirror this. **It deliberately does
not.** A measurement spike (`targets/chez/docs/research/2026-06-02-chez-dispatch-spike/`,
`FINDINGS.md`) shows chez's fully-typed `foreign-procedure` already compiles to a
*direct* `objc_msgSend` call sitting **at the native dispatch floor** (~6 ns
simple shapes, ~10.5 ns struct return); a native shim is *equal* on simple shapes
and ~3× *slower* on struct returns, and native marshalling saves at most ~12% on
strings while *losing* on collections (chez crossings cost only ~6–17 ns, so
there is no headroom to reclaim by avoiding them). Relocating dispatch or
marshalling would therefore add a hop and **violate ADR-0010's own performance
goal**. Chez honours ADR-0010 by keeping the cheap compiled crossing: the emitter
continues to open-code one typed `foreign-procedure` per method signature, and
`types.sls` keeps its marshalling in idiomatic Scheme (ADR-0005). The native
library is reserved for concerns that genuinely cannot be expressed as a thin
call (blocks, delegates, dynamic classes, GC pinning, foreign-thread activation —
see ADR-0016).

## Consequences

- **The chez emitter does not change** for dispatch/marshalling — chez was
  already largely ADR-0010-compliant; the real work is the ADR-0011
  de-Common and the ADR-0016 threading deepening, not an emitter rewrite.
- **libffi-generic is a conceptual escape hatch only** (for any signature the
  emitter cannot type statically; variadics are already filtered). Measured ~3×
  slower than direct, so it is a fallback, never a path.
- **The divergence is the record's point.** A future reader comparing chez to
  racket (ADR-0013) must not "fix" chez by relocating its dispatch — the
  measurement says that is strictly worse for a compiled-FFI target. The same
  conclusion may apply to future compiled-FFI targets; the interpreted-FFI
  reasoning that drove ADR-0013 is target-specific.

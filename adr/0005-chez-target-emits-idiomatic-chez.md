# Chez target emits idiomatic Chez Scheme, not portable R6RS

The `chez` target's emitter and runtime produce **maximally idiomatic Chez
Scheme** — `(import (chezscheme))`, `foreign-procedure`, guardians, fluid
parameters, condition system, ftype-pointer, and any Chez-specific
extension that makes the generated source read like code a Chez programmer
would actually write. The target does **not** restrict itself to portable
R6RS (`(rnrs ...)` imports only) for the sake of running unchanged on
Larceny / Sagittarius / Vicare / Loko / etc.

## Consequences

- Cross-target symmetry between `racket` and `chez` is **on-disk and at the
  IR-decision level**, not at the source-form level: per-class files,
  `main` re-export per framework, `runtime/` + `generated/` layout, the
  same framework set, the same sample-app portfolio. The shape of the code
  inside each file is target-native.
- `bundle-chez` packages apps assuming a Chez runtime is present at
  bundling time and on the user's machine at run time; it does not attempt
  to wrap a portable Scheme launcher.
- A future port to another Scheme implementation is a **new target**, not
  a `--chez-portable` flag on this one. See ADR-0004 for the parallel
  principle on paradigms ("register two targets, do not reify a dimension").
- The chez design spec and the implementation plan that follow this ADR
  are free to assume Chez ≥ 10 features without portability caveats.

See `CONTEXT.md` (the `Target idiom` glossary entry) for the canonical
phrasing of the constraint.

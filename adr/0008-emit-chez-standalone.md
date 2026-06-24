# `emit-chez` is a standalone sibling crate, not a fork of `emit-racket`

`generation/crates/emit-chez/` is a brand-new crate sitting next to
`generation/crates/emit-racket/`. Both depend on the shared
`generation/crates/emit/` crate for language-agnostic concerns (IR types,
naming utilities, FFI-type mapping, framework-ordering, snapshot
testing, doc rendering). **No code is shared between the two emitters
except via `emit/`.**

## Considered options

- **Verbatim fork of `emit-racket`.** Rejected: every Racket-ism
  (`#lang racket/base` headers, `(require ...)` forms, `tell` macro
  calls, `_cprocedure` FFI types, the racket method-name conventions)
  would have to be edited in place against a target whose idiom diverges
  significantly — `library` forms, `foreign-procedure`,
  `define-record-type`, `let-values` for `(values result error)`. The
  resulting diff is so large it's not really a fork — it's a rewrite
  with vestigial Racket bones. Worse, every shared bugfix would have
  to be applied twice with target-specific adaptations.
- **Refactor-then-split: extract Racket-specific bits from `emit-racket`
  into a trait, then implement that trait for chez in a sibling crate.**
  Rejected for now: the racket emitter (6432 LOC across `emit_class.rs`,
  `emit_constants.rs`, `emit_enums.rs`, `emit_functions.rs`,
  `emit_framework.rs`, `emit_protocol.rs`) wasn't designed against an
  abstraction; finding the right cut points after-the-fact would require
  *understanding* both targets' idioms thoroughly first. We don't yet —
  chez emit doesn't exist. A future refactor pass, once both emitters
  are stable, can lift common patterns into `emit/`. Premature
  factoring now would shape `emit-chez` to fit emit-racket's contours
  rather than chez's idiom.
- **Standalone sibling (chosen).** `emit-chez` is written from scratch
  against the enriched IR, free to reach for Chez idioms where they
  diverge (multiple-value returns for `NSError`, `library` forms for
  per-class files, `foreign-procedure` instead of `_cprocedure`). The
  cost is some structural duplication of orchestration (the
  `emit_framework`-shaped top-level driver), but the orchestration is
  small relative to the per-element generators.

## Consequences

- Doubles the maintenance surface for cross-cutting emitter changes
  (e.g. an IR addition that needs surfacing in both targets). Mitigation:
  shared concerns belong in `emit/`, and the per-target crates are kept
  small enough that "find both call sites" is a tractable search.
- The chez emitter is free to evolve its own structure; a later refactor
  pass to lift common patterns into `emit/` becomes a *real* refactor
  (informed by two working emitters) rather than a speculative one.
- Sets the precedent for future targets (a hypothetical `gerbil`, the
  Swift-side stubs in `swift/Sources/APIAnywareGerbil/` already hint at):
  each language gets its own `emit-<target>` crate. The "register two
  targets" escape hatch from ADR-0004 extends to "every target is its
  own emitter crate", consistent with the per-target topology already
  visible at the `swift/` and `bundle-*/` layers.

# Chez surfaces `NSError**` as `(values result error)`

Every chez-emitted procedure whose ObjC signature takes a trailing
`NSError**` out-parameter returns **two Scheme values**: the primary result
and an error value (`#f` on success, an `nserror` Scheme record on failure).
Callers use `let-values` / `call-with-values` to consume both. The procedure
does not raise; the error path is in-band.

## Considered options

- **Raise on non-nil `NSError`.** Rejected: turns recoverable per-call
  failures into stack-unwinding events; Cocoa idiom is that `NSError` is
  routine and most callers branch on it locally. Also poisons the
  `with-autorelease-pool` boundary because a raise from inside the pool
  body still needs `dynamic-wind` to drain — adds an
  always-on cost for the non-exceptional path.
- **Return a mutable box / pair.** Rejected: works, but the caller has to
  construct the box up front and then destructure; multiple-value return is
  the natural Chez idiom for "result plus side channel" and reads better at
  the call site (`(let-values ([(data err) (nsdata-... )]) ...)`).
- **Multiple-value return (chosen).** Most idiomatic Chez, zero allocation
  for the success path beyond the result itself, signature is self-documenting
  (the procedure's arity tells you it's fallible).

## Consequences

- Hard to reverse: every fallible procedure in every emitted framework
  carries this shape. Changing later means a rewrite across all generated
  bindings and every sample app that uses them.
- `emit-chez` must detect `NSError**` parameters in the IR (the same
  marker `emit-racket` could use, if it chose to — but racket today
  surfaces these through `tell` returns and lets the caller pull the
  error out of the wrapper, so this is the first time the IR's
  `NSError**` marker drives an actual signature change).
- The error record shape (`nserror` with fields `domain`, `code`,
  `localised-description`, `userinfo`) is implementation detail of the
  runtime `objc` cluster — not part of this ADR; settled in the design
  spec.
- Procedures that previously returned `id` now return `(values id
  nserror)`; this is observable to sample-app authors and must be called
  out in `knowledge/targets/chez.md`.

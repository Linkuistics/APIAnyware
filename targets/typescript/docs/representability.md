# typescript (Node) — representability (§18 / §7.7)

How faithfully a given macOS API can be expressed in the typescript binding, and how that
is measured for a target with no authored `capability.apiw`/`conformance/` (see
`overview.md`'s facet table — `apianyware-conformance`'s `LIVE_TARGETS` list does not yet
include `typescript`). Where the four Lisp targets get a derived §7.7 histogram from
`apianyware-conformance`, this target's representability is measured directly against the
real TypeScript compiler over the real corpus.

## The same ladder, applied narratively

REFACTOR §20's capability *levels* and §7.7's per-API *statuses* are one 7-rung ladder
(best → worst): `exact-static` (fully represented, no special handling), `exact-runtime`
(exact via a runtime mechanism), `idiomatic-conventional` (upheld by convention),
`lossy-but-documented`, `unsafe-only`, `not-representable`, `research`. This target has no
authored `capability.apiw` rung per dimension, so no automated floor derivation exists —
the sections below are the qualitative equivalent, grounded in what the emitter and the
type-surface gate actually measure.

## Where typescript lands, by construct

- **The directly-reachable ObjC surface is `exact-static`.** The trampoline-elided
  projection posture (`ffi-model.md`) reaches it with no special handling and a checked
  `.d.ts` type — the same trampoline-elision-limit reasoning racket's `representability.md`
  gives, now backed by a compile-time type check rather than only a runtime contract.
- **The Swift-native residual is `exact-runtime`.** Free functions, methods returning
  Swift-native values, and `throws` route through the by-name trampoline table or the
  `Result<T>` error channel (ADR-0061, ADR-0058) — exact, but through a generated
  mechanism rather than direct `objc_msgSend`.
- **A handful of shapes are `lossy-but-documented` or counted-deferred**, each with its own
  owner rather than silently dropped:
  - the blocks **call-site** feature (only a narrow two-selector completion-handler carve-out
    shipped; `block-call-site-emission-k120`),
  - non-curated by-value struct types outside the closed nine-member POD family
    (`CLLocationCoordinate2D` and similar),
  - one vacuous-but-ObjC-legal protocol conformance (`CALayoutManager`),
  - a protocol qualifier on a non-`Id` base (`NSFoo<P> *`, `Class<P>`) — the base class
    recovers, the qualifier does not,
  - the array-typed-global constant case (`extern const unsigned char X[]`) — reads safely
    but not yet honestly (`array-constant-symbol-value-k109`).
- **Generic free functions (21) and Swift operator declarations (13) are genuinely
  unbindable** — no TS identifier exists for an operator, and a sanitised entry name would
  collide (ADR-0061 §3). Recorded, not built.

## The measurement mechanism: the corpus-typecheck gate, not a derived histogram

Instead of `apianyware-conformance --target typescript` (unavailable — see above), this
target's standing representability guard is the **corpus-typecheck gate**: emit Foundation +
AppKit plus their transitive import closure fresh from the committed IR, and run the
runtime package's `tsc --noEmit --strict` over the result.

```sh
RUNTIME_LOAD_TEST=1 cargo test -p apianyware-emit-typescript --test runtime_load_test -- --nocapture
```

As of the last full-portfolio measurement (`sample-apps-k112`, 2026-07-16), the residual
settled at a single stable bucket — **33 TS2559** (the blocks/non-curated-struct/vacuous-
conformance frontier above) and **zero** TS2416/TS2420/TS2305 — across the whole seven-app
sample portfolio's construction. Re-run the gate for the current number; this page cites the
mechanism, not a frozen count (constraint 4).

## See also

- [`../bindings/node/docs/api-coverage.md`](../bindings/node/docs/api-coverage.md) — how to
  read this for "is API X covered".
- [`ffi-model.md`](ffi-model.md) — the projection posture the `exact-static` claim rests on.
- [`reference.md`](reference.md) — the gate's own history and every residual's owner.

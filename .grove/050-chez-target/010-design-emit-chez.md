# 010-design-emit-chez

**Kind:** planning

## Goal
Crystallise the chez design from the inherited decisions (this node's
`BRIEF.md`) into:
1. A design spec at `docs/specs/YYYY-MM-DD-chez-target-design.md` that
   covers the runtime, the emitter signature, the framework-emission
   order, and the Swift-dylib surface.
2. The three ADRs the parent brief defers to this leaf: NSError shape,
   lifetime model, emitter topology.
3. A grown subtree of work leaves under `050-chez-target/` that the
   subsequent sessions execute one by one.

## Context

### Read first (in this order)
- The node `BRIEF.md` (the inherited decisions are non-negotiable; do not
  re-grill them).
- ADR-0004 (paradigm retired) and ADR-0005 (idiom posture). The spec
  cites both.
- `generation/crates/emit/src/binding_style.rs` — the trait surface the
  emitter must implement.
- `generation/crates/emit-racket/src/lib.rs` + `emit_framework.rs` —
  reference orchestration shape only.
- `generation/targets/racket/runtime/` — every file's chez counterpart
  has to be designed. List the runtime files that need a chez analog and
  flag the ones that don't translate (e.g. anything that depends on
  Racket's class system specifically).

### Open design questions the grilling must close

- **Framework set and emission order.** Confirm: chez emits the same
  framework set as racket, in the same topological order
  (`topological_sort` in `emit/src/framework_ordering.rs`). Any framework
  to defer for chez specifically?
- **Runtime decomposition.** Which racket runtime files map 1:1 to chez,
  which need rewriting from scratch (class system / dynamic-class),
  which are obsolete for chez (e.g. anything Racket-specific that has no
  ObjC analog).
- **Swift dylib factoring.** Single sibling crate that builds
  `libAPIAnywareChez.dylib`, or shared with racket's Swift build via a
  cargo / Swift package layout change? The dylib is target-specific
  per the parent brief, but the Swift project that produces it may or
  may not be.
- **Sample-app port plan.** Order to port the 7 apps (likely: hello-window
  first, then the rest by complexity). Per-app effort estimate based on
  what the app exercises (blocks? delegates? subclassing?).
- **Bundle-chez crate surface.** Mirror `bundle-racket` exactly, or
  diverge (e.g. chez compiles to native binaries via `compile-program`;
  the bundle layout may differ from racket's source-launched layout).

### ADRs to write in this leaf

Per `grilling.md` "ADRs sparingly". Three are pre-approved by the parent
brief; do not invent more unless the grilling surfaces a fourth that
clears all three of (hard to reverse, surprising, real trade-off).

1. **ADR-0006: chez surfaces NSError\*\* as `(values result error)`.**
   Cite the considered options (raise on non-nil, return mutable box).
2. **ADR-0007: chez objc-object lifetime = guardian + outer
   autoreleasepool wrap.** Explain why the combination beats either
   mechanism alone. Cite the entry-point convention (every event handler,
   every callback, every `main` runs inside an `@autoreleasepool`).
3. **ADR-0008: emit-chez is a standalone sibling of emit-racket, not a
   fork.** Cite the considered options (verbatim fork, refactor-then-split).

### Optional: PRD
If the design spec hits a clear human-shareable agreement point — e.g.
"here is the chez runtime architecture diagram and we both agree this is
what we're building" — write it at `docs/prd/<date>-chez-target.md`. Not
required; the design spec alone is fine if the user is ready to proceed
straight into work leaves.

## Done when

- `docs/specs/YYYY-MM-DD-chez-target-design.md` exists and covers:
  runtime decomposition (per-file mapping from racket runtime to chez
  runtime, plus any chez-only files), emitter file layout (mirroring
  `emit-racket/src/`), framework emission contract (per ADR-0005's
  idiom-not-portable guarantee), Swift dylib surface, sample-app port
  order with per-app notes.
- ADRs 0006, 0007, 0008 exist.
- `CONTEXT.md` has any new terms appended inline (e.g. `objc-object`,
  `entry-point autoreleasepool`, anything else that surfaces).
- Work leaves under `050-chez-target/` are seeded with `020-`, `030-`,
  `040-`, … prefixes — at minimum:
  - `020-…` chez runtime scaffold (a runtime that loads cleanly in
    `chez --script` with no FFI calls yet — gets the module layout
    right).
  - `030-…` emit-chez crate scaffold + foundation framework emission
    end-to-end.
  - `040-…` swift-dylib build (or its own sub-node if the planning
    surfaces enough scope).
  - `050-…+` further framework emission + sample-app ports, decomposed
    per the spec's port order.
- A PRD MAY be written; not required.

## Notes
- The 2026-05-23 chez decomposition is **not on main**. The parent
  brief lists the surviving design intent. Treat any disagreement
  between that intent and the inherited decisions in the parent brief
  as the parent brief winning — it post-dates the 2026-05-23 work and
  reflects the 030 grilling.
- Numbering inside this node: `010-` is this leaf; subsequent leaves
  pick the next prefix in tens. Do not gap-fill into `015-` etc.
- Watch for the `Target vs. Language` ambiguity in CONTEXT.md. If the
  spec or an ADR ends up needing to disambiguate, prefer **target** as
  the canonical term per CONTEXT.md; do not rename the Rust trait /
  CLI flag in this grove (root BRIEF rule).

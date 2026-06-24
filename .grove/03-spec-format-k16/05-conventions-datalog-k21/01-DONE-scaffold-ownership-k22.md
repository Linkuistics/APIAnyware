# scaffold-ownership-k22

**Kind:** work

## Goal

Stand up the convention-rules **substrate** and port the **first facet** (parameter ownership) as
the proof-of-pattern for retiring `heuristics.rs` (see node brief `conventions-datalog-k21`).

Deliver a new crate **`platforms/macos/tools/conventions`** containing:
- an `ascent!` **`ConventionProgram`** (mirrors the `resolve`/`enrich` ascent-program shape),
- a **fact loader** (`Framework` → convention base facts: selectors, params w/ block-typed +
  name, properties w/ copy+block flags, swift attributes, class/protocol names),
- a **readback** turning derived facts → per-`(receiver, selector)` `MethodAnnotation`, **ownership
  facet only**, each `ParamOwnership` stamped with the rule that derived it,
- the **parameter-ownership rules**: weak `delegate`/`dataSource` params (name + selector-segment +
  `setDelegate:`/`setDataSource:`); weak `add…Observer:` observer param; block-typed param → copy.

## Context

Design source (do NOT re-grill): **ADR-0047**, PRD, node brief. The legacy behavior to reproduce
is `heuristics.rs::derive_parameter_ownership` + `is_delegate_param` + `is_observer_param`
(`platforms/macos/tools/annotate/src/heuristics.rs`) — port *exactly*, no new rules (goldens-as-truth).

**Pipeline stays UNCHANGED this leaf** — `annotate` still calls `heuristics.rs`. Nothing this leaf
produces reaches disk, so the full pipeline + emit goldens are trivially green. The flip happens in
the node's last child once all four facets are ported.

Provenance carriage: introduce the **minimal** representation needed to stamp an ownership fact with
`source="convention:<rule>"` (decide method-level vs per-`ParamOwnership` in-session; prefer the
smallest change that lets the readback + characterization test assert the *stamp shape*). Full
per-fact rollout is the flip child's job — do not ripple into the `.apiw` schema/writer or machine
serde here unless trivially forced.

Crate home rationale + ascent precedent: node brief "Deferred decisions". Add the crate to the
workspace `members` + `README §11` map per the crate-home convention (root `BRIEF.md` Skeleton
outcomes).

## Done when

- `platforms/macos/tools/conventions` builds; `ConventionProgram` + loader + ownership readback exist.
- A **characterization test** asserts the new ownership facet **equals** `heuristics.rs`'s
  `parameter_ownership` output — over synthetic fixtures covering every legacy ownership test case
  (delegate, dataSource, KVO/notification/shared observer, block→copy, the negative cases), and over
  real committed IR **if present** (skip-as-pass when the gitignored IR is absent, per the
  `enriched-IR-gitignored` convention).
- Derived ownership facts carry the `convention:<rule>` stamp; a test pins the stamp shape.
- `cargo build` + `cargo test` green for the new crate and the workspace; `cargo fmt --all`.

## Notes

The half-wired transition is deliberately avoided: ownership rules are validated *against*
heuristics.rs, not swapped *into* the pipeline. Subsequent facet leaves extend the same
`ConventionProgram` + characterization harness; the flip child consumes it.

# flip-retire-k26

**Kind:** work

## Goal

The **final child** of `conventions-datalog-k21`: flip the analysis pipeline off the imperative
`heuristics.rs` and onto the `ConventionProgram`, retire `heuristics.rs`, and finalize the
per-fact `convention:<rule>` provenance. All four facets are now ported and
characterization-equivalent (ownership-k22, block-invocation-k23, threading-k24, error-pattern-k25),
so this is the atomic cutover the build-then-flip strategy was building toward. Retiring this leaf
retires the node — its **Done when** *is* the node's done-bar (ADR-0046 §4 / ADR-0047).

## Settled design (do NOT re-grill)

- **ADR-0047** — convention heuristics as `ascent` rules; derived facts stamped
  `source="convention:<rule>"`; runtime-loadable rules deferred.
- **ADR-0046 §4** — per-fact provenance/precedence; on disagreement, winner stamped + losers retained
  as `superseded-by`.
- Node brief `conventions-datalog-k21` (planned child 5) + the k25 leaf's Notes.

## The flip — concrete mechanics

`annotate` currently classifies **per method**: `annotate_framework` (`annotate/src/lib.rs:90`) loops
methods and calls `heuristics::annotate_method_heuristic` (`:178`) /
`annotate_protocol_method_heuristic` (`:190`). The cutover replaces those per-method calls with a
**batch** derivation:

1. Add `apianyware-conventions` to `annotate/Cargo.toml` `[dependencies]` (reverses today's
   **dev-only** edge — see the **dependency-cycle** note below).
2. Per framework-set, run the four public facet APIs once each — `derive_ownership`,
   `derive_block_invocations`, `derive_threading`, `derive_error_pattern` — each returning
   `BTreeMap<MethodKey, …Facet>` keyed by `(receiver, selector)` (`MethodKey`).
3. Assemble each method's `MethodAnnotation` by looking its `(receiver, selector)` up in the four
   maps (absent ⇒ the facet's empty/`None` default, exactly the legacy per-method result). The
   existing LLM-merge logic in `lib.rs` is **untouched** — only the heuristic *source* changes.
4. Delete `heuristics.rs` (it is pure classifiers — the merge glue lives in `lib.rs`, so nothing
   "non-rule" remains to keep). Drop `pub mod heuristics;` from `lib.rs`.

**Dependency-cycle note (landmine).** `conventions` dev-depends on `apianyware-annotate` so the four
`*_equivalence.rs` characterization tests can compare against `heuristics.rs`. Once `heuristics.rs`
is deleted those tests **cannot compile** (their baseline is gone) — they were always **scaffolding**
to gate the port. Delete all four `tests/{ownership,block,threading,error_pattern}_equivalence.rs`
**and** the `[dev-dependencies] apianyware-annotate` edge in the same flip commit. After the flip the
**emit goldens** are the standing regression guard (goldens-as-truth); the per-facet unit tests in
`program.rs` stay (they need no `annotate` baseline).

## Decision to settle this leaf (may escalate)

**Provenance granularity** (deferred since k22). `MethodAnnotation.source` is today a *single*
method-level `AnnotationSource` enum, but a method now aggregates facts from up to four rules, each
wanting its own `convention:<rule>` stamp. The facet readbacks already carry per-fact/per-index
`provenance: convention:<rule>` — finalize how that lands on-disk. Per-fact carriage touches
`ParamOwnership` / `BlockParamAnnotation` + the `.apiw` schema/writer + machine `serde` + emit
consumers. **If it grows cross-workstream** (ws5's LLM side-channel consumes provenance), **escalate
before cutting over** rather than absorbing a ws5-shaped change here. A minimal in-`MethodAnnotation`
carriage that keeps emit goldens stable is acceptable if the richer rollout is genuinely ws5's.

## Done when (retires the node)

- `annotate` is wired to the `ConventionProgram`; `heuristics.rs` is removed; the four
  `*_equivalence.rs` tests + the dev-dep edge are gone.
- **Emit goldens prove equivalence**: full pipeline regenerated (regenerate aggressively — don't
  trust stale checkpoints), 71 suites + emit goldens green end-to-end, **no** classification
  regression vs the pre-flip output.
- Each derived fact carries `source="convention:<rule>"`; the disagreement/precedence audit
  (ADR-0046 §4) attributes per rule.
- `cargo build`/`test`/`clippy` green; `cargo fmt --all` + a standalone `style:` commit if it drifts.

## Notes

This is the last planned child of `conventions-datalog-k21`. On retirement the node likely has no
live leaf → the retire-cascade asks before treating **workstream 2** (`spec-format-k16`) done; promote
anything durable from the node brief (the ascent-convention pattern, the `convention:<rule>` stamp,
the goldens-as-truth gate) up to the ws2 brief / ADRs / `CONTEXT.md` before that. Runtime-loadable
rules remain a deferred enhancement (ADR-0047).

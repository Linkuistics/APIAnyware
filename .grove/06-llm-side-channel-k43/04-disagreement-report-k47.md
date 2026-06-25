# disagreement-report-k47

**Kind:** work

## Goal

Build the **`apianyware-analyze annotations audit`** subcommand (node BRIEF decomposition #4).
Read each family's resolved-only **`fact_provenance`** carriage (the disagreement audit
`precedence-audit-k45` landed) and report, per family: the **disagreements** (fact-slots whose
winner has a non-empty `superseded_by`) and **agreement / redundancy counts** (how often a tier
agreed with — was redundant against — the winner). Replaces `audit-llm-redundancy.py` (the old
`.llm.json`-vs-heuristic redundancy categoriser, dead since the k20 cutover).

## Context (see node `BRIEF.md` + ADR-0050 §3 + `CONTEXT.md` "Disagreement audit / `superseded-by`")

- **Input is the realized carriage, not re-derivation.** `precedence-audit-k45` already runs the
  resolve-time §28 audit and writes per-fact provenance into `resolved.json`:
  `MethodAnnotation.fact_provenance: Option<MethodFactProvenance>`, with one `SlotProvenance
  { param_index?, source, rules, superseded_by: Vec<SupersededFact{source,value}> }` per producing
  slot (ownership/block keyed by `param_index`; threading/error method-level). `audit` is a
  **read-only report** over that carriage — no resolve pass needed beyond loading `resolved.json`.
- **Subcommand group already exists.** `staleness-regen-k46` built the clap `Subcommand` scaffold:
  `annotations` is an `AnnotationsCommand` group (`semantic/tools/analyze-cli/src/annotations.rs`)
  with a `Stale` variant. **k47 only adds an `Audit(AuditArgs)` variant + arm** — mirror the
  `stale` module's shape (`annotations/stale.rs`): a pure compute over in-memory types + an IO
  `run` + human/`--json` output, unit-testable in isolation.
- **Redundancy = agreement.** A loser that *agrees* with the winner is **not** in `superseded_by`
  (only disagreements are; ADR-0050 §3). "Redundancy" for the report is therefore the count of
  slots where a lower tier produced the *same* value as the winner — i.e. the winner could have
  come from convention alone. That signal needs the per-tier producing values, which the audit
  records only for *disagreeing* losers. Decide during this child: either (a) report redundancy
  as "convention-sourced winners with an LLM overlay that agreed" — derivable if k45 retained
  agreeing-tier info — or (b) re-run the per-slot tier comparison in `audit` from convention facets
  + overlay. **Pin the exact redundancy definition during this child** (mirrors how k46 pinned the
  annotatable-shape predicate); lean on what `fact_provenance` already carries before re-deriving.
- **Loading.** `apianyware_datalog::loading::load_all_family_artifacts(api_root, "resolved.json",
  only)` (same as `stale`); overlay via `crate::load_overlay` if the redundancy definition needs it.

## Done when

- `apianyware-analyze annotations audit [--only <F,…>] [--json]` reads each family's
  `resolved.json` and reports per family the disagreement slots (winner `source` + each
  `superseded_by {source,value}`) and the agreement/redundancy counts, with a summary line.
  Structured, LLM-friendly output ([[cli-tool-design]]): stable keys, actionable. Decide the exit
  policy (report-only exit 0, vs gate) — `audit` is **informational**, so default to exit 0 unless
  a clear gate is wanted.
- Typed Rust (same serde types, no path-drift); a focused `audit`-logic module testable in
  isolation. Lands as an `Audit` variant in the existing `annotations` group.
- **Golden-neutral / no pipeline change:** `audit` is read-only — writes no `resolved.json`,
  touches no emit path. `resolve` still byte-identical; emit goldens green.
- `cargo build --workspace` clean; touched-crate tests green; clippy clean.
- Committed in one focused commit named by the `disagreement-report-k47` handle.

## Notes

- **Don't retire the old script here.** `audit-llm-redundancy.py` + the Makefile `lint-annotations`
  rework are the **`retire-tooling`** child's job (ws5 #6, last) — build the replacement now.
- The `stale` sibling (k46) reads the resolved surface vs the overlay; `audit` reads the
  resolved-only `fact_provenance` — orthogonal inputs, shared subcommand group.
- On retire, grow the next frontier child `orchestration-skill` (node BRIEF sequence #5).

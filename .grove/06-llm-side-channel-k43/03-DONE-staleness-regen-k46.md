# staleness-regen-k46

**Kind:** work

## Goal

Build the **`apianyware-analyze annotations stale`** subcommand (ADR-0050 §4 / D5; node
BRIEF decomposition #3). Compute staleness **live** — set-diff each family's *committed*
`annotations.apiw` overlay against the current `extracted.json` — and emit a **regeneration
worklist** classifying stale `(class, selector)` slots by the three signals. **No stored
content hash** (artifacts-not-state). Replaces `check-llm-annotation-drift.sh` (the old
`_llm-annotations/*.llm.json` + `analysis/ir/` drift check, dead since the k20 cutover).

## Context (see node `BRIEF.md` D5 + ADR-0050 §4 + `CONTEXT.md` "Staleness / regeneration")

- **Three signals** (`CONTEXT.md`): *orphaned* (an overlay fact names a `(class, selector)`
  **absent** from the current API surface), *new-surface* (a current method with an
  **annotatable shape** and **no** overlay fact), *shape-changed* (a method present in both
  whose **parameter shape moved** — e.g. a `param_index` an overlay fact targets no longer
  has the annotated type). "Annotatable shape" = a method the convention/LLM tiers would
  meaningfully annotate (block param, NSError** out-param, ownership-relevant object param,
  threading-relevant); lean on the existing convention facets / signature inspection to
  decide rather than re-deriving — pin the exact predicate during this child.
- **CLI is flat today.** `apianyware-analyze` has no subcommands — `main.rs::run_pipeline` is
  the bare resolve flow (`--only`, `--api-root`, `--pattern-kinds-dir`). This child introduces
  the **clap `Subcommand` scaffold**: the existing resolve flow becomes the default/`resolve`
  subcommand, and `annotations stale` is added alongside. The sibling `annotations audit`
  (ws5 `disagreement-report-k47`) slots into the same `annotations` group — build the group so
  k47 only adds a variant.
- **Inputs already exist.** Overlay parse: `apianyware_spec_format::apiw::parse_apiw`
  (→ `FrameworkAnnotations`). Extracted load:
  `apianyware_datalog::loading::load_all_family_artifacts(api_root, "extracted.json", only)`.
  Both keyed by `(receiver, selector)`. The diff is pure set logic over those two — no resolve
  pass needed (staleness is overlay-vs-extracted, not a resolved-graph concern).
- **Scope boundary — worklist, not dispatch.** This child *produces* the stale-family /
  stale-slot worklist (the thing a human or the orchestration step acts on). The
  **regeneration dispatch** (Claude-Code subagents per stale family, each writing `.apiw`
  directly — economic constraint [[llm_annotation_constraint]]) is the **`orchestration-skill`**
  child's (ws5 #5). Don't dispatch subagents here; emit a worklist the next child consumes.

## Done when

- `apianyware-analyze annotations stale [--only <F,…>]` reads each family's committed
  `annotations.apiw` + current `extracted.json` and reports per family the *orphaned* /
  *new-surface* / *shape-changed* slots, plus a machine-consumable **worklist** (the families
  needing regeneration). Structured, LLM-friendly output ([[cli-tool-design]] skill): stable
  keys, a summary line, actionable; exit non-zero iff any family is stale (so it gates).
- Typed Rust (same serde types, no path-drift) — the crate-home is `apianyware-analyze`
  subcommands (ADR-0050 §6 / D7); a focused `stale`-logic module is testable in isolation.
- **Golden-neutral / no pipeline change:** `stale` is a read-only analysis — it writes **no**
  `resolved.json` and touches no emit path → emit goldens unmoved by construction. `resolve`
  must keep behaving exactly as today after the subcommand restructure (regenerate Foundation
  end-to-end; emit goldens green).
- `cargo build --workspace` clean; touched-crate tests green; clippy clean.
- Committed in one focused commit named by the `staleness-regen-k46` handle.

## Notes

- **Don't retire the old script here.** `check-llm-annotation-drift.sh` + `audit-llm-redundancy.py`
  + the Makefile `lint-annotations` rework are the **`retire-tooling`** child's job (ws5 #6,
  last) — build the replacement now, retire the scaffolding then.
- **Set-diff is cheap, stores nothing** (`CONTEXT.md` _Avoid_): no content-hash cache, no
  `.stale` marker file. Recompute every invocation.
- The `annotations audit` sibling (k47) reads the `superseded-by` carriage k45 just landed;
  `stale` reads `extracted.json` vs the overlay — orthogonal inputs, shared subcommand group.
- On retire, grow the next frontier child `disagreement-report` (the node BRIEF sequence #4).

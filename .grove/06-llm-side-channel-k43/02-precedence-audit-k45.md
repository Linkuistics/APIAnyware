# precedence-audit-k45

**Kind:** work

## Goal

Build the **resolve-time disagreement / precedence audit** — the heart of ws5 (ADR-0046 §4 /
ADR-0050 §3). At resolve time, per `(receiver, selector)` **fact-slot**, gather every producing
tier, apply §28 precedence, **stamp the winner's `source`** on the resolved fact, record each
*disagreeing* loser as `superseded-by { source; value }`, and leave a no-producer slot **explicit
`unknown`**. This lands per-fact `source` (+ optional `superseded-by`) in `resolved.json`.

## Context (see node `BRIEF.md` D-log + ADR-0050 §3 + `CONTEXT.md` "Disagreement audit")

- **Foundation laid by `provenance-vocab-k44`:** `AnnotationSource = {Convention, Llm, Manual}`
  (serde `convention`/`llm`/`manual`). This child *adds* the variants/payload it produces:
  the `Convention` `<rule>` payload (the per-fact `convention:<rule>` stamp the
  `apianyware-conventions` facets already compute but k26 kept off-disk), plus `Extraction` and
  `Unknown`.
- **Where the merge lives today:** `platforms/macos/tools/annotate` already merges the convention
  tier (datalog facets, keyed `(receiver, selector)`) with the authored overlay
  (`annotations.apiw`: `llm`/`manual`) — see `annotate_framework` / `validate.rs::merge_annotations`
  (currently "LLM precedence; fill gaps from heuristic", method-level `source` only). This child
  reworks that merge into the per-fact precedence audit. The legacy `AnnotationDisagreement`
  record (`heuristic_value`/`llm_value` in `semantic/tools/types/src/annotation.rs`) is the natural
  thing to evolve into the `superseded-by` record.
- **The four convention facets** (`apianyware-conventions::readback`) already carry per-fact
  `convention:<rule>` provenance stamps in-memory (`OwnershipFacet.provenance`, etc.) — this child
  is their first on-disk consumer.
- **Precedence (§28):** `manual > accepted-LLM > convention > extraction > unknown`. `accepted-LLM`
  ≡ a committed `source llm` fact (D2 — git is the accept boundary; no staging state).

## Done when

- `resolved.json` facts (per `ParamOwnership` / `BlockParamAnnotation` / threading / error
  fact-slot) carry a per-fact `source`; disagreeing losers are recorded `superseded-by`; a
  no-producer slot is explicit `unknown` (never silently defaulted).
- The **winning value is unchanged** from today's merge (llm-over-convention) → emit stays
  provenance-blind → **all four targets' emit goldens byte-identical** (the gate). A moved golden
  is a bug, not an intended change.
- `cargo build --workspace` clean; touched-crate tests green; Foundation (+ a 2nd framework if
  `extracted.json` present) resolves end-to-end; emit golden suites unmoved.
- Committed in one focused commit named by the `precedence-audit-k45` handle.

## Notes

- **Golden-neutrality is the contract.** Stamp provenance; do **not** change which value wins.
  If a precedence decision would change a winning value vs. today's merge, that is a finding to
  surface, not silently absorb.
- **ws8 boundary:** extend the Rust `resolved.json` serde here; the *machine JSON Schema* for the
  full ladder + `superseded-by` stays ws8's.
- Doubt-pass candidate (driving.md): the precedence ordering + the "only disagreements become
  superseded-by" rule assert correctness properties — consider a fresh-context adversarial review
  before the commit stands.
- On retire, grow the next frontier child `staleness-regen` (the node BRIEF sequence).

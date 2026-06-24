# pipeline-cutover-k20

**Kind:** work

## Goal

Cut the live pipeline over from JSON to the **KDL spec triad at the new per-family paths**
(`platforms/macos/api/<Framework>/`), collapsing the four checkpoints to three, renaming the
colliding stage, and folding the LLM annotations into the authored overlay — keeping the pipeline
buildable + **goldens green** throughout (PRD "Migration"; ADR-0046).

## Context

Design source (do not re-grill): **PRD `prd/2026-06-24-spec-format-data-model.md`**, **ADR-0046**.
Uses the `spec-format` crate (k18) + schema (k19); honours the spike (k17) go/no-go (if no-go,
`extracted`/`resolved` stay JSON per the retreat — adjust this leaf accordingly). **ws2 owns this
relocation** (the brief's ws4 TODO is reassigned — format+location are one op over gitignored
artifacts; ws4 inherits the populated tree). Current paths: collect→`collection/ir/collected`,
resolve(datalog)→`analysis/ir/resolved`, annotate→`analysis/ir/annotated`, enrich→`analysis/ir/
enriched`, generate reads `enriched`.

## Done when

- Pipeline reads/writes the **triad** at `platforms/macos/api/<Framework>/` (`extracted.kdl`,
  `annotations.apiw`, `resolved.kdl`); generators consume `resolved.kdl`.
- Four checkpoints collapsed to three on-disk files; the datalog cross-ref stage **renamed
  `resolved`→`linked`** (glossary already updated) so `resolved` means only `resolved.kdl`.
- `_llm-annotations/*.llm.json` converted to `annotations.apiw` (via the k18 converter) and the
  old JSON side-channel retired; resolve applies §28 precedence + stamps provenance/`superseded-by`.
- Full pipeline regenerates green; **all goldens + the 71 test suites pass** (regenerate
  aggressively — do not trust stale checkpoints); old `collection/ir/` + `analysis/ir/` paths gone.
- `cargo fmt --all` + a standalone `style:` commit if rustfmt drifts.

## Notes

The risky leaf — sequence carefully so each commit is buildable (D4). Heuristics may still be
imperative here (datalog conversion is k21); this leaf only moves format/shape/location +
overlay. Discharges the `TODO (workstream 2)` markers in the relevant placeholder READMEs.

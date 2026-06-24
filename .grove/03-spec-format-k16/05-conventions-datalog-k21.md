# conventions-datalog-k21

**Kind:** work

## Goal

Retire the imperative **`platforms/macos/tools/annotate/src/heuristics.rs`** (1,236 lines, 59
classifiers) and re-express the convention heuristics as declarative **`ascent` datalog rules**
over `extracted.kdl`, in the datalog layer (ADR-0047; PRD "Producers → files").

## Context

Design source (do not re-grill): **ADR-0047**, PRD `prd/2026-06-24-spec-format-data-model.md`.
Same engine as the existing resolution/ownership ascent programs (`semantic/tools/datalog`,
`resolve`, `enrich`). Rules are **compile-time** (recompile to change), legible, and their derived
facts land in `resolved.kdl` stamped `source="convention:<rule>"` — datalog's derivation trace
supplies the provenance. Sequence after the cutover (k20) so rules run against the KDL fact base.

## Done when

- The convention tier is `ascent` rules; `heuristics.rs` is removed (or reduced to non-rule glue).
- **Goldens prove equivalence**: the rule set reproduces the current classifications before any
  new rules are added (goldens-as-truth — no regression in the annotated/resolved output).
- Each derived fact carries `source="convention:<rule>"` provenance in `resolved.kdl`; the
  disagreement/precedence audit (ADR-0046 §4) attributes per rule.
- Full pipeline regenerates green; 71 suites + goldens pass; `cargo fmt --all` + `style:` if needed.

## Notes

The biggest single conversion — consider porting classifiers in batches, each batch goldens-green
before the next. Runtime-loadable rules remain a deferred enhancement (ADR-0047). After this
retires, the node likely has no live leaf → the retire-cascade asks before treating ws2 done.

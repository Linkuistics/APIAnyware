# kdl-serde-spike-k17

**Kind:** work

## Goal

**Gate the KDL-everywhere decision.** Prove (or disprove) that the large machine IR can be
serialized/deserialized as KDL with acceptable performance, on **one real framework** — before
the full cutover commits to it. This is the spike ADR-0046 §5 gates on.

## Context

Design source (do not re-grill): **PRD `prd/2026-06-24-spec-format-data-model.md`**, **ADR-0046**
(KDL everywhere), node `BRIEF.md` running log. The official `kdl` crate is *document-model*, not
serde-derive; the IR can be tens of MB per framework (the AppKit/Foundation graph). The two
candidate machine-ser/de paths: (a) a community serde adapter (`serde_kdl` / `serde-kdl`),
(b) hand-built `KdlDocument` via the official `kdl` crate. **Toolchain:** `kdl` 6.7.1 needs
rustc 1.95; this repo is on 1.93.1 → pin `kdl = "=6.3.4"` or bump rustc (decide here).

## Done when

- A real framework's `extracted`-shape IR round-trips JSON↔KDL losslessly (serde structural
  equivalence), via a chosen path (a) or (b), measured for parse + emit time and on-disk size
  vs the current JSON.
- A clear **go / no-go** recorded: KDL viable for machine artifacts, or invoke the **JSON
  retreat** (ADR-0046 §5) for `extracted`/`resolved` while authored `.apiw` stays KDL.
- The decision + numbers appended to the node `BRIEF.md` running log; if no-go, ADR-0046 gets a
  status note and the cutover leaf (k20) brief is adjusted.

## Notes

A spike — throwaway code is fine; the deliverable is the measurement + decision, not production
code. The eval harness at `semantic/docs/research/2026-06-24-kdl-authoring-eval/` shows the
`kdl`-crate validator pattern. `cargo fmt --all` only if any code lands in-tree.

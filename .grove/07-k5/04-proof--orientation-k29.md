# orientation-k29

## Goal

Proof the complete orientation set under the `grove-proof` charter:
`semantic/specification/interface-language/README.md`, `explanation/unsaid.md`
and `glossary.md`. Read against the documentation plan §9.1 and §4–§7, with
all contract classes in scope.

## Context

- G1 is embedded in the landing page, with a link back to that map from the
  domain explanation. G4 is embedded after the ownership comparison. Sources
  and SVGs are under `figures/`; shared vocabulary and PlantUML macros are under
  `figures/style/`. G4 is available for reuse by the concepts increment.
- Every diagram has a key, alt text and adjacent takeaway. Tables compare
  buffer length/storage and the independent threading questions; the existing
  reading-route table now states its role. The glossary remains a lookup list.
- Art's decisions, declined figures and verification evidence are recorded in
  `03-DONE-art--orientation-k28.md`. No medium limit or earlier-stage defect
  was identified. Normative text, the synthetic header and `.ail` examples are
  unchanged.
- `task docs:check` now includes SVG regeneration. `task docs:diagrams:write`
  updates committed SVGs after intentional edits. Renderer versions are pinned;
  font differences can still change bytes and require visual inspection.

## Done when

- The whole set passes the proof charter, including technical fidelity and the
  synthetic/proposed boundary in both prose and figures.
- Walk landing page → domain explanation → canonical rules, and test direct
  entry through the glossary. Verify live-page navigation under plan §3.
- `task docs:check` passes; any changed figures are regenerated and inspected.
- Check the orientation node's done conditions when retiring its last live
  leaf, and promote reusable context if the node closes.

# orientation-k71

## Goal

Draw G11, the API-model figure for `explanation/model.md`, and bring the
orientation pages' figures and captions into line with the model-first route.

## Context

- G11's contract: plan §6 (row, placement between G1 and the detail figures,
  labels in the prose's words, G9 never substituted). The page's structure:
  plan §9.8; concept names: plan §10.
- The slot and its facts: the node brief's `## Handed forward` list, written by
  orientation-k69.
- Shared vocabulary: `figures/style/vocabulary.txt` and `figures/style/ail.puml`
  under `semantic/specification/interface-language/`.

## Done when

- G11 is committed as source plus generated SVG under `figures/` with the
  shared style, embedded in the model page's *The model at a glance* with alt
  text and a caption. Every entity and relation it shows is also stated in the
  adjacent prose, and its labels use the watch API's names and §10's concept
  names rather than AIL keywords. If one view is not legible, two linked views
  (calls; description and access) are used, as §6 allows.
- G1's and G4's captions and any figure text on the orientation pages agree
  with the model page's concept names where they refer to them.
- `task docs:check` passes, including byte-for-byte SVG regeneration.

## Notes

Charter: figures, captions and alt text. Record prose defects for proof in the
node brief. Proof is already queued, so cut nothing at the end.

# tutorial-k83

## Goal

Align the tutorial's figures with the model-first route: `tutorial-model`,
`tutorial-lifetime`, `tutorial-borrow`, `tutorial-storage` and
`tutorial-callbacks` under the concepts their parts apply.

## Context

- Figure contract: plan §6 (G11 as overview; detail views route back to it).
  Concepts: plan §10. The drafts' figure notes and the node brief.

## Done when

- Each tutorial figure's caption names the concept it applies and routes to
  G11 or the concept section; `tutorial-model` is described as the language-
  containment view of the label-card package, distinct from the API model.
- Labels and alt text use the prose's names; the figures' facts are unchanged.
- No G10 view remains embedded on the tutorial pages. The grammar-reference
  links resolve to the relevant views, and the tutorial's semantic figures
  and local examples remain in place (model-reading-k73).
- `task docs:check` passes, including byte-for-byte SVG regeneration.

## Notes

Charter: figures, captions, alt text. Proof is queued, so cut nothing at the
end.

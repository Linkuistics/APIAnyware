# concepts-k97

## Goal

Check the correction's figures and surrounding text against the common API
model, fixing presentation within the art charter.

## Context

- Documentation plan §9.2, *Full-set scope correction*, and §6.
- concepts-k95–k96 and the node brief's handed-forward items.

## Work

Read the whole bounded document and affected summaries. Inspect its figures
and captions, especially the API-model views and synthetic source/access
examples. Their scope must agree with the corrected prose. Existing figures
may already satisfy the contract; add or change one only when the relationship
requires it. Keep sources and generated SVGs together, grammar views in the
grammar reference, and accurate labels for source-specific examples.

## Done when

- Figures/captions support the cross-language model and clearly label
  intentionally source-specific or synthetic examples.
- Necessary presentation changes preserve accessible figures and their sources.
- Rules, grammar and example contracts are preserved; `task docs:check` passes.

## Notes

concepts-k98 is already queued. Add no automatic repetition. Record defects
outside the art charter for the human instead of absorbing them.

## Decisions (running log)

D1 — Read the bounded pages and every figure they embed: G1 (README), G11a
and G11b (model). Their captions, box text and legends name the invented
watch API, roles (author, tool, consumer, package, catalogue) and
relations, with no source-language or platform restriction; they agree with the
corrected prose. The choices page embeds no figure. G3, embedded only in
`explanation/packages.md` outside the bounded document, keeps its explicit
"Invented API and synthetic definitions" legend and caption for the
`objc_like`/`swift_like` paths; it is accurately labelled and unchanged.

D2 — Figure declined: a table or diagram of described API sources against
consuming languages. Reason: editorial judgement (the two-line prose
distinction in the README and model is short and carries the relation; a
figure would imply a provider-support matrix the scope disclaims). It is not a
contract rule or a medium limit.

D3 — No figure, source or SVG changed. `task docs:check` passes (229
candidates, 0 pending, 0 errors). No later-stage defect; k98 proof already
stands, so no leaf added.

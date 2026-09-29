# concepts-k78

## Goal

Bring the concepts document's figures into the model-first route: G2–G7 and
the reused G9 views sit under the concept they illustrate, with captions
and labels in the model's words. G10's eleven railroad views live with the
grammar description in `reference/notation.md`, linked from other pages.

## Context

- Figure contract: plan §6 (G11 as the overview; G2–G7, G9–G10 as detail;
  a route from each detail view to the overview). Concepts: plan §10.
- The node brief's `## Handed forward` list and the drafts' figure notes.

## Done when

- Each semantic figure's caption on the three pages names the concept it details and
  links back to G11 or its concept section where that orients a direct entry;
  labels and alt text use the prose's names.
- All eleven G10 views are legible at their grammar-reference home, paired
  with the named productions and a textual grammar route. No G10 embed
  remains in this run's explanation or canonical pages or glossary; their
  section links resolve. Captions omit elementary syntax and railroad lessons.
  Verify each view against `grammar.ebnf`; retain its source and generated SVG.
- Any figure the drafts handed forward is committed as source plus SVG with
  the shared style.
- `task docs:check` passes, including byte-for-byte SVG regeneration.

## Notes

Charter: figures, captions, alt text. Proof is already queued, so cut nothing
at the end.

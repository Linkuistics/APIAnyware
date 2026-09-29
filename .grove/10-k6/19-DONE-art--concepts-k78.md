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

## Decisions (running log)

- D1 — Retain the existing semantic figures and their example boundaries.
  Connect each concepts-page figure caption to its API-model concept, and
  give each grammar view a nearby sentence stating its lookup purpose.
  G9 remains the language-containment view; G11 remains the API-model overview.
- D2 — Use direct document/source reads and rendered figures as evidence.
  Tier 2 coverage reports generation `2026-09-23T09:55:55Z`; this run's
  Markdown and figure metadata are changed or untracked, the design subtree
  is excluded, and several SVGs are excluded by suffix. No code-structure
  claim relies on this graph generation.
- D3 — Keep G10's existing productions and generated drawings: source and
  rendered paths match the EBNF. Add a full-size SVG route beside the wide
  callable view for narrow previews. Retain its textual grammar alternative.
- D4 — Decline additional lifecycle, storage and ownership diagrams as an
  editorial judgement: G6, the storage comparison and the ownership comparison
  already carry those relations. No draft left an unfilled figure slot.
  This is neither a contract prohibition nor a limitation of the medium.
- D5 — In the final aid read, make three prose-only comparisons visible as
  tables: L4's enum/flags domains under closed/open policies, C4's initialized
  payload versus allocated storage, and A4's compatibility evidence. Each
  table summarizes its adjacent examples and names its reading purpose;
  none adds a contract or changes canonical rule text.

## Verification and handoff

The semantic figures retain their existing placements, sources, SVGs, labels
and alt text. The nine G2–G7/G9 placements across the explanations, L2 and
glossary now name and link the model concept in their figure descriptions.
The eleven G10 views retain their named productions and exact-grammar routes;
each now states its lookup purpose beside the image. The wide callable view
also links its full-size SVG. L4, C4 and A4 gain the comparisons recorded in D5.
Choices' existing tables already carry its comparisons; no diagram was added.

Validation after the final reader-page edits:

- `task docs:check` passed: links and examples in 21 files, all 19 reader
  pages reachable, and all 26 SVGs reproduced byte for byte. SHA-256 digests
  matched before and after for every one of 106 subjects: the interface-language
  tree, checker Python files, Taskfile, documentation plan and audit.
- Removing paired reading aids and their trailing blank separator reproduces
  all three canonical pages exactly from `87221b8c`; an in-memory normative
  version mutation was detected for each. The grammar, conformance record
  and three frozen fixture packages also match that revision.
- Every scoped page retains its code fences, explicit anchors, headings and
  image markup against the session parent. G10 image enumeration finds all
  eleven only in the grammar reference within this run. Injected misplaced
  embeds were detected; the queued tutorial's existing embeds supplied the
  cross-scope control.
- Each G10 source production matches the canonical grammar token for token,
  with a deliberately altered token rejected. Inspected all eleven rendered
  railroad views and seven semantic SVGs using local PNG previews. Their
  paths, labels, keys and example boundaries agree with the adjacent text;
  the callable view benefits from the full-size route on narrow previews.
- The new tables carry only the adjacent examples' values and distinctions;
  they have role sentences and no merged cells. No source/SVG edit was needed.

These checks establish document consistency and preservation, not human
comprehension or execution of the proposed language. No outstanding handoff
or correction run was identified. Proof `concepts-k79` is already live, so
no successor is cut and the concepts node stays open for that stage.

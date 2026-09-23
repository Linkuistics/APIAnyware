# orientation-k36

## Goal

Correct the document's explanatory structure and prose after the human's first
reading identified compressed abstractions and negative framing.

## Context

All document and figure paths here are relative to
`semantic/specification/interface-language/`. The document is `README.md`, `explanation/unsaid.md` and `glossary.md`.

- Human findings H1–H2 and proxy finding P7 are recorded in
  `first-path-reading-k8`, decisions D2–D6, in that leaf's committed record.
- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`, §9.1.
  Its revised §4–§6 govern comprehension, framing and figures; §7 governs checks.
- This is the first correction run for this document after its original
  editorial pipeline. It runs through draft, copy-edit, art and proof in order.

## Work

Start with the overview's sentence "every producer crosses the same publication boundary". Explain who writes an AIL description, what a validator would check, and what other tools do with it. Introduce the technical terms through those actions. Rewrite the whole three-page set at that level of explanation. Retitle the domain page *Using an API across languages* while retaining its path. Give headings positive subjects and develop concepts through concrete cases. Update affected link text and heading-derived anchors throughout the existing set; stable explicit aliases are acceptable where needed.

Read the whole document, including its tables and opening summaries. Preserve
normative semantics, rule identities, AIL code and synthetic example contracts.
The human asked for understandable explanation before giving more feedback;
replacing a few reported phrases is insufficient.

## Done when

- The whole document explains the relevant actors, actions and consequences
  before relying on technical shorthand.
- Headings and explanatory framing state their subjects positively, while
  exact conditions, limitations and obligations remain recoverable.
- The revised structure brief is satisfied and `task docs:check` passes.
- Work belonging to later stages is recorded in the node's handed-forward list.

## Notes

The later stages of this correction run are already queued. Read the live
siblings and keep the existing run; each stage uses the editorial procedure
for any additional finding. A second re-run of the same stage on this document
requires escalation. The human requested corrections before further feedback;
`first-path-reading-k48` follows all three corrected documents and precedes
reference drafting. Keep the synthetic examples and proposed-language status
explicit throughout.

## Decisions (running log)

D1 — The named plan §9.1 supplies all three structure-brief requirements:
reader/outcome, the ordered sections for each page, and emphasis/non-goals.
Keep that order. Expand the whole orientation set through concrete actors,
actions and consequences; retain the C header and normative contracts. Glossary
entries gain examples and explanations rather than relying on cross-links to
teach their definitions. The existing correction siblings k37–k39 discharge the
successor-cutting obligation; no new editorial leaves are needed.

D2 — Technical authority is the directly read L1–L6, C1–C8 and A1–A5/F1 text.
Tier 2 graph project matches this workspace; coverage generation is
2026-09-23T09:55:55Z. Coverage excludes semantic/docs and reports changed
metadata for README/unsaid, so those sources are read directly. This is document
work, with no structural code claim. Figure wording remains art's charter;
record concrete G1/G4 handoffs while revising the prose around those figures.

D3 — Retitle the domain explanation in place and update the live incoming
link labels from concepts and tutorial. Preserve explicit aliases for the
changed publication, shared-description and familiar-terms headings. The
audit's original proposed title and the completed reading checkpoint remain
historical evidence. Add producer, consumer and publication-boundary glossary
entries after teaching those roles in the overview. The G1/G4 wording review
is recorded in the node brief for art; the existing copy-edit body already
owns the full sentence/terminology pass. No new human comprehension result or
new Grove issue lesson is established by this rewrite; k48 remains that check.

D4 — Structure and technical-truth read completed across the three revised
pages, including their summaries, tables, definitions and figure surroundings.
Plan §9.1's sequence is retained. The ownership cases map to C2/C3/C5;
borrow regions and invalidation to C1/C5; buffer/text cases to C3/C4; failure
and output states to C3/C5; executor/concurrency/re-entry to C2/C3/C6;
callback captures, counts and teardown to C2/C6. Publication, identities and
scope map to L2/L3/C8; access, ABI, representations, profiles and consumer
agreement to A1–A5; fixture limits to F1. Glossary type/slot/pattern statements
were checked against L1/L2/L4–L6/C1 as applicable. Constructed cases remain
labelled as possible contracts, with the C-header/fixture-mapping distinction
retained. No AIL blocks, rules, fixture files or production code changed.

D5 — Final verification after all document edits: `task docs:check` exited 0.
Links checked 19 files with 17 pages reachable; example checks passed for 19
files; all 11 SVGs regenerated identically, item by item. SHA-256 digests before
and after that run matched for 58 subjects: every file under
`semantic/specification/interface-language/` and `semantic/specification/tools/`
(excluding bytecode caches), plus `Taskfile.yml`, the documentation plan and
the audit. A parent-revision comparison confirmed the C header is byte-identical.
An enumeration of glossary headings confirmed every prior entry remains and
alphabetical order holds; the additions are Consumer, Producer and Publication
boundary. Diff inspection confines other reader-page edits to incoming title
labels. Mechanical checks establish document integrity, not language validation,
runtime behaviour or human comprehension. Live k37–k39 remain under this node,
so retirement closes only this leaf and requires no ancestor cascade.

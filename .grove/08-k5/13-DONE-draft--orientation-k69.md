# orientation-k69

## Goal

Draft `explanation/model.md`, the canonical account of the model of API
behaviour and binding obligations, and make the orientation pages lead to it.
A reader finishing the domain page can then name the entities a description
records, how they relate, and which question each concept answers, before
meeting any AIL notation.

## Context

- Structure briefs: plan §9.8 (the model page) and §9.1's *Model-first run*
  block (landing page, domain page, glossary), in
  `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`.
- The concept set, order, anchors and construct map: plan §10. The learning
  route: plan §3. The prose contract, including *Two models, one purpose* and
  *Make the model the main thread*: plan §4. G11: plan §6.
- The human's direction and rationale: first-path-reading-k64, D12–D13.
- Existing material to reuse, not replace: the watch API and the six
  obligation sections of `explanation/unsaid.md`; the landing page's workflow
  and G1; G4–G7 and G9 for names and relations.

## Done when

- `explanation/model.md` exists with §9.8's ordered sections and an explicit
  anchor for every §10 concept, in §10 order. Its concept sections show no AIL
  snippets; construct names appear only in the closing map.
- The closing map links, for each concept, the concept-page section and
  tutorial part that introduce its notation *as they exist today* (for
  example, *Lifecycles and patterns* until the concepts run splits it), and
  cites its rules. The concepts and tutorial runs update those links when they
  rename sections.
- G11's slot is recorded under this node's `## Handed forward` for `art`,
  with the entities and relations the prose establishes. The prose carries
  every fact the figure will show.
- The landing page links the model page from its map and paths table, and the
  domain page's obligation sections and *Where next* route to it (plan §3,
  *Staging*). The glossary links concept anchors as §9.1 states.
- The two k64 residues are repaired: the "railroad reading key" link text in
  `README.md` and `glossary.md`, and the "explicit end marker" description of
  reading aids in `README.md`.
- Existing explanations, examples, figures and anchors on the orientation
  pages are preserved; a renamed heading keeps its old slug.
- `task docs:check` passes.

## Notes

This is the first leaf of the one bounded model-first run authorized by the
human's 2026-09-29 direction (see the node brief). Copy-edit, art and proof
are already queued behind it, so cut nothing at the end.

If the concept set in §10 proves wrong while drafting — a concept the model
page cannot state affirmatively, or one construct with no concept — record
the change and its reason in this leaf, update §10 and the anchors in the same
session, and say so for `model-reading`. Do not change language semantics:
a mismatch between the model and the rules becomes an open question in
`explanation/choices.md`.

If the model page and the three routing edits do not fit one session, land
the model page with its landing-map link first and decompose.

## Decisions (running log)

- D1: Keep all eleven §10 concepts and their order. The current L/C/A rules
  support the set; no language change or concept-set revision is needed.
- D2: Reuse the watch API as alternative possible contracts, not a combined
  implementation. Keep the model's overview and concept sections free of AIL
  notation; put construct spellings and current introduction links in the
  closing map. G11 remains an explicit art handoff.
- D3: Preserve existing orientation examples and anchors. Add concept routes
  beside glossary definitions and before their notation fragments; repair the
  two stale reading-aid descriptions as part of the routing change.
- D4: Add L5 to §10's published-description rule list and the page's citations:
  advisory deprecation is defined there. This repairs traceability; it changes
  neither the concept set nor language semantics.
- D5: Spend the one in-session review on ownership, validity and callback
  counterexamples. The claim under challenge is that the model preserves the
  separate watch cases and the rules' lifetime boundaries, which mechanical
  documentation checks cannot establish. The fresh reviewer inspected the
  bounded prose against C1–C6/L4–L6 and constructed failure/null/teardown cases;
  it reported no substantive or minor findings. No finding needed reconciliation
  and no second review is scheduled. Human comprehension remains for
  model-reading.

## Verification

- `task docs:check` passed: 20 Markdown files checked, 18 pages reachable,
  checked AIL extracts matched their sources, and all 24 existing SVGs
  reproduced. SHA-256 digests before and after the final run matched for
  every file measured: `Taskfile.yml`, the documentation plan and audit,
  the interface-language tree and documentation tools (excluding Python caches).
- Compared `README.md`, `explanation/unsaid.md` and `glossary.md` with parent
  revision `793cd745`: headings, explicit anchors, fenced examples and image
  embeds are unchanged. Deliberate omitted-anchor and changed-example controls
  failed equality as expected. The scope is these three pages.
- Enumerated the model page's explicit anchors: all eleven match §10 in
  order. Concept sections contain no AIL fences or construct spellings;
  pre-map code spans name only the watch API and rule identifiers. The closing
  map's spellings were checked against canonical text and grammar, with
  schematic slot/place forms read against L2/C1.
- Read the complete model page against its structure brief and L/C/A sources;
  checked direct entries at `#callbacks` and `#access` for local context,
  domain motivation, variants, rule citations and notation/tutorial routes.
  The existing orientation pages retain their explanations and gain model
  routes; each glossary entry has a model route, with fragment entries naming
  their concept before the notation.
- Graph metadata remains generation `2026-09-23T09:55:55Z`; the design/research
  tree is excluded and relevant Markdown is stale or untracked. Coverage was
  checked and direct source reads supplied the evidence. No code-structure
  claim or completeness inference from graph absence was made.
- G11 is intentionally handed to the queued art stage in the node brief.
  Copy-edit, art and proof already stand as live later siblings; no stage is
  added and no parent node closes. These checks establish document consistency,
  not human comprehension, native behaviour or executed AIL validation.

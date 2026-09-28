# orientation-k54

## Goal

Complete and verify the figures supporting the corrected introductions across `README.md`, `explanation/unsaid.md` and `glossary.md`.

## Context

- Human assessment and H5–H7: first-path-reading-k48, D2–D5.
- Structure brief: documentation plan §9.1; general requirements:
  §4–§6 and §9.7.
- Rule-reading-k49 supplies the canonical examples, language model and selected
  railroad views. Read their landed form and this node's Handed forward list.
- Paths are relative to semantic/specification/interface-language/.

## Work

Inspect the three pages with G1/G4 and the new model routes. Render any justified new figure slots, reusing rule-reading's G9/G10 rather than redrawing contradictory models. Explain names, arrow meanings and reading order beside each figure.

Read the whole document under this stage's charter. Preserve original AIL
semantics, example contracts, proposed status and synthetic boundaries.
Work belonging to another stage follows the node's declared handoff and
escalation rules; do not silently absorb it.

## Done when

- This stage's charter is satisfied for the whole named document under the
  revised structure brief, with the disposition of each relevant H5/H6 location
  recorded in the task's notes.
- Snippets, prose and figures agree with their grammar and canonical rules;
  complete/fragment labels remain truthful.
- `task docs:check` passes. Mechanical checks and editorial inspection are
  reported separately from human comprehension.

## Notes

This is the human-directed second correction run. The escalation and authority
are in the node brief; no further automatic rerun is authorized. Record any
unresolved residue for first-path-reading-k64 and seek human direction when
necessary. The next stage is already queued under this node; do not add a duplicate.

## Decisions (running log)

- D1: Reuse G9 beside the glossary's local/imported example. The existing
  links make the model discoverable, but direct lookup still leaves package
  containment, import direction and member association in prose and code.
  Give the reused figure a local reading key and explicit scope for Filter,
  whose separate fragment remains on the rule page. Replace G9's page-relative
  "next fragment" legend with a statement that works at either embedding.
- D2: Add a slot-reference/place comparison table at the Slot entry. Show the
  owning callable explicitly so `$result` cannot appear to name one shared
  result across position and Filter. Retain the existing explanations and
  fragment labels; no language or example contract changes are needed.
- D3: Preserve G1/G4 and the domain comparison tables. Decline a second
  language model and repeated railroad embeddings in each glossary entry as
  an editorial judgement: reuse one model locally and route syntax detail to
  the existing G10 views beside their examples. This is neither a contract
  prohibition nor evidence that the medium cannot carry those relations.
- D4: The art correction has no unresolved handoff or medium limitation.
  Retire this leaf with orientation-k55 still live; no successor is added and
  orientation-k5 does not close. No architecture or language decision changed,
  so the ADR set needs no update. Human comprehension remains unassessed until
  first-path-reading-k64.

## H5/H6 disposition and figure inspection

Read all three orientation pages under the art charter. The following
dispositions cover their figure needs and the corrected notation introductions.

| Location | Disposition |
|---|---|
| README workflow and paths | G1 carries the producer/check/package/consumer sequence and selected-definition branch. G8 maps reader tasks to destinations, including L1's shell/key and L2's model/reference views. Existing adjacent text explains both roles; retained. |
| Domain ownership | G4 keeps three separate possible watch contracts, with time downward within each case. Its caption and key explain borrow versus transfer and responsibility at entry/delivery; retained. |
| Domain validity, buffers, failure, concurrency and teardown | Existing tables carry the comparisons and state what the reader should take from each. The watch header and explained operations supply their concrete context; retained. |
| Glossary declaration, identity, local/imported and member (H5/H6) | Reused G9 locally at the local/imported entry, with package/version context, arrow meanings, callable/field containment and explicit omissions. Point remains in geometry; Canvas and position remain siblings in canvas, associated by member. The figure's Filter is explicitly linked to its separate fragment. |
| Glossary callable and slot (H6) | Added a table mapping position's and Filter's signature slots to their callable-local places. The owning callable is visible in every row, including both distinct result slots. |
| Glossary package, clause, place and Import (H6) | Retained located fragments and routes to G10 shell, clause, names, callable and place views. Compared their source productions with grammar.ebnf and inspected the rendered tracks; the prose keys distinguish syntax from semantic validity. |
| Remaining glossary entries | Retained concise term definitions and routes to the domain/concept figures. Repeating diagrams for individual definitions, the identity tuple or each familiar-term comparison was declined as editorial judgement: the located examples, shared model, existing comparison tables and linked fuller explanations serve those lookup tasks. No medium limitation was found. |

Inspected rendered G1, G4 and G9 and the five linked G10 views (shell, names,
callable, places, clause), alongside their source and page explanations. Labels,
containment, arrow endpoints, keys and reading order remain legible; meaning
does not depend on colour. The new glossary caption explains the shared model's
scope and the placeholder import. The slot table has no merged cells and states
its comparison role immediately above it. No new diagram notation or renderer
was introduced.

The graph project was confirmed at Tier 2, generation 2026-09-23T09:55:55Z.
Coverage reported changed/untracked documentation metadata and excluded
design/research/SVG paths. The pages, contract sections, grammar and figure
sources were read directly; SVGs were inspected as rendered images. No
structural code or graph-completeness claim is made.

## Verification

After the final page and figure edits, `task docs:check` passed: link checking
covered 19 files with 17 Markdown pages reachable, example equality checked
19 files, and all 23 SVGs regenerated identically. Intentional regeneration
changed only G9's SVG, matching its one-line legend edit.

The sorted subject list and SHA-256 manifest matched item for item before and
after the gate: 93 files comprising the interface-language tree, documentation
tools (excluding ignored caches), root Taskfile, documentation plan and audit.
Manifest SHA-256: `ca90b12a9f94ee80a49582e5f9ff3391163719ab145dafa7a0b289bd129e613e`.

Rendered-figure inspection and the source/grammar comparison are editorial
evidence, separate from that mechanical gate. They establish consistency and
legibility, not human understanding, parser acceptance or runtime behaviour.
No in-session reviewer was needed for an unexpected correctness claim.

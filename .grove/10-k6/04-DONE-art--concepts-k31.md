# concepts-k31

## Goal

Add the concept explanations' figures under the documentation plan's visual
contract, with source and generated SVG committed together.

## Context

- Read all three concept pages in
  `semantic/specification/interface-language/explanation/`: `contracts.md`,
  `packages.md` and `choices.md`, plus the node brief's art handoff.
- The structure and prose contract are in
  `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`
  §4–§7 and §9.2. Apply the research survey's art criteria (§9).
- The node brief assigns G2/G3 to packages and G5/G6/G7 to contracts, with
  their precise distinctions. G4 is already reused in contracts. Use the
  shared vocabulary in `figures/style/vocabulary.txt` and `ail.puml`.
- Read the complete pages; figures supplement the existing prose. Keep the
  immutable fixture distinct from constructed mutable-store and ordering
  examples, and keep all fixture identities visibly synthetic.
- Copy-edit preserved the section order, code blocks and Q1–Q6. First-use
  glossary links, familiar-term warnings and explicit actors were improved.
  No structural or technical correction run is pending.

## Done when

- Required figures answer the handed-forward questions, carry accessible
  descriptions and use the shared vocabulary. Adjacent prose states the
  relationships; colour is never the only cue.
- Figure sources and generated SVGs are committed. Clear the art handoff
  entries closed by this stage.
- `task docs:check` passes, including byte-for-byte diagram regeneration.
  This does not establish AIL semantic conformance or human comprehension.
- Add a `proof` leaf with the bare stem `concepts`, unless a later live sibling
  already holds that stage, under the editorial family procedure.

## Decisions (running log)

- Use the approved PlantUML renderer and existing role/arrow vocabulary for
  G2/G3 structure, G5 borrow timing, G6 resource states and G7 callback timing.
  Keep G2 schematic: the frozen examples do not contain imported packages, and
  their exported destructor is not an example of private support.
- Reuse G1 on all three pages before detail; add tables for the remaining
  consequential mappings and comparisons, including outcome partitions.
- G5 separates the immutable fixture from a constructed mutable variant.
  G6 contains only the immutable store lifecycle; G7 separates a constructed
  call-scoped schedule from successful synthetic owner-scoped registration.
- Extend the shared vocabulary only for structure entries and resource states:
  compartmented boxes identify contract items; rounded boxes identify states;
  bold labelled arrows identify state transitions, distinct from transfers.
- Declined an additional diagram of the `before` pattern by editorial
  judgement: its role-binding table carries the same-instance ordering without
  mixing a constructed protocol into G6's immutable fixture. This is not a
  contract prohibition or evidence of a limitation in the medium.
- Declined a new choice-by-choice diagram by editorial judgement: the shared
  context map, comparison table, clause-count table and existing pressure-case
  table carry those relations without another notation. No medium limitation
  was encountered.
- Visual inspection corrected G2's excessive width and G6's overlapping note;
  the final SVGs have readable labels, local keys and accessible page captions.
  The sequence diagrams use notes for ordinary entry/completion so arrows keep
  their specific transfer, borrow, invalidation and callback meanings.

## Verification

- `task docs:check` passed: 13 files in the link and example checks, 11 pages
  reachable, and all seven SVGs reproduced byte-for-byte.
- SHA-256 manifests matched before and after the check for all files under
  `semantic/specification/interface-language/` and `semantic/specification/tools/`,
  plus `Taskfile.yml`, the documentation plan and documentation audit.
- Inspected rasterized renders of G2, G3, G5, G6 and G7 after layout changes.
  Reviewed the page diff: additions are figures, tables and their adjacent
  descriptions; existing code blocks, section order and Q1–Q6 are preserved.
- The gate establishes documentation consistency and figure reproducibility,
  not AIL semantic conformance, native behavior or human comprehension. No
  production code was explored or changed, and no graph evidence is claimed.

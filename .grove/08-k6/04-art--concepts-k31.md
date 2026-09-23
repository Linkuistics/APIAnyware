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

# orientation-k28

## Goal

Complete the figures for the orientation set: `semantic/specification/interface-language/README.md`,
`explanation/unsaid.md` and `glossary.md`. Follow the `grove-art` charter.

## Context

- Read the document node's `## Handed forward` entries for G1 and G4. They name
  the insertion points, relations and rule boundaries; clear entries you close.
- The documentation plan's §6 defines the figures and shared visual vocabulary;
  §9.1 defines this document's structure, and §4–§5 supply its prose contract.
- Copy-edit kept the section structure and synthetic C header intact. Rule
  identifiers now use code typography, glossary links cover additional terms,
  and the prose names concrete caller/callee actions. No language rules changed.
- These are proposed roles and hypothetical contracts, not running tools or
  a real API. The prose remains sufficient without the figures.

## Done when

- G1 shows producers, publication validation, the authoritative package and
  pinned dependencies, and consumers. Validation does not prove binary truth.
- G4 shows who holds the release/destruction obligation for borrowing,
  consumption at entry on every outcome, and an owned result at delivery.
  Retention remains separate. Draw it here or explicitly hand the slot to
  concepts as §9.1 permits.
- Commit diagram sources and tool-generated SVGs under `figures/`, with the
  shared styles §6 requires, accessible adjacent explanations and keys.
- `task docs:check` and any figure-rendering task added here pass.
- Add the `proof` successor with bare slug `orientation` unless already queued.

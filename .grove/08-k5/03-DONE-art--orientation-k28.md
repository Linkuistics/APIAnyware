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

## Decisions (running log)

- Use PlantUML for G1 and G4: its context shapes and sequence notation fit the
  two relations, and its pinned local renderer is already available. Shared
  role macros and line conventions live under `figures/style/`.
- Reuse G1 by linking to the landing-page map from the domain explanation;
  repeating the full context picture would delay the concrete header or reverse
  the context-to-detail order. G4 is drawn in this increment for later reuse.
- Keep figure tooling local and standard-library-only. The check renders into a
  temporary directory and compares bytes, with an explicit update mode; it
  checks the renderer versions and rejects unpaired sources/SVGs.
- Add compact tables for initialized length versus storage and for executor,
  concurrency and re-entrancy. Give the existing navigation table a role sentence.
- Declined figures (editorial judgement, not a forbidden fix or a medium limit):
  the glossary remains a lookup list; its familiar-meaning comparisons already
  have a table in the domain page. Separate borrow-validity, output-failure and
  callback-teardown drawings would repeat the local two-case explanations here;
  the detailed validity and callback timelines remain G5/G7 in concepts. No
  medium limitation was encountered.
- Verify the new renderer check with executable controls rather than a second
  reader of its branching logic: missing/stale/orphan SVGs, renderer syntax
  failure, duplicate stems and unpinned Mermaid are rejected; PlantUML and D2
  both generate and compare successfully. The check leaves stale SVGs untouched.
  Before/after SHA-256 matched for the checker, Taskfile and all six figure/style
  files during these controls. Ruff checks and formatting pass.
- Use an explicit near-white canvas: PlantUML omits the background rectangle
  for pure white, which leaves raster SVG exports transparent. The near-white
  background preserves dark text in exports as well as browser display.
- Final `task docs:check` passed: links and page reachability, example/fence
  checks, and exact regeneration of G1/G4. The inputs were frozen with matching
  before/after SHA-256 over the documentation set, documentation tools, figures,
  Taskfile, plan and audit. Both committed SVGs were rasterised with rsvg-convert
  and visually inspected: labels, keys and arrows are legible, with no renderer
  warning banners. No normative rules or example contracts changed.

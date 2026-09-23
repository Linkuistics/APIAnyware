# orientation-k5 — brief

## Goal

Land the orientation document: the landing `README.md`,
`explanation/unsaid.md` and `glossary.md`. A language designer new to API
binding can then state what AIL is and its status, explain the caller's and
implementer's obligations through concrete operations, and choose a path
through the documentation (plan outcome 1).

## Contract

The structure brief is the documentation plan's §9.1, at `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`. It states
the reader and their outcome, the ordered sections and the purpose of each,
and the emphasis and non-goals. The same plan's §4 (prose contract), §5
(page-one block and example labels), §6 (figures) and §7 (checks) govern
every stage. The gate is `task docs:check`, plus any task this document adds.

## Pipeline

`draft` → `copy-edit` → `art` → `proof`, cut lazily: each stage's last act
adds the next unless a live later sibling already holds it. Stage leaves carry
this document's bare stem as their slug. Defects a later stage owns go under
`## Handed forward` in this brief; the list is created by the first stage that
needs it. Figure slots that `draft` leaves for `art` go there too.

## Done when

- The three pages exist and meet §9.1. Every domain term in the root brief
  has a defining location and a glossary entry with a familiar-meaning warning
  where one applies.
- The landing page links every page that exists when this lands, and the
  existing normative and supporting pages remain reachable from it.
- Figure G1 (context) is committed as source plus SVG and reused as the map;
  the page's G4 slot is drawn or explicitly handed on to `concepts`.
- `proof` has walked the landing page to the domain explanation to the
  normative files, from a cold start and from a direct entry.

## Figure assets

G1 is `figures/g1-context.puml` plus its SVG, embedded in the landing page and
linked as the publication map from the domain explanation. G4 is
`figures/g4-ownership.puml` plus its SVG, embedded in the ownership section and
available for reuse by `explanation/contracts.md`. Both use
`figures/style/ail.puml`; the vocabulary and regeneration commands are in
`figures/style/vocabulary.txt`. These paths are relative to
`semantic/specification/interface-language/`.

`task docs:check` includes `docs:diagrams`, which compares regenerated SVG bytes.
Use `task docs:diagrams:write` after source or style edits, then inspect the SVGs.

## Human reading correction

The first human read (`first-path-reading-k8`, D4–D6) found the prose too
compressed and requested positive framing. `orientation-k36` through
`orientation-k39` form the first correction run. The revised plan §4–§6 and
§9.1 govern it, including the title *Using an API across languages*. Explain
the publication workflow through people, tools and actions before naming its
abstractions. Apply that treatment across all three pages and shared figures.
The follow-up human checkpoint is `first-path-reading-k48`.

## Handed forward

- **Proof — human clarification during art.** Assess all three pages for low
  semantic density outside reference and independence from Grove, editorial
  process, ADRs and planning artifacts. Art removed README's design-history
  section and the domain page's external design-proposal dependency, and updated
  the root brief and plan. The glossary remains a reference; short table cells
  should summarize explanations the non-reference page has already developed.
- **Proof — figure reconciliation.** G1 now uses concrete actors and actions;
  G4 uses the domain page's three separate synthetic watch cases. Check the
  captions and new domain comparison tables along with the whole document.
  Concept and tutorial context embeds became links to the overview. The shared
  G4 use explicitly returns to the domain watch example, keeping it distinct
  from the concept page's synthetic Store and callback fixtures.

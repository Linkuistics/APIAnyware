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

- **Art — G1, including README alt text.** The prose now teaches API authors
  and analysis tools writing a description, a validator checking required facts
  and consistency, and generators/renderers/LLM tools using the facts. The
  unchanged figure still leads with “One publication boundary” and shorthand
  such as “pins”. Revise its title, labels, limitation note, key and alt text
  to use the actors and actions taught by the revised workflow. Preserve the
  exact dependency selection and the limit on what validation establishes.
- **Art — G4, including unsaid alt text and shared uses.** The revised ownership
  section supplies concrete watch call cases before explaining transfer.
  Reconcile the figure's labels and notes with that treatment, keeping the
  three cases separate, transfer at entry on every outcome, the null-result
  condition and retention as a separate event. Review the shared vocabulary
  and all current embeds when changing the source/SVG. The prose already
  supplies these facts; source, SVG and alt text remain for art to edit.

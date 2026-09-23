# orientation-k5 — brief

## Goal

Land the orientation document: the landing `README.md`,
`explanation/unsaid.md` and `glossary.md`. A language designer new to API
binding can then state what AIL is and its status, name the obligations a
signature leaves unstated and the failure each prevents, and choose a path
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

## Handed forward

- **art — G1:** insert the context map in `README.md`, “The problem in brief”,
  after the short prose and domain-page link; reuse it on `explanation/unsaid.md`
  as appropriate without delaying the concrete header. Show human authors,
  analysers and third-party producers passing the same publication-validation
  boundary, an authoritative package with pinned profile/ABI catalogue
  dependencies, and binding generators, documentation renderers and LLM tooling
  as consumers. Validation checks completeness/consistency, not binary truth
  (L2–L3, A1, A5, C8). These are proposed roles, not running tools. Establish the
  shared visual vocabulary, source and generated SVG under `figures/` (§6).
- **art — G4:** insert the ownership sequence in `explanation/unsaid.md`,
  “Who is responsible for releasing a value?”, after the paragraph distinguishing
  owned result, consumed input and borrowed input. Show which party holds the
  obligation before/after each event; consumption is at entry on every outcome,
  including failure (C3), and a non-null owned result gives one obligation at
  delivery (C5). Keep retention separate from transfer. Introduce only caller,
  callee, handle and obligation, already explained in prose. Commit source/SVG
  for reuse by `explanation/contracts.md` in the concepts increment; if that
  increment supplies the figure, explicitly hand the slot onward as §9.1 allows.

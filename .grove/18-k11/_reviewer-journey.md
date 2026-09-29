# reviewer-journey-k11 — brief

## Goal

Integrate navigation across the finished set and present Step 2. Every page
is then reachable, with a return path, from each direct-entry type. The
audit's closing section traces each finding to the pages that resolve it.

## Contract

The structure brief is the documentation plan's §9.6, at `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`. It states
the reader and their outcome, the ordered sections and the purpose of each,
and the emphasis and non-goals. The same plan's §4 (prose contract), §5
(page-one block and example labels), §6 (figures) and §7 (checks) govern
every stage. The gate is `task docs:check`, plus any task this document adds.

Include the rule-reading model, grammar-reference routes and local examples in the final
routes. The 2026-09-28 feedback at language.md L2 shows why a direct rule entry
needs its own context. Preserve those aids when adding reference back-links,
and incorporate the actual assessments recorded by first-path-reading-k64
and model-reading-k73. G10 embeds belong only with the grammar description in
`reference/notation.md`; other pages link there, retain meaningful local
examples and omit familiar punctuation lessons. Walk those routes explicitly.

The model-first route (plan §3) is part of the journey: landing → domain page
→ `explanation/model.md` → concepts → tutorial → review guide. Plan §9.6 adds
two-way model routes: each concept section and map row on the model page links
its reference entries and review tasks, and each links back. Walk the route
end to end and from each concept to its notation, tutorial part, rules and
entries.

## Pipeline

`draft` → `copy-edit` → `art` → `proof`, cut lazily: each stage's last act
adds the next unless a live later sibling already holds it. Stage leaves carry
this document's bare stem as their slug. Defects a later stage owns go under
`## Handed forward` in this brief; the list is created by the first stage that
needs it. Figure slots that `draft` leaves for `art` go there too.

## Done when

- Every page has an inbound link from the landing page's map or its parent
  index. Links between rules, entries, explanations, tutorial parts and
  review tasks run both ways.
- The audit ends with "Step 2: refactored output", as §9.6 specifies.
- `proof` has walked the reviewer journey from every entry type in the plan's
  §3, and the survey's R1–R5 criteria hold for the whole set.

## Current navigation surface

The draft completes model-section/map-to-reference/task routes and their
returns, adds canonical-aid review routes, replaces the choices page's stale
forthcoming-guide mention and routes the tutorial's end to Reviewing AIL.
Reference entries used by tasks have task back-links, including exact-syntax
entries in notation.md. The landing page pairs frozen example files with their
walkthroughs; those `.ail` files themselves remain unchanged.

Step 2 is the audit's closing section. It indexes the complete page set,
maps F1–F12 to remedies and remaining boundaries, leaves Q1–Q6 open, and
separates navigation/consistency checks from the partial human assessments
at first-path-reading-k64 and model-reading-k73. The full-set human checkpoint
still owns comprehension; no new language question or figure is introduced.

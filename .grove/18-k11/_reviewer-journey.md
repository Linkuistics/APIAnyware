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

Include the rule-reading model, railroad views and local examples in the final
routes. The 2026-09-28 feedback at language.md L2 shows why a direct rule entry
needs its own context. Preserve those aids when adding reference back-links,
and incorporate the actual assessment recorded by first-path-reading-k64.

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

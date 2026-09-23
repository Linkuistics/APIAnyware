# concepts-k6 — brief

## Goal

Land the three concept explanations: `explanation/contracts.md`,
`explanation/packages.md` and `explanation/choices.md`. The reader can then
explain how AIL states each obligation, tell domain constraints from AIL's
choices, and see its alternatives, limits and open questions (plan outcomes 2,
in part, and 3).

## Contract

The structure brief is the documentation plan's §9.2, at `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`. It states
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

- The three pages exist and meet §9.2. Every normative claim cites a rule, and
  every AIL block carries its label.
- The open-question register in `explanation/choices.md` holds audit Q1–Q6,
  plus any question drafting found. None is resolved by the text.
- Figures G2–G7 that these pages need are committed as source plus SVG, under
  the shared visual vocabulary.
- The landing page and glossary link the new pages and terms. Each page was
  linked from the landing map in the session that landed it (plan §3,
  *Staging*).

## Decomposition

Two draft sessions, in order. The first drafts `explanation/contracts.md`, the
largest page and the one the other two lean on, and links it from the
landing page's map with its return and next routes. The second drafts
`explanation/packages.md` and `explanation/choices.md`, links them the same
way, and completes the glossary for all three pages. Each session converts
the plain-text mentions of the pages it lands into links. Only the second
draft's last act cuts `copy-edit`. The first finds its later sibling live and
cuts nothing.

## Human reading correction

The first human read (`first-path-reading-k8`, D4–D6) found compressed
abstractions and negative framing throughout the path. `concepts-k40` through
`concepts-k43` form the first correction run, after orientation's correction.
The revised plan §4–§6 and §9.2 govern the whole three-page set. Develop each
relationship through concrete actors, actions and examples before technical
shorthand. State each subject positively, preserving the exact contract,
alternatives, limits and Q1–Q6. The follow-up human checkpoint is
`first-path-reading-k48`.

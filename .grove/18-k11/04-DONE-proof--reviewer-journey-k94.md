# reviewer-journey-k94

## Goal

Read the whole navigation surface and audit Step 2 as a final proof, every class
in charter, and walk the reviewer journey from each entry type in plan §3.

## Context

- Structure brief: plan §9.6; node brief `_reviewer-journey.md`, including its
  `## Handed forward` entry (update Step 2's F12 boundary and closing paragraph
  now that copy-edit, art and proof have run; keep the full-set human
  assessment and Q1–Q6 unresolved).
- Art (k93) found nothing to change: the model page's map table
  (`explanation/model.md`, "From the model to AIL") is a mapping over a set of
  concepts, so a table is the right medium, and its role sentence sits directly
  above it. Its cells are long (about 500–750 characters) but the table still
  reads as a lookup; splitting it would be restructuring, which art does not do.
  Judgement, not a finding that the medium could not carry it. The audit's Step 2
  tables each carry an adjacent role sentence. No figure source, SVG or `.ail`
  file changed; `task docs:check` passes.

## Done when

- `task docs:check` passes and the handed-forward Step 2 update is made.

## Notes

Nothing is queued behind this leaf.

## Decisions (running log)

D1 — Starting gate: `task docs:check` passed at `95b03e46` (29 reachable
pages, all SVGs reproduced, coverage 229 candidates, 0 pending, 0 errors).

D2 — Cross-set coherence defect: `lifecycle` is filed under *Release
responsibility* in its reference entry's **Expresses** field, the reference
model-concept index and the disposition list. Plan §10, the model page's
entities section and map row, and the glossary's lifecycle entry all place it
under *Entities that outlive a call*. The entry's own text ("how an owned
handle or reference is released") answers the entities question ("how is each
released"), not the responsibility question ("who must release"). No recorded
decision supports the split; the draft's added "See also Entities" line worked
around it. Fix: move the entry, index row and disposition to `entities`, and
turn the see-also into the responsibility route. Navigation-scoped (entry →
concept link), so within §9.6's back-link section; no rule text changes.

D3 — Small consistency fixes: notation.md's one singular "Review task:" label
made "Review tasks:" like its seven siblings and the entries' field label;
profiles.md "Review: [Review the fixture's limits]" repeats the verb, so the
link text becomes "Assess the fixture's limits". Audit Step 2's tutorial rows
("Tutorial and lifetime", …) name page pairs as if they were purposes; relabel
them by part number and subject.

D4 — Handed-forward entry: Step 2's F12 boundary and closing paragraph are
updated to state that the navigation additions have passed copy-edit, art and
proof, keeping the full-set human assessment and Q1–Q6 unresolved.

D5 — Walks: all 28 non-landing pages have a direct inbound link from the
landing page or their parent index; the guided footers run landing → domain →
model → contracts → packages → choices → tutorial index → parts 1–5 → review
guide → tasks, each with a return. The model-to-entry check found every
linked entry returning to its concept's section or map row, with `lifecycle`
the only disagreement (D2). The G10 embeds occur only in `reference/notation.md`
(eleven views); the tutorial index maps six checkpoint packages. These match
Step 2's statements.

D6 — Final gate after edits: `task docs:check` passed (31 files, 29 reachable
pages, all SVGs reproduced, 229 candidates, 0 pending, 0 errors), and
`task docs:coverage:test` passed 14 tests with the reclassified disposition.
The stale-stage sweep over `semantic/` and the root brief found no remaining
"still pending" wording; its alternation pattern was seen to match the new
Step 2 text as a positive control. R1–R5: journey walked (D5); coverage
complete; links/fences/tables gated; every page states draft 0.1 and its
page-one status, and profiles.md states no production provider; task glosses
are uniform across the set and `lifecycle` now agrees with §10. The
hand-forward list is cleared (D4). No correction run: every defect found was
navigation-scoped and fixed here. No in-session reviewer spent — D2 follows
from the stated §10 contract, and the coverage check validates the concept.

D7 — Node close (`reviewer-journey-k11`): all three `Done when` items hold.
Promoted to the root brief's Notes; the node brief keeps its current-state
navigation account with the Handed forward section removed.

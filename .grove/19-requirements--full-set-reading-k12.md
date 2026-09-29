# full-set-reading-k12

## Goal

Run reader checkpoint 2 over the whole documentation set, after cross-set
navigation has landed. Establish, in the human's own words, whether the set
supports the review of AIL they want to make, and what further revision (if
any) the tree should hold.

## Context

- Documentation plan §8 and §1 (all six outcomes):
  `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`.
- Checkpoint 1's findings and dispositions, in `first-path-reading-k8`'s
  commit.
- Follow-up findings in `first-path-reading-k48` and the subsequent
  `first-path-reading-k64` assessment, and the model account's assessment in
  `model-reading`. Keep each read's reported extent and correction history
  distinct; do not infer approval of unreported pages.
- The model-first route (plan §3) and outcome 6 (plan §1): judge whether the
  reader can explain which model concept each construct expresses.
- The audit's closing "Step 2: refactored output" section, written by
  `reviewer-journey`.

## Work

1. Run the proxy reader as in checkpoint 1, over the whole set and all six
   outcomes, starting it from each direct-entry type in the plan's §3. Label
   its output as a proxy.
2. The human reads the set as a reviewer, starting from the landing page, and
   judges it against the root brief's completion conditions.
3. Triage the findings as in checkpoint 1. Revision work that is precise
   enough to state becomes leaves; revision work that is not stays on the root
   brief's horizon.

## Done when

- The human's verdict on the set is recorded in their words.
- Every finding has a disposition, and the root brief's horizon note on
  post-checkpoint revision has been resolved or restated.

## Notes

HITL. The same proxy-labelling rule as checkpoint 1 applies. Include direct
rule entries, their model/snippet support and links to the grammar/railroad
reference in the reading route. Assess model-reading-k73's example-led
refinement as well as the model-first structure. For VS Code preview, open
the interface-language folder or workspace root first so sibling figures load.
Further correction runs require the human's direction at this checkpoint;
the bounded runs authorized on 2026-09-28 do not authorize an unattended loop.

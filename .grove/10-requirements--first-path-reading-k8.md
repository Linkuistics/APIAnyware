# first-path-reading-k8

## Goal

Run reader checkpoint 1 over the first path: the landing page,
*What a signature leaves unsaid*, the glossary, the three concept pages and
the tutorial. Establish, in the human's own words, what must change before the
reference and review guide are drafted.

## Context

- Documentation plan §8 (reader checkpoints) and §1 (outcomes):
  `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`.
- Task-file decision D2 of `reviewer-documentation-k3`, from its commit: the
  human is the only human reader and knows the domain. No cold readers are
  available.

## Work

1. **The proxy reader.** Launch one fresh-context model briefed as a language
   designer new to API binding. Give it only the pages under test and outcomes
   1–3 from the plan's §1, and ask it to attempt them while thinking aloud.
   Keep the transcript's findings in this leaf's decision log, labelled as a
   proxy. It is not evidence of human comprehension. This spends the session's
   one in-session reviewer allowance.
2. **The human's read.** Ask the human to read the same path as a reviewer.
   Give them the proxy's findings as prompts, not conclusions. Ask them to mark
   what helps, what hinders, and whether the path supports the review they
   want to make.
3. **Triage** every finding into one of:
   - a defect in a landed document: cut a correction run under that
     document's node, as the grove editorial procedure requires;
   - a change to a later document: edit its structure brief in the plan's §9;
   - a language question: add it to the register in `explanation/choices.md`;
   - no action, with the reason.

## Done when

- The human's own assessment of the first path is recorded in their words.
- Every proxy and human finding has one of the four dispositions above.
- The reference and review-guide structure briefs reflect anything the
  reading changed.

## Notes

HITL: this session needs the human present. If they are not, stop and say so.
Do not substitute the proxy for them.

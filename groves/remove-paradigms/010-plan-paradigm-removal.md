# 010-plan-paradigm-removal

**Kind:** planning

## Goal
Grill the true scope of "paradigm / binding-style" in the codebase, raise
the governing ADR on `main`, seed `CONTEXT.md` with the resolved terms,
and grow this grove into ordered work leaves.

## Context
- The brief chain (root `BRIEF.md`) is the mandate. Read it first.
- There is no prior ADR on `main` for this work. (A previous ADR-0005
  existed on a discarded `chez` worktree — it is gone; rewrite as needed.)
- There is no `CONTEXT.md` glossary yet at the repo root. This task
  should *create it* and append the terms it resolves, per
  `.claude/skills/grove/CONTEXT-FORMAT.md`.
- Prior context worth a quick read before grilling:
  - `docs/specs/2026-04-19-racket-oo-class-system-analysis.md`
  - `docs/specs/2026-05-22-racket-oo-completion-design.md`
  - `docs/adding-a-language-target.md`
  - The current shape of `apps/`, any `--style`/`BindingStyle` references,
    and the `racket-oo`-named directories/slugs.

## Done when
- `CONTEXT.md` exists at the repo root, seeded with at least: **paradigm**,
  **binding style**, **target**, plus any aliases-to-avoid uncovered
  during grilling (e.g. distinguishing "binding style" from "target").
- A new ADR in `docs/adr/` records the decision to retire the paradigm
  dimension repo-wide, the rationale, and the consequences (rename of
  `racket-oo → racket`, removal of `BindingStyle`, etc.). Numbered after
  the existing 0001–0003.
- The root `BRIEF.md` is updated to cite the new ADR under "Pointers".
- This leaf is replaced by a node directory `010-plan-paradigm-removal/`
  *only if* the planning itself needs to decompose; otherwise this
  planning task simply *completes* and grows sibling work nodes:
  - `020-rename-racket-oo/` (or similar) — the rename to `racket`
  - `030-remove-binding-style/` — purge `BindingStyle` enum + `--style`
    flag + conditional dispatch
  - `040-collapse-apps-oo/` — fold or delete the `apps/oo/` layer
  - `050-doc-updates/` — `docs/adding-a-language-target.md`, READMEs
  - `060-validation/` — pipeline + snapshot + smoke + sample-app
    verification on `main`
  Numbering and exact set are the planning task's call — the list above
  is a starting hypothesis, not a schema.
- Each new node has a `BRIEF.md` and at least one ordered starter leaf.

## Notes
- Run the grilling procedure (`.claude/skills/grove/grilling.md`) before
  committing to the decomposition above. The hypothesis nodes may be
  wrong; let grilling reshape them.
- Raise ADRs **sparingly** (`ADR-FORMAT.md`). The governing retirement
  decision warrants one; downstream micro-decisions probably do not
  unless they are hard-to-reverse or surprising.
- A PRD is **not** required here — this is internal cleanup, not a
  human-facing agreement point. Skip `docs/prd/` unless grilling
  surfaces a genuine stakeholder question.
- Commit: one focused commit for the planning output (ADR + glossary
  seed + tree growth + brief update).

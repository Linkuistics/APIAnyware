# reverse-gen-exemplar-k64

**Kind:** work

## Goal

Prove the **reverse-gen workflow** (ADR-0052 / node BRIEF D2′) on **one** app: LLM-generate
a target-independent **description/spec/PRD** for `hello-window` **from its existing,
VM-verified implementation(s)**, human-validated — the worked exemplar + template the rest
of the portfolio (and the AppSpec grove's format design) build on.

## Why this app, why now

- **hello-window** is the simplest app (complexity 1/7) and the canonical bundler/demo app
  — the lowest-risk place to shake out the workflow.
- The reverse-gen output is a **bootstrap artifact**: a reasonable markdown
  description/spec/PRD that *informs* the AppSpec grove's later "formal spec" format design
  (driving.md — bootstrap/research before the dependent design). It does **not** wait on
  AppSpec tooling; Claude Code subagents are the LLM-driven tooling now
  ([[llm_annotation_constraint]]).

## Approach (sketch — refine on pickup)

1. Read the existing impl(s) at `targets/<t>/app-implementations/macos/hello-window/`
   (racket is the richest; sbcl/chez/gerbil corroborate) + the current prose
   (`apps/macos/hello-window/docs/{spec,learnings,test-strategy}.md`).
2. LLM-generate (subagent) a **projection-free** description/spec/PRD detailed enough to
   *reliably replicate* the app in any language: behaviour, window layout, controls,
   actions, API surface exercised, app-kind (`gui-app`), patterns, observable outcomes,
   accessibility expectations (REFACTOR §15 concept list). Carry the structural facts
   (app-kind / patterns / display-name) as **prose** (D3 — no machine manifest).
3. **Human-validate** (the in-the-loop step — git diff is the review boundary, ADR-0050).
4. Home it under `apps/macos/hello-window/` in the format-flexible layout (do not finalize
   the global layout — that firms after the AppSpec grove; keep the bundler's `spec.md` H1
   read working).

## Out of scope (externalize)

- **No `#lang app-spec` scenario suite / forward-gen** — suites come from the AppSpec
  toolkit post-pause; this is reverse-gen of the *spec* only.
- **No other apps** — one exemplar; the remaining apps are later leaves once the workflow +
  format are proven.
- **No AppSpec-grove build / seeds / pause point** — the subsequent children.

## Done when

`hello-window` has a human-validated, projection-free, LLM-generated spec/PRD under
`apps/macos/hello-window/`, derived from its existing implementation; the reverse-gen
workflow (prompt/subagent shape) is legible enough to repeat per app and to hand to the
AppSpec grove as format input. Goldens/pipeline untouched (app-data + docs only). Commit
names `reverse-gen-exemplar-k64`.

## Notes

Reference: node `BRIEF.md` (D2′/D3/D5), ADR-0052, ADR-0050 (git-as-review-boundary);
`~/Development/AppSpec` (vocabulary + the eventual consumer of this spec); REFACTOR §15
(app-spec concept list), §34 (the LLM build-test-patch loop this spec must enable). After
this exemplar retires, the next child is **build the AppSpec grove** (toolkit seed/PRD +
init in `~/Development/AppSpec` + cross-grove seeds), then the **pause point**.

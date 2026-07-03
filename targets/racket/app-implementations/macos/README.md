# Apps for racket

Each subdirectory is a sample app implementation. Apps progress from simple to
complex.

## Before working on any app here

1. Read the app spec: `{{PROJECT}}/apps/macos/{app}/docs/spec.md`
2. Read app-universal learnings (if present): `{{PROJECT}}/apps/macos/{app}/docs/learnings.md`
3. Read the scenario suite + contracts: `{{PROJECT}}/apps/macos/{app}/scenarios/` (`#lang app-spec`) + `{{PROJECT}}/apps/macos/{app}/docs/{logging-contract,observable-state}.md`
4. Read matrix learnings: `{{PROJECT}}/generation/targets/racket/apps/{app}/learnings.md` (if it exists)
5. Check the target plan: `{{PROJECT}}/targets/racket/docs/design/2026-05-22-racket-oo-completion-design.md`
   and `{{PROJECT}}/process/plans/2026-05-22-racket-oo-completion.md`

## All GUI testing uses TestAnyware

Never run apps directly. See `{{PROJECT}}/semantic/docs/testing/general.md` for workflow.

# Apps for racket

Each subdirectory is a sample app implementation. Apps progress from simple to
complex.

## Before working on any app here

1. Read the app spec: `{{PROJECT}}/docs/apps/{app}/spec.md`
2. Read app-universal learnings: `{{PROJECT}}/docs/apps/{app}/learnings.md`
3. Read the test strategy: `{{PROJECT}}/docs/apps/{app}/test-strategy.md`
4. Read matrix learnings: `{{PROJECT}}/generation/targets/racket/apps/{app}/learnings.md` (if it exists)
5. Check the target plan: `{{PROJECT}}/generation/targets/racket/docs/design/2026-05-22-racket-oo-completion-design.md`
   and `{{PROJECT}}/docs/superpowers/plans/2026-05-22-racket-oo-completion.md`

## All GUI testing uses TestAnyware

Never run apps directly. See `{{PROJECT}}/docs/testing/general.md` for workflow.

# apps-layout-finalize-k84

**Kind:** work

## Goal

Finalize the `apps/macos/` per-app layout now that the AppSpec format has firmed
(D5 deferred exactly this until the toolkit settled what a "formal spec" is — it
now has: the hello-window shape, produced by the toolkit's three capability
workflows). Sweep every app dir to that shape and clear the residual ws7 TODOs.

## Context

The firmed shape (hello-window, k64–k74):
`docs/{spec,learnings,logging-contract,observable-state,run-results}.md` +
`scenarios/*.rkt` + `run-values.rkt`. By this leaf's turn the per-app leaves
(k77–k83) have populated each app; what remains is reconciliation:

- **`test-strategy.md` disposition** — the pre-AppSpec TestAnyware checklist is
  superseded by the scenario suites; retire or fold its residue into the spec
  (the ws7 mapping from the k62 Q4 finding: `test-strategy.md` → suite + human
  expected-behaviour).
- **Bundler display-name read** — k63 kept `spec.md` H1 deliberately (zero churn);
  decide keep vs repoint now the layout is final; all four bundlers must stay green.
- **hello-window marker drop** — k73/k74 confirmed the gui-app "keeps running"
  expectation on all four impls; drop the now-confirmed `(to confirm in-VM)`
  markers from `hello-window/scenarios/03-close-button-keeps-running.rkt` (ADR-0010
  D4 says a PASS licenses this).
- **`apps/macos/README.md`** — document the final layout; clear the ws7 TODO
  markers pinned by the skeleton.

## Done when

Every `apps/macos/<app>/` dir follows the documented layout; the README documents it
and carries no stale ws7 TODOs; the bundlers build green against whatever
display-name read was decided. Commit names `apps-layout-finalize-k84`.

## Notes

Deliberately sequenced after the per-app leaves so finalization sees the full
populated portfolio rather than guessing at it. If a per-app leaf already left an
app fully conformant, this leaf's per-app work is a no-op check.

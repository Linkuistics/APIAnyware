# apps/macos/ — common macOS app data

Per-app data for APIAnyware's common macOS applications: one directory per app, holding
that app's target-independent **AppSpec data** — a description/spec, the
(forward-generated-and-validated) scenario suite, and the contracts. Free of projection,
so the same data drives racket, chez, gerbil, sbcl, and future targets alike
(REFACTOR §15). The per-target **implementations** live under
`targets/<t>/app-implementations/macos/<app>/` (§16), VM-verified there; this tree holds
the spec they all realize, not the implementations.

## Consumed from the external AppSpec project (ADR-0052)

An app spec is **not** a grove-native `.apiw` entity — it is authored against, and run
by, the external **AppSpec** project (`~/Development/AppSpec`), the LLM-driven spec/test
toolkit that consumes this tree and drives a live macOS VM through TestAnyware. The
authoring model is **human-in-the-loop, LLM-driving** (ADR-0052, the ws5 philosophy of
ADR-0050 applied to apps):

1. **reverse-gen** — point at an app's existing implementation → LLM-generate the
   description/spec detailed enough to *reliably replicate* it (human-annotated);
2. **forward-gen** — LLM-synthesize scenario suites that *correlate with* the spec, from
   best-practice guidelines, attack-vectors, and patterns/anti-patterns
   (human-validated);
3. **run** — the AppSpec runner replays the suites against any implementation.

Grove-domain structural facts an app carries — its **app-kind** (ADR-0049 instance
side), the **pattern-kinds** it exercises, the **display-name** (the bundlers read it
from the description's first H1) — stay **prose** in the app's description until a
machine consumer needs them (no machine manifest yet; lazy).

## Per-app layout

The AppSpec format firmed on the hello-window shape (produced end-to-end by the toolkit's
three capabilities) and every app in the portfolio conforms to it. Each `apps/macos/<app>/`
directory holds:

**Required (present for every app):**

- `docs/spec.md` — the reverse-gen'd, projection-free description/spec. Its first H1 is the
  app **display name**, which the four bundlers read (see *Bundler read* below).
- `docs/logging-contract.md` — Contract: the structured `[tag] …` log every impl must emit.
- `docs/observable-state.md` — Contract: the AX/OCR-observable state every impl must expose.
  (The two contracts double as the **porting guide** for a new impl.)
- `docs/run-results.md` — the live-VM run record + durable per-app findings.
- `scenarios/NN-<behaviour>.rkt` — the forward-gen'd `#lang app-spec` suite, one file per
  verifiable behaviour.
- `run-values.rkt` — per-app run bindings (coordinates, bundle-id) resolved at run time.

**Optional (present only where an app needs it):**

- `docs/learnings.md` — app-universal discoveries not captured by the spec.
- `run-values-<impl>.rkt` — added when a specific impl's on-screen layout diverges.
- `fixtures/` — documents/pages the scenarios open.

So the invariant per-app shape is `docs/{spec,logging-contract,observable-state,run-results}.md`
+ `scenarios/` + `run-values.rkt`. The pre-AppSpec `test-strategy.md` TestAnyware checklists
are **retired** — the executable scenario suite (behaviour), `observable-state.md` (the
observable facts), and `run-results.md` (the human expected-behaviour record) supersede them.

### Bundler read

The four bundlers (`targets/<t>/tools/bundle-<t>`) read each app's display name from the
**first markdown H1 of `<app>/docs/spec.md`** — the single, settled source. Renaming or
moving that file is its own scoped change; until then `spec.md` stays the bundler input
(the finalized zero-churn decision, `apps-layout-finalize-k84`).

## Catalogue

`docs/_index.md` is the current app catalogue (the eight-app portfolio, pattern-kind coverage,
the settled roster edges, and the coverage tie-in); `docs/2026-04-16-sample-app-portfolio-design.md`
is the original design rationale (a dated record, superseded for status by the index). App specs
are produced by reverse-gen from the per-target implementations — see
`docs/reverse-gen-workflow.md` (worked exemplar: `hello-window/docs/spec.md`). The external
**AppSpec toolkit** that generalizes reverse-/forward-gen is seeded in
`docs/appspec-toolkit-seed.md`.

The eight apps — hello-window, ui-controls-gallery, pdfkit-viewer, scenekit-viewer,
mini-browser, note-editor, drawing-canvas, swift-native-probe — each carry a complete,
live-VM-verified suite (see each app's `docs/run-results.md`). **Per-target implementation +
VM-verify status is derived, not hand-maintained:** run `apianyware-conformance` (ws6), which
scans each target's `app-implementations/macos/` ports and their `bindings/macos/reports/`
evidence and cross-checks the authored conformance judgment against that derived reality.

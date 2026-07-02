# appspec-pdfkit-viewer-k78 — brief

## Goal

The full AppSpec cycle for **pdfkit-viewer** (the PDFKit document viewer): reverse-gen
the spec from the four VM-verified impls, instrument the impls to the contracts,
rebuild, forward-gen the scenario suite, and Tier-2 live-run all four impls. Third app
through the toolkit (after hello-window and ui-controls-gallery).

## Context

- **hello-window is the worked template** (k64/k67–k74); **ui-controls-gallery
  (`appspec-ui-controls-gallery-k77`) is the richer precedent** — apply its promoted
  outcomes (parent brief "ui-controls-gallery outcomes"): per-impl geometry practice
  (measure from `agent snapshot --mode layout`, two-launch determinism diff, per-impl
  `run-values-<impl>.rkt` only where layouts diverge), the two Tier-2-only defect
  classes (launch presentation; ambiguous layout — nested containers in a stack must
  be stack views), full-suite-reliable runner (AppSpec `46fec5b` + `f2b8b76`), and the
  post-failure delayed-truncate adjudication (solo re-run, workflow §3).
- Drive via the AppSpec capability workflows:
  `~/Development/AppSpec/capabilities/{reverse-gen,forward-gen,run}/workflow.md`.
  Data homes **here** (ADR-0052; AppSpec ADR-0013): spec/contracts/scenarios under
  `apps/macos/pdfkit-viewer/`, impl instrumentation under
  `targets/<t>/app-implementations/macos/pdfkit-viewer/`.
- **App-specific: the PDF fixture.** The suite needs a PDF the app can load
  deterministically — fixtures are lazy + assertable (ws4 D3); home it with the app's
  scenarios (`apps/macos/pdfkit-viewer/`), never in the toolkit (no app data in
  AppSpec). Document-open + page-navigation are the behavioural core; observable
  state captures loaded-document title/page-count, not pixel contents.
- **Decomposed on entry (2026-07-02)** — per-stage children, materialized lazily
  (grow the next as each retires; stages may merge where they genuinely fit one
  session):
  1. **`reverse-gen-k95`** ✅ *(done 2026-07-02)* — the projection-free spec from the
     four impls (replaced the precursor `docs/spec.md`), via the AppSpec reverse-gen
     workflow. Key handoff: **no impl ships a document** — the open panel is the only
     source; the suite provisions an N ≥ 3-page fixture and drives the out-of-process
     panel by keyboard (Cmd-Shift-G → path → Return ×2). AX enabled flags are the
     reliable nav-state signal (screenshots can catch pre-repaint frames).
  2. **`conformance-data-k96`** ✅ *(done 2026-07-02)* — `logging-contract.md` +
     `observable-state.md` at `apps/macos/pdfkit-viewer/docs/`. Event vocabulary:
     lifecycle triad + `[document] opened file="…" pages=N` / `page-changed page=n
     pages=N` (post-state; silent no-ops emit nothing; consumers never count
     page-changed events or assume ordering vs `opened`). Key finding: the
     nav-enabled-flag read is **runner-side only** (TestAnyware's snapshot carries
     per-element `enabled`; the AppSpec SDK transform + `expect-ax` drop it) — a
     small `expect-ax #:enabled?` addition to seed to the AppSpec backlog; until
     then the label + `[document]` events proxy the four flag assertions.
  3. **`instrument-builds-k97`** — per-impl events emitter + `.app` build (likely a
     node, one child per impl, as k88 was).
  4. **forward-gen-suite** — the scenario suite + `run-values.rkt` (+ the PDF fixture).
  5. **live-run** — Tier-2 live-run all four impls → `docs/run-results.md`
     (closes this node's Done-when).

## Done when

All four impls run the forward-gen suite green in a live VM ([[vm_verify_every_app]] —
CLI smoke never satisfies the done-bar); `docs/run-results.md` records the outcome
table + per-impl findings. Commits name the child handles.

## Notes

Document-open + page-navigation are the behavioural core; observable state should
capture the loaded-document title/page-count, not pixel contents.

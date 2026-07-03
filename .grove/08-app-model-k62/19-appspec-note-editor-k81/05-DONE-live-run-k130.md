# live-run-k130

**Kind:** work

## Goal

Tier-2 live-run the note-editor forward-gen suite (k129: 21 scenarios,
`apps/macos/note-editor/scenarios/`) against all four impls in the live VM, per
`~/Development/AppSpec/capabilities/run/workflow.md` — the mini-browser k121 stage.
Outcome table + per-impl findings → `apps/macos/note-editor/docs/run-results.md`.

## Context (handoffs from forward-gen-suite-k129)

- **Geometry is PROVISIONAL** (`run-values.rkt` header): every coordinate is
  spec-derived via the k120 projection (window (510,115) 900×632 assumed, toolbar
  centre-line fb y 175, editor point (741,447)). Measure per impl from
  `agent snapshot --mode layout`, two-launch determinism diff first; per-impl
  `run-values-<impl>.rkt` siblings only where layouts diverge (precedent: racket
  alone on compact-22px in pdfkit + mini-browser). The **alert-cancel** coordinates
  are the weakest projection — measure from the OPEN alert (scenekit open-menu
  precedent) before trusting scenarios 10/12.
- **Run-stage guest prep** (run-values.rkt "persistence story"): create
  `/tmp/note-editor/{fixtures,work}`; upload `fixtures/fixture-note.md`
  **byte-exact** (123 chars — scenario 08 binds `rendered chars=123`; a 122 red
  flags newline-stripping in transport or the impl's read) and `fixtures/locked.md`
  then `chmod 000` it in-guest (scenario 16); **`rm -rf work/ && mkdir -p work/`
  between scenarios** (scenario 07 asserts `#:absent?`; a leftover
  `work/untitled.md` raises the save panel's replace-confirmation, breaking the
  keyboard choreography of 05/06/09/18).
- **Provisional choreography to firm** (adjudicate, then correct the suite or the
  contracts): Go-to-Folder **inside the save sheet** (Cmd-Shift-G — firmed only for
  the open panel, k103); the sheet-up OCR cue `untitled` (gates 05/06/09/17/18);
  Escape-cancels-the-**sheet** (07 — pdfkit firmed Escape on the open *panel*);
  the alert AX shape `AXWindow` titled `"alert"` + `Discard`/`Cancel` buttons
  (10/12/13); `/System` as a save target may be refused by the panel before the
  app's write runs (17 is recording — either outcome is a finding); editor
  `AXValue` fold-fidelity and WKWebView rendered-DOM exposure (k123 provisional
  rows — firm from raw snapshots during the run).
- **Scenario 02 is the k103 canary**: the placeholder-OCR recording pre-adjudicates
  the placeholder reads later scenarios use as their preview-emptied state witness
  (09/11/15/16/18). A red 02 with green `rendered` events = run-mechanism class,
  not impl defect. Recording set: 02, 04 (body-size OCR), 15 (undo/redo §9
  coupling — record grouping actuals), 16/17 (failure drivability), 20
  (quit-unsaved, flagged for human confirmation), 21 (close-button).
- **Known suite dispositions** (documented in the scenario comments; overrule by
  retagging if live evidence disagrees): the heading-render OCR rides hard
  scenario 03 last-positioned (firm `chars=7` event precedes); the sheet-prefill
  OCR gates hard scenario 05 (no other contract-stable cue exists).
- **Findings to fold into run-results.md** (doc-quality, feed regeneration): spec
  §15's driver guidance names a `--` flag-terminator the SDK's `gv-type` does not
  pass (leading-dash text undrivable; suites use the `*` §7.2 marker — the
  guidance line should name that alternative); the k123 observable-state
  round-trip sketch ("open the fixture → Save… to work/") contradicts §8.4 (an
  opened doc has a path → direct overwrite of the fixture) — the suite's 09
  realizes type → sheet-save → New → re-open instead.
- **Standing residuals to expect**: delayed-truncate empty-log red after a failure
  (adjudicate by solo re-run, workflow §3); the k121 type→click race is mitigated
  in-suite (every type settles on its final `rendered chars=N` line before any
  button click); Tahoe notification banner (dismiss by hover + close-X); menu-quit
  path only (SIGTERM ignored under `nsapplication-run`).
- Descriptors: `targets/<t>/app-implementations/macos/note-editor/note-editor-impl.rkt`
  (`com.linkuistics.note-editor-<impl>` at `/Applications/NoteEditor-<impl>.app`,
  env `NOTE_EDITOR_{EVENTS_LOG,TEST_CONFIG}`, defaults under `/tmp/note-editor/`).

## Done when

All four impls run the suite in the live VM with every red adjudicated (impl
defect / spec finding / run-mechanism — the k121 discipline);
`docs/run-results.md` records the outcome table + per-impl findings + firmed
provisional rows; suite/run-values corrections from measurement are committed.
Closes the k81 node's live-VM done-bar ([[vm_verify_every_app]]). Commits name
`live-run-k130`.

## Notes

The §9 undo/redo platform-coupling unknown is firmed here: scenario 15's
`dirty-changed`/`rendered` trace against the live run is the instrument (record
grouping actuals in run-results.md; a text-mutating Undo is expected to drive the
same notification path as typing).

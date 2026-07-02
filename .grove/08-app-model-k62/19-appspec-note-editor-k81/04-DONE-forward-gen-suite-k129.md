# forward-gen-suite-k129

**Kind:** work

## Goal

Forward-gen the note-editor `#lang app-spec` scenario suite + `run-values.rkt` +
the **file fixtures** from the k122 spec + k123 contracts, via the AppSpec
forward-gen workflow (`~/Development/AppSpec/capabilities/forward-gen/workflow.md`) —
the mini-browser k120 stage. Suite homes at `apps/macos/note-editor/scenarios/`.

## Context

- **Template:** the mini-browser suite (`apps/macos/mini-browser/scenarios/` +
  `run-values.rkt`, k120) and the pdfkit k102 exemplar rules (hard vs `recording:`
  cluster split, `;; spec:` per-assertion tracing, coverage-or-gap rule
  `AppSpec/capabilities/forward-gen/validation.md` L1b, two-run consensus for a suite
  gating four impls, presentation-settled `wait-for-log` probe before coordinate
  clicks).
- **Inputs:** `apps/macos/note-editor/docs/{spec,logging-contract,observable-state}.md`.
  The observable-state assertion → observation-path map is the suite's skeleton —
  every spec assertion verb-backed or a documented gap.
- **All four impls are instrumented + built** (k125–k128): the suite can assume the
  contract events (`[lifecycle] startup`, bare launch line beginning `Note Editor`,
  the six `[document]` events with fixed `path`·`dirty` key order, `[preview]
  rendered placeholder=<b> chars=<n>`, `shutdown reason=menu`) and the descriptors at
  `targets/<t>/app-implementations/macos/note-editor/note-editor-impl.rkt`
  (`com.linkuistics.note-editor-<impl>` at `/Applications/NoteEditor-<impl>.app`).
  Launch-line remainders diverge by design (`running.` ×3 vs sbcl `opened.`) — match
  the `Note Editor` prefix and the normalized log keys only; the visible failure
  `<detail>` diverges too (racket exn-message vs path) — assert the `Open failed: `/
  `Save failed: ` prefixes and exact-match the event's `path=` key instead.
- **The persistence story (k123) is the suite's new discipline:** fixtures + written
  files live under `/tmp/note-editor/{fixtures,work}`; every state-mutating scenario
  (save, open-after-save) carries the cleanup obligation; **Cmd-Shift-G with an
  absolute path neutralizes panel-remembered directories** (the k103 fixture rule —
  open-panel file cells are not in the AX tree). `expect-file`/`read-file` become
  live verbs for save assertions, cued by the `saved` event (hello-window 03's
  state-mutating precedent).
- **The first-save sheet vs subsequent-direct split** is the §8.4 core assertion: a
  `saved` with **no sheet interaction** witnesses the direct branch; the sheet branch's
  `saved` fires inside the completion handler — drive the sheet keyboard-first
  (Cmd-Shift-G → absolute path → Return, then Return for the default Save button —
  the sbcl VM-driving lesson; NSAlert Discard is also the default-button Return).
- **Contract rules the scenarios must respect:** never count events (per-keystroke
  `rendered` volume is expected — match the *final* state line driven to, e.g.
  `chars=7` after typing `# Hello`); within-operation order is deterministic
  (`dirty-changed` → `rendered` on first keystroke; `rendered` → `new`/`opened`
  mid-rule vs post-state; `saved` follows **no** render — never assert absence);
  silent no-ops (cancels, no-op undo/redo, window close, clean New/Open) emit
  nothing — their observables are the state channels; the §8.1 alert emits nothing
  (synchronous response to the runner's own click).
- **Dirty-state channels:** the window AX title is the dirty half
  (`Untitled — edited — Note Editor`, the title-bar AX signal the sbcl learnings
  confirmed legible); `dirty-changed` is the log half — both fire only on the
  clean→dirty flip.
- **Driver guidance from the precedents:** **settle after `type` before any button
  click** (the k121 racket type→click driver race — acutely relevant: every editing
  scenario types then clicks toolbar buttons); Return-submits are immune; prefer
  AX-exact (the value→AXTitle fold — the status label's channel, firmed at k80 ×4)
  over whole-screen OCR for deterministic strings; 11-pt OCR reads
  adjudicate-by-artifact (the k103 class); the editor pane's `AXValue` fold-fidelity
  and the WKWebView rendered-DOM exposure are k123 provisional rows to firm at
  live-run; Escape-for-Cancel on the alert (provisional); the Tahoe
  notification-banner gotcha.
- **Failure fixtures:** an unreadable file (`fixtures/locked.md`, mode 000) drives
  §8.5.6 `open-failed`; an unwritable path (e.g. under `/System`) drives §8.5.7
  `save-failed` — the failure events carry the **attempted** path + the unchanged
  dirty flag.
- **Geometry:** measure per impl from `agent snapshot --mode layout`; two-launch
  determinism diff before binding values; per-impl `run-values-<impl>.rkt` only where
  layouts diverge (precedent: racket alone on the compact-22px sibling in both pdfkit
  and mini-browser — expect the same split, but measure); the k120 spec-derived
  provisional-coordinate projection method is validated for provisional authoring.

## Done when

The suite + fixtures + run-values are committed under `apps/macos/note-editor/`,
validated per the forward-gen workflow (coverage-or-gap complete, two-run consensus
plan stated); the live-run leaf (grown next) executes it. Commits name
`forward-gen-suite-k129`.

## Notes

Undo/redo scenarios ride the §9 platform-coupling unknown: a text-mutating Undo is
expected to drive the same notification path as typing (`dirty-changed` when the flag
flips + `rendered`) — the live-run stage uses exactly those events to firm §9; suites
should assert the coupled events only where the spec marks them firm, else
`recording:`.

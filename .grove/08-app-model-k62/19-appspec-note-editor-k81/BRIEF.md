# appspec-note-editor-k81 — brief

## Goal

The full AppSpec cycle for **note-editor** (the Markdown editor with live WKWebView
preview — the text-editing + persistence app): reverse-gen the spec from the four
VM-verified impls, instrument to the contracts, rebuild, forward-gen the scenario
suite, Tier-2 live-run all four impls. Sixth app through the toolkit (after
hello-window, ui-controls-gallery, pdfkit-viewer, scenekit-viewer, mini-browser).

## Context

- **hello-window is the worked template** (k64/k67–k74); **the four richer precedents'
  promoted outcomes** (parent brief outcome sections k77/k78/k79/k80) apply: per-impl
  geometry practice (measure from `agent snapshot --mode layout`, two-launch
  determinism diff, per-impl `run-values-<impl>.rkt` only where layouts diverge; the
  spec-derived provisional-coordinate projection method validated by k80); the
  Tier-2-only defect classes (launch presentation; ambiguous layout — nested containers
  arranged in a stack must themselves carry intrinsic size); the OCR small-text
  run-mechanism class (prefer AX-exact via the value→AXTitle fold for deterministic
  strings; 11-pt OCR reads adjudicate-by-artifact) + delayed-truncate residual;
  **settle after `type` before any button click** (the k121 racket type→click driver
  race — acutely relevant here: every editing scenario types then clicks toolbar
  buttons); `acceptsFirstMouse` is control-dependent; menu-open-ending scenarios are
  safe (AppSpec `611f73c`); the Tahoe notification-banner gotcha; keyboard-driven
  panel drive (Cmd-Shift-G → absolute path → Return ×2, the k103 fixture rule) for
  NSOpenPanel/NSSavePanel paths.
- Drive via the AppSpec capability workflows:
  `~/Development/AppSpec/capabilities/{reverse-gen,forward-gen,run}/workflow.md`.
  Data homes **here** (ADR-0052; AppSpec ADR-0013): spec/contracts/scenarios under
  `apps/macos/note-editor/`, impl instrumentation under
  `targets/<t>/app-implementations/macos/note-editor/`.
- **App-specific: the first app with state-mutating persistence** — scenarios that
  create/edit/save notes mutate on-disk state (saved files, panel-remembered
  directories), so suite ordering + cleanup between scenarios matter (the
  `#lang app-spec` state-mutating discipline hello-window's scenario 03 established);
  `expect-file`/`read-file` become live verbs for save assertions. Editing behaviours
  the user called out — double-click, edit-in-place, empty state — are first-class
  expectations ([[sample_apps_perfect]]). The preview is a WKWebView driven by
  `loadHTMLString:` (no navigation, no network); the k80 WebKit learnings apply
  (WebKit corpus trampolines already relinked ×4 by k115; **gerbil**: importers of
  the webkit bindings need `(except-in … string-length)` — already recorded in the
  impl learnings). Save/Open panels are async/sheet-modal — completion-block and
  modal-session observability need contract log events to be assertable without
  races (the `[nav]`-channel precedent).
- **Decomposed on entry (2026-07-03)** — per-stage children mirroring
  `appspec-mini-browser-k80`, materialized lazily (grow the next as each retires;
  stages may merge where they genuinely fit one session):
  1. **`reverse-gen-k122`** ✅ *(done 2026-07-03)* — the projection-free spec from
     the four impls (replaced the precursor `docs/spec.md`), validated with zero
     witness discrepancies. Key handoffs: complexity corrected 6/7 → **3/7**;
     precursor over-claims cut (close-to-quit, in-template JS renderer, links,
     Cmd-Z shortcuts — **no Edit menu exists**, buttons are the only undo surface);
     standing common-mode facts — the unsaved guard covers **New/Open only**
     (quit/close silently discard, an explicit spec boundary), the text-change
     observer is never unregistered; file I/O is deliberately **target-native**
     (abstract read/write rule, no Cocoa call); launch-line prefixes diverge
     (`running.` ×3 vs sbcl `opened.`); **NO per-operation log lines exist** —
     status label is the sole message surface, preview render completion
     unobservable; failure `<detail>` diverges (racket exn-message vs path);
     dirty dot unobservable → window AX title is the channel; open-panel file
     cells not in the AX tree → Cmd-Shift-G.
  2. **`conformance-data-k123`** — the logging contract + observable-state doc.
  3. **instrument-builds** — per-impl instrumentation + rebuild ×4 (a node).
  4. **forward-gen-suite** — the scenario suite + fixtures + run-values.
  5. **live-run** — Tier-2 live-run all four impls → `docs/run-results.md`.

## Done when

All four impls run the forward-gen suite green in a live VM ([[vm_verify_every_app]] —
CLI smoke never satisfies the done-bar); `docs/run-results.md` records the outcome
table + per-impl findings. Commits name the child handles.

## Notes

Type-in-editor → live preview re-render, dirty-state tracking (`setDocumentEdited:` +
title suffix), Save… (NSSavePanel sheet + completion block, then direct writes),
Open… (NSOpenPanel), New-with-unsaved-changes NSAlert, and undo/redo are the
behavioural core; observable state captures the window title, status label, the
editor text, the preview render, and on-disk file contents — with panel drives
keyboard-driven and every mutation cleaned up between scenarios.

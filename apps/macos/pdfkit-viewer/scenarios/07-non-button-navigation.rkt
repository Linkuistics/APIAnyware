#lang app-spec
;; forward-generated from PDFKit Viewer §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: label tracks non-button navigation"
  #:description "When the user focuses the document area and pages by arrow key (Right — PDFView's conventional next-page key), then the label updates to page 2 — witnessing that the observer, not the buttons, drives the refresh (§7.1: the label stays correct however the page turns; §7.3: the notification observer runs the refresh). Provisional (§13 marks non-button navigation paths to confirm in-VM): a PASS confirms; a FAILURE is a spec-quality / key-handling finding, not a suite bug — in single-page-continuous mode an arrow press may scroll a sub-page distance instead of paging (the fixture page at fit-width is ~2x the viewport), in which case the live-run stage probes 'pagedown / 'end as the run-tuned realization of 'navigation the view itself handles' and the finding feeds back to reverse-gen. State-mutating flow: its own launch."

  ;; run: open-button-x/y — the Open… button's click coordinates; doc-area-x/y — a point inside the PDF
  ;; document area (the focus click); fixture-path — the in-VM fixture path. Bound at run time from the
  ;; per-app run-values config via current-run-values (ADR-0011); internal defines so they resolve at run
  ;; time, not at load (L1a).
  (define open-button-x (run-value 'open-button-x))
  (define open-button-y (run-value 'open-button-y))
  (define doc-area-x (run-value 'doc-area-x))
  (define doc-area-y (run-value 'doc-area-y))
  (define fixture-path (run-value 'fixture-path))

  ;; ── setup: the §13 fixture-rule open flow (as scenario 05, which asserts it in full) ──
  ;; spec: §13 — Launch diagnostic is emitted. (presentation-settled probe)
  (wait-for-log #rx"PDFKit Viewer")
  ;; spec: §13 — Empty state — label. (render-settled probe before the coordinate click)
  (wait-for-ocr "No PDF loaded")
  (click-at open-button-x open-button-y)
  (wait-for-ocr "Cancel")
  (chord '(cmd shift) 'g)
  (wait 1)
  (type fixture-path)
  (press 'return)
  (wait 1)
  (press 'return)
  ;; spec: (to confirm in-VM) — Open loads page 1. (the open-completed signal gating the key drive)
  (wait-for-log #px"\\[document\\] opened file=\"fixture\\.pdf\" pages=3")
  (wait-for-ocr "Page 1 of 3")

  ;; spec: (to confirm in-VM) — Label tracks non-button navigation. (focus the document area so the PDF
  ;; view receives the key event; at page 1 the click cannot itself turn a page)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y); a single click in PDFView neither
  ;; navigates nor edits (§12 — no app keyboard shortcuts of its own; selection needs a drag).
  (click-at doc-area-x doc-area-y)

  ;; spec: (to confirm in-VM) — Label tracks non-button navigation. (§13 names an arrow key; no toolbar
  ;; button is involved from here on)
  ;; harness: runner/harness-inputs.rkt — press takes a key symbol; "right" is in the driver keymap
  ;; (testanyware-rfb keymap.rs).
  (press 'right)

  ;; spec: (to confirm in-VM) — Label tracks non-button navigation. (the observer fires on the view's own
  ;; navigation: page=2 is fresh in this scenario's buffer — no button click ever logged it — so the event
  ;; match is discriminating; match the specific driven-to line, never a count.)
  ;; harness: runner/harness-logs.rkt — regexp.
  (wait-for-log #px"\\[document\\] page-changed page=2 pages=3")

  ;; spec: (to confirm in-VM) — Label tracks non-button navigation. (the changed label, per the §13 verb map)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls, absorbing repaint lag.
  (wait-for-ocr "Page 2 of 3"))

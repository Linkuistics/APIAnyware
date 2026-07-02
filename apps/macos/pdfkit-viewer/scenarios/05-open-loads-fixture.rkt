#lang app-spec
;; forward-generated from PDFKit Viewer §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: open loads the fixture at page 1"
  #:description "When the user opens the provisioned 3-page fixture through the keyboard-driven open panel (Cmd-Shift-G → path → Return ×2 — the panel is out-of-process, §11/§13 fixture rule), then the [document] opened event fires with the fixture's basename and page count, the label reads 'Page 1 of 3', and the fixture's PAGE 1 marker renders in the document area. Provisional (§13 marks open-loads-page-1 and first-page-renders to confirm in-VM): a PASS confirms; a FAILURE is a spec-quality / panel-driving finding, not a suite bug. State-mutating flow: its own launch, each step carrying its own-effect read."

  ;; run: open-button-x/y — the Open… button's click coordinates (framebuffer px); fixture-path — the in-VM
  ;; absolute path the run stage uploads fixtures/fixture.pdf to. All bound at run time from the per-app
  ;; run-values config via current-run-values (ADR-0011). Internal defines inside the scenario thunk so they
  ;; resolve at run time, not at load (validation L1a).
  (define open-button-x (run-value 'open-button-x))
  (define open-button-y (run-value 'open-button-y))
  (define fixture-path (run-value 'fixture-path))

  ;; spec: §13 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe for the click.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"PDFKit Viewer")

  ;; spec: §13 — Empty state — label. (Re-asserted as the render-settled probe before the coordinate click.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "No PDF loaded")

  ;; spec: (to confirm in-VM) — Open loads page 1. (activate Open… — the fixture-rule flow starts here)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at open-button-x open-button-y)

  ;; spec: (to confirm in-VM) — Open flow reaches the panel. (the panel must be up before the keyboard
  ;; drive; "Cancel" is its discriminating affordance — it appears nowhere in the app's own UI.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls, absorbing panel-present latency.
  (wait-for-ocr "Cancel")

  ;; spec: §13 fixture rule — the panel is out-of-process, so it is driven by keyboard: Cmd-Shift-G opens
  ;; the go-to-folder sheet.
  ;; harness: runner/harness-inputs.rkt — chord takes (list-of-modifier-symbols key).
  (chord '(cmd shift) 'g)

  ;; harness: runner/harness-state.rkt — (wait seconds); the go-to-folder sheet needs a beat to take key
  ;; focus before typing (out-of-process; no AX/OCR affordance of the sheet is contract-stable to poll on).
  (wait 1)

  ;; spec: §13 fixture rule — type the fixture's in-VM path. The panel canonicalizes paths (/tmp may come
  ;; back /private/tmp), which is why the opened-event match below uses only the BASENAME.
  ;; harness: runner/harness-inputs.rkt — (type text).
  (type fixture-path)

  ;; spec: §13 fixture rule — Return ×2: the first confirms the go-to-folder sheet (navigating the panel to
  ;; the fixture), the second activates the panel's default Open button on the selected file.
  ;; harness: runner/harness-inputs.rkt — press takes a key symbol.
  (press 'return)
  (wait 1)
  (press 'return)

  ;; spec: (to confirm in-VM) — Open loads page 1. (the [document] opened event is the reliable
  ;; open-completed signal — logging contract; exact-matches the fixture BASENAME and page count.)
  ;; harness: runner/harness-logs.rkt — regexp; the literal dot in the basename is escaped.
  (wait-for-log #px"\\[document\\] opened file=\"fixture\\.pdf\" pages=3")

  ;; spec: (to confirm in-VM) — Open loads page 1. (the §7.2 loaded-state label; N=3 is fixture truth, not
  ;; an impl-specific value.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls, absorbing the post-event repaint lag
  ;; (the label state and log events update before the repaint — spec §13).
  (wait-for-ocr "Page 1 of 3")

  ;; spec: (to confirm in-VM) — The first page renders. (the fixture's own page-1 marker becomes
  ;; OCR-readable — witnessing that rendering happened, never what it looks like; the marker sits in the
  ;; page's upper third so it is visible at fit-width zoom without scrolling.)
  ;; harness: runner/harness-observations.rkt — expect-ocr is a single-shot literal substring match;
  ;; case-sensitive, so the uppercase PAGE marker cannot be satisfied by the 'Page 1 of 3' label.
  (expect-ocr "PAGE 1")

  ;; spec: §12 — No window retitling on document load (a spec-stated exclusion: the title names the app,
  ;; not the document — §4). The AX exact-title read is the discriminating channel post-load (whole-screen
  ;; OCR is not — the menu bar also reads "PDFKit Viewer").
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "PDFKit Viewer"))

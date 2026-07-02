#lang app-spec
;; forward-generated from Mini Browser §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: fixture page body renders (OCR marker)"
  #:description
  "When the page-one fixture has finished loading, then its large ALL-CAPS body marker FIXTURE ONE is OCR-readable — witnessing that rendering happened, never what it looks like. recording: whether WKWebView-rendered text is OCR-observable under the driver is to confirm in-VM (the observable-state provisional row; §13 itself has no rendering line — a spec-quality finding for reverse-gen). A pass confirms the row (reverse-gen may add/harden a rendering line); a failure is a spec-quality / run-capability finding about rendered-text OCR, not a suite bug — the runner captures artifacts for review."

  ;; run: address-field-x/y — AX-reported centre of the address field (framebuffer px);
  ;; fixture-one-url — the file:// URL of the uploaded fixture page-one.html. Bound at run
  ;; time from the per-app run-values config (ADR-0011).
  (define addr-x (run-value 'address-field-x))
  (define addr-y (run-value 'address-field-y))
  (define fixture-one-url (run-value 'fixture-one-url))

  ;; ── §3-lifecycle-mandated setup (spec §13 preamble): dismiss the offline launch alert ──
  ;; spec: §13 — Network reality (preamble) — wait for the pre-dismissal cue.
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #px"\\[nav\\] failed" #:timeout 20.0)
  ;; spec: §13 — Network reality (preamble) — settle: let the modal run.
  (wait 1.0)
  ;; spec: §13 — Network reality (preamble) — dismiss the modal.
  (press 'return)
  ;; spec: §13 — Network reality (preamble) — settle after dismissal.
  (wait 0.5)

  ;; spec: §13 — Driver guidance — re-activation click after the dismissed modal (k112).
  (click-at addr-x addr-y)
  ;; spec: §13 — Driver guidance — break the click sequence so the triple-click starts fresh.
  (wait 1.0)

  ;; spec: (to confirm in-VM) — The fixture's body marker after a file:// load.
  ;; (triple-click = select-all)
  (click-at addr-x addr-y)
  ;; spec: (to confirm in-VM) — The fixture's body marker after a file:// load.
  (click-at addr-x addr-y)
  ;; spec: (to confirm in-VM) — The fixture's body marker after a file:// load.
  (click-at addr-x addr-y)
  ;; spec: (to confirm in-VM) — The fixture's body marker after a file:// load. (drive the load)
  (type fixture-one-url)
  ;; spec: (to confirm in-VM) — The fixture's body marker after a file:// load. (submit)
  (press 'return)
  ;; spec: (to confirm in-VM) — The fixture's body marker after a file:// load. (sync — the
  ;; driven load finishes)
  (wait-for-log #px"\\[nav\\] finished url=\"file:[^\"]*page-one\\.html\"" #:timeout 15.0)
  ;; spec: (to confirm in-VM) — The fixture's body marker after a file:// load. (finished is
  ;; post-state but the web view's repaint may lag — settle before the OCR read)
  (wait 1.0)
  ;; spec: (to confirm in-VM) — The fixture's body marker after a file:// load. (the marker
  ;; is 72px extra-bold dark-on-light — designed for exactly this probe)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "FIXTURE ONE" #:timeout 10.0))

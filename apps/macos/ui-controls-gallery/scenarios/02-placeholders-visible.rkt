#lang app-spec
;; forward-generated from UI Controls Gallery §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: placeholders are visible while the fields are empty"
  #:description "When the gallery is freshly launched and the two text fields are untouched, then the placeholder texts 'Type here' and 'Password' are readable on screen. Provisional (to confirm in-VM: greyed placeholder text may or may not OCR reliably): a PASS confirms the expectation and signals reverse-gen may drop the (to confirm in-VM) marker; a FAILURE is a spec-quality / OCR-capability finding for human review, not a suite bug (the runner captures the failure artifacts). Pure observation, but kept out of the hard cluster so a provisional failure cannot fail 01."

  ;; spec: §13 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe: the logging
  ;; contract emits the launch line only once the window is key+front, so a later OCR timeout means
  ;; placeholder-OCR failure, not a launch failure.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Controls Gallery")

  ;; spec: (to confirm in-VM) — Placeholders are visible while the fields are empty.
  ;; harness: runner/harness-observations.rkt — wait-for-ocr matches a literal substring and polls, absorbing
  ;; render latency. "Type here" is the stable substring of the §6 invariant placeholder "Type here..." (the
  ;; ellipsis is OCR-fragile and left out of the match).
  (wait-for-ocr "Type here")

  ;; spec: (to confirm in-VM) — Placeholders are visible while the fields are empty.
  ;; harness: runner/harness-observations.rkt — expect-ocr is a literal substring match.
  (expect-ocr "Password"))

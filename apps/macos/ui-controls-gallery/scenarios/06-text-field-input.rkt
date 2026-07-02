#lang app-spec
;; forward-generated from UI Controls Gallery §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: text field accepts typed input"
  #:description "When the user clicks the text field and types 'abc', then 'abc' becomes readable on screen. Provisional (to confirm in-VM): a PASS confirms and signals reverse-gen may drop the marker; a FAILURE is a spec-quality / OCR finding, not a suite bug. State-mutating: its own launch. (The secure field's non-echo counterpart is asserted nowhere — no in-set verb can express 'the AX value is not the cleartext'; a reported gap.)"

  ;; run: text-field-x / text-field-y — the text field's click coordinates (framebuffer px), bound at run time
  ;; from the per-app run-values config via current-run-values (ADR-0011). Window size and layout are
  ;; impl-varying (§4/§5), so the run stage may bind these per impl. Internal defines so they resolve at run time.
  (define text-field-x (run-value 'text-field-x))
  (define text-field-y (run-value 'text-field-y))

  ;; spec: §13 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe for the click below.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Controls Gallery")

  ;; spec: (to confirm in-VM) — Text field accepts input. (the click focuses the field)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at text-field-x text-field-y)

  ;; spec: (to confirm in-VM) — Text field accepts input.
  ;; harness: runner/harness-inputs.rkt — (type text). Never typed into the secure field (contract: field
  ;; contents are never logged; the secure field's non-echo assertion is a reported gap).
  (type "abc")

  ;; spec: (to confirm in-VM) — Text field accepts input.
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring, absorbing type/render latency.
  (wait-for-ocr "abc"))

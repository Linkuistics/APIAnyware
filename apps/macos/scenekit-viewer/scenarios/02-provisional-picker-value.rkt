#lang app-spec
;; forward-generated from SceneKit Viewer §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: provisional picker selected-value reads"
  #:description "When the viewer is at its post-launch steady state, then the geometry picker displays its first item 'Cube' — the platform's first-item default (the app never sets a selection, §5.1; the §12 'no explicit picker selection' exclusion) matching the initially displayed cube — readable by OCR and folded into the pop-up element's AXTitle (the SDK transform folds value->AXTitle; pdfkit firmed the fold for static text, not popups — observable-state role table: to confirm). Provisional (to confirm in-VM): a PASS confirms the first-item default and the popup value fold, so a regeneration may fold these reads into the hard cluster (01) and reverse-gen may drop the markers; a FAILURE is a spec-quality / role-mapping finding for human review, not a suite bug. Pure observations: shares no mutation."

  ;; spec: §13 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe: the logging
  ;; contract emits the launch line only once the window is key+front, so the reads below see the fully
  ;; presented window.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"SceneKit Viewer")

  ;; spec: (to confirm in-VM) — Picker present, first item selected. (the OCR half of the selected-value
  ;; read: a pop-up — pullsDown false — displays its current selection, expected 'Cube' by the platform
  ;; first-item default, §5.1.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Cube")

  ;; spec: (to confirm in-VM) — Picker present, first item selected. (the AX half: the popup's selected-item
  ;; value expected folded into AXTitle — the observable-state role table marks the popup value-fold
  ;; to-confirm.)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXPopUpButton #:title "Cube"))

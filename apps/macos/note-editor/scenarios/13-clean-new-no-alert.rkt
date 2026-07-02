#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "clean New shows no alert"
  #:description
  "When New is activated on a clean document, then §8.5.1 skips the confirmation entirely and the operation proceeds directly: [document] new fires (had an alert been raised instead, no event could fire and the wait would time out — the discriminating catch), no window titled 'alert' exists, and the status reads 'New document'. One boundary flow in its own launch."

  ;; run: new-button-x/y — click coordinates (framebuffer px). Bound at run time from the
  ;; per-app run-values config (ADR-0011).
  (define new-x (run-value 'new-button-x))
  (define new-y (run-value 'new-button-y))

  ;; spec: §15 — Boundary — clean New shows no alert. (presentation-settled probe)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  (wait-for-ocr "Undo")

  ;; spec: §15 — Boundary — clean New shows no alert. (activate New on the clean launch
  ;; document)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at new-x new-y)

  ;; spec: §15 — Boundary — clean New shows no alert. (the operation proceeded directly —
  ;; the post-state event is the primary witness: a raised alert would block the §8.2 rule
  ;; and this wait would time out)
  (wait-for-log #px"\\[document\\] new path=\"\" dirty=false" #:timeout 10.0)
  ;; spec: §15 — Boundary — clean New shows no alert. (no alert window exists — the
  ;; k80/k121-firmed shape keyed on the discriminating 'alert' window title; the app is
  ;; alive, so the snapshot is well-defined)
  ;; harness: runner/harness-observations.rkt — expect-no-ax asserts role(+title) absence.
  (expect-no-ax #:role 'AXWindow #:title "alert")
  ;; spec: §15 — Boundary — clean New shows no alert. (status — exact via the
  ;; value→AXTitle fold)
  (expect-ax #:role 'AXStaticText #:title "New document"))

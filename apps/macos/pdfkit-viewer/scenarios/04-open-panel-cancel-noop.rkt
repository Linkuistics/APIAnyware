#lang app-spec
;; forward-generated from PDFKit Viewer §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: open panel presents and cancel is a no-op"
  #:description "When the user clicks Open…, then the modal open panel presents (out-of-process on modern macOS — OCR is the presence probe, §11); when the user then cancels it with Escape, nothing changes — the empty-state label persists (§6 boundary: response ≠ OK is a silent no-op; also the §12 'no error dialog' exclusion). Provisional (both §13 lines are to-confirm-in-VM): a PASS confirms; a FAILURE is a spec-quality / panel-driving finding, not a suite bug. No `opened` event is expected on cancel and its ABSENCE is not asserted (silent no-ops emit nothing). State-mutating flow: its own launch, each step carrying its own-effect read."

  ;; run: open-button-x/y — the Open… button's click coordinates (framebuffer px), bound at run time from the
  ;; per-app run-values config via current-run-values (ADR-0011). Internal defines inside the scenario thunk
  ;; so they resolve at run time, not at load (validation L1a).
  (define open-button-x (run-value 'open-button-x))
  (define open-button-y (run-value 'open-button-y))

  ;; spec: §13 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe for the click.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"PDFKit Viewer")

  ;; spec: §13 — Empty state — label. (Re-asserted as the render-settled probe and the before-state of the
  ;; cancel-no-op pair below.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "No PDF loaded")

  ;; spec: (to confirm in-VM) — Open flow reaches the panel. (activate Open…)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y). The action handler blocks in
  ;; runModal (§6), but the click is delivered asynchronously so the driver is not blocked.
  (click-at open-button-x open-button-y)

  ;; spec: (to confirm in-VM) — Open flow reaches the panel. ("Cancel" is the panel's discriminating
  ;; affordance — it appears nowhere in the app's own UI, so its readability witnesses the panel.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls, absorbing the panel-present latency.
  (wait-for-ocr "Cancel")

  ;; spec: (to confirm in-VM) — Boundary — cancel is a no-op. (dismiss without confirming)
  ;; harness: runner/harness-inputs.rkt — press takes a key symbol; escape cancels the key panel.
  (press 'escape)

  ;; spec: (to confirm in-VM) — Boundary — cancel is a no-op. (the prior state stays displayed — §6 step 8.
  ;; Caveat for the live-run stage: the label sits in the top toolbar strip and may be readable even while
  ;; the centred panel is still dismissing, so this poll can pass early; the run stage may insert a settle
  ;; ((wait seconds)) before it — a run-capability tweak, not a §13 assertion.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "No PDF loaded"))

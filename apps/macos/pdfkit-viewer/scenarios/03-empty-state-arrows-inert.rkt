#lang app-spec
;; forward-generated from PDFKit Viewer §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "empty-state arrows are inert"
  #:description "When the user clicks the ◀ and ▶ arrow-button positions while no document is loaded, then nothing observable happens — the empty-state label 'No PDF loaded' persists (§7.4: with no document both buttons are disabled and clicking them does nothing observable). The direct enabled-flag read is the app's headline reported gap (runner-side: the SDK transform drops `enabled`); this scenario carries the behavioural half of the §13 empty-state line. State-mutating clicks isolated in their own launch, carrying only the persistence read that verifies their (non-)effect. No [document] event is expected and its ABSENCE is not asserted (logging contract: silent no-ops emit nothing — never a negative log read)."

  ;; run: prev-button-x/y, next-button-x/y — the arrow buttons' click coordinates (framebuffer px), bound at
  ;; run time from the per-app run-values config via current-run-values (ADR-0011). Internal defines inside
  ;; the scenario thunk so they resolve at run time, not at load (validation L1a).
  (define prev-button-x (run-value 'prev-button-x))
  (define prev-button-y (run-value 'prev-button-y))
  (define next-button-x (run-value 'next-button-x))
  (define next-button-y (run-value 'next-button-y))

  ;; spec: §13 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe for the
  ;; coordinate clicks below.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"PDFKit Viewer")

  ;; spec: §13 — Empty state — label. (Re-asserted as the render-settled probe: the label must be readable
  ;; BEFORE the clicks so the persistence read below is a genuine before/after pair.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "No PDF loaded")

  ;; spec: §13 — Empty state — navigation disabled. (behavioural half — click the disabled ◀ position)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at prev-button-x prev-button-y)

  ;; spec: §13 — Empty state — navigation disabled. (behavioural half — click the disabled ▶ position)
  (click-at next-button-x next-button-y)

  ;; spec: §13 — Empty state — navigation disabled. (the persisting empty state is the whole observable
  ;; effect: no document exists for the arrows to navigate, so the label cannot have changed.)
  ;; harness: runner/harness-observations.rkt — expect-ocr is a single-shot literal substring match.
  (expect-ocr "No PDF loaded"))

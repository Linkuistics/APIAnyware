#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: the placeholder is OCR-legible in the preview"
  #:description
  "When Note Editor has launched with an empty document, then the §7.1 placeholder 'Start typing Markdown on the left…' is expected to be OCR-readable in the preview pane. recording: spec §15 marks WKWebView OCR legibility (to confirm in-VM) — the ~16px gray-italic placeholder is this app's headline OCR unknown (riskier than mini-browser's 72px markers, the k103 small-text class) — anchored on §3 step 5 (the initial render precedes the window) and §7.1's fixed placeholder text; the firm app-side half (the rendered placeholder=true chars=0 hand-off) is asserted hard in scenario 01. A PASS confirms the channel and signals reverse-gen may drop the marker; a FAILURE is a run-mechanism/spec-quality finding, not an impl defect — and it pre-adjudicates every later scenario that reads the placeholder as its preview-emptied state witness (the New/undo/restart/open-failure flows), whose identical reads would red for the same reason. Pure observation isolated under the recording tag so the hard launch cluster stays free of the known-risk channel."

  ;; spec: §15 — Launch diagnostic is emitted. (presentation-settled probe — the line is
  ;; emitted once the window is key+front)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")

  ;; spec: (to confirm in-VM) — Placeholder shows in the preview. (the on-screen half —
  ;; WKWebView-rendered ~16px gray italic; ellipsis-free substring per the §15 driver
  ;; guidance; case-sensitive)
  (wait-for-ocr "Start typing Markdown" #:timeout 10.0))

#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "no strokes survive a relaunch"
  #:description "When a stroke exists and the app is killed and relaunched, then the canvas starts empty: strokes live in process memory only and are lost on quit (§13 — no persistence, no save/export). The post-restart proof is the cardinality channel: a Clear on the fresh instance records cleared count=0 — the flow's ONLY cleared line, so the match is discriminating (a persisted-and-restored stroke would make it count=1 and the wait would time out). The relaunch's own launch line is byte-identical to the first launch's, so the post-restart settle rides the live OCR channel, not the log (the accumulated-buffer rule — the note-editor 18 precedent). One lifecycle flow in its own launch."

  ;; run: bundle-id — from the impl descriptor (ADR-0011); canvas-point-x/y — a canvas-interior point;
  ;; clear-button-x/y — the Clear button. From the per-app run-values config; internal defines so they
  ;; resolve at run time, not at load (L1a).
  (define bundle-id (run-value 'bundle-id))
  (define canvas-point-x (run-value 'canvas-point-x))
  (define canvas-point-y (run-value 'canvas-point-y))
  (define clear-button-x (run-value 'clear-button-x))
  (define clear-button-y (run-value 'clear-button-y))

  ;; ── setup: give the pre-restart instance a stroke on record ──
  ;; spec: §14 — Launch diagnostic is emitted. (presentation-settled probe)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Drawing Canvas")
  ;; spec: §14 — Toolbar controls present. (render-settled probe before the coordinate click)
  (wait-for-ocr "Clear")
  ;; spec: §13 not-included — No persistence (strokes are lost on quit). (draw the stroke that must NOT
  ;; survive)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at canvas-point-x canvas-point-y)
  ;; spec: §13 not-included — No persistence (strokes are lost on quit). (the stroke is on record
  ;; pre-restart)
  (wait-for-log #px"\\[canvas\\] stroke-committed r=0 g=0 b=0 width=2 points=1\\b")

  ;; spec: §13 not-included — No persistence (strokes are lost on quit). (kill and relaunch — restart-impl!
  ;; is the driver's quit → relaunch → wait-ready sequence)
  ;; harness: runner/harness-state.rkt — (restart-impl!).
  (restart-impl!)
  ;; spec: §13 not-included — No persistence (strokes are lost on quit). (settle the fresh presentation)
  (wait 1)

  ;; spec: §13 not-included — No persistence (strokes are lost on quit). (the fresh instance is up)
  ;; harness: runner/harness-observations.rkt — #:running? defaults to #t.
  (expect-running-app bundle-id)
  ;; spec: §13 not-included — No persistence (strokes are lost on quit). (fresh-presentation settle on the
  ;; live screen — post-restart log probes are non-discriminating, the accumulated-buffer rule)
  (wait-for-ocr "Clear" #:timeout 10.0)

  ;; spec: §13 not-included — No persistence (strokes are lost on quit). (the fresh stroke set is EMPTY:
  ;; the flow's only cleared line must carry count=0)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at clear-button-x clear-button-y)
  ;; spec: §13 not-included — No persistence (strokes are lost on quit). (count=0 — a restored stroke would
  ;; land count=1 and time this wait out)
  ;; harness: runner/harness-logs.rkt — regexp; \\b guards the trailing integer.
  (wait-for-log #px"\\[canvas\\] cleared count=0\\b"))

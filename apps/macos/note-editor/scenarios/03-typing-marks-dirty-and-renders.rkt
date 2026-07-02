#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "typing marks the document dirty and the preview renders the heading"
  #:description
  "When '# Hello' is typed into the editor of a fresh document, then the clean→dirty flip fires ([document] dirty-changed dirty=true — the log half) and the window AX title takes the '— edited —' form (the state half), and the preview re-renders the heading: the final [preview] rendered placeholder=false chars=7 hand-off is logged and 'Hello' becomes OCR-readable in the right pane (h1-rendered large — the best OCR odds in the preview). One editing flow in its own launch, each read verifying this mutation's effect."

  ;; run: editor-click-x/y — a point inside the editor pane (framebuffer px); bound at run
  ;; time from the per-app run-values config (ADR-0011).
  (define editor-x (run-value 'editor-click-x))
  (define editor-y (run-value 'editor-click-y))

  ;; spec: §15 — Launch diagnostic is emitted. (re-asserted as the presentation-settled
  ;; probe before the coordinate click — the k102 rule; the line is emitted once the window
  ;; is key+front)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  ;; spec: §15 — Toolbar is present. (re-asserted as the render-settled probe)
  (wait-for-ocr "Undo")

  ;; spec: §15 — Typing marks the document dirty. (focus the editor — clicking past the
  ;; text end puts the insertion point at the end)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y), framebuffer px.
  (click-at editor-x editor-y)
  ;; spec: §15 — Typing marks the document dirty. (settle after the focus click)
  (wait 0.5)
  ;; spec: §15 — Typing marks the document dirty. (7 ASCII characters)
  (type "# Hello")

  ;; spec: §15 — Typing marks the document dirty. (the log half — §6.2 step 1 fires on the
  ;; clean→dirty flip only, path is empty on an Untitled document; logging contract)
  (wait-for-log #px"\\[document\\] dirty-changed path=\"\" dirty=true" #:timeout 10.0)
  ;; spec: §15 — The preview renders the heading. (the final hand-off line driven to —
  ;; chars=7 for '# Hello'; per-keystroke rendered volume is expected, the suite matches
  ;; the final state line, never counts; this doubles as the settle-after-type probe —
  ;; the k121 type→click race guidance — before any later read)
  (wait-for-log #px"\\[preview\\] rendered placeholder=false chars=7\\b" #:timeout 10.0)

  ;; spec: §15 — Typing marks the document dirty. (the state half — exact §6.1 dirty form,
  ;; real U+2014 em dashes; the window AX title is the dirty channel of record, never the
  ;; close-box dot)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "Untitled — edited — Note Editor")

  ;; spec: (to confirm in-VM) — The preview renders the heading. (settle for the repaint —
  ;; the rendered event witnesses the hand-off, not the pixels)
  (wait 0.5)
  ;; spec: (to confirm in-VM) — The preview renders the heading. ('Hello' rendered as an
  ;; h1 — large text, the designed OCR marker, the best odds of the k103 class; the editor
  ;; pane also echoes '# Hello', so this read witnesses 'the text is on screen' — the
  ;; rendered event above stays the firm render witness; a garble adjudicates by artifact)
  (wait-for-ocr "Hello" #:timeout 10.0))

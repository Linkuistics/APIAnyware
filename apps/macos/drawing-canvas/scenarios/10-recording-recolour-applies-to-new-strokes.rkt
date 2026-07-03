#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: live recolour applies to subsequent strokes only — the key behaviour"
  #:description "When the user draws a stroke, drives the colour panel's RGB fields to 0/128/255, re-keys the main window, and draws again — the panel still open — then the colour-changed action's success path stores the device fold r=0 g=150 b=255 (typed 0/128/255 lands post-fold as device (0,150,255), byte-identical across impls — k112/logging contract) and the SECOND stroke freezes that colour at its own mouse-down, while the FIRST stroke's committed tuple — already on record as 0/0/0 — never changes: §2's capture-at-mouse-down freeze, the spec's load-bearing behaviour, proven from the log pair. Drawing with the panel open also realizes the §13 no-modality exclusion. Provisional (§14 marks the line to confirm in-VM; the re-key choreography is to confirm at live-run): a PASS confirms the key behaviour's model half; both strokes' rendered colours are pixel-level — the screenshot artifact is that record (documented gap). A FAILURE is a driver-choreography / spec-quality finding, not a suite bug. Re-run caveat (k112): a no-change field commit does not re-fire the panel action, and the shared panel remembers its colour in per-app defaults — a re-run that finds the panel already at the driven colour may never emit color-changed; a run-stage/provisioning concern this recording surfaces, not a suite bug. State-mutating throughout: one launch, each mutation carrying its own-effect read."

  ;; run: canvas-point-x/y, canvas-point-2-x/y — two canvas points (k94 margins, clear of the open panel
  ;; frame); color-button-x/y — the Color… button; panel-sliders-tab-x/y — the panel toolbar's
  ;; sliders-mode tab (clicked for determinism: the shared panel remembers its last mode via user
  ;; defaults, so the launch mode is not contractual); panel-{red,green,blue}-field-x/y — the RGB value
  ;; fields, PER-IMPL: panel-interior geometry is measured live from the OPEN panel, never shared across
  ;; impls (k112 — racket's compact metrics shift the picker-pane fields); window-titlebar-x/y — a
  ;; title-bar point for the re-key click (no canvas mouse-down, no control side-effect — the documented
  ;; re-key rule). All framebuffer px, bound at run time from the per-app run-values config via
  ;; current-run-values (ADR-0011); internal defines so they resolve at run time, not at load (L1a).
  (define canvas-point-x (run-value 'canvas-point-x))
  (define canvas-point-y (run-value 'canvas-point-y))
  (define canvas-point-2-x (run-value 'canvas-point-2-x))
  (define canvas-point-2-y (run-value 'canvas-point-2-y))
  (define color-button-x (run-value 'color-button-x))
  (define color-button-y (run-value 'color-button-y))
  (define panel-sliders-tab-x (run-value 'panel-sliders-tab-x))
  (define panel-sliders-tab-y (run-value 'panel-sliders-tab-y))
  (define panel-red-field-x (run-value 'panel-red-field-x))
  (define panel-red-field-y (run-value 'panel-red-field-y))
  (define panel-green-field-x (run-value 'panel-green-field-x))
  (define panel-green-field-y (run-value 'panel-green-field-y))
  (define panel-blue-field-x (run-value 'panel-blue-field-x))
  (define panel-blue-field-y (run-value 'panel-blue-field-y))
  (define window-titlebar-x (run-value 'window-titlebar-x))
  (define window-titlebar-y (run-value 'window-titlebar-y))

  ;; spec: §14 — Launch diagnostic is emitted. (presentation-settled probe for the coordinate clicks)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Drawing Canvas")

  ;; spec: §14 — Toolbar controls present. (render-settled probe before the first coordinate click)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Color")

  ;; spec: (to confirm in-VM) — Live recolour of subsequent strokes — the key behaviour. (baseline: a
  ;; stroke in the launch colour BEFORE any pick — its committed tuple is the 'previously drawn strokes
  ;; keep their original colour' record)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at canvas-point-x canvas-point-y)

  ;; spec: (to confirm in-VM) — Live recolour of subsequent strokes — the key behaviour. (the baseline
  ;; black tuple on record; also the canvas click-delivery gate)
  ;; harness: runner/harness-logs.rkt — regexp; \\b guards the integers.
  (wait-for-log #px"\\[canvas\\] stroke-committed r=0 g=0 b=0 width=2 points=1\\b")

  ;; ── open the panel (asserted in full in 09) and reach the RGB sliders pane ──
  ;; spec: (to confirm in-VM) — Colour panel opens. (the panel-present gate for the drive below)
  (click-at color-button-x color-button-y)
  (wait-for-ocr "Colors")
  ;; spec: (to confirm in-VM) — Live recolour of subsequent strokes — the key behaviour. (select the
  ;; sliders pane explicitly — determinism over the panel's remembered mode; RGB kind was seeded at
  ;; provisioning, k112; the panel is key, so clicks inside it fire first-click. 'Blue' is the RGB pane's
  ;; slider label — the RGB-kind gate.)
  (click-at panel-sliders-tab-x panel-sliders-tab-y)
  (wait-for-ocr "Blue")

  ;; ── the typed RGB drive: 0 / 128 / 255 (small fields — type into them, never read them; k112) ──
  ;; spec: (to confirm in-VM) — Live recolour of subsequent strokes — the key behaviour. (red := 0;
  ;; ctrl-a/ctrl-k clears the field editor before typing; return commits and fires the action)
  ;; harness: runner/harness-inputs.rkt — chord takes (list-of-modifier-symbols key); type takes a string;
  ;; press takes a key symbol.
  (click-at panel-red-field-x panel-red-field-y)
  (chord '(ctrl) 'a)
  (chord '(ctrl) 'k)
  (type "0")
  (press 'return)
  ;; spec: (to confirm in-VM) — Live recolour of subsequent strokes — the key behaviour. (green := 128)
  (click-at panel-green-field-x panel-green-field-y)
  (chord '(ctrl) 'a)
  (chord '(ctrl) 'k)
  (type "128")
  (press 'return)
  ;; spec: (to confirm in-VM) — Live recolour of subsequent strokes — the key behaviour. (blue := 255)
  (click-at panel-blue-field-x panel-blue-field-y)
  (chord '(ctrl) 'a)
  (chord '(ctrl) 'k)
  (type "255")
  (press 'return)

  ;; spec: (to confirm in-VM) — Live recolour of subsequent strokes — the key behaviour. (the success-path
  ;; event, post device-RGB normalization and store — §8.1 steps 2-4; the fold is deterministic: typed
  ;; 0/128/255 lands as device r=0 g=150 b=255, byte-identical across impls — k112/logging contract.
  ;; Continuous wiring may emit many lines during the drive — the driven-to line is matched, never a count.)
  ;; harness: runner/harness-logs.rkt — regexp; \\b guards the trailing integer.
  (wait-for-log #px"\\[canvas\\] color-changed r=0 g=150 b=255\\b")

  ;; spec: (to confirm in-VM) — Live recolour of subsequent strokes — the key behaviour. (re-key the main
  ;; window via a TITLE-BAR click — no canvas mouse-down, no control side-effect: after the panel takes
  ;; key, the first main-window click may deliver, and on the canvas a delivered click would begin a stray
  ;; stroke — the documented re-key rule; choreography to confirm at live-run)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at window-titlebar-x window-titlebar-y)
  ;; harness: runner/harness-state.rkt — (wait seconds): settle the key-window handoff before the gesture.
  (wait 1)

  ;; spec: (to confirm in-VM) — Live recolour of subsequent strokes — the key behaviour. (a NEW stroke,
  ;; drawn while the panel is STILL OPEN)
  ;; spec: §13 not-included — No modality. (the panel is an independent window; drawing continues while it
  ;; is open — this click succeeding IS that exclusion realized)
  (click-at canvas-point-2-x canvas-point-2-y)

  ;; spec: (to confirm in-VM) — Live recolour of subsequent strokes — the key behaviour. (the freeze pair:
  ;; the new stroke carries the driven colour frozen at ITS mouse-down — width still 2, untouched — while
  ;; the baseline 0/0/0 committed line already on record proves previously drawn strokes keep their
  ;; original colour; both strokes' pixels ride the screenshot artifact)
  ;; harness: runner/harness-logs.rkt — regexp; fixed key order per the logging contract.
  (wait-for-log #px"\\[canvas\\] stroke-committed r=0 g=150 b=255 width=2 points=1\\b"))

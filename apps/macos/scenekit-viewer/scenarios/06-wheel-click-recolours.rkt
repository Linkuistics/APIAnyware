#lang app-spec
;; forward-generated from SceneKit Viewer §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: colour-wheel click recolours the app state"
  #:description "When the user clicks a point inside the open colour panel's colour wheel, then the panel sends its continuous action, the handler normalizes, stores, and applies the colour (§7.4), and the color-changed event lands — matched SHAPE-ONLY (r/g/b as bare integers): a wheel-clicked colour's folded values are unknowable. This is the app-state half of §13's live recolour; the rendered half (the shape visibly recolouring) is pixel-level — a documented gap. Provisional (§13: the continuous action fires reliably on a DRAG, which the closed verb set cannot express — single-CLICK delivery is the to-confirm): a PASS confirms click delivery suffices; a FAILURE is the documented no-drag-verb run-capability finding (the suite then degrades to the typed-field drive of 07 as the only colour path), not a suite bug. State-mutating flow: its own launch."

  ;; run: color-button-x/y — the colour button; panel-wheel-tab-x/y — the panel toolbar's colour-wheel mode
  ;; tab (clicked for determinism: the shared panel remembers its last mode via user defaults, so the
  ;; launch mode is not contractual — without this click a suite RE-run would find the sliders pane 07/08
  ;; left behind); wheel-point-x/y — a point inside the wheel, off-centre so the picked colour is saturated
  ;; and certain to differ from the panel's prior colour (a no-change pick might not fire the action). All
  ;; framebuffer px, bound at run time from the per-app run-values config via current-run-values
  ;; (ADR-0011); internal defines so they resolve at run time, not at load (L1a).
  (define color-button-x (run-value 'color-button-x))
  (define color-button-y (run-value 'color-button-y))
  (define panel-wheel-tab-x (run-value 'panel-wheel-tab-x))
  (define panel-wheel-tab-y (run-value 'panel-wheel-tab-y))
  (define wheel-point-x (run-value 'wheel-point-x))
  (define wheel-point-y (run-value 'wheel-point-y))

  ;; ── setup: open the colour panel (as scenario 05, which asserts it in full) ──
  ;; spec: §13 — Launch diagnostic is emitted. (presentation-settled probe)
  (wait-for-log #rx"SceneKit Viewer")
  ;; spec: §13 — Colour button present. (render-settled probe before the coordinate click)
  (wait-for-ocr "Colo")
  (click-at color-button-x color-button-y)
  ;; spec: (to confirm in-VM) — Colour panel opens. (the panel-present gate for the clicks below)
  (wait-for-ocr "Colors")

  ;; spec: (to confirm in-VM) — Live recolour. (select the wheel mode explicitly — determinism over the
  ;; panel's remembered mode; the panel is key, so clicks inside it fire first-click — the §13 two-click
  ;; guidance covers the APP window after the panel has taken key, not the panel itself)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at panel-wheel-tab-x panel-wheel-tab-y)
  ;; harness: runner/harness-state.rkt — (wait seconds): the mode switch has no contract-stable text to
  ;; poll on (the wheel pane is chrome-free), so a settle stands in.
  (wait 1)

  ;; spec: (to confirm in-VM) — Live recolour. (the wheel click — the app-state half's trigger)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at wheel-point-x wheel-point-y)

  ;; spec: (to confirm in-VM) — Live recolour. (the success-path event, post store+apply — logging
  ;; contract. SHAPE-ONLY matcher: the clicked colour's folded components are unknowable. Never count
  ;; events — continuous wiring may deliver one-or-more lines for a single click; one match suffices.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp; \\d+ matches the bare integers.
  (wait-for-log #px"\\[scene\\] color-changed r=\\d+ g=\\d+ b=\\d+"))

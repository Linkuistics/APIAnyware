#lang app-spec
;; forward-generated from SceneKit Viewer §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: dismissing the panel changes nothing"
  #:description "When the user closes the colour panel without a further pick after driving the colour to 0/128/255, then nothing changes — no code observes panel closure (§7.4 boundary), so the stored colour survives dismissal: a subsequent geometry swap's geometry-changed line still carries the driven colour's device fold r=0 g=150 b=255 (RECORDED ACTUALS, live-run-k112 — the panel's slider space is not device-RGB; typed 0/128/255 lands as (0,150,255), see scenario 07). No color-changed is expected on dismissal and its ABSENCE is never asserted (logging contract: silent no-ops emit nothing). The displayed-colour half is pixel-level — a documented gap; this is the behavioural (app-state) half. Provisional (§13 marks the boundary to confirm in-VM): a PASS confirms; a FAILURE is a spec-quality finding, not a suite bug. State-mutating flow: one launch shared by the sequential drive-dismiss-swap steps, each mutation carrying its own-effect read."

  ;; run: color-button-x/y, panel-sliders-tab-x/y, panel-{red,green,blue}-field-x/y — the typed-colour
  ;; drive (as scenario 07); panel-close-x/y — the panel's own close widget (⌘W is not used: it needs a
  ;; Close menu item the app is not required to have, §8); picker-x/y, sphere-item-x/y — the swap
  ;; (open-menu item position, stable from the fresh-launch Cube selection). All framebuffer px, bound at
  ;; run time from the per-app run-values config via current-run-values (ADR-0011); internal defines so
  ;; they resolve at run time, not at load (L1a).
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
  (define panel-close-x (run-value 'panel-close-x))
  (define panel-close-y (run-value 'panel-close-y))
  (define picker-x (run-value 'picker-x))
  (define picker-y (run-value 'picker-y))
  (define sphere-item-x (run-value 'sphere-item-x))
  (define sphere-item-y (run-value 'sphere-item-y))

  ;; ── setup: the typed-colour drive (as scenario 07, which asserts it in full) ──
  ;; spec: §13 — Launch diagnostic is emitted. (presentation-settled probe)
  (wait-for-log #rx"SceneKit Viewer")
  ;; spec: §13 — Colour button present. (render-settled probe before the coordinate click)
  (wait-for-ocr "Colo")
  (click-at color-button-x color-button-y)
  ;; spec: (to confirm in-VM) — Colour panel opens. (the panel-present gate)
  (wait-for-ocr "Colors")
  (click-at panel-sliders-tab-x panel-sliders-tab-y)
  ;; spec: (to confirm in-VM) — Colour persists across a swap — the key behaviour. (RGB-kind gate, as 07)
  (wait-for-ocr "Blue")
  (click-at panel-red-field-x panel-red-field-y)
  (chord '(ctrl) 'a)
  (chord '(ctrl) 'k)
  (type "0")
  (press 'return)
  (click-at panel-green-field-x panel-green-field-y)
  (chord '(ctrl) 'a)
  (chord '(ctrl) 'k)
  (type "128")
  (press 'return)
  (click-at panel-blue-field-x panel-blue-field-y)
  (chord '(ctrl) 'a)
  (chord '(ctrl) 'k)
  (type "255")
  (press 'return)
  ;; spec: (to confirm in-VM) — Live recolour. (the drive-landed gate: the known colour is stored+applied;
  ;; recorded actuals — typed 0/128/255 folds to device (0,150,255), see scenario 07)
  (wait-for-log #px"\\[scene\\] color-changed r=0 g=150 b=255")

  ;; spec: (to confirm in-VM) — Boundary — dismissing the panel changes nothing. (dismiss without a pick:
  ;; the panel is key, so its close widget fires first-click. No color-changed is expected from this and
  ;; its absence is NOT asserted — silent no-ops emit nothing, never a negative log read.)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at panel-close-x panel-close-y)
  ;; harness: runner/harness-state.rkt — (wait seconds): let the dismissal and key-window handoff settle —
  ;; with the panel gone the app's main window re-keys (in-process; the app never deactivated), so the
  ;; picker click below is expected to fire FIRST-click (the §13 two-click guidance covers the
  ;; panel-still-has-key case, which no longer holds; if that expectation is wrong the menu never opens and
  ;; the Torus gate below times out — a driver finding this recording surfaces).
  (wait 1)

  ;; spec: (to confirm in-VM) — Boundary — dismissing the panel changes nothing. (the post-dismiss swap)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at picker-x picker-y)
  ;; spec: (to confirm in-VM) — Picker menu lists the catalogue. (the open-menu gate for the item click)
  (wait-for-ocr "Torus")
  ;; spec: (to confirm in-VM) — Geometry swap tracks selection. (choose Sphere)
  (click-at sphere-item-x sphere-item-y)

  ;; spec: (to confirm in-VM) — Boundary — dismissing the panel changes nothing. (the assertion: the
  ;; post-dismiss swap still carries the driven colour — had dismissal reset or changed the stored colour,
  ;; this exact line could not land; recorded-actuals fold as the gate above)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp; match the specific driven-to line,
  ;; never a count.
  (wait-for-log #px"\\[scene\\] geometry-changed shape=\"Sphere\" r=0 g=150 b=255"))

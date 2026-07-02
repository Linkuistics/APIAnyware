#lang app-spec
;; forward-generated from SceneKit Viewer §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: colour persists across a geometry swap"
  #:description "When the user drives the colour to an exactly-known value by typing 0/128/255 into the panel's RGB slider fields and then swaps the geometry to Sphere, then the swap re-applies the stored colour to the fresh geometry's material (§7.1/§7.2 — SceneKit gives each new geometry a fresh default material) and the single geometry-changed line carries shape=\"Sphere\" with the driven r=0 g=128 b=255 — the app's load-bearing behaviour (§2), never resetting to white. Provisional (§13 marks the key behaviour to confirm in-VM; the typed drive's exactness is to-confirm — the panel's slider colour space -> device-RGB conversion may shift components, in which case the suite degrades to shape-level matchers and recorded actuals): a PASS confirms the key behaviour AND the exact-drive channel; a FAILURE is a spec-quality / drive-fidelity finding for human review, not a suite bug. State-mutating flow: one launch shared by the sequential drive-then-swap steps (the swap's precondition IS the driven colour), each mutation carrying its own-effect read."

  ;; run: color-button-x/y — the colour button; panel-sliders-tab-x/y — the panel toolbar's sliders mode
  ;; tab; panel-{red,green,blue}-field-x/y — the RGB slider text fields (bind from the panel's AX snapshot
  ;; while in RGB-sliders mode); picker-x/y — the geometry picker; sphere-item-x/y — the Sphere row in the
  ;; OPEN menu (stable: the swap departs from the fresh-launch Cube selection). All framebuffer px, bound
  ;; at run time from the per-app run-values config via current-run-values (ADR-0011); internal defines so
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
  (define picker-x (run-value 'picker-x))
  (define picker-y (run-value 'picker-y))
  (define sphere-item-x (run-value 'sphere-item-x))
  (define sphere-item-y (run-value 'sphere-item-y))

  ;; ── setup: open the colour panel (as scenario 05, which asserts it in full) ──
  ;; spec: §13 — Launch diagnostic is emitted. (presentation-settled probe)
  (wait-for-log #rx"SceneKit Viewer")
  ;; spec: §13 — Colour button present. (render-settled probe before the coordinate click)
  (wait-for-ocr "Colo")
  (click-at color-button-x color-button-y)
  ;; spec: (to confirm in-VM) — Colour panel opens. (the panel-present gate)
  (wait-for-ocr "Colors")

  ;; spec: (to confirm in-VM) — Colour persists across a swap — the key behaviour. (switch the panel to its
  ;; sliders mode so the RGB text fields exist; the panel is key, so panel clicks fire first-click)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at panel-sliders-tab-x panel-sliders-tab-y)
  ;; spec: (to confirm in-VM) — Colour persists across a swap — the key behaviour. ('Blue' is the RGB
  ;; sliders pane's slider label: its readability settles the pane swap AND gates on the RGB slider KIND
  ;; being active — the pane remembers its last kind via user defaults, and Gray/CMYK/HSB panes carry no
  ;; 'Blue' label, so a non-RGB default times out here cleanly as a run-stage finding (remedied by seeding
  ;; VM defaults or a regenerated kind-selection step — deliberately NOT emitted now: the kind pop-up's
  ;; item positions depend on its current selection, the same re-align trap as the picker).)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Blue")

  ;; spec: (to confirm in-VM) — Colour persists across a swap — the key behaviour. (drive the red field to
  ;; 0: click into it, clear with ctrl-a/ctrl-k — StandardKeyBinding line-start + kill-to-end, interpreted
  ;; by the field editor on the keyDown path independent of menus; ⌘A select-all is NOT usable — §8
  ;; mandates only the Quit item, and without an Edit menu the ⌘A key equivalent has no consumer — then
  ;; type the value and commit with return, firing the panel's action)
  ;; harness: runner/harness-inputs.rkt — chord takes (list-of-modifier-symbols key), not a flat form;
  ;; type takes a string; press takes a key symbol.
  (click-at panel-red-field-x panel-red-field-y)
  (chord '(ctrl) 'a)
  (chord '(ctrl) 'k)
  (type "0")
  (press 'return)

  ;; spec: (to confirm in-VM) — Colour persists across a swap — the key behaviour. (the green field → 128.
  ;; Each commit fires the continuous action with the field's new value and the other components' CURRENT
  ;; values — intermediate color-changed lines with mixed components are expected and never counted; only
  ;; the final driven-to line is matched. Logging contract.)
  (click-at panel-green-field-x panel-green-field-y)
  (chord '(ctrl) 'a)
  (chord '(ctrl) 'k)
  (type "128")
  (press 'return)

  ;; spec: (to confirm in-VM) — Colour persists across a swap — the key behaviour. (the blue field → 255)
  (click-at panel-blue-field-x panel-blue-field-y)
  (chord '(ctrl) 'a)
  (chord '(ctrl) 'k)
  (type "255")
  (press 'return)

  ;; spec: (to confirm in-VM) — Live recolour. (the exactly-driven colour is stored and applied — the §7.4
  ;; success path; this full-triple line lands once all three commits are in. The exact values are the
  ;; whole point: they make the persistence line below a single-line assertion — logging contract. A
  ;; colour-space shift at this read is the documented degrade-to-recorded-actuals finding.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp; brackets escaped, values literal.
  (wait-for-log #px"\\[scene\\] color-changed r=0 g=128 b=255")

  ;; spec: (to confirm in-VM) — Colour persists across a swap — the key behaviour. (now swap: the colour
  ;; panel has taken key, so per the §13 driver guidance the FIRST click on the app window only
  ;; re-activates it — the picker fires on the second click; the settle between the two keeps the pair from
  ;; registering as a double-click)
  ;; harness: runner/harness-inputs.rkt — click-at; runner/harness-state.rkt — (wait seconds).
  (click-at picker-x picker-y)
  (wait 1)
  (click-at picker-x picker-y)
  ;; spec: (to confirm in-VM) — Picker menu lists the catalogue. (the open-menu gate for the item click)
  (wait-for-ocr "Torus")
  ;; spec: (to confirm in-VM) — Geometry swap tracks selection. (choose Sphere — the swap that must NOT
  ;; lose the driven colour)
  (click-at sphere-item-x sphere-item-y)

  ;; spec: (to confirm in-VM) — Colour persists across a swap — the key behaviour. (THE assertion: the
  ;; swap's post-state event carries the driven colour folded into the same line — drive a known colour,
  ;; swap, match the folded values (logging contract). A white-reset regression — the fresh default
  ;; material without the §7.2 re-apply — would land r=255 g=255 b=255 and fail this match. The earlier
  ;; color-changed line cannot satisfy this matcher — the event name differs — so the match is
  ;; discriminating within this scenario's buffer; no earlier geometry-changed line exists (startup applies
  ;; the initial colour without emitting a scene event — logging contract).)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp; match the specific driven-to line,
  ;; never a count.
  (wait-for-log #px"\\[scene\\] geometry-changed shape=\"Sphere\" r=0 g=128 b=255"))

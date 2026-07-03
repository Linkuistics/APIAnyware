#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: dismissing the panel picks nothing"
  #:description "When the panel is driven to a known colour (typed 0/128/255 → device (0,150,255), the recorded-actuals fold) and then CLOSED without a further pick, then colour state is unchanged: no app code observes panel closure (§8.1 boundary), so a dot drawn after the dismissal still commits carrying r=0 g=150 b=255 — the positive form of 'picks nothing' (had dismissal reset or altered the stored colour, this exact frozen tuple could not land). No color-changed is expected on dismissal and its absence is never asserted (silent no-ops emit nothing — logging contract). The rendered colour is the artifact half — a documented gap. Recording (the §14 boundary is to-confirm and the flow rides the same provisional drive + re-key choreography as 10): a PASS confirms; a FAILURE is a spec-quality or choreography finding for human review, not a suite bug. Same k112 re-run caveat as 10 (a no-change field commit does not re-fire the action). State-mutating flow: one launch shared by the sequential drive→dismiss→draw steps, each mutation carrying its own-effect read."

  ;; run: color-button-x/y — the Color… button; panel-sliders-tab-x/y — the panel toolbar's sliders-mode
  ;; tab; panel-{red,green,blue}-field-x/y — the RGB sliders pane's value fields (per impl, measured from
  ;; the OPEN panel — k112); panel-close-x/y — the panel's own close widget (the panel is key, so it fires
  ;; first-click); window-titlebar-x/y — the re-key click point (chrome-free title-bar stretch, clear of
  ;; the traffic-light controls; side-effect-free whether or not the main window already re-keyed on panel
  ;; close); canvas-point-x/y — a canvas-interior point (the panel is closed by then, so no overlap
  ;; constraint). All framebuffer px from the per-app run-values config (ADR-0011); internal defines so
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
  (define window-titlebar-x (run-value 'window-titlebar-x))
  (define window-titlebar-y (run-value 'window-titlebar-y))
  (define canvas-point-x (run-value 'canvas-point-x))
  (define canvas-point-y (run-value 'canvas-point-y))

  ;; ── setup: open the panel and drive the known colour (as 09/10, which assert these steps in full) ──
  ;; spec: §14 — Launch diagnostic is emitted. (presentation-settled probe)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Drawing Canvas")
  ;; spec: §14 — Toolbar controls present. (render-settled probe before the coordinate clicks)
  (wait-for-ocr "Clear")
  ;; spec: (to confirm in-VM) — Colour panel opens. (setup — asserted in full in 09)
  (click-at color-button-x color-button-y)
  (wait-for-ocr "Colors")
  ;; spec: (to confirm in-VM) — Boundary — dismissing the panel picks nothing. (RGB sliders-pane gate,
  ;; provisioning-seeded — as 10)
  (click-at panel-sliders-tab-x panel-sliders-tab-y)
  (wait-for-ocr "Blue")
  ;; spec: (to confirm in-VM) — Boundary — dismissing the panel picks nothing. (the typed drive to the
  ;; known colour — the drive discipline is documented in 10)
  ;; harness: runner/harness-inputs.rkt — chord takes (list-of-modifier-symbols key).
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
  ;; spec: (to confirm in-VM) — Boundary — dismissing the panel picks nothing. (the drive-landed gate:
  ;; the known colour is stored — recorded-actuals fold, as 10)
  (wait-for-log #px"\\[canvas\\] color-changed r=0 g=150 b=255\\b")

  ;; spec: (to confirm in-VM) — Boundary — dismissing the panel picks nothing. (dismiss without a
  ;; pick — the panel is key, so its own close widget fires first-click; no [canvas] event is expected
  ;; from this and none is asserted — silent no-ops emit nothing)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at panel-close-x panel-close-y)
  ;; harness: runner/harness-state.rkt — (wait seconds): let the dismissal and key-window handoff settle
  ;; (in-process panel; the app never deactivated).
  (wait 1)
  ;; spec: (to confirm in-VM) — Boundary — dismissing the panel picks nothing. (defensive re-key via the
  ;; title bar — side-effect-free whether or not the main window already re-keyed on panel close; the
  ;; observable-state re-key rule)
  (click-at window-titlebar-x window-titlebar-y)
  (wait 1)

  ;; spec: (to confirm in-VM) — Boundary — dismissing the panel picks nothing. (draw after dismissal)
  (click-at canvas-point-x canvas-point-y)
  ;; spec: (to confirm in-VM) — Boundary — dismissing the panel picks nothing. (the frozen tuple still
  ;; carries the driven colour — no color-changed intervened, asserted in its positive form; a dismissal
  ;; that reset colour state would make this exact line unmatchable and the wait time out)
  ;; harness: runner/harness-logs.rkt — regexp; match the specific line, never a count.
  (wait-for-log #px"\\[canvas\\] stroke-committed r=0 g=150 b=255 width=2 points=1\\b"))

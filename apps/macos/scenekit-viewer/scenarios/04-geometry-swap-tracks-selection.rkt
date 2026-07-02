#lang app-spec
;; forward-generated from SceneKit Viewer §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: geometry swap tracks the picker selection"
  #:description "When the user opens the geometry picker and chooses 'Sphere', then the swap handler assigns the catalogue sphere and re-applies the current colour — the [scene] geometry-changed event fires with shape=\"Sphere\" (post-state; logging contract), the picker's displayed value updates to 'Sphere', and the window title is NOT retitled (§12 exclusion). The event matcher is SHAPE-ONLY: no colour has been driven in this scenario and the initial colour's folded r/g/b values are OS/appearance-dependent — never assumed (logging contract). The rendered shape change itself is pixel-level — a documented gap, checked by eye at live-run. Provisional (§13 marks the line to confirm in-VM): a PASS confirms the swap flow, including the item click at its open-menu AX-snapshot position; a FAILURE is a spec-quality / menu-driving finding, not a suite bug. State-mutating: its own launch, carrying only the reads that verify its own effect."

  ;; run: picker-x/y — the geometry picker's click coordinates; sphere-item-x/y — the 'Sphere' item's
  ;; coordinates in the OPEN menu (read from the open menu's AX snapshot with 'Cube' current — the fresh-
  ;; launch state; a pop-up re-aligns its menu to the current selection, §13 driver guidance). All
  ;; framebuffer px, bound at run time from the per-app run-values config via current-run-values (ADR-0011).
  ;; Internal defines so they resolve at run time, not at load (validation L1a).
  (define picker-x (run-value 'picker-x))
  (define picker-y (run-value 'picker-y))
  (define sphere-item-x (run-value 'sphere-item-x))
  (define sphere-item-y (run-value 'sphere-item-y))

  ;; spec: §13 — Launch diagnostic is emitted. (presentation-settled probe)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"SceneKit Viewer")

  ;; spec: §13 — Colour button present. (Re-asserted as the render-settled probe on the strip's FIRM text —
  ;; the picker's 'Cube' display is to-confirm (02's subject); probing on it would couple this verdict to
  ;; 02's finding.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Colo")

  ;; spec: (to confirm in-VM) — Geometry swap tracks selection. (open the picker's menu; window is key at
  ;; launch so the first click delivers)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at picker-x picker-y)

  ;; spec: (to confirm in-VM) — Picker menu lists the catalogue. (menu-open probe: a non-selected title
  ;; witnesses the open menu before the item click below)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Torus")

  ;; spec: (to confirm in-VM) — Geometry swap tracks selection. (choose 'Sphere' at its open-menu
  ;; AX-snapshot position)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at sphere-item-x sphere-item-y)

  ;; spec: (to confirm in-VM) — Geometry swap tracks selection. (the discriminating assert: the post-state
  ;; geometry-changed event, SHAPE-ONLY — never the initial colour's folded values, and never a count or an
  ;; ordering; this scenario's buffer holds no prior geometry-changed line, so the match is fresh. Logging
  ;; contract.)
  ;; harness: runner/harness-logs.rkt — regexp; brackets and quotes escaped.
  (wait-for-log #px"\\[scene\\] geometry-changed shape=\"Sphere\"")

  ;; spec: (to confirm in-VM) — Geometry swap tracks selection. (the display half: the pop-up shows its new
  ;; selection, §5.1. Caveat for the live-run stage: 'Sphere' was momentarily readable in the dismissing
  ;; menu, so this poll can in principle pass on a stale frame — the event match above is the
  ;; discriminating assert; a settle before this read is a run-capability tweak, not a §13 assertion.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Sphere")

  ;; spec: §12 — No window retitling (a spec-stated exclusion: the title stays 'SceneKit Viewer' — §4). The
  ;; AX exact-title read is the discriminating channel post-mutation (whole-screen OCR is not — the menu
  ;; bar may also read the app name).
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "SceneKit Viewer"))

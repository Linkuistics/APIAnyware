#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).
;; Regenerated 2026-07-03 (canvas-ax-scope-k140): the whole-snapshot negative over-reached onto window
;; chrome at live-run (k139 red on all four impls); it now scopes to the app-under-test's window content
;; via the AppSpec #:scope 'app-content extension (AppSpec cb178f8), which drops the window's own title-bar
;; AXStaticText and foreign windows — the honest test of the canvas's AX-absence.

(scenario "recording: canvas exposes no content elements"
  #:description "When Drawing Canvas is at its post-launch steady state, then within the app-under-test's window content no static-text element exists — the canvas is an app-defined NSView with no accessibility configured (§6, the §13 'no accessibility configuration on the canvas' exclusion), strokes are pixels not elements (§12), and the toolbar band holds only the three controls with no text labels (§5.1), so the canvas region has zero AX children. The negative is scoped with #:scope 'app-content so it excludes what the canvas never produced but the whole snapshot would surface: the window's own title-bar AXStaticText (the platform exposes the window's accessibility title 'Drawing Canvas' as chrome — §12 line, an EXPECTED window property, not canvas content) and any other app's windows (e.g. desktop Notification Center widgets). The scope makes 'the canvas exposes no content elements' a discriminating assertion: a real static-text child of the app window (a §13 accessibility-configuration violation) still fails it, while window chrome no longer does. Pure observation: shares no mutation."

  ;; spec: §14 — Launch diagnostic is emitted. (presentation-settled probe)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Drawing Canvas")

  ;; spec: §12/§14 — Canvas exposes no content elements. (§14 names the observable: 'no static-text/child
  ;; element exists for the drawing surface'; AXStaticText is the concrete role the negative keys on.)
  ;; harness: runner/harness-observations.rkt — expect-no-ax matches #:role (+ optional exact #:title),
  ;; and #:scope 'app-content walks only the app-under-test's standard window, dropping the title-bar
  ;; chrome (the AXStaticText whose text equals the window's AXTitle) and foreign windows.
  (expect-no-ax #:role 'AXStaticText #:scope 'app-content))

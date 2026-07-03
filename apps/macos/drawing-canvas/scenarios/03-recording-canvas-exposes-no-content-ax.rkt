#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: canvas exposes no content elements"
  #:description "When Drawing Canvas is at its post-launch steady state, then no static-text element exists anywhere in the accessibility snapshot — the canvas is an app-defined NSView with no accessibility configured (§6, the §13 'no accessibility configuration on the canvas' exclusion), strokes are pixels not elements (§12), and the toolbar band holds only the three controls with no text labels (§5.1), so the whole-snapshot scope of expect-no-ax is expected clean. Provisional (§14 flags the line to confirm in-VM; observable-state marks the row provisional): a PASS confirms the canvas's AX invisibility and signals reverse-gen may drop the marker; a FAILURE is a spec-quality / snapshot-scope finding for human review (either the canvas grew AX content — a §13 violation — or platform chrome exposes static text the whole-snapshot negative trips on, and the run stage narrows the key), not a suite bug. Pure observation: shares no mutation."

  ;; spec: §14 — Launch diagnostic is emitted. (presentation-settled probe)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Drawing Canvas")

  ;; spec: (to confirm in-VM) — Canvas exposes no content elements. (§14 names the observable: 'no
  ;; static-text/child element exists for the drawing surface' — AXStaticText is the concrete role the
  ;; negative keys on; no title, so the whole tree must be free of it)
  ;; harness: runner/harness-observations.rkt — expect-no-ax matches #:role (+ optional exact #:title).
  (expect-no-ax #:role 'AXStaticText))

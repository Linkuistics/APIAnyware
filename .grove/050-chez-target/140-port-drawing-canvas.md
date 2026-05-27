# 140-port-drawing-canvas

**Kind:** work

## Goal
Port `drawing-canvas` to chez. First and only app with a **dynamic
NSView subclass** via `make-dynamic-subclass`. Validates the libobjc
`foreign-callable` IMP construction under real AppKit dispatch.

## Context
- `generation/targets/racket/apps/drawing-canvas/drawing-canvas.rkt`.
- `runtime/dispatch.sls`'s `make-dynamic-subclass` and `add-method!`
  surface (leaf 040).
- The IMP procedures **must remain reachable** for the lifetime of the
  subclass — Chez's `lock-object` is the mechanism. Confirm this
  during the leaf and document.

## Done when
- `drawing-canvas.sls` exists, bundles, launches, accepts mouse drags
  and draws strokes, redraws on resize, exits cleanly. TestAnyware run
  green.
- A long-running drag (drag → drag → drag for 30 seconds) shows no
  growth. The `drawRect:` and mouse-event IMPs are firing without
  leaking.
- Visual output matches the racket version (stroke colour, antialiasing,
  background).

## Notes
- Module-level binding for IMP procedures vs. `lock-object` — the
  racket dynamic-class.rkt mandates module-level; the chez `lock-object`
  story may relax that. Settle here.

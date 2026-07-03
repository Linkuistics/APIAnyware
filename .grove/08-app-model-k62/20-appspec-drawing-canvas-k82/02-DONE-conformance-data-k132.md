# conformance-data-k132

**Kind:** work

## Goal

Author the drawing-canvas **conformance data** — the logging contract
(`apps/macos/drawing-canvas/logging-contract.md`) + observable-state doc
(`apps/macos/drawing-canvas/observable-state.md`) — from the accepted spec (k131),
per the k123 (note-editor) precedent. These are the porting-guide contracts every
impl satisfies; the instrument child realizes them ×4.

## Context

- **The k131 handoff is the agenda:** the app emits **NO per-operation log lines**
  (stdout = the launch line only; strokes/colour/width/clear all silent) and the
  canvas is expected AX-invisible — stroke lifecycle + tool state need **contract
  log events** to be assertable at all. The scenekit `[scene]` channel is the mirror
  (unobservable content surface → events carry the state assertions).
- Candidate event vocabulary (settle module names + key order, the k123 discipline —
  fixed key order, post-state semantics, suites match final lines never counts):
  stroke lifecycle (begun/committed — beware per-point volume; the k123
  per-keystroke-volume precedent says high-frequency events are acceptable but
  suites must match final lines; consider `points=` count on commit instead of
  per-point lines), tool state (`color-changed r= g= b=` after the fold,
  `width-changed width=`), clear (`cleared count=`), and the launch-line prefix
  rule (`Drawing Canvas` prefix only — remainder diverges `running.` ×3 vs sbcl
  `opened.`, the standing rule).
- Two impls carry a stderr `colorChanged:` failure diagnostic (racket/chez), two
  don't — decide: contract-standardize or leave realization (k123 precedent: visible
  prefixes contracted only, failure detail via event keys).
- **Observable-state rows:** window AXTitle `Drawing Canvas`; `Color…`/`Clear`
  button AX rows (U+2026 in AXTitle — the k96 precedent); slider AX value/range;
  canvas = no content AX (provisional — confirm in-VM); NSColorPanel shape (k112
  rows: opens at (0,605) 250×397, RGB-kind seeding per impl at provisioning,
  racket's compact metrics reach inside the picker pane); screenshots as the sole
  canvas-content channel (visual bar = artifact review).
- Env-var/config conventions per the k123/k124 precedent
  (`DRAWING_CANVAS_EVENTS_LOG`, descriptor at
  `targets/<t>/app-implementations/macos/drawing-canvas/drawing-canvas-impl.rkt`,
  `com.linkuistics.drawing-canvas-<impl>` at `/Applications/DrawingCanvas-<impl>.app`)
  — declare in the contract; the instrument child realizes. No fixtures, no
  persistence → no between-scenario cleanup obligation (first app since
  hello-window without one).

## Done when

Both contract docs committed under `apps/macos/drawing-canvas/`; event vocabulary +
AX rows complete enough for the instrument child to code against and the forward-gen
child to assert against; provisional in-VM rows marked as such.

## Notes

Keep the contract minimal — events exist to make the spec's §14 assertions drivable
(stroke drawn/committed, tool state, clear), not to mirror internal state. The
capture-at-mouse-down freeze (spec §2/§7.1) is the key behaviour the events must
make provable without pixel comparison: a stroke-committed event carrying the
stroke's frozen `r= g= b= width= points=` proves both the freeze and the
subsequent-strokes-only rule directly from the log channel.

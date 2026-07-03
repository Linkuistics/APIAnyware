# chez-instrument-build-k135

**Kind:** work

## Goal

Instrument the chez drawing-canvas impl to the k132 contracts, build the `.app`, and
CLI-smoke it — mirror the k134 racket reference pattern via the chez house style
(the note-editor k126 twin: inline `dc-` emitter, startup + test-config no-op
top-level before `(main)`, terminate hook).

## Context

- Contracts: `apps/macos/drawing-canvas/docs/{logging-contract,observable-state}.md`;
  per-impl checklist at the logging contract's foot.
- Impl: `targets/chez/app-implementations/macos/drawing-canvas/`; the chez
  note-editor sibling carries the emitter/wiring house pattern to transplant.
- **k134 handoffs (the reference pattern):**
  - Emission points: `startup` before window/canvas construction (the R6RS body
    rule lands it for free); the five `[canvas]` events — `stroke-begun` at the
    end of the mouse-down override and `stroke-committed` at the end of the
    mouse-up override, each formatting the **stroke's own frozen**
    `r`/`g`/`b`/`width` (read from the stroke record, never the current tool
    state; capture the in-progress stroke *before* the flags clear, emit after),
    `committed` adding `points=<n>` (down + drags; release never appended);
    `width-changed` post-store in the slider action; `cleared count=<n>`
    captured pre-clear, emitted at rule end, ALWAYS (0 on empty);
    `color-changed` success-path-only post-store in the panel handler (the chez
    stderr `colorChanged:` guard stays off events.log). Fixed key orders; round
    once at emit (`× 255` / width, nearest integer, bare); launch line
    dual-emitted; `shutdown reason=menu` in the `applicationWillTerminate:`
    hook.
  - **Corpus half-done (k134): collect + resolve are shared and already done**
    (CoreGraphics collected, deps-together resolved with Foundation+AppKit).
    This child still needs the **per-target generate + relink**:
    `apianyware-generate --target chez` (expect a new `coregraphics/` dir), then
    `swift build --product APIAnywareChez` (never `--target`) — CG GROWS the
    trampoline table (racket went 175 → 221 by `grep -c @_cdecl`; the Generated
    sources are **gitignored**, so "git-clean" is vacuous — regenerate + relink
    is the operative verify, and relink must precede bundling, the k107 order
    rule). Goldens must not move.
  - Smoke bar: launch via `open` → `startup` → launch line in
    `/tmp/drawing-canvas/events.log`, AppleScript quit → `shutdown reason=menu`,
    no stray events. The `[canvas]` events are **not host-reachable** (every one
    needs a UI gesture) — witness by code audit against the checklist + an
    emitter isolation check; live-run exercises them.
- Descriptor `drawing-canvas-impl.rkt` sibling: `#:bundle-id
  com.linkuistics.drawing-canvas-chez`, `#:binary
  /Applications/DrawingCanvas-chez.app`, env vars
  `DRAWING_CANVAS_{EVENTS_LOG,TEST_CONFIG}`, fixed defaults under
  `/tmp/drawing-canvas/`.
- Launch-line remainder stays as realized (chez prints `Drawing Canvas running.
  Close window or Ctrl+C to exit.` — the prefix rule).

## Done when

Checklist satisfied for chez; `DrawingCanvas-chez.app` builds with
`CFBundleIdentifier com.linkuistics.drawing-canvas-chez`; CLI smoke green
(startup / launch line / shutdown reason=menu); learnings record any deviation.

## Notes

No visible-behaviour change — logging/plist/build plumbing only. The freeze
subtlety is the one emission trap: the stroke events format the stroke's own
captured components/width, so a post-gesture tool change can never leak in.

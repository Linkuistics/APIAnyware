# sbcl-instrument-build-k137

**Kind:** work

## Goal

Instrument the sbcl drawing-canvas impl to the k132 contracts, build the `.app`,
and CLI-smoke it — mirror the k134/k135/k136 reference pattern via the sbcl house
style (the note-editor k128 twin: a **separate pure-CL events file**
`events.lisp` beside the app; startup + test-config no-op before the app enters
`-run`; terminate-hook delegate). The last of the four impls — retiring this
leaf retires the `instrument-builds-k133` node.

## Context

- Contracts: `apps/macos/drawing-canvas/docs/{logging-contract,observable-state}.md`;
  per-impl checklist at the logging contract's foot.
- Impl: `targets/sbcl/app-implementations/macos/drawing-canvas/drawing-canvas.lisp`;
  the sbcl note-editor sibling (`note-editor/events.lisp` + its wiring) carries
  the emitter house pattern to transplant.
- **k134/k135/k136 handoffs (the reference pattern):**
  - Emission points: `startup` first record before window/canvas construction;
    the five `[canvas]` events — `stroke-begun` at the end of the mouse-down
    override and `stroke-committed` at the end of the mouse-up override, each
    formatting the **stroke's own frozen** `r`/`g`/`b`/`width` (read from the
    stroke record, never the current tool state; capture the in-progress stroke
    *before* the flags clear, emit after), `committed` adding `points=<n>`
    (down + drags; release never appended); `width-changed` post-store in the
    slider action; `cleared count=<n>` captured pre-clear, emitted at rule end,
    ALWAYS (0 on empty); `color-changed` success-path-only post-store in the
    panel handler (sbcl carries no stderr guard — no alignment needed, contract
    note). Fixed key orders; round once at emit (`× 255` / width, nearest
    integer, bare); launch line dual-emitted; `shutdown reason=menu` in the
    `applicationWillTerminate:` hook. Single-writer holds: sbcl's block bounce
    is a main-thread pass-through (ADR-0035/0036).
  - **Corpus: collect + resolve are shared and done (k134).** This child still
    needs the **per-target generate + relink**: `apianyware-generate --target
    sbcl` (expect a new `coregraphics/` binding dir; baseline verified — the
    current generated tree has none), then relink the adapter (`swift build
    --product APIAnywareSbcl`, never `--target`) BEFORE bundling — CG GROWS the
    trampoline table (racket, chez, and gerbil all went **175 → 221** by
    `grep -c @_cdecl`; sbcl's baseline is 175, the same twin expected; the
    Generated sources are gitignored, so "git-clean" is vacuous — regenerate +
    relink is the operative verify, the k107 order rule). Goldens must not move.
  - Emitter isolation check (k135/k136 practice): slice the emitter verbatim
    from the source (sbcl's is already a separate `events.lisp` — load it
    directly under host `sbcl`), drive it with the contract example values,
    diff byte-exact (incl. the k112 fold → `color-changed r=0 g=150 b=255` and
    the `width=11` rounding).
- **sbcl `build.sh` alignment (the k133-node finding, verified at k132):** today
  it writes the unsuffixed `com.linkuistics.drawing-canvas` and omits the
  kind-required `CFBundleInfoDictionaryVersion` — align to
  `com.linkuistics.drawing-canvas-sbcl` + add the key by **moving to the
  production bundler** (ADR-0041, the k128/k119 mirror), retiring any
  /tmp-staged wrap.
- Descriptor `drawing-canvas-impl.rkt` sibling: `#:bundle-id
  com.linkuistics.drawing-canvas-sbcl`, `#:binary
  /Applications/DrawingCanvas-sbcl.app`, env vars
  `DRAWING_CANVAS_{EVENTS_LOG,TEST_CONFIG}`, fixed defaults under
  `/tmp/drawing-canvas/`.
- Smoke bar: launch via `open` → `startup` → launch line in
  `/tmp/drawing-canvas/events.log`, AppleScript quit → `shutdown reason=menu`,
  no stray events, clean exit. The `[canvas]` events are **not host-reachable**
  (every one needs a UI gesture) — witness by code audit against the checklist
  + the emitter isolation check; live-run exercises them.
- Launch-line remainder stays as realized (sbcl prints `Drawing Canvas opened.
  Drag to draw; Color… changes the stroke colour, the slider its width, Clear
  empties the canvas. Quit with Cmd-Q.` — the prefix rule).

## Done when

Checklist satisfied for sbcl; `DrawingCanvas-sbcl.app` builds with
`CFBundleIdentifier com.linkuistics.drawing-canvas-sbcl` +
`CFBundleInfoDictionaryVersion`; CLI smoke green (startup / launch line /
shutdown reason=menu); learnings record any deviation. On retire, the k133 node
has no live leaf — confirm with the user, promote the node brief's durable
handoffs to the `appspec-drawing-canvas-k82` brief, and grow the
forward-gen-suite child there (the k82 stage-4 mirror).

## Notes

No visible-behaviour change — logging/plist/build plumbing only. The freeze
subtlety is the one emission trap: the stroke events format the stroke's own
captured components/width, so a post-gesture tool change can never leak in.

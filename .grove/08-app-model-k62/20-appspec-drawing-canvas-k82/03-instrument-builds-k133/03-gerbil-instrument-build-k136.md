# gerbil-instrument-build-k136

**Kind:** work

## Goal

Instrument the gerbil drawing-canvas impl to the k132 contracts, build the `.app`,
and CLI-smoke it — mirror the k134/k135 reference pattern via the gerbil house
style (the note-editor k127 twin: inline emitter on Gambit primitives only,
startup + test-config no-op top-level before `(main)`, terminate-hook delegate).

## Context

- Contracts: `apps/macos/drawing-canvas/docs/{logging-contract,observable-state}.md`;
  per-impl checklist at the logging contract's foot.
- Impl: `targets/gerbil/app-implementations/macos/drawing-canvas/drawing-canvas.ss`;
  the gerbil note-editor sibling carries the emitter/wiring house pattern to
  transplant (inline emitter rides the statically-linked prelude — no new import).
- **k134/k135 handoffs (the reference pattern):**
  - Emission points: `startup` before window/canvas construction (top-level
    before `(main)`, the def-initializers-evaluate-first rule); the five
    `[canvas]` events — `stroke-begun` at the end of the mouse-down override and
    `stroke-committed` at the end of the mouse-up override, each formatting the
    **stroke's own frozen** `r`/`g`/`b`/`width` (read from the stroke record,
    never the current tool state; capture the in-progress stroke *before* the
    flags clear, emit after), `committed` adding `points=<n>` (down + drags;
    release never appended); `width-changed` post-store in the slider action;
    `cleared count=<n>` captured pre-clear, emitted at rule end, ALWAYS (0 on
    empty); `color-changed` success-path-only post-store in the panel handler
    (gerbil carries no stderr guard — no alignment needed, contract note).
    Fixed key orders; round once at emit (`× 255` / width, nearest integer,
    bare); launch line dual-emitted; `shutdown reason=menu` in the
    `applicationWillTerminate:` hook.
  - **Corpus: collect + resolve are shared and done (k134).** This child still
    needs the **per-target generate + relink**: `apianyware-generate --target
    gerbil` (expect a new `coregraphics/` binding dir), then relink the adapter
    (`swift build --product APIAnywareGerbil`, never `--target`) BEFORE
    bundling — CG GROWS the trampoline table (racket and chez both went
    175 → 221 by `grep -c @_cdecl`; the Generated sources are gitignored, so
    "git-clean" is vacuous — regenerate + relink is the operative verify, the
    k107 order rule). Goldens must not move.
  - **Gerbil regen watch-outs:** the k127 `string-length` generics-shadow class
    — a regenerated binding module can export a generic that shadows a Gambit
    builtin the app module calls (fix by `(except-in … <name>)`, loss-free when
    the app never sends that selector); check the regenerated CG modules'
    exports against the app's imports. gcc-15 resolves on PATH today (Homebrew
    symlink → gcc-16); if a fresh box hits "gcc-15: command not found", the
    `/tmp/aw-gcc15-shim` symlink is the standing fix (ADR-0021 gotcha).
  - Smoke bar: launch via `open` → `startup` → launch line in
    `/tmp/drawing-canvas/events.log`, AppleScript quit → `shutdown reason=menu`,
    no stray events, clean exit. The `[canvas]` events are **not
    host-reachable** (every one needs a UI gesture) — witness by code audit
    against the checklist + an emitter isolation check; live-run exercises them.
- Descriptor `drawing-canvas-impl.rkt` sibling: `#:bundle-id
  com.linkuistics.drawing-canvas-gerbil`, `#:binary
  /Applications/DrawingCanvas-gerbil.app`, env vars
  `DRAWING_CANVAS_{EVENTS_LOG,TEST_CONFIG}`, fixed defaults under
  `/tmp/drawing-canvas/`.
- `build.sh` mirrors the gerbil note-editor k127 recipe (bundle default id →
  rename → PlistBuddy set the suffixed id → re-sign); expect the slow
  generics-shards + closure + exe-link pipeline (k127 warm timings: ~2/2/4.5 min).
- Launch-line remainder stays as realized (gerbil prints `Drawing Canvas
  running. Close window or Ctrl+C to exit.` — the prefix rule).

## Done when

Checklist satisfied for gerbil; `DrawingCanvas-gerbil.app` builds with
`CFBundleIdentifier com.linkuistics.drawing-canvas-gerbil`; CLI smoke green
(startup / launch line / shutdown reason=menu); learnings record any deviation.

## Notes

No visible-behaviour change — logging/plist/build plumbing only. The freeze
subtlety is the one emission trap: the stroke events format the stroke's own
captured components/width, so a post-gesture tool change can never leak in.

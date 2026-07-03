# instrument-builds-k133 — brief

**Kind:** node (decomposed on entry 2026-07-03 — one instrument+build child per impl,
the k106/k115/k124 split; racket first as the reference pattern, siblings mirror it;
children materialized lazily, grow the next as each retires)

## Children

1. `racket-instrument-build-k134` — the reference pattern (events.rkt + wiring +
   descriptor + self-contained build.sh; the note-editor k125 twin) **plus the
   CoreGraphics corpus step the siblings inherit** (see the corpus finding below).

## Corpus finding (2026-07-03, on decompose — revises the parent-brief expectation)

The parent brief's "no corpus step" expectation held for the **trampoline layer only**
(verified: `Trampolines.swift` git-clean, adapter dylib newer, 175 `@_cdecl` entries —
the k124 state). But **CoreGraphics is absent from the local partial corpus**
(Foundation+AppKit+PDFKit+SceneKit+WebKit): `platforms/macos/api/CoreGraphics/` does
not exist and no target's generated tree has a `coregraphics/` dir — drawing-canvas is
the first app since the refactor to need its direct CG C calls
(`CGContextMoveToPoint` …). So this node **owns a scenekit-k106-style corpus step**
(the k98/k107 twin): `SDKROOT=macosx apianyware-collect --only CoreGraphics` once
(the standing xcrun workaround), then deps-together `apianyware-analyze --only
Foundation,AppKit,CoreGraphics`, then per-target regenerate + relink-verify in each
child. Goldens must not move.

## Goal

Instrument the four drawing-canvas impls to the k132 contracts and rebuild each to a
launchable `.app`: the events.log emitter (`[lifecycle]`/`[canvas]` events per
`apps/macos/drawing-canvas/docs/logging-contract.md`), the `applicationWillTerminate:`
shutdown hook, test-config no-op handling, the impl descriptor, and a self-contained
`build.sh` — then CLI-smoke each on the host (startup → launch line → AppleScript quit
→ `shutdown reason=menu`).

## Context

- Contracts: `apps/macos/drawing-canvas/docs/{logging-contract,observable-state}.md`
  (k132); the conformance checklist at the contract's foot is the per-impl work list.
- Impls: `targets/<t>/app-implementations/macos/drawing-canvas/` (racket/chez/gerbil/
  sbcl, all VM-verified pre-instrumentation).
- **Emission points** (contract): `startup` first record before window/canvas
  construction; `stroke-begun` at the end of the §7.2 mouse-down rule and
  `stroke-committed` at the end of the mouse-up rule — each carrying the stroke's
  **frozen** `r`/`g`/`b`/`width` (device-RGB × 255 and width, both rounded to bare
  integers), `committed` adding `points=<n>`; `color-changed` success-path-only
  post-store; `width-changed` post-store; `cleared count=<n>` at the end of every
  Clear (`0` on empty — always emitted); `shutdown` in the terminate hook. **No
  per-drag-point events** (mouse-drag appends unlogged). Fixed key orders; keep the
  racket/chez stderr `colorChanged:` guards off events.log.
- **Host-reachability:** every `[canvas]` event needs a UI gesture (mouse on the
  canvas / panel / slider / Clear) — none is host-reachable, the k124 rule: the
  per-impl bar is **code-audit against the checklist + the lifecycle CLI smoke**;
  live-run exercises the rest.
- **Single-writer holds:** mouse overrides, action handlers, and the panel's
  continuous action are all main-thread (contract "Single writer"; sbcl's block
  bounce is a main-thread pass-through, ADR-0035/0036).
- **Trampoline expectation:** drawing-canvas's corpus is Foundation+AppKit(+direct
  CoreGraphics C calls) — no WebKit; the standing no-corpus-step expectation
  (confirmed ×4 at k124) is verify-not-regenerate: `Trampolines.swift` git-clean +
  adapter dylib newer ⇒ relink current.
- Env vars: `DRAWING_CANVAS_EVENTS_LOG` → `/tmp/drawing-canvas/events.log`;
  `DRAWING_CANVAS_TEST_CONFIG` → `/tmp/drawing-canvas/test-config.scm`. Descriptor at
  `targets/<t>/app-implementations/macos/drawing-canvas/drawing-canvas-impl.rkt`;
  bundle `com.linkuistics.drawing-canvas-<impl>` at
  `/Applications/DrawingCanvas-<impl>.app`.
- **sbcl `build.sh`:** align `CFBundleIdentifier` →
  `com.linkuistics.drawing-canvas-sbcl` + add `CFBundleInfoDictionaryVersion`
  (verified missing at k132; the k104/k114 mirror) — deliver by moving to the
  production bundler (ADR-0041, the k128/k119 mirror), retiring any /tmp-staged wrap.
- Prior-app patterns: the k125–k128 note-editor children (per-impl house styles:
  inline emitter — sbcl a separate pure-CL events file; startup + test-config no-op
  top-level before `(main)`; terminate-hook delegate). The shape transfers 1:1;
  drawing-canvas's new emission sites are the canvas subclass's three mouse overrides
  and the three action handlers.

## Done when

All four impls emit the full contract vocabulary (`[lifecycle]` witnessed by host CLI
smoke; `[canvas]` by code audit — not host-reachable), each bundles to a `.app` with
the suffixed bundle-id, and per-impl learnings record any deviation. Instrumentation
changes no visible behaviour.

## Notes

The freeze semantics are the emission subtlety: the stroke events format the
**stroke's own frozen** components/width (captured at its mouse-down), never the
current tool state at emit time — the whole point of the `committed` tuple is that it
can differ from the tool state after a mid-gesture… (not drivable) or post-gesture
tool change. Round once, at emit, from the stored doubles.

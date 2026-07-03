# racket-instrument-build-k134

**Kind:** work

## Goal

Instrument the **racket** drawing-canvas impl to the k132 contracts, build the
self-contained `.app`, and CLI-smoke it on the host — the reference pattern the three
sibling impls mirror (the note-editor k125 twin). Owns the **CoreGraphics corpus step**
the siblings inherit (the k98/k107 twin — see the node brief's corpus finding).

## Context

- Contracts: `apps/macos/drawing-canvas/docs/{logging-contract,observable-state}.md`;
  the conformance checklist at the logging contract's foot is the work list. Events:
  `[lifecycle] startup` / the bare launch line beginning `Drawing Canvas` (dual
  emission, keep stdout) / `[lifecycle] shutdown reason=<menu|signal|error>`; the five
  `[canvas]` events — `stroke-begun r= g= b= width=` at the end of the §7.2 mouse-down
  rule and `stroke-committed r= g= b= width= points=` at the end of the mouse-up rule,
  each formatting the **stroke's own frozen** components/width (device-RGB × 255 and
  width, both rounded to bare integers at emit from the stored doubles — never the
  current tool state); `color-changed r= g= b=` success-path-only post-store;
  `width-changed width=` post-store; `cleared count=<n>` at the end of every Clear
  (`0` on empty — always emitted). Fixed key orders; **no per-drag-point events**
  (mouse-drag appends unlogged); racket's stderr `colorChanged:` guard stays off
  events.log. Env vars `DRAWING_CANVAS_{EVENTS_LOG,TEST_CONFIG}`, fixed defaults under
  `/tmp/drawing-canvas/`.
- Impl (bare today — source + learnings only):
  `targets/racket/app-implementations/macos/drawing-canvas/drawing-canvas.rkt`. The
  emission sites map cleanly: the `define-objc-subclass` mouse overrides
  (`mouseDown:`/`mouseUp:` — read the frozen tuple from the **last stroke vector**,
  not the `current-*` bindings), the three `toolbar-target` handlers
  (`widthChanged:`/`clearCanvas:`/`colorChanged:`), and the additive app delegate
  (the impl installs none today).
- **Corpus step (owned here, siblings inherit):** CoreGraphics is absent from the
  local partial corpus — `SDKROOT=macosx apianyware-collect --only CoreGraphics` once,
  then deps-together `apianyware-analyze --only Foundation,AppKit,CoreGraphics`, then
  `apianyware-generate --target racket` + adapter relink-verify (`swift build` in
  `targets/racket/adapters/macos` if `Trampolines.swift` moved; today it is git-clean
  with the dylib newer, 175 entries). Goldens must not move.
- Reference pattern (note-editor k125): sibling `events.rkt` (path resolve /
  truncate-open line-buffered / quote-string / bare booleans) + top-of-module wiring
  (events-init! + startup before construction; test-config env no-op;
  uncaught-exception-handler → signal/error; app delegate → reason=menu) +
  self-contained `build.sh` (k76 bundler + post-mv PlistBuddy re-sign to
  `com.linkuistics.drawing-canvas-racket` / `DrawingCanvas-racket.app`; prereq keyed
  on `generated/coregraphics/functions.rkt`) + the `drawing-canvas-impl.rkt`
  descriptor (`#:binary /Applications/DrawingCanvas-racket.app`).
- Smoke (per-impl bar; VM bar stays with live-run): launch via `open`, observe in
  `/tmp/drawing-canvas/events.log` the launch sequence `startup` → the bare launch
  line, AppleScript quit → `shutdown reason=menu`, no stray events. The `[canvas]`
  events all need UI gestures — **not host-reachable** (the k124 rule); they are
  witnessed by code-audit against the checklist here and exercised for real at
  live-run.

## Done when

Checklist satisfied for racket; `DrawingCanvas-racket.app` builds with
`CFBundleIdentifier com.linkuistics.drawing-canvas-racket` and passes the
self-containment gate; CLI smoke green (startup / launch line / shutdown
reason=menu); learnings record the corpus-step deviation and any other finding.

## Notes

No visible-behaviour change (logging/plist/build plumbing only) — the launch-line
remainder stays as realized. The freeze subtlety: `stroke-begun`/`stroke-committed`
format the stroke vector's own captured `r`/`g`/`b`/`width` (rounded once, at emit),
so a mid-gesture or post-gesture tool change can never leak into a stroke's events.

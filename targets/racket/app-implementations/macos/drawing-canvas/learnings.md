# drawing-canvas x racket

**2026-07-03 (racket-instrument-build-k134) — AppSpec logging-contract instrumentation + self-contained build:**
- Instrumented to `apps/macos/drawing-canvas/docs/logging-contract.md` (k132):
  `events.rkt` (note-editor k125 template; the quote-string helper dropped — no
  event in this app carries a string value) + wiring — `[lifecycle] startup`
  before window/canvas construction, test-config env no-op, uncaught handler →
  signal/error, `applicationWillTerminate:` delegate → `shutdown reason=menu`,
  dual-emitted bare launch line, and the five `[canvas]` events: `stroke-begun`/
  `stroke-committed` in the mouse overrides post-state, `width-changed`/
  `cleared`/`color-changed` in the three toolbar handlers post-store
  (`color-changed` success-path only; the stderr `colorChanged:` guard stays
  off events.log).
- **Freeze semantics fall out of the data model:** the impl already captures
  colour/width into each stroke's vector at mouse-down, so both stroke events
  read the *stroke's own* `(vector-ref stroke 0..3)` — never the `current-*`
  tool state at emit time. `mouseUp:` captures `(last strokes)` before
  `end-stroke!` clears the flags (the finalized vector stays in `strokes`),
  emits after — post-state and frozen at once. Rounding lives once, in the
  emitter (`component->255`/`width->int`), so all events formatting the same
  stored double agree (the contract's freeze-proof property).
- **CoreGraphics corpus step (the k98/k107 twin — revises the parent brief's
  no-corpus-step expectation):** CoreGraphics was absent from the local partial
  corpus (first app since the refactor to need its direct CG C calls) —
  collected (`SDKROOT=macosx apianyware-collect --only CoreGraphics`, 8 classes)
  + deps-together resolve (`apianyware-analyze --only
  Foundation,AppKit,CoreGraphics`) + `apianyware-generate --target racket`
  (new `coregraphics/` dir, 12 files). Unlike SceneKit, **CoreGraphics GROWS
  the trampoline table** (175 → 221 by the standing `grep -c @_cdecl`
  convention; the generate log says 220 — the k125 off-by-one counting note
  applies): the CG Swift overlay has a bindable Swift-native residual. The
  typed dispatch regenerated too (615 entries) → adapter relink REQUIRED
  before bundling (the k107 generate → relink → bundle order rule, honoured).
  Goldens unmoved.
- **The "Trampolines.swift git-clean" verify is vacuous** — the Generated
  Swift sources (`sources/Generated/*.swift`) are *gitignored*, so git-clean is
  always true. The operative halves of the standing relink-current check are
  the dylib-newer-than-source mtime comparison and (when the corpus grows) an
  actual regenerate + relink. Siblings inherit the corpus step done here;
  their per-target generate + relink still applies.
- `build.sh` (note-editor k125 mirror): production bundler → rename →
  `com.linkuistics.drawing-canvas-racket` → re-sign → self-containment gate;
  prereq keys on `generated/coregraphics/functions.rkt` (the k99 rule).
  Descriptor `drawing-canvas-impl.rkt` authored. `DrawingCanvas-racket.app`
  86M, travels alone.
- CLI smoke green: exact launch sequence `[lifecycle] startup` → bare launch
  line; AppleScript quit → `shutdown reason=menu`; no stray events; clean
  process exit. The `[canvas]` events are not host-reachable (every one needs
  a UI gesture) — witnessed by code-audit against the checklist + the emitter
  isolation run (all contract example lines byte-exact, incl. the k112 device
  `(0,150,255)` fold → `color-changed r=0 g=150 b=255` and `width=11`
  rounding); live-run exercises them for real.
- Host-side `raco make` on the impl source cannot work (the `../../generated/`
  requires resolve only inside the bundler's staged tree) — the bundle step's
  `raco exe` is the compile gate, events.rkt verified in isolation.

**2026-06-02 (Racket 9.2 + ffi2, native dispatch) — first VM verification:**
- 🟢 Toolbar (Color… / brush-width slider / Clear) + empty canvas render correctly.
- 🟢 Live freehand drawing works: three mouse-drag strokes produced three smooth
  black lines — exercises `mouseDragged` event handling, the drawing path, and
  canvas redraw through generated AppKit/CoreGraphics bindings + native dispatch.
- TestAnyware VM (macOS 26.3).

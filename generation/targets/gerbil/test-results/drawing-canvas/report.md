# Drawing Canvas — Gerbil Test Report

**Date:** 2026-06-08
**Status:** PASS — third gerbil sample app; the **transparent-subclass showcase**
(ADR-0020). First app to drive a synthesized ObjC `NSView` subclass (`drawRect:`
+ three mouse overrides) under live AppKit dispatch, and first to compile/link
the **CoreGraphics** binding closure in a bundled standalone.

Done-bar for grove leaf `100-sample-apps/030-drawing-canvas`: the self-contained
`.app` built by `bundle-gerbil` **actually draws** in a macOS VM with **no Gerbil
installed** — drag paints smooth strokes, the Color panel changes stroke colour
live, the width slider changes thickness, Clear empties the canvas, a single
click paints a round dot. CLI smoke does not satisfy this
([[feedback-vm-verify-every-app]]).

## Build

`cargo run --example bundle_app -p apianyware-macos-bundle-gerbil -- drawing-canvas`.
Output: `…/apps/drawing-canvas/build/Drawing Canvas.app`, bundle id
`com.linkuistics.DrawingCanvas`, codesigned. `otool -L Contents/MacOS/drawing-canvas`
is dylib-clean — only system libs/frameworks (AppKit, **CoreGraphics**, Foundation,
libobjc, libSystem, libz, libsqlite3) plus the vendored
`@executable_path/../Frameworks/libssl.3.dylib` + `libcrypto.3.dylib` (ADR-0009);
the Gerbil/Gambit runtime is statically embedded (`gxc -exe` links `libgambit.a`).

Build time ~11.6 min cold (generics 35 shards 358s · facade 16s · 21 modules `-O`
78s · `-exe -O` link 317s). The per-app generics recompile (~5 min) is the known
non-amortised cost ([[project_gerbil_grove]]); CoreGraphics's 2,910-line
`functions.ss` is in the `-O` closure.

### Four toolchain/emitter/runtime bugs this app surfaced (all fixed at source)

drawing-canvas is the first app past the all-`objc_msgSend` `hello-window`/
`ui-controls` ceiling — it has a custom subclass, direct CoreGraphics C calls, and
a non-ASCII button title. Each exposed a latent defect:

1. **Cold-cache parallel-compile race** (`bundle-gerbil/compile.rs`). `gxc`'s
   per-module `create-directory` of the shared cache dir runs outside its build
   lock; against an empty cache all parallel shard workers race and one aborts
   (`*** ERROR IN __with-lock -- File exists`). `ui-controls` only won the race by
   timing. **Fix:** compile the first generics shard serially to warm the
   directory tree, then fan out the rest.

2. **CoreGraphics header vs synthesized-extern conflict** (`emit-gerbil`,
   `functions.ss`). ADR-0021 synthesizes `extern` prototypes to avoid ObjC
   umbrella headers, but CG geometry forces `#include <CoreGraphics/CGGeometry.h>`
   for struct layout — and that header's real prototypes *conflict* with the
   `void *` fallbacks the emitter synthesizes for ~9 functions whose types it
   can't model (`CGAffineTransformComponents`, `CFDictionaryRef`, `CGRect *`
   out-params, `CGRectEdge`). **Fix:** in `functions.ss` declare CG structs with
   self-contained inline typedefs (no header → no conflict); class modules keep
   the header (they synthesize no function prototypes, so nothing collides).
   Goldens re-blessed, gerbil bindings regenerated.

3. **Missing `-framework` on the closure-compile pass** (`bundle-gerbil/compile.rs`).
   `gxc -O` links each module's loadable `.oN`; class modules only reference
   `objc_msgSend` (`-lobjc`), but `functions.ss` makes **direct** CG C calls
   (`CGContextStrokePath` …), so the pre-compile link needs `-framework
   CoreGraphics` too — previously only the final `-exe` link got the frameworks.
   **Fix:** thread the framework link args into the `-O` closure pass.

4. **`char-string` can't carry non-ASCII** (`runtime/ffi.ss`). `string->nsstring`
   used Gambit's `char-string`, which marshals through the C locale (ISO-8859-1);
   the `…` in the "Color…" button title aborted with *"Can't convert to C
   char-string"* at launch (caught only by VM-verify, not the build).
   **Fix:** the three NSString-marshalling crossings now use Gambit's
   `UTF-8-string` — codepoint-exact for the full Unicode range.

One hand-written runtime addition was also needed: `point-x`/`point-y`
`define-c-lambda` accessors in `runtime/cocoa.ss` (the mouse handlers extract
x/y from the by-value `CGPoint` returned by `convertPoint:fromView:`).

## VM verify (no-Gerbil bar)

Golden `testanyware-golden-macos-tahoe`, arm64, macOS 26 (1024×768). Tarball
(11 MB) uploaded (md5-verified), `xattr -dr com.apple.quarantine`, launched via
`open -n`. No runtime errors in captured stdout/stderr after the UTF-8 fix.

Results (`drawing-canvas-initial.png`, `drawing-canvas-strokes-color-width.png`,
`drawing-canvas-clear-then-redraw.png`):

- [x] Window draws, titled **"Drawing Canvas"**, 640-wide resizable, centred,
      with the toolbar (Color… / width slider / Clear) pinned to the top edge and
      an empty white canvas below. The **"Color…" title renders its ellipsis**
      correctly (the UTF-8 fix).
- [x] **Menu-bar app name "Drawing Canvas"** with the standard About/Hide/Quit
      app menu (`install-standard-app-menu!`).
- [x] **Drag paints smooth strokes.** Two drags produced clean multi-point black
      polylines exactly along the drag paths — proving the synthesized
      `DrawingCanvasView` subclass's `mouseDown:`/`mouseDragged:`/`mouseUp:`
      overrides fire from live AppKit dispatch, `drawRect:` repaints, and the
      by-value `CGPoint` path (`locationInWindow` → `convertPoint:fromView:` →
      `point-x`/`point-y`) delivers correct coordinates. Smooth, not jagged.
- [x] **Single click paints a round dot.** A bare click rendered a filled disc
      (`kCGLineCapRound` on the coincident-point stroke), no special-case branch.
- [x] **Width slider changes thickness.** Dragging the slider knob ran
      `widthChanged:` (read `nscontrol-double-value`, set `current-width`); the
      next stroke painted markedly thicker. (`make-delegate` target-action bridge,
      ADR-0017.)
- [x] **Color panel changes stroke colour live.** Color… ran `openColor:`,
      opening the shared `NSColorPanel` with `target`/`action`/`continuous` set;
      picking red in the colour wheel fired `colorChanged:` (normalise to
      device-RGB via `colorUsingColorSpace:` + `deviceRGBColorSpace`, then
      red/green/blueComponent); subsequent strokes painted **red and thick**.
- [x] **Clear empties the canvas.** Clicking Clear ran `clearCanvas:`
      (`clear-strokes!` + `setNeedsDisplay:`); the canvas went blank, and a fresh
      stroke + dot drawn afterward confirmed the canvas stays live (and
      colour/width state persists).

The CoreGraphics rendering, the transparent-subclass IMP-trampoline callback path
(`drawRect:` with the undeliverable `CGRect` reduced to a `(self)` override), and
the `make-delegate` toolbar callbacks all survive whole-program `-O` in a
no-Gerbil VM.

See [[feedback-use-testanyware]], [[reference-testanyware-cli]],
[[feedback-sample-apps-perfect]].

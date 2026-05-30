# Drawing Canvas — Chez Test Report

**Date:** 2026-05-29
**Status:** Pass-with-fixes

> **Superseded by the standalone re-verification (2026-05-30) below.** The body
> describes the retired source-exec / precompile bundle. Under ADR-0009 chez apps
> ship as a self-contained open-world standalone binary. The standalone run found
> and fixed a **new whole-program-only bug** (the `(& NSRect)` IMP ftype was
> invisible in the sealed binary's interaction-environment) — see the dated
> section at the end. Source-exec-era caveats (menu-bar "chez", `brew install
> chezscheme`) are obsolete.

## Build & launch

- Dev-host bundle build: `cargo run --release --example bundle_app -p
  apianyware-macos-bundle-chez -- drawing-canvas` — **~150 s** (dominated by
  the `.sls` → `.so` precompile pass).
- Bundle size: **92 MB** (AppKit + CoreGraphics precompiled `.so` set; smaller
  than the WebKit apps since no WebKit/PDFKit).
- In-VM cold launch: window fully painted **≤ 4 s** after `open -n` (toolbar +
  blank canvas). Well inside the GUI-side band the delegate-trio established
  (≥ 10 s would be a regression).
- VM provisioning: the golden image (`testanyware-golden-macos-tahoe`) ships no
  Chez. As with the note-editor run, `brew` pours 10.3.0 which **cannot load**
  `.so` precompiled by the dev host's 10.4.1, so the run copied the host's
  relocatable 10.4.1 Cellar (3.5 MB tarball) into `/opt/homebrew/Cellar` and
  symlinked `/opt/homebrew/bin/chez`. The 43 MB app tarball was uploaded as
  eleven 4 MB chunks (the agent's single-upload cap returns HTTP 413 on a 43 MB
  payload) and md5-verified after reassembly.

## What this app is the first to exercise

`drawing-canvas` is the only chez sample with a **dynamic NSView subclass**.
`make-dynamic-subclass` (`runtime/dispatch.sls`) allocates `DrawingCanvasView`
at launch and installs four Scheme procedures as ObjC method IMPs —
`drawRect:`, `mouseDown:`, `mouseDragged:`, `mouseUp:`. AppKit then calls
*into* Scheme on its own schedule for the view's lifetime. Confirmed working:

- **IMP retention via `lock-object` + the runtime hashtable.** The IMP
  procedures are ordinary `letrec*` locals inside `main` (not module-level
  bindings as the racket `dynamic-class.rkt` mandates). `make-dynamic-subclass`
  `lock-object`s each `foreign-callable` code and stashes the handles in a
  process-lifetime hashtable; the runtime's callable table keeps the closures
  reachable. 1326 drags over 32 s fired the IMPs with no callable errors —
  the locked codes stayed live.
- **`(self _cmd arg …)` IMP convention** and the **by-value `(& NSRect)`**
  `drawRect:` parameter (resolved in the eval environment because the app
  imports `(apianyware runtime types)`).
- **CoreGraphics drawing inside `drawRect:`** — `CGContextMoveToPoint` /
  `AddLineToPoint` / `StrokePath` with round caps/joins, end to end.
- **Mouse-event coordinate transform** — `locationInWindow` →
  `convertPoint:fromView:` (`fromView=nil`).

## Issue found & fixed

### Issue 1: small by-value struct returns omitted Chez's hidden result-buffer arg
- **Category:** Binding bug (emit-chez emitter), plus the matching hand-written
  runtime helper.
- **Symptom:** every `mouseDown:` / `mouseDragged:` IMP raised
  `Exception: incorrect number of arguments 2 to
  #<procedure %msg-nsevent-location-in-window-getter>`, so no stroke ever
  drew (the IMPs fired but threw before touching state).
- **Root cause:** Chez's `foreign-procedure` exposes a `(& ftype)` *result*
  type through a hidden leading result-buffer argument — for **every** by-value
  struct return, regardless of size. Leaf 025 added that buffer only for
  structs > 16 bytes (NSRect, …), assuming ≤ 16-byte structs (NSPoint, NSSize,
  NSRange, CGVector) return in registers and need no buffer. That assumption is
  true of the C ABI but **not** of Chez's calling convention: a
  `(& NSPoint)`-returning `foreign-procedure` called with 2 args
  (`self`, `sel`) fails at runtime; it requires 3 (`buf`, `self`, `sel`).
  Empirically confirmed against `[NSEvent mouseLocation]`. `drawing-canvas` is
  the first app to call an NSPoint-returning getter under live dispatch, so the
  latent bug surfaced here.
- **Fix:**
  - `emit-chez/src/ffi_type_mapping.rs` — `return_needs_indirect_result` now
    flags **all** geometry struct returns (renamed `large_struct_return_ftype`
    → `struct_return_ftype`, extended to NSPoint/CGPoint, NSSize/CGSize,
    NSRange, CGVector). The wrapper now emits the `%result-buf` leading arg and
    returns the buffer for these too. The `foreign-procedure` *declaration* is
    unchanged (`(void* void*) (& NSPoint)`); only the call site changes. Test
    `small_struct_method_return_emits_indirect_result_buffer` updated to assert
    the new shape; regenerated all 284 frameworks.
  - `runtime/cocoa.sls` — `nsevent-location-in-window` (the hand-written
    helper) had the same 2-arg bug; now allocates the buffer and passes it
    leading.
- **Screenshots:** the failure produced a blank canvas; after the fix,
  `screenshot-002-strokes.png` onward.

## Steps Completed

- [x] **Launch + initial state.** 640×480 window titled `Drawing Canvas`;
      menu bar reads **Drawing Canvas** (bundler sets `CFBundleName`); toolbar
      = `Color…` / width slider (min) / `Clear`; blank canvas below.
      (screenshot-001-launch.png)
- [x] **Mouse drag → strokes.** Two diagonal drags render a smooth,
      antialiased black "X"; each drag is a multi-point `mouseDragged:` stroke
      with round caps/joins. (screenshot-002-strokes.png)
- [x] **Width slider (continuous target-action).** Moving the slider right then
      drawing yields a visibly thicker stroke; earlier strokes keep their
      captured 2 pt width (per-stroke width is correct). (screenshot-003-width.png)
- [x] **Color panel.** `Color…` opens the shared `NSColorPanel`; selecting red
      fires `colorChanged:` (continuous) → current RGB updates → the next
      stroke is red and thick. (screenshot-004-color.png)
- [x] **Clear.** `Clear` drops all strokes; canvas returns to blank.
      (screenshot-005-clear.png)
- [x] **Redraw on resize.** Enlarging the window re-anchors `Clear` to the
      right edge (MinXMargin), keeps `Color…`/slider pinned to the top
      (MinYMargin), grows the canvas, and `drawRect:` redraws the strokes
      bottom-left anchored (unflipped coords). (screenshot-006-resize.png)
- [x] **Leak / long-run.** 1326 drags over 32 s (far beyond human use),
      clearing periodically: RSS grew from **825 MB → 837 MB** during the
      burst and was **flat at 836.8 MB** across 24 s of subsequent idle — no
      ongoing leak. 0 callable errors throughout.
- [x] **Clean exit.** Cmd+Q quits the process cleanly (no error output).

## Visual parity

Matches the racket version: black antialiased strokes on the default white
canvas, round caps producing dot-on-click, per-stroke colour/width capture,
red after the colour-panel pick. Menu-bar app name is `Drawing Canvas` (better
than hello-window's `chez` note, same as note-editor — bundler sets
`CFBundleName`).

## Notes / candidate follow-ups

- **Per-call `foreign-alloc` in struct-return getters never freed.** The
  generated `(& ftype)` getters (and the cocoa helper) `foreign-alloc` a result
  buffer per call and return the ftype-pointer without freeing — a small
  unbounded accumulation under hot-path struct-return calls (here:
  `locationInWindow` + `convertPoint:` per mouse event, ~32 bytes/event;
  < 1 MB of the 32 s burst's growth, and flat at idle). This is a **target-wide
  concern** established by leaf 025 (not specific to drawing-canvas) and worth a
  follow-up — e.g. a per-thread scratch buffer for transient struct returns, or
  having callers free. Not blocking: behaviour is bounded and idle-flat,
  matching racket's effective bar.
- Two macOS "Software Update" / "What's New" notification banners appeared
  during testing — VM noise, unrelated to the app; visible in some screenshots.

---

## Standalone re-verification (2026-05-30, leaf `060/050/070`)

**Status: PASS (with a whole-program-only bug found + fixed).** Seventh and final
portfolio app — the **capstone**: a dynamic NSView subclass (`DrawingCanvasView`)
created at runtime via `make-dynamic-subclass`, with four Scheme-implemented IMPs
(`drawRect:`, `mouseDown:`, `mouseDragged:`, `mouseUp:`). The hardest test of the
embedded-`scheme`-boot compiler, since the IMPs are `foreign-callable`
trampolines `eval`'d into existence at runtime.

### Bug found + fixed: `(& NSRect)` IMP ftype invisible under whole-program seal

**Symptom.** First standalone launch threw `unrecognized foreign-callable
argument ftype name NSRect` (and then, after a first fix attempt, `attempt to
import invisible library (apianyware runtime types)`) — no window appeared.

**Root cause.** `drawRect:`'s IMP signature is `(list '(& NSRect)) 'void`.
`runtime/dispatch.sls` eval's the `foreign-callable` form in
`(interaction-environment)`, so the `NSRect` ftype identifier must resolve there.
In a `--script` (source-exec) run the app's own top-level `(import (apianyware
runtime types))` populated the interaction-environment, so it worked. The
standalone **top-level-program wrapper** (`compile-whole-program`, spike F2)
imports into the program's lexical scope instead and **seals the program**,
de-registering its libraries — so the interaction-environment lacked `NSRect`,
*and* a runtime `(import (apianyware runtime types))` is impossible ("invisible
library"). A standalone-only regression that only the struct-by-value IMP
triggers (every other portfolio app's trampolines use scalar/`void*` tokens,
always present in the base interaction-environment).

**Fix (runtime, `runtime/dispatch.sls`).** Re-`define-ftype` the geometry structs
(`NSPoint`, `NSSize`, `NSRect`, `NSRange`) **directly into the
interaction-environment**, lazily on the first `build-callable` (guarded once).
ftypes are structural (layout-only) declarations depending on nothing but
`(chezscheme)`'s `define-ftype`, so re-declaring them is sound and immune to
library sealing — unlike a runtime `import`. Kept byte-for-byte in sync with
`(apianyware runtime types)`. Verified locally that the delegate and block paths
are unregressed and the full app loads in source-exec mode.

### VM verify (no-Chez bar) — after the fix

Golden macOS 26.3 arm64, no Chez present. Uploaded (md5-verified), unpacked,
quarantine-stripped, `open -n`. Bundle: `Drawing Canvas.app`, 4.8 MB, signed, no
Chez/Scheme linkage.
- [x] **Window launches** (640×512) — the dynamic subclass registered and
      `drawRect:` ran on the empty canvas (`screenshot-standalone-001-empty.png`).
      Toolbar: Color… / line-width slider / Clear.
- [x] **`mouseDown:`/`mouseDragged:`/`mouseUp:` IMPs fire** — three mouse drags
      draw two diagonal strokes (an X) + a horizontal line; each drag ran
      `start-stroke!`/`extend-stroke!`/`end-stroke!`
      (`screenshot-standalone-002-strokes-drawn.png`).
- [x] **`drawRect:` with `(& NSRect)` renders** — the strokes are drawn via
      CoreGraphics from the IMP that receives the dirty rect by value. This is
      the fixed path; it now works in the sealed standalone, exercising the
      all-sizes struct-return ABI (leaf-140) under the embedded boot.
- [x] **`clearCanvas:` toolbar delegate** — Clear empties the strokes and
      re-renders blank (`screenshot-standalone-003-cleared.png`).
- [x] **RSS ~108 MB**, stable.

**Significance.** The capstone claim holds: a dynamically-registered ObjC class
with Scheme IMPs `eval`'d at runtime works in a whole-program-compiled, no-Chez
standalone binary — the strongest proof of the embedded-`scheme`-boot compiler.
The one whole-program-only defect was in the runtime's ftype visibility (now
fixed), not in the dynamic-subclass machinery itself.

**Obsoleted source-exec caveats (resolved by standalone):** menu bar reads
"Drawing Canvas"; no `brew install chezscheme`; 4.8 MB bundle.

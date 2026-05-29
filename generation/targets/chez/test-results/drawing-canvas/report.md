# Drawing Canvas — Chez Test Report

**Date:** 2026-05-29
**Status:** Pass-with-fixes

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

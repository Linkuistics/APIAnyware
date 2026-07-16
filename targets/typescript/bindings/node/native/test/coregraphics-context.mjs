// Integration check for coregraphics-context-function-surface-k124: the eight direct-C
// CGContext* drawing functions and NSGraphicsContext.CGContext()'s bare-pointer return — all
// rejected outright before this leaf (`method_filter.rs`'s `has_raw_pointer`/`is_raw_pointer`
// gate) despite the rest of the pipeline already handling a bare `TypeRefKind::Pointer` correctly
// (`TsFfiTypeMapper` → `bigint`, `method_retain_axis` → `NoWrap`, `emit_functions`'s param/return
// arms → a bare passthrough). The fix is a narrow, hand-verified allowlist
// (`ADMITTED_OPAQUE_POINTER_FUNCTIONS`/`ADMITTED_OPAQUE_POINTER_METHODS`), mirroring
// `block-call-site-emission-k120`'s own carve-out shape.
//
// Proves the crossing against a REAL CGContextRef, not a synthetic value: allocate a plain
// NSView, get a real backing NSBitmapImageRep via `bitmapImageRepForCachingDisplayInRect:`
// (headless — no window/run loop needed), wrap it in an NSGraphicsContext, pull its real
// CGContextRef `bigint` via `.CGContext()`, then drive all eight admitted free functions to
// stroke a horizontal red line — and read the drawn pixel back through
// `NSBitmapImageRep.colorAtX:y:` to confirm CoreGraphics genuinely executed the stroke (a real
// pixel turned red), not merely "didn't crash".
//
// Run: node targets/typescript/bindings/node/native/test/coregraphics-context.mjs
// Requires: the addon built (build.sh) and the runtime built (npm run build in runtime/).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const runtimeUrl = new URL('../../runtime/dist/index.js', import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

const rt = await import(runtimeUrl.href);
const { NSObject, __alloc, __class, __init, __installDispatch, __registerClass, __sel, __unwrap, __wrapRetained } =
  rt;

const addon = require(addonPath);
__installDispatch(addon);

let failures = 0;
function check(label, cond, detail) {
  const ok = Boolean(cond);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail !== undefined ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

const rect = (x, y, width, height) => ({ origin: { x, y }, size: { width, height } });

// ── Hand-shaped bindings — the emitted shape, matching this directory's own convention
// (plain-init.mjs/dynamic-class.mjs): the @apianyware/* bundler wiring (Step 8) doesn't exist
// yet, so these drive the runtime seam directly rather than importing the generated modules. ──

class NSBitmapImageRep extends NSObject {
  static {
    __registerClass('NSBitmapImageRep', NSBitmapImageRep);
  }
  static __cls = __class('NSBitmapImageRep');

  colorAtX_y_(x, y) {
    const __ret = addon.aw_ts_msg_qq_P(__unwrap(this), __sel('colorAtX:y:'), x, y);
    return __wrapRetained(NSColor, __ret);
  }
}

class NSView extends NSObject {
  static {
    __registerClass('NSView', NSView);
  }
  static __cls = __class('NSView');

  init() {
    return __init(this);
  }

  bitmapImageRepForCachingDisplayInRect_(r) {
    const __ret = addon.aw_ts_msg_R_P(
      __unwrap(this),
      __sel('bitmapImageRepForCachingDisplayInRect:'),
      r,
    );
    return __wrapRetained(NSBitmapImageRep, __ret);
  }
}

class NSGraphicsContext extends NSObject {
  static {
    __registerClass('NSGraphicsContext', NSGraphicsContext);
  }
  static __cls = __class('NSGraphicsContext');

  static graphicsContextWithBitmapImageRep_(rep) {
    const __ret = addon.aw_ts_msg_P_P(
      NSGraphicsContext.__cls,
      __sel('graphicsContextWithBitmapImageRep:'),
      __unwrap(rep),
    );
    return __wrapRetained(NSGraphicsContext, __ret);
  }

  // The member under test — NSGraphicsContext.CGContext(), the k124 method carve-out: a bare
  // pointer return, crossing as a raw `bigint`, no wrap (`aw_ts_msg_0_P_n`, the non-folding
  // non-object variant `emit_class::method_retain_axis` resolves to for a `Ptr`-shaped,
  // non-object return).
  CGContext() {
    return addon.aw_ts_msg_0_P_n(__unwrap(this), __sel('CGContext'));
  }
}

class NSColorSpace extends NSObject {
  static {
    __registerClass('NSColorSpace', NSColorSpace);
  }
  static __cls = __class('NSColorSpace');

  static deviceRGBColorSpace() {
    const __ret = addon.aw_ts_msg_0_P(NSColorSpace.__cls, __sel('deviceRGBColorSpace'));
    return __wrapRetained(NSColorSpace, __ret);
  }
}

class NSColor extends NSObject {
  static {
    __registerClass('NSColor', NSColor);
  }
  static __cls = __class('NSColor');

  colorUsingColorSpace_(space) {
    const __ret = addon.aw_ts_msg_P_P(__unwrap(this), __sel('colorUsingColorSpace:'), __unwrap(space));
    return __wrapRetained(NSColor, __ret);
  }

  redComponent() {
    return addon.aw_ts_msg_0_d(__unwrap(this), __sel('redComponent'));
  }

  greenComponent() {
    return addon.aw_ts_msg_0_d(__unwrap(this), __sel('greenComponent'));
  }

  blueComponent() {
    return addon.aw_ts_msg_0_d(__unwrap(this), __sel('blueComponent'));
  }
}

// ── 0. The eight admitted CGContext* free functions exist and are callable ────────────────────
for (const name of [
  'aw_ts_fn_CGContextSetRGBStrokeColor',
  'aw_ts_fn_CGContextSetLineWidth',
  'aw_ts_fn_CGContextSetLineCap',
  'aw_ts_fn_CGContextSetLineJoin',
  'aw_ts_fn_CGContextBeginPath',
  'aw_ts_fn_CGContextMoveToPoint',
  'aw_ts_fn_CGContextAddLineToPoint',
  'aw_ts_fn_CGContextStrokePath',
]) {
  check(`addon exports ${name}`, typeof addon[name] === 'function');
}

// ── 1. A real CGContextRef, from a real NSGraphicsContext backed by a real bitmap ──────────────
const view = __alloc(NSView).init();
const rep = view.bitmapImageRepForCachingDisplayInRect_(rect(0, 0, 20, 20));
check('bitmapImageRepForCachingDisplayInRect: returns a real NSBitmapImageRep', rep instanceof NSBitmapImageRep);

const gctx = NSGraphicsContext.graphicsContextWithBitmapImageRep_(rep);
check('graphicsContextWithBitmapImageRep: returns a real NSGraphicsContext', gctx instanceof NSGraphicsContext);

const ctx = gctx.CGContext();
check('NSGraphicsContext.CGContext() returns a nonzero bigint handle', typeof ctx === 'bigint' && ctx !== 0n, ctx);

// ── 2. Drive all eight functions to stroke a horizontal line ───────────────────────────────────
const kCGLineCapRound = 1;
const kCGLineJoinRound = 1;

addon.aw_ts_fn_CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, 1.0); // pure red, opaque
addon.aw_ts_fn_CGContextSetLineWidth(ctx, 8.0);
addon.aw_ts_fn_CGContextSetLineCap(ctx, kCGLineCapRound);
addon.aw_ts_fn_CGContextSetLineJoin(ctx, kCGLineJoinRound);
addon.aw_ts_fn_CGContextBeginPath(ctx);
addon.aw_ts_fn_CGContextMoveToPoint(ctx, 0, 10);
addon.aw_ts_fn_CGContextAddLineToPoint(ctx, 20, 10);
addon.aw_ts_fn_CGContextStrokePath(ctx);

// ── 3. Read the drawn pixel back — a real, independently observable effect, not just
// "didn't crash" (the same discipline inbound-struct-arg.mjs's frame-readback proof and
// plain-init.mjs's real-instance proof already established). ──────────────────────────────────
const deviceRGB = NSColorSpace.deviceRGBColorSpace();
const raw = rep.colorAtX_y_(10, 10);
check('colorAtX:y: returns a real NSColor at the stroked pixel', raw instanceof NSColor);
const painted = raw.colorUsingColorSpace_(deviceRGB);
check('the stroked pixel normalizes to device RGB', painted instanceof NSColor);

const r = painted.redComponent();
const g = painted.greenComponent();
const b = painted.blueComponent();
// A loose, dominance-based bound rather than an exact (1,0,0) match: the bitmap's own working
// color space (from `bitmapImageRepForCachingDisplayInRect:`) is not necessarily bit-identical
// to `deviceRGBColorSpace()`, so `colorUsingColorSpace:` genuinely recolour-manages the sample —
// the same reason `note-editor`'s own colour-panel handler normalizes before reading components.
// Red overwhelmingly dominant is the real, decisive signal that CoreGraphics executed the stroke.
check(
  'the stroked pixel is genuinely red — CoreGraphics executed the stroke, not a no-op',
  r > 0.9 && r > g * 2 && r > b * 5,
  `r=${r} g=${g} b=${b}`,
);

console.log(failures === 0 ? '\nALL CHECKS PASSED' : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);

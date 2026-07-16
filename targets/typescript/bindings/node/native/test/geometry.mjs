// Integration check for the POD geometry surface (pod-struct-types-k73; ADR-0042 population A,
// ADR-0055 §5).
//
// Proves the by-value struct crossing in BOTH directions against the live addon: a plain JS object
// → `napiRead<Stem>` → the real C struct → the ObjC/C call → the real C struct → `napiMake<Stem>` →
// a plain JS object. The shape under test is the family rule — **the JS object mirrors the C
// struct's fields** — and specifically its one nested member, `CGRect`, whose C struct nests a
// `CGPoint origin` and a `CGSize size`. A flat `{x,y,width,height}` would read as a ZEROED rect
// here (the readers default a missing field to 0), so a regression to flat fails loudly rather
// than silently returning garbage geometry.
//
// Run: node targets/typescript/bindings/node/native/test/geometry.mjs
// Requires: the addon built (build.sh) and the runtime built (npm run build in runtime/).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const runtimeUrl = new URL('../../runtime/dist/index.js', import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

// Namespace import: `__dispatch` is a live binding `__installDispatch` reassigns (see spine.mjs).
const rt = await import(runtimeUrl.href);
const { NSObject, __class, __sel, __installDispatch, __unwrap, __wrapOwned, __wrapRetained, withAutoreleasePool } = rt;

const addon = require(addonPath);
__installDispatch(addon);

let failures = 0;
function check(label, cond, detail) {
  const ok = Boolean(cond);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail !== undefined ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

/** Deep field equality against an expected nested rect — a flat return fails every field. */
function rectEquals(r, x, y, w, h) {
  return (
    r != null &&
    r.origin != null &&
    r.size != null &&
    r.origin.x === x &&
    r.origin.y === y &&
    r.size.width === w &&
    r.size.height === h
  );
}

const rect = (x, y, width, height) => ({ origin: { x, y }, size: { width, height } });

// ── 1. The pure-C geometry free functions (Foundation; headless, deterministic) ───────────────
// The densest POD population in the corpus, and the emitted `functions.ts` call sites that
// referenced `CGRect` with no import before this leaf. `NSInsetRect` reads a rect AND returns one,
// so a single call exercises napiReadRect and napiMakeRect back-to-back.

const outer = rect(0, 0, 100, 50);
const inset = addon.aw_ts_fn_NSInsetRect(outer, 10, 5);
check(
  'NSInsetRect: nested rect in → nested rect out',
  rectEquals(inset, 10, 5, 80, 40),
  JSON.stringify(inset),
);

// Two rects in, a scalar out — the read path alone, twice, with no make path to mask it.
check(
  'NSContainsRect: the inset rect is contained by the outer',
  addon.aw_ts_fn_NSContainsRect(outer, inset) === true,
);
check(
  'NSContainsRect: the outer rect is NOT contained by the inset',
  addon.aw_ts_fn_NSContainsRect(inset, outer) === false,
);

const offset = addon.aw_ts_fn_NSOffsetRect(outer, 7, -3);
check(
  'NSOffsetRect: only the origin moves; the size rides along untouched',
  rectEquals(offset, 7, -3, 100, 50),
  JSON.stringify(offset),
);

// The negative control: a FLAT rect (the pre-k73 addon shape) has no `origin`/`size`, so every
// field reads 0 — proving the nested field names are genuinely load-bearing at the boundary and
// that this test would catch a regression to flat rather than passing vacuously.
const flat = addon.aw_ts_fn_NSInsetRect({ x: 0, y: 0, width: 100, height: 50 }, 0, 0);
check(
  'a flat {x,y,width,height} arg reads as a ZEROED rect — the nesting is load-bearing',
  rectEquals(flat, 0, 0, 0, 0),
  JSON.stringify(flat),
);

// ── 2. The rest of the family, through the same seam ──────────────────────────────────────────
// Each is flat in C, so each is flat here — one rule (mirror the struct), not nine special cases.

const union = addon.aw_ts_fn_NSUnionRange({ location: 0, length: 5 }, { location: 3, length: 7 });
check(
  'NSRange: {location,length} round-trips (flat in C, flat here)',
  union != null && union.location === 0 && union.length === 10,
  JSON.stringify(union),
);

const pointInRect = addon.aw_ts_fn_NSPointInRect({ x: 50, y: 25 }, outer);
check('CGPoint: {x,y} reads as a by-value arg', pointInRect === true);
check(
  'CGPoint: a point outside the rect',
  addon.aw_ts_fn_NSPointInRect({ x: 500, y: 25 }, outer) === false,
);

// ── 3. Through METHOD dispatch, not just free functions ───────────────────────────────────────
// `+[NSValue valueWithRect:]` / `-[NSValue rectValue]`: a rect crosses INTO an objc_msgSend and
// comes back OUT of one — the `aw_ts_msg_*` path the emitted class bodies use, headless-safe
// (Foundation's NSGeometry extensions), and boxing proves the struct survived intact natively.

class NSValue extends NSObject {
  static __cls = __class('NSValue');
  static valueWithRect_(r) {
    return __wrapRetained(NSValue, addon.aw_ts_msg_R_P(NSValue.__cls, __sel('valueWithRect:'), r));
  }
  rectValue() {
    return addon.aw_ts_msg_0_R(__unwrap(this), __sel('rectValue'));
  }
}

withAutoreleasePool(() => {
  const boxed = NSValue.valueWithRect_(rect(1, 2, 3, 4));
  const back = boxed.rectValue();
  check(
    'NSValue: a rect boxed through +valueWithRect: and read back by -rectValue is unchanged',
    rectEquals(back, 1, 2, 3, 4),
    JSON.stringify(back),
  );
});

// ── 4. The hello-window shape — the Step-7 call this leaf unblocks ────────────────────────────
// `NSWindow.alloc().initWithContentRect_styleMask_backing_defer_(rect, …)` then `-frame`. AppKit,
// but window-server-free: `defer:YES` means no backing store is realised until the window is
// ordered front, which this never does. This is the literal blocker in the leaf brief: without a
// CGRect type there is no way to write this call at all.

const NSWindowCls = __class('NSWindow');
const NSTitledWindowMask = 1;
const NSBackingStoreBuffered = 2;

withAutoreleasePool(() => {
  const contentRect = rect(0, 0, 480, 320);
  const allocd = addon.aw_ts_msg_0_P(NSWindowCls, __sel('alloc'));
  // `init…` is +1-owned, so the non-folding `_o` sibling (ADR-0057 §4).
  const win = __wrapOwned(
    NSObject,
    addon.aw_ts_msg_RQQb_P_o(
      allocd,
      __sel('initWithContentRect:styleMask:backing:defer:'),
      contentRect,
      NSTitledWindowMask,
      NSBackingStoreBuffered,
      true,
    ),
  );
  check('NSWindow: -initWithContentRect:… accepted the nested rect', win !== null);

  if (win !== null) {
    using w = win;
    const frame = addon.aw_ts_msg_0_R(__unwrap(w), __sel('frame'));
    // AppKit grows the frame beyond the CONTENT rect by the title bar's height, so the exact
    // height is a platform detail — assert the invariants that hold regardless: the origin and
    // width are preserved, and the frame is at least as tall as the content it was given.
    check(
      'NSWindow: -frame returns a nested rect whose origin/width match the content rect',
      frame != null &&
        frame.origin != null &&
        frame.size != null &&
        frame.origin.x === 0 &&
        frame.origin.y === 0 &&
        frame.size.width === 480 &&
        frame.size.height >= 320,
      JSON.stringify(frame),
    );
    // The composability the nesting buys (ADR-0055 §5): `frame.origin` IS a CGPoint, so it feeds
    // a CGPoint-taking method with no hand-spreading. This is the line a flat rect cannot write.
    addon.aw_ts_msg_O_v(__unwrap(w), __sel('setFrameOrigin:'), frame.origin);
    const moved = addon.aw_ts_msg_0_R(__unwrap(w), __sel('frame'));
    check(
      'NSWindow: frame.origin feeds -setFrameOrigin: directly — the rect composes',
      moved != null && moved.origin.x === 0 && moved.origin.y === 0,
      JSON.stringify(moved),
    );
  }
});

console.log(failures === 0 ? '\nALL GEOMETRY CHECKS PASSED' : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);

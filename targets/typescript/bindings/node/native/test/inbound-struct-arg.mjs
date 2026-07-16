// Integration check for the inbound struct-PARAMETER surface (inbound-struct-arg-surface-k123,
// ADR-0059 §1/§4 widened to admit the closed 9-member POD geometry family, params only —
// ADR-0055 §5a). Before this leaf, `NSView.drawRect:` (and any struct-arg override) had no
// installable inbound trampoline — the whole premise of the `drawing-canvas` ladder app
// (dynamic `NSView` subclass overriding `drawRect:`) was blocked on it.
//
// `setFrame:`/`drawRect:` share ONE generated trampoline (`aw_ts_inb_R_v`) and ONE super-send
// entry (`aw_ts_super_R_v`) — both are pure functions of the ABI shape `(CGRect) -> void`, not
// the selector — so proving `setFrame:` (which has an independently OBSERVABLE side effect via
// `-frame`) proves `drawRect:`'s identical machinery works too. This suite drives BOTH
// selectors against the REAL addon:
//
//   §1 setFrame: — a JS override receives a real, correctly-valued CGRect (not zeroed/garbage)
//     when dispatched via the ordinary outbound entry (standing in for "AppKit calls the
//     override"); it forwards to `$super` (aw_ts_super_R_v) directly, and the REAL NSView base
//     implementation's effect is independently confirmed by reading `-frame` back afterward — a
//     round-trip proof, not just "didn't crash".
//   §2 drawRect: — the literal selector `drawing-canvas` needs, proven to dispatch through the
//     same generated machinery with an independently-chosen rect.
//
// Headless: a real `NSView` instance (`alloc`/`init`), no window, no run loop, no graphics
// context — this suite proves the ABI/marshalling mechanism, not visual output (that is
// `drawing-canvas`'s own TestAnyware VM verification).
//
// Run: node targets/typescript/bindings/node/native/test/inbound-struct-arg.mjs
// Requires: the addon built (build.sh) and the runtime built (npm run build in runtime/).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const runtimeUrl = new URL('../../runtime/dist/index.js', import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

const rt = await import(runtimeUrl.href);
const { NSObject, __class, __sel, __installDispatch, __unwrap, __subclassAlloc, __bindSubclass } = rt;

const addon = require(addonPath);
__installDispatch(addon);

let failures = 0;
function check(label, cond, detail) {
  const ok = Boolean(cond);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail !== undefined ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

const rect = (x, y, width, height) => ({ origin: { x, y }, size: { width, height } });
function rectEquals(r, expected) {
  return (
    r != null &&
    r.origin != null &&
    r.size != null &&
    r.origin.x === expected.origin.x &&
    r.origin.y === expected.origin.y &&
    r.size.width === expected.size.width &&
    r.size.height === expected.size.height
  );
}

// The two new generated entries this leaf adds (mirrors super.mjs's own export-presence check).
for (const name of ['aw_ts_super_R_v']) {
  check(`addon exports ${name}`, typeof addon[name] === 'function');
}

const NSVIEW_CLASS = __class('NSView');
// (CGRect) -> void — the exact shape `drawRect:` and `setFrame:` share; one trampoline/super
// entry serves both (content-addressed by ABI shape, not selector — the k57 discipline).
const RECT_VOID_ENCODING = 'v@:{CGRect={CGPoint=dd}{CGSize=dd}}';
const OVERRIDES = [
  ['setFrame:', RECT_VOID_ENCODING],
  ['drawRect:', RECT_VOID_ENCODING],
];

class TrackedView extends NSObject {
  constructor() {
    super(__subclassAlloc(TrackedView, NSVIEW_CLASS, OVERRIDES));
    __bindSubclass(this);
    this.setFrameLog = [];
    this.drawRectLog = [];
  }
  setFrame_(r) {
    this.setFrameLog.push(r);
    // $super.setFrame_(r) — the outbound-shaped struct-arg super-send (ADR-0059 §4), reaching
    // the REAL NSView base implementation so its effect is independently observable via -frame.
    rt.__dispatch.aw_ts_super_R_v(__unwrap(this), NSVIEW_CLASS, __sel('setFrame:'), r);
  }
  drawRect_(r) {
    this.drawRectLog.push(r);
  }
}

// ── §1 — setFrame: override receives a correct CGRect; $super forwards it to the real base ────
{
  using v = new TrackedView();
  const wanted = rect(10, 20, 100, 200);
  // Dispatch through the ordinary outbound entry (aw_ts_msg_R_v) — the real ObjC message send,
  // routed by the runtime to whichever IMP is installed for -setFrame: on this instance's
  // synthesized class, i.e. OUR override (standing in for "AppKit calls the override").
  addon.aw_ts_msg_R_v(__unwrap(v), __sel('setFrame:'), wanted);

  check(
    'setFrame: override received exactly one call',
    v.setFrameLog.length === 1,
    v.setFrameLog.length,
  );
  check(
    'the override received the REAL CGRect (not zeroed/garbage)',
    rectEquals(v.setFrameLog[0], wanted),
    JSON.stringify(v.setFrameLog[0]),
  );

  // Read the frame back through the ordinary outbound getter (aw_ts_msg_0_R, already proven by
  // geometry.mjs) — this only matches `wanted` if the $super struct-arg send inside the override
  // genuinely reached NSView's real -setFrame: with the SAME value, not a truncated/zeroed one.
  const framed = addon.aw_ts_msg_0_R(__unwrap(v), __sel('frame'));
  check(
    '$super.setFrame_(r) reached the REAL base implementation (frame round-trips)',
    rectEquals(framed, wanted),
    JSON.stringify(framed),
  );
}

// ── §2 — drawRect: (the literal selector drawing-canvas needs) dispatches through the same
// generated machinery, independently confirmed with a different rect ──────────────────────────
{
  using v = new TrackedView();
  const wanted = rect(1, 2, 3, 4);
  addon.aw_ts_msg_R_v(__unwrap(v), __sel('drawRect:'), wanted);

  check('drawRect: override received exactly one call', v.drawRectLog.length === 1, v.drawRectLog.length);
  check(
    'drawRect: received the REAL CGRect (not zeroed/garbage)',
    rectEquals(v.drawRectLog[0], wanted),
    JSON.stringify(v.drawRectLog[0]),
  );
}

console.log(failures === 0 ? '\nALL CHECKS PASSED' : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);

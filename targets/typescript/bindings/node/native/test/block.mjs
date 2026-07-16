// Integration check for the on-thread-0 NS_NOESCAPE block INBOUND surface
// (block-noescape-on-main-k39, realising the on-thread-0 direct-invoke fast path of ADR-0059 §2).
// The blocks dual of inbound.mjs (subclass) / delegate.mjs (delegate).
//
// Loads the REAL Swift-native addon, installs it as `__dispatch`, and proves the blocks surface:
// a JS function passed where an ObjC NS_NOESCAPE block parameter is expected
// (`-[NSArray enumerateObjectsUsingBlock:]`) is wrapped by `makeBlock` into a REAL ObjC block (a
// `@convention(block)` Swift closure capturing the CallbackId, `_Block_copy`'d to the heap) whose
// invoke is a typed inbound trampoline. Foundation invokes it SYNCHRONOUSLY on thread 0 for each
// element during the enumerate — the per-element JS body runs and observes each element — and the JS
// function is held ONLY for the call's duration (the `__withNoescapeBlock` register/release bracket,
// no tsfn). A throwing block body is contained per invocation at the boundary (no C-ABI unwind).
//
// Headless: Foundation-only (NSMutableArray of NSStrings), no AppKit.
//
// Run: node targets/typescript/bindings/node/native/test/block.mjs
// Requires: the addon built (build.sh) and the runtime built (npm run build in runtime/).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const runtimeUrl = new URL('../../runtime/dist/index.js', import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

const rt = await import(runtimeUrl.href);
const { __class, __sel, __installDispatch, __withNoescapeBlock, onCallbackError } = rt;

const addon = require(addonPath);
__installDispatch(addon);

let failures = 0;
function check(label, cond, detail) {
  const ok = Boolean(cond);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail !== undefined ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

// The new block primitives the addon must export (on top of the outbound spine + subclass/delegate inbound).
for (const name of ['makeBlock', 'releaseBlock']) {
  check(`addon exports ${name}`, typeof addon[name] === 'function');
}

// ── Build an NSMutableArray of NSStrings (Foundation-only, headless) ─────────────────────────────
// The enumerate block's ABI: void (^)(id obj, NSUInteger idx, BOOL *stop) — content-addressed PQP_v
// (the shared inbound code alphabet, block-maker-tables-k62: the BOOL* out-pointer is a pointer P and
// crosses to JS as a raw handle; the generated maker replaced the hand-written PQb_v one).
// enumerateObjectsUsingBlock: itself is (id, SEL, id block) -> void — the existing outbound code P_v.
const ENUM_SEL = 'enumerateObjectsUsingBlock:';
const ENUM_SIG = 'PQP_v';

const words = ['alpha', 'beta', 'gamma'];
const arr = addon.allocInit(__class('NSMutableArray')); // +1 owned
const idToWord = new Map();
const strs = [];
for (const w of words) {
  const s = addon.cfstr(w); // +1 owned; the array retains it on addObject:
  strs.push(s);
  idToWord.set(s, w); // key by the raw id handle — stable across retain, matches what enumerate yields
  addon.aw_ts_msg_P_v(arr, __sel('addObject:'), s);
}

// The emitted-shape enumerate binding: __withNoescapeBlock brackets makeBlock/releaseBlock around the
// ordinary outbound enumerate dispatch (the block crosses as an `id`, code P_v). A real emitted module
// would generate exactly this shape from the IR block signature + the NS_NOESCAPE annotation.
function enumerate(arrId, fn) {
  return __withNoescapeBlock(fn, ENUM_SIG, (block) =>
    rt.__dispatch.aw_ts_msg_P_v(arrId, __sel(ENUM_SEL), block),
  );
}

// ── (1) Synchronous on-thread-0 delivery: the block fires for every element, in order ────────────
{
  const seen = [];
  enumerate(arr, (objId, idx) => {
    seen.push([Number(idx), idToWord.get(objId)]);
  });
  // enumerateObjectsUsingBlock: is synchronous → `seen` is fully populated by the time enumerate
  // returns (proving the block fired on thread 0, inline, during the call).
  check(
    'NS_NOESCAPE block fired synchronously on thread 0 for all elements, in order',
    JSON.stringify(seen) === JSON.stringify([
      [0, 'alpha'],
      [1, 'beta'],
      [2, 'gamma'],
    ]),
    JSON.stringify(seen),
  );
}

// ── (2) Held only for the call's duration (no tsfn): a second enumerate re-brackets cleanly ──────
// The first call's register/release bracket ran to completion; a leaked or over-released block/handle
// would crash or mis-fire here. A clean second run is the observable "not held past the call" proof.
{
  let count = 0;
  enumerate(arr, () => {
    count++;
  });
  check('a second enumerate re-brackets cleanly (fn not leaked / over-released)', count === 3, count);
}

// ── (3) Boundary containment: a throwing block body is contained per invocation (ADR-0059 §7) ────
// The block has no selector, so the error context carries none (contextOf → { id } only). NSArray
// keeps enumerating (we never set *stop), so a throw-every-time body is contained 3×, once per element.
{
  let reported = 0;
  onCallbackError((_err, ctx) => {
    reported++;
    check('block error context has no selector (a block invoke has none)', ctx.selector === undefined, ctx.selector);
  });
  enumerate(arr, () => {
    throw new Error('boom');
  });
  // Reaching this line at all means no JS exception unwound the C ABI through NSArray's enumeration.
  check('throwing block body contained → enumerate completed, no C-ABI unwind', true);
  check('onCallbackError fired once per element (3 contained throws)', reported === 3, reported);
  onCallbackError(null);
}

// Cleanup: drop our alloc/cfstr +1s (the array holds its own retains until released).
for (const s of strs) addon.release(s);
addon.release(arr);

console.log(failures === 0 ? '\nALL CHECKS PASSED' : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);

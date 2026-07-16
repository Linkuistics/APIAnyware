// Integration check for the on-thread-0 dynamic-subclass INBOUND path
// (subclass-inbound-on-main-k37, realising the on-thread-0 slice of ADR-0059
// §1/§3(subclass)/§5(on-thread-0)/§7). The inbound dual of spine.mjs.
//
// Loads the REAL Swift-native addon, installs it as `__dispatch`, and proves ObjC→JS:
// a JS class `extends`ing a bound ObjC class synthesizes ONE ObjC subclass per JS class
// (objc_allocateClassPair + class_addMethod + a back-ref ivar), each overridden selector an
// installed typed `@_cdecl` inbound trampoline. When the ObjC runtime dispatches the selector
// — directly (`[a compare: b]`) OR framework-driven (`-[NSArray sortedArrayUsingSelector:]`) —
// the trampoline marshals args, calls the runtime's `__invokeCallback` SYNCHRONOUSLY on thread 0,
// and returns the JS-computed value to ObjC. A throwing override is contained at the boundary
// (no C-ABI unwind, `onCallbackError` fires, typed nil/0 default returned).
//
// Headless: Foundation-only (NSObject subclass + compare: + NSMutableArray sort), no AppKit.
//
// Run: node targets/typescript/bindings/node/native/test/inbound.mjs
// Requires: the addon built (build.sh) and the runtime built (npm run build in runtime/).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const runtimeUrl = new URL('../../runtime/dist/index.js', import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

const rt = await import(runtimeUrl.href);
const {
  NSObject,
  __class,
  __sel,
  __unwrap,
  __installDispatch,
  __subclassAlloc,
  __bindSubclass,
  onCallbackError,
} = rt;

const addon = require(addonPath);
__installDispatch(addon);

let failures = 0;
function check(label, cond, detail) {
  const ok = Boolean(cond);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail !== undefined ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

// The new inbound primitives the addon must export (on top of the outbound spine).
for (const name of [
  'installCallbackInvoker', 'defineSubclass', 'allocInit', 'setBackRef',
  'aw_ts_msg_P_q', 'aw_ts_msg_P_v', 'aw_ts_msg_q_P',
]) {
  check(`addon exports ${name}`, typeof addon[name] === 'function');
}

// ── A JS subclass of NSObject overriding -compare: (value-returning, NSInteger) ──────────────
// Inbound object args cross as raw ObjC-id handles; the test maps them back to JS instances
// (a stand-in for the emitter/runtime uniquing a later child provides — out of k37 scope).
const idToInstance = new Map();

const OBJC_NSOBJECT = __class('NSObject');
const COMPARE_OVERRIDE = [['compare:', 'q@:@']]; // NSInteger return, self, _cmd, one id arg

class Ranked extends NSObject {
  constructor(rank) {
    super(__subclassAlloc(Ranked, OBJC_NSOBJECT, COMPARE_OVERRIDE));
    this.rank = rank;
    __bindSubclass(this);
    idToInstance.set(__unwrap(this), this);
  }
  // -[NSObject compare:] → NSComparisonResult (NSOrderedAscending -1 … Descending 1), by JS rank.
  compare_(otherId) {
    const other = idToInstance.get(otherId);
    if (this.rank < other.rank) return -1;
    if (this.rank > other.rank) return 1;
    return 0;
  }
}

// The synthesized ObjC subclass is a real, distinct Class handle.
{
  using a = new Ranked(5);
  check('subclass instance wraps a nonzero id', typeof __unwrap(a) === 'bigint' && __unwrap(a) !== 0n, __unwrap(a));
}

// ── (1) Direct value-returning inbound on thread 0: [a compare: b] ───────────────────────────
{
  using a = new Ranked(5);
  using b = new Ranked(9);
  const cmpAB = rt.__dispatch.aw_ts_msg_P_q(__unwrap(a), __sel('compare:'), __unwrap(b));
  check('[Ranked(5) compare: Ranked(9)] → JS returned -1', Number(cmpAB) === -1, cmpAB);
  const cmpBA = rt.__dispatch.aw_ts_msg_P_q(__unwrap(b), __sel('compare:'), __unwrap(a));
  check('[Ranked(9) compare: Ranked(5)] → JS returned 1', Number(cmpBA) === 1, cmpBA);
  const cmpAA = rt.__dispatch.aw_ts_msg_P_q(__unwrap(a), __sel('compare:'), __unwrap(a));
  check('[Ranked(5) compare: Ranked(5)] → JS returned 0', Number(cmpAA) === 0, cmpAA);
}

// ── (2) Framework-driven inbound: -[NSArray sortedArrayUsingSelector:@selector(compare:)] ────
// Foundation itself calls compare: on each element — the override runs under framework control.
{
  const r1 = new Ranked(1);
  const r2 = new Ranked(2);
  const r3 = new Ranked(3);
  const arr = rt.__dispatch.allocInit(__class('NSMutableArray')); // +1 owned
  for (const r of [r3, r1, r2]) {
    rt.__dispatch.aw_ts_msg_P_v(arr, __sel('addObject:'), __unwrap(r)); // addObject: (id,SEL,id)->void
  }
  // sortedArrayUsingSelector: (id,SEL,SEL)->id — the SEL arg crosses as a handle (same shape as P_P).
  const sorted = rt.__dispatch.aw_ts_msg_P_P(arr, __sel('sortedArrayUsingSelector:'), __sel('compare:'));
  const count = Number(rt.__dispatch.aw_ts_msg_0_Q(sorted, __sel('count')));
  const ranks = [];
  for (let i = 0; i < count; i++) {
    const elem = rt.__dispatch.aw_ts_msg_q_P(sorted, __sel('objectAtIndex:'), i); // (id,SEL,NSInteger)->id (+1 folded)
    ranks.push(idToInstance.get(elem).rank);
    rt.__dispatch.release(elem); // balance the fold's +1 (peek only)
  }
  check('sortedArrayUsingSelector: ordered by JS compare: → [1,2,3]', JSON.stringify(ranks) === '[1,2,3]', JSON.stringify(ranks));
  rt.__dispatch.release(sorted);
  rt.__dispatch.release(arr);
  r1[Symbol.dispose]();
  r2[Symbol.dispose]();
  r3[Symbol.dispose]();
}

// ── (3) Boundary containment: a JS override that throws (ADR-0059 §7) ────────────────────────
{
  class Boom extends NSObject {
    constructor() {
      super(__subclassAlloc(Boom, OBJC_NSOBJECT, COMPARE_OVERRIDE));
      __bindSubclass(this);
    }
    compare_() {
      throw new Error('boom');
    }
  }
  let reported = 0;
  onCallbackError((err, ctx) => {
    reported++;
    check('onCallbackError carries the selector context', ctx.selector === 'compare:', ctx.selector);
  });
  using x = new Boom();
  using y = new Boom();
  const r = rt.__dispatch.aw_ts_msg_P_q(__unwrap(x), __sel('compare:'), __unwrap(y));
  check('throwing override contained → typed default 0 (no C-ABI unwind)', Number(r) === 0, r);
  check('onCallbackError fired exactly once for the contained throw', reported === 1, reported);
  onCallbackError(null);
}

// ── (4) The widened generated alphabet (inbound-imp-table-k61) ────────────────────────────────
// Shapes the hand-written five never had, served by the GENERATED table + the widened delivery
// core: a double return (`d@:` — the .double IEEE-bit-pattern slot), an unsigned return (`Q@:` —
// the .uint64 slot), and a BOOL argument (`v@:c` — the .bool BounceArg, arriving as a JS boolean).
// Each is driven through the matching outbound entry, so the round trip is ObjC-dispatch-real.
{
  const WIDE_OVERRIDES = [
    ['level', 'd@:'], // () -> double
    ['badge', 'Q@:'], // () -> NSUInteger
    ['setOn:', 'v@:c'], // (BOOL) -> void
  ];
  let onArg; // what the setOn: override received (value + JS type)
  class Gauge extends NSObject {
    constructor() {
      super(__subclassAlloc(Gauge, OBJC_NSOBJECT, WIDE_OVERRIDES));
      __bindSubclass(this);
    }
    level() {
      return 2.75;
    }
    badge() {
      return 42;
    }
    setOn_(flag) {
      onArg = { value: flag, type: typeof flag };
    }
  }
  using g = new Gauge();
  const level = rt.__dispatch.aw_ts_msg_0_d(__unwrap(g), __sel('level'));
  check('double-returning override round-trips the .double slot (2.75)', level === 2.75, level);
  const badge = Number(rt.__dispatch.aw_ts_msg_0_Q(__unwrap(g), __sel('badge')));
  check('NSUInteger-returning override round-trips the .uint64 slot (42)', badge === 42, badge);
  rt.__dispatch.aw_ts_msg_b_v(__unwrap(g), __sel('setOn:'), true);
  check('BOOL arg crosses the .bool BounceArg as a JS boolean true', onArg?.value === true && onArg?.type === 'boolean', JSON.stringify(onArg));
  rt.__dispatch.aw_ts_msg_b_v(__unwrap(g), __sel('setOn:'), false);
  check('BOOL arg false crosses as a JS boolean false', onArg?.value === false && onArg?.type === 'boolean', JSON.stringify(onArg));
}

console.log(failures === 0 ? '\nALL CHECKS PASSED' : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);

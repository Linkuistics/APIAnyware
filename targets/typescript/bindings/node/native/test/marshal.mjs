// Integration check for the INBOUND VALUE SURFACE (inbound-value-kinds-k79, ADR-0059 §8 + the
// ADR-0057 §2/§4 lifetime arms). The inbound dual of sel-class.mjs's outbound leg.
//
// Loads the REAL Swift-native addon and drives real ObjC objects through real inbound trampolines,
// proving that a JS delegate / subclass override / block written against a value-kind descriptor
// receives the types its interface DECLARES — and returns them — rather than raw `bigint` handles:
//
//   Leg A — args in.   A delegate whose descriptor declares an object param receives a genuine
//     WRAPPER (instanceof, ===-stable across redeliveries of the same sender, methods dispatch on
//     it); a SEL param arrives as its selector-name string; a Class param as the bound constructor.
//
//   Leg B — retain accounting, MEASURED.  `-retainCount` before/after proves the borrowed wrap takes
//     exactly one +1 on the fresh mint and ZERO on redelivery (no leak per event) — the ADR-0057 §2
//     claim, read off the object rather than asserted.
//
//   Leg C — returns out.  A delegate that MINTS an object and returns it under a +0-convention
//     selector round-trips it to ObjC ALIVE (retain-autoreleased, independent of the JS wrapper's
//     +1) — the case a bare `__unwrap` handle would leave dangling. A +1-convention (`owned`) return
//     hands the caller its own +1 instead.
//
//   Leg D — negative controls.  A descriptor that does not cover the arriving selector is a LOUD,
//     contained spec bug (never a silently-raw handle); returning a disposed wrapper is contained,
//     not a use-after-free. Neither unwinds the C ABI.
//
// Headless: Foundation only (a bare test protocol + NSString/NSMutableString), no AppKit.
//
// Run: node targets/typescript/bindings/node/native/test/marshal.mjs
// Requires: the addon built (build.sh) and the runtime built (npm run build in runtime/).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const runtimeUrl = new URL('../../runtime/dist/index.js', import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

const rt = await import(runtimeUrl.href);
const {
  CLS,
  NSObject,
  OBJ,
  RAW,
  RET_OBJ,
  SEL,
  __class,
  __forwarderClass,
  __installDispatch,
  __registerCallback,
  __registerClass,
  __respondsBits,
  __sel,
  __wrapOwned,
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

// The two primitives the inbound value surface adds to the seam (ADR-0057 §2/§4).
for (const name of ['retain', 'retainAutorelease']) {
  check(`addon exports ${name}`, typeof addon[name] === 'function');
}

// -retainCount, read through the ordinary 0_Q entry — the ground truth for the lifetime claims.
const rc = (id) => Number(addon.aw_ts_msg_0_Q(id, __sel('retainCount')));

// Stand-in "emitted classes": registered under their ObjC runtime names exactly as a generated
// class's static block does, so __classCtor / OBJ(…) resolve to them.
class NSString extends NSObject {}
__registerClass('NSString', NSString);
class NSMutableString extends NSObject {}
__registerClass('NSMutableString', NSMutableString);

// The test protocol every leg drives. Encodings are the k61 alphabet: `@` is EVERY pointer-like
// (id, SEL, Class alike) — which is exactly why the value kind cannot live in the trampoline and
// must ride on the descriptor instead.
const SPEC_METHODS = [
  ['takeObject:', 'v@:@'], // an object arg   → a wrapper
  ['takeSelector:', 'v@:@'], // a SEL arg      → a string
  ['takeClass:', 'v@:@'], // a Class arg      → the bound ctor
  ['makeObject', '@@:'], // a +0 object return → retain-autoreleased
  ['copyObject', '@@:'], // a +1 object return → retained
];

// `OBJ` carries no declared class (ADR-0059 §8, reconciled by `dynamic-class-wrap-k88`): the wrap
// resolves the object's REAL ObjC class through the ctor registry, climbing to the nearest bound
// ancestor. So a `cfstr` string — really a `__NSCFConstantString`, which no binding declares — still
// arrives as an `NSString`, which is exactly what the declared class used to buy, without the class
// reference the emitted spec module would otherwise have to value-import.
const MARSHAL = rt.__methodMarshal({
  'takeObject:': { args: [OBJ], ret: RAW },
  'takeSelector:': { args: [SEL], ret: RAW },
  'takeClass:': { args: [CLS], ret: RAW },
  makeObject: { args: [], ret: RET_OBJ() }, // +0 convention
  copyObject: { args: [], ret: RET_OBJ('owned') }, // +1 convention
});

// The retain-accounted legs need a **countable** object: `cfstr` yields an immortal/constant
// NSString whose `-retainCount` is `NSUIntegerMax`, so every accounting check against one is
// vacuously true. A plain `[[NSObject alloc] init]` starts at exactly 1 and counts honestly (the
// same reason retain.mjs builds its baseline that way), so those legs feed a real NSObject — whose
// class the wrap now resolves for itself.
const MARSHAL_COUNTED = rt.__methodMarshal({
  'takeObject:': { args: [OBJ], ret: RAW },
  makeObject: { args: [], ret: RET_OBJ() },
  copyObject: { args: [], ret: RET_OBJ('owned') },
});
const freshObject = () => addon.allocInit(__class('NSObject')); // +1, retainCount 1

const SPEC = {
  protocol: 'AWValueSurface',
  methods: SPEC_METHODS,
  setter: 'setValueDelegate:',
  propertyKey: 'valueDelegate',
  associate: true,
};

/** A forwarder over SPEC whose JS side is `jsObj`, marshalled by `marshal` (omit → raw handles). */
function forwarder(jsObj, marshal) {
  const cls = __forwarderClass(SPEC);
  const fwd = addon.allocInit(cls); // +1 owned
  const cbid = __registerCallback(jsObj, marshal);
  addon.setBackRef(fwd, cbid);
  addon.setRespondsBits(fwd, __respondsBits(jsObj, SPEC_METHODS));
  return fwd;
}

const sendObj = (fwd, sel, arg) => addon.aw_ts_msg_P_v(fwd, __sel(sel), arg);
const sendRet = (fwd, sel) => addon.aw_ts_msg_0_P_n(fwd, __sel(sel)); // raw handle, no fold, no wrap

// ── Leg A — args in: the declared types, not bigints ───────────────────────────────────────────
{
  let object;
  let selector;
  let classRef;
  const fwd = forwarder(
    {
      takeObject_: (o) => {
        object = o;
      },
      takeSelector_: (s) => {
        selector = s;
      },
      takeClass_: (c) => {
        classRef = c;
      },
    },
    MARSHAL,
  );

  // A real NSString the caller owns — the borrowed (+0) shape a delegate arg always has.
  const str = addon.cfstr('alpha'); // +1 owned by US, standing in for the ObjC caller's ownership
  sendObj(fwd, 'takeObject:', str);
  const first = object;
  check('an object arg arrives as a WRAPPER of the declared class', first instanceof NSString, first?.constructor?.name);
  check(
    'the wrapper dispatches — it is a real bound object, not an opaque box',
    Number(addon.aw_ts_msg_0_Q(rt.__unwrap(first), __sel('length'))) === 5,
  );

  // Redelivery of the SAME id → the SAME wrapper (`sender === this.button` — ADR-0057 §3 uniquing).
  sendObj(fwd, 'takeObject:', str);
  check('the same object redelivered is the SAME wrapper (===)', object === first);

  // A SEL and a Class arg — both `@` at the ABI, both distinct at the TS surface. This is the whole
  // point of the descriptor: the trampoline cannot tell these three apart, and the emitter can.
  sendObj(fwd, 'takeSelector:', __sel('doCommand:'));
  check('a SEL arg arrives as its selector-name string', selector === 'doCommand:', selector);

  sendObj(fwd, 'takeClass:', __class('NSMutableString'));
  check('a Class arg arrives as the bound constructor', classRef === NSMutableString, classRef?.name);

  addon.release(str);
  addon.release(fwd);
}

// ── Leg B — the borrowed-wrap retain accounting, MEASURED off the object ───────────────────────
{
  let wrapper;
  const fwd = forwarder(
    {
      takeObject_: (o) => {
        wrapper = o;
      },
    },
    MARSHAL_COUNTED,
  );

  const obj = freshObject(); // a countable +1 — retainCount 1
  const before = rc(obj);
  check('baseline: a fresh NSObject counts honestly', before === 1, before);

  sendObj(fwd, 'takeObject:', obj); // fresh mint → __wrapBorrowed takes its OWN +1
  const afterMint = rc(obj);
  check(
    'a fresh borrowed wrap takes exactly ONE +1 (the ARC store-time retain JS cannot insert)',
    afterMint === before + 1,
    `${before} → ${afterMint}`,
  );

  sendObj(fwd, 'takeObject:', obj); // live wrapper → zero crossings
  sendObj(fwd, 'takeObject:', obj);
  const afterRedelivery = rc(obj);
  check(
    'redelivery costs ZERO retains — a hot event stream does not leak one +1 per event',
    afterRedelivery === afterMint,
    `${afterMint} → ${afterRedelivery}`,
  );

  // The wrapper owns exactly one +1, released by dispose (ADR-0057 §1/§2 — the invariant all three
  // wrap primitives converge on).
  wrapper[Symbol.dispose]();
  const afterDispose = rc(obj);
  check(
    'disposing the borrowed wrapper releases exactly its one +1',
    afterDispose === before,
    `${afterRedelivery} → ${afterDispose}`,
  );
  addon.release(obj);
  addon.release(fwd);
}

// ── Leg C — returns out: the ADR-0057 §4 retain axis ───────────────────────────────────────────
{
  // The load-bearing case: the delegate MINTS an object and returns it. JS drops its reference the
  // moment the callback returns; only the +0-return contract (retain + autorelease) keeps the object
  // alive for the caller. A bare `__unwrap` handle would hand ObjC an object owned solely by a
  // collectable JS wrapper.
  const fwd = forwarder(
    {
      makeObject: () => __wrapOwned(NSObject, freshObject()), // a fresh +1, JS-owned…
      copyObject: () => __wrapOwned(NSObject, freshObject()), // …and JS lets go of it on return
    },
    MARSHAL_COUNTED,
  );

  // Headless Node has NO ambient ObjC autorelease pool (under AppKit, thread 0's runloop provides
  // one per iteration — ADR-0057 §8). Push one explicitly so the +0 return's autorelease has
  // somewhere to land, exactly as the ambient pool would.
  const pool = addon.pushAutoreleasePool();
  const returned = sendRet(fwd, 'makeObject');
  check('a +0-convention object return reaches ObjC as a real handle', returned !== 0n, returned);
  check(
    'and it is ALIVE for the caller — retain-autoreleased, not merely the wrapper +1',
    // 2 = the JS wrapper's +1 (still in the uniquing map) + the pending autorelease's +1.
    rc(returned) === 2,
    `retainCount=${rc(returned)}`,
  );
  addon.popAutoreleasePool(pool); // drain — the autoreleased +1 goes, the wrapper's stays
  check(
    'the autoreleased +1 drains with the pool, leaving the wrapper owning exactly one',
    rc(returned) === 1,
    `retainCount=${rc(returned)}`,
  );

  const poolB = addon.pushAutoreleasePool();
  const owned = sendRet(fwd, 'copyObject');
  check(
    'a +1-convention (owned) return hands the CALLER its own +1 — never autoreleased',
    // 2 = the JS wrapper's +1 + the caller's +1. An autorelease here would under-retain an
    // overridden copyWithZone: / init and crash the caller once the pool drained.
    rc(owned) === 2,
    `retainCount=${rc(owned)}`,
  );
  addon.popAutoreleasePool(poolB);
  check(
    "the owned return's +1 SURVIVES the pool drain (it is the caller's, not autoreleased)",
    rc(owned) === 2,
    `retainCount=${rc(owned)}`,
  );
  addon.release(owned); // the caller (us) relinquishes its +1

  addon.release(fwd);
}

// ── Leg D — negative controls: a spec fault is loud + contained, never a C-ABI unwind ──────────
{
  // The k73 lesson — write the negative control. A descriptor that misses one of its own selectors
  // must NOT quietly hand the callback a raw bigint under a declared NSString: that is the exact lie
  // this surface removes. It throws, is reported, and the trampoline substitutes its typed default.
  const partial = rt.__methodMarshal({ 'takeSelector:': { args: [SEL], ret: RAW } });
  const reported = [];
  onCallbackError((e) => reported.push(String(e)));

  let called = 0;
  const fwd = forwarder({ takeObject_: () => called++, takeSelector_: () => called++ }, partial);
  const str = addon.cfstr('uncovered');
  sendObj(fwd, 'takeObject:', str); // covered by the SPEC, NOT by the partial descriptor

  check('an uncovered selector never reaches the JS side with a raw handle', called === 0, called);
  check(
    'it is reported as a loud spec bug (contained — no C-ABI unwind)',
    reported.length === 1 && reported[0].includes('no inbound value descriptor for takeObject:'),
    reported[0],
  );

  onCallbackError(null);
  addon.release(str);
  addon.release(fwd);
}

{
  // Returning a DISPOSED wrapper: contained, and the trampoline gets its typed nil default —
  // a thrown ObjectDisposedError, never a use-after-free inside the framework.
  const reported = [];
  onCallbackError((e) => reported.push(String(e)));

  const dead = __wrapOwned(NSMutableString, addon.cfstr('doomed'));
  const deadHandle = rt.__unwrap(dead);
  dead[Symbol.dispose]();

  const fwd = forwarder({ makeObject: () => dead }, MARSHAL);
  const returned = sendRet(fwd, 'makeObject');

  check('returning a disposed wrapper yields the typed nil default, not a dangling id', returned === 0n, returned);
  check(
    'and it is reported (ObjectDisposedError), contained at the boundary',
    reported.length === 1 && reported[0].includes('Disposed'),
    reported[0],
  );
  void deadHandle;
  onCallbackError(null);
  addon.release(fwd);
}

// ── The no-descriptor path: every pre-k79 battery depends on it staying raw ────────────────────
{
  const seen = [];
  const fwd = forwarder({ takeObject_: (o) => seen.push(o) }); // no marshal
  const str = addon.cfstr('raw');
  sendObj(fwd, 'takeObject:', str);
  check(
    'a callback registered WITHOUT a descriptor still traffics in raw bigint handles',
    typeof seen[0] === 'bigint' && seen[0] === str,
    typeof seen[0],
  );
  addon.release(str);
  addon.release(fwd);
}

console.log(failures === 0 ? '\nALL CHECKS PASSED' : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);

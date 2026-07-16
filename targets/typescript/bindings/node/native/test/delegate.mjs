// Integration check for the on-thread-0 delegate / data-source INBOUND surface
// (delegate-inbound-on-main-k38, realising the on-thread-0 slice of ADR-0059 §3(delegate) / §6
// (keep-alive) / §5(on-thread-0) / §7). The delegate dual of inbound.mjs's subclass leg.
//
// Loads the REAL Swift-native addon, installs it as `__dispatch`, and proves the delegate surface:
//
//   Leg A — direct forwarder (a bare test protocol AWDataSource): the per-protocol forwarding class,
//     the set-time `respondsToSelector:` snapshot (exact @optional fidelity — YES for an implemented
//     method, NO for an unimplemented one, both via the per-instance bitset), a value-returning
//     method reaching JS and returning its result to ObjC, and boundary containment of a JS throw.
//
//   Leg B — genuine framework (NSKeyedArchiver): a JS delegate implementing
//     `archiver:willEncodeObject:` (value-returning id) is installed via the full runtime path
//     (`__installDelegate` → `bindDelegate`: send `setDelegate:`, associate, balance the alloc +1).
//     NSKeyedArchiver's `delegate` is `assign` (unretained), so the forwarder survives ONLY because
//     of the associated-object keep-alive (ADR-0059 §6); the framework then consults
//     `respondsToSelector:` and calls the delegate synchronously during `encodeObject:`/`finishEncoding`.
//     A second delegate that does NOT implement the method — sharing the SAME per-protocol class —
//     is never called (its per-instance snapshot says NO), proving the per-instance design end-to-end.
//
// Headless: Foundation-only (a defined protocol + NSKeyedArchiver), no AppKit.
//
// Run: node targets/typescript/bindings/node/native/test/delegate.mjs
// Requires: the addon built (build.sh) and the runtime built (npm run build in runtime/).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const runtimeUrl = new URL('../../runtime/dist/index.js', import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

const rt = await import(runtimeUrl.href);
const {
  __class,
  __sel,
  __installDispatch,
  __registerCallback,
  __forwarderClass,
  __respondsBits,
  __protocolArg,
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

// The new delegate primitives the addon must export (on top of the outbound spine + subclass inbound).
for (const name of [
  'defineForwarder', 'setRespondsBits', 'associate', 'allocInitWithObject',
  'aw_ts_msg_P_b', 'aw_ts_msg_PP_v', 'aw_ts_msg_0_v',
]) {
  check(`addon exports ${name}`, typeof addon[name] === 'function');
}

// ── Leg A — direct forwarder: respondsToSelector: fidelity + value-return + containment ───────────
// Test protocol AWDataSource: `numberOfItems` (q@:, no-arg NSInteger) + `compareItem:` (q@:@, one id
// arg → NSInteger). Both encodings install a trampoline, so both enter the responds snapshot — the
// unimplemented one is answered NO from the bitset (the snapshot path), not the class fallback.
const DATASOURCE = {
  protocol: 'AWDataSource',
  methods: [
    ['numberOfItems', 'q@:'],
    ['compareItem:', 'q@:@'],
  ],
  setter: 'setDataSource:',
  propertyKey: 'dataSource',
  associate: true,
};

// Build a forwarder for a JS delegate implementing ONLY numberOfItems (not compareItem_).
function makeForwarder(jsObj, spec) {
  const cls = __forwarderClass(spec); // synthesize (memoized) + install the inbound invoker
  const fwd = addon.allocInit(cls); // +1 owned forwarder instance
  const cbid = __registerCallback(jsObj);
  addon.setBackRef(fwd, cbid);
  addon.setRespondsBits(fwd, __respondsBits(jsObj, spec.methods));
  return fwd;
}

{
  const ds = { numberOfItems: () => 7 }; // implements numberOfItems; not compareItem_.
  const fwd = makeForwarder(ds, DATASOURCE);

  // The per-protocol forwarding class is a real, distinct Class handle.
  check('forwarder wraps a nonzero id', typeof fwd === 'bigint' && fwd !== 0n, fwd);

  // respondsToSelector: — the exact @optional snapshot (the load-bearing correctness point).
  const respImpl = addon.aw_ts_msg_P_b(fwd, __sel('respondsToSelector:'), __sel('numberOfItems'));
  check('respondsToSelector:(numberOfItems) → YES (implemented)', respImpl === true, respImpl);
  const respMissing = addon.aw_ts_msg_P_b(fwd, __sel('respondsToSelector:'), __sel('compareItem:'));
  check('respondsToSelector:(compareItem:) → NO (unimplemented — exact fidelity)', respMissing === false, respMissing);
  // A selector not in the protocol falls back to NSObject's table (inherited methods answer YES).
  const respInherited = addon.aw_ts_msg_P_b(fwd, __sel('respondsToSelector:'), __sel('isEqual:'));
  check('respondsToSelector:(isEqual:) → YES (inherited NSObject method)', respInherited === true, respInherited);

  // Value-returning delivery: send numberOfItems into the forwarder → JS runs → returns to ObjC.
  const n = addon.aw_ts_msg_0_q(fwd, __sel('numberOfItems'));
  check('value-returning delegate method → JS returned 7', Number(n) === 7, n);

  addon.release(fwd); // no association in this leg — drop the alloc +1.
}

// Boundary containment: a delegate method that throws is contained (ADR-0059 §7).
{
  const boom = { numberOfItems: () => { throw new Error('boom'); } };
  const fwd = makeForwarder(boom, DATASOURCE);
  let reported = 0;
  onCallbackError((_err, ctx) => {
    reported++;
    check('onCallbackError carries the selector context', ctx.selector === 'numberOfItems', ctx.selector);
  });
  const n = addon.aw_ts_msg_0_q(fwd, __sel('numberOfItems'));
  check('throwing delegate method contained → typed default 0 (no C-ABI unwind)', Number(n) === 0, n);
  check('onCallbackError fired exactly once for the contained throw', reported === 1, reported);
  onCallbackError(null);
  addon.release(fwd);
}

// ── Leg B — genuine framework: NSKeyedArchiver willEncodeObject: (value-returning, weak delegate) ──
// The forwarder is kept alive ONLY by the associated-object keep-alive (NSKeyedArchiver.delegate is
// `assign`); if the keep-alive failed, the forwarder would dealloc once `__protocolArg` balances the
// alloc +1, the archiver's weak delegate would go nil, and willEncodeObject: would never fire.
//
// Since `emitted-delegate-spec-k84` this leg drives the EMITTED path: the spec is per-protocol (no
// setter, no key, no associate flag — those ride the slot), and the install is the two steps an
// emitted setter body performs, in that order — `__protocolArg` then the ObjC send.
const ARCHIVER_DELEGATE = {
  protocol: 'NSKeyedArchiverDelegate',
  methods: [['archiver:willEncodeObject:', '@@:@@']],
};

// Encode a small object graph through an archiver whose delegate is `jsDelegate`; returns nothing —
// the JS delegate observes the willEncode calls. `initForWritingWithMutableData:` (keyed) is used so
// there is a real `setDelegate:` owner to associate against.
function driveArchiver(jsDelegate) {
  const data = addon.aw_ts_msg_0_P(__class('NSMutableData'), __sel('data')); // +1 (folded)
  const archiver = addon.allocInitWithObject(
    __class('NSKeyedArchiver'), __sel('initForWritingWithMutableData:'), data,
  ); // +1 owned
  // Exactly what the emitted `NSKeyedArchiver.setDelegate_` body does — mint-and-associate the
  // forwarder, then send. `true` is the associate arm: the archiver's delegate is `assign`.
  const fwd = __protocolArg(archiver, 'setDelegate:#0', jsDelegate, ARCHIVER_DELEGATE, true);
  addon.aw_ts_msg_P_v(archiver, __sel('setDelegate:'), fwd);

  // A small graph: an NSArray of two strings. willEncodeObject: fires for the encoded objects.
  const arr = addon.aw_ts_msg_0_P(__class('NSMutableArray'), __sel('array')); // +1 (folded)
  const s1 = addon.cfstr('alpha'); // +1 owned
  const s2 = addon.cfstr('beta'); // +1 owned
  addon.aw_ts_msg_P_v(arr, __sel('addObject:'), s1);
  addon.aw_ts_msg_P_v(arr, __sel('addObject:'), s2);
  const rootKey = addon.cfstr('root'); // +1 owned
  addon.aw_ts_msg_PP_v(archiver, __sel('encodeObject:forKey:'), arr, rootKey);
  addon.aw_ts_msg_0_v(archiver, __sel('finishEncoding'));

  // Cleanup: releasing the archiver drops the association → the forwarder deallocs.
  addon.release(rootKey);
  addon.release(s1);
  addon.release(s2);
  addon.release(arr);
  addon.release(archiver);
  addon.release(data);
}

{
  // A delegate that DOES implement archiver:willEncodeObject: (value-returning identity passthrough).
  let willEncodeCount = 0;
  const impl = {
    archiver_willEncodeObject_: (_archiver, obj) => {
      willEncodeCount++;
      return obj; // +0 passthrough — encode the object unchanged.
    },
  };
  driveArchiver(impl);
  check(
    'NSKeyedArchiver drove willEncodeObject: on the JS delegate (kept alive by the association)',
    willEncodeCount > 0,
    `count=${willEncodeCount}`,
  );

  // A delegate that does NOT implement it — sharing the SAME per-protocol class. Its per-instance
  // snapshot says NO, so the framework never calls it: exact @optional fidelity end-to-end.
  let strayCount = 0;
  const notImpl = { somethingElse: () => strayCount++ }; // no archiver_willEncodeObject_.
  driveArchiver(notImpl);
  check(
    'a delegate not implementing willEncodeObject: is never called (respondsToSelector: NO honored)',
    strayCount === 0,
    `count=${strayCount}`,
  );
}

console.log(failures === 0 ? '\nALL CHECKS PASSED' : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);

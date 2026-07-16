// Integration check for the on-thread-0 dynamic-subclass §4 surface — `$super`, overridable `dealloc`,
// and `class_addMethod` added methods (super-dealloc-on-main-k40, realising the on-thread-0 slice of
// ADR-0059 §4). The §4 dual of inbound.mjs (subclass) / delegate.mjs (delegate) / block.mjs (blocks).
//
// Loads the REAL Swift-native addon, installs it as `__dispatch`, and proves three things:
//
//   §1 $super — a JS override of `-isEqual:` that delegates to `this.$super.isEqual_(other)` reaches
//     the BASE `-[NSObject isEqual:]` (identity) — NOT re-entering its own override (the ADR-0034
//     `call-next-method` infinite-recursion trap native `super.` would hit). Value-returning; the
//     override negates the base answer, so a correct, terminating result proves both reach-base and
//     no-recursion. The `aw_ts_super_P_b` primitive is also exercised directly. Both super entries
//     are now GENERATED from the IR (super-send-table-k63) — this suite proves the generated
//     `aw_ts_super_0_v` / `aw_ts_super_P_b` serve the shapes the hand-written pair served.
//
//   §2 dealloc — a synthesized subclass / forwarder deallocing ON THREAD 0 runs its JS `dealloc`
//     override (if any, against a LIVE handle — ADR-0057 §6 ordering), chains `$super.dealloc()`, and
//     **releases its `callbacks`-registry keep-alive** — closing the loop k37/k38 left open (the strong
//     registry entry that pinned a bound instance was, until now, never released). Proven for: a
//     subclass with a JS `dealloc` (dispose path), a subclass with NO override (native chains super),
//     a directly-released forwarder, and a genuine framework-driven forwarder dealloc (NSKeyedArchiver
//     association drop). After each, `__resolveCallback(id)` is `undefined`.
//
//   §3 added methods — a `class_addMethod`-added target-action `-buttonClicked:` (a selector NOT on
//     the base) is callable from ObjC and reaches the JS method; boundary containment holds.
//
// Headless: Foundation-only (NSObject subclasses + NSKeyedArchiver), no AppKit.
//
// Run: node targets/typescript/bindings/node/native/test/super.mjs
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
  __registerCallback,
  __resolveCallback,
  __forwarderClass,
  __respondsBits,
  __allocSubclass,
  __detectOverrides,
  __wrapBorrowed,
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

// The new §4 primitives the addon must export (on top of the outbound spine + inbound surfaces).
for (const name of ['installDeallocDeliverer', 'aw_ts_super_0_v', 'aw_ts_super_P_b']) {
  check(`addon exports ${name}`, typeof addon[name] === 'function');
}

const NSOBJECT = __class('NSObject');

// ── §1 — $super: value-returning super-send reaches base, no recursion into the override ──────────
// Equatable overrides -isEqual: (c@:@); the override delegates to this.$super.isEqual_(other) and
// NEGATES it. If $super re-entered the override, this would infinite-loop; a terminating, correct
// (identity-based, then negated) answer proves both reach-base and no-recursion.
const ISEQUAL_OVERRIDE = [['isEqual:', 'c@:@']]; // BOOL ret, self, _cmd, one id arg
class Equatable extends NSObject {
  constructor() {
    super(__subclassAlloc(Equatable, NSOBJECT, ISEQUAL_OVERRIDE));
    __bindSubclass(this);
  }
  isEqual_(otherId) {
    // this.$super.isEqual_(other) → [super isEqual: other] via objc_msgSendSuper to NSObject (identity).
    const base = rt.__dispatch.aw_ts_super_P_b(__unwrap(this), NSOBJECT, __sel('isEqual:'), otherId);
    return !base; // negate so we can tell the override ran AND the base was consulted.
  }
}

{
  using a = new Equatable();
  using b = new Equatable();
  // [a isEqual: a] → base YES (a===a) → override negates → NO.
  const same = addon.aw_ts_msg_P_b(__unwrap(a), __sel('isEqual:'), __unwrap(a));
  check('$super reaches base -isEqual: (a≡a → base YES → override negates → false)', same === false, same);
  // [a isEqual: b] → base NO (a≠b) → override negates → YES. (Reaching here at all ⇒ no recursion.)
  const diff = addon.aw_ts_msg_P_b(__unwrap(a), __sel('isEqual:'), __unwrap(b));
  check('$super does not re-enter the override (a≠b → base NO → override negates → true)', diff === true, diff);

  // The aw_ts_super_P_b primitive directly: begins lookup at NSObject, so it is the base identity.
  const superSame = addon.aw_ts_super_P_b(__unwrap(a), NSOBJECT, __sel('isEqual:'), __unwrap(a));
  check('aw_ts_super_P_b(a, NSObject, isEqual:, a) → base identity YES', superSame === true, superSame);
  const superDiff = addon.aw_ts_super_P_b(__unwrap(a), NSOBJECT, __sel('isEqual:'), __unwrap(b));
  check('aw_ts_super_P_b(a, NSObject, isEqual:, b) → base identity NO', superDiff === false, superDiff);
}

// ── §1b — the GENERIC k96 mechanism: __allocSubclass + auto-detected overrides + the `$super` ─────
// proxy, exercised against the REAL addon — the emitter-facing half §1 hand-rolls. `NSBase` stands
// in for what `emit-typescript` generates: a class registered under a real ObjC name, carrying a
// `static __overridable` catalogue (`emitted-subclass-surface-k96`). `AutoEquatable` is the
// hand-written-app shape: no hand-listed override array, no raw `aw_ts_super_*` call — just
// `__allocSubclass(AutoEquatable)` and `this.$super.isEqual_(other)`.
class NSBase extends NSObject {
  static {
    rt.__registerClass('NSObject', NSBase); // stands in for the emitted NSObject-rooted class
  }
}
// The emitted `static readonly __overridable` catalogue (k96) — plain JS has no field modifier for
// it, so this test assigns it the way the emitted `.ts`'s compiled `.js` output would carry it.
NSBase.__overridable = [
  {
    name: 'isEqual_',
    selector: 'isEqual:',
    encoding: 'c@:@',
    superEntry: 'aw_ts_super_P_b',
    args: [{ k: 'obj' }],
    ret: { k: 'raw' },
  },
];
class AutoEquatable extends NSBase {
  constructor() {
    super(__allocSubclass(AutoEquatable));
    __bindSubclass(this);
  }
  isEqual_(otherId) {
    // The override's own arg arrives raw (no marshal wired for THIS test — a later concern); wrap
    // it so the $super OBJ-kind arg conversion (`__unwrap`) has a genuine wrapper to convert.
    const other = __wrapBorrowed(otherId);
    const base = this.$super.isEqual_(other); // → aw_ts_super_P_b(recv, NSBase's own class, sel, id)
    return !base;
  }
}

{
  const detected = __detectOverrides(AutoEquatable);
  check(
    '__detectOverrides finds isEqual: from the merged catalogue',
    detected.length === 1 && detected[0][0] === 'isEqual:' && detected[0][1] === 'c@:@',
    JSON.stringify(detected),
  );

  using a = new AutoEquatable();
  using b = new AutoEquatable();
  const same = addon.aw_ts_msg_P_b(__unwrap(a), __sel('isEqual:'), __unwrap(a));
  check(
    '__allocSubclass + $super: a≡a → base YES → override negates → false',
    same === false,
    same,
  );
  const diff = addon.aw_ts_msg_P_b(__unwrap(a), __sel('isEqual:'), __unwrap(b));
  check(
    '__allocSubclass + $super: a≠b → base NO → override negates → true (no re-entrant recursion)',
    diff === true,
    diff,
  );
}

// ── §2a — dealloc: a subclass with a JS override runs it (live handle) + closes the registry loop ─
// Tracked defines dealloc(): it observes a LIVE handle (ADR-0057 §6 ordering), then chains
// this.$super.dealloc(). Disposing it triggers dealloc synchronously on thread 0.
class Tracked extends NSObject {
  constructor(log) {
    super(__subclassAlloc(Tracked, NSOBJECT, [])); // no method overrides; dealloc is auto-installed.
    this.log = log;
    this.cbid = __bindSubclass(this);
  }
  dealloc() {
    this.log.push('dealloc');
    // ADR-0057 §6: the disposed flag flips AFTER release, so the override sees a live handle.
    this.log.push(typeof __unwrap(this) === 'bigint' && __unwrap(this) !== 0n ? 'live' : 'dead');
    // Chain [super dealloc] — the documented user obligation (forgetting it leaks, as in ObjC).
    rt.__dispatch.aw_ts_super_0_v(__unwrap(this), NSOBJECT, __sel('dealloc'));
  }
}
{
  const log = [];
  let cbid;
  {
    using t = new Tracked(log);
    cbid = t.cbid;
    check('bound subclass is registered (pinned by the keep-alive)', __resolveCallback(cbid) !== undefined);
  } // dispose → release → dealloc on thread 0
  check('JS dealloc override ran on dispose (thread 0)', log.includes('dealloc'), JSON.stringify(log));
  check('the handle was LIVE during the override (ADR-0057 §6 ordering)', log.includes('live'), JSON.stringify(log));
  check('dealloc released the subclass registry entry (k37/k38 loop closed)', __resolveCallback(cbid) === undefined);
}

// ── §2b — dealloc: a subclass with NO JS override still closes the loop (native chains [super dealloc]) ─
class Plain extends NSObject {
  constructor() {
    super(__subclassAlloc(Plain, NSOBJECT, []));
    this.cbid = __bindSubclass(this);
  }
}
{
  let cbid;
  {
    using p = new Plain();
    cbid = p.cbid;
  } // dispose → dealloc; no JS override → native chains [super dealloc]; registry still released.
  check('a no-override subclass dealloc still releases the registry (native super-chain)', __resolveCallback(cbid) === undefined);
}

// ── §2c — dealloc: a directly-released forwarder closes the loop ──────────────────────────────────
const DATASOURCE = {
  protocol: 'AWSuperDataSource',
  methods: [['numberOfItems', 'q@:']],
  setter: 'setDataSource:',
  propertyKey: 'dataSource',
  associate: true,
};
{
  const cls = __forwarderClass(DATASOURCE); // synthesize (memoized) + install the dealloc IMP
  const fwd = addon.allocInit(cls); // +1 owned forwarder instance
  const cbid = __registerCallback({ numberOfItems: () => 3 });
  addon.setBackRef(fwd, cbid);
  check('bound forwarder is registered (pinned)', __resolveCallback(cbid) !== undefined);
  addon.release(fwd); // last ref → forwarder deallocs on thread 0 → dealloc IMP → registry released
  check('forwarder dealloc released the registry entry (loop closed)', __resolveCallback(cbid) === undefined);
}

// ── §2d — dealloc: a framework-driven forwarder dealloc via the association drop ──────────────────
// NSKeyedArchiver.delegate is `assign` (unretained) — the forwarder lives only by the associated-object
// keep-alive. Releasing the archiver deallocs it, which drops the association, which deallocs the
// forwarder ON THREAD 0 → its dealloc IMP releases the registry (the genuine end-to-end path).
const ARCHIVER_DELEGATE = {
  protocol: 'NSKeyedArchiverDelegate',
  methods: [['archiver:willEncodeObject:', '@@:@@']],
  setter: 'setDelegate:',
  propertyKey: 'delegate',
  associate: true,
};
{
  const data = addon.aw_ts_msg_0_P(__class('NSMutableData'), __sel('data')); // +1 (folded)
  const archiver = addon.allocInitWithObject(
    __class('NSKeyedArchiver'),
    __sel('initForWritingWithMutableData:'),
    data,
  ); // +1 owned
  const cls = __forwarderClass(ARCHIVER_DELEGATE);
  const fwd = addon.allocInit(cls); // +1 owned
  const cbid = __registerCallback({ archiver_willEncodeObject_: (_a, o) => o });
  addon.setBackRef(fwd, cbid);
  addon.setRespondsBits(fwd, __respondsBits({ archiver_willEncodeObject_: () => {} }, ARCHIVER_DELEGATE.methods));
  // The emitted setter's two steps (`emitted-delegate-spec-k84`): associate the forwarder (the strong
  // keep-alive — NSKeyedArchiver's delegate is `assign`), balance the alloc +1, then send.
  addon.associate(archiver, 'setDelegate:#0', fwd);
  addon.release(fwd);
  addon.aw_ts_msg_P_v(archiver, __sel('setDelegate:'), fwd);
  check('archiver forwarder registered (kept alive only by the association)', __resolveCallback(cbid) !== undefined);

  addon.release(archiver); // last ref → archiver deallocs → association releases fwd → fwd deallocs
  addon.release(data);
  check('framework-driven forwarder dealloc released the registry entry', __resolveCallback(cbid) === undefined);
}

// ── §3 — added methods: a class_addMethod target-action reaches JS (+ containment) ────────────────
// buttonClicked_ is NOT on NSObject — it is ADDED via class_addMethod (encoding v@:@, an added
// target-action). ObjC dispatch to it reaches the JS method with the sender arg.
const BUTTON_METHODS = [['buttonClicked:', 'v@:@']]; // void, self, _cmd, id sender
class Button extends NSObject {
  constructor(log) {
    super(__subclassAlloc(Button, NSOBJECT, BUTTON_METHODS));
    this.log = log;
    __bindSubclass(this);
  }
  buttonClicked_(senderId) {
    this.log.push(senderId); // observe the target-action fired, carrying the sender id.
  }
}
{
  using btn = new Button([]);
  // respondsToSelector:(buttonClicked:) → YES: it is a real, added method (not a snapshot).
  const responds = addon.aw_ts_msg_P_b(__unwrap(btn), __sel('respondsToSelector:'), __sel('buttonClicked:'));
  check('added target-action is a real method (respondsToSelector: buttonClicked: → YES)', responds === true, responds);

  // Send the added selector from ObjC (aw_ts_msg_P_v is (id,SEL,id)->void). The sender is NSObject.
  const log = btn.log;
  rt.__dispatch.aw_ts_msg_P_v(__unwrap(btn), __sel('buttonClicked:'), NSOBJECT);
  check('added target-action reached the JS method with the sender', log.length === 1 && log[0] === NSOBJECT, JSON.stringify(log.map(String)));
}

// A throwing added-method body is contained at the boundary (ADR-0059 §7).
{
  class Boom extends NSObject {
    constructor() {
      super(__subclassAlloc(Boom, NSOBJECT, BUTTON_METHODS));
      __bindSubclass(this);
    }
    buttonClicked_() {
      throw new Error('action boom');
    }
  }
  using x = new Boom();
  let reported = 0;
  onCallbackError((_err, ctx) => {
    reported++;
    check('onCallbackError carries the added-selector context', ctx.selector === 'buttonClicked:', ctx.selector);
  });
  rt.__dispatch.aw_ts_msg_P_v(__unwrap(x), __sel('buttonClicked:'), NSOBJECT);
  check('a throwing target-action is contained (void returns, no C-ABI unwind)', true);
  check('onCallbackError fired once for the contained throw', reported === 1, reported);
  onCallbackError(null);
}

console.log(failures === 0 ? '\nALL CHECKS PASSED' : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);

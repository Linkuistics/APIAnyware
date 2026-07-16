// The dynamic class wrap, against the REAL addon (`dynamic-class-wrap-k88`).
//
// The defect: an `id` the IR names no class for minted a bare `NSObject`. `-[NSArray objectAtIndex:]` is
// declared to return `id`, so `NSArray.array().objectAtIndex_(0)` handed back a wrapper carrying **none of
// NSString's methods** — and that is why a protocol-qualified slot could not honestly be typed by its
// interface (`protocol-binding-surface-k89`): the type would promise members the value lacks.
//
// The fix: the wrap primitives' **class-less arm** (`__wrapRetained(id)`, one arg) resolves the object's
// class through `object_getClass` and climbs `class_getSuperclass` to the nearest class the binding
// declares (the gerbil ADR-0020 "nearest bound ancestor" rule, at the value boundary).
//
// The climb is not a nicety — it is the whole mechanism, and this battery is what proved it. Cocoa is
// built from **class clusters**: an NSString is really a `__NSCFString` or an `NSTaggedPointerString`, an
// NSArray really an `__NSArrayI`. Those are private, absent from every header and so from the IR. A first
// cut resolved the object's *literal* class and therefore handed back a method-less stand-in for almost
// every real object — the very lie it was written to remove. Check 2 below is the measurement that caught it.
//
// Everything here is measured against the live runtime — `instanceof` on real objects, ownership off
// `-retainCount` — never asserted.
//
// Run: node targets/typescript/bindings/node/native/test/dynamic-class.mjs
// Requires: the addon built (build.sh) and the runtime built (npm run build in runtime/).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const runtimeUrl = new URL('../../runtime/dist/index.js', import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

// Namespace import: `__dispatch` is a live ESM binding `__installDispatch` reassigns.
const rt = await import(runtimeUrl.href);
const { NSObject, __cfstr, __class, __installDispatch, __registerClass, __sel, __unwrap, __wrapOwned, __wrapRetained } =
  rt;

const addon = require(addonPath);
__installDispatch(addon);

let failures = 0;
function check(label, cond, detail) {
  const ok = Boolean(cond);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail !== undefined ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

// -retainCount as a plain unsigned scalar read (the 0_Q entry; does not mutate the count).
const rc = (id) => Number(rt.__dispatch.aw_ts_msg_0_Q(id, __sel('retainCount')));

check('addon exports classOf', typeof addon.classOf === 'function');
check('addon exports superclassOf', typeof addon.superclassOf === 'function');

// ── Emitted-shaped bindings: each registers itself from its static block, as emit_class writes. ──
class NSString extends NSObject {
  static {
    __registerClass('NSString', NSString);
  }
  static __cls = __class('NSString');
  static of(s) {
    return __wrapOwned(NSString, __cfstr(s)); // a DECLARED class — the IR named it
  }
  length() {
    return Number(rt.__dispatch.aw_ts_msg_0_Q(__unwrap(this), __sel('length')));
  }
}

class NSArray extends NSObject {
  static {
    __registerClass('NSArray', NSArray);
  }
  static __cls = __class('NSArray');
  static arrayWithObject_(o) {
    return __wrapRetained(NSArray, rt.__dispatch.aw_ts_msg_P_P(NSArray.__cls, __sel('arrayWithObject:'), __unwrap(o)));
  }
  count() {
    return Number(rt.__dispatch.aw_ts_msg_0_Q(__unwrap(this), __sel('count')));
  }
  // -[NSArray objectAtIndex:] is declared `id` — the IR names NO class, so this is the class-less arm
  // exactly as emit_class now renders it: `return __wrapRetained(__ret)!;`
  objectAtIndex_(index) {
    const __ret = rt.__dispatch.aw_ts_msg_Q_P(__unwrap(this), __sel('objectAtIndex:'), index);
    return __wrapRetained(__ret);
  }
}

// ── 1–2. The class clusters are real, and they are why the naive resolution fails. ───────────────
const hello = NSString.of('hello');
const helloClass = addon.classOf(__unwrap(hello));
const helloClassName = addon.className(helloClass);
check(
  "an NSString's REAL class is a private cluster class, not NSString",
  helloClassName !== 'NSString',
  helloClassName,
);
// …and it is reachable from NSString by climbing — which is what makes the wrap sound.
let climbed = null;
for (let c = helloClass; c !== 0n; c = addon.superclassOf(c)) {
  if (addon.className(c) === 'NSString') {
    climbed = c;
    break;
  }
}
check('…but NSString IS on its superclass chain (the climb is what recovers it)', climbed !== null);

// ── 3. The headline, through a FRESH mint (not the uniquing path). ───────────────────────────────
// Dispose the JS wrapper first, so reading the string back out of the array must genuinely MINT —
// otherwise uniquing would return the already-NSString-typed wrapper and prove nothing.
const arr = NSArray.arrayWithObject_(hello);
hello[Symbol.dispose]();
const element = arr.objectAtIndex_(0);

check('a class-less `id` return mints as the nearest BOUND class', element instanceof NSString, element?.constructor?.name);
check("…so the class's methods are really there", element?.length?.() === 5, `length=${element.length()}`);
check('…and it is NOT a bare NSObject (the pre-k88 lie)', element?.constructor !== NSObject);

// The cluster walk applies to every class, not just strings: an array-of-arrays round-trips too
// (the real class is an `__NSArrayI`-family private, and it climbs to NSArray).
const inner = NSArray.arrayWithObject_(element);
const outer = NSArray.arrayWithObject_(inner);
const innerClassName = addon.className(addon.classOf(__unwrap(inner)));
inner[Symbol.dispose]();
const readBack = outer.objectAtIndex_(0);
check("an array's real class is also a cluster private", innerClassName !== 'NSArray', innerClassName);
check('…and it too mints as its nearest bound class', readBack instanceof NSArray, readBack?.constructor?.name);
check('…with working methods', readBack?.count?.() === 1);

// ── 4. Uniquing still holds: the live-wrapper path never asks the object for its class. ──────────
const same = arr.objectAtIndex_(0);
check('a live wrapper is returned as-is (uniquing, zero class crossings)', same === element);

// ── 5. Ownership MEASURED — the class-less arm must not disturb the retain axis. ─────────────────
// A heap object with a real retain count (a tagged-pointer string reports UINT_MAX and would make this
// check vacuous — which it silently did before this comment existed).
const probe = NSArray.arrayWithObject_(readBack); // a genuine heap NSArray
const holder = NSArray.arrayWithObject_(probe); // holder retains probe
const probeId = __unwrap(probe);
const before = rc(probeId);
probe[Symbol.dispose](); // JS gives its +1 back
const minted = holder.objectAtIndex_(0); // fresh mint through the class-less arm
check('the re-mint resolves the bound class', minted instanceof NSArray);
check(
  'the mint owns exactly one +1 — uniform-+1 held across the class-less arm',
  rc(__unwrap(minted)) === before,
  `before=${before} after=${rc(__unwrap(minted))}`,
);

// ── 6. THE NEGATIVE CONTROL: NO bound ancestor anywhere on the chain. ────────────────────────────
// A real object whose entire ancestry is unregistered here — NSDateFormatter → NSFormatter → NSObject,
// none of which this battery binds. (A CFString literal would NOT test this: its chain reaches the
// NSString bound above, so it always finds an ancestor.) It must still round-trip through §5b's
// stand-in: the true handle, the true name, a stable identity — never a throw, and never a silent
// substitution of some other class.
const fmtId = addon.allocInit(__class('NSDateFormatter'));
const fmtRealName = addon.className(addon.classOf(fmtId));
const stand = __wrapOwned(fmtId);
check('an object with NO bound ancestor still wraps, and does not throw', stand instanceof NSObject);
check('…through a stand-in carrying the TRUE ObjC class name', stand?.constructor?.name === fmtRealName, fmtRealName);
check('…which is not one of the bound classes', stand?.constructor !== NSString && stand?.constructor !== NSArray);
check('…and not the bare root either — the name is preserved', stand?.constructor !== NSObject);
stand?.[Symbol.dispose]();

// ── 7. A DECLARED class still wins (marshal.ts's reason: the IR knows what the runtime will not say). ──
const declared = NSString.of('declared');
check('a declared class still wins over the object’s real one', declared.constructor === NSString, declared.constructor.name);
declared[Symbol.dispose]();

console.log(failures === 0 ? '\nALL PASS' : `\n${failures} FAILURE(S)`);
process.exit(failures === 0 ? 0 : 1);

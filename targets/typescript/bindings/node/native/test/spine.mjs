// Integration check for the outbound dispatch spine (napi-dispatch-spine-k35).
//
// Loads the REAL Swift-native N-API addon, installs it as the runtime's `__dispatch`
// backend (replacing the throwing NOT_LOADED sentinel), and round-trips a minimal
// emitted-golden-shaped binding — construct → dispatch → wrap → dispose — proving the
// ADR-0011 seam is real end-to-end on arm64. Mirrors the shape the emitter produces
// (tkobject.ts / seam.type-test.ts): a class with `static __cls = __class(name)`, method
// bodies that call `rt.__dispatch.aw_ts_msg_<codes>(...)` and wrap via `__wrap*`.
//
// Run: node targets/typescript/bindings/node/native/test/spine.mjs
// Requires: the addon built (build.sh) and the runtime built (npm run build in runtime/).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const runtimeUrl = new URL('../../runtime/dist/index.js', import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

// Namespace import, not destructuring: `__dispatch` is an ESM LIVE binding that
// `__installDispatch` reassigns — destructuring it captures the stale NOT_LOADED value.
// A real emitted module uses `import { __dispatch }` (also live), so accessing `rt.__dispatch`
// faithfully mirrors that. Plain functions (__class, __wrapOwned, …) read the live binding
// internally, so those are safe to alias.
const rt = await import(runtimeUrl.href);
const {
  NSObject,
  __class,
  __sel,
  __installDispatch,
  __unwrap,
  __wrapOwned,
  __wrapRetained,
  __cfstr,
  withAutoreleasePool,
} = rt;

// Install the real backend BEFORE any class body evaluates its `static __cls = __class(...)`.
const addon = require(addonPath);
__installDispatch(addon);

let failures = 0;
function check(label, cond, detail) {
  const ok = Boolean(cond);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail !== undefined ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

// The fixed primitives + the per-signature entries all registered on the addon.
for (const name of [
  'getClass', 'getSelector', 'release', 'pushAutoreleasePool', 'popAutoreleasePool', 'cfstr',
  'aw_ts_msg_0_Q', 'aw_ts_msg_0_q', 'aw_ts_msg_q_v', 'aw_ts_msg_0_P', 'aw_ts_msg_P_P',
  'aw_ts_msg_0_R', 'aw_ts_msg_P_G',
]) {
  check(`addon exports ${name}`, typeof addon[name] === 'function');
}

// ── A golden-shaped NSString binding ──────────────────────────────────────────────────────
class NSString extends NSObject {
  static __cls = __class('NSString');
  // +1 owned constructor via the cfstr primitive → __wrapOwned (ADR-0057 §2).
  static of(s) {
    return __wrapOwned(NSString, __cfstr(s));
  }
  // Scalar (unsigned) return: -[NSString length] → aw_ts_msg_0_Q.
  length() {
    return rt.__dispatch.aw_ts_msg_0_Q(__unwrap(this), __sel('length'));
  }
  // Object return with one object arg: -stringByAppendingString: → aw_ts_msg_P_P (+0, retain-folded).
  stringByAppendingString_(other) {
    return __wrapRetained(
      NSString,
      rt.__dispatch.aw_ts_msg_P_P(__unwrap(this), __sel('stringByAppendingString:'), __unwrap(other)),
    );
  }
}

check('NSString.__cls is a nonzero Class handle', typeof NSString.__cls === 'bigint' && NSString.__cls !== 0n, NSString.__cls);

// Extend the NSString binding with a struct-return method (Foundation-only, headless-safe):
// -[NSString rangeOfString:] → NSRange {location, length}. This behaviourally proves the
// Swift struct-return → napi-object marshalling. The CGRect x8 path (aw_ts_msg_0_R) is the
// same mechanism on a larger struct; the substrate spike proved the Swift CGRect ABI
// first-hand, and it exercises live once AppKit is loaded (the sample-app milestone).
NSString.prototype.rangeOfString_ = function rangeOfString_(needle) {
  return rt.__dispatch.aw_ts_msg_P_G(__unwrap(this), __sel('rangeOfString:'), __unwrap(needle));
};

// Wrap the whole round-trip in a native autorelease pool so the +0 autoreleased temporaries
// drain cleanly (exercises pushAutoreleasePool/popAutoreleasePool too).
withAutoreleasePool(() => {
  const hello = NSString.of('hello, spine');
  check('cfstr → -length round-trips', hello.length() === 12n || hello.length() === 12, hello.length());

  const bang = NSString.of('!');
  using combined = hello.stringByAppendingString_(bang);
  check('P_P object dispatch → -length', combined.length() === 13n || combined.length() === 13, combined.length());

  // Struct-by-value return through Swift-native N-API: 'spine' is at index 7, length 5.
  using needle = NSString.of('spine');
  const range = hello.rangeOfString_(needle);
  const rangeShape = range && typeof range.location === 'number' && typeof range.length === 'number';
  check('P_G NSRange struct-return marshals to {location,length}', rangeShape, JSON.stringify(range));
  check('rangeOfString: found the substring', rangeShape && range.location === 7 && range.length === 5, JSON.stringify(range));

  // Deterministic disposal (exercises release / objc_release on thread 0).
  hello[Symbol.dispose]();
  bang[Symbol.dispose]();
});

console.log(failures === 0 ? '\nALL CHECKS PASSED' : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);

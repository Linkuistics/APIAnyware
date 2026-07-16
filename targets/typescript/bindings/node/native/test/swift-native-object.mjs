// Integration check for the Swift-native `s:` residual OBJECT-return marshalling
// (object-bridged-returns-k55, ADR-0061 §3, ADR-0027 → TS/N-API).
//
// Loads the REAL Swift-native N-API addon and exercises the exact **return shape** the emitter's
// `crate::trampoline` generates for an object-returning residual function —
// `napiMakeRetainedObject(env, (<call>) as AnyObject?)` — proving the `passRetained`→+1-handle
// marshalling + the runtime's `__wrapOwned` ownership round-trips a correct, usable object handle.
//
// Why a probe, not a real function: no headless, non-throwing, object-returning Swift-native FREE
// function exists in the macOS SDK — the object residual lives at the *method* level, a recorded
// follow-up-grove deferral (ADR-0061 §4). `hypot` proves the scalar call-by-name *reach*; there is
// no object-returning free function to reach, so this proves the object *marshalling* against a real
// Foundation `String`→`NSString` bridge. `passRetained`'s +1 is a stdlib guarantee; `__wrapOwned`'s
// +1 handling is proven separately by test/retain.mjs (retain-fold-k48).
//
// Run: node targets/typescript/bindings/node/native/test/swift-native-object.mjs
// Requires: the addon built (build.sh) and the runtime built (npm run build in runtime/).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const runtimeUrl = new URL('../../runtime/dist/index.js', import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

const rt = await import(runtimeUrl.href);
const { NSObject, __class, __sel, __installDispatch, __unwrap, __wrapOwned, __cfstr, withAutoreleasePool } = rt;

const addon = require(addonPath);
__installDispatch(addon);

let failures = 0;
function check(label, cond, detail) {
  const ok = Boolean(cond);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail !== undefined ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

// The residual object-return probe entry is registered (the emitted `.ts` call site's target shape).
check('addon exports aw_ts_swift_probe_objectReturn', typeof addon.aw_ts_swift_probe_objectReturn === 'function');

// A minimal NSString binding (the emitted shape) to read the returned object's value back.
class NSString extends NSObject {
  static __cls = __class('NSString');
  length() {
    return rt.__dispatch.aw_ts_msg_0_Q(__unwrap(this), __sel('length'));
  }
  isEqualToString_(other) {
    return rt.__dispatch.aw_ts_msg_P_b(__unwrap(this), __sel('isEqualToString:'), __unwrap(other));
  }
}

withAutoreleasePool(() => {
  // The emitted object-return shape: `return __wrapOwned(<Cls>, __dispatch.aw_ts_swift_<…>())!`.
  // The trampoline bridged a Swift `String` to an `id` and handed a +1 handle; `__wrapOwned` takes it.
  const s = __wrapOwned(NSString, addon.aw_ts_swift_probe_objectReturn());
  check('object-return trampoline yields a nonzero object handle', s !== null);
  const expected = __wrapOwned(NSString, __cfstr('aw-object-return-probe'));
  check(
    'object return → NSString value round-trips',
    s !== null && Boolean(s.isEqualToString_(expected)),
  );
  check(
    'object return → -length is 22',
    s !== null && (s.length() === 22n || s.length() === 22),
    s !== null ? s.length() : 'null',
  );

  // Dispose exercises the release seam on the wrapped +1 — no over-/under-release (clean balance).
  if (s !== null) s[Symbol.dispose]();
});

console.log(failures === 0 ? '\nALL CHECKS PASSED' : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);

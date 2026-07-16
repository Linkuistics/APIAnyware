// Integration check for the constant-read entries (constants-k51, ADR-0025/0055 §6;
// array-constant-symbol-value-k109).
//
// Loads the REAL Swift-native N-API addon and exercises the `aw_ts_const_<code>` reads the
// emitter's constant call sites bind to (`emit_constants.rs`). A constant's value is a
// link-time fact (ADR-0025): the entry `dlsym`s the named global and returns its value by
// result ABI shape. Two behavioural proofs (the leaf's Done-when), Foundation-only so they
// run headless on arm64:
//   - a pointer-valued object global (`NSCocoaErrorDomain`, an `NSString * const`) via
//     aw_ts_const_P, wrapped borrowed at a uniform +1 (__wrapRetained), reaching JS as the
//     correct string;
//   - a scalar global (`NSFoundationVersionNumber`, a `const double`) via aw_ts_const_d,
//     reaching JS as the correct number.
// Plus null-on-missing-symbol (an absent symbol → 0 → __wrapRetained → null).
//
// `aw_ts_const_N_a` (array-constant-symbol-value-k109) has no real byte/char-array global this
// process can reach headlessly: Foundation declares none, and the measured population
// (`CoreSpotlightVersionString` et al.) lives in frameworks this addon does not link, so `dlsym`
// misses them here exactly as it does today for any not-yet-loaded framework (the same latent
// gap `pointer-constant-ownership-k92` already flagged corpus-wide — loading a framework on
// demand is not this leaf's fix either). What this file CAN and does check deterministically:
// the entry is registered, and a missing symbol degrades to `""` (not a crash). The read
// mechanism itself — the symbol's own dlsym'd address, read as a C string with no load-through —
// is verified first-hand against the REAL, unmodified `CoreSpotlightVersionString` symbol by a
// standalone `dlopen`-then-read repro (this leaf's session notes), the same discipline
// `pointer-constant-ownership-k92` used for its own crash mechanism.
//
// Run: node targets/typescript/bindings/node/native/test/constants.mjs
// Requires: the addon built (build.sh) and the runtime built (npm run build in runtime/).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const runtimeUrl = new URL('../../runtime/dist/index.js', import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

const rt = await import(runtimeUrl.href);
const { NSObject, __class, __sel, __installDispatch, __unwrap, __wrapOwned, __wrapRetained, __cfstr, withAutoreleasePool } =
  rt;

const addon = require(addonPath);
__installDispatch(addon);

let failures = 0;
function check(label, cond, detail) {
  const ok = Boolean(cond);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail !== undefined ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

// The closed alphabet of constant-read entries is registered on the addon.
for (const name of [
  'aw_ts_const_P', 'aw_ts_const_P_n', 'aw_ts_const_N', 'aw_ts_const_N_a', 'aw_ts_const_b',
  'aw_ts_const_c', 'aw_ts_const_C', 'aw_ts_const_s', 'aw_ts_const_S', 'aw_ts_const_i',
  'aw_ts_const_I', 'aw_ts_const_q', 'aw_ts_const_Q', 'aw_ts_const_f', 'aw_ts_const_d',
]) {
  check(`addon exports ${name}`, typeof addon[name] === 'function');
}

// A minimal NSString binding (the emitted shape) to read back an object global's value.
class NSString extends NSObject {
  static __cls = __class('NSString');
  static of(s) {
    return __wrapOwned(NSString, __cfstr(s));
  }
  length() {
    return rt.__dispatch.aw_ts_msg_0_Q(__unwrap(this), __sel('length'));
  }
  isEqualToString_(other) {
    return rt.__dispatch.aw_ts_msg_P_b(__unwrap(this), __sel('isEqualToString:'), __unwrap(other));
  }
}

withAutoreleasePool(() => {
  // ── Pointer-valued object global (aw_ts_const_P) — the emitted shape:
  //    export const NSCocoaErrorDomain = __wrapRetained(NSString, __dispatch.aw_ts_const_P('…'))!
  const domain = __wrapRetained(NSString, rt.__dispatch.aw_ts_const_P('NSCocoaErrorDomain'));
  check('aw_ts_const_P reads a nonzero object handle', domain !== null);
  check(
    'const P → NSString value is "NSCocoaErrorDomain"',
    domain !== null && Boolean(domain.isEqualToString_(NSString.of('NSCocoaErrorDomain'))),
  );
  check(
    'const P → -length is 18',
    domain !== null && (domain.length() === 18n || domain.length() === 18),
    domain !== null ? domain.length() : 'null',
  );

  // ── Scalar global (aw_ts_const_d): NSFoundationVersionNumber is a positive double.
  const version = rt.__dispatch.aw_ts_const_d('NSFoundationVersionNumber');
  check('const d reads a plausible Foundation version', typeof version === 'number' && version > 1000, version);

  // ── Missing symbol: an absent object global → 0 → __wrapRetained → null (graceful).
  const missing = __wrapRetained(NSObject, rt.__dispatch.aw_ts_const_P('APIAW_NoSuchGlobalSymbol_k51'));
  check('missing object global → null', missing === null);
  const missingScalar = rt.__dispatch.aw_ts_const_d('APIAW_NoSuchGlobalSymbol_k51');
  check('missing scalar global → 0', missingScalar === 0);
  const missingOpaque = rt.__dispatch.aw_ts_const_P_n('APIAW_NoSuchGlobalSymbol_k51');
  check('missing opaque-pointer global → 0n', missingOpaque === 0n || missingOpaque === 0);

  // ── Missing array-symbol global (aw_ts_const_N_a, array-constant-symbol-value-k109):
  //    graceful "" — matches aw_ts_const_N's own missing-symbol posture.
  const missingArrayString = rt.__dispatch.aw_ts_const_N_a('APIAW_NoSuchGlobalSymbol_k51');
  check('missing array-symbol global → ""', missingArrayString === '', JSON.stringify(missingArrayString));

  // Dispose the borrowed global's folded +1 (balanced; constant strings are immortal, so this
  // is a no-op on the object, but it exercises the release path).
  if (domain !== null) domain[Symbol.dispose]();
});

console.log(failures === 0 ? '\nALL CHECKS PASSED' : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);

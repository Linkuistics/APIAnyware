// Integration probe for the error-out (`…_e`) @catch entries (error-catch-entries-k49, ADR-0058).
//
// Verifies the THREE mechanism obligations against the REAL addon, first-hand, with real
// Foundation selectors (Foundation-only + deterministic — no AppKit/display, so it runs under a
// plain `node` like the rest of test/*.mjs):
//
//   1. An escaping NSException is caught NATIVELY (never unwinds the C ABI into V8), its id +
//      -reason captured → {thrown:true}, and the runtime's __resultRetained THROWS an
//      NSExceptionError whose .message is the reason.  Driver: -[NSString stringByAppendingString:]
//      with a nil argument → NSInvalidArgumentException.
//   2. A primary-nil / NO return keys ok:false and wraps the out-param NSError; unwrap escalates to
//      NSErrorError.  Driver: -[NSFileManager removeItemAtPath:error:] on a nonexistent path.
//   3. A clean return is {thrown:false, primary} with error unset.  Driver: the same remove on a
//      real temp file → YES.
//
// Plus the ADR-0057 §4 fold-iff-+0 invariant THROUGH the `…_e` entries: a +0 fallible object
// primary (folding P_P_e) and a +1 one (non-folding P_P_o_e) both reach JS at a uniform +1, proved
// by -retainCount (the retain.mjs ground truth).
//
// Run: node targets/typescript/bindings/node/native/test/error.mjs
// Requires: the addon built (build.sh) and the runtime built (npm run build in runtime/).

import { createRequire } from 'node:module';
import { writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const runtimeUrl = new URL('../../runtime/dist/index.js', import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

const rt = await import(runtimeUrl.href);
const {
  NSObject,
  NSErrorError,
  NSExceptionError,
  ObjCError,
  __class,
  __sel,
  __cfstr,
  __installDispatch,
  __unwrap,
  __resultRetained,
  __resultOwned,
  __resultScalar,
  unwrap,
} = rt;

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

// ── 1. NSException: caught natively, thrown as NSExceptionError ───────────────────────────────
// -[NSString stringByAppendingString:nil] raises NSInvalidArgumentException. Route it through the
// object-primary error-out entry (P_P_e); the synthesized &err cell is ignored by the selector.
{
  const receiver = __cfstr('hello');
  const r = rt.__dispatch.aw_ts_msg_P_P_e(receiver, __sel('stringByAppendingString:'), 0n);
  check('NSException path: thrown axis is set native-side', r.thrown === true, r.thrown);
  check('NSException path: exception id captured (+1, non-null)', typeof r.exception === 'bigint' && r.exception !== 0n);
  check('NSException path: -reason captured native-side', typeof r.reason === 'string' && r.reason.length > 0, JSON.stringify(r.reason));

  let thrown;
  try {
    __resultRetained(NSObject, r);
  } catch (e) {
    thrown = e;
  }
  check('__resultRetained throws on the thrown axis', thrown !== undefined);
  check('  → is an NSExceptionError (extends ObjCError, Error)', thrown instanceof NSExceptionError && thrown instanceof ObjCError && thrown instanceof Error);
  check('  → .message is the native-captured reason', thrown?.message === r.reason, thrown?.message);
  check('  → .exception is an NSObject handle', thrown?.exception instanceof NSObject);
  // Allocation balance: the caught exception wrapper disposes cleanly (its native +1 releases).
  thrown?.exception?.[Symbol.dispose]();
  check('  → the exception wrapper disposes without over-release', true);
  addon.release(receiver);
}

// ── 2. NSError writer, failure: nil/NO primary → ok:false, unwrap → NSErrorError ───────────────
// -[NSFileManager removeItemAtPath:error:] on a nonexistent path returns NO and populates *error.
const fm = rt.__dispatch.aw_ts_msg_0_P(__class('NSFileManager'), __sel('defaultManager')); // +1 (folded)
{
  const path = __cfstr('/nonexistent/aw-error-probe-does-not-exist-xyz');
  const r = rt.__dispatch.aw_ts_msg_P_b_e(fm, __sel('removeItemAtPath:error:'), path);
  check('NSError failure: not thrown', r.thrown === false);
  check('NSError failure: BOOL primary is NO', r.primary === false, r.primary);
  check('NSError failure: out-param NSError captured (+1, non-null)', typeof r.error === 'bigint' && r.error !== 0n);

  const res = __resultScalar(r);
  check('__resultScalar keys ok:false on NO', res.ok === false);
  check('  → .error is an NSObject wrapping the NSError', res.ok === false && res.error instanceof NSObject);

  let escalated;
  try {
    unwrap(res);
  } catch (e) {
    escalated = e;
  }
  check('unwrap escalates the Result failure to NSErrorError', escalated instanceof NSErrorError && escalated instanceof ObjCError);
  if (res.ok === false) res.error[Symbol.dispose]();
  addon.release(path);
}

// ── 3. NSError writer, success: clean return → {thrown:false, primary:true}, error unset ───────
{
  const tmpPath = join(tmpdir(), `aw-error-probe-${process.pid}.txt`);
  writeFileSync(tmpPath, 'delete me');
  const path = __cfstr(tmpPath);
  const r = rt.__dispatch.aw_ts_msg_P_b_e(fm, __sel('removeItemAtPath:error:'), path);
  check('NSError success: not thrown', r.thrown === false);
  check('NSError success: BOOL primary is YES', r.primary === true, r.primary);
  check('NSError success: out-param NSError left unset (nil on success)', r.error === 0n, r.error);
  const res = __resultScalar(r);
  check('__resultScalar keys ok:true on YES', res.ok === true && res.value === true);
  addon.release(path);
}

// ── 4. fold-iff-+0 through the `…_e` entries: uniform +1 for the object primary ────────────────
// +0 (folding P_P_e): fetch a dict-held value via -objectForKey: (a +0 autoreleased return). The
// dict's retain is the stable baseline; the folding entry must add exactly one +1 for the wrapper.
{
  const val = addon.allocInit(__class('NSObject')); // my +1
  const dict = addon.allocInit(__class('NSMutableDictionary')); // my +1
  const key = __cfstr('k');
  rt.__dispatch.aw_ts_msg_PP_v(dict, __sel('setObject:forKey:'), val, key); // dict retains val
  const baseRc = rc(val);
  check('+0 baseline: dict holds val at +1 over my alloc +1', baseRc === 2, baseRc);

  const r = rt.__dispatch.aw_ts_msg_P_P_e(dict, __sel('objectForKey:'), key);
  check('+0 fallible fetch: not thrown, live primary', r.thrown === false && r.primary !== 0n);
  const res = __resultRetained(NSObject, r);
  check('+0 fallible fetch keys ok:true', res.ok === true);
  const wRc = rc(__unwrap(res.value));
  check('+0 fallible object primary folds exactly one +1 (uniform +1)', wRc === baseRc + 1, wRc);
  res.value[Symbol.dispose]();
  check('+0 dispose releases exactly the fold +1 (back to baseline)', rc(val) === baseRc, rc(val));

  addon.release(val);
  addon.release(dict);
  addon.release(key);
}

// +1 (non-folding P_P_o_e): -mutableCopyWithZone:nil returns a fresh +1 mutable copy. The
// non-folding entry must NOT retain again; __resultOwned → __wrapOwned takes that +1 directly, so
// the fresh copy reaches JS at retainCount 1 (a fold here would double-retain → 2).
{
  const src = __cfstr('a reasonably long, non-tagged NSString value for a real mutable copy');
  const r = rt.__dispatch.aw_ts_msg_P_P_o_e(src, __sel('mutableCopyWithZone:'), 0n);
  check('+1 fallible copy: not thrown, live primary', r.thrown === false && r.primary !== 0n);
  const res = __resultOwned(NSObject, r);
  check('+1 fallible copy keys ok:true', res.ok === true);
  const mcRc = rc(__unwrap(res.value));
  check('+1 fallible object primary reaches JS at a uniform +1 (no double-retain)', mcRc === 1, mcRc);
  res.value[Symbol.dispose]();
  addon.release(src);
}

addon.release(fm);

console.log(failures === 0 ? '\nALL CHECKS PASSED' : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);

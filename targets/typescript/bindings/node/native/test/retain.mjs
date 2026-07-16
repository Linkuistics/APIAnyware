// Integration probe for the retain-fold reconciliation (retain-fold-k48, ADR-0057 §2/§4).
//
// Verifies the uniform-+1 invariant against the REAL addon: every wrapped object reaches JS at
// exactly one +1 with no over-/under-retain, across BOTH ownership conventions AND the uniquing
// (existing-wrapper) path. `-retainCount` is the ground truth — read through the ordinary `0_Q`
// scalar entry (a query that does not itself mutate the count). Foundation-only + deterministic
// (no AppKit / display), so it runs under a plain `node` like the other test/*.mjs checks.
//
// It mirrors what the FIXED emitter produces: a +0 object return calls the bare (folding) entry,
// a +1-convention return (`-mutableCopy`) calls the non-folding `…_o` sibling. Routing a +1
// method through the folding entry (or failing to release the fold on a re-fetch) is exactly the
// double-retain / leak this guards against — see the two "no leak" checks below.
//
// Run: node targets/typescript/bindings/node/native/test/retain.mjs
// Requires: the addon built (build.sh) and the runtime built (npm run build in runtime/).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const runtimeUrl = new URL('../../runtime/dist/index.js', import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

const rt = await import(runtimeUrl.href);
const { NSObject, __class, __sel, __installDispatch, __unwrap, __wrapOwned, __wrapRetained, __cfstr } = rt;

const addon = require(addonPath);
__installDispatch(addon);

let failures = 0;
function check(label, cond, detail) {
  const ok = Boolean(cond);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail !== undefined ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

// -retainCount as a plain unsigned scalar read (the 0_Q entry); normalise bigint|number → number.
const rc = (id) => Number(rt.__dispatch.aw_ts_msg_0_Q(id, __sel('retainCount')));

// ── +0 convention + the uniquing (existing-wrapper) path ────────────────────────────────────
// Build a mutable array holding one plain NSObject `x`, then re-fetch it via -firstObject (a +0
// autoreleased return through the folding `0_P`). The array's retain is the stable baseline; the
// binding must add exactly one +1 for the live wrapper, no matter how many times `x` is re-fetched.
const x = addon.allocInit(__class('NSObject')); // my +1
const arr = addon.allocInit(__class('NSMutableArray'));
rt.__dispatch.aw_ts_msg_P_v(arr, __sel('addObject:'), x); // array retains x
const baseRc = rc(x);
check('baseline: array holds x at +1 over my alloc +1', baseRc === 2, baseRc);

const w1 = __wrapRetained(NSObject, rt.__dispatch.aw_ts_msg_0_P(arr, __sel('firstObject')));
const rcMint = rc(__unwrap(w1));
check('+0 mint folds exactly one +1 (uniform +1)', rcMint === baseRc + 1, rcMint);

const w2 = __wrapRetained(NSObject, rt.__dispatch.aw_ts_msg_0_P(arr, __sel('firstObject')));
check('uniquing: re-fetch returns the same wrapper', w1 === w2);
check(
  '+0 re-fetch does NOT leak the fold (existing-wrapper release balances it)',
  rc(__unwrap(w2)) === rcMint,
  rc(__unwrap(w2)),
);

// Disposing the sole live wrapper releases exactly the one +1 it owned → back to the baseline.
w1[Symbol.dispose]();
check('dispose releases exactly the wrapper +1 (balances to baseline)', rc(x) === baseRc, rc(x));

// ── +1 convention: -mutableCopy through the non-folding `0_P_o` sibling ──────────────────────
// A +1-convention return already owns its +1; the non-folding entry must NOT retain again, and
// __wrapOwned takes that +1 directly → the fresh mutable copy reaches JS at retainCount 1.
using src = __wrapOwned(NSObject, __cfstr('a reasonably long, non-tagged NSString value for copy'));
using mc = __wrapOwned(NSObject, rt.__dispatch.aw_ts_msg_0_P_o(__unwrap(src), __sel('mutableCopy')));
check('addon exports the non-folding aw_ts_msg_0_P_o entry', typeof addon.aw_ts_msg_0_P_o === 'function');
check('+1 mutableCopy reaches JS at a uniform +1 (no double-retain)', rc(__unwrap(mc)) === 1, rc(__unwrap(mc)));

// Clean up the raw handles the probe owns (x's alloc +1 and the array's alloc +1).
addon.release(x);
addon.release(arr);

console.log(failures === 0 ? '\nALL CHECKS PASSED' : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);

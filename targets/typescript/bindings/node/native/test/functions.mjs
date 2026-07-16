// Integration check for the plain-C free-function table (`aw_ts_fn_<symbol>`, ADR-0025's
// trampoline-elided limit for a named C export; ADR-0054 §1a).
//
// Loads the REAL Swift-native N-API addon and drives the `aw_ts_fn_<symbol>` path end-to-end.
// The resolver arms were proven against three hand-written entries at `fn-entry-spine-k68`; they
// now come from the GENERATED whole-corpus table (Generated/FunctionTable.swift,
// `fn-table-codegen-k69`) — 2192 per-symbol exports over 317 shared per-signature bodies. The
// three symbols were picked from the real corpus precisely so they would survive that transition.
//
// Part 1 — the resolver (`fn_resolve.swift`), one symbol per arm:
//
//   1. CoreFoundation.CFAbsoluteTimeGetCurrent() -> double
//        CoreFoundation is a direct dependency of the addon → the bare `dlsym` path.
//   2. LatentSemanticMapping.LSMMapGetTypeID() -> CFTypeID
//        Loaded by neither Node nor the addon → proves the LAZY `dlopen`. This test asserts the
//        framework is absent from the process before the call and present after, using Node's
//        diagnostic report — so the laziness is observed, not inferred.
//   3. Ruby.rb_clear_cache() -> void
//        Ruby.framework loads fine and still exports no such symbol (it is a header-only /
//        deprecated declaration; 24 of the corpus's 26 unresolvables are Ruby's) → proves the
//        LOUD failure: a JS Error naming symbol + framework, never a null-address call.
//
// It also exercises the `napi_create_function` `data` channel itself: those three entries are
// SHARED per-signature callbacks (`aw_ts_fnsig_0_d` / `_0_Q` / `_0_v`), told which symbol to
// dispatch only by the descriptor pointer they read back from `napi_get_cb_info`. Two distinct
// exports sharing one Swift body is the whole point — 2192 exports, 317 bodies.
//
// Part 2 — the retain axis (ADR-0057 §4), which rides the same descriptor. Under uniform-+1 the
// runtime's `__wrapRetained` does NOT retain: it takes a handle whose entry already folded a +1.
// So a **+0** object return must fold and a **+1** (CF Create Rule) one must not, and the two are
// told apart per symbol, not per signature — one `aw_ts_fnsig_P_P` body serves both. 233 of the
// table's entries fold. The proof is an autorelease pool: a folded +0 object outlives its drain.
//
// Run: node targets/typescript/bindings/node/native/test/functions.mjs
// Requires: the addon built (build.sh).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

/** Whether a framework's image is loaded into this process right now. */
function frameworkLoaded(name) {
  return process.report
    .getReport()
    .sharedObjects.some((so) => so.includes(`/${name}.framework/`));
}

// Sampled BEFORE the addon loads, so the addon's own linkage is visible in the delta too.
const lsmLoadedAtStart = frameworkLoaded('LatentSemanticMapping');

const addon = require(addonPath);

let failures = 0;
function check(label, cond, detail) {
  const ok = Boolean(cond);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail !== undefined ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

// ── The exports exist under their per-symbol keys (`function_entry_name`) ───────────────────
for (const sym of ['CFAbsoluteTimeGetCurrent', 'LSMMapGetTypeID', 'rb_clear_cache']) {
  check(`addon exports aw_ts_fn_${sym}`, typeof addon[`aw_ts_fn_${sym}`] === 'function');
}

// ── 1. Bare dlsym: a symbol from an already-loaded framework ────────────────────────────────
// CFAbsoluteTime is seconds since 2001-01-01, so it must track Date.now() to within a second.
const cfNow = addon.aw_ts_fn_CFAbsoluteTimeGetCurrent();
const expected = Date.now() / 1000 - 978307200;
check('CFAbsoluteTimeGetCurrent() is a number', typeof cfNow === 'number', cfNow);
check(
  'CFAbsoluteTimeGetCurrent() agrees with Date.now() to <2s',
  Math.abs(cfNow - expected) < 2,
  `native=${cfNow.toFixed(3)} js=${expected.toFixed(3)}`,
);
// A second call must advance: it is a live clock read through the resolved address, not a
// constant baked at registration.
const cfLater = addon.aw_ts_fn_CFAbsoluteTimeGetCurrent();
check('a second call advances the clock', cfLater >= cfNow, `${cfNow} → ${cfLater}`);

// ── 2. Lazy dlopen: a symbol from a framework nothing has loaded ────────────────────────────
check(
  'LatentSemanticMapping is NOT loaded before the call',
  !lsmLoadedAtStart && !frameworkLoaded('LatentSemanticMapping'),
);

const typeId = addon.aw_ts_fn_LSMMapGetTypeID();
check('LSMMapGetTypeID() returns a non-zero CFTypeID', typeof typeId === 'number' && typeId > 0, typeId);
check(
  'LatentSemanticMapping IS loaded after the call (lazy dlopen)',
  frameworkLoaded('LatentSemanticMapping'),
);
// The cached address is reused, and a CFTypeID is a process-stable constant.
check('LSMMapGetTypeID() is stable across calls', addon.aw_ts_fn_LSMMapGetTypeID() === typeId, typeId);

// The two entries above share no Swift body with each other, but both reached their symbol
// solely through the `data` descriptor — a per-symbol export over a per-signature callback.
check(
  'the two resolved entries are distinct exports',
  addon.aw_ts_fn_CFAbsoluteTimeGetCurrent !== addon.aw_ts_fn_LSMMapGetTypeID,
);

// ── 3. Loud failure: a symbol no image exports ──────────────────────────────────────────────
let threw = null;
try {
  addon.aw_ts_fn_rb_clear_cache();
} catch (e) {
  threw = e;
}
check('rb_clear_cache() throws rather than calling a null address', threw instanceof Error);
check(
  'the thrown message names the symbol',
  threw?.message?.includes('rb_clear_cache'),
  threw?.message,
);
check('the thrown message names the framework', threw?.message?.includes('Ruby'));
// Ruby.framework really did load — the failure is "no such symbol", not "no such image".
check('Ruby.framework was loaded by the attempt', frameworkLoaded('Ruby'));
// A second call throws again (the failure is not cached as a resolved address).
let threwAgain = false;
try {
  addon.aw_ts_fn_rb_clear_cache();
} catch {
  threwAgain = true;
}
check('a second call throws again', threwAgain);

// The throw left no pending exception behind: the process is still usable.
check('the addon still works after the throw', addon.aw_ts_fn_LSMMapGetTypeID() === typeId);

// ── 4. The retain axis: a +0 object return folds, a +1 one does not ─────────────────────────
// The fold is a per-SYMBOL fact (the CF Create Rule reads the name) carried in the descriptor,
// while the Swift body is per-SIGNATURE — so both symbols below run through bodies that cannot
// themselves know the convention. `retainCount` is the observable.
const rc = (h) => addon.aw_ts_msg_0_Q(h, addon.getSelector('retainCount'));
const len = (h) => addon.aw_ts_msg_0_Q(h, addon.getSelector('length'));

// NSTemporaryDirectory() -> NSString: no Create/Copy in the name → +0 autoreleased → FOLDS.
// (A long path, so it is a real heap NSString, not an immortal constant or a tagged pointer —
// `NSStringFromClass` would have reported retainCount 2^64-1 and proven nothing.)
const pool = addon.pushAutoreleasePool();
const tmp = addon.aw_ts_fn_NSTemporaryDirectory();
const tmpLen = len(tmp);
check('NSTemporaryDirectory() returns a non-empty NSString', tmpLen > 0, `length=${tmpLen}`);
check(
  'inside the pool the folded +0 return is retained twice (pool +1, fold +1)',
  rc(tmp) === 2,
  rc(tmp),
);
addon.popAutoreleasePool(pool);
// THE point of the fold: the pool dropped its +1 and the object is still alive, holding ours.
check('after the drain exactly the fold’s +1 remains', rc(tmp) === 1, rc(tmp));
check('the object survived its autorelease pool', len(tmp) === tmpLen, len(tmp));
addon.release(tmp); // balance the fold — the wrapper's `dispose`/FR would do this.

// MTLCopyAllDevices() -> NSArray: `Copy` in the name → +1 owned → NO fold. A spurious fold here
// would read 2 and leak. It also happens to be a lazy-dlopen entry (Metal), like LSMMapGetTypeID.
const pool2 = addon.pushAutoreleasePool();
const devices = addon.aw_ts_fn_MTLCopyAllDevices();
check(
  'a +1 Create-Rule return is NOT double-retained (one +1, ours)',
  rc(devices) === 1,
  rc(devices),
);
addon.popAutoreleasePool(pool2);
check('the +1 return never entered the pool, so the drain does not touch it', rc(devices) === 1);
addon.release(devices);

// A `Ptr` return that is NOT an object is never folded: retaining a Class would leak, and
// `objc_retain` on a SEL is undefined behaviour. Neither is wrapped `.ts`-side, so both come back
// as raw handles, identical to the runtime's own lookups.
check(
  'NSClassFromString returns an unretained Class handle',
  addon.aw_ts_fn_NSClassFromString(addon.cfstr('NSMutableArray')) === addon.getClass('NSMutableArray'),
);
check(
  'NSSelectorFromString returns an unretained SEL handle',
  addon.aw_ts_fn_NSSelectorFromString(addon.cfstr('length')) === addon.getSelector('length'),
);

console.log(failures === 0 ? '\nALL CHECKS PASSED' : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);

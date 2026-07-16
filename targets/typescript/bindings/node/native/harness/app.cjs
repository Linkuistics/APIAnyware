// app.cjs — the facility-test payload the k42 embedder harness (embed_main.mm) runs via
// LoadEnvironment. Proves ADR-0056's governing constraint first-hand under the production entry
// architecture: Node's own threading/scheduling facilities keep working while AppKit owns thread 0
// and libuv is pumped as a guest. Each test writes a boolean into `results`; when the expected set
// completes, it sets globalThis.__done / __ok / __resultsJson, which embed_main.mm reads via V8
// after NSApp stops. CommonJS so the embedder's createRequire loads it synchronously.

'use strict';
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { pathToFileURL } = require('url');
const { Worker } = require('worker_threads');

const results = Object.create(null);
// The tests we wait for before declaring __done. (nested-runloop survival is measured natively.)
const expected = [
  'setTimeout', 'setImmediate', 'nextTickAfterTimer', 'promiseAfterTimer',
  'nextTickBeforePromiseOrder', 'pureChain', 'staleTimeout', 'threadpool', 'worker',
  'dispatch', 'bounce', 'offMainDelivery', 'escapingBlock', 'deallocOffMain',
];

function mark(name, ok) {
  if (name in results) return;
  results[name] = Boolean(ok);
  const remaining = expected.filter((k) => !(k in results));
  if (remaining.length === 0) finish();
}

let finished = false;
function finish() {
  if (finished) return;
  finished = true;
  globalThis.__done = true;
  globalThis.__ok = expected.every((k) => results[k] === true);
  globalThis.__resultsJson = JSON.stringify(results);
}

// 1. A basic libuv timer fires.
setTimeout(() => mark('setTimeout', true), 10);

// 2. setImmediate (libuv check phase) fires.
setImmediate(() => mark('setImmediate', true));

// 3 + 4. The finding-C crux: a process.nextTick / a Promise microtask enqueued *from a libuv timer
// callback* must drain. Under the k6 blocking-call harness the timer callback's InternalCallbackScope
// is nested inside the blocked napi run() call and SKIPS the nextTick/microtask drain, so these never
// fire. Under the embedder (native owns main(), no ambient napi call) the scope is top-level and drains.
setTimeout(() => {
  process.nextTick(() => mark('nextTickAfterTimer', true));
  Promise.resolve().then(() => mark('promiseAfterTimer', true));
}, 15);

// 5. Ordering: within one drain, process.nextTick runs before Promise microtasks (Node contract).
setTimeout(() => {
  const order = [];
  process.nextTick(() => order.push('nextTick'));
  Promise.resolve().then(() => {
    order.push('promise');
    mark('nextTickBeforePromiseOrder', order[0] === 'nextTick' && order[1] === 'promise');
  });
}, 20);

// 6. A pure async/await chain that hops through 100 microtasks after an initial libuv timer resolves.
(async () => {
  await new Promise((r) => setTimeout(r, 25));
  let n = 0;
  for (let i = 0; i < 100; i++) {
    await Promise.resolve();
    n++;
  }
  mark('pureChain', n === 100);
})();

// 7. Stale-uv_backend_timeout: a timer ARMED AFTER a quiescent gap must still fire (libuv #1565 /
// Electron #7079). Add it from inside a first timer at 300ms so it is armed after the loop settled.
setTimeout(() => {
  const armed = Date.now();
  setTimeout(() => mark('staleTimeout', Date.now() - armed >= 250), 300);
}, 300);

// 8. libuv threadpool completion (crypto.pbkdf2 runs on a threadpool thread, delivered on the loop thread).
crypto.pbkdf2('pw', 'salt', 20000, 32, 'sha256', (err, key) => {
  mark('threadpool', !err && key && key.length === 32);
});
// belt-and-suspenders: a threadpool fs op too (not gated on, just exercised).
fs.readFile(__filename, () => {});

// 9. worker_threads: its own thread + its own uv_run(DEFAULT), untouched by the main pump; runs + joins.
const worker = new Worker(
  "const { parentPort } = require('worker_threads');" +
    "let s = 0; for (let i = 1; i <= 1000; i++) s += i;" +
    "parentPort.postMessage(s);",
  { eval: true },
);
worker.on('message', (sum) => {
  worker.terminate().finally(() => mark('worker', sum === 500500));
});
worker.on('error', () => mark('worker', false));

// 10. The real seam under the embedder: load the ESM @apianyware/runtime, load the -undefined
// dynamic_lookup .node addon (its napi_* symbols must resolve against the embedded libnode), bind
// the backend via __installDispatch, and round-trip one real dispatch (cfstr('hi') → -[NSString
// length] == 2 → release). Proves the addon + runtime coexist with the embedder + pump in one
// process — the production entry architecture with the real runtime, not a toy. Guarded so any
// failure marks false (never hangs the harness).
(async () => {
  try {
    const addonPath = path.join(__dirname, '..', 'build', 'APIAnywareTypeScript.node');
    const runtimeIndex = path.join(__dirname, '..', '..', 'runtime', 'dist', 'index.js');
    const rt = await import(pathToFileURL(runtimeIndex).href);
    const addon = require(addonPath);
    rt.__installDispatch(addon);
    const cls = addon.getClass('NSString');
    const s = addon.cfstr('hi'); // +1 owned NSString id
    const len = addon.aw_ts_msg_0_Q(s, addon.getSelector('length'));
    addon.release(s);
    mark('dispatch', cls !== 0n && (len === 2n || len === 2));
  } catch (err) {
    globalThis.__dispatchError = String(err && err.stack ? err.stack : err);
    mark('dispatch', false);
  }
})();

// 11. The tsfn-bounce-k43 seam under the embedder: prove the background→main callback bounce
// (ADR-0056 §3) first-hand. __ensureInbound installs the value-returning deliverer and creates the
// singleton bounce napi_threadsafe_function on thread 0; aw_test_bounce then originates on a REAL GCD
// background thread and (a) value-round-trips a JS return (41 → 42) through the completion semaphore,
// (b) holds the always-post discipline when the JS callback throws (unblocks with the typed default
// 0), and (c) delivers a void bounce on thread 0. Every callback must land on thread 0 (isMainThread),
// never off-main. Guarded so any failure marks false (never hangs the harness).
(async () => {
  try {
    const addonPath = path.join(__dirname, '..', 'build', 'APIAnywareTypeScript.node');
    const runtimeIndex = path.join(__dirname, '..', '..', 'runtime', 'dist', 'index.js');
    const rt = await import(pathToFileURL(runtimeIndex).href);
    const addon = require(addonPath);
    rt.__installDispatch(addon);
    rt.__ensureInbound(); // installs __invokeCallback + __deliverValueReturning → creates the bounce tsfn

    // Value-returning target: receives 41 on thread 0, returns 42 (the round-trip payload).
    const valueId = rt.__registerCallback((x) => x + 1);
    // Throwing target: the always-post discipline must still unblock the bg thread with the default 0.
    const throwId = rt.__registerCallback(() => {
      throw new Error('bounce boom (contained — the bg thread must still unblock)');
    });
    // The notify callback IS a void bounce delivered on thread 0: read the probe + verify the round-trip.
    const notifyId = rt.__registerCallback(() => {
      const voidOnMain = addon.isMainThread(); // the void bounce reached JS on thread 0
      const r = addon.aw_test_bounce_result();
      const ok =
        voidOnMain &&
        r.originOffMain && // the sequence genuinely originated off the main thread
        r.valueReturned === 42 && // the JS return round-tripped back through the semaphore
        r.valueDeliveredOnMain && // ...and was delivered on thread 0, not off-main
        r.throwUnblocked && // a throwing value callback still unblocked the bg thread
        r.throwReturned === 0; // ...with the typed default (always-post on a contained throw)
      if (!ok) globalThis.__bounceDetail = JSON.stringify({ voidOnMain, ...r });
      mark('bounce', ok);
    });

    addon.aw_test_bounce(valueId, throwId, notifyId);
  } catch (err) {
    globalThis.__bounceError = String(err && err.stack ? err.stack : err);
    mark('bounce', false);
  }
})();

// 12. The off-main-delivery-k44 seam under the embedder: prove the REAL inbound trampolines' off-main
// branch first-hand (the real-trampoline analogue of test #11's mechanism-only aw_test_bounce). A JS
// class extends NSObject overriding value-returning + void selectors → one synthesized ObjC subclass
// whose IMPs are the typed trampolines. aw_test_off_main_delivery then originates on a REAL GCD bg
// thread and objc_msgSends those overridden selectors: each trampoline detects pthread_main_np()==0 and
// bounces to thread 0 (awBounceVoid / awBounceValue) instead of re-entering JS off-main. It proves (a) a
// value-returning override round-trips its JS return (42) through the completion semaphore, (b) a
// throwing override still unblocks the bg thread with the typed default 0 (always-post, ADR-0059 §7),
// (c) a void override delivers on thread 0, and (d) EVERY JS callback ran on thread 0 (isMainThread()),
// never off-main. Guarded so any failure marks false (never hangs the harness).
(async () => {
  try {
    const addonPath = path.join(__dirname, '..', 'build', 'APIAnywareTypeScript.node');
    const runtimeIndex = path.join(__dirname, '..', '..', 'runtime', 'dist', 'index.js');
    const rt = await import(pathToFileURL(runtimeIndex).href);
    const addon = require(addonPath);
    rt.__installDispatch(addon);
    rt.__ensureInbound(); // installs the inbound bridge + (via bounce.swift) the bounce tsfn on thread 0

    // JS-side thread-0 landing evidence (mutated by the overrides when they run on thread 0).
    const seen = {
      valueCbOnMain: null, boolCbOnMain: null, throwCbOnMain: null,
      voidCbOnMain: null, voidCbFired: false,
    };

    // A JS subclass of NSObject overriding value-returning selectors — a q@:@ (NSInteger) returning 42,
    // a c@:@ (BOOL) returning true, a q@:@ that throws — and one void (v@:@). Synthesized once; its IMPs
    // are the typed trampolines. The q@:@ + c@:@ pair exercises two distinct value-returning deliver
    // functions (deliverInt64 + deliverBool) and both slot reinterprets through the real bg-thread path.
    const OVERRIDES = [
      ['awValue:', 'q@:@'], // NSInteger return, self, _cmd, one id arg → returns 42
      ['awBool:', 'c@:@'], // BOOL return → returns true (the .bool slot reinterpret)
      ['awThrow:', 'q@:@'], // NSInteger return → throws (contained; always-post default 0)
      ['awVoid:', 'v@:@'], // void return, self, _cmd, one id arg
    ];
    const OBJC_NSOBJECT = rt.__class('NSObject');
    class OffMainSubject extends rt.NSObject {
      constructor() {
        super(rt.__subclassAlloc(OffMainSubject, OBJC_NSOBJECT, OVERRIDES));
        rt.__bindSubclass(this);
      }
      awValue_() {
        seen.valueCbOnMain = addon.isMainThread();
        return 42;
      }
      awBool_() {
        seen.boolCbOnMain = addon.isMainThread();
        return true;
      }
      awThrow_() {
        seen.throwCbOnMain = addon.isMainThread();
        throw new Error('off-main boom (contained — the bg thread must still unblock)');
      }
      awVoid_() {
        seen.voidCbOnMain = addon.isMainThread();
        seen.voidCbFired = true;
      }
    }
    // Kept strongly referenced (not disposed) so the ObjC instance survives the async bg sequence; the
    // __bindSubclass registry entry also pins it. The harness process exits after, so no leak matters.
    const subject = new OffMainSubject();
    const instanceId = rt.__unwrap(subject);

    // The notify callback IS a void bounce delivered on thread 0 (FIFO after the void override): read
    // the native probe + the JS-side landing evidence and verify the whole off-main round-trip.
    const notifyId = rt.__registerCallback(() => {
      const notifyOnMain = addon.isMainThread(); // the notify void bounce reached JS on thread 0
      const r = addon.aw_test_off_main_delivery_result();
      const ok =
        notifyOnMain &&
        r.originOffMain && // the sequence genuinely originated off the main thread
        r.valueReturned === 42 && // the q@:@ value override's return round-tripped the semaphore
        r.boolReturned === true && // the c@:@ BOOL override's return round-tripped (the .bool reinterpret)
        r.throwUnblocked && // a throwing value override still unblocked the bg thread (never hung)
        r.throwReturned === 0 && // ...with the typed default (always-post on a contained throw)
        r.voidSent && // the void override's objc_msgSend returned on the bg thread
        seen.voidCbFired && // the void override's JS body actually ran
        seen.valueCbOnMain === true && // every override delivered on thread 0, never off-main:
        seen.boolCbOnMain === true &&
        seen.throwCbOnMain === true &&
        seen.voidCbOnMain === true;
      if (!ok) globalThis.__offMainDetail = JSON.stringify({ notifyOnMain, ...r, ...seen });
      mark('offMainDelivery', ok);
    });

    // Drive it from a real GCD bg thread. argId is the instance's own id (the overrides ignore the arg).
    addon.aw_test_off_main_delivery(
      instanceId,
      addon.getSelector('awValue:'),
      addon.getSelector('awBool:'),
      addon.getSelector('awThrow:'),
      addon.getSelector('awVoid:'),
      instanceId,
      notifyId,
    );
  } catch (err) {
    globalThis.__offMainError = String(err && err.stack ? err.stack : err);
    mark('offMainDelivery', false);
  }
})();

// 13. The block-escaping-off-main-k45 seam under the embedder: prove the ESCAPING block surface (ADR-0059
// §2 default path) first-hand. A JS function passed where an ObjC block parameter is expected, where the
// block ESCAPES (stored by the framework, invoked later — possibly off thread 0), is wrapped into a real
// heap ObjC block whose invoke is the typed inbound trampoline, with the JS fn PINNED by the registry.
// aw_test_escaping_block_delivery stores two such blocks (a void `0_v` and a value-returning `P_b`), then on
// a REAL GCD bg thread invokes each via the raw Block ABI (so each bounces to thread 0), then does the last
// _Block_release OFF-MAIN — the framework dropping a stored completion handler off-main. It proves (a) an
// escaping block survives past its make call and delivers on thread 0 when invoked later off thread 0, (b)
// a value-returning escaping block round-trips its JS return through the completion semaphore, and (c)
// OFF-MAIN teardown is legal — the holder's off-main dispose release-bounces the registry drop to thread 0
// (both entries gone by the notify). Guarded so any failure marks false (never hangs the harness).
(async () => {
  try {
    const addonPath = path.join(__dirname, '..', 'build', 'APIAnywareTypeScript.node');
    const runtimeIndex = path.join(__dirname, '..', '..', 'runtime', 'dist', 'index.js');
    const rt = await import(pathToFileURL(runtimeIndex).href);
    const addon = require(addonPath);
    rt.__installDispatch(addon);
    rt.__ensureInbound(); // installs the inbound bridge + the block-release deliverer + the bounce tsfn

    // JS-side thread-0 landing evidence (mutated by the escaping-block bodies when they run on thread 0).
    const seen = { voidOnMain: null, voidFired: false, valueOnMain: null, throwOnMain: null };

    // Register three escaping-block JS fns directly (low-level, like block.mjs) so we hold their CallbackIds
    // to assert the off-main teardown dropped them: a void completion, a BOOL-returning value block, and a
    // THROWING void block (its throw must be contained → onCallbackError, never a C-ABI unwind; ADR-0059 §7).
    const voidId = rt.__registerCallback(() => {
      seen.voidOnMain = addon.isMainThread();
      seen.voidFired = true;
    });
    const valueId = rt.__registerCallback(() => {
      seen.valueOnMain = addon.isMainThread();
      return true; // the P_b block's JS return, round-tripped through the completion semaphore
    });
    const throwId = rt.__registerCallback(() => {
      seen.throwOnMain = addon.isMainThread();
      throw new Error('escaping-block boom (contained — no C-ABI unwind through the pump)');
    });
    // Count contained-throw reports from the throwing escaping block (must fire exactly once, for throwId).
    let escReports = 0;
    rt.onCallbackError((_err, ctx) => {
      // A block invoke has no selector — the error context carries only { id } (contextOf → { id }).
      if (ctx.id === throwId && ctx.selector === undefined) escReports++;
    });
    // Build the real escaping blocks (registry-pinned, NOT bracketed). Each sole +1 is transferred to the
    // driver, which does the last _Block_release off-main — so JS does NOT releaseBlock here. Signatures
    // are the shared inbound code alphabet (block-maker-tables-k62: 0_v no-arg void, P_b BOOL-returning).
    const voidBlock = addon.makeEscapingBlock(voidId, '0_v');
    const valueBlock = addon.makeEscapingBlock(valueId, 'P_b');
    const throwBlock = addon.makeEscapingBlock(throwId, '0_v');

    // The notify callback IS a void bounce delivered on thread 0 (FIFO after the off-main release
    // bounces): read the native probe + JS-side landing evidence and assert every registry entry dropped.
    const notifyId = rt.__registerCallback(() => {
      const notifyOnMain = addon.isMainThread();
      const r = addon.aw_test_escaping_block_delivery_result();
      const voidDropped = rt.__resolveCallback(voidId) === undefined; // off-main teardown dropped the fn
      const valueDropped = rt.__resolveCallback(valueId) === undefined;
      const throwDropped = rt.__resolveCallback(throwId) === undefined;
      const ok =
        notifyOnMain &&
        r.originOffMain && // the sequence genuinely originated off the main thread
        r.voidReturned && // the void escaping block's invoke returned on the bg thread (delivery reached it)
        r.valueReturned === true && // the P_b block's JS return round-tripped the semaphore
        r.throwInvoked && // the throwing block's invoke returned on the bg thread (no unwind reached it)
        seen.voidFired && // the void escaping block's JS body actually ran
        seen.voidOnMain === true && // ...on thread 0, never off-main
        seen.valueOnMain === true && // the value block delivered on thread 0 too
        seen.throwOnMain === true && // the throwing block's body ran on thread 0 (then threw)
        escReports === 1 && // the throw was contained + reported exactly once via onCallbackError
        voidDropped && // off-main teardown release-bounced each registry drop to thread 0
        valueDropped &&
        throwDropped;
      if (!ok) {
        globalThis.__escapingDetail = JSON.stringify({
          notifyOnMain, ...r, ...seen, escReports, voidDropped, valueDropped, throwDropped,
        });
      }
      rt.onCallbackError(null);
      mark('escapingBlock', ok);
    });

    // Drive it off a real GCD bg thread. argId is voidBlock's own id (the P_b body ignores its arg).
    addon.aw_test_escaping_block_delivery(voidBlock, valueBlock, throwBlock, voidBlock, notifyId);
  } catch (err) {
    globalThis.__escapingError = String(err && err.stack ? err.stack : err);
    mark('escapingBlock', false);
  }
})();

// 14. The dealloc-off-main-k46 seam under the embedder: prove the OFF-MAIN SYNCHRONOUS dealloc bounce
// (ADR-0059 §4) first-hand — the off-main dual of super.mjs's on-thread-0 dealloc (k40). When the framework
// drops a synthesized subclass/forwarder instance's LAST ref off thread 0 (a superview released on a bg
// queue), the JS `dealloc` override AND the registry-release teardown must run on thread 0 — via a
// SYNCHRONOUS bounce (block the deallocating thread, run the override + teardown on thread 0, return) — so
// ObjC `-dealloc` completes AFTER the override (never *async*: the object would be freed before the override
// runs → UAF of the JS back-ref). aw_test_dealloc_off_main drops the last ref of three synthesized instances
// off a REAL GCD bg thread: an override that chains [super dealloc] on thread 0 (hadOverride=true), a
// NO-override instance (native chains [super dealloc] on the bg thread), and a THROWING override (contained,
// still unblocks + still drops the registry). It proves (a) each JS dealloc override ran on thread 0
// (isMainThread), (b) each instance's registry keep-alive dropped on thread 0 (the k37/k38 loop close,
// off-main), and (c) the bg thread never hung — even the throwing override unblocked it (always-post).
// Guarded so any failure marks false (never hangs the harness). No onCallbackError hook is installed here:
// the throwing dealloc's containment is proven by throwReleased + throwDropped, and a competing global hook
// would race the escaping-block test (#13), which owns onCallbackError.
(async () => {
  try {
    const addonPath = path.join(__dirname, '..', 'build', 'APIAnywareTypeScript.node');
    const runtimeIndex = path.join(__dirname, '..', '..', 'runtime', 'dist', 'index.js');
    const rt = await import(pathToFileURL(runtimeIndex).href);
    const addon = require(addonPath);
    rt.__installDispatch(addon);
    rt.__ensureInbound(); // installs the inbound bridge (incl. __deliverDealloc) + the bounce tsfn on thread 0

    // JS-side thread-0 landing evidence (mutated by the dealloc overrides when they run on thread 0).
    const seen = { overrideOnMain: null, overrideChainedSuper: false, throwOnMain: null };
    const OBJC_NSOBJECT = rt.__class('NSObject');
    const deallocSel = addon.getSelector('dealloc');

    // ONE synthesized subclass class (empty overrides — the shared dealloc IMP is auto-installed); three
    // instances differing only in their registered target's dealloc method. Low-level (defineSubclass +
    // allocInit + registerCallback + setBackRef, like super.mjs §2c) so each instance has exactly ONE owning
    // +1 the bg thread can drop as the last ref — the JS-wrapper `using` path would release on thread 0, not
    // off-main, which is the whole point being tested.
    const cls = addon.defineSubclass(OBJC_NSOBJECT, 'AWDeallocOffMainSubject', []);
    const make = (target) => {
      const inst = addon.allocInit(cls); // +1 owned synthesized-subclass instance
      const cbid = rt.__registerCallback(target); // pins the JS target (the keep-alive dealloc must drop)
      addon.setBackRef(inst, cbid);
      return { inst, cbid };
    };

    // (a) override that chains [super dealloc] on thread 0 — hadOverride=true, JS chains super.
    let overrideInst = 0n;
    const oc = make({
      dealloc() {
        seen.overrideOnMain = addon.isMainThread(); // the override ran on thread 0, never off-main
        rt.__dispatch.aw_ts_super_0_v(overrideInst, OBJC_NSOBJECT, deallocSel); // chain [super dealloc]
        seen.overrideChainedSuper = true;
      },
    });
    overrideInst = oc.inst;

    // (b) no override — hadOverride=false; the native IMP chains [super dealloc] on the bg thread.
    const pc = make({ tag: 'plain' });

    // (c) throwing override — contained + reported on thread 0; still unblocks the bg thread + drops the registry.
    const tc = make({
      dealloc() {
        seen.throwOnMain = addon.isMainThread();
        throw new Error('off-main dealloc boom (contained — the deallocating thread must still unblock)');
      },
    });

    // The notify callback IS a void bounce delivered on thread 0 (FIFO after the dealloc bounces' registry
    // drops): read the native probe + JS-side landing evidence and assert every registry entry dropped.
    const notifyId = rt.__registerCallback(() => {
      const notifyOnMain = addon.isMainThread();
      const r = addon.aw_test_dealloc_off_main_result();
      const overrideDropped = rt.__resolveCallback(oc.cbid) === undefined; // dealloc dropped the keep-alive
      const plainDropped = rt.__resolveCallback(pc.cbid) === undefined;
      const throwDropped = rt.__resolveCallback(tc.cbid) === undefined;
      const ok =
        notifyOnMain &&
        r.originOffMain && // the sequence genuinely originated off the main thread
        r.overrideReleased && // the override instance's last release returned (the bounce unblocked the bg thread)
        r.plainReleased && // the no-override instance's release returned (native chained super off-main)
        r.throwReleased && // the throwing override's release returned (always-post unblocked the bg thread)
        seen.overrideOnMain === true && // the JS dealloc override ran on thread 0, never off-main
        seen.overrideChainedSuper && // ...and chained [super dealloc]
        seen.throwOnMain === true && // the throwing override's body also ran on thread 0 (then threw)
        overrideDropped && // each instance's registry keep-alive dropped on thread 0 inside the bounce
        plainDropped &&
        throwDropped;
      if (!ok) {
        globalThis.__deallocDetail = JSON.stringify({
          notifyOnMain, ...r, ...seen, overrideDropped, plainDropped, throwDropped,
        });
      }
      mark('deallocOffMain', ok);
    });

    // Drive it off a real GCD bg thread: it does the last objc_release of each instance off-main.
    addon.aw_test_dealloc_off_main(oc.inst, pc.inst, tc.inst, notifyId);
  } catch (err) {
    globalThis.__deallocError = String(err && err.stack ? err.stack : err);
    mark('deallocOffMain', false);
  }
})();

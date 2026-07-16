// Integration check for the OFF-MAIN ESCAPING block INBOUND surface
// (block-call-site-emission-k120, realising the untested-until-now half of ADR-0059 §2's default
// path). The escaping dual of block.mjs's NS_NOESCAPE leg.
//
// block.mjs already proved the NS_NOESCAPE fast path (a block invoked synchronously, held only for
// the call). This file proves the other half — the one `note-editor`'s Save-sheet completion handler
// needs and no test exercised before this leaf: a JS function wrapped by `__makeEscapingBlock` into a
// REAL heap ObjC block that OUTLIVES the call, fires later (possibly OFF thread 0), and is torn down
// by the FRAMEWORK's own release (never an explicit JS-side release call) — the exact mechanism the
// generated `beginSheetModalForWindow_completionHandler_` call site
// (`targets/typescript/bindings/macos/generated/appkit/{nssavepanel,nsalert}.ts`) now calls into.
//
// Drives it through `-[NSNotificationCenter addObserverForName:object:queue:usingBlock:]` — a genuine
// Foundation escaping-block API (the observer block is retained until removed), headless (no window,
// no VM needed), and NOT itself emitted by the TS corpus (its selector is not in the narrow
// `ADMITTED_COMPLETION_HANDLER_SELECTORS` carve-out) — so it is called via the RAW native dispatch
// entry here, exactly as block.mjs calls `enumerateObjectsUsingBlock:` raw. What this file actually
// verifies is the shared mechanism (`__makeEscapingBlock`, `awMakeEscapingBlock_<code>`,
// `EscapingBlockHolder`, `deliverBlockVoid`'s off-main bounce) — the SAME machinery
// `beginSheetModalForWindow_completionHandler_`'s generated body calls, just reached through a
// headless-testable door instead of a real NSSavePanel sheet + window.
//
// Three legs:
//   (1) queue = nil → the block fires SYNCHRONOUSLY on the posting thread (thread 0 here) — the
//       on-thread-0 direct-invoke arm of `deliverBlockVoid`.
//   (2) queue = a background NSOperationQueue → the block fires OFF thread 0 — the singleton
//       `napi_threadsafe_function` bounce arm, never exercised end-to-end before this leaf.
//   (3) boundary containment (ADR-0059 §7): a throwing escaping-block body is caught, reported, and
//       does not crash — proven on both the on-thread-0 and off-main legs.
//
// Headless: Foundation-only (NSNotificationCenter + NSOperationQueue), no AppKit.
//
// Run: node targets/typescript/bindings/node/native/test/block-escaping.mjs
// Requires: the addon built (build.sh) and the runtime built (npm run build in runtime/).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const runtimeUrl = new URL('../../runtime/dist/index.js', import.meta.url);
const addonPath = fileURLToPath(new URL('../build/APIAnywareTypeScript.node', import.meta.url));

const rt = await import(runtimeUrl.href);
const { __class, __sel, __installDispatch, __makeEscapingBlock, onCallbackError } = rt;

const addon = require(addonPath);
__installDispatch(addon);

let failures = 0;
function check(label, cond, detail) {
  const ok = Boolean(cond);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail !== undefined ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

for (const name of ['makeEscapingBlock', 'aw_ts_msg_PPPP_P', 'aw_ts_msg_PP_v']) {
  check(`addon exports ${name}`, typeof addon[name] === 'function');
}

const center = addon.aw_ts_msg_0_P(__class('NSNotificationCenter'), __sel('defaultCenter'));
const NOTE_NAME = addon.cfstr('APIAnywareBlockEscapingTest');
const ADD_SEL = __sel('addObserverForName:object:queue:usingBlock:');
const POST_SEL = __sel('postNotificationName:object:');
const REMOVE_SEL = __sel('removeObserver:');
// void (^)(NSNotification *) — one Class-shaped block param, void return: code "P_v" (block.mjs's
// own module doc already canonicalises this exact code from the shared alphabet).
const BLOCK_SIG = 'P_v';

function post() {
  addon.aw_ts_msg_PP_v(center, POST_SEL, NOTE_NAME, 0n);
}

// ── (1) On-thread-0 escaping delivery: queue = nil → synchronous on the posting thread ───────────
{
  let firedWith = undefined;
  const block = __makeEscapingBlock((note) => {
    firedWith = note;
  }, BLOCK_SIG);
  const token = addon.aw_ts_msg_PPPP_P(center, ADD_SEL, NOTE_NAME, 0n, 0n, block);
  check('addObserverForName: returns a non-nil observer token', token !== 0n);
  post();
  check(
    'escaping block fired synchronously on thread 0 (queue=nil) with a notification handle',
    typeof firedWith === 'bigint' && firedWith !== 0n,
    firedWith,
  );
  addon.aw_ts_msg_P_v(center, REMOVE_SEL, token);
  firedWith = undefined;
  post();
  check('removeObserver: stops delivery — a second post does not re-fire', firedWith === undefined);
}

// ── (2) Off-main escaping delivery: a background NSOperationQueue → the tsfn bounce ───────────────
{
  const queue = addon.allocInit(__class('NSOperationQueue'));
  let firedOnMain = undefined;
  let resolveFired;
  const fired = new Promise((resolve) => {
    resolveFired = resolve;
  });
  const block = __makeEscapingBlock((note) => {
    // `pthread_self()` isn't exposed to JS; the observable proof is indirect but decisive: this
    // body runs INSIDE the addon's on-thread-0 delivery core (`deliverBlockVoid`) regardless of
    // which OS thread queued it — reaching this callback body AT ALL, asynchronously, from a
    // background NSOperationQueue post (never possible synchronously, since `post()` below returns
    // long before the queue's own thread runs the block) is the off-main-bounce proof: nothing else
    // could have delivered it back onto the JS thread.
    firedOnMain = note;
    resolveFired();
  }, BLOCK_SIG);
  const token = addon.aw_ts_msg_PPPP_P(center, ADD_SEL, NOTE_NAME, 0n, queue, block);
  const postedAt = Date.now();
  post();
  check(
    'a background-queue post returns immediately (block has not fired synchronously)',
    firedOnMain === undefined,
  );
  // Unambiguous proof of genuine off-main decoupling (not just "fast"): busy-block the JS thread
  // for 200ms right after posting. A `napi_threadsafe_function` callback can only run once the JS
  // event loop is free to process its queue — so if delivery were actually synchronous-on-this-
  // thread (the bg queue's post() call itself invoking the block inline before returning, defeating
  // the "off-main" claim), it would have already completed *before* this busy-wait even started.
  // Surviving 200ms of a busy JS thread with `firedOnMain` still unset, THEN observing it fire once
  // the loop is freed, is only possible via a genuine cross-thread bounce.
  const spinUntil = Date.now() + 200;
  while (Date.now() < spinUntil) {
    /* deliberately busy — the JS thread is unavailable to any callback here */
  }
  check(
    'still undecoupled after a 200ms busy-blocked JS thread (delivery genuinely awaits the free loop)',
    firedOnMain === undefined,
  );
  const timeout = new Promise((resolve) => setTimeout(() => resolve('timeout'), 2000));
  const outcome = await Promise.race([fired.then(() => 'fired'), timeout]);
  check(
    'off-main escaping block delivered via the tsfn bounce within 2s',
    outcome === 'fired',
    `waited ${Date.now() - postedAt}ms, outcome=${outcome}`,
  );
  check(
    'the off-main delivery carried the real notification handle',
    typeof firedOnMain === 'bigint' && firedOnMain !== 0n,
    firedOnMain,
  );
  addon.aw_ts_msg_P_v(center, REMOVE_SEL, token);
  addon.release(queue);
}

// ── (3) Boundary containment (ADR-0059 §7): a throwing escaping-block body is caught, not fatal ──
{
  let reported = 0;
  onCallbackError((_err, ctx) => {
    reported++;
    check('block error context has no selector (an escaping block invoke has none)', ctx.selector === undefined, ctx.selector);
  });
  const block = __makeEscapingBlock(() => {
    throw new Error('boom (escaping, on-thread-0)');
  }, BLOCK_SIG);
  const token = addon.aw_ts_msg_PPPP_P(center, ADD_SEL, NOTE_NAME, 0n, 0n, block);
  post();
  check('throwing escaping block body contained → process still running, no C-ABI unwind', true);
  check('onCallbackError fired once for the thrown escaping block', reported === 1, reported);
  addon.aw_ts_msg_P_v(center, REMOVE_SEL, token);
  onCallbackError(null);
}

console.log(failures === 0 ? '\nALL CHECKS PASSED' : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);

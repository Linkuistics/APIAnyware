// JS function → ObjC NS_NOESCAPE block — the runtime *policy* half of ADR-0059 §2 (blocks surface,
// the on-thread-0 direct-invoke fast path). A JS function passed where an ObjC **NS_NOESCAPE** block
// parameter is expected (e.g. `-[NSArray enumerateObjectsUsingBlock:]`) is wrapped by the native core
// into a real ObjC block whose invoke is a generated typed inbound trampoline, invoked **synchronously
// on thread 0** during the enclosing outbound call — so the JS function is held **only for the call's
// duration** (no `napi_threadsafe_function`, no heap-block persistence). Unlike the subclass (k37) /
// delegate (k38) surfaces there is **no selector and no back-ref ivar**: a block invoke's registered
// target *is* the callable, and the native side captures the `CallbackId` directly in the block — so
// `__invokeCallback` reaches the fn via its `call.selector === undefined` branch (built in by k33).
//
// This module owns the *bracket* — register the JS fn, ask the native core for the block-pointer, hand
// it to the outbound call, then release the block + drop the registry entry; the C-ABI *mechanism* (the
// real block, its `@convention(block)` trampoline invoke, the boundary `@catch`) is Swift-native — the
// ADR-0059 Mechanics policy-TS / mechanism-Swift seam, the same split as the subclass/delegate surfaces.
//
// Scope (block-noescape-on-main-k39): the NS_NOESCAPE on-thread-0 fast path lives in `__withNoescapeBlock`.
// The **escaping** default path (block-escaping-off-main-k45, `__makeEscapingBlock` below) is the off-main
// dual: a JS function passed where an ObjC block parameter is expected where the block **escapes** (is
// stored by the framework and invoked later — a completion handler, a notification block) is wrapped into
// a heap ObjC block that **outlives the enclosing call** and may fire **off thread 0**. The JS function is
// therefore **pinned by the registry** (not held only for the call — no `finally` release) and delivery
// reuses the on-thread-0 direct invoke / off-main `napi_threadsafe_function` bounce (ADR-0059 §5). Teardown
// is native-driven: the framework's last release triggers the native holder's dispose, which routes the
// registry-drop back to thread 0 (the ADR-0057 release-on-thread-0 seam) — so this module registers the JS
// function but does **not** release it; the native side does, via `installBlockReleaseDeliverer`.

import {
  type CallbackFn,
  type CallbackId,
  type CallbackMarshal,
  __ensureInbound,
  __registerCallback,
  __releaseCallback,
} from './callbacks.js';
import { __dispatch } from './dispatch.js';

/**
 * Run `fn` as an ObjC `NS_NOESCAPE` block for the duration of `body` (ADR-0059 §2 fast path), on
 * thread 0. Registers `fn` (a block has no selector, so the registered target *is* the callable), asks
 * the native core for a block-pointer whose invoke is the typed inbound trampoline for `signature`,
 * and hands it to `body` — which passes it as the block argument to the ordinary outbound enumerate
 * dispatch. In a `finally` it releases the block and drops the registry entry, so the JS fn is **not**
 * held past the call (the `NS_NOESCAPE` guarantee — no tsfn holder). The block fires synchronously
 * inside `body`, so `fn` is live exactly when the framework invokes it. Returns whatever `body` returns
 * (so it composes with a value-returning outer call).
 *
 * `signature` content-addresses the block ABI (e.g. `'PQP_v'` for `-enumerateObjectsUsingBlock:` —
 * the shared inbound code alphabet, `InboundSig::code_string`: a `BOOL* stop` out-pointer is `P`); an
 * un-installed signature yields a `0n` block-pointer, turned here into a **hard, visible error** (an
 * emitter/analysis bug — the inbound analogue of a missing `aw_ts_msg_*` entry) rather than a nil-block
 * crash inside the framework. Thread-0 only (registry mutation off thread 0 crashes; ADR-0059 Mechanics).
 *
 * `marshal` (`__blockMarshal(…)`, marshal.ts) is the block's **inbound value surface** (ADR-0059 §8) —
 * with it, the JS function receives the object/`SEL`/`Class` types the emitted block type declares
 * instead of raw handles; without it, raw handles (the pre-descriptor behaviour).
 */
export function __withNoescapeBlock<T>(
  fn: CallbackFn,
  signature: string,
  body: (block: bigint) => T,
  marshal?: CallbackMarshal,
): T {
  __ensureInbound();
  const id: CallbackId = __registerCallback(fn, marshal);
  const block = __dispatch.makeBlock(id, signature);
  if (block === 0n) {
    __releaseCallback(id);
    throw new TypeError(
      `@apianyware/runtime: no inbound block trampoline for signature ${signature} (ADR-0059 §2)`,
    );
  }
  try {
    return body(block);
  } finally {
    __dispatch.releaseBlock(block);
    __releaseCallback(id);
  }
}

/**
 * Wrap `fn` as a real **escaping** ObjC block (ADR-0059 §2 default/correctness-first path) and return
 * the heap block-pointer the emitted call site passes as the block argument. Unlike `__withNoescapeBlock`,
 * this is **not** bracketed: an escaping block outlives the enclosing call (the framework stores it and
 * invokes it later — a completion handler, a stored observer), possibly **off thread 0**, so `fn` is
 * **pinned by the registry** for as long as the block can fire and delivery hops every off-main invoke to
 * thread 0. The JS function is registered here; it is **released natively** when the framework tears the
 * block down — the block's captured holder routes `__releaseCallback` back to thread 0 (via
 * `installBlockReleaseDeliverer`, the ADR-0057 release-on-thread-0 seam) — so there is deliberately **no
 * `finally` release** here. Guessing an escaping block is noescape would be a UAF or a leak, which is why
 * escaping is the default and noescape the annotated fast path (ADR-0059 §2 / §Consequences).
 *
 * `signature` content-addresses the block ABI (`'0_v'` = `void (^)(void)`, `'P_v'` = `void (^)(id)`,
 * `'P_b'` = `BOOL (^)(id)` — the shared inbound code alphabet, `InboundSig::code_string`); an
 * un-installed signature yields a `0n` block-pointer, turned here into a
 * **hard, visible error** (an emitter/analysis bug) after dropping the just-minted registry entry — never
 * a nil-block crash inside the framework. Thread-0 only (registry mutation off thread 0 crashes).
 *
 * `marshal` (`__blockMarshal(…)`, marshal.ts) is the block's **inbound value surface** (ADR-0059 §8) —
 * with it, the JS function receives the object/`SEL`/`Class` types the emitted block type declares
 * instead of raw handles; without it, raw handles (the pre-descriptor behaviour).
 */
export function __makeEscapingBlock(
  fn: CallbackFn,
  signature: string,
  marshal?: CallbackMarshal,
): bigint {
  __ensureInbound();
  const id: CallbackId = __registerCallback(fn, marshal);
  const block = __dispatch.makeEscapingBlock(id, signature);
  if (block === 0n) {
    __releaseCallback(id);
    throw new TypeError(
      `@apianyware/runtime: no inbound escaping-block trampoline for signature ${signature} (ADR-0059 §2)`,
    );
  }
  return block;
}

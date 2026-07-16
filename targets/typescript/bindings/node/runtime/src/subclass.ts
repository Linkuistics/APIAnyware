// JS class → dynamic ObjC subclass — the runtime *policy* half of ADR-0059 §3 (subclass surface).
// A JS class `extends`ing a bound ObjC class becomes a real ObjC subclass: ONE synthesized ObjC
// class per JS class (memoized here, thread-0 only), each JS-overridden selector installed as a
// generated typed inbound trampoline IMP by the native core, each instance carrying a back-ref ivar
// to its JS `CallbackId`. This module owns the *when* (memoize the synthesis, register the instance,
// stamp the back-ref); the C-ABI *mechanism* (`objc_allocateClassPair`, `class_addMethod`, the
// trampolines, the ivar write) is Swift-native — the ADR-0057 §4 / ADR-0058 policy-TS/mechanism-Swift
// seam, now on the inbound side.
//
// Scope (subclass-inbound-on-main-k37): the on-thread-0 subclass surface. The delegate surface
// (`respondsToSelector:` snapshot, associated-object keep-alive) and the off-main tsfn paths are
// later `inbound-trampolines-k36` children; the strong `callbacks` registry entry that pins a bound
// instance is released by the dealloc path (a later child), not here.

import {
  type CallbackId,
  type CallbackMarshal,
  __ensureInbound,
  __registerCallback,
} from './callbacks.js';
import { __dispatch } from './dispatch.js';
import { type NSObject, __unwrap } from './lifetime.js';

/**
 * One overridden method for the native synthesis: the raw ObjC `selector` and its ObjC method
 * `typeEncoding` (e.g. `['compare:', 'q@:@']`). The encoding content-addresses the typed inbound
 * trampoline (the inbound dual of ADR-0054's `aw_ts_msg_*` codes); the emitter derives both from the
 * IR. An unsupported encoding is skipped natively (no IMP installed for it).
 */
export type SubclassOverride = readonly [selector: string, typeEncoding: string];

/** A JS class value (a constructor). Keyed identity for the per-class synthesis memo. */
// biome-ignore lint/complexity/noBannedTypes: a JS class is exactly a constructor Function here.
type JSClass = Function;

/** At most one synthesized ObjC `Class` handle per JS class (ADR-0059 §3 — memoized, never disposed). */
const synthesized = new WeakMap<JSClass, bigint>();
let subclassSeq = 0;

/**
 * The synthesized ObjC `Class` handle for `jsClass`, created on first use and memoized. `baseClass`
 * is the bound ObjC superclass handle (the emitted parent's `__cls`); `overrides` are the selectors
 * the JS class overrides — the native side always also installs the shared `dealloc` IMP (ADR-0059 §4),
 * so `dealloc` is not listed here. Thread-0 only (`objc_registerClassPair` races off main).
 */
/**
 * The synthesized ObjC `Class` handle for `jsClass`, or `undefined` if it has never been
 * instantiated (nothing is synthesized until then). Read by `__classArg` (classes.ts) so a
 * user-derived JS class passed as a `Class` argument reaches ObjC as **its own** synthesized
 * class — never the bound parent's, which is what an inherited static would have yielded.
 */
export function __synthesizedClass(jsClass: JSClass): bigint | undefined {
  return synthesized.get(jsClass);
}

export function __subclassClass(
  jsClass: JSClass,
  baseClass: bigint,
  overrides: readonly SubclassOverride[],
): bigint {
  const cached = synthesized.get(jsClass);
  if (cached !== undefined) return cached;
  __ensureInbound();
  subclassSeq += 1;
  const name = `APIAnyware_${jsClass.name || 'Subclass'}_${subclassSeq}`;
  const encoded = overrides.map(([selector, encoding]) => `${selector}|${encoding}`);
  const handle = __dispatch.defineSubclass(baseClass, name, encoded);
  synthesized.set(jsClass, handle);
  return handle;
}

/**
 * Allocate a `+1` owned instance of `jsClass`'s synthesized ObjC subclass — the handle a subclass
 * constructor passes to `super(...)`. Synthesizes the class on first use (memoized). The instance is
 * not yet bound to its JS side; the constructor calls `__bindSubclass(this)` after `super()` returns.
 */
export function __subclassAlloc(
  jsClass: JSClass,
  baseClass: bigint,
  overrides: readonly SubclassOverride[],
): bigint {
  return __dispatch.allocInit(__subclassClass(jsClass, baseClass, overrides));
}

/**
 * Bind a freshly-constructed subclass instance to its JS side: register it (a strong keep-alive that
 * pins it while ObjC can still call back — ADR-0059 §6) and stamp the resulting `CallbackId` into its
 * back-ref ivar so the native trampolines resolve it. Called from the subclass constructor after
 * `super(__subclassAlloc(...))`. Returns the id (for a later dealloc-driven release).
 *
 * `marshal` is the class's **inbound value surface** (ADR-0059 §8) — the converter built from the
 * emitted per-overridable-method value-kind descriptors (`__methodMarshal`), so an override receives
 * the types its `.d.ts` declares. Omitted, the override's values cross as raw handles.
 */
export function __bindSubclass(instance: NSObject, marshal?: CallbackMarshal): CallbackId {
  const id = __registerCallback(instance, marshal);
  __dispatch.setBackRef(__unwrap(instance), id);
  return id;
}

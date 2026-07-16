// The INBOUND value surface (ADR-0059 §8) — what a JS delegate / block / subclass override actually
// *receives* and *returns*. The inbound dual of the outbound value surface (`PtrValue`, ADR-0055
// §3/§5b): outbound, the emitted call site converts because it knows the declared type statically;
// inbound, the call site is `__invokeCallback` — one generic funnel — so the declared type has to
// **travel with the callback**. This module is where it travels as.
//
// ## Why the kind cannot live in the trampoline
//
// The generated inbound trampolines are content-addressed by **ABI signature**
// (`InboundSig::code_string`), and at the ABI an `id`, a `SEL`, a `Class`, a block and a raw pointer
// are *one thing*: they all collapse to the pointer code `P` / encoding `@`. That collapse is right —
// it is what lets ~50 trampolines cover the whole corpus. But it means the trampoline **cannot know**
// which of its pointer args is an object to wrap, which is a selector to name, which is a metatype to
// resolve. Nor could it act on that knowledge if it had it: wrapping needs the uniquing map
// (lifetime.ts), the ctor registry (classes.ts) and the selector memo (dispatch.ts), all of which are
// TS-side policy.
//
// So the value kind rides from the emitter to the runtime as a per-method **descriptor**, and the
// conversion happens here. Same species as k66's `Class{…}` overload and k76's file stem: *a lossy
// map used as a key* — either it is not a key, or the loss is re-encoded. Here it is re-encoded.
//
// ## The lifetime rule (ADR-0057 §2, the third wrap primitive)
//
// An inbound object arg is **borrowed** — `+0`, the ObjC caller owns it, nothing folded a retain in,
// and the method's convention gave none away. It wraps through [`__wrapBorrowed`]: a live wrapper is
// returned as-is (zero crossings — the same `sender` on every event); a fresh one takes its own +1.
// That reconstructs the store-time retain ARC inserts and JS cannot, so `this.lastSender = sender`
// is sound rather than a use-after-free at the next turn boundary.
//
// An object a JS callback **returns** follows the ADR-0057 §4 **three-state retain axis** — the very
// predicate (`method_retain_axis`) the outbound table, the emitted call sites and the `$super`
// entries already read (one decision, N readers): a `+0`-convention selector hands back
// `objc_retainAutorelease` (the real ObjC contract — so `return NSMenu.alloc().init()` is safe by
// construction, independent of the JS wrapper's +1); a `+1`-convention one (an overridden
// `copyWithZone:`/`init`) hands back `objc_retain` (the caller owns it); a `SEL`/`Class` return takes
// neither (retaining a class leaks; `objc_retain` on a selector is undefined behaviour).
//
// ## The seam split
//
// Policy here (which kind, which ctor, when to retain); mechanism in Swift (`objc_retain` /
// `objc_retainAutorelease`) — the same split as retain-on-wrap and the error `@catch` (ADR-0059
// Mechanics). And the runtime stays dumb: it consults no signature table at call time, it applies a
// descriptor the *registrant* supplied, exactly as an emitted call site applies a wrap primitive the
// emitter chose.

import type { CallbackMarshal } from './callbacks.js';
import { type ObjCClass, __classArg, __classCtor } from './classes.js';
import { __dispatch, __sel, __selName } from './dispatch.js';
import { type NSObject, __unwrap, __wrapBorrowed } from './lifetime.js';

/**
 * How one **argument** crosses ObjC → JS. `raw` is every scalar/bool/double (and, for now, every
 * pointer shape outside the three below — a block pointer, a `BOOL* stop` out-pointer); `obj` is any
 * ObjC object, wrapped into its **real** class.
 *
 * ## Why `obj` carries no class (reconciles ADR-0059 §8, `emitted-delegate-spec-k84`)
 *
 * §8 had `obj` name the **declared** class, and rejected resolving the wrapper by the object's
 * *dynamic* class — because at the time the class-less wrap minted a **stand-in** for any class the
 * registry did not hold, and a declared `NSString` is really a `__NSCFString`, which no binding
 * declares. [`dynamic-class-wrap-k88`](ADR-0057 §3b) then made the class-less arm climb to the
 * **nearest bound ancestor**, so `__NSCFString` now resolves to `NSString` — and the rejection's
 * premise is simply false. The dynamic class is a *descendant* of the declared one by construction,
 * so its nearest bound ancestor is always **at or below** the declared class: never less specific,
 * often more (a declared `NSString` that is really an `NSMutableString` wraps as one). Carrying the
 * class bought nothing, and it cost the spec module a **value** import of every declared arg class —
 * which is what would have made a same-framework spec/class pair a module cycle with a TDZ on the
 * spec `const`. Dropping it, an emitted `delegates.ts` imports nothing but the runtime.
 */
export type ArgKind =
  | { readonly k: 'raw' }
  | { readonly k: 'sel' }
  | { readonly k: 'cls' }
  | { readonly k: 'obj' };

/** The ADR-0057 §4 retain convention of an object a callback returns: `+0` (the default) or `+1`. */
export type RetainAxis = 'plain' | 'owned';

/** How the **return** crosses JS → ObjC. An `obj` return carries its retain axis, not a ctor. */
export type RetKind =
  | { readonly k: 'raw' }
  | { readonly k: 'sel' }
  | { readonly k: 'cls' }
  | { readonly k: 'obj'; readonly axis: RetainAxis };

/** One method's inbound value surface: a kind per visible arg, plus the return's. */
export interface MethodMarshal {
  readonly args: readonly ArgKind[];
  readonly ret: RetKind;
}

/** A scalar/bool/double — or a pointer shape with no TS-surface conversion. Crosses unconverted. */
export const RAW = { k: 'raw' } as const;
/** An ObjC `SEL` ⟷ its selector-name `string` (ADR-0055 §3). */
export const SEL = { k: 'sel' } as const;
/** An ObjC `Class` metatype ⟷ the bound TS constructor (ADR-0055 §5b). */
export const CLS = { k: 'cls' } as const;
/** An object **argument** — borrowed (+0 → `__wrapBorrowed`), wrapped into its real class. */
export const OBJ = { k: 'obj' } as const;

/** An object **return** — `'plain'` (+0, retain-autoreleased) or `'owned'` (+1, an `init`/`copy`). */
export function RET_OBJ(axis: RetainAxis = 'plain'): RetKind {
  return { k: 'obj', axis };
}

/** A `void` / scalar return, and the default for a method whose return needs no conversion. */
export const RET_RAW: RetKind = RAW;

/** Convert one raw C-ABI arg the trampoline delivered into its declared TS type. */
function argIn(kind: ArgKind, raw: unknown): unknown {
  switch (kind.k) {
    case 'raw':
      return raw;
    case 'sel':
      return __selName(raw as bigint);
    case 'cls':
      return __classCtor(raw as bigint);
    case 'obj':
      // The class-less arm: the object's own class, resolved through the ctor registry and climbed
      // to the nearest bound ancestor (ADR-0057 §3b). See `ArgKind` for why no declared class rides
      // along — it could only be less specific than this.
      return __wrapBorrowed(raw as bigint);
  }
}

function isThenable(v: unknown): boolean {
  return (
    (typeof v === 'object' || typeof v === 'function') &&
    v !== null &&
    typeof (v as { then?: unknown }).then === 'function'
  );
}

/**
 * Convert the JS return into the raw handle/scalar the trampoline hands back to ObjC, carrying the
 * ownership the ObjC caller expects (see the module doc). A method that returns nothing yields
 * `undefined`, which reads as nil for every pointer kind.
 *
 * A **thenable under a pointer kind** is the ADR-0059 §7 async-in-a-value-slot case, and it is caught
 * here rather than left to fail as a mystery unwrap: an `async` method cannot deliver a value
 * synchronously (§5 forbids inline `await`), so it is reported and coerced to the typed default — the
 * same outcome `__deliverValueReturning` produces for an *un*marshalled callback, with the message
 * intact. A thenable under `raw` is left alone: an `async` **void** delegate method is legitimate
 * (a callback needing async work schedules it), and its return is ignored natively.
 */
function retOut(kind: RetKind, value: unknown): unknown {
  if (kind.k !== 'raw' && isThenable(value)) {
    throw new TypeError('async callback cannot return a value synchronously');
  }
  switch (kind.k) {
    case 'raw':
      return value;
    case 'sel':
      return __sel((value ?? null) as string | null);
    case 'cls':
      return __classArg((value ?? null) as ObjCClass | null);
    case 'obj': {
      const handle = __unwrap((value ?? null) as NSObject | null);
      if (handle === 0n) return 0n;
      return kind.axis === 'owned'
        ? __dispatch.retain(handle)
        : __dispatch.retainAutorelease(handle);
    }
  }
}

/**
 * The shared conversion driver. A descriptor the registrant supplied but that does not cover the
 * arriving selector is an **emitter/spec bug**, not a value to guess at — so it throws, which
 * `__invokeCallback` contains and reports through `onCallbackError` (visible, non-fatal, typed
 * default). Silently passing the raw handle through is exactly the lie this module exists to remove.
 */
function driver(
  lookup: (selector: string | undefined) => MethodMarshal | undefined,
): CallbackMarshal {
  const need = (selector: string | undefined): MethodMarshal => {
    const m = lookup(selector);
    if (m === undefined) {
      throw new TypeError(
        `@apianyware/runtime: no inbound value descriptor for ${selector ?? '<block>'} (ADR-0059 §8)`,
      );
    }
    return m;
  };
  return {
    in(selector, args) {
      const m = need(selector);
      // An arg past the descriptor's arity is a signature mismatch, not a value to convert — leave
      // it raw and let the typed trampoline's own arity be the authority.
      return args.map((a, i) => (i < m.args.length ? argIn(m.args[i], a) : a));
    },
    out(selector, value) {
      return retOut(need(selector).ret, value);
    },
  };
}

/**
 * The converter a **delegate / subclass** registers: one [`MethodMarshal`] per **raw ObjC selector**
 * (`'application:openFile:'`, not the injective `application_openFile_` name — the native trampoline
 * delivers the raw `_cmd`, and the runtime does the `:`→`_` mapping separately).
 */
export function __methodMarshal(methods: Readonly<Record<string, MethodMarshal>>): CallbackMarshal {
  return driver((selector) => (selector === undefined ? undefined : methods[selector]));
}

/**
 * The converter a **block** registers: one [`MethodMarshal`], no selector (a block's registered
 * target *is* the callable, so `call.selector === undefined` — callbacks.ts).
 */
export function __blockMarshal(marshal: MethodMarshal): CallbackMarshal {
  return driver((selector) => (selector === undefined ? marshal : undefined));
}

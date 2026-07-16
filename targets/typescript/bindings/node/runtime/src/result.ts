// The error-model value machinery (ADR-0058): the `Result<T>` discriminated union, the
// `__result*` boundary constructors that read the native `…_e` discriminant, and `unwrap`.
// Pure TS — the native `@catch` + primary-return detection are Step 4 (mechanism native,
// policy runtime; the same seam split as retain-on-wrap, ADR-0057 §4).

import { NSErrorError, NSExceptionError } from './errors.js';
import { NSObject, __wrapOwned, __wrapRetained } from './lifetime.js';

/**
 * A fallible selector's type-visible surface (ADR-0058 §1): on success `ok: true` carries the
 * wrapped primary return; on failure `ok: false` carries the bound `NSError`. The `ok`
 * discriminant makes `value` unreachable on the failure arm, so the compiler forces the check —
 * the type-visibility win a bare tuple cannot give.
 *
 * Layering (ADR-0058 §1, reconciled): the error arm is typed as the runtime root `NSObject`,
 * not Foundation's `NSError` — only `NSObject` is runtime-owned and `@apianyware/foundation`
 * imports *from* this package, so naming `NSError` here would form a cycle. The native object
 * behind the handle IS a real `NSError`; typed `.domain`/`.userInfo` access is a future
 * Foundation class-registration refinement (see errors.ts).
 */
export type Result<T> =
  | { readonly ok: true; readonly value: T }
  | { readonly ok: false; readonly error: NSObject };

/**
 * The structured discriminant the native `…_e` dispatch entry returns (ADR-0058 §Mechanics) —
 * the wire contract Step 4's `@_cdecl` entry must produce, defined here because the runtime is
 * built before the addon. The native side decides ONLY the exception axis (it `@catch`es an
 * escaping `NSException`, which must never unwind the C ABI into V8, ADR-0056); the TS helper
 * keys `ok:false` on the primary return (nil / `NO`), per Apple's "check the return, not the
 * error" — the mechanism invariant every target shares.
 *
 * - `thrown: false` — a normal return: `primary` is the primary value (an object `id` as a
 *   `bigint`, or a scalar `boolean`); `error` is the out-param `NSError` id (read only when the
 *   primary keys failure — it may hold garbage on success).
 * - `thrown: true` — an `NSException` was caught: `exception` is its id, `reason` its
 *   `-reason` string (captured native-side so the JS `Error.message` needs no further crossing).
 */
export type NativeErrorResult =
  | { readonly thrown: true; readonly exception: bigint; readonly reason: string }
  | {
      readonly thrown: false;
      readonly primary: bigint | number | boolean;
      readonly error: bigint;
    };

/** Escalate a caught `NSException` discriminant to the throw channel (shared by all helpers). */
function throwNSException(r: { exception: bigint; reason: string }): never {
  // The exception wrapper is +0 (autoreleased by the native @catch) — wrap via the +0 primitive.
  throw new NSExceptionError(__wrapRetained(NSObject, r.exception) as NSObject, r.reason);
}

/** Wrap the failure NSError (a +0 autoreleased out-param) as the `ok:false` arm. */
function failure(errorId: bigint): { readonly ok: false; readonly error: NSObject } {
  return { ok: false, error: __wrapRetained(NSObject, errorId) as NSObject };
}

/**
 * Build the `Result` for a fallible selector with a **+0 (autoreleased) object primary**
 * (`objectFromFile:error:`): nil primary → `ok:false` (wraps the `NSError`); a live primary →
 * `ok:true` (wraps it +0 via `__wrapRetained`). A caught `NSException` throws (§2).
 */
export function __resultRetained<T extends NSObject>(
  Cls: new (handle: bigint) => T,
  r: NativeErrorResult,
): Result<T>;
/**
 * The IR declares no class for the primary (a bare `id`): wrap into the object's **real** class
 * (`dynamic-class-wrap-k88`) — the same class-less arm the plain wrap primitives take.
 *
 * `T` is the declared conformance a protocol-qualified primary carries (defaulting to `NSObject`),
 * exactly as on `__wrapRetained` — so a fallible selector returning `id<P>` declares
 * `Result<P & NSObject>` and its wrap satisfies it (`protocol-binding-surface-k89`).
 */
export function __resultRetained<T extends NSObject = NSObject>(r: NativeErrorResult): Result<T>;
export function __resultRetained(
  a: (new (handle: bigint) => NSObject) | NativeErrorResult,
  b?: NativeErrorResult,
): Result<NSObject> {
  const [Cls, r] = resultArgs(a, b);
  if (r.thrown) throwNSException(r);
  const primary = r.primary as bigint;
  if (primary === 0n) return failure(r.error);
  const value = Cls === null ? __wrapRetained(primary) : __wrapRetained(Cls, primary);
  return { ok: true, value: value as NSObject };
}

/**
 * Build the `Result` for a fallible selector with a **+1 (owned) object primary** (an
 * `init…error:` / `new…error:` factory): identical keying to [`__resultRetained`], but a live
 * primary wraps +1 via `__wrapOwned` (which balances a redundant +1 on a live duplicate).
 */
export function __resultOwned<T extends NSObject>(
  Cls: new (handle: bigint) => T,
  r: NativeErrorResult,
): Result<T>;
/**
 * The IR declares no class for the primary (a bare `id`): wrap into the object's **real** class
 * (`dynamic-class-wrap-k88`) — the same class-less arm the plain wrap primitives take.
 *
 * `T` is the declared conformance a protocol-qualified primary carries (defaulting to `NSObject`),
 * exactly as on `__wrapRetained` — so a fallible selector returning `id<P>` declares
 * `Result<P & NSObject>` and its wrap satisfies it (`protocol-binding-surface-k89`).
 */
export function __resultOwned<T extends NSObject = NSObject>(r: NativeErrorResult): Result<T>;
export function __resultOwned(
  a: (new (handle: bigint) => NSObject) | NativeErrorResult,
  b?: NativeErrorResult,
): Result<NSObject> {
  const [Cls, r] = resultArgs(a, b);
  if (r.thrown) throwNSException(r);
  const primary = r.primary as bigint;
  if (primary === 0n) return failure(r.error);
  const value = Cls === null ? __wrapOwned(primary) : __wrapOwned(Cls, primary);
  return { ok: true, value: value as NSObject };
}

/**
 * Normalize the two call shapes the object-primary Result builders accept — `(Cls, r)` when the IR
 * declared the primary's class, `(r)` when it did not. The `NativeErrorResult` is a plain object and a
 * ctor is a function, so the arms are distinguishable without a marker (the `wrapArgs` shape, lifetime.ts).
 */
function resultArgs(
  a: (new (handle: bigint) => NSObject) | NativeErrorResult,
  b?: NativeErrorResult,
): [(new (handle: bigint) => NSObject) | null, NativeErrorResult] {
  return typeof a === 'function' ? [a, b as NativeErrorResult] : [null, a];
}

/**
 * Build the `Result` for a fallible selector with a **BOOL primary** (`writeToFile:error:`):
 * `NO`/falsy primary → `ok:false` (wraps the `NSError`); `YES` → `ok:true`. A BOOL primary
 * carries no further information beyond the flag itself, so the success value is `true`. A
 * caught `NSException` throws (§2).
 */
export function __resultScalar(r: NativeErrorResult): Result<boolean> {
  if (r.thrown) throwNSException(r);
  if (!r.primary) return failure(r.error);
  return { ok: true, value: true };
}

/**
 * Build the `Result` for a fallible selector with a **non-BOOL scalar primary**
 * (`writeJSONObject(_:toStream:options:error:) -> Int`, e.g. a byte count): unlike a BOOL
 * primary, a non-BOOL scalar's nonzero success value IS data the caller wants — Apple's
 * zero-on-failure convention still keys `ok:false` (ADR-0058 reconciled — a scalar primary is
 * not always BOOL, but is always keyed the same way), but the real value must ride through on
 * success instead of a hard-coded flag. `r.primary` already carries the marshalled value (the
 * native `…_e` entry widens every non-BOOL scalar to a JS `number`, `native_dispatch.rs`'s
 * `primary_expr`), so no further coercion is needed. A caught `NSException` throws (§2).
 */
export function __resultScalarValue(r: NativeErrorResult): Result<number> {
  if (r.thrown) throwNSException(r);
  if (!r.primary) return failure(r.error);
  return { ok: true, value: r.primary as number };
}

/**
 * The opt-in bridge from a `Result` failure to the throw channel (ADR-0058 §3): returns
 * `r.value`, or throws `new NSErrorError(r.error)` — the Rust `Result::unwrap` idiom. It exists
 * because the target style forbids throwing a plain object: escalating a `Result` to a throw must
 * go through a proper `Error` subclass. `Result` stays the default type-visible surface; `unwrap`
 * is the explicit escalation.
 */
export function unwrap<T>(r: Result<T>): T {
  if (r.ok) return r.value;
  throw new NSErrorError(r.error);
}

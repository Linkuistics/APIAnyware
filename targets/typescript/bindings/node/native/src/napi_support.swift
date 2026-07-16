// N-API marshalling helpers for the Swift-native addon (napi-dispatch-spine-k35).
//
// These wrap the raw `napi_*` C surface (imported via shim.h) into small Swift helpers
// the dispatch entries use to read JS arguments and build JS return values. The addon
// hosts N-API directly in Swift — there is no napi-rs / Rust marshalling layer
// (ADR-0054 §2, core-language confirmed Swift-native here). Opaque N-API handles
// (`napi_env`, `napi_value`, `napi_callback_info`) import from the C typedefs as
// `OpaquePointer?`; the ObjC id/SEL/Class handles cross to JS as `bigint` (a raw
// pointer address in a `UInt`), per the substrate spike's opaque-handle boundary.

import AppKit  // NSDirectionalEdgeInsets + the rest of the POD geometry family (ADR-0042)
import Foundation

/// N-API's "the string is null-terminated, compute the length" sentinel (`SIZE_MAX`).
let NAPI_AUTO_LENGTH = ~size_t(0)

/// Read a JS string argument as a Swift `String` (two-call: size, then copy). `nil` on
/// a non-string / failed read. Used for class names, selector names, and `cfstr` literals.
func napiReadString(_ env: napi_env?, _ value: napi_value?) -> String? {
    var len: size_t = 0
    guard napi_get_value_string_utf8(env, value, nil, 0, &len) == napi_ok else { return nil }
    var buf = [CChar](repeating: 0, count: len + 1)
    var copied: size_t = 0
    guard napi_get_value_string_utf8(env, value, &buf, len + 1, &copied) == napi_ok else {
        return nil
    }
    return String(cString: buf)
}

/// Build a JS string return value.
func napiMakeString(_ env: napi_env?, _ s: String) -> napi_value? {
    var result: napi_value?
    _ = s.withCString { napi_create_string_utf8(env, $0, NAPI_AUTO_LENGTH, &result) }
    return result
}

/// Read a JS `bigint` argument as a raw pointer-width handle (`UInt`). ObjC id/SEL/Class
/// cross the seam as `bigint` (ADR-0054 §2); `0n` is the null handle.
func napiReadHandle(_ env: napi_env?, _ value: napi_value?) -> UInt {
    var out: UInt64 = 0
    var lossless = false
    _ = napi_get_value_bigint_uint64(env, value, &out, &lossless)
    return UInt(out)
}

/// Build a JS `bigint` return value from a raw handle — the id/SEL/Class opaque handle.
func napiMakeHandle(_ env: napi_env?, _ handle: UInt) -> napi_value? {
    var result: napi_value?
    _ = napi_create_bigint_uint64(env, UInt64(handle), &result)
    return result
}

/// Marshal an object return to a **+1** `id` handle for the runtime's `__wrapOwned` (ADR-0057 §4,
/// `object-bridged-returns-k55`). A Swift-native residual trampoline calls a function by name, gets
/// an object — a Foundation-bridged value (`String`→`NSString`, `[T]`→`NSArray`) or a class
/// instance — and hands JS a raw pointer at +1: `Unmanaged.passRetained` adds the +1 the wrapper
/// takes (balanced by dispose's `objc_release`). A nil object (an `Optional` `.none`, e.g. a `T?`
/// return) → the null handle `0` (→ `__wrapOwned` → `null`). This is the object dual of the +0
/// object-return dispatch entries' `objcRetain` fold: both hand JS a uniform +1.
func napiMakeRetainedObject(_ env: napi_env?, _ object: AnyObject?) -> napi_value? {
    guard let object else { return napiMakeHandle(env, 0) }
    return napiMakeHandle(env, UInt(bitPattern: Unmanaged.passRetained(object).toOpaque()))
}

/// Read a JS number argument as `Int64` (for scalar setters, e.g. `-setTag:`).
func napiReadInt64(_ env: napi_env?, _ value: napi_value?) -> Int64 {
    var out: Int64 = 0
    _ = napi_get_value_int64(env, value, &out)
    return out
}

/// Read a JS number argument as `Double` — a scalar `double`/`CGFloat` argument to a
/// Swift-native free-function trampoline (`aw_ts_swift_*`, fn-trampoline-spine-k53).
func napiReadDouble(_ env: napi_env?, _ value: napi_value?) -> Double {
    var out: Double = 0
    _ = napi_get_value_double(env, value, &out)
    return out
}

/// Read a JS number argument as `UInt64` (an unsigned scalar argument, code `Q` — e.g.
/// `-setLength:` taking `NSUInteger`). N-API has no direct number→u64, so route through
/// the `double` path (exact ≤ 2^53, the same loss posture as `napiMakeUInt64`); a
/// negative / non-finite number clamps to 0 rather than trapping.
func napiReadUInt64(_ env: napi_env?, _ value: napi_value?) -> UInt64 {
    let d = napiReadDouble(env, value)
    guard d.isFinite, d > 0 else { return 0 }
    return UInt64(d)
}

/// Build a JS number from an `Int64` (a signed scalar return, code `q`).
func napiMakeInt64(_ env: napi_env?, _ v: Int64) -> napi_value? {
    var result: napi_value?
    _ = napi_create_int64(env, v, &result)
    return result
}

/// Build a JS number from a `UInt64` (an unsigned scalar return, code `Q`; e.g. `-length`).
/// N-API has no direct u64→number, so route through the loss-checked `double` path — exact
/// for values ≤ 2^53, which covers every count/length this spine exercises.
func napiMakeUInt64(_ env: napi_env?, _ v: UInt64) -> napi_value? {
    var result: napi_value?
    _ = napi_create_double(env, Double(v), &result)
    return result
}

/// Build a JS number from a `Double` (a floating scalar return/read, codes `d`/`f`; e.g. a
/// `const double` global read through `aw_ts_const_d`).
func napiMakeDouble(_ env: napi_env?, _ v: Double) -> napi_value? {
    var result: napi_value?
    _ = napi_create_double(env, v, &result)
    return result
}

/// Build a JS `undefined` — the return for a `void` (`v`) dispatch entry.
func napiUndefined(_ env: napi_env?) -> napi_value? {
    var result: napi_value?
    _ = napi_get_undefined(env, &result)
    return result
}

/// Build a JS boolean — the return for a `BOOL` (`B`) dispatch entry (e.g. `-respondsToSelector:`).
func napiMakeBool(_ env: napi_env?, _ v: Bool) -> napi_value? {
    var result: napi_value?
    _ = napi_get_boolean(env, v, &result)
    return result
}

/// Set a numeric (double) named property on a JS object — used to marshal a POD struct.
private func napiSetDouble(_ env: napi_env?, _ obj: napi_value?, _ name: String, _ v: Double) {
    var num: napi_value?
    _ = napi_create_double(env, v, &num)
    _ = napi_set_named_property(env, obj, name, num)
}

/// Marshal a `CGRect` (arm64 x8 struct-by-value return, code `R`) into a plain JS
/// `{ origin: { x, y }, size: { width, height } }` object — the POD-object surface (ADR-0042).
/// **Nested**, because `struct CGRect { CGPoint origin; CGSize size; }` is: the family rule is that
/// the JS object mirrors the C struct's fields, and CGRect is the one member whose struct is itself
/// nested (ADR-0055 §5). Nesting is what keeps `rect.origin` the very `CGPoint` a CGPoint-taking
/// method wants. Proving this crosses the Swift-native N-API boundary is the load-bearing
/// marshalling-depth evidence (the substrate spike proved it through napi-rs; this proves it
/// Swift-native).
func napiMakeRect(_ env: napi_env?, _ r: CGRect) -> napi_value? {
    var obj: napi_value?
    _ = napi_create_object(env, &obj)
    _ = napi_set_named_property(env, obj, "origin", napiMakePoint(env, r.origin))
    _ = napi_set_named_property(env, obj, "size", napiMakeSize(env, r.size))
    return obj
}

/// Marshal an `NSRange` (a struct-by-value return, code `G`) into a plain JS
/// `{ location, length }` object — the register-pair struct case (16 bytes, x0:x1). A
/// deterministic, Foundation-only (headless-safe) companion to the CGRect x8 case.
func napiMakeRange(_ env: napi_env?, _ location: UInt, _ length: UInt) -> napi_value? {
    var obj: napi_value?
    _ = napi_create_object(env, &obj)
    var loc: napi_value?
    _ = napi_create_double(env, Double(location), &loc)
    _ = napi_set_named_property(env, obj, "location", loc)
    var len: napi_value?
    _ = napi_create_double(env, Double(length), &len)
    _ = napi_set_named_property(env, obj, "length", len)
    return obj
}

// ── The POD geometry family (ADR-0042 population A) — struct ⇄ JS-object marshalling ───────
// The generated dispatch table (Generated/DispatchTable.swift) routes every by-value geometry
// struct through a `napiMake<Stem>` maker (result) and a `napiRead<Stem>` reader (argument):
// a plain JS object with the struct's own field names, doubles throughout.
//
// **One rule: the JS object mirrors the C struct** (ADR-0055 §5) — same field names, same
// nesting. Eight of the nine are flat because their C structs are; `CGRect` is nested because
// `struct CGRect { CGPoint origin; CGSize size; }` is. There is no exception to file away: the
// emitted `.d.ts` types (`@apianyware/runtime`, `structs.ts`) are these shapes, one for one, and
// `tsc` checks every call site against them.
//
// Readers default a missing/non-numeric field to 0 (JS-side typoes surface as zeroed geometry,
// never a crash — a missing `origin` reads as a zeroed CGPoint by the same rule). `NSRange`
// fields import as `Int` in Swift; they marshal through the `NSUInteger` bit pattern like the
// hand-written `P_G` entry always did.

/// Read one numeric field of a JS object (`0` when absent / non-numeric).
private func napiGetDouble(_ env: napi_env?, _ obj: napi_value?, _ name: String) -> Double {
    napiReadDouble(env, napiGetNamed(env, obj, name))
}

/// `NSRange` overload of [`napiMakeRange`] — the generated entries pass the struct value.
func napiMakeRange(_ env: napi_env?, _ r: NSRange) -> napi_value? {
    napiMakeRange(env, UInt(bitPattern: r.location), UInt(bitPattern: r.length))
}

func napiReadRect(_ env: napi_env?, _ value: napi_value?) -> CGRect {
    CGRect(
        origin: napiReadPoint(env, napiGetNamed(env, value, "origin")),
        size: napiReadSize(env, napiGetNamed(env, value, "size")))
}

func napiMakePoint(_ env: napi_env?, _ p: CGPoint) -> napi_value? {
    var obj: napi_value?
    _ = napi_create_object(env, &obj)
    napiSetDouble(env, obj, "x", p.x)
    napiSetDouble(env, obj, "y", p.y)
    return obj
}

func napiReadPoint(_ env: napi_env?, _ value: napi_value?) -> CGPoint {
    CGPoint(x: napiGetDouble(env, value, "x"), y: napiGetDouble(env, value, "y"))
}

func napiMakeSize(_ env: napi_env?, _ s: CGSize) -> napi_value? {
    var obj: napi_value?
    _ = napi_create_object(env, &obj)
    napiSetDouble(env, obj, "width", s.width)
    napiSetDouble(env, obj, "height", s.height)
    return obj
}

func napiReadSize(_ env: napi_env?, _ value: napi_value?) -> CGSize {
    CGSize(width: napiGetDouble(env, value, "width"), height: napiGetDouble(env, value, "height"))
}

func napiReadRange(_ env: napi_env?, _ value: napi_value?) -> NSRange {
    NSRange(
        location: Int(napiGetDouble(env, value, "location")),
        length: Int(napiGetDouble(env, value, "length")))
}

func napiMakeEdgeInsets(_ env: napi_env?, _ i: NSEdgeInsets) -> napi_value? {
    var obj: napi_value?
    _ = napi_create_object(env, &obj)
    napiSetDouble(env, obj, "top", i.top)
    napiSetDouble(env, obj, "left", i.left)
    napiSetDouble(env, obj, "bottom", i.bottom)
    napiSetDouble(env, obj, "right", i.right)
    return obj
}

func napiReadEdgeInsets(_ env: napi_env?, _ value: napi_value?) -> NSEdgeInsets {
    NSEdgeInsets(
        top: napiGetDouble(env, value, "top"), left: napiGetDouble(env, value, "left"),
        bottom: napiGetDouble(env, value, "bottom"), right: napiGetDouble(env, value, "right"))
}

func napiMakeDirectionalEdgeInsets(_ env: napi_env?, _ i: NSDirectionalEdgeInsets) -> napi_value? {
    var obj: napi_value?
    _ = napi_create_object(env, &obj)
    napiSetDouble(env, obj, "top", i.top)
    napiSetDouble(env, obj, "leading", i.leading)
    napiSetDouble(env, obj, "bottom", i.bottom)
    napiSetDouble(env, obj, "trailing", i.trailing)
    return obj
}

func napiReadDirectionalEdgeInsets(_ env: napi_env?, _ value: napi_value?)
    -> NSDirectionalEdgeInsets
{
    NSDirectionalEdgeInsets(
        top: napiGetDouble(env, value, "top"), leading: napiGetDouble(env, value, "leading"),
        bottom: napiGetDouble(env, value, "bottom"),
        trailing: napiGetDouble(env, value, "trailing"))
}

func napiMakeAffineTransformStruct(_ env: napi_env?, _ t: NSAffineTransformStruct) -> napi_value? {
    var obj: napi_value?
    _ = napi_create_object(env, &obj)
    napiSetDouble(env, obj, "m11", t.m11)
    napiSetDouble(env, obj, "m12", t.m12)
    napiSetDouble(env, obj, "m21", t.m21)
    napiSetDouble(env, obj, "m22", t.m22)
    napiSetDouble(env, obj, "tX", t.tX)
    napiSetDouble(env, obj, "tY", t.tY)
    return obj
}

func napiReadAffineTransformStruct(_ env: napi_env?, _ value: napi_value?)
    -> NSAffineTransformStruct
{
    NSAffineTransformStruct(
        m11: napiGetDouble(env, value, "m11"), m12: napiGetDouble(env, value, "m12"),
        m21: napiGetDouble(env, value, "m21"), m22: napiGetDouble(env, value, "m22"),
        tX: napiGetDouble(env, value, "tX"), tY: napiGetDouble(env, value, "tY"))
}

func napiMakeAffineTransform(_ env: napi_env?, _ t: CGAffineTransform) -> napi_value? {
    var obj: napi_value?
    _ = napi_create_object(env, &obj)
    napiSetDouble(env, obj, "a", t.a)
    napiSetDouble(env, obj, "b", t.b)
    napiSetDouble(env, obj, "c", t.c)
    napiSetDouble(env, obj, "d", t.d)
    napiSetDouble(env, obj, "tx", t.tx)
    napiSetDouble(env, obj, "ty", t.ty)
    return obj
}

func napiReadAffineTransform(_ env: napi_env?, _ value: napi_value?) -> CGAffineTransform {
    CGAffineTransform(
        a: napiGetDouble(env, value, "a"), b: napiGetDouble(env, value, "b"),
        c: napiGetDouble(env, value, "c"), d: napiGetDouble(env, value, "d"),
        tx: napiGetDouble(env, value, "tx"), ty: napiGetDouble(env, value, "ty"))
}

func napiMakeVector(_ env: napi_env?, _ v: CGVector) -> napi_value? {
    var obj: napi_value?
    _ = napi_create_object(env, &obj)
    napiSetDouble(env, obj, "dx", v.dx)
    napiSetDouble(env, obj, "dy", v.dy)
    return obj
}

func napiReadVector(_ env: napi_env?, _ value: napi_value?) -> CGVector {
    CGVector(dx: napiGetDouble(env, value, "dx"), dy: napiGetDouble(env, value, "dy"))
}

// ── Error-out (`…_e`) NativeErrorResult marshalling (ADR-0058) ──────────────────────────────
// The `…_e` `@catch` entries hand back the runtime's `NativeErrorResult` discriminant
// (`result.ts`): the native side decides ONLY the exception axis (`@catch`, via `awexc.m`) and
// the retain convention; the TS `__result*` keys `ok`/`false` on the primary (nil / `NO`).

/// Copy the `awexc.m` `-reason` C string into a Swift `String` and `free` the malloc'd buffer.
/// `nil` (an exception with no reason) becomes "" — the shim never returns a dangling pointer.
func napiTakeReason(_ cstr: UnsafeMutablePointer<CChar>?) -> String {
    guard let cstr else { return "" }
    defer { free(cstr) }
    return String(cString: cstr)
}

/// Build the `NativeErrorResult` "thrown" arm — `{ thrown: true, exception, reason }`. The
/// exception id is +1 (retained by the `awexc.m` `@catch`), taken by the runtime's
/// `__wrapRetained`; `reason` was captured native-side so the JS `Error.message` needs no
/// further crossing (the root-typed wrapper exposes no `-reason` accessor).
func napiMakeThrownResult(_ env: napi_env?, _ exception: UInt, _ reason: String) -> napi_value? {
    let obj = napiNewObject(env)
    napiSetNamed(env, obj, "thrown", napiMakeBool(env, true))
    napiSetNamed(env, obj, "exception", napiMakeHandle(env, exception))
    napiSetNamed(env, obj, "reason", napiMakeString(env, reason))
    return obj
}

/// Build the `NativeErrorResult` "normal" arm — `{ thrown: false, primary, error }`. `primary`
/// is a pre-marshalled napi value (an object `bigint` handle folded per the entry's +0/+1
/// convention, or a `BOOL`); `error` is the +1 out-param `NSError` (read only by `__result*`
/// when the primary keys failure — it may be 0 on success).
func napiMakeNormalResult(_ env: napi_env?, _ primary: napi_value?, _ error: UInt) -> napi_value? {
    let obj = napiNewObject(env)
    napiSetNamed(env, obj, "thrown", napiMakeBool(env, false))
    napiSetNamed(env, obj, "primary", primary)
    napiSetNamed(env, obj, "error", napiMakeHandle(env, error))
    return obj
}

/// Read the argument vector of a callback (fixed capacity — every entry this spine hosts
/// takes ≤ 3 args: receiver, selector, and at most one visible parameter).
func napiCallbackArgs(_ env: napi_env?, _ info: napi_callback_info?, _ count: Int) -> [napi_value?] {
    var argc = size_t(count)
    var argv = [napi_value?](repeating: nil, count: max(count, 1))
    _ = napi_get_cb_info(env, info, &argc, &argv, nil, nil)
    return argv
}

/// Register one `(napi_env, napi_callback_info) -> napi_value` callback as a named export.
func napiDefine(
    _ env: napi_env?,
    _ exports: napi_value?,
    _ name: String,
    _ cb: @escaping @convention(c) (napi_env?, napi_callback_info?) -> napi_value?
) {
    var fn: napi_value?
    if napi_create_function(env, name, NAPI_AUTO_LENGTH, cb, nil, &fn) == napi_ok {
        _ = napi_set_named_property(env, exports, name, fn)
    }
}

// ── The `data` channel (`fn-entry-spine-k68`) ──────────────────────────────────────────────
// `napi_create_function` takes a `void *data` that `napi_get_cb_info` hands back to the
// callback. Every entry above passes `nil` for it, because each one *is* its own export: an
// `aw_ts_msg_<codes>` entry is named by the very signature it casts, so the callback needs no
// extra context.
//
// The plain-C free-function table (`aw_ts_fn_<symbol>`, ADR-0025's trampoline-elided limit)
// cannot work that way. Its exports are keyed **per symbol** (2192 of them — a C function is
// called by its own address, not multiplexed through `objc_msgSend`), but its *bodies* are
// only distinguishable **per ABI signature** (317 of them). The `data` payload is the join:
// one shared callback per signature, registered 2192 times, each registration carrying the
// descriptor of the symbol it must call. See `fn_resolve.swift`.

/// Register a callback as a named export, carrying a `data` payload the callback reads back
/// through [`napiCallbackArgsData`]. The `data`-carrying sibling of [`napiDefine`] — used only
/// by the free-function table, whose shared per-signature callbacks learn *which* symbol they
/// dispatch from this pointer.
func napiDefineWithData(
    _ env: napi_env?,
    _ exports: napi_value?,
    _ name: String,
    _ cb: @escaping @convention(c) (napi_env?, napi_callback_info?) -> napi_value?,
    _ data: UnsafeMutableRawPointer?
) {
    var fn: napi_value?
    if napi_create_function(env, name, NAPI_AUTO_LENGTH, cb, data, &fn) == napi_ok {
        _ = napi_set_named_property(env, exports, name, fn)
    }
}

/// Read a callback's argument vector **and** its registered `data` payload — the
/// [`napiDefineWithData`] counterpart. `napi_get_cb_info`'s last out-param is the `void *`
/// passed at `napi_create_function` time; [`napiCallbackArgs`] discards it by passing `nil`.
func napiCallbackArgsData(_ env: napi_env?, _ info: napi_callback_info?, _ count: Int)
    -> ([napi_value?], UnsafeMutableRawPointer?)
{
    var argc = size_t(count)
    var argv = [napi_value?](repeating: nil, count: max(count, 1))
    var data: UnsafeMutableRawPointer?
    _ = napi_get_cb_info(env, info, &argc, &argv, nil, &data)
    return (argv, data)
}

/// Throw a JS `Error` from a napi callback. The callback must then return `nil`: N-API's
/// contract is that a callback returning `nil` with a pending exception propagates it into JS.
/// Used by the free-function resolver for a symbol no loaded image exports — a loud failure at
/// the call site, never a null-address call (`fn-entry-spine-k68`).
func napiThrow(_ env: napi_env?, _ message: String) {
    _ = message.withCString { napi_throw_error(env, nil, $0) }
}

// ── Inbound-facing helpers (subclass-inbound-on-main-k37) ──────────────────────────────────
// The inbound trampolines build a JS `InboundCall = {id, selector, args}`, call the runtime's
// `__invokeCallback`, and read back an `InboundResult = {threw, value?}`. Unlike the outbound
// entries these run from an ObjC IMP (no `env` argument) — they use the env captured at
// `installCallbackInvoker` time, legal only on thread 0 (ADR-0059 Mechanics).

/// Read a JS array of strings (each element read via `napiReadString`; non-strings skipped).
/// Used by `defineSubclass` to receive the `"<selector>|<typeEncoding>"` override list.
func napiReadStringArray(_ env: napi_env?, _ value: napi_value?) -> [String] {
    var len: UInt32 = 0
    guard napi_get_array_length(env, value, &len) == napi_ok else { return [] }
    var out: [String] = []
    out.reserveCapacity(Int(len))
    for i in 0..<len {
        var element: napi_value?
        guard napi_get_element(env, value, i, &element) == napi_ok,
            let s = napiReadString(env, element)
        else { continue }
        out.append(s)
    }
    return out
}

/// Build an empty JS object (the `InboundCall` container).
func napiNewObject(_ env: napi_env?) -> napi_value? {
    var obj: napi_value?
    _ = napi_create_object(env, &obj)
    return obj
}

/// Set a named property on a JS object.
func napiSetNamed(_ env: napi_env?, _ obj: napi_value?, _ name: String, _ value: napi_value?) {
    _ = napi_set_named_property(env, obj, name, value)
}

/// Read a named property off a JS object (`nil` on failure) — **clearing any exception the
/// failure left pending**, so the guard means what it reads as: no value, and no side effect.
///
/// A property lookup on a non-object (`undefined.x`, `null.x`) does not merely return a bad status:
/// V8 *throws*, and N-API leaves that exception **pending on the env**. Returning `nil` without
/// clearing it hands the caller an env on which almost every further napi call is undefined
/// behaviour (N-API's own rule) — and the geometry readers below do exactly that, walking on to the
/// next field. So a failed lookup swallows the exception here, at the one site that can see it.
/// That is what makes the readers' documented posture — a missing/non-numeric field is 0, never a
/// crash — true for a *nested* miss (a rect with no `origin`) and not just a flat one.
func napiGetNamed(_ env: napi_env?, _ obj: napi_value?, _ name: String) -> napi_value? {
    var value: napi_value?
    guard napi_get_named_property(env, obj, name, &value) == napi_ok else {
        var pending = false
        if napi_is_exception_pending(env, &pending) == napi_ok, pending {
            var thrown: napi_value?
            _ = napi_get_and_clear_last_exception(env, &thrown)
        }
        return nil
    }
    return value
}

/// Build a JS array of the given length (elements set via `napiSetElement`).
func napiNewArray(_ env: napi_env?, _ length: Int) -> napi_value? {
    var arr: napi_value?
    _ = napi_create_array_with_length(env, size_t(length), &arr)
    return arr
}

/// Set element `index` of a JS array.
func napiSetElement(_ env: napi_env?, _ arr: napi_value?, _ index: Int, _ value: napi_value?) {
    _ = napi_set_element(env, arr, UInt32(index), value)
}

/// Read a JS boolean value (`false` on a non-bool / failed read) — for the `InboundResult.threw` flag.
func napiGetBool(_ env: napi_env?, _ value: napi_value?) -> Bool {
    var out = false
    _ = napi_get_value_bool(env, value, &out)
    return out
}

/// Dereference a `napi_ref` to its JS value (`nil` if cleared) — the stored `__invokeCallback` fn.
func napiRefValue(_ env: napi_env?, _ ref: napi_ref?) -> napi_value? {
    var value: napi_value?
    guard napi_get_reference_value(env, ref, &value) == napi_ok else { return nil }
    return value
}

/// Build one `InboundCall = { id, selector?, args }` JS object (ADR-0059 §1) — the shape the runtime's
/// `__invokeCallback` / `__deliverValueReturning` read. `selectorName == nil` omits the `selector`
/// property (a block invoke — the registered target IS the callable); `argValues` are pre-marshalled
/// napi values. Shared by the on-thread-0 trampolines (`invokeInbound`) and the off-main tsfn bounce
/// (`bounce.swift`), so the two directions build the identical wire object. Must run on thread 0.
func napiBuildInboundCall(
    _ env: napi_env?, _ callbackId: UInt, _ selectorName: String?, _ argValues: [napi_value?]
) -> napi_value? {
    let call = napiNewObject(env)
    napiSetNamed(env, call, "id", napiMakeHandle(env, callbackId))
    if let selectorName { napiSetNamed(env, call, "selector", napiMakeString(env, selectorName)) }
    let args = napiNewArray(env, argValues.count)
    for (index, value) in argValues.enumerated() {
        napiSetElement(env, args, index, value)
    }
    napiSetNamed(env, call, "args", args)
    return call
}

/// Call a JS function with `args` and a `null`/`undefined` receiver, returning its result.
/// On a pending JS exception (the `__invokeCallback` contract says this must not happen, but the
/// boundary is defended anyway — ADR-0059 §7) it is cleared and `nil` is returned so the trampoline
/// falls back to its typed default rather than letting the exception unwind the C ABI.
func napiCallFunction(_ env: napi_env?, _ fn: napi_value?, _ args: [napi_value?]) -> napi_value? {
    var recv: napi_value?
    _ = napi_get_undefined(env, &recv)
    var argv = args
    var result: napi_value?
    let status = napi_call_function(env, recv, fn, size_t(argv.count), &argv, &result)
    if status != napi_ok {
        var pending: napi_value?
        _ = napi_get_and_clear_last_exception(env, &pending)
        return nil
    }
    return result
}

// The outbound dispatch spine of the Swift-native N-API addon (napi-dispatch-spine-k35,
// realising ADR-0054 §1/§2 for the Node TypeScript target). It hosts N-API *and* the
// generated-style `objc_msgSend` dispatch in one Swift `.node` — no napi-rs / Rust.
//
// Each exported entry is a napi callback that (a) reads its `bigint`/number/string args,
// (b) `unsafeBitCast`s `objc_msgSend` to the concrete `@convention(c)` shape for the ABI
// signature (the ADR-0013 mechanism the substrate spike proved first-hand), (c) calls it,
// and (d) marshals the result back to a JS value. This is the inbound-marshalling job
// napi-rs did in the spike, now done Swift-native.
//
// Scope: the fixed `NativeDispatch` primitives + the closed-alphabet `aw_ts_const_<code>`
// constant reads (ADR-0025/0055 §6, constants-k51). The per-signature `aw_ts_msg_*` entries
// (+ the `…_o` +1 siblings, ADR-0057 §4 retain-fold-k48, and the `…_e` error-@catch siblings,
// ADR-0058 error-catch-entries-k49) live in the GENERATED table — Generated/DispatchTable.swift,
// written by `apianyware-generate --target typescript` from the IR
// (outbound-dispatch-table-k58; build order: generate → build.sh) and registered via
// `awRegisterGeneratedDispatch` below. `awMsgSendAddr`/`objcRetain`/`objcRelease` are internal
// (not private) because the generated entries call them.

import Foundation

// ── The ARC-managed ObjC runtime entry points, fetched once by address ────────────────────
// Swift's ObjectiveC overlay marks objc_msgSend / objc_retain / objc_release unavailable
// (ARC "owns" them), so — exactly as the substrate spike's Bridge.swift does — they are
// resolved via dlsym(RTLD_DEFAULT, …) and recast per use. objc_getClass / sel_registerName
// are not ARC-managed and are called directly.

private let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)
/// Internal (not private): the generated per-signature entries (Generated/DispatchTable.swift)
/// cast this per call site, exactly as the hand-written entries here do.
let awMsgSendAddr = dlsym(RTLD_DEFAULT, "objc_msgSend")!
private let retainAddr = dlsym(RTLD_DEFAULT, "objc_retain")!
private let releaseAddr = dlsym(RTLD_DEFAULT, "objc_release")!
private let retainAutoreleaseAddr = dlsym(RTLD_DEFAULT, "objc_retainAutorelease")!
private let poolPushAddr = dlsym(RTLD_DEFAULT, "objc_autoreleasePoolPush")!
private let poolPopAddr = dlsym(RTLD_DEFAULT, "objc_autoreleasePoolPop")!

/// `objc_retain(id)` → the same id, +1. Folded into a +0-returning dispatch entry so the
/// wrapped id arrives at JS already +1 (ADR-0057 §4). Null-safe. Internal: the generated
/// +0 entries fold through this.
@inline(__always) func objcRetain(_ id: UInt) -> UInt {
    if id == 0 { return 0 }
    typealias Fn = @convention(c) (UInt) -> UInt
    return unsafeBitCast(retainAddr, to: Fn.self)(id)
}

/// `objc_retainAutorelease(id)` → the same id, +1 with a **pending autorelease** — the exact
/// `+0`-return convention (ADR-0057 §4, inbound-return arm): the caller gets a reference valid
/// until the pool drains and owns nothing. The ARC runtime's own primitive (`objc_autorelease(
/// objc_retain(x))`), so a returned object is independent of the JS wrapper's `+1` — which is what
/// makes a JS override's `return NSMenu.alloc().init()` safe by construction. Null-safe.
///
/// The pool: on thread 0 AppKit's ambient per-runloop-iteration pool covers it (ADR-0057 §8); a
/// framework thread invoking a value-returning callback off-main already needs one for *any* `+0`
/// return, and GCD/NSThread runloops provide it. Internal — the `retainAutorelease` primitive below.
@inline(__always) func objcRetainAutorelease(_ id: UInt) -> UInt {
    if id == 0 { return 0 }
    typealias Fn = @convention(c) (UInt) -> UInt
    return unsafeBitCast(retainAutoreleaseAddr, to: Fn.self)(id)
}

/// `objc_release(id)` — the runtime's dispose/FR/`+1`-balance release seam (ADR-0057 §4).
@inline(__always) func objcRelease(_ id: UInt) {
    if id == 0 { return }
    typealias Fn = @convention(c) (UInt) -> Void
    unsafeBitCast(releaseAddr, to: Fn.self)(id)
}

// ── Fixed NativeDispatch primitives (dispatch.ts) ─────────────────────────────────────────

/// `getClass(name) → Class handle` (interned by libobjc; classes are permanent, never released).
private func aw_getClass(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    guard let name = napiReadString(env, a[0]), let cls = objc_getClass(name) else {
        return napiMakeHandle(env, 0)
    }
    return napiMakeHandle(env, unsafeBitCast(cls as AnyObject, to: UInt.self))
}

/// `getSelector(name) → SEL handle` (interned by libobjc).
private func aw_getSelector(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    guard let name = napiReadString(env, a[0]) else { return napiMakeHandle(env, 0) }
    return napiMakeHandle(env, unsafeBitCast(sel_registerName(name), to: UInt.self))
}

/// `selectorName(sel) → String` — `sel_getName`, the inverse of `getSelector`. ADR-0055 §3 keeps
/// selectors `string`s at the TS surface, so a `SEL` **return** comes back as its name (the runtime
/// memoizes; selectors are permanent). A nil `SEL` never reaches here — `__selName` maps `0n` to
/// `null` JS-side, because `sel_getName(nil)` is not defined.
private func aw_selectorName(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    let sel = napiReadHandle(env, a[0])
    guard sel != 0, let ptr = UnsafeRawPointer(bitPattern: sel) else { return napiMakeString(env, "") }
    return napiMakeString(env, String(cString: sel_getName(unsafeBitCast(ptr, to: Selector.self))))
}

/// `className(cls) → String` — `class_getName`, the inverse of `getClass`. The key `__classCtor`
/// (classes.ts) resolves a returned `Class` handle through, back to its bound TS constructor. This
/// is the **ObjC runtime** name, which is exactly what the IR keys classes on (CONTEXT.md *ObjC
/// runtime class name (vs Swift-overlay name)*) — so the lookup matches by construction.
private func aw_className(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    let cls = napiReadHandle(env, a[0])
    guard cls != 0, let ptr = UnsafeRawPointer(bitPattern: cls) else { return napiMakeString(env, "") }
    return napiMakeString(env, String(cString: class_getName(unsafeBitCast(ptr, to: AnyClass.self))))
}

/// `classOf(id) → Class handle` — `object_getClass`, the **instance→class** crossing. `getClass` goes
/// name→class and `className` class→name; nothing went from an *object* to its class, so an `id` the IR
/// names no class for (every `id` / `id<P>` return, every inbound object arg on a protocol-qualified
/// slot) could only be wrapped as the root `NSObject` — a wrapper carrying none of the real class's
/// methods (`dynamic-class-wrap-k88`). With this, the runtime resolves the true class through the
/// ADR-0055 §5b ctor registry instead.
///
/// `object_getClass` — not `-class` — deliberately: it is a plain pointer read with no message send, so
/// it works on a class object, on a proxy that would forward `-class` to its target, and during dealloc.
/// Nil-safe (a nil `id` yields the nil `Class`, which `__classCtor` maps back to `null`).
private func aw_classOf(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    let id = napiReadHandle(env, a[0])
    guard id != 0, let ptr = UnsafeRawPointer(bitPattern: id) else { return napiMakeHandle(env, 0) }
    guard let cls = object_getClass(unsafeBitCast(ptr, to: AnyObject.self)) else {
        return napiMakeHandle(env, 0)
    }
    return napiMakeHandle(env, unsafeBitCast(cls as AnyObject, to: UInt.self))
}

/// `superclassOf(cls) → Class handle` — `class_getSuperclass`; `0n` at the root. Walked by the runtime's
/// **nearest bound ancestor** resolution (classes.ts): Cocoa's class clusters mean an `NSString` is really
/// a `__NSCFString` / `NSTaggedPointerString` and an `NSArray` really an `__NSArrayI` — private classes no
/// binding declares — so an object's *own* class is usually not one the emitter emits. The wrap boundary
/// climbs to the nearest ancestor it does (`dynamic-class-wrap-k88`; the gerbil ADR-0020 rule, applied to
/// an instance rather than a type reference).
private func aw_superclassOf(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    let cls = napiReadHandle(env, a[0])
    guard cls != 0, let ptr = UnsafeRawPointer(bitPattern: cls),
        let sup = class_getSuperclass(unsafeBitCast(ptr, to: AnyClass.self))
    else {
        return napiMakeHandle(env, 0)
    }
    return napiMakeHandle(env, unsafeBitCast(sup as AnyObject, to: UInt.self))
}

/// `release(handle)` → `objc_release` (ADR-0057 §4). Called on thread 0 by dispose/FR.
private func aw_release(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    objcRelease(napiReadHandle(env, a[0]))
    return napiUndefined(env)
}

/// `retain(handle) → handle` → `objc_retain` (ADR-0057 §2, the **borrowed** wrap): an INBOUND object
/// arg reaches a JS callback at `+0` — the ObjC caller owns it, JS does not — so `__wrapBorrowed`'s
/// fresh mint takes its own `+1` here, reconstructing ARC's store-time retain that JS cannot insert.
/// The one crossing the outbound `+0` path avoids by folding into its dispatch entry; the inbound
/// trampoline cannot fold, because its ABI signature collapses `id`/`SEL`/`Class` into one pointer
/// code and so does not know which args are objects. Null-safe. Thread 0 (with the rest of the
/// registry/uniquing policy).
private func aw_retain(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    return napiMakeHandle(env, objcRetain(napiReadHandle(env, a[0])))
}

/// `retainAutorelease(handle) → handle` → `objc_retainAutorelease` (ADR-0057 §4, the inbound-return
/// arm): the object a JS callback RETURNS under a `+0`-convention selector. The caller owns nothing
/// and the reference is valid until the pool drains — the real ObjC contract, independent of the JS
/// wrapper's `+1`. A `+1`-convention selector (an overridden `copyWithZone:`/`init`) uses `retain`
/// instead; a `SEL`/`Class` return takes neither. Null-safe.
private func aw_retainAutorelease(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    return napiMakeHandle(env, objcRetainAutorelease(napiReadHandle(env, a[0])))
}

/// `pushAutoreleasePool() → pool handle` (ADR-0057 §8; `withAutoreleasePool`).
private func aw_pushAutoreleasePool(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    typealias Fn = @convention(c) () -> UInt
    return napiMakeHandle(env, unsafeBitCast(poolPushAddr, to: Fn.self)())
}

/// `popAutoreleasePool(handle)` — drains + pops the pool.
private func aw_popAutoreleasePool(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    typealias Fn = @convention(c) (UInt) -> Void
    unsafeBitCast(poolPopAddr, to: Fn.self)(napiReadHandle(env, a[0]))
    return napiUndefined(env)
}

/// `cfstr(str) → +1 owned NSString id` (ADR-0058). Built via `[[NSString alloc]
/// initWithUTF8String:]` — a +1 owned return the runtime wraps with `__wrapOwned`.
private func aw_cfstr(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    guard let s = napiReadString(env, a[0]), let nsstr = objc_getClass("NSString") else {
        return napiMakeHandle(env, 0)
    }
    let cls = unsafeBitCast(nsstr as AnyObject, to: UInt.self)
    typealias Msg0 = @convention(c) (UInt, UInt) -> UInt
    typealias MsgN = @convention(c) (UInt, UInt, UnsafePointer<CChar>) -> UInt
    let allocated = unsafeBitCast(awMsgSendAddr, to: Msg0.self)(
        cls, unsafeBitCast(sel_registerName("alloc"), to: UInt.self))
    let initSel = unsafeBitCast(sel_registerName("initWithUTF8String:"), to: UInt.self)
    let id = s.withCString { unsafeBitCast(awMsgSendAddr, to: MsgN.self)(allocated, initSel, $0) }
    return napiMakeHandle(env, id)
}

/// `allocInit(cls) -> id` — `[[cls alloc] init]`, returning the +1 owned instance (ADR-0059 §3
/// subclass construction). No retain fold: `alloc` already returns +1, and the runtime's wrapper
/// takes that +1 (releasing it on dispose).
private func aw_allocInit(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    let cls = napiReadHandle(env, a[0])
    typealias Fn = @convention(c) (UInt, UInt) -> UInt
    let msg = unsafeBitCast(awMsgSendAddr, to: Fn.self)
    let allocated = msg(cls, unsafeBitCast(sel_registerName("alloc"), to: UInt.self))
    let inited = msg(allocated, unsafeBitCast(sel_registerName("init"), to: UInt.self))
    return napiMakeHandle(env, inited)
}

/// `allocInitWithObject(cls, initSel, arg) -> id` — `[[cls alloc] <initSel>: arg]`, a one-object-arg
/// designated initializer returning the +1 owned instance (e.g. `-initForWritingWithMutableData:`).
/// No retain fold: the initializer already returns +1, taken by the runtime's wrapper (or balanced
/// natively, as in `bindDelegate`). Companion to `allocInit` for inits that take an object argument.
private func aw_allocInitWithObject(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 3)
    typealias Msg1 = @convention(c) (UInt, UInt) -> UInt
    typealias Msg2 = @convention(c) (UInt, UInt, UInt) -> UInt
    let allocated = unsafeBitCast(awMsgSendAddr, to: Msg1.self)(
        napiReadHandle(env, a[0]), unsafeBitCast(sel_registerName("alloc"), to: UInt.self))
    let inited = unsafeBitCast(awMsgSendAddr, to: Msg2.self)(
        allocated, napiReadHandle(env, a[1]), napiReadHandle(env, a[2]))
    return napiMakeHandle(env, inited)
}

// ── Constant-read (`aw_ts_const_<code>`) entries (ADR-0025/0055 §6, constants-k51) ─────────
// A constant global's *value* is a link-time fact (ADR-0025) — no IR literal — so the emitter
// (`emit_constants.rs`) emits a module-load read `__dispatch.aw_ts_const_<code>('NAME')`, content-
// addressed by the constant's **result ABI shape** (`native_dispatch::constant_entry_name`). Each
// entry `dlsym`s the named global and loads its value by that shape. The codes are the closed
// scalar/pointer alphabet (`native_dispatch.rs` `AbiType::code`) — a small fixed set keyed on the
// result shape, NOT the per-symbol *generated* full table (a later emit-typescript concern). Struct
// globals are deferred by the emitter, so no struct const entry is needed.
//
// A pointer result (`P`) forks on ownership, not just shape (`pointer-constant-ownership-k92`):
// `aw_ts_const_P` is the OBJECT arm (an `id`/`Class`/`instancetype` global — folds a `+1` retain,
// the emitter wraps it); `aw_ts_const_P_n` is the OPAQUE-POINTER arm (a raw C pointer / block
// singleton — never retains, the emitter hands it through as a bare `bigint`).
//
// `aw_ts_const_N_a` is a THIRD, independent fork on the same `dlsym`'d address, for an
// **array-typed global** (`unsigned char X[]`/`char X[]`, `array-constant-symbol-value-k109`): the
// symbol's own address IS the array — not a stored pointer/id to load through — so it must never
// go via `aw_ts_const_P`/`_P_n` (which both `.load(as:)` THROUGH the address) or `aw_ts_const_N`
// (which also loads through, for a *stored* `char * const`). Retaining a non-object dereferences a
// nonexistent `isa` — measured crash: `CoreSpotlightVersionString`, a `unsigned char[]` array
// symbol whose loaded "pointer value" used to be (mis)read as ASCII banner text loaded THROUGH.

/// Resolve a named global's **storage address** for a constant read: `dlsym(RTLD_DEFAULT, name)`
/// returns `&global`, which the per-code entry loads by the constant's result ABI shape. `nil` when
/// the arg is not a string or the symbol is absent (e.g. an AppKit global headless) — the entry then
/// yields its zero value (the graceful-degradation posture `aw_getClass` uses). Args are `(name)`.
private func constSymbol(_ env: napi_env?, _ info: napi_callback_info?) -> UnsafeMutableRawPointer? {
    let a = napiCallbackArgs(env, info, 1)
    guard let name = napiReadString(env, a[0]) else { return nil }
    return dlsym(RTLD_DEFAULT, name)
}

/// `aw_ts_const_P(name) -> id handle` — a **pointer-valued object global** (`NSString * const
/// NSFontAttributeName`). The global holds a **borrowed +0** id; `dlsym` returns `&global`, so load
/// the id and **fold a `+1`** (`objcRetain`) so it reaches JS at the uniform +1 the runtime's
/// `__wrapRetained` takes (ADR-0057 §4) — exactly like the +0 object-return dispatch entries. A
/// missing symbol → 0 → `__wrapRetained` → `null` (`objcRetain` is null-safe: 0 folds to 0).
private func aw_ts_const_P(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let sym = constSymbol(env, info) else { return napiMakeHandle(env, 0) }
    return napiMakeHandle(env, objcRetain(sym.load(as: UInt.self)))
}

/// `aw_ts_const_P_n(name) -> handle` — a **pointer-shaped global that is not an ObjC object**
/// (a raw C pointer / opaque handle / block singleton — the emitter routes here exactly when the
/// IR's `is_object_type` is false, `pointer-constant-ownership-k92`). `dlsym` returns `&global`;
/// load the pointer value and hand it back **unretained** — the emitter never wraps it (it is a
/// bare `bigint`), so there is no `+1` to fold, and `objc_retain` on a non-object dereferences a
/// nonexistent `isa` (measured crash: `CoreSpotlightVersionString`). A missing symbol → 0.
private func aw_ts_const_P_n(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let sym = constSymbol(env, info) else { return napiMakeHandle(env, 0) }
    return napiMakeHandle(env, sym.load(as: UInt.self))
}

/// `aw_ts_const_N(name) -> string` — a **C-string global** (`const char * const`). `dlsym` returns
/// `&global`; load the `char*` and marshal to a JS string. A missing symbol / null pointer → "".
private func aw_ts_const_N(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let sym = constSymbol(env, info), let c = sym.load(as: UnsafePointer<CChar>?.self) else {
        return napiMakeString(env, "")
    }
    return napiMakeString(env, String(cString: c))
}

/// `aw_ts_const_N_a(name) -> string` — an **array-typed global whose own symbol address IS the
/// array** (`unsigned char X[]`/`char X[]`, a byte/char element — `array-constant-symbol-value-k109`),
/// read as a NUL-terminated banner string straight off the symbol's own address. Distinct from
/// `aw_ts_const_N` (a *stored* `char * const` global, which loads THROUGH its address to reach the
/// pointer value): `dlsym` already returns the array's own base address, so there is nothing to load
/// — the address itself IS the `char*` to marshal. A missing symbol → "".
private func aw_ts_const_N_a(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let sym = constSymbol(env, info) else { return napiMakeString(env, "") }
    return napiMakeString(env, String(cString: sym.assumingMemoryBound(to: CChar.self)))
}

// The scalar-global reads: `dlsym` → load by the code's Swift width → marshal. Every signed/small
// width fits `Int64` (→ `napiMakeInt64`); `Q` (UInt64) routes through the loss-checked double path
// (`napiMakeUInt64`); `f`/`d` are floats (`napiMakeDouble`); `b` (a C `BOOL`, one byte) is `!= 0`. A
// missing symbol yields the shape's zero.
private func aw_ts_const_b(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let s = constSymbol(env, info) else { return napiMakeBool(env, false) }
    return napiMakeBool(env, s.load(as: UInt8.self) != 0)
}
private func aw_ts_const_c(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let s = constSymbol(env, info) else { return napiMakeInt64(env, 0) }
    return napiMakeInt64(env, Int64(s.load(as: Int8.self)))
}
private func aw_ts_const_C(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let s = constSymbol(env, info) else { return napiMakeInt64(env, 0) }
    return napiMakeInt64(env, Int64(s.load(as: UInt8.self)))
}
private func aw_ts_const_s(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let s = constSymbol(env, info) else { return napiMakeInt64(env, 0) }
    return napiMakeInt64(env, Int64(s.load(as: Int16.self)))
}
private func aw_ts_const_S(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let s = constSymbol(env, info) else { return napiMakeInt64(env, 0) }
    return napiMakeInt64(env, Int64(s.load(as: UInt16.self)))
}
private func aw_ts_const_i(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let s = constSymbol(env, info) else { return napiMakeInt64(env, 0) }
    return napiMakeInt64(env, Int64(s.load(as: Int32.self)))
}
private func aw_ts_const_I(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let s = constSymbol(env, info) else { return napiMakeInt64(env, 0) }
    return napiMakeInt64(env, Int64(s.load(as: UInt32.self)))
}
private func aw_ts_const_q(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let s = constSymbol(env, info) else { return napiMakeInt64(env, 0) }
    return napiMakeInt64(env, s.load(as: Int64.self))
}
private func aw_ts_const_Q(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let s = constSymbol(env, info) else { return napiMakeUInt64(env, 0) }
    return napiMakeUInt64(env, s.load(as: UInt64.self))
}
private func aw_ts_const_f(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let s = constSymbol(env, info) else { return napiMakeDouble(env, 0) }
    return napiMakeDouble(env, Double(s.load(as: Float.self)))
}
private func aw_ts_const_d(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let s = constSymbol(env, info) else { return napiMakeDouble(env, 0) }
    return napiMakeDouble(env, s.load(as: Double.self))
}

// ── Module registration — the sole N-API entry Node calls at dlopen (NAPI_MODULE) ─────────

@_cdecl("napi_register_module_v1")
public func napi_register_module_v1(_ env: napi_env?, _ exports: napi_value?) -> napi_value? {
    // Fixed NativeDispatch primitives (dispatch.ts).
    napiDefine(env, exports, "getClass", aw_getClass)
    napiDefine(env, exports, "getSelector", aw_getSelector)
    napiDefine(env, exports, "selectorName", aw_selectorName)
    napiDefine(env, exports, "className", aw_className)
    napiDefine(env, exports, "classOf", aw_classOf)
    napiDefine(env, exports, "superclassOf", aw_superclassOf)
    napiDefine(env, exports, "release", aw_release)
    napiDefine(env, exports, "retain", aw_retain)
    napiDefine(env, exports, "retainAutorelease", aw_retainAutorelease)
    napiDefine(env, exports, "pushAutoreleasePool", aw_pushAutoreleasePool)
    napiDefine(env, exports, "popAutoreleasePool", aw_popAutoreleasePool)
    napiDefine(env, exports, "cfstr", aw_cfstr)
    // The per-signature aw_ts_msg_* table (+ `_o`/`_e` siblings) is GENERATED —
    // Generated/DispatchTable.swift, written by `apianyware-generate --target typescript`
    // (outbound-dispatch-table-k58) and registered wholesale here.
    awRegisterGeneratedDispatch(env, exports)
    // Constant-read (`aw_ts_const_<code>`) entries (ADR-0025/0055 §6) — the closed alphabet.
    napiDefine(env, exports, "aw_ts_const_P", aw_ts_const_P)
    napiDefine(env, exports, "aw_ts_const_P_n", aw_ts_const_P_n)
    napiDefine(env, exports, "aw_ts_const_N", aw_ts_const_N)
    napiDefine(env, exports, "aw_ts_const_N_a", aw_ts_const_N_a)
    napiDefine(env, exports, "aw_ts_const_b", aw_ts_const_b)
    napiDefine(env, exports, "aw_ts_const_c", aw_ts_const_c)
    napiDefine(env, exports, "aw_ts_const_C", aw_ts_const_C)
    napiDefine(env, exports, "aw_ts_const_s", aw_ts_const_s)
    napiDefine(env, exports, "aw_ts_const_S", aw_ts_const_S)
    napiDefine(env, exports, "aw_ts_const_i", aw_ts_const_i)
    napiDefine(env, exports, "aw_ts_const_I", aw_ts_const_I)
    napiDefine(env, exports, "aw_ts_const_q", aw_ts_const_q)
    napiDefine(env, exports, "aw_ts_const_Q", aw_ts_const_Q)
    napiDefine(env, exports, "aw_ts_const_f", aw_ts_const_f)
    napiDefine(env, exports, "aw_ts_const_d", aw_ts_const_d)
    // The per-symbol Swift-native `s:` residual trampoline table (`aw_ts_swift_*`, ADR-0061) is
    // GENERATED — Generated/TrampolineTable.swift, written by
    // `apianyware-generate --target typescript` (swift-residual-cli-pass-k65). One call-by-name
    // napi callback per residual function; registered wholesale here.
    awRegisterGeneratedTrampolines(env, exports)
    // The object-return marshalling + shape probe (object-bridged-returns-k55, ADR-0061 §3) —
    // fixed machinery, not a per-symbol entry, so it stays hand-written (trampolines.swift).
    napiDefine(env, exports, "aw_ts_swift_probe_objectReturn", aw_ts_swift_probe_objectReturn)
    // The plain-C free-function table (`aw_ts_fn_<symbol>`, ADR-0025's trampoline-elided limit) is
    // GENERATED — Generated/FunctionTable.swift, written by `apianyware-generate --target
    // typescript` (fn-table-codegen-k69): one per-symbol export over a shared per-signature body,
    // joined by the descriptor in `napi_create_function`'s `data`. Its *resolution* machinery is
    // fixed and hand-written (fn_resolve.swift) — a lazy `dlsym`→`dlopen`→`dlsym` that throws
    // rather than call a null address, and the +0 object return's retain fold.
    awRegisterGeneratedFunctions(env, exports)
    // Subclass construction (ADR-0059 §3) + the inbound trampoline primitives.
    napiDefine(env, exports, "allocInit", aw_allocInit)
    napiDefine(env, exports, "allocInitWithObject", aw_allocInitWithObject)
    awRegisterInbound(env, exports)
    // The per-signature aw_ts_super_* $super table (ADR-0059 §4) is GENERATED alongside the
    // inbound trampolines — Generated/InboundTable.swift (super-send-table-k63). napi callbacks,
    // not IMPs, so they register here like the outbound table rather than entering the IMP map.
    awRegisterGeneratedSuperSends(env, exports)
    // The off-main tsfn bg→main bounce + postCallbackCompletion (ADR-0056 §3, tsfn-bounce-k43).
    awRegisterBounce(env, exports)
    return exports
}

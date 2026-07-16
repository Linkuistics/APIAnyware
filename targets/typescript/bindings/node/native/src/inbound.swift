// The INBOUND direction — ObjC→JS — of the Swift-native N-API addon
// (subclass-inbound-on-main-k37, realising the on-thread-0 slice of ADR-0059
// §1/§3(subclass)/§5(on-thread-0)/§7). The inbound dual of dispatch.swift's outbound spine.
//
// A JS class `extends`ing a bound ObjC class synthesizes ONE ObjC subclass per JS class
// (`objc_allocateClassPair` + `class_addMethod` + a back-ref ivar); each overridden selector is
// installed as a generated typed `@_cdecl`-style inbound trampoline (one per distinct ABI
// signature, content-addressed by ObjC type encoding — the inbound dual of ADR-0054's outbound
// `aw_ts_msg_*`). When the ObjC runtime dispatches an overridden selector to such an instance, the
// trampoline reads the instance's back-ref → `CallbackId`, marshals the C-ABI args to JS values,
// and calls the runtime's `__invokeCallback` SYNCHRONOUSLY on thread 0, returning the JS-computed
// value (or a typed nil/0 default on the JS-threw / stale-id path — the ADR-0058 native-`@catch`
// mirror; no exception is allowed to unwind the C ABI into the framework).
//
// Scope (grown k37→k44): the full ON-THREAD-0 inbound surface — subclass (k37), delegate
// (`respondsToSelector:` snapshot + associated-object keep-alive, k38), `NS_NOESCAPE` blocks (k39),
// and `$super` / overridable `dealloc` / added methods (k40) — PLUS the OFF-MAIN delivery of the
// shared subclass/delegate core (k44): a trampoline firing off thread 0 routes through the
// `tsfn-bounce-k43` mechanism (`awBounceVoid` / `awBounceValue`, bounce.swift) instead of re-entering
// JS off-main. Still deferred to later `k36` siblings: the escaping heap-block+tsfn holder (the
// off-main half of blocks) and the off-main synchronous `dealloc` bounce.
//
// The env-less-IMP crux: an inbound trampoline is an ObjC method IMP invoked by the ObjC runtime,
// so — unlike the outbound napi callbacks — it receives no `napi_env`. It reaches JS through the
// `napi_env` + `napi_ref`-to-`__invokeCallback` captured at `installCallbackInvoker` time, legal
// only on thread 0 (ADR-0059 Mechanics). Every raw ObjC id stays a `UInt` and is only ever touched
// through `@convention(c)` calls (never bridged to a Swift `AnyObject`, which would insert an ARC
// release and over-release the live receiver) — the same raw-pointer discipline the outbound spine
// applies to `objc_msgSend`.

import Foundation

// ── Captured JS delivery handle (installCallbackInvoker; thread 0) ─────────────────────────
// Plain globals in the C sense — this addon does not use Swift concurrency (matching the
// outbound spine's dlsym'd-address idiom); all inbound work is on thread 0. `gEnv`/`gInvokeRef`
// are module-internal (not `private`) so the off-main tsfn bounce (`bounce.swift`) reaches the
// same captured thread-0 env + `__invokeCallback` ref for its void-path delivery on thread 0.
var gEnv: napi_env?
var gInvokeRef: napi_ref?
/// The captured `napi_ref` to the runtime's `__deliverDealloc` (installDeallocDeliverer; thread 0) —
/// the dedicated dealloc-delivery entry the `dealloc` IMP calls (ADR-0059 §4). Separate from
/// `gInvokeRef` because dealloc is not an ordinary callback: it releases the registry keep-alive and
/// decides whether the JS override chained `$super.dealloc()` (so the native IMP need not).
private var gDeallocRef: napi_ref?

/// The back-ref ivar every synthesized subclass / forwarder carries: a pointer-width slot holding
/// the instance's JS `CallbackId` (ADR-0059 §3 — instance state stays JS-side; one ObjC ivar).
private let BACKREF_IVAR = "__aw_cbid"

/// The delegate-forwarder responds-snapshot ivar: a pointer-width bitset recording which protocol
/// methods the JS delegate implements, taken at set-time (ADR-0059 §3 — exact `@optional` fidelity).
/// Only forwarder classes carry it; subclasses (k37) do not add it, and never read it.
private let RESPONDS_IVAR = "__aw_responds"

// ── ARC-free libobjc entry points (dlsym, like the spine's objc_msgSend) ────────────────────
// `object_getClass` / `objc_msgSend` / `objc_release` / `objc_setAssociatedObject` import into
// Swift taking ARC-managed `Any?`/`AnyObject` params, which would bridge a raw id and over-release
// the live receiver. Resolve them by address and call them `@convention(c)` on raw `UInt`s instead —
// no ARC touches the instance (the same raw-pointer discipline the outbound spine applies).
private let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)
private let objectGetClassAddr = dlsym(RTLD_DEFAULT, "object_getClass")!
private let classGetSuperclassAddr = dlsym(RTLD_DEFAULT, "class_getSuperclass")!
private let msgSendAddr = dlsym(RTLD_DEFAULT, "objc_msgSend")!
private let releaseAddr = dlsym(RTLD_DEFAULT, "objc_release")!
private let setAssociatedAddr = dlsym(RTLD_DEFAULT, "objc_setAssociatedObject")!
/// `objc_msgSendSuper(struct objc_super *, SEL, …)` — the super-send analogue of `objc_msgSend`
/// (ADR-0059 §4, `$super`). Like `objc_msgSend`, Swift's ObjectiveC overlay marks it unavailable, so
/// resolve it by address and recast per signature. Method lookup begins at `objc_super.super_class`
/// (the immediate base) and proceeds up — so it skips the synthesized subclass's own override, the
/// exact anti-recursion the ADR-0034 `call-next-method` trap needs. Internal (not private): the
/// generated per-signature `aw_ts_super_*` entries (Generated/InboundTable.swift, super-send-table-k63)
/// recast this per call site, exactly as the `superSendVoid` machinery below does.
let awMsgSendSuperAddr = dlsym(RTLD_DEFAULT, "objc_msgSendSuper")!

/// `OBJC_ASSOCIATION_RETAIN` (atomic strong) — the delegate keep-alive policy (ADR-0059 §6). The
/// `<objc/runtime.h>` value is `01401` **octal**; write it as hex here — Swift does NOT read a leading
/// `0` as octal (a decimal `01401` would be a malformed policy → a corrupt/non-retaining association).
private let OBJC_ASSOCIATION_RETAIN: UInt = 0x301

@inline(__always) private func rawObjectGetClass(_ id: UInt) -> UInt {
    typealias Fn = @convention(c) (UInt) -> UInt
    return unsafeBitCast(objectGetClassAddr, to: Fn.self)(id)
}

/// `class_getSuperclass(cls)` — the immediate superclass handle (`0` if none). Called `@convention(c)`
/// on raw `UInt`s (like `rawObjectGetClass`), NOT via the Swift overlay's `AnyClass`-typed import: an
/// `AnyClass` metatype round-tripped through `unsafeBitCast(_, to: UInt.self)` does NOT yield the raw
/// class pointer (the correct idiom needs an `as AnyObject` coercion), so the raw-call form is both
/// safer and consistent with the rest of this file. Used by the `dealloc` IMP to compute the
/// search-start class for its native `[super dealloc]` chain.
@inline(__always) private func rawClassGetSuperclass(_ cls: UInt) -> UInt {
    guard cls != 0 else { return 0 }
    typealias Fn = @convention(c) (UInt) -> UInt
    return unsafeBitCast(classGetSuperclassAddr, to: Fn.self)(cls)
}

/// `class_respondsToSelector(cls, sel)` — the `respondsToSelector:` fallback for a non-protocol
/// selector (inherited NSObject methods). Takes a class + SEL (both non-instance handles), so a
/// direct call is ARC-benign.
@inline(__always) private func rawClassRespondsToSelector(_ cls: UInt, _ sel: UInt) -> Bool {
    guard cls != 0 else { return false }
    return class_respondsToSelector(
        unsafeBitCast(cls, to: AnyClass.self), unsafeBitCast(sel, to: Selector.self))
}

/// Byte offset of ivar `name` within instances of the class `clsHandle`. Class objects are never
/// deallocated, so bridging the class handle to `AnyClass` here is ARC-benign (a class release is a
/// runtime no-op) — unlike bridging an instance id.
private func ivarOffset(ofClass clsHandle: UInt, named name: String) -> Int? {
    guard clsHandle != 0 else { return nil }
    let cls: AnyClass = unsafeBitCast(clsHandle, to: AnyClass.self)
    guard let ivar = class_getInstanceVariable(cls, name) else { return nil }
    return ivar_getOffset(ivar)
}

/// Read a pointer-width ivar off an instance by name (`0` if the class has no such ivar).
private func readUIntIvar(_ selfId: UInt, _ name: String) -> UInt {
    guard let objPtr = UnsafeMutableRawPointer(bitPattern: selfId),
        let offset = ivarOffset(ofClass: rawObjectGetClass(selfId), named: name)
    else { return 0 }
    return objPtr.load(fromByteOffset: offset, as: UInt.self)
}

/// Write a pointer-width ivar on an instance by name (no-op if the class has no such ivar).
private func writeUIntIvar(_ selfId: UInt, _ name: String, _ value: UInt) {
    guard let objPtr = UnsafeMutableRawPointer(bitPattern: selfId),
        let offset = ivarOffset(ofClass: rawObjectGetClass(selfId), named: name)
    else { return }
    objPtr.storeBytes(of: value, toByteOffset: offset, as: UInt.self)
}

@inline(__always) private func readBackRef(_ selfId: UInt) -> UInt {
    readUIntIvar(selfId, BACKREF_IVAR)
}

/// The selector name off `_cmd` — pure `sel_getName` (no napi, no ARC, legal on ANY thread), so it
/// serves both the on-thread-0 `callInvoker` and the off-main bounce gather (ADR-0059 Mechanics).
@inline(__always) private func selectorName(_ cmd: UInt) -> String {
    String(cString: sel_getName(unsafeBitCast(cmd, to: Selector.self)))
}

// ── The shared inbound delivery core (on-thread-0 fast path + off-main bounce) ───────────────

/// Build `InboundCall = { id, selector?, args }` from a callback id, an optional selector name, and
/// pre-marshalled napi arg values, and invoke the runtime's `__invokeCallback`, returning the result
/// napi_value (an `InboundResult`) — or `nil` on a hard fault (no invoker, or a JS throw / napi fault
/// `napiCallFunction` already cleared). `selectorName == nil` is a **block** invoke: no `selector`
/// property is set, so the runtime reads `call.selector === undefined` and treats the registered
/// target as the callable itself (blocks have no selector); a non-nil name is a delegate/subclass
/// dispatch. The caller reads `.value` into its typed return **while `env`'s handle scope is open**,
/// then closes it. Contains every failure (ADR-0059 §7); nothing unwinds the C ABI.
private func invokeInbound(
    _ env: napi_env, _ callbackId: UInt, _ selectorName: String?, _ argValues: [napi_value?]
) -> napi_value? {
    guard let ref = gInvokeRef, let invoke = napiRefValue(env, ref) else { return nil }
    let call = napiBuildInboundCall(env, callbackId, selectorName, argValues)
    return napiCallFunction(env, invoke, [call])
}

// ── The generic inbound delivery core (on-thread-0 fast path + off-main bounce) ──────────────
// The subclass/delegate delivery every GENERATED trampoline (Generated/InboundTable.swift,
// inbound-imp-table-k61) routes through — the subclass/delegate analogue of the block cores below,
// generalised over `[BounceArg]` so scalar/double args cross typed (the per-return hand-written
// `deliver*` quartet this replaces carried id handles only). On thread 0: marshal the raw args via
// `napiFromBounceArgs`, invoke the runtime's `__invokeCallback` synchronously, read the typed return.
// Off thread 0 (a GCD worker, a framework completion thread): NEVER re-enter JS — only the back-ref
// ivar read + raw-arg gather happen here; the registry read + JS invocation + napi all happen on
// thread 0 inside the tsfn `call_js` (bounce.swift). Void is fire-and-forget (`awBounceVoid`); a
// value return blocks the bg thread on the completion semaphore (`awBounceValue`) and the generated
// trampoline reinterprets the returned `UInt64` slot per its C-ABI return kind (a double travels as
// its bit pattern). The deadlock caveat rides along (a value-returning bounce while thread 0 is
// *synchronously* blocked deadlocks — ADR-0056 §3; void is immune). Contained on any failure
// (missing invoker, stale back-ref, JS throw, napi fault → the typed default 0/nil/NO, ADR-0059 §7);
// nothing unwinds the C ABI.

/// Deliver a **value-returning** inbound call, returning the raw `UInt64` slot the caller
/// reinterprets per `kind`. A per-call handle scope isolates the marshalling napi_values (the
/// trampoline enters from arbitrary ObjC frames).
func deliverInboundValue(
    _ selfId: UInt, _ cmd: UInt, _ args: [BounceArg], _ kind: BounceReturnKind
) -> UInt64 {
    if pthread_main_np() == 0 {  // off-main → bounce; block on the completion semaphore
        return awBounceValue(readBackRef(selfId), selectorName(cmd), args, kind).slot
    }
    guard let env = gEnv else { return 0 }
    var scope: napi_handle_scope?
    guard napi_open_handle_scope(env, &scope) == napi_ok else { return 0 }
    defer { napi_close_handle_scope(env, scope) }
    guard
        let result = invokeInbound(
            env, readBackRef(selfId), selectorName(cmd), napiFromBounceArgs(env, args))
    else { return 0 }
    // On threw, the native side alone knows the ABI return type → the typed default.
    if napiGetBool(env, napiGetNamed(env, result, "threw")) { return 0 }
    let value = napiGetNamed(env, result, "value")
    switch kind {
    case .void: return 0
    case .int64: return UInt64(bitPattern: napiReadInt64(env, value))
    case .handle: return UInt64(napiReadHandle(env, value))
    case .bool: return napiGetBool(env, value) ? 1 : 0
    case .uint64: return napiReadUInt64(env, value)
    case .double: return napiReadDouble(env, value).bitPattern
    }
}

/// Deliver a **void** inbound call (a setter override, an added target-action, a fire-and-forget
/// delegate method). The JS return is ignored; a JS throw is already contained + reported inside
/// `__invokeCallback` (§7) — nothing here can unwind the C ABI.
func deliverInboundVoid(_ selfId: UInt, _ cmd: UInt, _ args: [BounceArg]) {
    if pthread_main_np() == 0 {  // off-main → fire-and-forget bounce (the bg thread does not wait)
        awBounceVoid(readBackRef(selfId), selectorName(cmd), args)
        return
    }
    guard let env = gEnv else { return }
    var scope: napi_handle_scope?
    guard napi_open_handle_scope(env, &scope) == napi_ok else { return }
    defer { napi_close_handle_scope(env, scope) }
    _ = invokeInbound(env, readBackRef(selfId), selectorName(cmd), napiFromBounceArgs(env, args))
}

// ── The typed inbound trampolines (one per distinct ABI signature; ADR-0059 §1) ─────────────
// GENERATED at corpus scale since inbound-imp-table-k61: Generated/InboundTable.swift renders one
// non-capturing `@convention(c)` closure per distinct inbound signature over the
// subclass-overridable + delegate/protocol frontiers (each reads `_cmd` for the selector, so one
// trampoline serves every override of its signature shape — content-addressed by ObjC type
// encoding), plus the `awGeneratedInboundIMP(forEncoding:)` map consulted here. The hand-written
// five (`q@:@`, `q@:`, `@@:@@`, `v@:@`, `c@:@`) were retired when the generated table covered them.

/// Map an ObjC type encoding to its installable trampoline IMP (`nil` if unsupported — the caller
/// skips the override; a never-seen signature is the §1 NSInvocation escape hatch, out of scope here).
private func trampoline(forEncoding encoding: String) -> IMP? {
    return awGeneratedInboundIMP(forEncoding: encoding)
}

// ── The delegate forwarder: per-protocol class + the respondsToSelector: snapshot (ADR-0059 §3) ──
// A delegate wraps its JS object in an instance of a per-protocol forwarding class (base NSObject),
// memoized by the runtime. Its IMPs are the §1 typed trampolines above; its `respondsToSelector:` is
// the shared IMP below, answering from a per-instance snapshot bitset (the RESPONDS_IVAR) so
// `@optional` fidelity is exact — the load-bearing correctness point (NativeScript's shared-class
// delegates reported YES for every optional → the invisible-rows bug).

/// Per-forwarder-class selector→bit-index map: lets the shared `respondsToSelector:` IMP find a
/// queried protocol method's bit in the instance snapshot. Keyed by the class handle (==
/// `object_getClass(instance)`), populated at `defineForwarder` time. Thread-0 only (ADR-0059 Mechanics).
private var gForwarderBits: [UInt: [UInt: Int]] = [:]

/// The shared `respondsToSelector:` IMP for every forwarding class: for a protocol method, answer
/// from the instance's set-time snapshot bitset (never a live JS consult); for any other selector,
/// defer to the class's real method table (inherited NSObject methods). Reads only the instance's
/// class + ivar — never bridges the id to an AnyObject.
private let respondsTo_imp: @convention(c) (UInt, UInt, UInt) -> Bool = { selfId, _cmd, querySel in
    let cls = rawObjectGetClass(selfId)
    if let index = gForwarderBits[cls]?[querySel] {
        return (readUIntIvar(selfId, RESPONDS_IVAR) >> UInt(index)) & 1 != 0
    }
    return rawClassRespondsToSelector(cls, querySel)
}

// ── $super / dealloc / added methods (super-dealloc-on-main-k40; ADR-0059 §4, on-thread-0) ──
// The dynamic-subclass surface's super-send, overridable dealloc, and added ObjC-reachable methods.
// `$super` dispatches via `objc_msgSendSuper` to the immediate base (skipping the override — the
// anti-recursion the ADR-0034 `call-next-method` trap needs); `dealloc` runs the JS override (if any),
// releases the instance's `callbacks`-registry keep-alive (closing the k37/k38 loop), and chains
// `[super dealloc]`; added methods reuse the §1 trampolines (`v@:@` target-action / `c@:@` etc.).

/// `struct objc_super { id receiver; Class super_class; }` as a Swift tuple — two contiguous
/// pointer-width fields (guaranteed C-compatible layout), passed by address to `objc_msgSendSuper`.
private typealias ObjcSuper = (receiver: UInt, superClass: UInt)

/// `objc_msgSendSuper(&{recv, superCls}, sel) -> void` — a no-arg super-send. **Fixed machinery**, not
/// a per-signature entry: the shared `dealloc` IMP chains `[super dealloc]` through it natively when a
/// synthesized class has no JS `dealloc` override (below), with no napi env in hand. The per-signature
/// `$super` surface JS calls is the GENERATED `aw_ts_super_*` table (Generated/InboundTable.swift).
private func superSendVoid(_ recv: UInt, _ superCls: UInt, _ sel: UInt) {
    var sup: ObjcSuper = (recv, superCls)
    typealias Fn = @convention(c) (UnsafeMutableRawPointer, UInt) -> Void
    withUnsafeMutablePointer(to: &sup) {
        unsafeBitCast(awMsgSendSuperAddr, to: Fn.self)(UnsafeMutableRawPointer($0), sel)
    }
}

/// Deliver a `dealloc` to the runtime's `__deliverDealloc(cbid)` and read back whether a JS `dealloc`
/// override existed (→ the JS side already chained `$super.dealloc()`, so the native IMP must NOT).
/// `false` on any fault (no deliverer / napi fault) — the IMP then chains `[super dealloc]` itself, so
/// the object is never leaked. Contained; nothing unwinds the C ABI. Runs the JS override + drops the
/// registry keep-alive on thread 0. Module-internal (not `private`): the off-main synchronous dealloc
/// bounce in bounce.swift routes here too — the on-thread-0 IMP calls it directly, the off-main IMP calls
/// it inside the bounce `call_js`, so both share one thread-0 dealloc-delivery seam.
func deliverDealloc(_ cbid: UInt) -> Bool {
    guard let env = gEnv, let ref = gDeallocRef, let fn = napiRefValue(env, ref) else { return false }
    var scope: napi_handle_scope?
    guard napi_open_handle_scope(env, &scope) == napi_ok else { return false }
    defer { napi_close_handle_scope(env, scope) }
    guard let result = napiCallFunction(env, fn, [napiMakeHandle(env, cbid)]) else { return false }
    return napiGetBool(env, result)
}

/// The shared `-dealloc` IMP installed on every synthesized subclass / forwarder (ADR-0059 §4). Resolve
/// the back-ref → `CallbackId`, then run the JS `dealloc` override + drop the registry keep-alive **on
/// thread 0** (closing the k37/k38 loop): directly via `deliverDealloc` when this dealloc is already on
/// thread 0, or via a **synchronous bounce** (`awBounceDealloc`, blocking the deallocating thread) when
/// the framework dropped the last ref off thread 0 (a superview released on a bg/GCD queue). NEVER
/// *async*-bounced — an async dealloc would let ObjC `-dealloc` free the object BEFORE the JS override
/// runs → UAF of the JS back-ref (ADR-0059 §4). Both return `hadOverride`; then — only if there was NO
/// JS override — chain `[super dealloc]` natively on the deallocating thread (an override is obligated to
/// chain `this.$super.dealloc()` itself, matching ObjC; forgetting it leaks, as in ObjC). `super_class`
/// is `class_getSuperclass(object_getClass(self))` — the immediate base, so the search skips this very
/// IMP (no recursion). Off thread 0 the IMP touches NO napi / NO registry — the deliver + release happen
/// on thread 0 inside the bounce; the synchronous-bounce deadlock caveat rides along (a dealloc bounce
/// while thread 0 is synchronously blocked deadlocks — ADR-0056 §3 / ADR-0059 §5).
private let dealloc_imp: @convention(c) (UInt, UInt) -> Void = { selfId, cmd in
    let cbid = readBackRef(selfId)
    // On thread 0 deliver directly; off thread 0 SYNCHRONOUSLY bounce (block the deallocating thread until
    // thread 0 has run the override + registry release). Both return `hadOverride`.
    let hadOverride = pthread_main_np() != 0 ? deliverDealloc(cbid) : awBounceDealloc(cbid)
    if !hadOverride {
        superSendVoid(selfId, rawClassGetSuperclass(rawObjectGetClass(selfId)), cmd)
    }
}

/// Install the shared `-dealloc` IMP (encoding `v@:`) on a synthesized class before registration. Every
/// bound subclass / forwarder needs it: the registry keep-alive (ADR-0059 §6) must be dropped when the
/// ObjC instance dies, and `[super dealloc]` chained — the k37/k38 loop close.
private func installDeallocIMP(_ cls: AnyClass) {
    _ = "v@:".withCString { types in
        class_addMethod(cls, sel_registerName("dealloc"), unsafeBitCast(dealloc_imp, to: IMP.self), types)
    }
}

// ── The inbound N-API primitives (registered into the module by awRegisterInbound) ──────────

/// `installCallbackInvoker(fn)` — capture the thread-0 `napi_env` and a strong `napi_ref` to the
/// runtime's `__invokeCallback`, so env-less inbound IMPs can reach JS (ADR-0059 §5). Idempotent:
/// a prior ref is released and replaced.
private func aw_installCallbackInvoker(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    gEnv = env
    if let old = gInvokeRef {
        _ = napi_delete_reference(env, old)
        gInvokeRef = nil
    }
    var ref: napi_ref?
    _ = napi_create_reference(env, a[0], 1, &ref)
    gInvokeRef = ref
    return napiUndefined(env)
}

/// `installDeallocDeliverer(fn)` — capture the thread-0 `napi_env` and a strong `napi_ref` to the
/// runtime's `__deliverDealloc`, so the env-less `dealloc` IMP can deliver on thread 0 (ADR-0059 §4).
/// Installed alongside `installCallbackInvoker` at first synthesis. Idempotent (a prior ref is replaced).
private func aw_installDeallocDeliverer(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    gEnv = env
    if let old = gDeallocRef {
        _ = napi_delete_reference(env, old)
        gDeallocRef = nil
    }
    var ref: napi_ref?
    _ = napi_create_reference(env, a[0], 1, &ref)
    gDeallocRef = ref
    return napiUndefined(env)
}

/// `defineSubclass(baseClass, name, overrides) -> Class handle` — synthesize one ObjC subclass of
/// `baseClass` named `name`, add the back-ref ivar, and install a typed trampoline IMP for each
/// `"<selector>|<typeEncoding>"` override (ADR-0059 §3). Called once per JS class (memoized by the
/// runtime). Returns `0` on allocation failure (e.g. a duplicate name).
private func aw_defineSubclass(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 3)
    let baseHandle = napiReadHandle(env, a[0])
    guard baseHandle != 0, let name = napiReadString(env, a[1]) else { return napiMakeHandle(env, 0) }
    let base: AnyClass = unsafeBitCast(baseHandle, to: AnyClass.self)

    guard let cls = name.withCString({ objc_allocateClassPair(base, $0, 0) }) else {
        return napiMakeHandle(env, 0)
    }
    _ = BACKREF_IVAR.withCString { ivarName in
        // A pointer-width, pointer-aligned slot (alignment log2(8) = 3), encoded `Q` (unsigned).
        class_addIvar(cls, ivarName, MemoryLayout<UInt>.size, 3, "Q")
    }
    for entry in napiReadStringArray(env, a[2]) {
        let parts = entry.split(separator: "|", maxSplits: 1)
        guard parts.count == 2, let imp = trampoline(forEncoding: String(parts[1])) else { continue }
        let selector = sel_registerName(String(parts[0]))
        _ = String(parts[1]).withCString { types in class_addMethod(cls, selector, imp, types) }
    }
    installDeallocIMP(cls)  // the shared dealloc IMP (registry-release + [super dealloc]); ADR-0059 §4.
    objc_registerClassPair(cls)
    return napiMakeHandle(env, unsafeBitCast(cls as AnyObject, to: UInt.self))
}

/// `setBackRef(instance, callbackId)` — stamp the JS `CallbackId` into the synthesized subclass /
/// forwarder's back-ref ivar so the trampoline can resolve the instance's JS side (ADR-0059 §3).
private func aw_setBackRef(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 2)
    writeUIntIvar(napiReadHandle(env, a[0]), BACKREF_IVAR, napiReadHandle(env, a[1]))
    return napiUndefined(env)
}

/// `defineForwarder(protocol, name, overrides) -> Class handle` — synthesize ONE per-protocol
/// forwarding class (base `NSObject`) named `name` (memoized by the runtime, ADR-0059 §3, delegate
/// surface): add the back-ref + responds-snapshot ivars, install a typed trampoline IMP per
/// `"<selector>|<typeEncoding>"` override (recording each method's bit index for the snapshot), install
/// the shared per-instance `respondsToSelector:` override, and — best-effort — conform to the ObjC
/// `protocol` if one is registered. Returns `0` on allocation failure (e.g. a duplicate name).
private func aw_defineForwarder(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 3)
    let protocolName = napiReadString(env, a[0])
    guard let name = napiReadString(env, a[1]), let nsobject = objc_getClass("NSObject") else {
        return napiMakeHandle(env, 0)
    }
    let base: AnyClass = unsafeBitCast(nsobject as AnyObject, to: AnyClass.self)
    guard let cls = name.withCString({ objc_allocateClassPair(base, $0, 0) }) else {
        return napiMakeHandle(env, 0)
    }
    // Two pointer-width, pointer-aligned (alignment log2(8) = 3) ivars, encoded `Q` (unsigned): the
    // JS CallbackId back-ref and the respondsToSelector: snapshot bitset.
    _ = BACKREF_IVAR.withCString { class_addIvar(cls, $0, MemoryLayout<UInt>.size, 3, "Q") }
    _ = RESPONDS_IVAR.withCString { class_addIvar(cls, $0, MemoryLayout<UInt>.size, 3, "Q") }
    // One typed trampoline IMP per protocol method; a method's position IS its snapshot bit index
    // (matching the runtime's `__respondsBits`), so use the true enumerated index even across a
    // skipped unsupported encoding. Only installed methods enter the bit map — so a non-installed
    // method reports `respondsToSelector:` NO (safe; the framework never sends an un-IMP'd selector).
    var bitMap: [UInt: Int] = [:]
    for (index, entry) in napiReadStringArray(env, a[2]).enumerated() {
        let parts = entry.split(separator: "|", maxSplits: 1)
        guard parts.count == 2, let imp = trampoline(forEncoding: String(parts[1])) else { continue }
        let selector = sel_registerName(String(parts[0]))
        _ = String(parts[1]).withCString { types in class_addMethod(cls, selector, imp, types) }
        bitMap[unsafeBitCast(selector, to: UInt.self)] = index
    }
    // The per-instance-snapshot respondsToSelector: override (shared IMP; encoding `c@::` — BOOL ret,
    // self, _cmd, SEL arg). Installed before registration.
    _ = "c@::".withCString {
        class_addMethod(cls, sel_registerName("respondsToSelector:"),
            unsafeBitCast(respondsTo_imp, to: IMP.self), $0)
    }
    // Best-effort formal conformance so `conformsToProtocol:` holds for a registered protocol (a bare
    // test protocol has no ObjC `Protocol` → skipped). Added before registration, per the runtime rules.
    if let protocolName, let proto = objc_getProtocol(protocolName) {
        _ = class_addProtocol(cls, proto)
    }
    installDeallocIMP(cls)  // the shared dealloc IMP (registry-release + [super dealloc]); ADR-0059 §4.
    objc_registerClassPair(cls)
    let clsHandle = unsafeBitCast(cls as AnyObject, to: UInt.self)
    gForwarderBits[clsHandle] = bitMap
    return napiMakeHandle(env, clsHandle)
}

/// `setRespondsBits(instance, bits)` — stamp the set-time `respondsToSelector:` snapshot (bit `i` set
/// iff the JS delegate implements protocol method `i`) into the forwarder's responds ivar (ADR-0059 §3).
private func aw_setRespondsBits(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 2)
    writeUIntIvar(napiReadHandle(env, a[0]), RESPONDS_IVAR, napiReadHandle(env, a[1]))
    return napiUndefined(env)
}

// ── The delegate keep-alive (ADR-0059 §6) ────────────────────────────────────────────────────────
// Per-property-key stable association-key pointers (interned; never freed — delegate property keys
// are few and permanent). `objc_setAssociatedObject` needs a stable `const void*` key per property.
private var gAssocKeys: [String: UnsafeMutableRawPointer] = [:]
private func assocKey(_ name: String) -> UnsafeMutableRawPointer {
    if let existing = gAssocKeys[name] { return existing }
    let p = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1)
    gAssocKeys[name] = p
    return p
}

/// `associate(owner, key, obj)` — the delegate keep-alive primitive (ADR-0059 §6), on thread 0:
/// `objc_setAssociatedObject(owner, assocKey(key), obj, OBJC_ASSOCIATION_RETAIN)`. The association
/// retains `obj` and lives exactly as long as `owner`; re-associating the same key **releases the
/// object previously held there**, which is what makes re-setting a delegate slot leak-free. `obj == 0`
/// clears the key.
///
/// A bare primitive, not the k38 `bindDelegate` compound op (send + associate + balance) it replaces:
/// that op only fitted a *setter*, and ADR-0055 §4b binds `id<P>` in **every** param position — an
/// `init…` argument, a plain method argument, a static's argument (`emitted-delegate-spec-k84`). The
/// ordering of the association against the ObjC send is now `delegate.ts`'s, where the rest of the
/// keep-alive policy already lives (the ADR-0059 policy-TS / mechanism-Swift seam).
private func aw_associate(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 3)
    let owner = napiReadHandle(env, a[0])
    let key = napiReadString(env, a[1]) ?? ""
    let obj = napiReadHandle(env, a[2])
    if owner != 0 {
        typealias Assoc = @convention(c) (UInt, UnsafeRawPointer, UInt, UInt) -> Void
        unsafeBitCast(setAssociatedAddr, to: Assoc.self)(
            owner, assocKey(key), obj, OBJC_ASSOCIATION_RETAIN)
    }
    return napiUndefined(env)
}

// ── Blocks: JS function → ObjC NS_NOESCAPE block (ADR-0059 §2, on-thread-0 fast path) ──────────────
// A block's invoke is the inbound dual of the subclass/delegate IMPs — but a block has NO selector and
// NO back-ref ivar: the `CallbackId` is *captured* directly in the `@convention(block)` Swift closure,
// and the runtime's `__invokeCallback` reads `call.selector === undefined` → the registered target IS
// the callable. For `NS_NOESCAPE` the block fires synchronously on thread 0 during the enclosing
// outbound call; `makeBlock` `_Block_copy`s it to the heap so it survives the make→dispatch JS
// round-trip, and `releaseBlock` drops that +1 right after (no tsfn, no persistence — the baseline
// fast path). A `@convention(block)` Swift closure IS a real ObjC block; `unsafeBitCast` to a raw
// pointer reads its block-pointer (single-word representation), `_Block_copy` gives a heap block
// independent of the Swift local's ARC lifetime.
//
// GENERATED at corpus scale since block-maker-tables-k62: Generated/InboundTable.swift renders one
// noescape + escaping maker pair per distinct block-invoke signature over ALL class + protocol
// methods' block-typed params (the future frontier — block-carrying methods are still emitter-
// deferred), keyed by the SAME signature-code alphabet as the trampoline identifiers (the hand-written
// `PQb_v`/`_v`/`P_B` codes canonicalised to `PQP_v`/`0_v`/`P_b`; a `BOOL* stop` out-pointer crosses as
// a raw handle `P` — a typed stop-writer is a later nicety). The hand-written makers were retired when
// the generated switches covered them; the delivery cores below stay hand-written.

/// `makeBlock(callbackId, signature) → block-pointer handle` — build a real ObjC block (ADR-0059 §2)
/// whose invoke is the typed inbound trampoline for `signature`, capturing `callbackId`. Returns `0`
/// for an un-installed signature (the runtime turns that into a visible error — the inbound analogue of
/// a missing `aw_ts_msg_*` entry). Thread-0 only.
private func aw_makeBlock(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 2)
    let cbid = napiReadHandle(env, a[0])
    guard let signature = napiReadString(env, a[1]) else { return napiMakeHandle(env, 0) }
    return napiMakeHandle(env, awGeneratedMakeBlock(cbid, signature))
}

/// `releaseBlock(handle)` — `_Block_release` the heap block `makeBlock` returned (ADR-0059 §2),
/// balancing its `_Block_copy` +1. Null-safe.
private func aw_releaseBlock(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    if let ptr = UnsafeRawPointer(bitPattern: napiReadHandle(env, a[0])) { _Block_release(ptr) }
    return napiUndefined(env)
}

// ── Escaping blocks: JS function → heap ObjC block held PAST the call (ADR-0059 §2 default path) ────
// (block-escaping-off-main-k45.) The off-main dual of the NS_NOESCAPE fast path above. An **escaping**
// block — a stored completion handler, a notification block, a stored observer — OUTLIVES the enclosing
// outbound call and may fire OFF thread 0, so the JS function must be PINNED (not held only for the call)
// and every invoke delivered on thread 0. Never re-enter JS off-main.
//
// The one genuine design choice (resolved here; ADR-0059 §2 reconciled in place): the JS function is held
// by the RUNTIME REGISTRY (a monotonic `CallbackId`, exactly like the noescape path), NOT a per-block
// delivery/holder tsfn. So (a) delivery reuses `invokeInbound` (on thread 0) and the SINGLETON
// `awBounce*` (off-main) — full k43/k44 reuse — and (b) containment/reporting flow through the
// registry-keyed `__invokeCallback` uniformly (a block's `call.selector === undefined`, its target IS the
// callable). The tsfn's ADR-0059 §2 role is thereby REFINED: the *singleton* bounce (the same ADR-0056 §3
// primitive that delivers) also provides the off-main TEARDOWN — a `release`-bounce
// (`awBounceReleaseCallback`) that drops the registry entry on thread 0. Rationale: because containment
// lives in the registry-keyed `__invokeCallback`, the fn must be in the registry regardless — so a
// per-block tsfn could only *route teardown*, a job the singleton already does without a per-block
// `uv_async_t` (the ADR §2 handle-exhaustion concern). Every externally-observable property the ADR
// requires holds: pinned while live, released on teardown, teardown legal off-main, JS-ref drop on thread 0.
//
// The teardown TRIGGER is the block's own memory management: the heap block's `@convention(block)` closure
// captures a Swift `EscapingBlockHolder` (strong). A `@convention(block)` Swift closure capturing a class
// instance gets copy/dispose helpers that `swift_retain`/`swift_release` the capture, so when the framework
// does the last `_Block_release` — on ANY thread — the dispose helper releases the holder; its `deinit`
// fires on that thread and routes the registry-drop to thread 0. This is exactly WHY escaping needs the
// tsfn seam and noescape does not: noescape teardown is synchronous on thread 0 in the runtime `finally`;
// escaping teardown is asynchronous, possibly off-main, and only the tsfn can legally route the JS-ref
// drop from any thread to thread 0 (a raw `napi_ref`/registry mutation off thread 0 crashes).

/// Captured (strong) by an escaping block's invoke closure; its `deinit` is the block-torn-down signal.
/// Holds one `CallbackId` (the registry keep-alive the block pins). `deinit` may run on any thread (the
/// framework can release a stored block off-main), so it touches NO napi/registry directly — it routes the
/// drop to thread 0 via the singleton release-bounce (ADR-0059 §2 / ADR-0057 release-on-thread-0).
/// Module-internal: the generated escaping makers (Generated/InboundTable.swift) capture it.
final class EscapingBlockHolder {
    let cbid: UInt
    init(_ cbid: UInt) { self.cbid = cbid }
    deinit { awBounceReleaseCallback(cbid) }
}

// Block delivery core — no `selfId`/`_cmd`/back-ref/selector (a block's registered target IS the callable,
// so the selector is `nil`). On thread 0 invoke directly via `invokeInbound` (the fast path — do NOT bounce
// to self, the value-returning shape needs the result NOW). Off thread 0 route through the singleton bounce
// (void: fire-and-forget; value: block on the completion semaphore). Args arrive pre-shaped as raw
// `[BounceArg]` so the off-main path hands them straight to `awBounce*` and the thread-0 path marshals them
// via `napiFromBounceArgs`. Contained on any failure (ADR-0059 §7); nothing unwinds the C ABI.
// Module-internal: every generated block maker (noescape AND escaping) delivers through these two — the
// block analogue of deliverInboundValue/Void, the same policy split (the core owns thread/containment).

/// Deliver a **void** block invoke (fire-and-forget). A JS throw is contained + reported inside
/// `__invokeCallback` (on thread 0 or via the bounce) — nothing here unwinds the C ABI.
func deliverBlockVoid(_ cbid: UInt, _ args: [BounceArg]) {
    if pthread_main_np() == 0 {  // off-main → fire-and-forget bounce (the bg thread does not wait)
        awBounceVoid(cbid, nil, args)
        return
    }
    guard let env = gEnv else { return }
    var scope: napi_handle_scope?
    guard napi_open_handle_scope(env, &scope) == napi_ok else { return }
    defer { napi_close_handle_scope(env, scope) }
    _ = invokeInbound(env, cbid, nil, napiFromBounceArgs(env, args))
}

/// Deliver a **value-returning** block invoke, returning the raw `UInt64` slot for the caller to
/// reinterpret per `kind` (the rare value-returning shape — a `BOOL`/`NSInteger`/id-returning block).
/// Off-main round-trips through the completion semaphore; on thread 0 reads the JS return directly.
/// Contained to the typed default `0` on any failure (missing env, stale id, JS throw — always-post, §7).
func deliverBlockValue(_ cbid: UInt, _ args: [BounceArg], _ kind: BounceReturnKind) -> UInt64 {
    if pthread_main_np() == 0 {  // off-main → bounce; block on the completion semaphore for the return
        return awBounceValue(cbid, nil, args, kind).slot
    }
    guard let env = gEnv else { return 0 }
    var scope: napi_handle_scope?
    guard napi_open_handle_scope(env, &scope) == napi_ok else { return 0 }
    defer { napi_close_handle_scope(env, scope) }
    guard let result = invokeInbound(env, cbid, nil, napiFromBounceArgs(env, args)) else { return 0 }
    if napiGetBool(env, napiGetNamed(env, result, "threw")) { return 0 }
    let value = napiGetNamed(env, result, "value")
    switch kind {
    case .void: return 0
    case .int64: return UInt64(bitPattern: napiReadInt64(env, value))
    case .handle: return UInt64(napiReadHandle(env, value))
    case .bool: return napiGetBool(env, value) ? 1 : 0
    case .uint64: return napiReadUInt64(env, value)
    case .double: return napiReadDouble(env, value).bitPattern
    }
}

// The per-signature escaping-block makers are GENERATED (Generated/InboundTable.swift, block-maker-
// tables-k62). Each builds a `@convention(block)` Swift closure capturing the `holder` (strong, so the
// block's dispose fires `holder.deinit` on the last `_Block_release`) whose body marshals its typed ABI
// args to `[BounceArg]` and delivers via the block core, then `_Block_copy`s it to the heap (the block
// outlives this frame). The returned heap block carries the sole `+1` the runtime holds.

/// `makeEscapingBlock(callbackId, signature) → block-pointer handle` — build a real ESCAPING ObjC block
/// (ADR-0059 §2 default path) whose invoke is the typed inbound trampoline for `signature`, pinning the JS
/// function via the registry (the runtime registered it) and routing its teardown to thread 0 via the
/// captured holder's `deinit` → release-bounce. Returns `0` for an un-installed signature — and NO holder
/// is created on that path (the generated switch mints it per case), so no spurious release-bounce fires
/// (the runtime drops the just-minted registry entry on the `0n` error path). Thread-0 only.
private func aw_makeEscapingBlock(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 2)
    let cbid = napiReadHandle(env, a[0])
    guard let signature = napiReadString(env, a[1]) else { return napiMakeHandle(env, 0) }
    return napiMakeHandle(env, awGeneratedMakeEscapingBlock(cbid, signature))
}

// The per-signature `aw_ts_super_*` super-send entries (the $super analogue of aw_ts_msg_*; §4) are
// GENERATED — Generated/InboundTable.swift, super-send-table-k63. Args are (recvHandle,
// superClassHandle, selHandle, …visibleParams); the emitted `this.$super` accessor passes the bound
// parent's `__cls` as `superClass`, so dispatch begins there (skipping the override). They are napi
// callbacks, registered wholesale by `awRegisterGeneratedSuperSends` from `napi_register_module_v1` —
// content-addressed by `InboundSig::code_string`, the same alphabet that names the IMP trampolines,
// and carrying the outbound retain-fold (`…_o` = a +1 return, no fold — ADR-0057 §4).

// ── First-hand off-main exercise (test-only): drive real inbound trampolines from a GCD bg thread ──
// The real-trampoline analogue of bounce.swift's `aw_test_bounce` (off-main-delivery-k44). Proves the
// off-main branch of the shared delivery core first-hand under the k42 embedder harness (the pump must
// run so thread 0 services the tsfn): originate on a genuine GCD background thread and `objc_msgSend` a
// synthesized subclass's overridden value-returning + void selectors — each typed trampoline detects
// off-main and bounces to thread 0 instead of re-entering JS off-main. NOT a production entry: the real
// trampolines already branch on `pthread_main_np()`; this just supplies the genuine bg origin the
// headless tests (all on thread 0) cannot. Records: the sequence genuinely originated off-main; a
// value-returning override round-tripped its JS return through the completion semaphore; a throwing
// value-returning override still unblocked the bg thread with the typed default `0` (always-post,
// ADR-0059 §7); a void override's `objc_msgSend` returned. Each callback's thread-0 landing is asserted
// JS-side via `isMainThread()` — the strongest evidence JS never ran off-main.

private struct OffMainProbe {
    var originOffMain = false        // the bg thread confirmed it was NOT the main thread
    var valueReturned: Int64 = 0     // the `q@:@` value-returning override's JS return, read on the bg thread
    var boolReturned = false         // the `c@:@` BOOL override's JS return (a second value-returning kind)
    var throwReturned: Int64 = -1    // the throwing override's return — must be the typed default 0
    var throwUnblocked = false       // the bg thread got past the throwing value bounce (never hung)
    var voidSent = false             // the void override's objc_msgSend returned on the bg thread
}
private var gOffMainProbe = OffMainProbe()

/// `aw_test_off_main_delivery(instanceId, valueSel, boolSel, throwSel, voidSel, argId, notifyId)` — run
/// the whole off-main inbound sequence off a real GCD background thread and report via a final void
/// bounce. Returns immediately (thread 0 stays free to PUMP — the value-returning path needs it). The bg
/// thread: (1) `objc_msgSend` the `q@:@` value-returning override `valueSel` → expects the JS return
/// through the semaphore (exercises `deliverInt64`); (2) `objc_msgSend` the `c@:@` BOOL override `boolSel`
/// → a second value-returning kind through a distinct deliver fn (`deliverBool` + the `.bool` slot
/// reinterpret); (3) `objc_msgSend` the throwing override `throwSel` (`q@:@`) whose JS throws → the
/// always-post discipline unblocks it with the typed default `0`; (4) `objc_msgSend` the void override
/// `voidSel` (`v@:@`) → a fire-and-forget bounce; (5) a void bounce to `notifyId` (delivered on thread 0,
/// FIFO after the void override) so JS reads the probe. Every `objc_msgSend` recasts the shared
/// `msgSendAddr` per signature (the outbound spine's idiom) on raw `UInt`s — no ARC touches the receiver.
private func aw_test_off_main_delivery(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 7)
    let instanceId = napiReadHandle(env, a[0])
    let valueSel = napiReadHandle(env, a[1])
    let boolSel = napiReadHandle(env, a[2])
    let throwSel = napiReadHandle(env, a[3])
    let voidSel = napiReadHandle(env, a[4])
    let argId = napiReadHandle(env, a[5])
    let notifyId = napiReadHandle(env, a[6])
    gOffMainProbe = OffMainProbe()
    DispatchQueue.global().async {
        gOffMainProbe.originOffMain = pthread_main_np() == 0
        typealias MsgQ = @convention(c) (UInt, UInt, UInt) -> Int64
        typealias MsgB = @convention(c) (UInt, UInt, UInt) -> Bool  // `c@:@` — matches trampoline_B_at
        typealias MsgV = @convention(c) (UInt, UInt, UInt) -> Void
        let sendQ = unsafeBitCast(msgSendAddr, to: MsgQ.self)
        let sendB = unsafeBitCast(msgSendAddr, to: MsgB.self)
        let sendV = unsafeBitCast(msgSendAddr, to: MsgV.self)
        // (1) q@:@ value-returning override → the trampoline bounces; the JS return round-trips.
        gOffMainProbe.valueReturned = sendQ(instanceId, valueSel, argId)
        // (2) c@:@ BOOL override → a second value-returning kind (deliverBool + the .bool reinterpret).
        gOffMainProbe.boolReturned = sendB(instanceId, boolSel, argId)
        // (3) throwing override → the always-post discipline unblocks us with the typed default 0.
        gOffMainProbe.throwReturned = sendQ(instanceId, throwSel, argId)
        gOffMainProbe.throwUnblocked = true
        // (4) void override → fire-and-forget bounce (JS records its thread-0 landing).
        sendV(instanceId, voidSel, argId)
        gOffMainProbe.voidSent = true
        // (5) notify on thread 0 so JS reads the probe (FIFO after the void override's bounce).
        awBounceVoid(notifyId, nil, [])
    }
    return napiUndefined(env)
}

/// `aw_test_off_main_delivery_result() -> { originOffMain, valueReturned, boolReturned, throwReturned,
/// throwUnblocked, voidSent }` — read the probe the bg sequence filled in (called by notify on thread 0).
private func aw_test_off_main_delivery_result(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let obj = napiNewObject(env)
    napiSetNamed(env, obj, "originOffMain", napiMakeBool(env, gOffMainProbe.originOffMain))
    napiSetNamed(env, obj, "valueReturned", napiMakeInt64(env, gOffMainProbe.valueReturned))
    napiSetNamed(env, obj, "boolReturned", napiMakeBool(env, gOffMainProbe.boolReturned))
    napiSetNamed(env, obj, "throwReturned", napiMakeInt64(env, gOffMainProbe.throwReturned))
    napiSetNamed(env, obj, "throwUnblocked", napiMakeBool(env, gOffMainProbe.throwUnblocked))
    napiSetNamed(env, obj, "voidSent", napiMakeBool(env, gOffMainProbe.voidSent))
    return obj
}

// ── First-hand escaping-block exercise (test-only): store, invoke off-main, tear down off-main ──────
// The escaping analogue of `aw_test_off_main_delivery` (block-escaping-off-main-k45). Proves the escaping
// surface first-hand under the k42 embedder harness (the pump must run so thread 0 services the tsfn): the
// runtime made two real escaping blocks (a void `_v` and a value-returning `P_B`) and handed this driver
// their sole `+1` (ownership transferred — JS does NOT release them). The driver, on a genuine GCD bg
// thread: (1) confirms it is off-main; (2) invokes each stored block via the raw Block ABI invoke funcptr
// (offset 16 — ARC-free, exactly how the ObjC runtime invokes a block), so each block's typed invoke
// detects off-main and bounces to thread 0 instead of re-entering JS off-main — the void fires-and-forgets,
// the `P_B` round-trips its JS return through the completion semaphore; (3) does the LAST `_Block_release`
// OFF-MAIN (the framework dropping the stored block), so each holder's `deinit` fires off-main and
// release-bounces the registry drop to thread 0; (4) notifies via a void bounce so JS reads the probe and
// asserts both registry entries were dropped. Every callback's thread-0 landing is asserted JS-side via
// `isMainThread()` — the strongest evidence JS never ran off-main. NOT a production entry.

private struct EscapingProbe {
    var originOffMain = false   // the bg thread confirmed it was NOT the main thread
    var voidReturned = false    // the void `_v` block's invoke returned on the bg thread (delivery reached it)
    var valueReturned = false   // the `P_B` block's round-tripped JS return, read on the bg thread
    var throwInvoked = false    // the throwing `_v` block's invoke returned on the bg thread (contained, §7)
}
private var gEscapingProbe = EscapingProbe()

/// The Block ABI invoke funcptr of a heap block — `*(void (**)(void *, …))(block + 16)` (isa 8 + flags 4 +
/// reserved 4). The ARC-free way to invoke a block from raw pointers, matching this file's discipline.
@inline(__always) private func blockInvoke(_ block: UnsafeRawPointer) -> UnsafeRawPointer {
    return block.load(fromByteOffset: 16, as: UnsafeRawPointer.self)
}

/// `aw_test_escaping_block_delivery(voidBlock, valueBlock, throwBlock, argId, notifyId)` — drive the whole
/// escaping sequence off a real GCD background thread and report via a final void bounce. Returns
/// immediately (thread 0 stays free to PUMP — the value-returning path needs it). Takes ownership of the
/// three blocks' `+1` (the bg thread does the last release). Every block invoke recasts the block's own
/// invoke funcptr per signature on raw pointers — no ARC touches the block.
private func aw_test_escaping_block_delivery(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 5)
    let voidBlock = napiReadHandle(env, a[0])
    let valueBlock = napiReadHandle(env, a[1])
    let throwBlock = napiReadHandle(env, a[2])
    let argId = napiReadHandle(env, a[3])
    let notifyId = napiReadHandle(env, a[4])
    gEscapingProbe = EscapingProbe()
    DispatchQueue.global().async {
        gEscapingProbe.originOffMain = pthread_main_np() == 0
        typealias VoidInvoke = @convention(c) (UnsafeRawPointer) -> Void
        // (1) void `_v` escaping block → off-main invoke bounces to thread 0 (fire-and-forget).
        if let vp = UnsafeRawPointer(bitPattern: voidBlock) {
            unsafeBitCast(blockInvoke(vp), to: VoidInvoke.self)(vp)
            gEscapingProbe.voidReturned = true
        }
        // (2) value-returning `P_B` escaping block → off-main invoke round-trips the JS return (semaphore).
        if let vp = UnsafeRawPointer(bitPattern: valueBlock) {
            typealias BoolInvoke = @convention(c) (UnsafeRawPointer, UInt) -> Bool
            gEscapingProbe.valueReturned = unsafeBitCast(blockInvoke(vp), to: BoolInvoke.self)(vp, argId)
        }
        // (3) throwing `_v` escaping block → off-main fire-and-forget bounce; the JS throw is contained +
        // reported on thread 0 inside `__invokeCallback` (ADR-0059 §7). The bg thread never sees it and the
        // invoke returns cleanly — no JS exception unwinds the C ABI through the block invoke.
        if let vp = UnsafeRawPointer(bitPattern: throwBlock) {
            unsafeBitCast(blockInvoke(vp), to: VoidInvoke.self)(vp)
            gEscapingProbe.throwInvoked = true
        }
        // (4) the framework drops the stored blocks OFF-MAIN (the last +1) → each holder `deinit` fires
        // off-main and release-bounces the registry drop to thread 0 (ADR-0059 §2 / ADR-0057).
        if let vp = UnsafeRawPointer(bitPattern: voidBlock) { _Block_release(vp) }
        if let vp = UnsafeRawPointer(bitPattern: valueBlock) { _Block_release(vp) }
        if let vp = UnsafeRawPointer(bitPattern: throwBlock) { _Block_release(vp) }
        // (5) notify on thread 0 (FIFO after the release-bounces) so JS reads the probe + asserts the drops.
        awBounceVoid(notifyId, nil, [])
    }
    return napiUndefined(env)
}

/// `aw_test_escaping_block_delivery_result() -> { originOffMain, voidReturned, valueReturned, throwInvoked }`
/// — read the probe the bg escaping sequence filled in (called by the notify callback on thread 0).
private func aw_test_escaping_block_delivery_result(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let obj = napiNewObject(env)
    napiSetNamed(env, obj, "originOffMain", napiMakeBool(env, gEscapingProbe.originOffMain))
    napiSetNamed(env, obj, "voidReturned", napiMakeBool(env, gEscapingProbe.voidReturned))
    napiSetNamed(env, obj, "valueReturned", napiMakeBool(env, gEscapingProbe.valueReturned))
    napiSetNamed(env, obj, "throwInvoked", napiMakeBool(env, gEscapingProbe.throwInvoked))
    return obj
}

// ── First-hand off-main dealloc exercise (test-only): drop the last ref off-main, dealloc on thread 0 ──
// The dealloc analogue of `aw_test_off_main_delivery` / `aw_test_escaping_block_delivery`
// (dealloc-off-main-k46). Proves the off-main SYNCHRONOUS dealloc bounce first-hand under the k42 embedder
// harness (the pump must run so thread 0 services the synchronous bounce while the deallocating thread
// blocks): the runtime made three synthesized-subclass instances (each +1 owned, its `callbacks`-registry
// entry pinned) and handed this driver their sole ref. The driver, on a genuine GCD background thread: (1)
// confirms it is off-main; (2) does the LAST `objc_release` of each — refcount 0 → `-dealloc` fires
// OFF-MAIN → the shared `dealloc_imp` detects off-main and `awBounceDealloc`s, blocking the bg thread until
// thread 0 has run the JS override + dropped the registry keep-alive, then chaining `[super dealloc]` per
// `hadOverride`; (3) records each release returned (the bg thread never hung — the always-post discipline).
// Three shapes: an override that chains `[super dealloc]` on thread 0 (`hadOverride` true), a NO-override
// instance (`hadOverride` false → the IMP chains `[super dealloc]` on the bg thread), and a THROWING
// override (contained + reported on thread 0, still unblocks + still drops the registry). Each override's
// thread-0 landing is asserted JS-side via `isMainThread()` — the strongest evidence the JS `dealloc` never
// ran off-main. NOT a production entry (the real `dealloc_imp` already branches on `pthread_main_np()`; this
// just supplies the genuine off-main last-release the headless tests, all on thread 0, cannot).

private struct DeallocOffMainProbe {
    var originOffMain = false      // the bg thread confirmed it was NOT the main thread
    var overrideReleased = false   // the override instance's last release returned (the bounce unblocked the bg thread)
    var plainReleased = false      // the no-override instance's last release returned (native chains super off-main)
    var throwReleased = false      // the throwing-override instance's last release returned (always-post unblocked)
}
private var gDeallocOffMainProbe = DeallocOffMainProbe()

/// `aw_test_dealloc_off_main(overrideInst, plainInst, throwInst, notifyId)` — drop the last ref of each
/// synthesized instance off a real GCD bg thread (triggering an off-main `-dealloc` → synchronous bounce)
/// and report via a final void bounce. Returns immediately (thread 0 stays free to PUMP — the synchronous
/// dealloc bounce needs it). Takes ownership of each instance's sole `+1`; each `objc_release` recasts the
/// shared `releaseAddr` on a raw `UInt` (the outbound spine's idiom) — no ARC touches the receiver.
private func aw_test_dealloc_off_main(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 4)
    let overrideInst = napiReadHandle(env, a[0])
    let plainInst = napiReadHandle(env, a[1])
    let throwInst = napiReadHandle(env, a[2])
    let notifyId = napiReadHandle(env, a[3])
    gDeallocOffMainProbe = DeallocOffMainProbe()
    DispatchQueue.global().async {
        gDeallocOffMainProbe.originOffMain = pthread_main_np() == 0
        typealias Rel = @convention(c) (UInt) -> Void
        let release = unsafeBitCast(releaseAddr, to: Rel.self)
        // (1) override instance: last ref → -dealloc off-main → bounce → the JS override runs on thread 0 and
        // chains [super dealloc] (hadOverride=true); the bg thread blocks in awBounceDealloc until it returns.
        release(overrideInst)
        gDeallocOffMainProbe.overrideReleased = true
        // (2) no-override instance: last ref → -dealloc off-main → bounce (hadOverride=false) → the IMP chains
        // [super dealloc] on THIS (the deallocating) thread; the registry drops on thread 0 inside the bounce.
        release(plainInst)
        gDeallocOffMainProbe.plainReleased = true
        // (3) throwing override: last ref → -dealloc off-main → bounce; the JS override throws (contained +
        // reported on thread 0, ADR-0059 §7) but still reports hadOverride=true and still drops the registry —
        // the always-post discipline unblocks the bg thread (the object leaks, as in ObjC, if super is unchained).
        release(throwInst)
        gDeallocOffMainProbe.throwReleased = true
        // (4) notify on thread 0 (FIFO after the dealloc bounces' registry drops) so JS reads the probe.
        awBounceVoid(notifyId, nil, [])
    }
    return napiUndefined(env)
}

/// `aw_test_dealloc_off_main_result() -> { originOffMain, overrideReleased, plainReleased, throwReleased }`
/// — read the probe the bg dealloc sequence filled in (called by the notify callback on thread 0).
private func aw_test_dealloc_off_main_result(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let obj = napiNewObject(env)
    napiSetNamed(env, obj, "originOffMain", napiMakeBool(env, gDeallocOffMainProbe.originOffMain))
    napiSetNamed(env, obj, "overrideReleased", napiMakeBool(env, gDeallocOffMainProbe.overrideReleased))
    napiSetNamed(env, obj, "plainReleased", napiMakeBool(env, gDeallocOffMainProbe.plainReleased))
    napiSetNamed(env, obj, "throwReleased", napiMakeBool(env, gDeallocOffMainProbe.throwReleased))
    return obj
}

/// Register the inbound primitives on the module `exports` (called from `napi_register_module_v1`).
func awRegisterInbound(_ env: napi_env?, _ exports: napi_value?) {
    napiDefine(env, exports, "installCallbackInvoker", aw_installCallbackInvoker)
    napiDefine(env, exports, "installDeallocDeliverer", aw_installDeallocDeliverer)
    napiDefine(env, exports, "defineSubclass", aw_defineSubclass)
    napiDefine(env, exports, "setBackRef", aw_setBackRef)
    napiDefine(env, exports, "defineForwarder", aw_defineForwarder)
    napiDefine(env, exports, "setRespondsBits", aw_setRespondsBits)
    napiDefine(env, exports, "associate", aw_associate)
    napiDefine(env, exports, "makeBlock", aw_makeBlock)
    napiDefine(env, exports, "releaseBlock", aw_releaseBlock)
    napiDefine(env, exports, "makeEscapingBlock", aw_makeEscapingBlock)
    napiDefine(env, exports, "aw_test_off_main_delivery", aw_test_off_main_delivery)
    napiDefine(env, exports, "aw_test_off_main_delivery_result", aw_test_off_main_delivery_result)
    napiDefine(env, exports, "aw_test_escaping_block_delivery", aw_test_escaping_block_delivery)
    napiDefine(
        env, exports, "aw_test_escaping_block_delivery_result", aw_test_escaping_block_delivery_result)
    napiDefine(env, exports, "aw_test_dealloc_off_main", aw_test_dealloc_off_main)
    napiDefine(env, exports, "aw_test_dealloc_off_main_result", aw_test_dealloc_off_main_result)
}

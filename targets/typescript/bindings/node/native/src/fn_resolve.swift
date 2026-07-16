// Symbol resolution for the plain-C free-function table (`aw_ts_fn_<symbol>`), the fixed
// machinery half of `fn-entry-spine-k68`. Realises ADR-0025's trampoline-elided limit for a
// named C export: the emitted `.ts` calls the C function *directly*, so the addon must hand it
// a real function address.
//
// ## Why the entries are per-symbol but the bodies are per-signature
//
// An ObjC method is dispatched through `objc_msgSend` — one address, selected by selector — so
// the whole corpus of methods folds into 998 `aw_ts_msg_<codes>` entries, one per distinct ABI
// signature (Generated/DispatchTable.swift). A C function is called **by its own address**, so
// there is no folding at the export: 2192 symbols means 2192 exports, and that count is a floor.
//
// The *bodies*, though, only differ by ABI signature — 317 of them across the corpus. So each
// export is registered against a **shared per-signature callback** (`aw_ts_fnsig_<codes>`, an
// internal Swift name that never crosses to JS) plus a **descriptor** carried in
// `napi_create_function`'s `data` payload. The callback reads the descriptor back through
// `napi_get_cb_info` and casts the resolved address to the `@convention(c)` shape it was
// generated for. Exports keys stay `aw_ts_fn_<symbol>` (`native_dispatch::function_entry_name`),
// so the `.ts` call sites are untouched and the mirror invariant is unaffected.
//
// The descriptor is therefore the **only per-symbol channel** a shared body has, which is why it
// carries more than the address: `bundled` (below) and `retains` — the CF Create Rule's verdict on
// the object return's ownership, folded by `awFnFoldRetain`. One `aw_ts_fnsig_P_P` body serves
// both a +0 and a +1 object return, and only the descriptor can tell them apart.
//
// ## Why resolution is lazy
//
// Measured first-hand over the whole corpus (2026-07-09, macOS 26.5.1 arm64):
//
//   - `dlsym(RTLD_DEFAULT, …)` with nothing extra loaded resolves **1 of 2192** symbols. The
//     addon links only libSystem / CoreFoundation / CreateML / Foundation / libobjc, and the
//     corpus spans 73 frameworks — Metal, WebKit, Ruby, Tcl, vecLib, GLUT.
//   - After `dlopen` of each symbol's owning framework, **2166 of 2192** resolve (98.8 %).
//   - Eagerly `dlopen`ing all 72 loadable frameworks at module load costs **~90 ms** and drags
//     Metal/WebKit/Ruby/Tcl into every process.
//
// So an address is resolved on **first call** to its entry and cached in the descriptor. A
// program that never calls a Metal function never loads Metal. (Node itself already loads a
// good many system frameworks — 44 of the corpus's 73 — so the *observable* laziness is over
// the other 29: ARKit, MapKit, OpenCL, Ruby, Tcl, LatentSemanticMapping, …)
//
// ## Why `dlopen` is the only honest probe
//
// Since Big Sur the system frameworks' Mach-O binaries live **only in the dyld shared cache**;
// `/System/Library/Frameworks/Security.framework/Security` does not exist on disk. `stat` says
// no, `dlopen` says yes. Never gate on the filesystem.
//
// The lone exception in the corpus is `libdispatch` (62 symbols): an IR "framework" that is not
// a bundle at all — it lives in libSystem and is therefore *always* loaded. Its descriptors
// carry `bundled: false`, so the resolver does not try (and fail) to `dlopen` it, and a genuine
// miss is not blamed on a missing image.
//
// ## Failing loudly
//
// 26 symbols resolve nowhere even after their framework is loaded: 24 Ruby header-only or
// deprecated declarations (`rb_clear_cache`, `rb_hash_end`, …) plus DirectoryService's two
// `dsIsDirService*Running`. They are declared in headers the collector reads and exported by no
// image — a property of the SDK, not a bug. Calling one throws a JS `Error` naming the symbol
// and its framework. It must never call a null address and never silently no-op.

import Foundation

/// `RTLD_DEFAULT` — search every image already loaded into the process, in load order.
/// Re-declared here because `dispatch.swift`'s is `private` (Swift's `private` is file-scoped).
private let RTLD_DEFAULT_HANDLE = UnsafeMutableRawPointer(bitPattern: -2)

/// One free-function entry: the C symbol to call, the framework that exports it, its return's
/// retain convention, and the lazily-resolved address.
///
/// `addr` is mutated on first call and never again. No lock guards it: `dlsym` is idempotent and
/// returns the same address for the same symbol, so two threads racing to resolve one entry
/// write the identical pointer-width value. That matters because a `worker_thread` can reach an
/// entry off thread 0 — the free-function surface, unlike AppKit, is not main-affine.
struct AwFnEntry {
    /// The C symbol name, e.g. `"CFAbsoluteTimeGetCurrent"`.
    let symbol: StaticString
    /// The owning framework's name, e.g. `"CoreFoundation"` — the `dlopen` path and, on
    /// failure, the diagnostic.
    let framework: StaticString
    /// Whether `framework` names a loadable `.framework` bundle. `false` for an IR "framework"
    /// that is not one (`libdispatch`, in libSystem and always loaded).
    let bundled: Bool
    /// Whether this entry folds an `objcRetain` into its object return (`awFnFoldRetain`).
    let retains: Bool
    /// The resolved address, or `nil` until the entry's first call.
    var addr: UnsafeMutableRawPointer?
}

/// The generated table's per-symbol descriptor literal — `AwFnDesc("hypot", "CoreGraphics")`.
/// A plain value type so the generated Swift is one flat array literal; the two flags are spelled
/// only where they leave their defaults.
struct AwFnDesc {
    let symbol: StaticString
    let framework: StaticString
    let bundled: Bool
    let retains: Bool

    init(
        _ symbol: StaticString, _ framework: StaticString, bundled: Bool = true,
        retains: Bool = false
    ) {
        self.symbol = symbol
        self.framework = framework
        self.bundled = bundled
        self.retains = retains
    }
}

/// Fold the +1 an object return owes the wrapper, iff this symbol's return is **+0**.
///
/// Uniform-+1 (ADR-0057 §4): every JS wrapper owns exactly one retain. The runtime's
/// `__wrapRetained` does *not* retain — it takes a handle whose native entry already folded one —
/// while `__wrapOwned` takes the callee's own +1. Which of the two the emitted `.ts` calls is
/// decided per symbol by the Core Foundation **Create Rule** (`Create`/`Copy` in the name → +1),
/// so the fold rides the **descriptor**, not the shared per-signature body.
///
/// `retains` is set only for a return the `.ts` actually wraps (`is_object_type`). A `Class` or
/// `SEL` also crosses as a `UInt` handle but is never wrapped, so it is never folded: retaining a
/// class would leak, and `objc_retain` on a selector is undefined behaviour.
@inline(__always) func awFnFoldRetain(_ data: UnsafeMutableRawPointer?, _ id: UInt) -> UInt {
    guard let data, data.assumingMemoryBound(to: AwFnEntry.self).pointee.retains else { return id }
    return objcRetain(id)
}

/// Allocate the descriptor table the registration passes to `napiDefineWithData` as `data`.
///
/// The entries are heap-allocated (never freed — they live as long as the loaded addon) because
/// `napi_create_function` stores the raw pointer we hand it: a Swift `Array`'s buffer offers no
/// such stability guarantee across the array's lifetime, and taking `&array[i]` would be a
/// dangling pointer the moment the array moved.
func awMakeFnEntries(_ descs: [AwFnDesc]) -> UnsafeMutablePointer<AwFnEntry> {
    let table = UnsafeMutablePointer<AwFnEntry>.allocate(capacity: max(descs.count, 1))
    for (i, d) in descs.enumerated() {
        table.advanced(by: i).initialize(
            to: AwFnEntry(
                symbol: d.symbol, framework: d.framework, bundled: d.bundled, retains: d.retains,
                addr: nil))
    }
    return table
}

/// Resolve (and cache) one entry's address, or **throw a JS `Error` and return `nil`**.
///
/// The cold path is `dlsym` → `dlopen` the owning framework → `dlsym` again. The warm path is a
/// single load of the cached pointer. A caller that gets `nil` back has a pending JS exception
/// and must return `nil` from its napi callback without touching `env` further.
func awResolveFn(_ env: napi_env?, _ data: UnsafeMutableRawPointer?)
    -> UnsafeMutableRawPointer?
{
    guard let data else {
        // Only reachable if an entry were registered through `napiDefine` (which passes `nil`
        // data) instead of `napiDefineWithData` — a generator bug, not a runtime condition.
        napiThrow(env, "aw_ts_fn: free-function entry registered without its descriptor")
        return nil
    }
    let entry = data.assumingMemoryBound(to: AwFnEntry.self)
    if let cached = entry.pointee.addr { return cached }

    let symbol = entry.pointee.symbol.description
    if let addr = symbol.withCString({ dlsym(RTLD_DEFAULT_HANDLE, $0) }) {
        entry.pointee.addr = addr
        return addr
    }

    let framework = entry.pointee.framework.description
    if entry.pointee.bundled {
        // The image is not loaded yet. `RTLD_GLOBAL` so this symbol — and every later symbol
        // from the same framework — resolves through `RTLD_DEFAULT` from here on.
        let path = "/System/Library/Frameworks/\(framework).framework/\(framework)"
        let image = path.withCString { dlopen($0, RTLD_LAZY | RTLD_GLOBAL) }
        if image == nil {
            let reason = dlerror().map { String(cString: $0) } ?? "dlopen failed"
            napiThrow(env, "aw_ts_fn_\(symbol): could not load \(framework) (\(path)) — \(reason)")
            return nil
        }
        if let addr = symbol.withCString({ dlsym(RTLD_DEFAULT_HANDLE, $0) }) {
            entry.pointee.addr = addr
            return addr
        }
    }

    // The image is loaded (or needs none) and still does not export the symbol: a header-only,
    // inlined or deprecated declaration the collector saw but no binary provides.
    napiThrow(
        env,
        "aw_ts_fn_\(symbol): \(framework) exports no symbol '\(symbol)' — it is declared in the "
            + "SDK headers but not by any loaded image (a header-only, inlined or deprecated "
            + "declaration). This entry cannot be called.")
    return nil
}

// The per-signature bodies (`aw_ts_fnsig_<codes>`), the descriptor array, and
// `awRegisterGeneratedFunctions` are **generated** — Generated/FunctionTable.swift, written by
// `apianyware-generate --target typescript` (fn-table-codegen-k69). The three hand-written proof
// entries this file carried through `fn-entry-spine-k68` were transitional and are gone, exactly
// as `swift-residual-cli-pass-k65` retired the hand-written `aw_ts_swift_CoreGraphics_hypot` and
// `outbound-dispatch-table-k58` retired dispatch.swift's ~44 hand-picked `aw_ts_msg_*` entries.
// What stays here is the fixed machinery the generated table stands on: the descriptor types,
// the heap-stable allocation, the lazy resolver, and the retain fold.
//
// The `aw_ts_fnsig_` prefix is an **internal Swift name**, never a JS export key — it reuses the
// `AbiType::code` alphabet (`native_dispatch.rs`) purely so a reader can see which cast a body
// performs. The exports are `aw_ts_fn_<symbol>`, computed by `function_entry_name`, and are the
// only names the emitted `.ts` knows.

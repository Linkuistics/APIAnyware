// OpaqueHandle.swift — opaque heap-boxed handles for non-bridged Swift values.
//
// The sbcl trampoline layer (ADR-0038; ADR-0011 hermetic isolation) returns
// Swift-native *values* that have no Foundation bridge and are not ObjC objects —
// non-bridged `struct`s, payload `enum`s, tuples, value-backed existentials,
// opaque `some P` returns — across the flat C ABI as **opaque handles**. (An ObjC
// object return is handled differently: it is a real `id`, handed back raw and
// `wrap`ped to its exact bound CLOS class Lisp-side via the ADR-0034 MOP class
// registry, never boxed here — see Generated/Trampolines.swift and the runtime's
// swift-trampoline cluster.)
//
// The generated `@_cdecl` trampolines box the value here and hand the Lisp runtime
// the raw pointer; a value-struct *parameter* is read back via `awSbclUnbox` (same
// module, where the concrete type is nameable).
//
// This mirrors the gerbil/chez/racket targets' `OpaqueHandle.swift` in shape,
// renamed under the `aw_sbcl_*` / `awSbcl*` namespace. Per ADR-0011 the targets
// share no native substrate — the duplication is deliberate (the ADR-0010/0011
// economics: a bespoke per-target native library is affordable), not an oversight.
//
// Exports: aw_sbcl_box_free (the one uniform value-handle free).
// Generic helpers (same-module, called by generated trampolines + accessors):
//   awSbclBox, awSbclUnbox.

import Foundation

/// Heap box holding an arbitrary Swift value as `Any`. A `final class` so it is
/// reference-counted: `Unmanaged.passRetained` gives the opaque +1 handle the Lisp
/// runtime holds, and the matching release (via `aw_sbcl_box_free`) frees it.
///
/// `value` is a `var` (D3): a `mutating` value-receiver method trampoline reads the
/// boxed value into a `var`, calls the mutating method, and writes the mutated value
/// back into the **same** box, so the single handle the runtime holds reflects the
/// mutation (the value-type write-back, ADR-0030 §D3).
public final class AwSbclValueBox {
    public var value: Any
    @inlinable public init(_ value: Any) { self.value = value }
}

/// Box a non-bridged Swift value and return an opaque, +1-retained handle.
///
/// Used by generated trampolines whose return type has no Foundation bridge and
/// is not an ObjC object. The handle is owned by the Lisp runtime; its lifetime
/// ends at `aw_sbcl_box_free`.
@inlinable
public func awSbclBox<T>(_ value: T) -> UnsafeMutableRawPointer {
    Unmanaged.passRetained(AwSbclValueBox(value)).toOpaque()
}

/// Read a boxed value back as `T`. Used by generated value-struct param unboxing,
/// where the concrete `T` is known and nameable. Does **not** consume the handle
/// (the box stays alive for further use until freed).
///
/// Traps if the stored value is not a `T` — a codegen bug, not a runtime input
/// error, so failing loudly is correct.
@inlinable
public func awSbclUnbox<T>(_ handle: UnsafeMutableRawPointer, as _: T.Type) -> T {
    let box = Unmanaged<AwSbclValueBox>.fromOpaque(handle).takeUnretainedValue()
    return box.value as! T
}

/// Free an opaque value handle created by `awSbclBox` (-1 ref, frees at zero).
/// The one uniform free for every boxed-value handle, regardless of boxed type.
/// After this call the handle is invalid and must not be used.
@_cdecl("aw_sbcl_box_free")
public func awSbclBoxFree(_ handle: UnsafeMutableRawPointer) {
    Unmanaged<AwSbclValueBox>.fromOpaque(handle).release()
}

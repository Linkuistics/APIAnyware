// OpaqueHandle.swift — opaque heap-boxed handles for non-bridged Swift values.
//
// The chez trampoline layer (ADR-0027 ported to chez in leaf 060; ADR-0011
// hermetic isolation) returns Swift-native values that have no Foundation bridge
// — non-bridged `struct`s, payload `enum`s, tuples, value-backed existentials,
// opaque `some P` returns — across the flat C ABI as **opaque handles**. The
// generated `@_cdecl` trampolines in `Generated/Trampolines.swift` box the value
// here and hand chez the raw pointer; per-type accessors (also generated, in the
// same module, where the concrete type is nameable) read it back via
// `awChezUnbox`.
//
// This mirrors the racket target's `OpaqueHandle.swift` byte-for-byte in shape,
// renamed under the `aw_chez_*` / `awChez*` namespace. Per ADR-0011 the two
// targets share no native substrate — the duplication is deliberate (the
// ADR-0010/0011 economics: a bespoke per-target native library is affordable),
// not an oversight. Design rationale (one rep, one free; `Unmanaged` for class
// instances only) is identical to racket's — see that file's header and spec §3.
//
// Exports: aw_chez_box_free (the one uniform value-handle free).
// Generic helpers (same-module, called by generated trampolines + accessors):
//   awChezBox, awChezUnbox.

import Foundation

/// Heap box holding an arbitrary Swift value as `Any`. A `final class` so it is
/// reference-counted: `Unmanaged.passRetained` gives the opaque +1 handle chez
/// holds, and the matching release (via `aw_chez_box_free`) frees it.
public final class AwChezValueBox {
    /// `var`, not `let`: a `mutating` value-receiver method trampoline (D3, ADR-0030)
    /// writes the mutated value back here (`box.value = awSelf`), so the single handle
    /// the chez side holds reflects the mutation (one stable identity).
    public var value: Any
    @inlinable public init(_ value: Any) { self.value = value }
}

/// Box a non-bridged Swift value and return an opaque, +1-retained handle.
///
/// Used by generated trampolines whose return type has no Foundation bridge.
/// The handle is owned by chez; its lifetime ends at `aw_chez_box_free`.
@inlinable
public func awChezBox<T>(_ value: T) -> UnsafeMutableRawPointer {
    Unmanaged.passRetained(AwChezValueBox(value)).toOpaque()
}

/// Read a boxed value back as `T`. Used by generated per-type accessors, where
/// the concrete `T` is known and nameable. Does **not** consume the handle (the
/// box stays alive for further accessor calls until freed).
///
/// Traps if the stored value is not a `T` — a codegen bug, not a runtime input
/// error, so failing loudly is correct.
@inlinable
public func awChezUnbox<T>(_ handle: UnsafeMutableRawPointer, as _: T.Type) -> T {
    let box = Unmanaged<AwChezValueBox>.fromOpaque(handle).takeUnretainedValue()
    return box.value as! T
}

/// Free an opaque value handle created by `awChezBox` (-1 ref, frees at zero).
/// The one uniform free for every boxed-value handle, regardless of boxed type.
/// After this call the handle is invalid and must not be used.
@_cdecl("aw_chez_box_free")
public func awChezBoxFree(_ handle: UnsafeMutableRawPointer) {
    Unmanaged<AwChezValueBox>.fromOpaque(handle).release()
}

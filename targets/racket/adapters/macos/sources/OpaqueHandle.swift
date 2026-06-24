// OpaqueHandle.swift — opaque heap-boxed handles for non-bridged Swift values.
//
// The trampoline layer (ADR-0027 / targets/racket/docs/design/2026-06-15-racket-trampoline.md §3)
// returns Swift-native values that have no Foundation bridge — non-bridged
// `struct`s, payload `enum`s, tuples, value-backed existentials, opaque `some P`
// returns — across the flat C ABI as **opaque handles**. The generated
// `@_cdecl` trampolines in `Generated/Trampolines.swift` box the value here and
// hand Racket the raw pointer; per-type field/tag accessors (also generated, in
// the same module, where the concrete type is nameable) read it back via
// `awRacketUnbox`.
//
// Design — one rep, one free (resolved in leaf 040/010, spec §3 updated):
//
//   A value of *any* type is wrapped in `AwValueBox`, a `final class` holding it
//   as `Any`, and the box is `Unmanaged.passRetained`-ed to an opaque pointer.
//   This collapses the spec's separate struct / enum / tuple / existential /
//   opaque rows onto a single mechanism and yields **one** uniform free entry,
//   `aw_racket_box_free` — there is no per-type `_free`. Three properties make
//   this the right rep:
//
//   1. `Any` boxing holds value types (and the values they transitively own)
//      with correct copy/lifetime semantics; the round-trip through
//      `awRacketUnbox` returns an equal value.
//   2. It works for types that cannot be *named* at a free site — an opaque
//      `some P` return — because the box, not the call site, owns the storage.
//   3. The box is itself a class, so its lifetime rides the **existing**
//      `Unmanaged` retain/finalize machinery the runtime already uses for class
//      instances (MemoryManagement.swift). The Racket seam wraps the handle the
//      same way it wraps any retained object and the finalizer calls
//      `aw_racket_box_free` — no new lifetime model (brief 040/010 constraint).
//
// Genuine **class instances** (where reference identity must be preserved, e.g.
// the value is later passed back to another API) do *not* box here: the
// trampoline `Unmanaged.passRetained`es the instance directly and Racket frees
// it through the existing `aw_racket_release`. Only non-class / unnameable
// values take the `AwValueBox` path.
//
// Exports: aw_racket_box_free (the one uniform handle free).
// Generic helpers (same-module, called by generated trampolines + accessors):
//   awRacketBox, awRacketUnbox.

import Foundation

/// Heap box holding an arbitrary Swift value as `Any`. A `final class` so it is
/// reference-counted: `Unmanaged.passRetained` gives the opaque +1 handle Racket
/// holds, and the matching release (via `aw_racket_box_free`) frees it.
///
/// `value` is a `var` (not `let`) for the **mutating value-receiver write-back**
/// path (method-frontier D3, spec §method): a `mutating` method on a value-type
/// receiver mutates a local copy unboxed from the handle; the trampoline writes the
/// mutated value back into this box so the single handle Racket holds reflects the
/// mutation (one stable identity). Mutability is a thread-safety note only — handles
/// are single-threaded under the Racket main-thread model (ADR-0014).
public final class AwValueBox {
    public var value: Any
    @inlinable public init(_ value: Any) { self.value = value }
}

/// Box a non-bridged Swift value and return an opaque, +1-retained handle.
///
/// Used by generated trampolines whose return type has no Foundation bridge.
/// The handle is owned by Racket; its finalizer must call `aw_racket_box_free`.
@inlinable
public func awRacketBox<T>(_ value: T) -> UnsafeMutableRawPointer {
    Unmanaged.passRetained(AwValueBox(value)).toOpaque()
}

/// Read a boxed value back as `T`. Used by generated per-type field/tag
/// accessors, where the concrete `T` is known and nameable. Does **not** consume
/// the handle (the box stays alive for further accessor calls until freed).
///
/// Traps if the stored value is not a `T` — a codegen bug, not a runtime input
/// error, so failing loudly is correct.
@inlinable
public func awRacketUnbox<T>(_ handle: UnsafeMutableRawPointer, as _: T.Type) -> T {
    let box = Unmanaged<AwValueBox>.fromOpaque(handle).takeUnretainedValue()
    return box.value as! T
}

/// Free an opaque value handle created by `awRacketBox` (-1 ref, frees at zero).
/// The one uniform free for every boxed-value handle, regardless of the boxed
/// type. After this call the handle is invalid and must not be used.
@_cdecl("aw_racket_box_free")
public func awRacketBoxFree(_ handle: UnsafeMutableRawPointer) {
    Unmanaged<AwValueBox>.fromOpaque(handle).release()
}

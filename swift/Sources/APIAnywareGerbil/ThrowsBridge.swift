// ThrowsBridge.swift — the `throws` → trailing NSError out-param convention.
//
// A Swift-native `throws` function cannot propagate its error across the flat C
// ABI. The gerbil trampoline layer (ADR-0029) takes a trailing caller-allocated
// out-buffer (`NSError **`): on a thrown error it writes a **retained** `NSError *`
// (or leaves nil) through it before returning a fallback value, and the gerbil
// seam (`runtime/swift-trampoline.ss`'s `aw-swift-call/error`) allocates the cell,
// checks it, releases the +1, and raises.
//
// Mirrors the chez/racket targets' `ThrowsBridge.swift`, renamed under `awGerbil*`
// (per ADR-0011 the targets share no native substrate — the duplication is by
// design).
//
// Two entry points, both same-module Swift (an `Error` is not C-representable, so
// neither can be `@_cdecl`; they are called from generated `@_cdecl` bodies):
//
//   awGerbilWriteError — marshal a thrown `Error` to a retained `NSError *`
//     through the out-buffer (Unmanaged.passRetained, raw cell, ARC kept out).
//   awGerbilTry — run a throwing body, return its value on success or write the
//     error + return a caller-supplied fallback on throw, so a generated
//     trampoline body is a single expression.

import Foundation

/// Write a thrown error to a trailing `NSError **` out-buffer as a **retained**
/// (+1) `NSError *`. The +1 retain hands gerbil an `NSError` whose lifetime is
/// independent of any autorelease pool; the raw-pointer store keeps ARC out of
/// the assignment (no implicit retain/over-release).
///
/// `errOut` is the caller-allocated cell (`UnsafeMutableRawPointer?` storage);
/// nil means the caller did not ask for the error (it is then dropped).
public func awGerbilWriteError(_ errOut: UnsafeMutableRawPointer?, _ error: Error) {
    guard let errOut = errOut else { return }
    let nsError = error as NSError
    let retained = Unmanaged.passRetained(nsError).toOpaque()
    errOut.assumingMemoryBound(to: UnsafeMutableRawPointer?.self).pointee = retained
}

/// Run a throwing body, returning its value on success. On a thrown error, write
/// the error through `errOut` (see `awGerbilWriteError`) and return `fallback`.
///
/// `fallback` is the value the C boundary returns on the error path — the
/// generated trampoline supplies it for its concrete return rep (nil for an
/// `id`/handle pointer, 0 for a scalar). This lets a generated body be a single
/// `return awGerbilTry(errOut, <fallback>) { try <call> }`.
public func awGerbilTry<R>(
    _ errOut: UnsafeMutableRawPointer?,
    _ fallback: R,
    _ body: () throws -> R
) -> R {
    do {
        return try body()
    } catch {
        awGerbilWriteError(errOut, error)
        return fallback
    }
}

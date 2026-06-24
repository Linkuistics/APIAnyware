// ThrowsBridge.swift — the `throws` → trailing NSError out-param convention.
//
// A Swift-native `throws` function cannot propagate its error across the flat C
// ABI. The trampoline layer (ADR-0027 / spec §3) mirrors the **exact** shape the
// generated ObjC dispatch table already uses for Cocoa `…error:` methods
// (native_dispatch.rs `err_write`): the trampoline takes a trailing
// caller-allocated out-buffer (`NSError **`), and on a thrown error writes a
// **retained** `NSError *` (or leaves nil) through it before returning a fallback
// value. The Racket seam — which already checks-and-raises for the dispatch
// path — reuses that same machinery here.
//
// Two entry points, both same-module Swift (an `Error` is not C-representable,
// so neither can be `@_cdecl`; they are called from generated `@_cdecl` bodies):
//
//   awRacketWriteError — the primitive: marshal a thrown `Error` to a retained
//     `NSError *` through the out-buffer. Mirrors dispatch `err_write` byte for
//     byte (Unmanaged.passRetained, raw cell, ARC kept out of the loop).
//   awRacketTry — ergonomic wrapper: run a throwing body, return its value on
//     success or write the error + return a caller-supplied fallback on throw,
//     so a generated trampoline body is a single expression.

import Foundation

/// Write a thrown error to a trailing `NSError **` out-buffer as a **retained**
/// (+1) `NSError *`, matching the generated dispatch table's `error_out` shape
/// exactly so the Racket side's existing check-and-raise applies unchanged.
///
/// `errOut` is the caller-allocated cell (`UnsafeMutableRawPointer?` storage);
/// nil means the caller did not ask for the error (it is then dropped). The +1
/// retain hands Racket an `NSError` whose lifetime is independent of any
/// autorelease pool; the raw-pointer store keeps ARC out of the assignment (no
/// implicit retain/over-release), again as the dispatch entry does.
public func awRacketWriteError(_ errOut: UnsafeMutableRawPointer?, _ error: Error) {
    guard let errOut = errOut else { return }
    let nsError = error as NSError
    let retained = Unmanaged.passRetained(nsError).toOpaque()
    errOut.assumingMemoryBound(to: UnsafeMutableRawPointer?.self).pointee = retained
}

/// Run a throwing body, returning its value on success. On a thrown error, write
/// the error through `errOut` (see `awRacketWriteError`) and return `fallback`.
///
/// `fallback` is the value the C boundary returns on the error path — the
/// generated trampoline supplies it for its concrete return rep (nil for an
/// `id`/handle pointer, 0 for a scalar). This lets a generated body be a single
/// `return awRacketTry(errOut, <fallback>) { try <call> }`.
public func awRacketTry<R>(
    _ errOut: UnsafeMutableRawPointer?,
    _ fallback: R,
    _ body: () throws -> R
) -> R {
    do {
        return try body()
    } catch {
        awRacketWriteError(errOut, error)
        return fallback
    }
}

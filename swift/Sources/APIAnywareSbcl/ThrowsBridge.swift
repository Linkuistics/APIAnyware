// ThrowsBridge.swift — the `throws` → trailing NSError out-param convention.
//
// A Swift-native `throws` function cannot propagate its error across the flat C
// ABI. The sbcl trampoline layer (ADR-0038) takes a trailing caller-allocated
// out-buffer (`NSError **`): on a thrown error it writes a **retained** `NSError *`
// (or leaves nil) through it before returning a fallback value, and the sbcl seam
// (the runtime's `aw-with-error-cell` macro / `signal-cocoa-error`, ADR-0037)
// allocates the cell, checks it, releases the +1, and signals `ns:cocoa-error`.
//
// Mirrors the gerbil/chez/racket targets' `ThrowsBridge.swift`, renamed under
// `awSbcl*` (per ADR-0011 the targets share no native substrate — the duplication
// is by design). The SBCL twist (ADR-0037): the *same* `signal-cocoa-error` Lisp
// signaller serves both this Swift-`throws` path and the direct `NSError**` path,
// keyed on the primary return — but that unification is Lisp-side; the Swift
// bridge here is identical to the peers.
//
// Two entry points, both same-module Swift (an `Error` is not C-representable, so
// neither can be `@_cdecl`; they are called from generated `@_cdecl` bodies):
//
//   awSbclWriteError — marshal a thrown `Error` to a retained `NSError *`
//     through the out-buffer (Unmanaged.passRetained, raw cell, ARC kept out).
//   awSbclTry — run a throwing body, return its value on success or write the
//     error + return a caller-supplied fallback on throw, so a generated
//     trampoline body is a single expression.

import Foundation

/// Write a thrown error to a trailing `NSError **` out-buffer as a **retained**
/// (+1) `NSError *`. The +1 retain hands the Lisp runtime an `NSError` whose
/// lifetime is independent of any autorelease pool; the raw-pointer store keeps
/// ARC out of the assignment (no implicit retain/over-release).
///
/// `errOut` is the caller-allocated cell (`UnsafeMutableRawPointer?` storage);
/// nil means the caller did not ask for the error (it is then dropped).
public func awSbclWriteError(_ errOut: UnsafeMutableRawPointer?, _ error: Error) {
    guard let errOut = errOut else { return }
    let nsError = error as NSError
    let retained = Unmanaged.passRetained(nsError).toOpaque()
    errOut.assumingMemoryBound(to: UnsafeMutableRawPointer?.self).pointee = retained
}

/// Run a throwing body, returning its value on success. On a thrown error, write
/// the error through `errOut` (see `awSbclWriteError`) and return `fallback`.
///
/// `fallback` is the value the C boundary returns on the error path — the
/// generated trampoline supplies it for its concrete return rep (nil for an
/// `id`/handle pointer, 0 for a scalar). This lets a generated body be a single
/// `return awSbclTry(errOut, <fallback>) { try <call> }`.
public func awSbclTry<R>(
    _ errOut: UnsafeMutableRawPointer?,
    _ fallback: R,
    _ body: () throws -> R
) -> R {
    do {
        return try body()
    } catch {
        awSbclWriteError(errOut, error)
        return fallback
    }
}

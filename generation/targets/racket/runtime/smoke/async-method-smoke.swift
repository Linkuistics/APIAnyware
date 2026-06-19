// async-method-smoke.swift — the Swift side of the async-method in-process smoke
// (030-racket/020-async-method, the §8.7 raw-symbol-bind pattern).
//
// Compiled INTO libAPIAnywareRacket.dylib alongside the runtime sources (so it can
// call the same-module `awRacketAsyncDispatch` / `AwAsyncOutcome` / `awRacketBox`
// the generated code uses). It hand-authors the EXACT generated shape of
// `URLSession.data(from:)` (an `async throws` class-receiver method with a bridged
// `NSURL`→`URL` param returning a boxed `(Data, URLResponse)` tuple), plus two
// accessors so racket can obtain the receiver + a file URL and read the result.
//
// This is the proof that the D5 async codegen + R4 callback runtime resolve and run
// a real recovered async method end-to-end. The full pipeline + VM-verify is
// 030-rerun-verify.

import Foundation

/// `URLSession.shared` as a +1-retained opaque `id` (the population-A receiver the
/// racket side passes back into the trampoline).
@_cdecl("aw_smoke_url_session_shared")
public func aw_smoke_url_session_shared() -> UnsafeMutableRawPointer? {
    return Unmanaged.passRetained(URLSession.shared).toOpaque()
}

/// A file `NSURL` from a path string (`id` in, `id` out) — the bridged object param
/// the async trampoline reconstructs as `URL`.
@_cdecl("aw_smoke_file_url")
public func aw_smoke_file_url(_ path: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    let p = Unmanaged<NSString>.fromOpaque(path!).takeUnretainedValue() as String
    return Unmanaged.passRetained(URL(fileURLWithPath: p) as NSURL).toOpaque()
}

/// The async `data(from:)` trampoline — byte-for-byte the generated shape
/// (`trampoline.rs` `emit_async_method_tramp`): receiver + bridged object param,
/// then ctx + C callback; the operation closure captures the receiver pointer via
/// `nonisolated(unsafe)`, unboxes inside, `await`s, and marshals `(Data, URLResponse)`
/// to a boxed handle on the cooperative pool; the completion delivers it via `awCb`.
@_cdecl("aw_smoke_url_session_data")
public func aw_smoke_url_session_data(
    _ awRecv: UnsafeMutableRawPointer?,
    _ a0: UnsafeMutableRawPointer?,
    _ awCtx: Int,
    _ awCb: @convention(c) (Int, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void
) {
    let o0 = Unmanaged<NSURL>.fromOpaque(a0!).takeUnretainedValue() as URL
    nonisolated(unsafe) let awRecvUnsafe = awRecv
    awRacketAsyncDispatch({ () async -> AwAsyncOutcome in
        let awSelf = Unmanaged<Foundation.URLSession>.fromOpaque(awRecvUnsafe!).takeUnretainedValue()
        do {
            let awR = try await awSelf.data(from: o0)
            return AwAsyncOutcome(value: awRacketBox(awR))
        } catch {
            return AwAsyncOutcome.failure(error)
        }
    }, { awOutcome in
        awCb(awCtx, awOutcome.value, awOutcome.error)
    })
}

/// Unbox the boxed `(Data, URLResponse)` result handle and return the `Data` byte
/// count — lets the racket smoke assert real bytes crossed the bridge.
@_cdecl("aw_smoke_tuple_data_count")
public func aw_smoke_tuple_data_count(_ handle: UnsafeMutableRawPointer?) -> Int {
    let tuple = awRacketUnbox(handle!, as: (Data, URLResponse).self)
    return tuple.0.count
}

// Hand-written companions to the GENERATED Swift-native `s:` residual trampoline table
// (Generated/TrampolineTable.swift, ADR-0061 ported from racket ADR-0027).
//
// A `objc_exposed == false` free function has NO C symbol — it is reachable only across the
// Swift ABI (ADR-0025 trampoline-elision limit). So the addon carries, per residual function, a
// napi callback that `import`s the owning framework module and calls the API **by name**, letting
// swiftc own Swift-ABI correctness (ADR-0027 §1; the mangled-`s:`-symbol + hand-cast route was
// rejected there). Those entries are **generated** from the IR by
// `apianyware-generate --target typescript` (swift-residual-cli-pass-k65) and register themselves
// through `awRegisterGeneratedTrampolines`.
//
// What stays here is what is NOT per-symbol: the object-return marshalling probe below. The
// hand-written `aw_ts_swift_CoreGraphics_hypot` this file carried for the spike (fn-trampoline-
// spine-k53) is now generated, byte-for-byte in the shape the emitter renders — `test/swift-native.mjs`
// exercises the generated entry.

import Foundation

/// **Object-return marshalling + shape probe** (`object-bridged-returns-k55`, ADR-0061 §3). No
/// headless, non-throwing, object-returning Swift-native *free* function exists in the macOS SDK —
/// an SDK survey found the object residual lives at the *method* level (ADR-0061 §4), so unlike
/// the generated `hypot` (which proves the scalar call-by-name *reach*) there is no real
/// object-returning free function to reach. This probe instead exercises the exact **return shape**
/// `emit-typescript`'s `crate::trampoline` generates for an object return —
/// `napiMakeRetainedObject(env, (…) as AnyObject?)` — against a real Foundation `String`→`NSString`
/// bridge, proving the `passRetained`→+1-handle marshalling compiles and round-trips a correct,
/// usable object handle headless. (`passRetained`'s +1 is a stdlib guarantee; `__wrapOwned`'s +1
/// handling is proven by `retain-fold-k48`.) Registered under `"aw_ts_swift_probe_objectReturn"`;
/// not a real API — it stands in for the object residual's *marshalling*, not its by-name reach.
func aw_ts_swift_probe_objectReturn(_ env: napi_env?, _ info: napi_callback_info?)
    -> napi_value?
{
    _ = napiCallbackArgs(env, info, 0)
    return napiMakeRetainedObject(env, ("aw-object-return-probe") as AnyObject?)
}

// ChezFFI.swift — Chez Scheme-specific FFI helpers.
//
// The APIAnywareChez module is self-contained (ADR-0011): it owns its entire
// native surface, with no dependency on a shared substrate.
//
//   - ChezRuntime:    class/selector lookup, retain/release, autorelease pool,
//                     and NSString conversion (`aw_chez_*`), absorbed from the
//                     former APIAnywareCommon
//   - BlockBridge:    ObjC block creation from foreign-callable pointers
//   - DelegateBridge: Dynamic ObjC class creation with per-instance dispatch
//   - GCPrevention:   Swift-side registry used by BlockBridge for async
//                     dispose-helper accounting (chez itself uses
//                     lock-object on the Scheme side)
//
// All exports use @_cdecl with the `aw_chez_` prefix. Method dispatch
// (objc_msgSend) stays in Scheme as a typed `foreign-procedure` per call site
// (ADR-0015) — the native library is not in that path.

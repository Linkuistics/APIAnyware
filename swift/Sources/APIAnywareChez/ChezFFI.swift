// ChezFFI.swift — Chez Scheme-specific FFI helpers.
//
// The APIAnywareChez module provides:
//   - BlockBridge:    ObjC block creation from foreign-callable pointers
//   - DelegateBridge: Dynamic ObjC class creation with per-instance dispatch
//   - GCPrevention:   Swift-side registry used by BlockBridge for async
//                     dispose-helper accounting (chez itself uses
//                     lock-object on the Scheme side)
//
// All exports use @_cdecl with `aw_chez_` prefix.
// The Common module's `aw_common_msg_*` variants handle objc_msgSend
// dispatch and are statically embedded into libAPIAnywareChez.dylib.

import APIAnywareCommon

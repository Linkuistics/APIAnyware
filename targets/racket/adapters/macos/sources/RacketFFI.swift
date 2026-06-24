// RacketFFI.swift — Racket-specific FFI helpers.
//
// The APIAnywareRacket module is self-contained (ADR-0011, hermetic isolation):
// it provides both the racket-specific bridges and the absorbed substrate it
// once shared via APIAnywareCommon.
//
//   Racket-specific:
//   - BlockBridge:    ObjC block creation from C function pointers
//   - DelegateBridge: Dynamic ObjC class creation with per-instance dispatch
//   - GCPrevention:   Reference registry preventing GC collection of live callbacks
//
//   Absorbed substrate (formerly APIAnywareCommon):
//   - AutoreleasePool, ClassLookup, MemoryManagement,
//     ObservationBridge, StringConversion, StructMarshal
//
// All exports — racket-specific and absorbed substrate alike — use @_cdecl with
// the `aw_racket_` prefix. On de-sharing from APIAnywareCommon (leaf 020) the
// absorbed copies were renamed off the borrowed `aw_common_` namespace so the
// library owns its full symbol surface; the runtime loader (swift-helpers.rkt)
// binds these `aw_racket_` names.

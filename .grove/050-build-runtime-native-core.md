# 050-build-runtime-native-core

**Kind:** work

## Goal

Build the SBCL runtime + native core (guide Steps 3–4): the `sb-alien` FFI seam;
the **MOP machinery** (the `objc-class` metaclass + `slot-value-using-class` /
`allocate-instance` / dispatch hooks; `make-instance` → `alloc`/`init`); block /
delegate bridges; **dynamic ObjC subclass synthesis** (`objc_allocateClassPair` +
IMP trampolines from `define-alien-callable`); lifetime (finalizers/weak-ptrs +
entry-point autoreleasepool); foreign-thread activation (`sb-thread`) + AppKit
main-thread handling; the **startup re-resolution pass** (relive baked
`Class`/`SEL` pointers after `save-lisp-and-die`, 020 §B5); and **`libAPIAnywareSbcl`
— the trampoline-only Swift dylib** (settled: necessary, not optional — like
gerbil's `gsc`, SBCL cannot compile Swift inline; ADR-0029 precedent).

## Context

Design fixed in **030-design** (the object-model, lifetime/threading/conditions,
and trampoline-layer child leaves) + the complete-API model ADRs 0025/0026/0029.
Read those specs + ADRs. Peers: racket/chez/gerbil Swift trampoline dylibs (all
trampoline-only, hermetic per-target). The dylib is **Swift** (it re-exports the
Swift-native residual) — *not* an ObjC core; ObjC is reached directly via
`sb-alien` `objc_msgSend`.

## Done when

- Runtime loads in SBCL; the MOP object model works end-to-end (instantiate,
  dispatch, subclass, callback) against a real framework.

## Notes

- Decomposes (MOP, bridges, lifetime, threading, dylib) when picked.

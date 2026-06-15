# 050-build-runtime-native-core

**Kind:** work

## Goal

Build the SBCL runtime + native core (guide Steps 3–4): the `sb-alien` FFI seam;
the **MOP machinery** (the `objc-class` metaclass + `slot-value-using-class` /
`allocate-instance` / dispatch hooks; `make-instance` → `alloc`/`init`); block /
delegate bridges; **dynamic ObjC subclass synthesis** (`objc_allocateClassPair` +
IMP trampolines from `define-alien-callable`); lifetime (finalizers/weak-ptrs +
entry-point autoreleasepool); foreign-thread activation (`sb-thread`) + AppKit
main-thread handling; and the `libAPIAnywareSbcl` native dylib if 030 decides one
is needed.

## Context

Design fixed in **030-design** (questions 3,5,6,7). Read its spec + ADRs. Peers:
racket/chez Swift dylibs; gerbil's no-dylib ObjC-in-gsc core (ADR-0017) — SBCL
likely needs a small ObjC dylib since it can't compile ObjC inline.

## Done when

- Runtime loads in SBCL; the MOP object model works end-to-end (instantiate,
  dispatch, subclass, callback) against a real framework.

## Notes

- Decomposes (MOP, bridges, lifetime, threading, dylib) when picked.

# sbcl macOS binding — unsafe escape hatches (§22)

When the binding does not model an API, sbcl lets you drop below it to raw `sb-alien`. This is the
documented, supported way out — but it is **unsafe** in the FFI sense (you take on the memory,
lifetime, and threading obligations the binding otherwise upholds). The escape hatch is the
`unsafe-escape-hatch` idiom in [`../../../idioms/catalogue.apiw`](../../../idioms/catalogue.apiw).

## The hatches, least to most drastic

1. **The raw foreign pointer of a wrapped object.** Every wrapped object is a CLOS instance carrying
   its underlying ObjC pointer in the inherited `ns:ns-object` `ptr` slot; `aw-ptr` exposes it (a
   `sb-sys:system-area-pointer`) for APIs the binding does not model. Pass it to your own typed
   `sb-alien` cast over `objc_msgSend`. You are now responsible for the ObjC retain/release discipline
   on that pointer — the lifetime finalizer only tracks wrappers `aw-wrap` created. Use `aw-wrap` to
   bring a raw `id` *back* into the class graph (it resolves to the exact bound type via the MOP
   registry; pass `t` for a +1/owned reference so the main-thread release finalizer is armed).

2. **A raw typed `sb-alien` cast over `objc_msgSend`.** For a selector with no generated generic, look
   the selector up via the `ffi.lisp` `aw-sel`/`aw-class` helpers and `sap-alien`-recast the
   `+objc-msgsend+` SAP to the exact `(function <ret> sap sap <args>…)` type for the call's ABI
   signature, then send the message directly. This is also the escape when a generated framework tree
   fails to load — drop to a raw cast without loading the broken framework. (arm64 needs no
   `_stret`/`_fpret` variant — the plain entry handles structs/floats via x8.)

3. **Raw buffers (`buffers = idiomatic-conventional`).** Interior-pointer / caller-allocated buffer
   APIs use raw `sb-alien` pointers by convention — a foreign-allocated region passed in and filled in
   place, or the **two-call sizing pattern** (`two-call-sizing`): call once for the length, allocate,
   call again to fill. No bounds checking is enforced.

4. **A pointer-valued constant.** A constant whose value is a runtime address (not a literal) is
   reached via the dylib's symbol surface / a `sb-alien` read rather than as a Lisp literal — see
   [`../../../docs/reference.md`](../../../docs/reference.md). (Pointer constants are the one constant
   class the trampoline does *not* elide; a framework string constant like
   `PDFViewPageChangedNotification` is also a foreign read, re-resolved at startup in a dumped image.)

## What you give up

Dropping to a hatch bypasses the binding's compile-time typed marshalling, its registry rooting of
callbacks, the `sb-ext:finalize` + main-thread release-queue accounting, the autorelease-pool
discipline, and the main-thread-bounce contract. In particular:

- A raw native callback you hand to ObjC is **not** rooted by the binding's registry — keep its Lisp
  closure reachable yourself, or the GC may reclaim it while ObjC still holds it. (The binding's
  `aw-block` / `define-objc-subclass` root for you via the **strong** `*subclass-instances*` table;
  hand-rolled trampolines do not.) **And there is no bounce in a raw call's path** — a raw callback
  invoked on a foreign OS thread runs Lisp on that thread, which under GC crashes deterministically
  (`GC-STOP-THE-WORLD` `ENOTSUP`, ADR-0035). If you hand-roll a callback, you must bounce to the main
  thread (`aw-on-main`) yourself before any Lisp runs.
- Lifetimes are yours: nothing releases what you `retain`/`alloc` outside a wrapper, and the finalizer
  will not fire for a pointer it never wrapped. A `+0` accessor result you **store** (rather than
  immediately pass on) must be **owned** (`%objc-retain` + `aw-wrap … t`), or it dies with whatever
  currently retains it.
- For UI mutation you must hop to the main thread yourself (`aw-on-main`) — the binding's main-thread
  bounce is not in a raw call's path. (Pure-Lisp compute on a native `sb-thread` worker is safe; it is
  the ObjC/UI touch that must be on main.)
- SBCL enables IEEE FP traps by default and AppKit produces NaN/∞ intermediates during ordinary
  layout — the runtime masks them on the main thread, but a raw crossing off that path may need its
  own `(sb-int:set-floating-point-modes :traps '())`.

## When you shouldn't need a hatch

If the API is Swift-native (`async`/`throws`/value-return) rather than unmodeled ObjC, the binding
*does* model it — through the sole-native-unit `libAPIAnywareSbcl` dylib, not a raw hatch
([`../../../docs/ffi-model.md`](../../../docs/ffi-model.md)). And to receive framework callbacks
(delegate methods, `drawRect:`), prefer **`define-objc-subclass`** over a hand-rolled trampoline — it
is the supported, GC-safe, bounce-correct path, and its reflective forwarding IMP is ABI-correct for
every selector shape. Reach for a hatch only for genuinely unmodeled ObjC surface; if you find
yourself needing one for a common API, that is a coverage gap worth filing (see
[`api-coverage.md`](api-coverage.md)).

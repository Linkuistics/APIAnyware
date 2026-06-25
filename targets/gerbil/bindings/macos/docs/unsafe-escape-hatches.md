# gerbil macOS binding — unsafe escape hatches (§22)

When the binding does not model an API, gerbil lets you drop below it to raw FFI. This is the
documented, supported way out — but it is **unsafe** in the FFI sense (you take on the memory,
lifetime, and threading obligations the binding otherwise upholds). The escape hatch is the
`unsafe-escape-hatch` idiom in [`../../../idioms/catalogue.apiw`](../../../idioms/catalogue.apiw).

## The hatches, least to most drastic

1. **The raw foreign pointer of a wrapped object.** Every wrapped object is a `defclass` instance
   carrying its underlying ObjC pointer in the inherited `NSObject` `ptr` slot; `->ptr` exposes it
   for APIs the binding does not model. Pass it to your own `define-c-lambda` over `objc_msgSend`.
   You are now responsible for the ObjC retain/release discipline on that pointer — the lifetime
   **will** only tracks wrappers `wrap` created. Use `wrap` / `wrap-borrowed` to bring a raw `id`
   *back* into the class graph (it resolves to the exact bound type, +1 vs borrowed respectively).

2. **A raw typed `define-c-lambda` over `objc_msgSend`.** For a selector with no generated procedure,
   look the selector up via the `runtime/ffi.ss` sel-lookup helper and build a typed `define-c-lambda`
   for `objc_msgSend` (or the struct-return variant) with the right ABI signature, then send the
   message directly. This is also the escape when a generated sibling module fails to load — drop to
   a raw `define-c-lambda` without importing the broken module.

3. **Raw buffers (`buffers = idiomatic-conventional`).** Interior-pointer / caller-allocated buffer
   APIs use raw foreign pointers by convention — a foreign-allocated region passed in and filled in
   place, or the **two-call sizing pattern** (`two-call-sizing`): call once for the length, allocate,
   call again to fill. No bounds checking is enforced.

4. **A pointer-valued constant.** A constant whose value is a runtime address (not a literal) is
   reached via the dylib's symbol surface / a `define-c-lambda` rather than as a Scheme literal — see
   [`../../../docs/reference.md`](../../../docs/reference.md). (Pointer constants are the one constant
   class the trampoline does *not* elide.)

## What you give up

Dropping to a hatch bypasses the binding's compile-time typed marshalling, its registry rooting of
callbacks, the lifetime will's retain/release accounting, the autorelease-pool discipline, and the
main-thread-bounce contract. In particular:

- A raw native callback you hand to ObjC is **not** rooted by the binding's registry — keep its
  Gerbil closure reachable yourself, or the GC may reclaim it while ObjC still holds it. (The
  binding's `make-delegate` / `make-objc-block` do this rooting for you; hand-rolled trampolines do
  not.) Note the native-core trampoline's known limits: it cannot deliver `float`/`double` or
  by-value-struct callback args, and IMP arity caps at 4 method args / blocks at 3.
- Lifetimes are yours: nothing releases what you `retain`/`alloc` outside a wrapper, and the will
  will not fire for a pointer it never wrapped.
- For UI mutation you must hop to the main thread yourself — the binding's main-thread **bounce** is
  not in a raw call's path. Gerbil does not thread-activate (ADR-0022), so a raw call invoked from a
  foreign thread runs on that thread with no marshalling.

## When you shouldn't need a hatch

If the API is Swift-native (`async`/`throws`/value-return) rather than unmodeled ObjC, the binding
*does* model it — through the trampoline-only `APIAnywareGerbil` dylib, not a raw hatch
([`../../../docs/ffi-model.md`](../../../docs/ffi-model.md)). And to receive framework callbacks
(delegate methods, `drawRect:`), prefer **transparent subclassing** (`runtime/subclass`) over a
hand-rolled trampoline — it is the supported, GC-safe path. Reach for a hatch only for genuinely
unmodeled ObjC surface; if you find yourself needing one for a common API, that is a coverage gap
worth filing (see [`api-coverage.md`](api-coverage.md)).

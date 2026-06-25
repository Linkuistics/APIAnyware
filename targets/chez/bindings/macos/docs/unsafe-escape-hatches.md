# chez macOS binding — unsafe escape hatches (§22)

When the binding does not model an API, chez lets you drop below it to raw FFI. This is the
documented, supported way out — but it is **unsafe** in the FFI sense (you take on the memory,
lifetime, and threading obligations the binding otherwise upholds). The escape hatch is the
`unsafe-escape-hatch` idiom in [`../../../idioms/catalogue.apiw`](../../../idioms/catalogue.apiw).

## The hatches, least to most drastic

1. **The raw foreign pointer of a wrapped object.** Every `objc-object` carries its underlying
   pointer; `unwrap` exposes it for APIs the binding does not model. Pass it to your own
   `foreign-procedure` over `objc_msgSend`. You are now responsible for the ObjC retain/release
   discipline on that pointer — the guardian only tracks wrappers it created.

2. **A raw typed `foreign-procedure` over `objc_msgSend`.** For a selector with no generated
   procedure, build a typed `foreign-procedure` for `objc_msgSend` (or the struct-return / fpret
   variant) with the right ABI signature and send the message directly, registering the selector
   with `sel-register` (`runtime/ffi.sls`). This is also the escape when a generated sibling library
   fails to load — drop to a raw `foreign-procedure` without importing the broken library.

3. **Raw buffers (`buffers = idiomatic-conventional`).** Interior-pointer / caller-allocated buffer
   APIs use raw foreign pointers by convention — a `bytevector` or `foreign-alloc`'d region passed
   in and filled in place, or the **two-call sizing pattern** (`two-call-sizing`): call once for the
   length, allocate, call again to fill. No bounds checking is enforced.

4. **A pointer-valued constant.** A constant whose value is a runtime address (not a literal) is
   reached via the dylib's symbol surface / a `foreign-procedure` rather than as a Scheme literal —
   see [`../../../docs/reference.md`](../../../docs/reference.md). (Pointer constants are the one
   constant class the trampoline does *not* elide.)

## What you give up

Dropping to a hatch bypasses the binding's compile-time typed marshalling, its `lock-object`
rooting of callbacks, the guardian's retain/release accounting, the autorelease-pool discipline,
and the thread-activation contract. In particular:

- A raw `foreign-callable` callback you hand to ObjC is **not** rooted by the binding — `lock-object`
  it yourself (and `unlock-object` when done) or the GC may move/collect it while ObjC still holds
  it. It must also be `__collect_safe` if ObjC can invoke it from a foreign thread (ADR-0016).
- Lifetimes are yours: nothing releases what you `retain`/`alloc` outside a wrapper, and the
  guardian will not drain a pointer it never registered.
- For UI mutation you must hop to the main thread yourself — the binding's main-thread dispatch is
  not in a raw call's path.

## When you shouldn't need a hatch

If the API is Swift-native (`async`/`throws`/value-return) rather than unmodeled ObjC, the binding
*does* model it — through the `APIAnywareChez` adapter, not a raw hatch
([`../../../docs/ffi-model.md`](../../../docs/ffi-model.md)). Reach for a hatch only for genuinely
unmodeled ObjC surface; if you find yourself needing one for a common API, that is a coverage gap
worth filing (see [`api-coverage.md`](api-coverage.md)).

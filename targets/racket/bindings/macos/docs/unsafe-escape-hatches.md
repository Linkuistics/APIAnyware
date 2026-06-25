# racket macOS binding — unsafe escape hatches (§22)

When the binding does not model an API, racket lets you drop below it to raw FFI. This is the
documented, supported way out — but it is **unsafe** in the Racket FFI sense (you take on the
memory, lifetime, and threading obligations the binding otherwise upholds). The escape hatch is the
`unsafe-escape-hatch` idiom in [`../../../idioms/catalogue.apiw`](../../../idioms/catalogue.apiw).

## The hatches, least to most drastic

1. **The raw `_cpointer` of a wrapped object.** Every `objc-object?` exposes its underlying
   `_cpointer` via an explicit unsafe accessor, for APIs the binding does not model. Pass it to
   your own `get-ffi-obj` / `objc_msgSend` call. You are now responsible for the ObjC retain/release
   discipline on that pointer.

2. **Raw `tell` / `objc_msgSend`.** For a selector with no generated procedure, send the message
   directly with `tell` (or a typed `get-ffi-obj` msgSend) from `ffi/unsafe/objc`. This is also the
   **documented escape** when a generated sibling module has a load-time error that even a narrow
   `only-in` can't avoid (developer guide, *Requiring generated bindings*) — drop to raw `tell`
   without touching the broken module.

3. **Raw buffers (`buffers = idiomatic-conventional`).** Interior-pointer / caller-allocated buffer
   APIs use unsafe FFI pointers by convention — `make-bytes` passed in and filled in place
   (`buffer-fill`), or the two-call sizing pattern (`two-call-sizing`): call once for the length,
   allocate, call again to fill. No bounds checking is enforced.

4. **A pointer-valued constant.** A constant whose value is a runtime address (not a literal) is
   reached via `dlsym` / a module-level `function-ptr` rather than as a Racket literal — see
   [`../../../docs/reference.md`](../../../docs/reference.md) §7.4/§7.6. (Pointer constants are the
   one constant class the trampoline does *not* elide.)

## What you give up

Dropping to a hatch bypasses the binding's depth-1 marshalling (typed coercion), its GC rooting of
callbacks, the main-thread bounce (ADR-0014), and the autorelease-pool discipline. In particular:

- A raw `_cprocedure` callback you hand to ObjC is **not** GC-rooted by the binding — root it
  yourself or the GC may collect it while ObjC still holds it.
- A raw call on a background thread does **not** auto-bounce to the main thread — you must hop
  yourself for main-thread-only APIs (UI mutation).
- Lifetimes are yours: nothing releases what you `alloc`/`retain` outside the wrapper.

## When you shouldn't need a hatch

If the API is Swift-native (`async`/`throws`/value-return) rather than unmodeled ObjC, the binding
*does* model it — through the `APIAnywareRacket` adapter, not a raw hatch
([`../../../docs/ffi-model.md`](../../../docs/ffi-model.md)). Reach for a hatch only for genuinely
unmodeled ObjC surface; if you find yourself needing one for a common API, that is a coverage gap
worth filing (see [`api-coverage.md`](api-coverage.md)).

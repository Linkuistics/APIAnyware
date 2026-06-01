# 040-nserror-out-params

**Kind:** work

## Goal
The remaining Depth-2 shape split out of leaf 030 (by decision 2026-06-01): route
`NSError **` out-params natively so an erroring method returns
`(values result error)` to Racket instead of threading a caller-allocated
`NSError**` cell through interpreted Racket. The native dispatch entry allocates
the `NSError*` cell, passes `&err` to `objc_msgSend`, and hands back both the
method result and the (retained, or nil) error object in one crossing.

Design: `docs/specs/2026-05-31-racket-native-binding-design.md` §3 Depth 2.

## Context

### Why split from 030
030 (strings + collections) landed with a real local witness (TestKit + a runtime
round-trip smoke) and no emitter/IR changes. `NSError**` is categorically
different and was separated so it gets the attention it needs without bloating
030's commit:
- **No local witness.** The synthetic TestKit framework has no `NSError**` method,
  so the change cannot be validated against the committed golden — only at the
  root-050 real-IR regen + VM-verify.
- **Needs emitter + IR work** the marshalling slices did not: the emitter must
  *detect* an `NSError**` out-param (how the IR spells pointer-to-pointer-to-object
  is the first thing to confirm), suppress it from the Racket wrapper's parameter
  list, route the method through a native entry that owns the `NSError*` cell, and
  reshape the wrapper's result into `(values result error)`.

### Scope (sharpen when picked)
- **Confirm the IR shape** of `NSError **` params (`TypeRefKind` — likely a
  `Pointer` to a `Pointer`/`Id`, or a dedicated kind). Find real witnesses in the
  Foundation/AppKit IR (e.g. `-writeToURL:options:error:`,
  `-executeFetchRequest:error:`).
- **`native_dispatch.rs`:** an `NSError**`-bearing signature needs a native entry
  variant that takes no error arg from ffi2, allocates `NSError* err = nil`
  locally, calls `objc_msgSend(recv, sel, …, &err)`, and returns the result while
  surfacing `err` (e.g. via a trailing out-buffer `ptr_t`, mirroring the
  struct-return out-buffer convention). Decide returned-`NSError*` ownership
  (autoreleased +0 vs retained +1 → Racket finalizer).
- **Emitter (`emit_class.rs`):** drop the `NSError**` param from the generated
  wrapper's arity; emit the `(values result error)` shape; wrap `error` as an
  `objc-object` (or `#f` when nil).
- **Native helper if needed** in `APIAnywareRacket` for the error-cell allocation,
  or fold it into the generated dispatch entry.

## Done when
- A method with an `NSError**` out-param emits a wrapper returning
  `(values result error)`; no caller-allocated `NSError**` cell in interpreted
  Racket.
- `cargo test` green; native side compiles. Real-IR validation + VM-verify is
  root-050.

## Notes
- Coordinate with leaf 060 (fallback deletion): keep this leaf to the *marshalling
  move*; leave broad fallback removal to 060.
- Returned-string/object ownership (+0/+1) discipline established in 030 (ffi2
  `string_t` and `#:retained`) is the precedent for the returned `NSError*`.

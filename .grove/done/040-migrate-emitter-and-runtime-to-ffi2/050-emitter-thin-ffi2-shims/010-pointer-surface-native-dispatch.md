# 010-pointer-surface-native-dispatch

**Kind:** work

## Goal
Route the *pointer-shaped remainder* of ObjC dispatch through the generated native
entries (ADR-0013), collapsing the largest block of remaining in-Racket `tell`
calls into thin one-line ffi2 shims. No new native marshalling — objects and
scalars already cross as `ptr_t`/scalar; this is routing widening + result
wrapping only. The struct and Depth-2 surfaces are sibling leaves 020/030.

Design: `docs/specs/2026-05-31-racket-native-binding-design.md` §2, §3 (Depth 0/1
pointer surface), §6 (`emit_class.rs` dispatch → moves native).

## Scope
- **`emit_method` (`emit_class.rs`):** make the `DispatchStrategy::Tell` branch
  (all-object params + object/void return) route through `native_dispatch_binding`
  when routable — it always is for all-object signatures (`_id` collapses to
  `ptr_t`). Object returns wrap via `ffi2-ptr->id` + `wrap-objc-object` (already
  the pattern in the TypedMsgSend object-return arm); void returns call directly.
  Keep `#:retained` driven by `returns_retained`.
- **`emit_property` getters:** route object getters (`() -> _id`) and scalar
  getters (`() -> <scalar>`) natively, mirroring the setter path that already
  routes. Both instance and class-property getters.
- **`collect_class_native_sigs` (`native_dispatch.rs`):** widen in lockstep so the
  newly-routed signatures (all-object methods, getters) are collected into the
  global set `generate_dispatch_swift` compiles — the emitted `.rkt` and the Swift
  entry table must not drift.
- **Leave `tell` in place only as the non-routable fallback** (struct/string/
  variadic). Full pure-Racket-fallback deletion is leaf 060.

## Out of scope (sibling leaves)
- Struct-by-value params/returns (`frame` etc.) → **020**.
- String / collection / `NSError**` Depth-2 marshalling → **030**.

## Done when
- TestKit golden (`tkbutton.rkt`, `tkview.rkt`) regenerated: `title`,
  `description`, `hidden`, `tag` getters and all-object methods/setters now emit
  `aw_racket_msg_*` native calls; no `tell` remains except genuinely non-routable
  shapes (struct returns like `frame`, pending 020).
- `cargo test -p` for the emit-racket crate green (unit + golden).
- `Dispatch.swift` regenerates and `swift build` compiles it (entry set widened).

## Notes
- `native_call_expr` already bridges `_id`/`_pointer` args via `id->ffi2-ptr`; the
  all-object path needs the same `coerce_id_params` it already calls in the typed
  arm — reuse, don't reinvent.
- Native uses the string selector via `sel_registerName`, which is correct.

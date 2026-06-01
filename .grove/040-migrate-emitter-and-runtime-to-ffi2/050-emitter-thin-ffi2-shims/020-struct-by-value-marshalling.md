# 020-struct-by-value-marshalling

**Kind:** work

## Goal
Route struct-by-value returns and params (the `_NSRect`/`_NSPoint`/`_NSSize`/
`_CGAffineTransform` geometry family) through native dispatch — the §3 "Depth 1"
8× headline (struct return ~90 ns in-Racket → ~11 ns native). Today these are the
`AbiType::from_ffi_unsafe` `None` arm and stay on `tell`/typed `get-ffi-obj`.

Design: `docs/specs/2026-05-31-racket-native-binding-design.md` §2.1 (struct
result is "the whole thesis in miniature"), §3 Depth 1, §6 (`struct_t`).

## Scope
- **`native_dispatch.rs`:** add a struct ABI shape. The Swift `@_cdecl` entry
  takes/returns a Swift struct laid out to match the C struct so `objc_msgSend`'s
  arm64 struct convention (≤16 B in regs; larger via x8 indirect — *no*
  `objc_msgSend_stret` on arm64) is satisfied by the `@convention(c)` cast. The
  ffi2 binding crosses it as a `struct_t` with generated accessors.
- **Content-addressed entry name** must encode the struct identity (not collapse
  to `P`) so distinct struct shapes get distinct entries.
- **`emit_class.rs`:** route struct-returning getters/methods (e.g. `frame`) and
  struct-param methods natively; result becomes a `struct_t` the wrapper hands
  back (or the existing geometry record — coordinate with the runtime
  `type-mapping.rkt` struct reps).
- Confirm the libffi generic escape hatch still covers any struct the emitter
  cannot lay out statically (spec §6 / §8 item 2).

## Done when
- TestKit golden `tkbutton-frame` / `tkview` struct returns emit a native
  `aw_racket_msg_*` struct entry, not `tell`.
- `cargo test` green; `Dispatch.swift` struct entries compile under `swift build`;
  if feasible, a runtime smoke confirming a `CGRect`-shaped return round-trips.

## Notes
- arm64 struct ABI is the subtle part: verify the Swift struct's layout/size puts
  it in the in-register vs x8-indirect path the real method uses. The 010 spike
  (`docs/research/2026-05-31-racket-ffi2-spike/`) measured the struct path and has
  a working C reference for the convention.
- Returned struct ownership is value-copy — no `+0/+1` retain concern (unlike
  object returns).

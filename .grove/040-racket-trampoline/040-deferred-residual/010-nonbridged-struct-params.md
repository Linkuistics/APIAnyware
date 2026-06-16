# 010-nonbridged-struct-params

**Kind:** work

## Goal

Trampoline the **69** functions currently recorded `deferred_nonbridged_struct_param`
— a function with a non-Foundation-bridged Swift `struct`/tuple/existential
**parameter** — so they bind from racket instead of being deferred. (A non-bridged
struct *return* is already handled: it boxes to an opaque `AwValueBox` handle
needing no naming. The gap is the **parameter** side, where the `@_cdecl` body
must spell the concrete Swift type to unbox it, and racket must be able to
*construct* a handle to pass in.)

## Context

- Why deferred (spec §5): calling the API by name needs the `@_cdecl` body to
  `awRacketUnbox(h, as: <NamedType>.self)`, which requires the type be nameable in
  the generated Swift, plus per-field accessors so racket can build the handle.
- Runtime is ready (040/010): `AwValueBox` + `awRacketBox`/`awRacketUnbox` +
  uniform `aw_racket_box_free`. Per-type field/tag accessors
  (`aw_racket_box_<T>_<field>`, `aw_racket_box_<T>_tag`) are the per-type surface
  to generate (spec §2, §3 rows for struct / tuple / payload-enum).
- Codegen: `emit-racket/src/trampoline.rs` (param-marshalling path + accessor
  emission); racket coercers in `runtime/swift-trampoline.rkt` (a handle
  constructor + field readers).

## Done when

- The codegen emits, for each newly-wired decl: the `@_cdecl` trampoline that
  unboxes its named-type param(s), and the `aw_racket_box_<T>_*` accessors racket
  needs to construct/inspect the handle; the emitter binds them.
- A clean `--target racket` generate **reduces** the
  `deferred_nonbridged_struct_param` count (report the before/after); residual
  that still can't be named (e.g. unnameable existentials) stays recorded with a
  reason, not silently dropped.
- Builds green (`swift build` + `cargo test --workspace`, snapshots updated); a
  **real** recovered decl from this bucket resolves and runs from racket
  (extend the 040/030 smoke).

## Notes

- Pick the real exemplar from the actual recovered residual (grep the enriched IR
  for the deferred decls), as 040/030 did — prefer a small concrete struct with
  scalar/bridged fields.
- If "nameable type" turns out underspecified for some shapes, kick back to the
  spec rather than guessing.

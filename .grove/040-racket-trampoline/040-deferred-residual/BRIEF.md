# 040-deferred-residual — brief

**Kind:** node (wire the two deferred buckets the smoke leaf quantified)

## Goal

Wire the two **non-hard** deferred residual buckets that 040/020 recorded with a
reason and counted (spec §5, "defer nothing, but be honest") so they become
trampolined instead of deferred. `unbindable_generic_free_function` (34) is a
**hard** limit (`@_cdecl` cannot be generic) and is explicitly *not* in scope.

As of the 040/030 regen (`--target racket`, 284 frameworks), the deferred counts
were: **69 `deferred_nonbridged_struct_param`**, **34
`unbindable_generic_free_function`**. The `async` bucket is recorded as
`deferred_async` (count surfaced per generate run).

## Context

- The runtime substrate these leaves bind against is **already built** (040/010):
  `OpaqueHandle.swift` (`AwValueBox`, `awRacketBox`/`awRacketUnbox`, the uniform
  `aw_racket_box_free`), `AsyncBridge.swift` (`awRacketAsyncDispatch`,
  `AwAsyncOutcome`, main-thread delivery), `ThrowsBridge.swift`. What's missing is
  the **codegen + emitter wiring**, not the runtime.
- Design of record: **ADR-0027** + `docs/specs/2026-06-15-racket-trampoline.md`.
  Spec §3 has the marshalling taxonomy (box rep, async row), §5 names both
  buckets as follow-up-leaf work, §6a the known-good exemplars.
- Codegen home: `generation/crates/emit-racket/src/trampoline.rs`
  (`collect_trampolines` / `generate_trampolines_swift`); emitter wiring in
  `emit_functions.rs` / `emit_constants.rs`; racket-side coercers in
  `generation/targets/racket/runtime/swift-trampoline.rkt`.

## Done when

- Both children are done: non-bridged struct params trampoline through named-type
  unbox + per-field accessors; async functions trampoline through the callback
  `@_cdecl` + racket `_cprocedure` main-thread binding.
- Each clean generate **reduces** the corresponding deferred count (and the
  reduction is reported, not silent); whatever genuinely cannot be wired stays
  recorded with a reason.
- Builds green (`swift build` + `cargo test --workspace`, snapshots updated); a
  real residual decl from each newly-wired bucket resolves and runs from racket
  (the 040/030 smoke pattern, extended).

## Children

- **010-nonbridged-struct-params** — the 69-decl bucket: `@_cdecl` bodies that
  unbox a *named* Swift struct/tuple/existential parameter, plus the per-type
  `aw_racket_box_<T>_*` field accessors the racket side needs to construct one.
- **020-async-functions** — the `deferred_async` bucket: generate the
  completion-callback `@_cdecl` shape over `awRacketAsyncDispatch`, bind it from
  racket via a main-thread-aware `_cprocedure`.

## Notes

- Racket-only (ADR-0011); chez (060) / gerbil (070) inherit nothing here.
- If a bucket turns out larger than one focused leaf, decompose that child rather
  than overrunning the session.
- If the build reveals the spec underspecified, kick back to update the spec (the
  040/030 pattern), don't guess.

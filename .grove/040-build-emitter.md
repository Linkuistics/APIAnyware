# 040-build-emitter

**Kind:** work

## Goal

Build the `emit-sbcl` crate (guide Step 2 + 5): `TargetInfo` (`id: "sbcl"`,
`display_name: "SBCL"`, `generated_subdir`) + `TargetEmitter::emit_framework`,
`SbclFfiTypeMapper`, naming (ObjC selector → CLOS generic-fn names per the
contract), method_filter, and `emit_class`/`emit_protocol`/`emit_enums`/
`emit_constants`/`emit_functions`. Statically emits the CLOS class graph
(`defclass … :metaclass objc-class` + per-selector receiver-specialized generics
per **D6**). Register in `cli/src/registry.rs`; `--target sbcl` works.
Snapshot/inline emission tests.

**Complete-API model (post-2026-06-20 reset):** the emitter consumes the shared
`objc_exposed` IR fact and derives the **direct-vs-trampoline boundary** per
ADR-0026 — ObjC bound directly (`sb-alien` `objc_msgSend`, trampoline elided),
`objc_exposed == false` residual routed to `libAPIAnywareSbcl` C-ABI trampolines,
unrepresentable residual skipped. The constant sub-rule (literal vs runtime-read
vs trampoline) follows ADR-0026 §3.

## Context

Refined by **030-design** before this is picked. Read the 030 design spec + the
contract spec + ADR-0026 (`objc_exposed` emitter contract) + the racket trampoline
spec (`docs/specs/2026-06-15-racket-trampoline.md`). Reference impls: `emit-chez`,
`emit-gerbil` (compiled-FFI peers; both now emit the `objc_exposed`-driven split).

## Done when

- Crate compiles, registered, `--target sbcl` + `--list-targets` work; tests pass.
- Emits source conforming to the CL-family contract.

## Notes

- Likely decomposes (per-emit-module leaves) when picked.

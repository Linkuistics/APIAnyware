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

Also emits the **`run_sbcl_trampolines` global pass** (model on
`run_gerbil_trampolines`) → gitignored
`swift/Sources/APIAnywareSbcl/Generated/Trampolines.swift`, and routes
`objc_exposed == false` decls to content-addressed `aw_sbcl_*` bindings
(`aw_sbcl_swift_<Fw>_<name>` / `_const_` / `_m_<Owner>_<base>` / `_init_<Owner>`,
ADR-0038 §2 / racket spec §2,§8.4 — reconstructed with no shared counter). The
residual reproduces the **§6d invariant exactly** (51 fn + 7 const + 576 init + 554
method), inheriting the B1–B5 swift-residual close through the shared IR.

## Context

Design settled in **030-design** — read the SBCL target design spec
(`generation/targets/sbcl/docs/design/2026-06-20-sbcl-target-design.md`) + the
CL-family contract spec + ADR-0026 (`objc_exposed` emitter contract) + ADR-0034
(the CLOS surface to emit) + ADR-0038 (the trampoline lower layer) + the racket
trampoline spec (`docs/specs/2026-06-15-racket-trampoline.md`, the marshalling
taxonomy + method frontier §8/§9). Reference impls: `emit-chez`, `emit-gerbil`
(compiled-FFI peers; both emit the `objc_exposed`-driven split).

## Done when

- Crate compiles, registered, `--target sbcl` + `--list-targets` work; tests pass.
- Emits source conforming to the CL-family contract.

## Notes

- Likely decomposes (per-emit-module leaves) when picked.

# 040-build-emitter — brief

**Kind:** node (decomposed 2026-06-20 — per-emit-module leaves, as the original
leaf anticipated)

## Goal

Build the `emit-sbcl` crate (guide Step 2 + 5): `TargetInfo` (`id: "sbcl"`,
`display_name: "SBCL"`, `generated_subdir`) + `TargetEmitter::emit_framework`,
`SbclFfiTypeMapper`, naming (ObjC selector → CLOS generic-fn names per the
contract), method_filter, and the construct emitters. Statically emits the CLOS
class graph (`defclass … :metaclass objc-class` + per-selector receiver-specialized
generics per **D6**, ADR-0034) and routes the `objc_exposed == false` residual to
`libAPIAnywareSbcl` trampolines + the `run_sbcl_trampolines` global pass (ADR-0038).
Register in `cli/src/registry.rs`; `--target sbcl` + `--list-targets` work.

## Decomposition (dependency-ordered; each leaf ends green — `cargo test` passes)

The module split follows ADR-0034 §Consequences (`040` emits class graph / generics
/ slot specs / baked tables, needs **none** of gerbil's generics-sharding) and
ADR-0038 §"Leaf split" (`040` routes `objc_exposed == false` + emits the
`run_sbcl_trampolines` pass). Reference module sizes from `emit-gerbil` in parens.

- **010-scaffold-types-naming** — crate scaffold (`Cargo.toml`, `lib.rs`),
  `SBCL_TARGET_INFO` + `SbclEmitter` skeleton, `SbclFfiTypeMapper` (`sb-alien`
  type mapping; ~ffi_type_mapping 655), `naming.rs` (ObjC selector → `ns:`
  acronym-aware kebab-case generic names + class names, contract §3.1/§3.2;
  ~naming 234), `method_filter.rs` (~317). Register in `cli/src/registry.rs`.
  `--target sbcl`/`--list-targets` work. Unit tests for naming + ffi mapping.
  *Foundation — every later leaf imports these.*
- **020-object-model** — `class_graph.rs` (reify ObjC ancestor chain; ~313) +
  `emit_class.rs` (`defclass … :metaclass objc-class`, foreign slot specs with
  baked offsets/ctypes, baked Class/SEL string tables; ~2792) + `emit_generics.rs`
  (one `defgeneric` per selector in `ns:`, one `defmethod` per class×selector
  specialized on receiver, the direct-`objc_msgSend` `sb-alien` dispatch + the
  `objc_exposed == false` method residual handoff; ~403). The ADR-0034 core; **no**
  sharding/flags/parallel-compile. Snapshot tests.
- **030-protocols** — `emit_protocol.rs` + cross-framework `ProtocolRegistry`
  (gerbil flattens conformed-protocol methods via its own conformance closure;
  ~370+167). Snapshot tests.
- **040-enums-constants-functions** — `emit_enums.rs` (~274) + `emit_constants.rs`
  (constant sub-rule: literal vs runtime-read-dlsym vs trampoline, ADR-0026 §3;
  ~553) + `emit_functions.rs` (top-level funcs, `objc_exposed` direct/trampoline
  split; ~800). Snapshot tests.
- **050-trampolines** — `trampoline.rs`: route `objc_exposed == false` decls to
  content-addressed `aw_sbcl_*` bindings (`aw_sbcl_swift_<Fw>_<name>` / `_const_` /
  `_m_<Owner>_<base>` / `_init_<Owner>`, ADR-0038 §2 / racket spec §2,§8.4 —
  reconstructed with no shared counter) + the `run_sbcl_trampolines` global pass →
  gitignored `swift/Sources/APIAnywareSbcl/Generated/Trampolines.swift` (model on
  `run_gerbil_trampolines`). Reproduce the **§6d invariant exactly** (51 fn + 7
  const + 576 init + 554 method), inheriting B1–B5 through the shared IR
  (~trampoline 3286 + shared_signatures 173). Residual-count tests.
- **060-orchestration-goldens** — wire `emit_framework` fully (facade / per-fw
  `main` re-export, `SubModule` collection + collision-rename; ~776), golden
  fixtures (testkit + foundation, mirroring gerbil), full snapshot/runtime-shape
  tests, end-to-end §6d invariant verification. The integration + done-bar leaf.

## Context

Design settled in **030-design** — read the SBCL target design spec
(`generation/targets/sbcl/docs/design/2026-06-20-sbcl-target-design.md`) + the
CL-family contract spec (`docs/specs/2026-06-20-cl-family-interface-contract.md`) +
ADR-0026 (`objc_exposed` emitter contract) + ADR-0034 (the CLOS surface to emit) +
ADR-0038 (the trampoline lower layer) + the racket trampoline spec
(`docs/specs/2026-06-15-racket-trampoline.md`, the marshalling taxonomy + method
frontier §8/§9). Reference impls: `emit-chez`, `emit-gerbil` (compiled-FFI peers;
both emit the `objc_exposed`-driven split).

## Done when (node)

- Crate compiles, registered, `--target sbcl` + `--list-targets` work; tests pass.
- Emits source conforming to the CL-family contract.
- The Swift-native residual reproduces the §6d invariant exactly.

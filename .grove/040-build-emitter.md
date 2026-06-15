# 040-build-emitter

**Kind:** work

## Goal

Build the `emit-sbcl` crate (guide Step 2 + 5): `TargetInfo` (`id: "sbcl"`,
`display_name: "SBCL"`, `generated_subdir`) + `TargetEmitter::emit_framework`,
`SbclFfiTypeMapper`, naming (ObjC selector → CLOS generic-fn names per the
contract), method_filter, and `emit_class`/`emit_protocol`/`emit_enums`/
`emit_constants`/`emit_functions`. Statically emits the CLOS class graph
(`defclass … :metaclass objc-class` + per-selector generics) per D3. Register in
`cli/src/registry.rs`; `--target sbcl` works. Snapshot/inline emission tests.

## Context

Refined by **030-design** before this is picked. Read the 030 design spec + the
contract spec. Reference impls: `emit-chez`, `emit-gerbil` (compiled-FFI peers).

## Done when

- Crate compiles, registered, `--target sbcl` + `--list-targets` work; tests pass.
- Emits source conforming to the CL-family contract.

## Notes

- Likely decomposes (per-emit-module leaves) when picked.

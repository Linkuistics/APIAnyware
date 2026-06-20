# 010-scaffold-types-naming

**Kind:** work

## Goal

Stand up the `emit-sbcl` crate skeleton + the two foundation modules every later
leaf imports:

- **Crate scaffold:** `generation/crates/emit-sbcl/Cargo.toml` (peer
  `emit-gerbil`'s deps), `src/lib.rs` declaring the module tree, `SBCL_TARGET_INFO`
  (`id: "sbcl"`, `display_name: "SBCL"`, `generated_subdir: "generated"` — confirm
  vs chez's `"apianyware"`; SBCL has no library-path-resolution constraint like
  chez, so `"generated"` is the default, but check the 050 runtime's load path
  expectation captured in any inbox note), and an `SbclEmitter` struct implementing
  `TargetEmitter` with `emit_framework` as a minimal stub (writes the framework
  dir; construct emitters land in later leaves).
- **`SbclFfiTypeMapper`** (`src/ffi_type_mapping.rs`) — ObjC/C `TypeRef` →
  `sb-alien` alien type spelling (`(sb-alien:* (sb-alien:* t))`, `sb-alien:int`,
  `sb-alien:double`, struct-by-value `(sb-alien:struct CGRect …)`, `c-string`,
  etc.). Compiled-FFI shape (ADR-0015), peer `emit-gerbil`'s `ffi_type_mapping.rs`
  but `sb-alien` spellings not `define-c-lambda` c-types. Reuse the shared
  `emit::ffi_type_mapping` helpers where they apply.
- **`naming.rs`** — the contract §3.1/§3.2 name mapper: `NSOpenGLView` →
  `ns:ns-opengl-view`, acronym-aware whole-word kebab-case (shared acronym table —
  do NOT split per capital; the naive rule is refuted, contract §3.1), selector →
  generic-fn symbol + keyword-list arglist
  (`nextEventMatchingMask:untilDate:inMode:dequeue:` → generic `ns:next-event-…`
  with `(:next-event-matching-mask :until-date :in-mode :dequeue)`), class-name
  symbols, the `ns:` package prefix. Reuse `emit::naming` shared helpers.
- **`method_filter.rs`** — port `emit-gerbil`'s filter (skip unbindable/dup
  selectors) adapted to the CLOS surface.
- **Register** `SbclEmitter` in `cli/src/registry.rs`; add `registry_contains_sbcl`
  + `format_target_list` assertions mirroring the gerbil tests.

## Context

Foundation leaf — see node BRIEF + the SBCL design spec §6 (contract conformance
table maps §3.1 → emitter naming, §3.2 → per-selector generics). Reference:
`emit-gerbil/src/{naming.rs,ffi_type_mapping.rs,method_filter.rs,lib.rs}` and the
shared `emit` crate (`naming.rs`, `ffi_type_mapping.rs`). Contract spec §3.1/§3.2.

## Done when

- `cargo build -p apianyware-macos-emit-sbcl` compiles; crate registered.
- `cargo run -p …-cli -- --list-targets` shows `sbcl  SBCL`; `--target sbcl` runs
  (emits framework dirs, no constructs yet — that's fine).
- Unit tests: naming (acronym runs, multi-component selectors → keyword lists) +
  ffi mapping (representative scalars/pointers/structs) pass.

## Notes

- Decide `generated_subdir` deliberately and record the reason inline (CONTEXT.md
  if it becomes a glossary-worthy convention).

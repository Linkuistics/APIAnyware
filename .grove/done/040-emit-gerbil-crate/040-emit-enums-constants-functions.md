# 040-emit-enums-constants-functions

**Kind:** work

## Goal

Write the three "data" emitters — `emit_enums.rs`, `emit_constants.rs`,
`emit_functions.rs` — in idiomatic Gerbil, and wire all three into
`emit_framework`. Completes the node: with this leaf the crate emits every
construct family.

## Context

Node brief + design spec §2 (idiom). Reference: `emit-chez/src/emit_enums.rs`,
`emit_constants.rs`, `emit_functions.rs`. Foundation from 010 (`ffi_type_mapping`,
`shared_signatures` for the framework→shared-object arg + libdispatch-unexported
skip list). `:std/foreign` `define-c-lambda`/`c-declare` is the Gerbil analogue
of chez's `foreign-procedure`/`foreign-entry`.

## Done when

- **Enums** (`emit_enums.rs`): one module defining every enum value as a Gerbil
  `(define <name> <value>)`, grouped by enum with a comment header. Handle the two
  hazards chez documents, adapted to Gerbil's module/import semantics:
  (1) values colliding with imported bindings — Gerbil's default imports differ
  from `(chezscheme)`, so re-derive which names are unsafe and how to keep the
  enum body a fresh namespace; (2) duplicate case names across enums — collapse
  when the value is identical, prefix with `<enum-type>-` when it differs.
  `enum_value_names` helper for the `main` re-export.
- **Constants** (`emit_constants.rs`): the three flavours — pointer-typed globals
  (deref once), struct-typed globals (address is the struct), and CFSTR macros
  (build a retained NSString at load via the runtime's string→nsstring helper).
  Express each via `:std/foreign` (`define-c-lambda`/`c-declare` reading the
  `c-initialized-global`/symbol address), not chez's `foreign-ref`/`foreign-entry`.
  `constant_names` helper.
- **Functions** (`emit_functions.rs`): one `define-c-lambda` per emittable C
  function; skip inline (no symbol) and variadic (fixed arity). Use the 010
  framework→shared-object arg and libdispatch-unexported skip list.
  `count_emittable` + `function_emittable_names` helpers.
- `emit_framework` writes `enums`/`constants`/`functions` modules (only when
  non-empty) and adds their exports to the `main` re-export — completing the
  orchestrator. The node's full Done-when (040 BRIEF) is satisfied: `cargo build
  -p apianyware-macos-emit-gerbil` green, `cargo test` green.
- Unit tests mirror chez's per-file tests (an enum with a collision, each
  constant flavour, an emittable + a skipped function).

## Notes

The runtime's string→nsstring / retain helpers (for CFSTR constants) are 050's;
emit against the agreed name and **inbox-add to 050** if unsettled. This is the
last child of node 040 — on retiring it, the node 040 retires too (the parent
chain check); promote any layout/contract decisions worth keeping into the design
spec or an ADR before the node moves to `done/`.

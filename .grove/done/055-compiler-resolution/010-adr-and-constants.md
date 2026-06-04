# 010-adr-and-constants

**Kind:** work

## Goal

Land the umbrella-header decision (see node BRIEF) as **ADR 0021** and convert the
**constants** emitter to it, proving the result compiles under the bottle's
default gcc-15.

## Tasks

1. **ADR** `docs/adr/0021-gerbil-emit-c-decls-not-umbrella-headers.md` — decision
   (option b), the three rejected alternatives + why (gcc-15 bottle, brittle
   `-cc clang` `_main`, chez-symbol-by-name evidence), and the proven mechanism
   (extern-decl shapes + token→C-type table + geometry split). Mark §4 superseded.
2. **token→C-type helper** in `emit-gerbil/src/ffi_type_mapping.rs` (shared with
   020's functions work): `pub fn c_type_for_token(tok: &str) -> &'static str`
   per the table in the node BRIEF.
3. **convert `emit_constants.rs`** — drop the umbrella `#include`; emit one
   `(c-declare "extern …;")` per non-CFSTR constant (object → `void * const`,
   struct-addr → `const char`, scalar → `c_type_for_token`). Update the module
   doc-comment and the unit tests (they currently assert `#include <…>`).
4. **prove** — drive the converted `generate_constants_file` with a handful of
   **real** Foundation constant names (object + scalar flavours), write the output
   to a `.ss`, and compile+link it under gcc-15 (`-framework Foundation`), no
   `-cc clang` / `-x objective-c`. Capture the green run in the ADR.
5. **reconcile** design spec §4 (point it at ADR 0021), and add the toolchain
   note to `lib/runtime/README.md` (the "Compiler note" currently says 055 will
   resolve it) + a one-line pointer for node 060 ("default compiler, no flags").

## Done when

- ADR 0021 committed; emit_constants emits no umbrella `#include`; its tests pass;
  a real-Foundation constants module compiles+runs under gcc-15 (evidence in ADR).
- §4 + README + 060-note updated.

## Notes

cargo test for emit-gerbil must stay green. The gcc-15 build recipe is in
`lib/runtime/README.md` (PATH to the 0.18.2 bottle + SDKROOT). Leave functions +
geometry to 020 (the emitter is allowed to be half-converted between leaves).

# 040-emit-gerbil-crate

**Kind:** work

## Goal

Create the `emit-gerbil` emitter crate (`generation/crates/emit-gerbil/`),
modelled on `emit-chez` (NOT `emit-racket` — gerbil keeps the crossing in Gerbil,
ADR-0017), emitting maximally-idiomatic Gerbil from the enriched IR.

## Context

Design: `docs/specs/2026-06-03-gerbil-target-design.md`. The emitter resembles
`emit-chez` (per-signature FFI emission, no generated Swift dispatch table, no
`swift build` step). Reference: `generation/crates/emit-chez/src/` — `emit_class.rs`,
`emit_protocol.rs`, `emit_enums.rs`, `emit_constants.rs`, `emit_functions.rs`,
`emit_framework.rs`, `ffi_type_mapping.rs`, `naming.rs`, `method_filter.rs`,
`shared_signatures.rs`.

## Done when

- `emit-gerbil` crate compiles and is wired into the workspace.
- Emits per the design spec:
  - **Dispatch (ADR-0017):** one typed `define-c-lambda` per distinct method ABI
    signature (reuse the `shared_signatures` dedup approach), inline-cast
    `objc_msgSend` bodies, `___CAST`/`___return` for `const` returns (FINDINGS §1).
  - **`begin-ffi`** blocks with C-safe headers (`<objc/runtime.h>`,
    `<objc/message.h>`, CoreGraphics); FFI unit compiled `-x objective-c` (§4).
  - **Object model (ADR-0018):** procedure namespaces over the single `objc-obj`
    handle struct; opt-in `:std/generic` veneer (`(defmethod (sel (o objc-obj)) …)`).
  - **Error model:** `(values result error)` for trailing-`NSError**` methods
    (ADR-0006 applied to gerbil).
  - Enums/constants/functions in idiomatic Gerbil.
  - Module/package layout: a binding **library** (`.ssi`+`.o1`), per-class files,
    a `main` re-export (cross-target on-disk symmetry, CONTEXT.md).
- Naming conventions settled (`naming.rs`): selector → Gerbil identifier mapping.

## Notes

May decompose into a node (class/protocol/enum/const/function emitters) when a
single session is too big. ffi_type_mapping is the Gerbil analogue of chez's —
arm64 width aliases, struct-by-value (`(c-define-type CGRect (struct "CGRect"))`,
by-value args, FINDINGS §4).

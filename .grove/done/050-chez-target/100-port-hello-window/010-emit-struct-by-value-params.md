# 010-emit-struct-by-value-params

**Kind:** work

## Goal
Lift the emit-chez method-filter restriction that defers all
struct-by-value params/returns. After this leaf, every known-geometry
typedef (NSPoint, NSSize, NSRect, NSRange, NSEdgeInsets,
NSDirectionalEdgeInsets, NSAffineTransformStruct, CGPoint, CGSize,
CGRect, CGAffineTransform, CGVector) is allowed as a param or return
in emitted method/property bindings. Non-geometry structs stay blocked
(no ftype in `runtime/types.sls`).

## Context
- `generation/crates/emit-chez/src/method_filter.rs` — the filter; its
  current `is_struct_value` returns true for any struct, blocking
  geometry too. Rename to `is_unsupported_struct` and reverse the
  geometry case.
- `generation/crates/emit-chez/src/emit_class.rs` — pre-filters
  properties on `mapper.is_struct_type(...)`; same fix shape
  (`is_unsupported_struct_property`). `emit_property` has the same
  guard; lift it too.
- `generation/crates/emit-chez/src/ffi_type_mapping.rs` —
  `is_known_geometry_alias` is the predicate to compose against;
  already produces `(& <Ftype>)` for these names. No change here.
- `generation/targets/chez/runtime/types.sls` — defines the ftypes and
  `make-nsrect` etc. that callers will pass in. No change here.
- Design spec §3 (emitted-class form) — the sketch shows
  `(& NSRect)` in the foreign-procedure signature and the rect param
  passed through without coercion. The emitter already does the right
  thing for non-class/id/selector params — they fall to `var.to_string()`
  in `coerce_arg_expr`. No call-site change needed.

## Done when
- `is_supported_method` admits geometry-aliased struct params and
  returns; rejects non-geometry struct params and returns; existing
  block + variadic + deprecated + Swift-paren + unsupported-pointer
  guards still apply.
- The 48 emit-chez unit tests still pass.
- `cargo run -p apianyware-macos-generate -- --lang chez` from the
  worktree root regenerates the chez tree cleanly.
- Spot-check: `generated/appkit/nswindow.sls` exports
  `make-nswindow-init-with-content-rect-style-mask-backing-defer`;
  `generated/appkit/nstextfield.sls` exports
  `make-nstextfield-init-with-frame`. Both have `(& NSRect)` in their
  `foreign-procedure` signature and pass the rect param through with
  no `coerce-arg` wrapper.
- `chez --script generation/targets/chez/runtime/verify.ss` still
  prints `[runtime scaffold] loaded` (sanity check; the runtime
  doesn't depend on emitter output but a regen could mass-disturb
  generated files).

## Notes
- The 080 leaf was supposed to address this per the cited comment but
  retired with constants/enums/functions/protocols only. The 080 done
  state is fine — this is a follow-up scoped to the geometry slice.
- Block-typed params and arbitrary structs remain blocked. Block
  bridging is the 130/note-editor leaf's runtime; arbitrary structs
  will land if/when the IR surfaces one we care about (currently
  none on the hello-window path).
- This is a regen-aggressively leaf
  ([[feedback-regenerate-pipeline-aggressively]]): rerun the chez
  emitter in full, don't trust stale checkpoints.

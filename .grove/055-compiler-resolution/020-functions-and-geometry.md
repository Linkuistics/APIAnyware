# 020-functions-and-geometry

**Kind:** work

## Goal

Finish the option-(b) emitter conversion (ADR 0021): the **functions** emitter and
the **geometry** struct declarations, so every emitted module — not just constants
— compiles under the default gcc-15 with no umbrella `#include`.

## Tasks

1. **convert `emit_functions.rs`** — drop the umbrella `#include`; emit one
   synthesized prototype per function `(c-declare "extern <C(ret)> NAME(<C(arg)>…);")`
   using the shared `c_type_for_token` (010). Keep the short `"NAME"` body. Emit
   `(c-declare "#include <stdbool.h>")` once if any slot is `bool`. Update tests
   (they assert `#include <umbrella>`).
2. **geometry** in `ffi_type_mapping.rs` + wherever class/function modules emit the
   geometry prelude (`geometry_decl`, `emit_class.rs`): keep the **CoreGraphics**
   `#include`s (C-safe, gcc-15-clean); for the four **NS-prefixed** structs emit an
   **inline plain-C tagged typedef** instead of the non-C-safe NS header —
   `_NSRange{unsigned long location,length}`, `NSEdgeInsets{double top,left,bottom,
   right}`, `NSDirectionalEdgeInsets{double top,leading,bottom,trailing}`,
   `NSAffineTransformStruct{double m11,m12,m21,m22,tX,tY}`. Verify each field
   layout against the SDK header (ABI-exact) before baking it in.
3. **prove** — drive the converted `generate_functions_file` with real Foundation
   functions (object + a geometry one if available) and an NS-geometry-bearing
   case; compile+link under gcc-15. Confirm the smoke suite
   (`lib/runtime/tests/run-smokes.sh`) still passes — smoke-geometry exercises the
   NS path.
4. **emit-gerbil `cargo test` green**; no `#include <Foundation/…>` /
   `<AppKit/…>` left anywhere in emitted output.

## Done when

- emit_functions + geometry emit no framework umbrella `#include`; all emit-gerbil
  tests pass; a real functions.ss and an NS-geometry case compile under gcc-15.
- The whole emitter is option-(b)-consistent — 060/070 can build with the default
  compiler.

## Notes

The inline NS-geometry typedefs are the one ABI-risk: get the field order/width
right (CGFloat=double, NSUInteger=unsigned long on arm64). 050/040's
smoke-geometry + a standalone `cc` probe are the cross-check.

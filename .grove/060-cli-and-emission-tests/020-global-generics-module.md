# 020-global-generics-module

**Kind:** work

## Goal

Fix the cross-module generic-unification unsoundness (escalated from leaf 050/040):
emit a **single shared generics-declaration module** holding the global selector set,
so a selector name shared by two unrelated classes (`count`, `title`, …) is ONE
`:std/generic` generic that every class extends — not N colliding per-module generics.

## Context

Today `emit_class::emit_surface_decls` writes `(g:defgeneric <sel>)` in **each** class
module. Two unrelated classes sharing a selector therefore export the same identifier
from different modules; the framework facade's re-export clashes/collapses. Surfaces
only at the full emitted-framework build — single-class runtime smokes can't see it.

Sound fix = the cross-framework `ClassRegistry` analogue (this node's BRIEF → 020):
a `GenericsRegistry` built once over all loaded frameworks in the **same CLI pre-pass**
(leaf 010), emitting one global `generics.ss` (package path `:gerbil-bindings/generics`)
that declares `(g:defgeneric <sel>)` for the union of instance-surface selectors and
exports them. `emit_class` **imports** that module instead of declaring per-module
generics; its `g:defmethod`s extend the shared generic; class modules and the facade
re-export the shared names (one origin → no facade clash).

Depends on 010 (the pre-pass + the `with_…` constructor seam exist by then).

## What to do

- `emit-gerbil`: a `GenericsRegistry` (global instance-surface selector set) +
  `generate_generics_module()` emitter. Decide the write path — the global module is
  cross-framework, so it is written once by the CLI pre-pass / a whole-program hook,
  not per-framework `emit_framework`.
- `emit_class`: replace `emit_surface_decls`' per-module `(g:defgeneric …)` with an
  import of `:gerbil-bindings/generics` + the shared-name re-export. Keep the
  `(declare (inline))` fast-path and the `g:defmethod` surface.
- Cosmetic alongside (ADR-0019): reconcile the illustrative `wrap-objc-obj` spelling
  to `wrap`.

## Done when

- A golden test over two unrelated classes sharing a selector asserts a **single**
  `(g:defgeneric <sel>)` declaration site (in `generics.ss`), and both class modules
  import + extend it rather than re-declaring.
- Existing `emit-gerbil` unit tests updated to the shared-module shape and green.
- `cargo test -p apianyware-macos-emit-gerbil -p apianyware-macos-generate` green.

## Notes

⚠️ Compile-correctness of the emitted Gerbil re-export spelling is not provable until
the full-framework build at sample-app time (090) — keep the shared-module structure
minimal and faithful to the 050 smoke patterns that already compiled.

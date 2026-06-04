# 030-manifest-class-graph

**Kind:** work

## Goal

Emit the **manifest ObjC class graph** as a Gerbil `defclass` hierarchy
(ADR-0020) — the structural foundation the dispatch surfaces (040) and the error
model (050) hang on. This replaces leaf-010's single-`objc-obj` handle.

## Done when

- **Type graph build:** from the union of *bound* classes and their **full ObjC
  ancestor chains** (`Class.ancestors` + `superclass` in the IR), construct the
  reified hierarchy. Intermediate ancestors we bind no methods of are included as
  **bare `defclass` nodes** carrying only the inheritance link (matches Apple's
  documented graph — ADR-0020 rationale). Ancestors not separately collected get
  a synthesized bare node.
- **Emission:** each class emits `(defclass (<Class> <Superclass>) (…slots…))`
  once, in its **owning framework's** module. The single runtime-owned `NSObject`
  root carries the `ptr` slot (+ the ADR-0019 lifetime will); subclasses inherit
  it. A parent in another framework ⇒ the class module **imports** the parent's
  module (cross-framework ancestry, like the proc modules importing the runtime).
- **No duplicate definitions:** a class is defined by its owner; modules that
  reference it only as an ancestor import it.
- **Wrap registry:** emit the class-name↔Gerbil-type **registry** entries the
  wrap boundary uses (runtime owns `object_getClass` + lookup; emitter emits the
  registration so a returned `id` wraps as its **exact** bound type, with the
  runtime falling back to the nearest bound ancestor when a class is unbound).
- **Subclassing metadata:** each `defclass` carries its **ObjC class name** so the
  runtime synthesis bridge (node 050) can `objc_allocateClassPair` against the
  right superclass. (Emitter side of transparent subclassing — ADR-0020; the
  shadowing `defclass`/`defmethod` + IMP trampolines are the runtime's.)
- Wired into `emit_framework`; crate compiles; tests cover: a 3-deep chain with an
  **unbound intermediate** emitted as a bare node; correct parent links; the root
  `ptr` slot inherited; a registry entry; a cross-framework parent import.

## Context

ADR-0020 (object model), §3a. The class-plan/dedup machinery from leaf 010
(`build_class_plan`, `effective_methods`, etc.) is reused. The IR `Class` carries
`ancestors` (ordered superclass chain) + `superclass` (immediate). Reference:
how chez emits its hierarchy is N/A (chez has no graph) — this is gerbil-specific;
the closest prior art is racket's runtime class registry. Inbox-note node 050 for
the runtime `NSObject` root + `ptr` accessor + registry-registration entry names.

## Notes

Settle the module/inheritance import shape early — leaf 040 (surfaces) and the
runtime both depend on it. Decide whether the registry is one entry per class
emitted inline, or a per-framework registration table.

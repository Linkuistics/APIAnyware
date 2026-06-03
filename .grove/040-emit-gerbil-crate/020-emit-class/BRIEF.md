# 020-emit-class — brief

## Decomposition (decided in-session, leaf 020 bootstrap)

One session can't carry dispatch + per-signature dedup + proc-core + veneer +
constructors + properties + the `(values result error)` error model at quality —
the error model alone depends on shared enrichment machinery
(`class_error_selectors` / `is_error_out_routable` in `emit-racket`'s
`native_dispatch`, or the `emit` crate) plus a runtime contract, and the veneer
doubles per-method emission. Split into two child leaves, each green at commit:

- **010-dispatch-proc-core** — the procedural binding: the class plan/exports/dedup
  machinery (ported from chez), the `begin-ffi` dispatch block (per-signature
  `define-c-lambda` dedup, inline-cast `objc_msgSend`, `___CAST`/`___return` for
  const returns, struct-by-value `c-define-type`s), the proc-core procedures over
  `objc-obj`, constructors (default + explicit), and properties (getter/setter).
  Wired into `emit_framework`; crate compiles; tests cover a method, a
  struct-returning method, a property, the default + an explicit constructor.
- **020-veneer-and-errors** — the layers on top: the opt-in `:std/generic`
  `(defmethod (sel (o objc-obj)) …)` veneer over each emitted proc (+ export
  wiring), and the `(values result error)` error model for trailing `NSError**`
  methods (`method_filter` adjustment + in-Gerbil out-param `define-c-lambda`
  shape + the `nserror` runtime contract, inbox-noted to 050).

The Done-when below is the **union** of the two children's done-bars (the
040-node acceptance for the class emitter).

## Goal

Write `emit_class.rs` — the dispatch core of the emitter. One ObjC class →
one Gerbil module of: per-signature `define-c-lambda` msgSend bindings, a
procedural-core procedure per emitted method over the single `objc-obj` handle,
constructors, properties, and the opt-in `:std/generic` veneer. Wire it into
`emit_framework` (the class loop + the `main` re-export entry).

## Context

Node brief + design spec §3 (dispatch), §3a (object model), §4 (FFI compilation).
ADR-0017 (per-signature `define-c-lambda`, ObjC-in-gsc core), ADR-0018 (procedural
core + `:std/generic` veneer over one `objc-obj`), ADR-0006/§error-model
(`(values result error)`). Reference: `emit-chez/src/emit_class.rs` (1,208 lines —
`build_class_plan`, `collect_exports`, `dedupe_across_categories`, `emit_method`,
`emit_constructor`, `emit_default_constructor`, `emit_property`, the
returns-retained / init-family logic). Foundation from leaf 010
(`naming`, `ffi_type_mapping`, `method_filter`, `shared_signatures`).

## Done when

- `generate_class_file(cls, framework) -> String` and `class_exports(cls) ->
  Vec<String>` exist (the two entry points `emit_framework` calls), mirroring
  chez's `generate_class_file_with_exports` single-pass shape.
- **Dispatch:** one typed `define-c-lambda` per **distinct method ABI signature**
  (group via the 010 `shared_signatures` key — do not emit a duplicate crossing
  per selector), inside a `begin-ffi` block. Body is an **inline-cast
  `objc_msgSend`** (arm64 forbids variadic msgSend — cast to the exact prototype),
  with `___CAST`/`___return` for `const`-qualified returns to avoid `cast-qual`
  warnings (FINDINGS §1). C-safe headers (`<objc/runtime.h>`, `<objc/message.h>`,
  CoreGraphics) declared; the unit is compiled `-x objective-c` (the cc-option is
  a runtime/CLI build concern — emit the source assuming it).
- **Procedural core (hot path):** a plain procedure per supported method, keyed
  per class (`<class>-<selector>`), taking/returning the `objc-obj` handle
  (`(defstruct objc-obj (ptr))` lives in the runtime — emit calls to its
  constructor/accessor by the runtime's agreed names; if unknown, inbox-note 050).
  `id`-typed returns wrapped through the runtime's `wrap`/lifetime entry.
- **OO veneer (opt-in):** for each method also emit a `:std/generic`
  `(defmethod (<selector> (o objc-obj)) …)` dispatching to the proc-core
  procedure — the 29.4 ns veneer, NOT Gerbil built-in `{}` dispatch (CONTEXT.md,
  ADR-0018). Veneer is additive; the proc core is the foundation.
- **Constructors:** explicit `initX:` → `make-<class>-…`; synthesize a default
  `make-<class>` (alloc+init) when no explicit initializer, like chez's
  `emit_default_constructor`. Honour `returns_retained` / init-family ownership.
- **Properties:** getter + `…-set-x!` setter; skip unsupported struct-valued
  properties (per `method_filter`).
- **Error model:** a method whose ObjC signature ends in `NSError**` returns
  `(values result error)` (`#f` on success, an `nserror` on failure) — `let-values`
  at call sites. ADR-0006 applied to gerbil.
- Export-name collision handling across categories/properties (port chez's
  `dedupe_across_categories` safety net).
- `emit_framework` writes one module per class and adds it to the `main`
  re-export. Crate compiles; unit tests cover a representative class (a method,
  a struct-returning method, an `NSError**` method, a property, the default
  constructor) the way chez's `emit_class` tests do.

## Notes

**May itself decompose.** If one session can't carry dispatch + proc-core +
veneer + constructors + properties + error-model, decompose into e.g.
`021-dispatch-and-proc-core`, `022-constructors-properties-veneer-errors`. Decide
when the session shows it's too big — don't pre-split.

Names the runtime owns (`objc-obj` ctor/accessor, `wrap`, the will/lifetime
helper, `make-objc-block`, the nserror wrapper) are 050's. Where 020 needs a name
that isn't settled, pick the obvious one, emit against it, and **inbox-add to 050**
recording the contract so the runtime matches — rather than blocking.

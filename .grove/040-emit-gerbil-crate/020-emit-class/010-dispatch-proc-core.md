# 010-dispatch-proc-core

**Kind:** work

## Goal

Write the procedural half of `emit_class.rs`: the dispatch core + proc-core +
constructors + properties, wired into `emit_framework`. This is the complete
*functional* Gerbil binding for a class — the opt-in OO veneer and the
`(values result error)` error model land in sibling leaf 020.

## Done when

- `generate_class_file(cls, framework) -> String` and `class_exports(cls) ->
  Vec<String>` exist (the two entry points `emit_framework` calls), mirroring
  chez's `generate_class_file_with_exports` single-pass shape.
- **Class plan / exports / dedup** ported from chez `emit_class.rs`
  (`build_class_plan`, `effective_methods`/`effective_properties`,
  `collect_exports`, `has_explicit_constructor`, `dedupe_across_categories`,
  the property/class-method collision pre-pass) — the IR-shaping is target-neutral;
  swap chez naming calls for `crate::naming`.
- **Dispatch (`begin-ffi` block):** one typed `define-c-lambda` per **distinct
  method ABI signature** (group via `shared_signatures::msgsend_signature_key` —
  no duplicate crossing per selector). Body is an **inline-cast `objc_msgSend`**
  (`((ret (*)(id, SEL, args…))objc_msgSend)(___arg1,(SEL)___arg2,…)` returned via
  `___return(...)`), per the spike's `01-reachability.ss`. `___CAST`/`___return`
  for `const`-qualified returns (FINDINGS §1). C-safe headers `c-declare`'d
  (`<objc/runtime.h>`, `<objc/message.h>`, `<CoreGraphics/CGGeometry.h>`); the
  `(c-define-type <Tok> (struct "<CName>"))` declaration for each by-value geometry
  struct the class uses (FINDINGS §4). Also bind `objc_getClass` /
  `sel_registerName` in the block.
- **Proc core:** a plain procedure per supported method, named via
  `naming::make_method_name` / `make_class_method_name`, taking/returning the
  `objc-obj` handle. Registers the selector (cache via `sel_registerName`), calls
  the shared `%msg-…` `define-c-lambda`. `id`-typed returns wrapped through the
  runtime wrap/lifetime entry; receiver unwrapped via `objc-obj-ptr`; class
  methods use `(objc_getClass "<Cls>")`.
- **Constructors:** explicit `initX:` → `make-<class>-…`; synthesize a default
  `make-<class>` (alloc+init) when no explicit initializer (chez's
  `emit_default_constructor`). Honour `returns_retained` / init-family ownership
  (port `method_returns_retained` / `is_family_match`).
- **Properties:** getter + `…-set-x!` setter; skip unsupported struct-valued /
  block properties (per `method_filter` + chez's `is_unsupported_struct_property`).
  Properties emit through the same per-signature dispatch block.
- `emit_framework` writes one `<fw>/<cls>.ss` module per class (under the package
  root) and pushes a `SubModule` so the facade re-exports it. Crate compiles;
  unit tests cover: a plain method, a struct-returning method, a property
  (getter+setter), the default constructor, an explicit constructor, and the
  per-signature dedup (two same-shape selectors → one `define-c-lambda`).

## Context

Node brief + design §3 (dispatch), §3a (object model — proc core), §4 (FFI
compilation). ADR-0017, ADR-0018. Foundation (leaf 010): `naming`,
`ffi_type_mapping`, `method_filter`, `shared_signatures`. Reference:
`emit-chez/src/emit_class.rs` (plan/exports/dedup port verbatim; dispatch +
bodies are the Gerbil divergence). Spike: `01-reachability.ss`,
`04-struct-return.ss` (the exact proven `define-c-lambda` forms).

## Runtime names 010 emits against (050's to honour)

Pick the obvious `defstruct` names and **inbox-add to 050** recording the contract:
`(defstruct objc-obj (ptr))` ⇒ ctor `make-objc-obj`, accessor `objc-obj-ptr`;
wrap/lifetime entry `wrap-objc-obj` (optional retained flag, mirroring chez
`wrap-objc-object`: `(wrap-objc-obj ptr)` / `(wrap-objc-obj ptr #t)`). Confirm /
adjust the actual names when 050 lands.

## Out of scope (sibling 020)

`:std/generic` veneer; `(values result error)` error model and its
`method_filter` adjustment; block-param boxing (`make-objc-block`) — defer
block-param methods here exactly as `method_filter` already does.

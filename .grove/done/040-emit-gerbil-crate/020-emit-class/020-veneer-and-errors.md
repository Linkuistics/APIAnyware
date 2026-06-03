# 020-veneer-and-errors

**Kind:** work

## Goal

Layer the two constructs that sit on top of the procedural binding from sibling
010: the opt-in `:std/generic` OO veneer, and the `(values result error)` error
model for trailing-`NSError**` methods.

## Done when

- **OO veneer (opt-in, ADR-0018):** for each emitted proc-core procedure also
  emit a `:std/generic` `(defmethod (<selector-generic> (o objc-obj)) …)`
  dispatching to the proc — the 29.4 ns veneer, NOT Gerbil built-in `{}` dispatch
  (CONTEXT.md). Decide the generic-name scheme (selector-keyed, receiver-only
  dispatch as the spike's `03b` measured) and wire the generic names into the
  class module's `(export …)` + the facade. Veneer is additive; the proc core
  stays the foundation. Tests: a method's `defmethod` is emitted and exported.
- **Error model (ADR-0006 applied to gerbil):** a method whose ObjC signature
  ends in `NSError**` returns `(values result error)` (`#f` on success, an
  `nserror` on failure). Drive routing off the shared enrichment machinery
  (`class_error_selectors` / `is_error_out_routable` — see
  `emit-racket/src/native_dispatch.rs` + `emit_class.rs`; lift to the `emit`
  crate if not already shared). The trailing `NSError**` is **dropped** from the
  proc's visible arity. Because gerbil keeps the crossing in Gerbil (no native
  `_e` entry, unlike racket), the `define-c-lambda` itself owns the out-param:
  declare a local `NSError *err = nil;`, pass `&err` to `objc_msgSend`, and return
  result + error — settle the two-value return shape (e.g. an out-param the proc
  reads, or a small struct/pair). Adjust `method_filter` so a trailing-`NSError**`
  method is **supported** (it currently defers `TypeRefKind::Pointer` params).
  `let-values` call-site shape documented. Tests: an `NSError**` method emits a
  `(values result error)` proc with the error param dropped.

## Context

Node brief + design § error model, §3a (veneer). ADR-0006, ADR-0018. Builds
directly on 010's output (`emit_class.rs`). References: `emit-racket`'s
error-out routing (`is_error_out_routable`, `class_error_selectors`,
`method_routes_error_out`, `visible_params`) — the gerbil version reuses the
*classification* but emits the out-param handling **in Gerbil**, not via a native
entry. Spike `03b-generic-tax.ss` for the `:std/generic` `defmethod` form.

## Runtime names 020 emits against (050's to honour)

`nserror` constructor/predicate + accessors (mirror chez `make-nserror`/`nserror?`/
`nserror-domain`/`nserror-code`/…) — **inbox-add to 050** with the contract:
the proc builds an `nserror` from the captured `NSError*` (or yields `#f` when
nil). Confirm the wrap entry's signature when 050 lands.

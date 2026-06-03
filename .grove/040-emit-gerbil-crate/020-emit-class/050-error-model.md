# 050-error-model

**Kind:** work

## Goal

Emit the `(values result error)` error model for methods whose ObjC signature
ends in a trailing `NSError**` out-param (ADR-0006 applied to gerbil). Layered on
the proc core (040), so both consumption surfaces inherit it. Carries the
contract worked out in the retired `020-veneer-and-errors` leaf.

## Done when

- **Routing off shared enrichment:** a method routes to the error model iff its
  selector is in the class's enrichment-derived error-selector set **and** its
  trailing param is a pointer (the `NSError**` cell — type-level corroboration).
  **Lift `class_error_selectors` from `emit-racket/src/native_dispatch.rs` to the
  shared `emit` crate** (it just filters `EnrichmentData.convenience_error_methods`
  by class → `HashSet<String>` — target-neutral) and use it from gerbil. (Racket's
  `is_error_out_routable` works on racket `_pointer` spellings; gerbil needs the
  analogue over its own tokens, but driven off the *same* enrichment set so the
  classification never drifts.) Thread the class's error selectors into
  `generate_class_file_with_exports` (emit_framework has `fw.enrichment`).
- **`method_filter` change:** a trailing-`NSError**` method becomes **supported**
  (it currently defers `TypeRefKind::Pointer` params). Only the *trailing* pointer
  that is an error-out cell is allowed; other raw-pointer params still defer.
- **In-Gerbil out-param crossing (the gerbil divergence from racket's native `_e`
  entry):** the crossing keeps the marshalling in Gerbil. The error-out
  `define-c-lambda` takes the method's **visible** args + a trailing
  `(pointer (pointer void))` error cell, casts it to `NSError**`, and passes it to
  `objc_msgSend` so the method writes the `NSError*` through it:
  `___return( ((<ret>(*)(id,SEL,<visible…>,NSError**))objc_msgSend)(___arg1,(SEL)___arg2,<actuals…>,(NSError**)___argLast) );`
  (void-return variant drops `___return`). Distinct binding name from the plain
  shape (an `-e` suffix, mirroring racket's `_e`). The trailing `NSError**` is
  **dropped** from the proc's visible arity.
- **Two-value proc shape:** the proc allocates/zeroes the cell, calls the
  crossing, reads the captured `NSError*`, returns `(values <wrapped-result>
  <nserror-or-#f>)`. Settle via a runtime helper `call-with-nserror-out` (contract:
  allocate a 1-ptr cell, run the thunk with it, build an `nserror` from the
  captured pointer or `#f`, free the cell, return both) so the per-method proc only
  adds its own result-wrapping — **inbox-add to node 050** with this contract +
  the `nserror` ctor/predicate/accessors (`make-nserror`/`nserror?`/`nserror-domain`/
  `nserror-code`/… mirroring chez).
- **Call-site shape** documented (`(let-values (((r err) (nsdata-write-to-file …)))
  …)`); both surfaces forward to the proc so they return the two values too.
- Crate compiles; tests cover: an `NSError**` method emits a `(values result
  error)` proc with the error param dropped + the `-e` crossing; a non-error
  trailing pointer still defers.

## Context

ADR-0006 (error model), ADR-0020 (layered on the proc core). Reference:
`emit-racket/src/native_dispatch.rs` (`class_error_selectors`,
`is_error_out_routable`, `NativeSig::error_out_from_ffi_unsafe`, `method_native_sig`)
— reuse the *classification*, emit the out-param handling **in Gerbil** not via a
native entry. `EnrichmentData.convenience_error_methods: Vec<ClassSelectorEntry>`
in `collection/crates/types/src/enrichment.rs`. NB: emit-chez reserved the
`nserror` accessor names but never wired the emission — **gerbil is the first
target to actually emit the error model**.

# method-init-residual-wiring-k15

**Kind:** work (deferred from 040/060 — scope decision 2026-06-20, user chose
"defer to follow-up leaf")

## Goal

Wire the **Swift-native method/init residual** (the §6d `576 init + 554 method`
trampolines) into the emitted SBCL binding tree as Lisp-side forms, completing the
callable surface that leaf 040/060 deliberately left collected-but-unbound. After
this leaf, `--target sbcl` emits a tree where a Swift-native receiver-handle method
and an init producer are reachable from Lisp (`(defmethod …)` / `make-instance`),
not only re-exported on the Swift side (`Generated/Trampolines.swift`).

040/060 already bound the **fn/const** residual (`FnTrampoline::render_binding` /
`ConstTrampoline::render_binding` → complete `(defun …)` / `(define-objc-constant …)`)
and the full direct ObjC contract surface. This leaf is the remaining
method/init half.

## Why deferred (the 060 scope decision)

The fn/const residual `render_binding()` returns complete drop-in forms; the
method/init residual (leaf 040/050) left only *building blocks*
(`MethodTrampoline::render_alien_funcall` / `arg_coercions` / `coerce_result` /
`ret_alien` / `arg_aliens` / `owner_is_class` / `is_async`,
`InitTrampoline::render_alien_funcall` / …) with a doc note that "the
orchestration leaf (060) wraps this in `(defmethod ns:<generic> ((self ns:<owner>) …) …)`".
Two genuinely-unsettled design questions made it too large+coupled to fold into the
node-closing leaf, and **none of it is VM-verifiable until the 050-runtime exists**
(the `aw-*` helpers it calls are runtime-owned):

1. **Generic naming for Swift base-name methods.** `MethodTrampoline` carries
   `swift_name` (the base name up to `(`, e.g. `update` from `update(with:)`) +
   `labels`, **not** an ObjC selector. The contract's `ns:` generic naming
   (`naming::qualified_generic_name`) is selector-driven. Decide: does a
   Swift-native method bind `ns:update` (base only — risks collision with an
   unrelated ObjC `update`), `ns:update-with` (base+labels, selector-analogous),
   or a distinct namespace? `MethodTrampoline` has **no** `binding_symbol`/generic
   field (unlike `FnTrampoline`), so the mapping is this leaf's to define.
2. **The defgeneric lockstep.** `collect_generics` walks only `objc_exposed`
   methods, so a residual method's generic has **no** `defgeneric`. Either extend
   the generics collection to include the residual method generics, or emit their
   `defgeneric`s alongside the residual `defmethod`s — keeping the
   "every defmethod has a matching defgeneric" invariant
   (`object_model_test::every_defmethod_has_a_matching_defgeneric`) true for the
   residual surface too.
3. **Init producers → `make-instance`.** An `InitTrampoline` produces a boxed
   owner handle. Decide how it surfaces: a `make-instance`-compatible registration
   (peer `register-objc-init`, §5) routed through the trampoline rather than
   `alloc`/`init`, vs a distinct `(defun ns:make-<owner> …)` constructor. Class
   owners `aw-wrap` the returned id to the bound type; value owners hand back the
   raw box (ADR-0038 §4, `owner_is_class`).

## Context

Reference the peer **gerbil**: `emit-gerbil/emit_class.rs` emits a per-class
"Swift-native methods (receiver-handle trampolines, ADR-0030)" section via
`classify_method` + `render_binding` — the structural model for where these forms
land (per owning class, in `classes.lisp`). ADR-0030 (method frontier), ADR-0038 §4
(the SBCL marshalling taxonomy + object-return wrap), the racket trampoline spec
§8/§9 (the receiver-handle taxonomy, unchanged through the IR). The building blocks
are all in `emit-sbcl/src/trampoline.rs` (`MethodTrampoline` / `InitTrampoline`
impls). The 060 orchestrator (`emit_framework.rs`) is where the per-framework
assembly happens — extend `classes.lisp` with the residual section per owning class.

## Done when

- Each owning class's `classes.lisp` carries its Swift-native residual
  method/init forms (the receiver-handle `defmethod`s + the init producers),
  reachable under stable `ns:` names; their generics satisfy the defgeneric
  lockstep.
- Snapshot/unit tests cover the residual method + init shapes (the 060 goldens
  extend to include a Swift-native method+init fixture case).
- The §6d count is unchanged (this leaf binds, it does not reclassify) — the
  existing `sbcl_residual_reproduces_the_6d_invariant` stays green.

## Notes

- Pure emitter codegen (snapshot-testable now); full VM verification rides the
  050-runtime + the 060-sample-app ladder. Sequenced at the grove root between the
  retired `040-build-emitter` and `050-build-runtime-native-core` so the emitter
  surface is complete before the runtime loads it.

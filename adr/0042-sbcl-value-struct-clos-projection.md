# SBCL value structs project to plain CLOS classes on a `ns:value-struct` root, wrapping the opaque box

The `sbcl` target's **population-B value-struct** residual — a Swift value struct
(`objc_exposed == false`, e.g. `IndexSet`, `CharacterSet`, `AffineTransform`) carrying
bindable Swift-native methods/inits — projects each such struct to a **plain CLOS class**
`ns:<struct>` deriving from a runtime-owned root **`ns:value-struct`** that holds the
opaque `AwSbclValueBox` handle in a `ptr` slot. Its instance methods bind as
receiver-specialized `(defmethod ns:<generic> ((self ns:<struct>) …) …)`, and its
initializers bind as `(defun ns:make-<struct> … (make-instance 'ns:<struct> :ptr <box>))`
constructors that **wrap the produced box into an instance**. The class is **not** the
`objc-class` metaclass (ADR-0034) — a value struct has no ObjC `Class`, so none of its MOP
hooks (alloc/init, foreign ivar offsets, subclass synthesis) apply.

This ADR records the value-struct residual wiring — the
object-model decision deferred when the **class-owner** half was wired. It completes
the §6d Swift-native residual's value-owner half on the
Lisp side; the trampoline classification + the `@_cdecl` Swift side were already done by
045 (the value-receiver `emit_method_tramp` branches: unbox via `awSbclUnbox`, mutating
write-back) and 050 (`AwSbclValueBox` / `awSbclBox` / `aw_sbcl_box_free`).

## Context — why a value struct cannot be a bare `defun`

045 bound class owners as `(defmethod ns:<gen> ((self ns:<owner>) …))` specialized on the
owner's `objc-class`-metaclass CLOS class. A value struct has **no CLOS class** (the
emitter emitted nothing for `Framework.structs`), so its methods had nowhere to specialize
— the object-model fork 045 deferred.

The naive alternative — a bare `(defun ns:<name> …)` taking the box handle explicitly — is
**unsound in SBCL's single `ns:` package** (ADR-0033 §3.1): a value-struct method named
like an ObjC selector (e.g. a struct's `contains(_:)` and `NSArray`'s `contains:`) must be
the **same symbol** `ns:contains`. A `defun ns:contains` and a `defgeneric ns:contains`
cannot share one symbol's function cell — so a bare `defun` breaks the shared-package
surface the moment any selector name coincides.

This is a **cross-target divergence**: gerbil (ADR-0020/0029) keeps value structs
**procedural** — `(->ptr self)` passes the raw box pointer through, methods are plain
`define`s — because Scheme has no `defun`/`defgeneric` symbol collision. SBCL's CLOS
single-package model forces the class projection instead.

## Decision

### 1. A value struct is a plain CLOS class on `ns:value-struct`

The runtime owns a root `(defclass ns:value-struct () ((ptr :initarg :ptr …)))` — a
**plain `standard-class`** (not `objc-class`). The emitter emits one
`(defclass ns:<struct> (ns:value-struct) ())` per value struct with bindable residual.

The box rides the **`ptr` slot — the same slot name `ns:ns-object` uses** — so the existing
`aw-ptr` (`(slot-value … 'ptr)`) reads it unchanged. Consequently a value-struct method's
receiver coerces through the *same* `(aw-ptr self)` as a class owner, and a value-struct
**argument** through the same `(aw-ptr arg)` (the `BoxedHandle` arg path 045 already wrote
in anticipation). The unbox + mutating write-back live entirely in the `@_cdecl` Swift
side, so the Lisp `render_defmethod` needs **no** value-specific path.

### 2. The constructor wraps the box into an instance

A value-owner constructor renders
`(defun ns:make-<struct> (…) (make-instance 'ns:<struct> :ptr <crossing>))`. This changes
045's placeholder (which handed back the raw box) so the returned value **dispatches
through the struct's `defmethod`s** and the `ns:value-struct` finalizer reclaims the box.
`make-instance` here is the *internal wrap*, not §3.3's ObjC `alloc`/`init` (which is
`objc-class`-only) — a value struct is constructed by the trampoline, never ObjC `alloc`.
The **initializer is the sole root producer** of a value-struct instance: method/function
returns of a value type stay un-nameable opaque boxes (classified `OpaqueBox(None)`),
consistent with the glossary's "handle producer / initializer trampoline".

### 3. Box lifetime — free directly on the finalizer thread

`ns:value-struct`'s `initialize-instance :after` arms a `sb-ext:finalize` that frees the
box (`aw-box-free` → `aw_sbcl_box_free`), capturing only the box pointer as an integer
(never the instance), `:dont-save t`. **Unlike a wrapped ObjC `id` (ADR-0036), a value box
has no UI affinity** — `aw_sbcl_box_free` only releases the Swift box's retain, no AppKit
`dealloc` runs — so it is freed directly on the off-main SBCL finalizer thread, with no
main-thread release-queue bounce.

### 4. Layout: one `structs.lisp` per framework

The value-struct forms land in a per-framework `structs.lisp` (gerbil's per-struct modules
collapsed to one file), facade-ordered and **residual-gated** by the loader (loaded like
`functions.lisp`). The method generics fold into `generics.lisp` via `collect_generics`
exactly like a class owner's; the struct **class name + constructor symbols** export
through the facade (the method generics already ride the framework's generic set).

### 5. Arity-clash drop keeps every `defmethod` congruent

A residual method whose generic post-kebabs to an **already-declared name at a different
arity** (e.g. a value struct's `format(_:)` → `ns:format`, colliding with `NSNumberFormatter`'s
no-arg `ns:format`; or `scale(_:)` vs `NSDecimalNumberHandler.scale`) is **dropped** from
emission — a CLOS generic cannot carry methods of two arities, so emitting it crashes at
*load*. The trampoline + §6d count are unaffected (the `@_cdecl` still exists); only the
unloadable `defmethod` is skipped, and the clash is surfaced (a generation `WARN`). This
enforces, at emission, the "first-arity-wins" the prior arity-conflict detector only
*reported*. The filter applies to **both** class and struct residual (latent for classes —
no class tripped it — manifest once value structs were emitted).

## Considered options

- **Bare `(defun ns:<name>)` taking the box explicitly (gerbil's procedural shape).**
  Rejected — collides with same-named generics in the single `ns:` package (a `defun` and
  `defgeneric` cannot share a symbol). The deciding argument for the CLOS class.
- **An `objc-class` metaclass for value structs.** Rejected — a value struct has no ObjC
  `Class`; the metaclass's hooks (alloc/init, ivar offsets, subclass synthesis) are all
  inapplicable. A plain `standard-class` is the honest, minimal projection.
- **Constructor hands back the raw box (045's placeholder).** Rejected — the box would not
  dispatch through the struct's methods (a raw SAP is not a `ns:<struct>` instance),
  breaking the object model. The constructor must wrap.
- **Routing `make-instance 'ns:<struct>` through the trampoline (a value alloc/init).**
  Rejected — `make-instance` is left as the standard CLOS make (the internal `:ptr` wrap);
  the named `ns:make-<struct>` constructor is the surface, matching the class-owner
  choice and avoiding a metaclass.
- **Collision-rename the arity-clashing selector.** Rejected here — renaming
  diverges the shared `ns:` surface from the §6d naming and the other targets; dropping the
  rare conflicting `defmethod` (with a `WARN`) is the lower-risk, scoped choice.

## Consequences

- **Emitter** (`emit-sbcl`): a new `emit_struct` module (`generate_struct_file`); a
  `struct_residual_methods`/`struct_residual_inits` pair (the `owner_is_class=false` dual of
  the class collectors); `collect_generics` / `generic_arity_conflicts` fold in struct
  residual generics; `coerce_init_result` wraps value owners; `emit_framework` writes
  `structs.lisp` + writes `generics.lisp` even for a struct-only (class-less) framework; a
  `generic_arity_index` + `arity_consistent` filter on both residual paths.
- **Runtime** (`value-struct.lisp`): the `ns:value-struct` root + box finalizer, loaded
  after `swift-trampoline.lisp`; the app binding loader gains a residual-gated
  `structs.lisp` step.
- **The §6d count is unchanged** — this decision binds, it does not reclassify; the value-owner
  trampolines were always counted, only their Lisp emission was unwired.
- **Verified end-to-end** — the runtime integration smoke now proves the value-struct chain
  (a `Pair` value struct: `make-instance`-wrapped constructor → `(aw-ptr self)` receiver →
  unbox → method result) against the real `libAPIAnywareSbcl`; the `swift-native-probe`
  loads the real `foundation/structs.lisp` (CharacterSet, IndexSet, …) and exercises an
  `IndexSet` round-trip.
- **Hard to reverse:** the `ns:value-struct` root, the `ptr`-slot box convention, and the
  box-wrapping constructor are baked into every generated `structs.lisp`.

See ADR-0034 (the `objc-class` projection this sits beside), ADR-0033 (the single `ns:`
package surface that forces the CLOS route), ADR-0036 (the ObjC-id lifetime this finalizer
deliberately diverges from), ADR-0038 (`AwSbclValueBox` / the sole native unit), gerbil
ADR-0020/0029 (the procedural value-struct shape SBCL diverges from), and the glossary
("Receiver-handle method trampoline" population A/B, "Handle producer / initializer
trampoline").

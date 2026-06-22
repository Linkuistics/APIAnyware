# 10-[37]-value-struct-residual-wiring

**Kind:** work (split from 045 — scope decision 2026-06-20: 045's "Done when" is
class-owner-scoped; population-B value structs need an object-model decision out of
scope for a wiring leaf)

> **Sequencing note.** Parked at `090` by `leaf-add` (appended after `080-docs`), but
> it logically belongs **after `050`** (it needs the value-box runtime,
> `AwSbclValueBox`) and **before `080-docs`** (docs should describe a complete residual
> surface). A planning session picking `050`/`060` should `grove-llm leaf-insert` this
> ahead of `080`. It is **not** a blocker for `060`-sample-apps (the 7-app ladder uses
> ObjC classes, not Swift value structs).

## Goal

Wire the **population-B (value-struct) half** of the Swift-native method/init residual
into the emitted SBCL tree, completing what leaf 045 scoped out. After this leaf, a
Swift-native **value struct** (e.g. `IndexSet`, `Data`) with bindable methods/inits is
callable from Lisp under stable `ns:` names, not only collected for the §6d count.

## Why split from 045

045 wired the **class** owners: each bindable Swift-native instance method became a
receiver-specialized `(defmethod ns:<base-labels> ((self ns:<owner>) …) …)` and each
init a `(defun ns:make-<owner>… )` constructor. That works because a class owner has a
**CLOS class** (`ns:<owner>`) to specialize the `defmethod` on, and the receiver is a
reference coerced via `(aw-ptr self)`.

A **value struct** (population B, glossary "Receiver-handle method trampoline") has
**no CLOS class** — emit-sbcl emits nothing for `fw.structs` today — so its methods
**cannot** be receiver-specialized `defmethod`s without first deciding the object
model. That is a genuine design fork (ADR-worthy), not mechanical wiring, so it was
deferred whole (methods **and** inits) to keep 045 coherent and class-scoped.

## The design decision to settle (grilling)

1. **Does a value struct become a CLOS class?** Options:
   - A plain `standard-class` (`ns:index-set`) carrying the opaque box handle in a slot,
     so its methods *can* be `defmethod`s specialized on it (uniform with class owners)
     and instances flow through generic dispatch. The constructor (`ns:make-index-set`)
     returns an instance wrapping the box rather than the raw box.
   - **No CLOS class**: value-struct methods become `(defun ns:<name> (self …) …)` taking
     the box handle explicitly. **Rejected risk:** a bare `defun ns:<name>` collides with
     any same-named generic in the single `ns:` package (a `defun` and a `defgeneric`
     cannot share a symbol), so this breaks the shared-package surface — a strong argument
     **for** the CLOS-class option.
2. **Where do the forms land?** A new per-framework `structs.lisp` (gerbil's per-struct
   module collapsed to one file), facade-ordered like the other construct files; or fold
   into the existing per-class layout.
3. **`make-instance` vs constructor for value inits.** 045 chose `(defun ns:make-<owner>…)`
   constructors uniformly; if value structs become CLOS classes, decide whether
   `make-instance 'ns:index-set` should also work (its `allocate-instance` would route
   through the init trampoline, not ObjC alloc/init).

## What already exists (045 building blocks)

- `classify_method(… owner_is_class=false …)` → `SelfMarshal::ValueBox` (mutating
  write-back per D3) — the classification is done; the §6d count includes value owners.
- `InitTrampoline::render_constructor` **already** renders the value-owner branch (hands
  back the raw opaque box, no `aw-wrap`) and is unit-tested
  (`init_constructor_value_owner_hands_back_raw_box`). Only the **emission** (where the
  constructor lands) is unwired for value owners.
- `MethodTrampoline::render_defmethod` renders the class-owner reference path only — a
  value-receiver path (unbox the box, mutating write-back) is this leaf's to add.
- The runtime value-box contract (`AwSbclValueBox`, `awSbclUnbox`) is 050's (ADR-0035/0038).

## Done when

- Each population-B value struct with bindable Swift-native methods/inits binds them
  under stable `ns:` names (the object-model decision above realized + an ADR if it
  warrants one).
- Snapshot/unit tests cover the value-struct residual shape.
- The §6d count is unchanged (this leaf binds, it does not reclassify).

## Pointers

- 045's resolutions (the class-owner half) — the precedent to extend: `naming.rs`
  (`swift_method_generic_name` / `swift_init_constructor_name`), `trampoline.rs`
  (`class_residual_methods` / `class_residual_inits` / `render_defmethod` /
  `render_constructor`), `emit_generics.rs` (`emit_swift_native_residual`,
  `collect_generics` lockstep fold-in).
- Peer gerbil `generate_struct_file` (`emit-gerbil/emit_class.rs`) — the procedural
  value-struct module (the structural shape; SBCL diverges to CLOS).
- ADR-0034 (object model) — a value-struct CLOS class is a **new** pattern beside the
  `objc-class` metaclass projection; likely a new ADR.
- Glossary: `CONTEXT.md` → "Receiver-handle method trampoline" (population A vs B),
  "Handle producer / initializer trampoline".

# 050-gerbil-runtime

**Kind:** work

## Goal

Build the gerbil runtime (`generation/targets/gerbil/runtime/`): the hand-written
Gerbil modules + the Objective-C native core that the generated bindings sit on.

## Context

Design: `docs/specs/2026-06-03-gerbil-target-design.md` §5, §6. Reference layout:
`generation/targets/chez/apianyware/runtime/` (`ffi.sls`, `objc.sls`, `types.sls`,
`cocoa.sls`, `dispatch.sls`, `cocoa-helpers.sls`, `tests/`). Gerbil analogues, NOT
copies (ADR-0011 hermetic isolation).

> **Object-model pivot (ADR-0020, supersedes ADR-0018).** This brief predates the
> pivot; the `objc-obj` single-handle / `:std/generic`-veneer framing below is
> superseded. The runtime now backs a **manifest `defclass` class graph** with
> **two dispatch surfaces** and **transparent extensible subclassing** — which
> promotes dynamic-class synthesis from a deferred native-core item to **core**.
> Exact contract names re-settle as the 040/020 leaves (030/040/050) land and
> inbox-note here. This leaf is now larger and **likely decomposes**.

## Done when

- **`objc` / class-graph module:** the runtime-owned **`NSObject` root `defclass`**
  carrying the `ptr` slot + the Gambit **will** sending `release` (ADR-0019); the
  class-name↔Gerbil-type **registry** + a class-aware `wrap` (`object_getClass` →
  exact bound type, fallback to nearest bound ancestor); `->ptr` arg coercion; the
  `with-autorelease-pool` entry-point macro.
- **`ffi` module:** `:std/foreign` seam, arm64 width aliases, the `objc_getClass`/
  `sel_registerName`/`objc_msgSend` plumbing; FFI unit compiled `-x objective-c`.
- **`types` module:** value marshalling in idiomatic Gerbil (strings, structs,
  CGRect decomposition per FINDINGS §4), the `nserror` struct + the
  `call-with-nserror-out` helper backing `(values result error)` (contract from
  leaf 040/020/050).
- **Dual dispatch surface support (ADR-0020):** the `:std/generic` machinery the
  generic surface binds into **and** the built-in `{}` MOP surface both work over
  the emitted `defclass` graph (the rename to avoid the `defmethod` clash).
- **Transparent subclassing bridge (ADR-0020 — now core, not deferred):** the
  shadowing `defclass`/`defmethod` forms that, for an ObjC-backed superclass,
  synthesize a real ObjC subclass (`objc_allocateClassPair` + IMP trampolines
  inferring signatures from the superclass's ObjC type encodings +
  `objc_registerClassPair`) routing framework callbacks into the user's Gerbil
  methods; falling through to the built-ins for non-ObjC classes. Gerbil analogue
  of racket's `dynamic-class.rkt` / `define-objc-subclass`. **Settle the
  `class_addMethod`-after-`objc_registerClassPair` ordering** (separate top-level
  `defmethod`s vs racket's add-all-then-register).
- **ObjC native core (ADR-0017):** block/delegate bridges + the subclass synthesis
  bridge authored as Objective-C compiled by gsc (`c-declare`/companion `.m`,
  `-x objective-c`), statically linked. **Main-thread model only** here — the
  foreign-thread story is the 080 threading spike (callbacks may bounce to main as
  a placeholder, like racket ADR-0014).
- Runtime smoke tests (objc round-trip, lifetime, both dispatch surfaces,
  a synthesized subclass receiving a framework callback) pass via gsc build (CLI
  smoke; VM-verify is the apps' job).

## Contract settled by node 040 (emitter)

The emitter (`emit-gerbil`, leaf 040) fixed these; the runtime must match them:

- **Package name `gerbil-bindings`.** Generated modules import as
  `:gerbil-bindings/<framework>/<class>` (and a framework facade as
  `:gerbil-bindings/<framework>`). The runtime owns the **static `gerbil.pkg`**
  (`(package: gerbil-bindings)`) at the generated package root
  (`generation/targets/gerbil/lib/`, `generated_subdir = "lib"`) — it is *not*
  emitted per run (IR-independent). Decide whether the runtime modules live under
  the same package or a sibling (e.g. `:gerbil-bindings/runtime/objc`) — the
  emitted code references runtime entries by bare imported name, so the import
  path is the runtime's call as long as the names resolve.
- **Names the generated code calls into (must exist in the runtime, exact
  spellings TBD as leaves 020–040 land — they will append here / inbox-note):**
  the `objc-obj` constructor + `objc-obj-ptr` accessor (ADR-0018 handle), a
  `wrap`/lifetime entry for `id`-typed returns (ADR-0019 will), the
  `with-autorelease-pool` entry macro, the block-bridge constructor
  (`make-objc-block` analogue), the delegate-bridge constructor (`make-delegate`
  analogue), the `nserror` wrapper for `(values result error)`, and a
  string→NSString helper for CFSTR constants. Treat any name a construct-emitter
  leaf emits against as binding on this module.
- **Dual dispatch surface (ADR-0020, supersedes the veneer bullet):** generated
  code emits **both** the built-in `{sel obj}` MOP surface **and** the
  `:std/generic` `(sel obj)` surface over the `defclass` graph — `{}` is no longer
  rejected (ADR-0018's cost-only rejection is superseded; both are offered, proc
  core is the fast path). Note the rename to avoid the built-in `defmethod` clash
  (`03b`/`07` used `(rename-in :std/generic (defmethod g:defmethod))`).

### Exact names emitted by leaf 040/020/010 (dispatch-proc-core)

The class emitter emits `(import :std/foreign :gerbil-bindings/runtime/objc)` and
calls these bare names — the runtime `objc` module **must export them by these
exact spellings** (or adjust the emitter + this contract together):

- `(defstruct objc-obj (ptr))` ⇒ `make-objc-obj`, `objc-obj-ptr`, `objc-obj?`.
- `wrap-objc-obj` — `(wrap-objc-obj ptr)` for an autoreleased (`+0`) `id` return,
  `(wrap-objc-obj ptr #t)` for a retained (`+1`) return (alloc/init, copy, new,
  `returns_retained`). Registers the Gambit will (ADR-0019). Mirrors chez
  `wrap-objc-object`.
- `objc-obj->ptr` — coerce an outbound `id` argument: an `objc-obj` → its `ptr`;
  `#f`/nil → a null pointer. Used for every object-typed arg, object property
  setter value, and the method receiver (`(objc-obj->ptr self)`).
- `objc_getClass` / `sel_registerName` are **emitted inline per class module** in
  the `begin-ffi` block (not runtime-owned) — selectors cached at module load.

**Geometry struct `c-define-type`s** are emitted per-class into the `begin-ffi`
block: `(c-define-type CGRect (struct "CGRect"))` etc., with the C header
`c-declare`d. CG tokens are spike-proven (§4). The NS-prefixed / affine tokens
carry best-known tags + headers (`NSRange`→`(struct "_NSRange")` via
`<Foundation/NSRange.h>`; `NSEdgeInsets`/`NSDirectionalEdgeInsets` via
`<Foundation/NSGeometry.h>`; `NSAffineTransformStruct` via
`<Foundation/NSAffineTransform.h>`; `CGAffineTransform` via its CG header) —
**unverified by gsc**; the 070 VM-verify (or a runtime smoke build) must confirm
the struct tags compile and adjust `geometry_decl` in `emit_class.rs` if not.
Consider hoisting these typedefs into the shared FFI prelude if per-module
redeclaration proves noisy.

(Post-ADR-0020 these names are re-targeted onto the `defclass` graph: leaf
040/020/030 settles the `NSObject` root + `ptr` accessor + class registry,
040/020/040 the typed `wrap`/`->ptr` + both surfaces, 040/020/050 the `nserror` +
`call-with-nserror-out` contract — each inbox-notes here when it runs.)

### Exact names emitted by leaf 040/020/030 (manifest class graph) — LANDED

The class-graph block now emitted at the top of every class module (and a bare
`defclass`-only variant for synthesized intermediate nodes). The runtime `objc`
module **must export these by these exact spellings**:

- **`NSObject` root `defclass`** — the runtime owns
  `(defclass NSObject (ptr) transparent: #t)` (the single class-graph root holding
  the `ptr` slot + the ADR-0019 will). Must export `NSObject`, the predicate
  `NSObject?`, the accessor `NSObject-ptr`, and `make-NSObject` (keyword ctor
  `(make-NSObject ptr: …)`, per spike `07-dual-surface.ss`). Every generated
  `defclass` chains up to `NSObject` and every class module imports it via the
  already-emitted `(import … :gerbil-bindings/runtime/objc)`.
- **`register-objc-class!`** — a runtime proc called once per class at module
  load: `(register-objc-class! <gerbil-class> "<objc-name>" "<objc-super-name>")`.
  Builds the **ObjC-name → Gerbil-type** map the class-aware `wrap` consults
  (`object_getClass` → exact bound type, nearest **bound** ancestor as fallback)
  AND stores the **ObjC superclass name** the transparent-subclassing bridge feeds
  to `objc_allocateClassPair`. The third arg is the *real* IR `superclass` (may be
  `""` for an ObjC root / synthesized node, may name a class whose Gerbil type was
  not statically resolvable — the runtime resolves it by ObjC name at wrap time).
  This is the registry the §"objc / class-graph module" Done-when calls for.
- **`transparent: #t`** is emitted on every generated `defclass` (printability /
  structural debug) — confirm gsc accepts it on the runtime root too.

Class identifiers are emitted in **ObjC PascalCase** (`NSButton`, `NSView`) — the
Gerbil class id == the ObjC class name; module stems stay lowercase
(`nsbutton.ss`). Each class module exports its `<Class>` + `<Class>?`. A class's
`defclass` derives from its resolved parent: same-framework parent ⇒ local sibling
import; cross-framework parent ⇒ import from the owning framework (needs the global
`ClassRegistry`, wired by leaf 060 — see that leaf's note); runtime root ⇒ no extra
import. **Transitional:** the leaf-010 proc surface (`wrap-objc-obj`/`objc-obj->ptr`
over the legacy `objc-obj` handle) still sits *below* the graph block in each
module until leaf 040/020/040 rewrites it — the runtime must keep the old `objc-obj`
contract working alongside the new `NSObject` root until then.

## Notes

The two-toolchain rule (spec §1): develop/measure on the bottled gerbil. Clear
stale `~/.gerbil/lib/static/<mod>.o.lock` on hung builds. May decompose if the
native core + Gerbil modules are too big for one session.

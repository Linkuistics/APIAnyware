# 050-gerbil-runtime — brief

## Goal

Build the gerbil runtime (`generation/targets/gerbil/runtime/`): the hand-written
Gerbil modules + the Objective-C native core that the generated bindings (emitted
by node 040) sit on. Under ADR-0020 the runtime owns a **manifest `defclass` class
graph**, **two dispatch surfaces**, **transparent extensible subclassing** (real
ObjC subclass synthesis — promoted from deferred to core), the **wills + pool**
lifetime model (ADR-0019), and the **`(values result error)`** error model
(ADR-0006). The per-signature `%msg-…` FFI crossings are emitted *inline per class
module* (node 040), not runtime-owned.

## Context

Design: `docs/specs/2026-06-03-gerbil-target-design.md` §4–§6, error model. ADRs
0017 (dispatch + ObjC-in-gsc core), 0019 (lifetime), 0020 (object model, supersedes
0018), 0006 (nserror shape). Reference layout (analogues, NOT copies — ADR-0011
hermetic isolation): `generation/targets/chez/apianyware/runtime/` and racket's
`runtime/dynamic-class.rkt` (the transparent-subclass analogue).

Toolchain (spec §1): bottled gerbil at `/opt/homebrew/Cellar/gerbil-scheme/0.18.2`
for dev/measure; `gxc`/`gxi` are multicall symlinks in its `bin/` (not on PATH).
FFI/runtime unit compiles **`-x objective-c`** (spec §4). Clear stale
`~/.gerbil/lib/static/<mod>.o.lock` on hung builds.

## Decomposition

The runtime layers by capability — data plane first (most generated code needs it),
then the two ObjC-native-core bridges, then a consolidation/verification pass. The
**binding contracts** the emitter (040) already emits against are recorded verbatim
in the sections below; every child leaf must honour those exact spellings (or
co-adjust the emitter + the contract together).

- **010 data-plane** — the `gerbil-bindings` package skeleton (`gerbil.pkg`,
  `-x objective-c` build config) + the `objc`/`types`/`ffi` runtime modules' data
  plane: `NSObject` root `defclass` + ptr slot + ADR-0019 will, `register-objc-class!`
  + class registry, class-aware `wrap`, `->ptr`, `with-autorelease-pool` /
  `define-entry-point`, the `nserror` record + `call-with-nserror-out`,
  `string->nsstring` + value/struct marshalling, dual-surface (`:std/generic` +
  `{}`) import resolution. Resolves the first-compile open items (geometry struct
  tags, `(declare (inline))` pragma, cross-module generic unification). `make-delegate`
  / `make-objc-block` / subclass synthesis are stubbed so the package compiles.
  Smoke: a hand-written class module round-trips NSString/NSMutableArray through
  wrap/->ptr/pool/will + an `nserror` path, compiled by gxc.
- **020 native-bridges** — the ObjC native core (`.m` / `c-declare`, `-x objective-c`):
  `make-objc-block` (block trampolines → Gerbil callback) and `make-delegate` (the
  monomorphic `objc_allocateClassPair` delegate bridge per the protocol contract
  below). IMP trampolines marshal per the Gambit FFI token vocabulary. Smoke: a
  delegate receives a real framework callback.
- **030 subclass-synthesis** — the transparent extensible subclassing bridge: the
  shadowing `defclass`/`defmethod` forms that synthesize a real ObjC subclass from
  an ObjC-backed superclass (`objc_allocateClassPair` + IMP from superclass type
  encodings + `objc_registerClassPair`), routing framework callbacks into user
  Gerbil override methods; fall-through for non-ObjC classes. Settles the
  `class_addMethod`-after-`registerClassPair` ordering. Racket `dynamic-class.rkt`
  analogue. Smoke: a synthesized `NSView` subclass with a `drawRect:` override
  receives the framework callback.
- **040 smoke-suite** — consolidate the runtime smoke tests (objc round-trip,
  lifetime, both dispatch surfaces, synthesized-subclass callback) into
  `runtime/tests/`, write the runtime README, and close any open items deferred
  from 010–030. (VM-verify of real apps is node 070/090's job, not here.)

Threading is **out of scope here** (main-thread-only); the foreign-thread story is
node 080's spike. Callbacks may bounce to main as a placeholder (racket ADR-0014).

## Done when

(Each child leaf carries its own done-bar; the node retires when all four land and
the consolidated smoke suite passes via gxc.) The original aggregate done-bars,
retained for reference:

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

### Exact names emitted by leaf 040/020/040 (consumption surfaces) — LANDED

The proc surface is now **re-targeted onto the typed `defclass` graph** (ADR-0020),
**superseding the transitional `objc-obj`/`wrap-objc-obj`/`objc-obj->ptr` names**
from leaf 010 — the runtime objc module must export, by these exact spellings:

- **`wrap`** — class-aware wrap of a raw `id` pointer → the **exact bound Gerbil
  instance** (`object_getClass` + the `register-objc-class!` registry, nearest
  bound ancestor as fallback), registering the ADR-0019 will. `(wrap p)` for an
  autoreleased (`+0`) return, `(wrap p #t)` for a retained (`+1`) return
  (alloc/init, copy, new, `returns_retained`). **Replaces `wrap-objc-obj`** — used
  for every object-typed method/property/constructor return.
- **`->ptr`** — coerce an outbound `id` argument: a bound instance → its `ptr`;
  `#f`/nil → a null pointer. **Replaces `objc-obj->ptr`** — used for every
  object-typed arg and object-property setter value. The **receiver** is no longer
  coerced through this: `self` is a typed instance, so the proc core reads its
  pointer directly as **`(NSObject-ptr self)`** (the runtime root's slot accessor).
- **The renamed `:std/generic` import** — every class module now emits
  `(import :std/foreign (rename-in :std/generic (defgeneric g:defgeneric)
  (defmethod g:defmethod)) … :gerbil-bindings/runtime/objc)`. The runtime must
  ensure `:std/generic` is available and the built-in `{}` MOP `defmethod` is in
  scope (default prelude). Both surfaces share one identifier per spike `07`.

**Dual surface shape per instance method / instance property (getter + setter):**
```
(declare (inline))                ; module-level — forwarders inline the proc core
(g:defgeneric <bare-sel>)         ; one per distinct surface selector, up top
(define (<class>-<sel> self …) (%msg-… (NSObject-ptr self) %sel-… …))   ; proc core
(defmethod {<bare-sel> <Class>} (lambda (self …) (<class>-<sel> self …)))   ; {} MOP
(g:defmethod (<bare-sel> (o <Class>) …) (<class>-<sel> o …))                ; generic
```
Class methods + class properties stay **proc-only** (no instance receiver to
dispatch on). The plan is built over the class's **own** methods/properties
(`cls.methods`/`cls.properties`), **not** the flattened `all_methods` — a subclass
inherits an ancestor's surface method through the `defclass` chain.

**⚠ Open: `(declare (inline))` form** — emitted as the obvious inlinable-proc-core
pragma; **confirm gsc honours it** (and that it doesn't fight `begin-ffi`/`defclass`
above it) at the runtime smoke build / VM-verify, adjust `emit_surface_decls` in
`emit_class.rs` if a different pragma (or `define-inline`) is needed.

**⚠ Open: cross-module generic unification.** Each class module declares its own
`(g:defgeneric <sel>)`, so two **unrelated** classes that happen to share a
selector name (`count`, `title`, `name`, …) export the **same** generic name from
**different** modules → the framework facade (`emit_framework.rs`) collapses/clashes
them. The sound fix is a **shared generics-declaration module** (the global selector
set, declared once and imported everywhere) — the analogue of the cross-framework
`ClassRegistry`, owned here or by the leaf-060 CLI pre-pass. Until then the facade
re-export is unsound for coincidentally-shared selectors. (ADR-0019's illustrative
`wrap-objc-obj` spelling also wants reconciling to `wrap` when the runtime lands.)

### Exact names emitted by leaf 040/020/050 (error model / nserror) — LANDED

gerbil is the **first** target to actually emit the `(values result error)` model
(ADR-0006); emit-chez reserved the accessor names but never wired emission. The
emitted class modules now reference two runtime-owned names that this node must
provide and export from `:gerbil-bindings/runtime/objc`:

- **`call-with-nserror-out`** — the in-Gerbil out-param settler. Contract:
  - takes one thunk of one argument;
  - allocates a 1-pointer cell, zeroed (compatible with the Gambit FFI token
    `(pointer (pointer void))` — a pointer to a `void*` slot; the emitted `-e`
    crossing `define-c-lambda` takes this cell as its trailing arg and casts it to
    `NSError**`);
  - runs `(thunk cell)`; the thunk is the per-method body, which calls the
    `%msg-…-e` crossing with `cell` as the trailing `%err-cell` arg and returns ONE
    value (its own result-wrapping already applied — object returns `(wrap …)`,
    scalar/bool returns bare);
  - reads the captured `NSError*` pointer out of the cell;
  - builds an `nserror` from it (or `#f` when the captured pointer is null);
  - frees the cell;
  - returns TWO values: `(values <thunk-result> <nserror-or-#f>)`.
  The error object is **+1/retained-owned** by the caller (mirrors racket's
  `wrap-objc-object … #:retained #t`): Cocoa hands back an autoreleased/retained
  `NSError*` through the out-param, so `call-with-nserror-out` owns that retain
  decision and registers the ADR-0019 lifetime will on the built `nserror`.

- **The `nserror` record + API**, mirroring chez's `(apianyware runtime objc)`
  exports: `make-nserror` `nserror?` `nserror-domain` `nserror-code`
  `nserror-localised-description` `nserror-userinfo` (chez spelling is British
  `localised`; keep it consistent unless this node decides otherwise).

Emitted call shape (witness) — for `-writeToFile:error:` on NSData →
```
(define (nsdata-write-to-file-error self path)
  (call-with-nserror-out
    (lambda (%err-cell)
      (%msg-p-pp->b-e (NSObject-ptr self) %sel-nsdata-write-to-file-error (->ptr path) %err-cell))))
```
Both consumption surfaces (`{}` and `:std/generic`) forward to this proc, so they
return the two values too. Call site:
`(let-values (((r err) (nsdata-write-to-file-error data "/tmp/x"))) …)`.

### Native bridges settled by leaf 050/020 — LANDED

The two ObjC-native-core callback bridges now exist (replacing the 010 stubs),
on a new runtime module `:gerbil-bindings/runtime/native-core` (the generic C
`c-define` trampolines + dispatch tables + class-pair/IMP plumbing — shared with
030) plus the clang companion `runtime/native_block.c` (the `^` block literals).
`objc.ss` owns the token marshalling and exports, by these spellings:

- **`(make-delegate specs)`** — `specs` = list of `(selector-string proc
  (param-token …) return-token)`. Synthesizes an ObjC class, one IMP per
  selector → `proc`, returns a `+1`-retained instance (caller must root it).
- **`(make-objc-block proc (param-token …) return-token)`** — wraps a proc as an
  ObjC block; `#f` proc → null block. (No emitter caller yet; forward contract.)
- **`wrap-borrowed`** — class-aware wrap with NO retain / NO will, for objects
  handed to a callback (borrowed for the callback's extent).

**Spec-token reshape (co-adjusted in `emit_protocol.rs`, brief-licensed).** The
delegate/block spec now emits **`object`** for an ObjC-object param/return,
distinct from a raw **`(pointer void)`** (a `BOOL*` out-param, a block, a `SEL`):
the bridge `wrap`s an `object` but passes a raw pointer through — `object_getClass`
on a non-object crashes. **Known gaps** (documented, not blocking): `float`/
`double` + by-value struct callback args are not deliverable by the generic
all-pointer trampoline (the bridge raises on those tokens); IMP arity caps at 4
method args, blocks at 3. Main-thread only (foreign threads are node 080).

**Build impact for 030 + 060/070.** 030 reuses `allocate-class-pair` /
`class-add-method` / `register-class-pair` from `native-core`. The build must
`clang -fblocks -c native_block.c` and add its `.o` to EVERY `-ld-options` line
(runtime `-O` compile + each app exe) — see `runtime/README.md` "Building".

### Transparent subclassing settled by leaf 050/030 — LANDED

The shadowing `defclass`/`defmethod`/`new` forms (ADR-0020's centre) live on a
**new module `:gerbil-bindings/runtime/subclass`** — imported ONLY by user app code
that subclasses, NOT by generated bindings (the generated graph uses the built-in
`defclass`; a shadow there would try to synthesize a subclass for every bound
class). For node **090** (sample apps — drawing-canvas especially): the subclassing
surface is

```scheme
(import :gerbil-bindings/appkit/nsview :gerbil-bindings/runtime/subclass)
(defclass (CanvasView NSView) (slots …))
(defmethod (CanvasView "drawRect:") (self) …)   ; ObjC selector as a STRING
(def v (new CanvasView))
```

Override formals are `(self . deliverable-args)` — omit struct/`float`/`double`
args (e.g. `drawRect:`'s `CGRect`), which the generic trampoline can't carry.
`call-super`/`call-super-id` cover zero-arg `[super …]` chains.

**Emitter impact: NONE.** ADR-0020 anticipated the emitter (040) emitting
superclass *type encodings* for IMP-signature inference; instead the runtime infers
them **live** from the ObjC superclass (`class_getInstanceMethod` +
`method_getTypeEncoding`) — always ABI-correct, version-proof, zero emitter
metadata. So node 040 needs no follow-up for subclassing; the already-emitted
`defclass` graph + `register-objc-class!` registry are sufficient.

**Native-core change (backward-compatible):** the IMP trampoline now passes the
receiver `self` to its closure (the override needs it to recover its Gerbil
instance); delegate closures drop the leading self (`make-imp-callback-closure`).
The 020 delegate/block smoke still passes. New ffi crossings:
`class-get-instance-method`, `method-type-encoding`, `msg-super-void`,
`msg-super-id`. New smoke: `tests/smoke-subclass.ss`.

**Ordering decision:** synthesize+register the class pair at `defclass`; each
`defmethod` override does a post-registration `class_addMethod` (legal — no ivars).
Constraint on user/emitted code: an override `defmethod` must follow its `defclass`.

## Notes

The two-toolchain rule (spec §1): develop/measure on the bottled gerbil. Clear
stale `~/.gerbil/lib/static/<mod>.o.lock` on hung builds. May decompose if the
native core + Gerbil modules are too big for one session.

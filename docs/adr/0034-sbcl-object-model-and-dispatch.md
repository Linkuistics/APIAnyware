# SBCL object model: ObjC projected into CLOS via the MOP, statically emitted, receiver-specialized dispatch

**Status:** accepted

The `sbcl` target's object model **projects ObjC's class system into CLOS through
SBCL's Metaobject Protocol (`sb-mop`)**. An `objc-class` metaclass (a subclass of
`standard-class`) backs every bound ObjC class; the **emitter statically generates
the CLOS class graph** while the **MOP machinery lives in the runtime**. ObjC
methods are exposed as **per-selector `defgeneric`/`defmethod` specialized on the
receiver** (D6) over that real class graph — CLOS generic dispatch, method
combination, and `call-next-method`, **not** literal multiple-argument dispatch
(ObjC is single-receiver). Ivars are foreign CLOS slots reachable through
`slot-value`; `make-instance` trampolines to `alloc`/`init`; subclassing
synthesizes a real ObjC class via `objc_allocateClassPair`. Because a dumped image
(`save-lisp-and-die`, D4) keeps baked Lisp metadata but loses live foreign
pointers, the runtime carries a **startup re-resolution pass** that re-`dlopen`s
each framework and re-resolves every `Class`/`SEL` from its baked string identity.

This ADR records the realization of D3 (010-plan) / D6 (030-design parent), settled
in `030-design/020-object-model`. Each load-bearing mechanism below was **verified
first-hand against SBCL 2.6.5 (arm64) and the live ObjC runtime**, per the leaf's
"do not assume" mandate — the prior-art survey
(`docs/research/cl-cocoa-bridges-across-the-family.md`) is CCL-centric and
explicitly left these un-de-risked (§6 gaps).

## Context — what was settled upstream vs. open here

**Settled upstream (carried in, not re-litigated):**

- **D3 (010-plan):** MOP projection of ObjC into CLOS, all-in — not a single
  `objc-object` wrapper (gerbil pre-rejected that as "vacuous", ADR-0018→0020) and
  not a manifest `defclass` graph *without* the MOP (that is gerbil's shape,
  ADR-0020 — sbcl goes further).
- **D6 (030-design parent):** dispatch is per-selector generics **specialized on
  the receiver** over the real metaclass-backed class graph. Holds D3's line
  against the single-dispatch veneer of every prior CL bridge (CCL only *wraps*
  ObjC's runtime message send, research §B3), and dodges the gerbil-ADR-0018
  "vacuous receiver-only dispatch over one type" critique by dispatching over a
  *real* class graph rather than one wrapper type.
- **Static emit + runtime MOP (ADR-0010):** the emitter generates the class graph
  statically from the shared IR; the metaclass and its hooks live in the runtime —
  diverging from CCL, which synthesizes classes *dynamically* from the live runtime
  (research §B5).

**Open here (designed first-hand):** SBCL's own AMOP conformance for the hooks the
projection needs; the slot/ivar mechanism (research §5.1 **refuted** the assumed
hook even for CCL); `make-instance`/subclass synthesis; the **generic-function
explosion + compile-cost risk** D6 carried forward from gerbil ADR-0023; and the
static-emit startup re-resolution pass (research §B5).

## Decision

### 1. The `objc-class` metaclass

A single metaclass `objc-class`, a subclass of `standard-class`, backs every bound
ObjC class. Each bound ObjC class is a `defclass … (:metaclass objc-class)` whose
runtime-owned root (`ns:ns-object`) carries the foreign `ptr` slot (the ObjC `id`).
The complete ancestor chain is reified as `defclass`es (matching Apple's documented
graph, like gerbil ADR-0020) so dispatch and subtyping ride a real hierarchy.

*Verified:* all `sb-mop` hooks the projection depends on exist as specializable
generic functions — `validate-superclass`, `compute-effective-slot-definition`,
`slot-value-using-class`, `(setf slot-value-using-class)`,
`direct-slot-definition-class`, `effective-slot-definition-class`,
`compute-slots`, `class-slots`, `finalize-inheritance`, `allocate-instance`,
`ensure-class-using-class`. `objc-class` subclasses `standard-class` and its
`validate-superclass` method installs cleanly. (`ensure-class` and
`standard-instance-access` are ordinary functions, not GFs — expected, not needed
as specialization points.)

### 2. Dispatch — explicit `defgeneric` per selector, `defmethod` per class

For each distinct selector the emitter emits **one explicit `defgeneric` in the
`ns:` package** (authoritative arglist + documentation; the named contract surface,
spec §3.2), then **one `defmethod` per (class × selector) specialized on the
receiver**. Selector arity is fixed by the selector name (colon count), so one
selector ⇒ one generic with one arglist; two frameworks binding the same selector
add methods to the *same* generic (the natural CL package model — gerbil needed an
explicit "declare once" invariant, ADR-0023; in CL it falls out of the symbol
being one binding). Explicit `defgeneric` (over implicit creation from `defmethod`)
was chosen because the compile cost that would have argued against it is now known
to be negligible (§3), so the authoritative arglist/docstring and the documented
exported-generic surface are bought for free.

### 3. The generic-function explosion risk is CLOSED — no mitigation needed

D6 carried forward gerbil's ADR-0023 risk: 6,496 selector declarations there
produced a 60 MB unit and a **~5h cold build**, fixed only by sharding + compiling
without `-O` + parallelism (→ 8.4 min). **That pathology does not reproduce in
SBCL.** A spike at full AppKit+Foundation scale — **6,500 `defgeneric` + 40,000
`defmethod` over 2,000 metaclass-backed classes** — compiled **cold in 8.4 s total,
single-threaded, 658 MB peak** (`defgeneric` decls 0.20 s; the 40,000 `defmethod`
7.71 s; load 0.43 s). A worst-case single generic with 3,000 methods compiled in
4.06 s — no per-GF superlinearity either.

The reason is structural: gerbil's cost lived in **Gambit's `:std/generic`
*macro library*** expanding each `defgeneric` into a large unit that `gsc -target C`
then choked on superlinearly in unit size. SBCL's `defgeneric`/`defmethod` are
**native CLOS special operators** the compiler lowers directly — no macro
explosion, no giant intermediate C translation unit. The cross-target lesson (same
shared IR ⇒ same selector count) does **not** carry the cross-target *cost*,
because that cost was in the host compiler's macro layer, not in the IR. Therefore
the sbcl emitter needs **no `generics.ss`-style sharding, no special compile flags,
no parallel-compile machinery**; one ordinary compilation closure suffices.

### 4. Slot / ivar mechanism — `slot-value-using-class` over baked foreign offsets

Native ObjC ivars are projected as foreign slots reachable through `slot-value`.
The mechanism, re-derived first-hand (the research **refuted** the claim that *CCL*
uses this hook, §5.1 — but for SBCL it demonstrably works):

- A custom **direct/effective foreign slot-definition class** carries the ivar's
  **baked bit-offset** and foreign C-type. `direct-slot-definition-class` returns
  the foreign class only when the slot spec supplies an `:offset`;
  `compute-effective-slot-definition` propagates offset + ctype to the effective
  slot.
- `slot-value-using-class` / `(setf slot-value-using-class)` specialized on
  `(objc-class instance foreign-effective-slot)` reads/writes the foreign memory at
  `(ptr + offset)` via `sb-sys:sap-ref-*`. A metaclass-backed class holds **both**
  foreign ivar slots and ordinary Lisp slots (e.g. the `ptr` handle); the hook
  **discriminates** (foreign slot ⇒ foreign read; otherwise `call-next-method` to
  standard storage). *Verified:* ivars at offsets 0 and 64 read and write correctly
  through `slot-value` against a real malloc'd buffer, while the plain-Lisp `ptr`
  slot falls through to standard storage.
- **Offsets are baked at generation time** from the SDK's ivar layout. *Risk
  (recorded):* this is SDK-drift-sensitive — a binding generated against one SDK
  assumes that SDK's ivar layout. Mitigation options (re-resolve offsets at startup
  via `ivar_getOffset`, or pin the SDK) are deferred to the runtime build (050);
  the *direct* ivar path is a fast-path optimization over the always-safe
  accessor-method path, and most "ivars" are reached via accessor selectors anyway
  (§2), so baked-offset slots are an opt-in, not the spine.

### 5. `make-instance` → alloc/init; subclass synthesis

- `make-instance` on a bound class routes through **`allocate-instance`
  specialized on `objc-class`** — the trampoline point to ObjC `alloc` — then
  `initialize-instance`/`shared-initialize` map init-keyword initargs to the ObjC
  `init…:` message. With **no** init initargs the object is `alloc`'d only
  (research §B4 nuance). *Verified:* `make-instance` fires the metaclass-specialized
  `allocate-instance`.
- **Subclassing** `(define-objc-subclass my-view (ns:ns-view) …)` (the contract's
  portable macro, ADR-0033 §3.4) expands to a `defclass … (:metaclass objc-class)`;
  the runtime synthesizes a **real ObjC subclass** via
  `objc_allocateClassPair` + IMP registration + `objc_registerClassPair`, so AppKit
  dispatches framework callbacks into the user's CLOS methods. `validate-superclass`
  permits the ObjC superclass. *Verified:* `objc_allocateClassPair` /
  `objc_registerClassPair` driven from SBCL via `sb-alien` synthesizes a class the
  live runtime then resolves by name with the correct superclass.

### 6. Static-emit class graph + startup re-resolution pass

The emitter bakes class identity, the ancestor graph, selector strings, and (opt-in)
ivar offsets at generation time. A `save-lisp-and-die` image therefore carries
**baked Lisp metadata but stale foreign pointers**. The runtime owns a CCL
`revive-objc-classes`-equivalent **startup re-resolution pass**:

1. re-`dlopen` every framework the image binds, then
2. walk the baked class graph re-resolving every `Class` via `objc_getClass`
   and every `SEL` via `sel_registerName` from its **baked string identity** —
   never reusing a baked pointer.

*Verified:* after `save-lisp-and-die` + reload in a fresh process, baked class-name
and selector **strings survive** the dump; `objc_getClass "NSString"` returns
**NULL** until Foundation is re-`dlopen`ed (while `NSObject`, in always-mapped
libobjc, survives); re-resolution after re-`dlopen` yields valid `Class`/`SEL`
pointers. This makes the pass **mandatory and sufficient**, and is load-bearing for
`070` (`bundle-sbcl`). How much of the framework-load / re-resolution burden the
target's Swift dylib's own load-time setup absorbs is decided in
`030-design/040-trampoline-layer`.

## Considered options

- **Single `objc-object` wrapper + generic veneer.** Rejected upstream (D3) — the
  gerbil-ADR-0018 "vacuous receiver-only dispatch over one type" failure; strip the
  veneer and what remains is chez with different syntax.
- **Manifest `defclass` graph *without* the MOP** (gerbil ADR-0020's shape).
  Workable, but forfeits the MOP's slot/allocation hooks that make ivar access and
  `make-instance`→alloc/init idiomatic CLOS rather than hand-rolled accessors. SBCL
  has full AMOP (§1 verified), so the MOP projection is the higher-idiom choice
  ADR-0005 favors.
- **Implicit generics (`defmethod`-only).** Fewer forms, but no authoritative
  arglist/docstring and a weaker documented `ns:` surface. Rejected once §3 showed
  explicit `defgeneric` is effectively free.
- **Sharding / no-`-O` / parallel compile (port gerbil ADR-0023).** Rejected as
  unnecessary machinery — §3 shows the blow-up does not occur in SBCL. Carrying it
  anyway would be cargo-culting a fix for a problem this target does not have.
- **Dynamic class synthesis from the live runtime (CCL's model).** Rejected —
  conflicts with ADR-0010 static emit. The MOP is the *mechanism*; the class graph
  stays statically emitted, with startup re-resolution (§6) bridging the dump.

## Consequences

- **050 (runtime + native core)** owns: the `objc-class` metaclass + its
  `sb-mop` hooks, the foreign slot-definition classes, the
  `objc_allocateClassPair` subclass-synthesis bridge (and IMP trampolines), and the
  **startup re-resolution pass** (§6).
- **040 (emitter)** emits: the full `defclass` ancestor graph with
  `(:metaclass objc-class)`, one explicit `defgeneric` per selector, one `defmethod`
  per (class × selector), foreign slot specs with baked offsets/ctypes, and the
  baked class/selector string tables the re-resolution pass consumes. It needs
  **none** of the gerbil generics-sharding pipeline.
- **No new build-time machinery.** Unlike gerbil (ADR-0021 BOTTLE toolchain +
  ADR-0023 shard/parallel pipeline), the sbcl binding compiles as one ordinary
  closure in seconds.
- **Boundaries to sibling leaves.** The per-signature `objc_msgSend` FFI crossing
  is the compiled-FFI mechanism (ADR-0015 / D2, `sb-alien` open-coded typed alien
  per ABI) realized in 040/050, not re-decided here. Lifetime, threading/callbacks,
  and the `NSError**` condition hierarchy are `030-design/030`. The Swift-native
  residual trampoline (`libAPIAnywareSbcl`) and its interaction with the §6
  re-resolution pass are `030-design/040`.
- **Hard to reverse:** the metaclass shape, the explicit-`defgeneric` surface, and
  the baked-graph + startup-re-resolution contract are baked into every generated
  binding, every sample app, and `bundle-sbcl`. The SBCL target design spec
  (assembled in 040) documents them.
- **Contract alignment:** the realization conforms to ADR-0033 / the contract spec
  — the metaclass is *mechanism below the contract* (C1), while `make-instance`,
  `slot-value`, `define-objc-subclass`/`define-objc-method`, and the named generics
  are the spec-shared surface.

See `docs/research/cl-cocoa-bridges-across-the-family.md` (§B1–B5, §5.1, §6, §7) for
the prior-art evidence and the gaps this leaf closed first-hand; ADR-0033 + the
contract spec for the upper-layer surface this realizes; ADR-0010 for static emit;
ADR-0005 for the idiom posture; gerbil ADR-0020 (manifest graph) and ADR-0023
(generics cost — the risk this ADR closes) for the precedents; ADR-0018 for the
"vacuous dispatch" critique D6 answers.

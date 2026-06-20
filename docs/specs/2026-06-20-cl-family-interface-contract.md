# Spec — the CL-family interface contract

**Date:** 2026-06-20
**Status:** specifies the CL-family interface-sharing axis established by ADR-0033;
governs the `sbcl` target's application-facing surface and any future CL-family
member.
**Authored by:** `add-sbcl-clos-target` grove, leaf `030-design/010-contract-and-family-adr`.
**Evidence base:** `docs/research/cl-cocoa-bridges-across-the-family.md` (the 020
prior-art survey — cited inline as §N).

This is the **specification-level interface** that every Common Lisp target in the
APIAnyware CL family conforms to, so that **application source is portable across
CL implementations** even though each compiles to a different FFI under the hood.
Only **`sbcl` is built** in this grove (D5a: portability-ready, not
portability-abstracted); the contract is authored against the four-member roster
(SBCL, CCL, AllegroCL, LispWorks) so the SBCL design is disciplined by what the
family must abstract over, and so a second member can be added later without
redesigning the surface.

The contract is **spec-shared, implementation-hermetic** (ADR-0033, scoping the
ADR-0011 exception): the *interface* is shared and documented; the *binding
implementation* — emitter FFI output, callback/block bridges, threading,
distribution — stays per-impl and idiomatic. There is **no shared binding code**
(the rejected "portable CFFI layer"); different FFI per impl is the whole point
(ADR-0005). This spec defines *what* every member must present; the per-impl
*how* lives in each target's own unit (for SBCL: the design spec authored in
`030-design/040`).

---

## 1. The two layers

The contract has two layers, in the ADR-0025 framing (complete-API binding model):

- **Upper layer — the CLOS surface (§3).** The `ns:` package, class and
  generic-function names, instantiation, subclassing, method definition, slot
  access, and the condition hierarchy. This is what application source is written
  against and what makes that source portable. **This spec is primarily about the
  upper layer.**
- **Lower layer — the `libAPIAnyware<Impl>` C ABI (§6).** The flat C-ABI re-export
  of each impl's Swift-native residual. It is the artifact that *forces*
  convergence (same shared IR → same C ABI → same surface) and delivers
  Swift-native coverage that no message-send bridge can reach (§B5, §1 of the
  research headline). Its concrete shape is designed per-impl (for SBCL:
  `030-design/040-trampoline-layer`); this spec only declares its role.

Both layers are per-impl in *implementation*; both are spec-shared in *interface*.

## 2. The normative boundary (decision C1)

**Observable behaviour is normative; the realization mechanism is
implementation-private.** The contract specifies the *application-facing,
observable* surface — package and names, what `make-instance` does, what
`slot-value` reaches, the macros an application writes, the conditions it can
handle. The contract does **not** specify the *mechanism* a member uses to deliver
that behaviour: the metaclass, the FFI, the slot/dispatch hooks, threading, and
distribution are all below the contract.

This is the resolution of the LispWorks-divergence question (§7.6 of the research).
The naive reading of the prior art would privilege the **metaclass shape**
(SBCL/CCL's `objc-class` metaclass) and treat LispWorks — which uses a plain
`standard-class` + `standard-objc-object` superclass and declares ivars via
`:objc-instance-vars` (§B1) — as a non-conforming fallback tier. The contract
**rejects that**: it lowers the metaclass *out* of the normative surface and
specifies subclassing as a **portable macro** (§3.4) whose expansion is each
member's private business. Consequence: **LispWorks is a first-class conformant
member**, satisfying the contract through a different mechanism, not a degraded
one. The metaclass name never appears in portable application source.

> Why this is safe under ADR-0011/0033: a portable macro whose *name and
> semantics* are in the spec but whose *expansion* each impl writes itself is
> spec-shared, implementation-hermetic — exactly like `make-instance`, which is in
> the contract but wired to `alloc`/`init` differently per impl. It is **not**
> shared binding code.

## 3. The normative surface (upper layer)

A conforming member MUST present all of §3.1–§3.8. Where a convention is borrowed
from Clozure CL it is cited; "adopt CCL wholesale" (research §7.2) is the default
and the burden is on any deviation.

### 3.1 Package & naming

- All bound Cocoa names live in the **`ns:` package** (§C1). The `NS` prefix is
  **retained**; the remainder is **kebab-cased**: `NSOpenGLView` →
  `ns:ns-opengl-view`, `NSURLHandleClient` → `ns:ns-url-handle-client`.
- **Multi-letter acronyms are whole words, not split per capital.** `NS`, `URL`,
  `HTTP`, … map to single hyphen-delimited tokens. The naive
  "hyphen-before-each-embedded-capital" rule is **refuted** (research §5.2): it
  would mis-spell `ns:ns-u-r-l-…`. The name mapper MUST special-case acronym
  runs. *(The acronym table is shared analysis-level data, not per-impl; the
  emitter applies it identically.)*
- **The mapping covers the whole top-level surface, not only classes.** Free
  functions, global constants, and enum values are equally application-facing and
  so are bound under the **same** acronym-aware kebab-case `ns:` symbols
  (`CGRectMake` → `ns:cg-rect-make`, `NSFontAttributeName` →
  `ns:ns-font-attribute-name`, `NSOrderedSame` → `ns:ns-ordered-same`). C
  identifiers also frequently use snake_case, so **`_` is an additional word
  separator** (`dispatch_async` → `ns:dispatch-async`, `objc_msgSend` →
  `ns:objc-msg-send`). The raw C symbol is what the FFI names for the link; the
  kebab `ns:` symbol is the portable application surface. A member MUST apply this
  uniformly so application source naming the surface stays portable. *(Established
  with the SBCL build, leaf `040-build-emitter`; the first member to require it.)*

### 3.2 Calling methods (message send)

- A multi-component selector maps to a **sequence of keyword symbols**, one per
  component (§B3): `nextEventMatchingMask:untilDate:inMode:dequeue:` →
  `(:next-event-matching-mask :until-date :in-mode :dequeue)`.
- The contract provides the CCL **`#/`** selector reader macro and the **`@`**
  NSString reader macro (§C1). These are the de-facto multi-impl standard —
  Objective-CL deliberately adopted CCL's `#/` (§C3) — so a conforming member
  MUST provide them.
- Dispatch is **D6**: per-selector `defgeneric`/`defmethod` **specialized on the
  receiver** over the real class graph (CLOS generic dispatch + method combination
  + `call-next-method`), **not** literal multiple-argument dispatch — ObjC is
  single-receiver. The contract specifies the *observable* dispatch semantics
  (sending a selector to a receiver runs the most-specific method; subclass
  overrides participate via `call-next-method`); the generic-function realization
  is upper-layer surface, but the *cost mitigation* (gerbil's generic explosion,
  ADR-0023) is an implementation concern designed per-impl. For SBCL it is settled
  (ADR-0034): the blow-up does **not** reproduce — native CLOS compiles the full
  AppKit+Foundation scale cold in ~8.4 s — so **no mitigation is needed**, and the
  emitter emits **one explicit `defgeneric` per selector** as the named surface.

### 3.3 Instantiation

- `(make-instance 'ns:ns-… initargs…)` MUST trampoline to ObjC `alloc`/`init`
  (§B4). With no init initargs the object is `alloc`'d only; init-keyword initargs
  become the ObjC `init…:` message. `make-instance` with a string class name MAY
  also be provided (CCL's `make-objc-instance` precedent) but the symbol form is
  the normative one.

### 3.4 Subclassing — the portable macro `define-objc-subclass` (decision C1)

```lisp
(define-objc-subclass my-view (ns:ns-view)
  (:slots (label :initform "" :accessor my-view-label))   ; Lisp-side slots
  (:ivars (counter :int))                                  ; native ObjC ivars (optional)
  (:methods …))                                            ; optional, expands to §3.5
```

- A conforming member MUST provide `define-objc-subclass` with these semantics:
  define a CLOS class that **is a real ObjC subclass** of the named ObjC
  superclass(es), registered with the live ObjC runtime so instances are valid
  ObjC objects. Whether the realization uses an `objc-class` metaclass (SBCL/CCL)
  or a `standard-class` + `standard-objc-object` (LispWorks) is **below the
  contract** (§2).
- `:slots` are Lisp-side CLOS slots; `:ivars` (optional) declare native ObjC
  instance variables with foreign types — the portable spelling of CCL's foreign
  direct slots and LispWorks' `:objc-instance-vars` (§B1/§B2), abstracted so
  application source does not name either mechanism.
- Application source MUST NOT write `(:metaclass objc-class)` directly; that form
  is an SBCL/CCL implementation detail the macro expands to, and is non-portable.

### 3.5 Defining methods — `define-objc-method` (decision C2)

```lisp
(define-objc-method (my-view draw-rect:) ((self my-view) (dirty ns:ns-rect))
  (call-next-method)
  …)
```

- The **canonical** method-definition form is the separate `define-objc-method`,
  CLOS-`defmethod`-style: explicit parameter types, `call-next-method` supported,
  the keyword method-name components joined into the selector. This matches CCL
  `objc:defmethod` and Objective-CL `define-objective-c-method` — both *separate*
  forms (§B4/§C3) — and supports incremental method addition and the delegate
  pattern (many protocol methods on one subclass).
- Methods may only be defined on **Lisp-created** subclasses, never as categories
  on foreign classes (§B4 — every method belongs to a Lisp class; no
  category-on-foreign-class mechanism). A static emitter that *declares
  conformance* to existing protocols is aligned with this and with LispWorks'
  "cannot define new ObjC protocols on 10.5+" constraint (§B4).
- The inline `(:methods …)` clause of `define-objc-subclass` (§3.4) is
  **contract-permitted sugar** that expands to `define-objc-method`. Providing it
  is optional; if provided, it MUST have the same semantics as the separate form.

### 3.6 Slot / ivar access

- Native ObjC ivars are read (and, with care, set) through **`slot-value`** and
  generated accessors (§B2). The contract specifies the *observable* mapping
  (named ivars are reachable as slots); the *mechanism* — whether via
  `slot-value-using-class`, computed accessors, or otherwise — is below the
  contract and is **explicitly not assumed**: the research **refuted** the claim
  that CCL routes through `slot-value-using-class` (§5.1), so each impl re-derives
  its slot mechanism first-hand (SBCL: `030-design/020-object-model` against
  `sb-mop`).

### 3.7 Conditions (declared here; hierarchy designed in `030-design/030`)

- Cocoa/ObjC errors surface as **signalled CL conditions**, *not* as returned
  `(values result error)` pairs. `NSError**` out-parameters and ObjC exceptions
  (`NSException`) become conditions; `handler-case`/`restart-case` is the idiom,
  not error-tuple inspection. This is a **named element of the contract** (the CL
  idiom for `NSError**`) and is normative.
- The contract requires a **named root condition type in the `ns:` package** from
  which all Cocoa-surfaced error conditions descend, so application source can
  `handler-case` on a stable family-portable name. **Designed in
  `030-design/030-lifetime-threading-conditions` (ADR-0037); back-filled here.** The
  prior-art survey found **zero** evidence on this (§C2, §6.3) — first-principles.

  **Confirmed hierarchy (flat, split by source):**
  - **`ns:objc-error`** `: cl:error` — the root; the stable family-portable
    `handler-case` target.
  - **`ns:cocoa-error`** `: ns:objc-error` — the `NSError**` path; readers
    `domain` / `code` / `user-info` / `localized-description`.
  - **`ns:objc-exception`** `: ns:objc-error` — the `NSException` path; readers
    `name` / `reason` / `user-info`.

  The condition types are **distinct symbols** from the projected CLOS classes
  `ns:ns-error` / `ns:ns-exception` (the condition wraps the object, not reuses its
  name). **No per-domain subclasses** — callers branch on the `domain`/`code`
  readers (a small flat surface is what keeps cross-impl conformance cheap).
  **Restarts (minimal, normative):** `use-value` (substitute result) and
  `continue`/`return-nil`; `retry` deferred. A member signals **only** when the
  primary return indicates failure (not merely because `NSError**` is set). The
  same condition surface serves both the direct `NSError**` path and a member's
  Swift-`throws` trampoline (SBCL: `ThrowsBridge`, ADR-0037).

### 3.8 What is explicitly NOT normative

The following are **below the contract** — per-impl, idiomatic, hermetic
(ADR-0011/0005). A member chooses these freely:

- The **FFI** (SBCL: `sb-alien`; CCL: its bridge; AllegroCL: `ff:`; LispWorks:
  `fli:`).
- The **object-model mechanism** (metaclass vs `standard-class`; the slot/dispatch
  hooks; how `objc_allocateClassPair`/IMP registration is driven).
- **Lifetime** (finalizers, weak refs, autorelease-pool plumbing), **threading**
  and **callback activation**, and **distribution** (SBCL: `save-lisp-and-die`).
- The **lower-layer C-ABI symbol names and signatures** (§6) — these are an
  internal convergence substrate, not application surface.

## 4. Conformance & the family roster

A member **conforms** iff it presents all of §3.1–§3.7 with the specified
observable behaviour. Conformance is about *behaviour*, not *mechanism* (§2), so
the metaclass divergence does not bear on it.

| Impl | Roster verdict | Realization of the contract | Evidence |
|---|---|---|---|
| **SBCL** | **IN — built in this grove** | `sb-alien` FFI; `objc-class` metaclass; `define-objc-subclass`→`:metaclass objc-class`; `save-lisp-and-die` | the target; native arm64 (§A1) |
| **CCL** | **IN — conformant by construction** | its production bridge already *is* this surface (metaclass tower, `ns:` package, keyword selectors, `#/`) | ~20-yr production bridge (§A1/§B1) |
| **LispWorks** | **IN — first-class via the macro (C1)** | `define-objc-subclass`→`standard-class` + `standard-objc-object` + `:objc-instance-vars`; conforms by *behaviour* through a different mechanism | production Cocoa bridge, arm64 (§A1/§B1) |
| **AllegroCL** | **IN — qualified; verify before relying** | `ff:` FFI; bridge maturity **unverified** by the survey — confirm its Cocoa story before counting it a conformance target | native arm64 from v11; Cocoa bridge unverified (§A1/§6.5) |
| **ECL / ABCL / Clasp** | **OUT for now — absence, not exclusion** | no evidence of a production Cocoa bridge; the contract stays abstract enough not to *forbid* them | no evidence either way (§A2/§6.6) |

The four-member roster stands. Only **CCL** is deeply evidenced; **LispWorks'**
mechanism divergence is handled by §2/§3.4, and **AllegroCL's** unverified bridge
is the one roster risk a future second-member build must close first.

## 5. The lower layer — the C-ABI convergence substrate (forward reference)

The contract's lower layer is each member's `libAPIAnyware<Impl>` Swift dylib,
which re-exports the **Swift-native residual** (`objc_exposed == false` top-level
functions/constants + the method-trampoline frontier) behind a flat C ABI
(ADR-0025/0026). ObjC is reached **directly** (`objc_msgSend` via the member's
FFI, trampoline elided); only the Swift-native delta trampolines through the
dylib, because no impl can call the Swift ABI without a Swift compilation unit
(SBCL, like gerbil's `gsc`, cannot compile Swift inline — ADR-0029).

This layer is **why the family converges**: the residual is a **deterministic
function of the shared IR** (gerbil reproduced racket's 51 functions + 7 constants
*exactly*), so same analysis → same C ABI → same upper surface. It is **per-target
hermetic** (ADR-0011/0029 settled this fork — no family-shared substrate). The
concrete SBCL lower layer (typed `sb-alien` binding, `save-lisp-and-die`
interaction, startup re-resolution) is designed in
`030-design/040-trampoline-layer`; this spec only fixes its *role* as the
contract's lower layer.

## 6. Relationship to the decision log

- **ADR-0033** establishes the family interface-sharing axis this spec realizes,
  and scopes the exception to **ADR-0011** that permits it.
- **ADR-0005** (max idiom, not portable subset) is intact: the share is
  spec-level, the FFI stays `sb-alien`, not CFFI.
- **ADR-0010** (the native library *is* the binding) and **ADR-0025** (complete-API
  model + trampoline elision) define the lower layer (§5).
- **ADR-0024** (doc placement): this spec is **main-tier** (`docs/specs/`) because
  the contract is *cross-target within the CL family*, not a per-target unit.

## 7. Open items deferred to child leaves

- **Condition hierarchy (§3.7)** — concrete root name + sub-types →
  `030-design/030-lifetime-threading-conditions`.
- **Object-model mechanism (§3.4–§3.6)** — **settled, ADR-0034**: `objc-class`
  metaclass; slot mechanism re-derived first-hand (`slot-value-using-class` +
  baked-offset foreign slots; §5.1's refutation was about CCL, not SBCL);
  AMOP-conformance confirmed against `sb-mop`; D6 dispatch with the
  generic-explosion risk **closed** (no mitigation needed); static-emit class graph
  + mandatory startup re-resolution pass (§B5). Was `030-design/020-object-model`.
- **Lower-layer C ABI (§5)** — symbol naming, typed `sb-alien` binding,
  `save-lisp-and-die` + startup re-resolution → `030-design/040-trampoline-layer`,
  which also authors the SBCL **target design spec** synthesizing 010–040.
- **AllegroCL bridge maturity (§4)** — unverified; close before any second-member
  build.

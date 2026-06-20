# 050-build-runtime-native-core

**Kind:** work

## Goal

Build the SBCL runtime + native core (guide Steps 3–4). **Design fully settled in
030-design — read the SBCL target design spec
(`generation/targets/sbcl/docs/design/2026-06-20-sbcl-target-design.md`) + ADRs
0034–0038 first; this leaf implements them, it does not re-decide.**

- the `sb-alien` FFI seam (compiled FFI, ADR-0015);
- the **MOP machinery** (ADR-0034): the `objc-class` metaclass + the verified
  `sb-mop` hooks (`slot-value-using-class` over baked foreign-offset slots /
  `allocate-instance` / dispatch); per-selector receiver-specialized generics
  (**no** gerbil-style sharding — ADR-0034 §3 closed that risk); `make-instance`
  → `alloc`/`init`;
- **ObjC subclass synthesis** (ADR-0034 §5): `objc_allocateClassPair` /
  `objc_registerClassPair` driven Lisp-side via `sb-alien`; per-selector IMP
  install via the **dylib's native bounce-shim** (ADR-0038 §4) — a raw
  `define-alien-callable` IMP is forbidden (it would run Lisp on a foreign thread);
- **lifetime** (ADR-0036): `sb-ext:finalize` + **main-thread release queue** +
  entry-point `with-autorelease-pool` (finalizers run off-main → enqueue raw `id`,
  drain `release` on main);
- **threading/callbacks** (ADR-0035): foreign-thread callbacks **bounce to the
  main thread** (the chez `Sactivate_thread` activation model is **rejected** —
  spiked, crashed 5/5); `sb-thread` is for SBCL-**native** background compute only,
  *not* a bounce substitute;
- **conditions** (ADR-0037): the `ns:objc-error` / `ns:cocoa-error` /
  `ns:objc-exception` hierarchy + the single `signal-cocoa-error` signaller (keyed
  on the primary return, serving both `NSError**` and the `ThrowsBridge`);
- the **startup re-resolution pass** (ADR-0034 §6): re-`dlopen` direct-msgSend
  frameworks + re-resolve every `Class`/`SEL` from baked string identity, composing
  with the dylib's own auto-reopen (ADR-0038 §5 — the dylib re-links its own symbols
  + its linked framework subset for free; this Lisp pass owns the rest);
- **`libAPIAnywareSbcl` — the SBCL target's SOLE native unit** (ADR-0038): one
  SwiftPM dynamic lib hosting `Generated/Trampolines.swift` + `OpaqueHandle` +
  `ThrowsBridge` + `AsyncBridge` + `CallbackBounce` + `SubclassSynth` (broader than
  gerbil's trampoline-only dylib because SBCL has no ObjC-in-`gsc` home; still does
  *not* absorb the MOP object model). Includes the per-signature bounce-shim IMP
  mechanism (generated-per-selector vs `NSInvocation` — choose here, design spec §8).

## Context

Design fixed in **030-design**: the SBCL target design spec (synthesis) + the
complete-API model ADRs 0025/0026 + the CL-family contract (ADR-0033 / contract
spec) + the sibling ADRs 0034 (object model) / 0035 (bounce) / 0036 (lifetime) /
0037 (conditions) / 0038 (trampoline lower layer). Read those. Peers: racket/chez/
gerbil Swift trampoline dylibs — but note sbcl's dylib is **broader** (sole native
unit, ADR-0038), and sbcl wraps `id` returns to bound type via the ADR-0034 MOP
registry (the gerbil ADR-0029 §2 analogue). ObjC is reached directly via `sb-alien`
`objc_msgSend` (trampoline elided); only the Swift-native residual goes through the
dylib.

## Done when

- Runtime loads in SBCL; the MOP object model works end-to-end (instantiate,
  dispatch, subclass, callback) against a real framework; a background-release
  smoke (ADR-0036) and the §6d-invariant trampoline residual resolve.

## Notes

- Decomposes (MOP, bridges, lifetime, threading, dylib) when picked.

### Runtime contract fixed by 040/020 (object-model emitter) — 050 must implement these so the emitted CLOS bindings load

PACKAGE MODEL
- `:ns` package `(:use)` NOTHING — pure holder of bound Cocoa symbols (class names
  `ns:ns-string`, generic-fn names `ns:length`). Runtime defines + exports them.
- Generated binding files are read in the runtime/impl package (suggest
  `(:use #:cl #:sb-mop)` + the `aw-*` helpers). Bound names are `ns:`-qualified;
  `sb-alien:` operators fully qualified; runtime helpers bare. (The per-file
  `(in-package …)` header + `(export …)` of bound names are orchestration leaf
  040/060's job; 040/020 emits only the forms.)

METACLASS + ROOT (ADR-0034 §1)
- `objc-class` : subclass of `standard-class`; its `validate-superclass` installs
  cleanly. The sb-mop hooks the projection needs are all verified to exist (spike 1).
- `ns:ns-object` : the runtime-owned root, carries the foreign `ptr` slot (the ObjC
  `id`). Never emitted by 040; every `defclass` chains up to it.

DISPATCH BODY (the typed objc_msgSend crossing the emitted `defmethod`s call)
- `+objc-msgsend+` : the `objc_msgSend` function SAP. MUST be re-resolved at startup
  (ADR-0038 §5). Bodies do `(sb-alien:alien-funcall (sb-alien:sap-alien
  +objc-msgsend+ (sb-alien:function <ret> sap sap <args>…)) …)`.
- `aw-ptr`  (instance|nil → id SAP) — outbound object coercion (contract's ->ptr;
  nil → null SAP).
- `aw-wrap` (id SAP [retained?] → exact bound instance) — inbound wrap; 2nd arg `t`
  ⇒ the result is +1 retained (init/copy/new families, and copy properties).
  Resolves the exact bound CLOS class via object_getClass + the class registry.
- `aw-sel`   (string → SEL SAP) — selector resolution; lazy + cached, re-resolved per
  process from the baked string (NEVER a baked pointer, ADR-0034 §6). SELs live in
  always-mapped libobjc so no eager table is needed.
- `aw-class` (string → Class SAP) — class lookup; lazy/cached/re-resolved. Used as the
  receiver for class methods.
- `aw-block` (Lisp closure → C block SAP) — the main-thread bounce is runtime (ADR-0035).
- `aw-with-error-cell` : a MACRO `((var) body…)` for NSError** out-param methods
  (ADR-0037). Allocates the cell, binds `var` (the emitter names it `%err`), threads it
  as the trailing `id*` actual, runs body, and signals `ns:cocoa-error` ONLY when the
  primary return indicates failure (nil/NO). Restarts use-value/continue/return-nil.

CLASS-METHOD DISPATCH
- Class methods are `(defmethod ns:<sel> ((class (eql (find-class 'ns:<cls>))) …) …)` —
  receiver-specialized on the class metaobject. The body's receiver is the literal
  `(aw-class "<ObjCName>")`; the `class` formal is `(declare (ignore class))`. (The
  `#/` reader / class-name reader that lets app source write the call ergonomically is a
  050 contract-surface concern.)

BAKED TABLES the runtime consumes
- `(register-objc-class 'ns:<cls> "<ObjCName>" "<ObjCSuper>")` — per class; the Class
  string table for the startup re-resolution pass. 050's pass re-`dlopen`s each
  framework, objc_getClass'es each baked name, stores the fresh Class SAP on the
  metaclass metaobject. Empty super string = independent ObjC root / synthesized bare node.
- `(register-objc-init 'ns:<cls> "<initSelector>" (:kw …))` — per objc_exposed explicit
  init (selector != "init"); the data for `make-instance`→alloc/init initarg mapping
  (ADR-0034 §5). One keyword per selector component. 050 owns the actual
  make-instance/allocate-instance/initialize-instance wiring; 040 only bakes this table.
  `init` itself = the bare alloc/init default make-instance already covers.
- `(register-objc-protocol "<ObjCName>" :required ((<sel> ns:<gen>) …) :optional ((<sel>
  ns:<gen>) …))` — **added by 040/030** (`emit_protocol`). Per ObjC protocol that
  declares ≥1 `objc_exposed` method; the static surface the runtime's
  `define-objc-subclass` conformance machinery (contract §3.4/§3.5, ADR-0034 §5) drives:
  `objc_getProtocol("<ObjCName>")` + `class_addProtocol` + per-selector IMP install. Each
  entry pairs the ObjC selector string with its `ns:` generic-fn name so a
  `define-objc-method` is routable to the selector it satisfies; the required/optional
  split mirrors the ObjC protocol. **040 bakes only names, NOT ABI signatures** — the
  runtime reads each method's ObjC type encoding from the **live** protocol
  (`protocol_getMethodDescription`) at conformance time ("the runtime drives
  conformance"). The `defgeneric`s for a protocol's delegate-only selectors (those no
  bound class declares) are emitted by `emit_protocol` next to this form; a Lisp subclass
  specializes them via `define-objc-method`. Protocol-declared *properties* are not
  separately registered (a conformer's accessors arrive via flattening; the runtime reads
  any needed encoding live) — revisit only if a real framework needs it.

FOREIGN IVAR SLOT SPECS (ADR-0034 §4 — opt-in fast path, currently EMPTY because the IR
surfaces no ivar layout)
- Spec shape `(<name> :offset <BITS> :ctype <:keyword>)`. `:offset` is the discriminator
  `direct-slot-definition-class` keys the foreign slot-definition class off; it is a BIT
  offset (runtime divides by 8, per spike 3). `:ctype` is the keyword
  `slot-value-using-class`'s `ecase` dispatches on (`:int`/`:double`/… ; extend as needed).
  The accessor-selector path is the always-safe default.

RESIDUAL (objc_exposed == false)
- 040 does NOT emit objc_msgSend bodies for objc_exposed==false methods/inits; it collects
  them (`emit_generics::collect_residual` → {owner, selector, is_init}). 050 (trampoline
  leaf 040/050) emits the `aw_sbcl_*` @_cdecl entries + `sb-alien` bindings; the §6d
  invariant (51 fn + 7 const + 576 init + 554 method) is reproduced there.

OPEN/DEFER
- Generic-name arity collisions across selectors (CL congruence) are surfaced by
  `emit_generics::generic_arity_conflicts` — empty on current fixtures; 040/060
  collision-renames if a real framework trips it.

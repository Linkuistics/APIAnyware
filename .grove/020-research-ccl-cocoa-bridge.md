# 020-research-ccl-cocoa-bridge

**Kind:** research

## Goal

Survey the prior art for mapping Objective-C / Cocoa into Common Lisp via CLOS,
so the SBCL target's **MOP object model** (D3) and the **CL-family interface
contract** (D5) are built on hard-won lessons rather than from scratch. The
definitive source is **Clozure CL's Cocoa bridge** (~20 years in production,
foreign ObjC classes projected into CLOS via the MOP); secondary sources include
**objective-cl**, the historical **MCL** bridge, and any SBCL-specific ObjC FFI
experiments.

## Audience — the downstream leaves this must answer for

This research feeds **030-design** (the contract + the SBCL MOP realization) and,
through it, **040-build-emitter** and **050-build-runtime-native-core**. Each
finding must point at the decision it informs.

## Questions to answer (per source, with primary-source citations)

**On the MOP object model (→ 030 object-model, 050 runtime):**
1. How does CCL represent an ObjC class as a CLOS class? What metaclass(es) does
   it use (`objc:objc-class`-equivalent), and what does the metaclass store
   (the ObjC `Class` pointer, ivar layout, method cache)?
2. How are ObjC instances represented — foreign pointers, CLOS instances, or a
   hybrid? How does `slot-value` / `slot-value-using-class` map to ObjC ivars?
3. How are ObjC methods exposed — `defgeneric` per selector? How is selector →
   generic-function-name done, and how is multiple dispatch reconciled with
   ObjC's single (receiver) dispatch?
4. How is `make-instance` mapped to `alloc`/`init`? How is subclassing in CLOS
   (`defclass … :metaclass …`) turned into `objc_allocateClassPair` + IMP
   registration? What does `define-objc-method` actually do?
5. **Static vs dynamic:** CCL synthesizes classes *dynamically* from the live
   runtime. What breaks / what is lost if the class graph is instead **statically
   emitted** (APIAnyware's model, D3)? Where does CCL rely on runtime
   introspection that a static emitter would have to bake in?

**On the CL-family interface contract (→ 030 contract, D5):**
6. What is CCL's user-facing surface — the `ns:` package, naming conventions,
   the `#/` reader macro for selectors, type/number bridging? Document it
   precisely enough to decide **adopt-CCL's-conventions vs define-our-own**.
7. How does CCL handle `NSError**` / errors — conditions, restarts, multiple
   values? (Feeds the contract's **condition hierarchy**.)
8. How portable is code written against CCL's bridge to *other* CL impls in
   practice? Is there any existing cross-impl Cocoa-in-CL contract to borrow?

**On the lifetime / threading / callback model (→ 030, 050):**
9. How does CCL manage ObjC retain/release against the CL GC? Finalizers, weak
   refs, autorelease-pool conventions?
10. How does CCL handle callbacks on foreign (AppKit) threads and main-thread
    affinity? (Feeds SBCL's `sb-thread` activation question.)

## Done when

- A research doc answers the questions above, **structured around them**, with a
  **"Synthesis for 030"** section pre-judging the contract/object-model decisions
  where the evidence is clear. (Placement: decide main-tier `docs/research/` vs
  per-target `generation/targets/sbcl/docs/research/` — the contract spans the CL
  family, so likely main-tier.)
- Every failure-mode / design claim carries a **primary-source citation** (CCL
  source file, mailing-list/issue URL, doc page). Absences recorded as findings.
- A **walk-away check** per source: with that bridge uninstalled, what is still
  legible / borrowable?

## Notes

- Bias the search toward *what CCL learned the hard way* (post-mortem framing),
  not a feature tour.
- Relevant CCL source areas: `objc-runtime.lisp`, `objc-clos.lisp`,
  `bridge.lisp`, the `ns` package, `define-objc-method`. Cite by file.
- A `deep-research` skill is available and is a natural fit for this leaf.

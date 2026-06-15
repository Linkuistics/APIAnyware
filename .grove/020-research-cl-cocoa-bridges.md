# 020-research-cl-cocoa-bridges

**Kind:** research

## Goal

Survey the prior art for mapping Objective-C / Cocoa into Common Lisp via CLOS,
**across the CL implementations the family must support** — confirmed members
**SBCL, CCL, AllegroCL, LispWorks** — plus a usage/landscape survey to catch any
other impls worth covering (ECL, ABCL, Clasp, …). This feeds the SBCL **MOP
object model** (D3) *and*, crucially, the **CL-family interface contract** (D5):
the contract must be portable across four quite different FFIs (`sb-alien`,
CCL's bridge, Allegro `ff:`, LispWorks `fli:`) and four MOPs with **varying AMOP
conformance** — so the research must establish what surface is *actually*
portable.

The deepest dive is **Clozure CL's Cocoa bridge** (~20 years in production,
foreign ObjC classes projected into CLOS via the MOP). Secondary deep sources:
**LispWorks' Objective-C/Cocoa interface** (documented; CAPI runs over Cocoa) and
**AllegroCL's** macOS/ObjC FFI story (confirm maturity). Historical: **MCL**,
**objective-cl**.

## Audience — the downstream leaves this must answer for

Feeds **030-design** (the contract + the SBCL MOP realization) and through it
**040-build-emitter** / **050-build-runtime-native-core**. Each finding points at
the decision it informs.

## Part A — Landscape & family membership (→ 030 contract scope, root BRIEF roster)

A1. Confirm the family roster: for **SBCL, CCL, AllegroCL, LispWorks** — does each
    run on current macOS/arm64, and what is each one's **ObjC/Cocoa bridge
    maturity** (production-grade, toy, or none)? Cite docs/sources.
A2. **Usage survey:** which CL implementations are actually used for macOS GUI /
    Cocoa work today? Are there other impls (ECL, ABCL, Clasp) that warrant
    inclusion, or that should be explicitly out of scope and why?
A3. **AMOP conformance per impl:** how closely does each track the AMOP
    metaobject protocol the contract's MOP surface depends on? Where they diverge,
    what does that cost a portable contract — and is a non-MOP fallback needed for
    weaker impls?

## Part B — Deep bridge prior art (→ 030 object-model + contract, 050 runtime)

For **CCL** primarily, and **LispWorks**/**AllegroCL** where a bridge exists:
1. How is an ObjC class represented as a CLOS class — what metaclass, storing
   what (ObjC `Class` pointer, ivar layout, method cache)?
2. How are ObjC instances represented (foreign ptr / CLOS instance / hybrid)? How
   does `slot-value` / `slot-value-using-class` map to ObjC ivars?
3. How are ObjC methods exposed — `defgeneric` per selector? selector →
   generic-fn naming; multiple dispatch vs ObjC single (receiver) dispatch.
4. `make-instance` → `alloc`/`init`; subclassing (`defclass … :metaclass …`) →
   `objc_allocateClassPair` + IMP registration; what `define-objc-method` does.
5. **Static vs dynamic:** CCL synthesizes classes *dynamically* from the live
   runtime. What breaks / is lost under APIAnyware's **static emit** (D3)? Where
   does each bridge rely on runtime introspection a static emitter must bake in?

## Part C — Contract surface & cross-impl portability (→ 030 contract, D5)

6. Document each bridge's user-facing surface precisely — the `ns:` package,
   naming conventions, selector reader macros (CCL `#/`), type/number bridging —
   enough to decide **adopt CCL's conventions vs define our own** as the contract.
7. Error handling: conditions / restarts / multiple values per impl (feeds the
   contract's **condition hierarchy** for `NSError**`).
8. Is there any **existing cross-impl Cocoa-in-CL contract** to borrow? How
   portable is CCL-bridge code to the others in practice?

## Part D — Lifetime / threading / callbacks (→ 030, 050)

9. ObjC retain/release vs CL GC per impl — finalizers, weak refs, autorelease-pool
   conventions.
10. Callbacks on foreign (AppKit) threads + main-thread affinity (feeds SBCL's
    `sb-thread` activation question).

## Done when

- A research doc answers A–D **structured around these questions**, with a
  **"Synthesis for 030"** section pre-judging the contract/object-model decisions
  where evidence is clear, and an explicit **family-roster recommendation**
  (which impls in, which out, why). Placement likely main-tier `docs/research/`
  (the contract spans the family).
- Every failure-mode / design / maturity claim carries a **primary-source
  citation** (source file, manual page, mailing-list/issue URL). Absences are
  findings.
- A **walk-away check** per bridge: with it uninstalled, what is still legible /
  borrowable?

## Notes

- Bias toward *what each bridge learned the hard way* (post-mortem framing), not a
  feature tour.
- CCL source areas to cite by file: `objc-runtime.lisp`, `objc-clos.lisp`,
  `bridge.lisp`, the `ns` package, `define-objc-method`. LispWorks: the
  "Objective-C and Cocoa" manual chapters. AllegroCL: the FFI / macOS docs.
- The `deep-research` skill is a natural fit for this leaf.

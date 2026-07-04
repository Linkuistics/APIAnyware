# A same-language family with a portable object model may share a spec-level interface contract

Establishes the **CL-family interface-sharing axis**: the Common Lisp targets
(SBCL built now; CCL, AllegroCL, LispWorks on the roster) share a **single,
documented, specification-level interface** — the `ns:` package, class and
generic-function names, instantiation/subclassing/method-definition macros, slot
access, and the condition hierarchy — so that **application source is portable
across CL implementations**, even though each compiles to an entirely different
FFI under the hood. This is a **scoped exception** to **ADR-0011** (targets are
hermetically isolated; only the API analysis is shared): ADR-0011 isolates
*substrate*; this ADR shares an *interface*. The contract itself is specified in
`targets/_shared/docs/design/2026-06-20-cl-family-interface-contract.md`; this ADR records *that*
the axis exists, *why* it is permitted, and *how narrowly* it is scoped.

## The gap in ADR-0011 this scopes

ADR-0011 was justified for **paradigmatically-alien** targets: Prolog, Haskell,
Idris2, TypeScript are so different from today's Scheme-ish targets that a shared
substrate would be the wrong abstraction for them, so each target shares *nothing*
downstream of the analysis IR. That reasoning is sound and **stays in force for
substrate** (native library, runtime, emitter semantics).

But ADR-0011 never considered the case of **two implementations of the same
standardized language**. SBCL and CCL are both Common Lisp; an application that
calls `(make-instance 'ns:ns-window …)` and subclasses `ns:ns-view` should run on
either without change. Sharing the *interface* it is written against is not the
shared-substrate ADR-0011 forbids — it is a different axis ADR-0011 is silent on.
This ADR fills that gap with a sharp precondition rather than a blanket licence.

## The precondition (decision C3) — eligibility is gated, not assumed

A language family qualifies for a spec-level interface contract **only if it has a
single, standardized, well-accepted object/interface model portable across its
implementations.** The contract needs something concrete to bind to; absent a
common object model, there is nothing to specify portably.

- **Common Lisp qualifies.** **ANSI CLOS + the AMOP** is one standardized object
  model that every listed impl provides. A portable MOP surface is therefore
  *feasible* — the contract binds to CLOS classes, generic functions, and the
  metaobject protocol, which mean the same thing across impls (modulo conformance
  gaps papered over by `closer-mop`, research §A3).
- **The Scheme family does *not* qualify** — and is therefore **ineligible, not
  merely abstaining.** Scheme is fractured: not all Schemes have an object system,
  and those that do (Racket's class system, TinyCLOS, Gerbil's `defclass`/MOP) are
  mutually incompatible. There is **no well-accepted object model portable across
  Scheme implementations** for a contract to bind to. racket/chez/gerbil stay
  fully hermetic under ADR-0011's default — not by choice, but because the
  precondition fails. *(If a portable Scheme object model ever became
  well-accepted, this would be a different argument.)*

Stating the criterion generally makes it a reusable test; gating it this tightly
keeps it from eroding ADR-0011's isolation. CL is, today, the only family that
meets it.

## The shared thing is the *interface*, never the *code* (decision C1)

What is shared is **observable behaviour**; what stays per-impl is **mechanism**.
The contract specifies the application-facing surface — package, names, what
`make-instance` does, what `slot-value` reaches, the macros an application writes,
the conditions it can handle. It deliberately does **not** specify the realization:
the metaclass, the FFI, the slot/dispatch hooks, threading, and distribution are
all below the contract.

This is what lets **LispWorks be a first-class member** despite using a plain
`standard-class` + `standard-objc-object` model instead of SBCL/CCL's `objc-class`
metaclass (research §B1/§7.6). Subclassing is specified as a **portable macro**
(`define-objc-subclass`) whose expansion each impl writes itself — spec-shared,
implementation-hermetic, exactly like `make-instance`. No shared *binding code*
ever crosses the impl boundary.

## Why spec-shared and not code-shared — the Objective-CL post-mortem

The tempting alternative — a **portable shared binding layer** (e.g. one CFFI-based
core all impls link) — is **refuted by direct prior art.** **Objective-CL**
(research §C3) is exactly this experiment: an explicitly multi-implementation
CL/ObjC bridge targeting **six** CL systems, mapping ObjC classes *and*
metaclasses onto CLOS and adopting CCL's `#/` reader macro. Its project page
documents the failure mode in primary source: its "six implementations" was partly
aspirational, breaking per-impl on **MOP/FFI divergence** — CCL hung in
`collect-classes`; CMUCL's MOP lacked funcallable-instance-function closures;
LispWorks' FFI was incompatible with the GNU ObjC runtime. (`closer-mop` exists
precisely because AMOP divergence is normally *papered over*, not assumed away —
research §A3.)

The lesson is exact: **the only sustainable cross-impl surface is the spec-level
one** (package, names, macros, conditions); shared *binding code* breaks on the
divergence that the per-impl FFI and MOP differences guarantee. That is the
evidentiary backbone of this ADR — and of why the **Swift-library C ABI**
(ADR-0025), not a shared Lisp core, is the right convergence substrate: it is the
one cross-impl thing that *can* also reach Swift-only APIs.

## Considered options

- **Full hermetic isolation, no contract (ADR-0011 default).** Each CL impl is an
  island like the Scheme targets. Cheapest; loses the portable-application-source
  goal (D5) for a family that is structurally able to deliver it, and lets each CL
  impl reinvent the `ns:` surface incompatibly — wasting the de-facto standard CCL
  already established.
- **Shared binding code — a portable CFFI/MOP layer (rejected).** One linked core
  all impls share. Directly refuted by Objective-CL's per-impl breakage; also
  reopens ADR-0005 (CFFI is the portable-subset FFI we already rejected) and
  breaches ADR-0011's substrate isolation. The wrong axis.
- **Spec-level interface contract, gated on a portable object model (chosen).**
  Share the *interface* (CLOS surface), keep the *implementation* per-impl and
  idiomatic. Eligibility gated on the C3 precondition so it does not generalize to
  ineligible families. Captures the portability value with none of the
  shared-code fragility, and aligns with CCL's existing surface for de-facto
  portability with the existing CL-Cocoa codebase.

## Consequences

- **A new shared artifact, `targets/_shared/docs/design/2026-06-20-cl-family-interface-contract.md`**,
  is **main-tier** (ADR-0024) because it is cross-target within the CL family, not
  a per-target unit. SBCL is built to conform to it; the other three roster members
  shape what it must abstract over but are not built (D5a).
- **ADR-0011 is unchanged for substrate.** Native library, runtime, and emitter
  semantics stay hermetically per-impl. This ADR adds an *interface-sharing axis*
  ADR-0011 did not contemplate; it does not weaken substrate isolation.
- **ADR-0005 is not reopened.** The share is spec-level; `sb-alien` stays. CFFI is
  still rejected.
- **The contract's lower layer is the ADR-0025 trampoline C ABI**, per-target
  hermetic (ADR-0011/0029). Same shared IR → same C ABI → same surface is the
  mechanism by which the family actually converges; the contract documents the
  upper surface that convergence produces.
- **Eligibility is a reusable test, not a CL carve-out.** A future same-language
  family that acquires a standardized portable object model could adopt the same
  axis; the Scheme targets do not, today, qualify.
- **`CONTEXT.md` is corrected.** Its *CL-family interface contract* entry currently
  lists "the `objc-class` metaclass / MOP protocol" as part of the *shared
  surface*; per decision C1 the metaclass is **mechanism, below the contract** —
  the glossary entry is updated to match (the shared surface is package/names/
  macros/conditions; the metaclass is SBCL/CCL's private realization).

See `targets/_shared/docs/design/2026-06-20-cl-family-interface-contract.md` for the contract
itself, `targets/_shared/docs/research/cl-cocoa-bridges-across-the-family.md` for the prior-art
evidence (esp. §C3 Objective-CL, §7.6 LispWorks, §A3 AMOP), ADR-0011 for the
isolation this scopes, ADR-0005 for the idiom posture it preserves, ADR-0010/0025
for the native-library/trampoline lower layer, and ADR-0024 for the doc placement.

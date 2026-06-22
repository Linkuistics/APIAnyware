# contract-and-family-adr-k4

**Kind:** planning

## Goal

Author the **CL-family interface contract** spec (the upper layer) and raise the
**family-axis ADR** that scopes the ADR-0011 exception permitting it. This is the
shared, spec-level interface every CL impl conforms to even though each compiles
to a different FFI; only **sbcl** is built (D5a), but the contract is authored
against the four-member roster (SBCL, CCL, AllegroCL, LispWorks).

## Context

Read: `done/010-plan` (D5/D5a), `done/020-…` research **§C1–C3, §7.2/§7.5/§7.6**,
CONTEXT.md *CL-family interface contract* + *MOP projection* + *`libAPIAnywareSbcl`
/ sbcl trampoline layer*, ADR-0011 (isolation — the exception this ADR scopes),
ADR-0024 (doc placement), ADR-0025 (two-layer model: this contract's lower layer
is the C-ABI trampoline).

**Pre-judged (020 §7.2 — burden on the counter-argument):** adopt CCL's
conventions wholesale — `ns:` package, NS-prefix-retained **acronym-aware**
kebab-case naming (020 §5 refuted the naive per-capital rule; `NS`/`URL` are whole
words), keyword-list selectors, `#/` + `@` reader macros. De-facto multi-impl
standard (Objective-CL borrowed them).

**Two layers to specify (ADR-0025 framing):**
- **Upper** — the CL surface: `ns:` package, class names, generic-function names,
  the `objc-class` metaclass / MOP protocol, the **condition hierarchy** (CL idiom
  for `NSError**`; the hierarchy *itself* is designed in `030-…-conditions`, but
  the contract declares it is part of the surface).
- **Lower** — `libAPIAnywareSbcl`'s exported **C ABI** (designed in
  `040-trampoline-layer`): the artifact that *forces* convergence (same shared
  analysis → same C ABI → same surface) and delivers Swift-native coverage.

## Open question to resolve here

- **LispWorks divergence (020 §7.6):** LispWorks uses a **non-metaclass**
  `standard-class` + `:objc-instance-vars` model. Decide whether the contract
  **privileges the metaclass shape** (sbcl/CCL) with a documented LispWorks
  fallback, or **abstracts over both**. Evidence shows the divergence but not the
  resolution. Recommendation to pressure-test: privilege the metaclass shape
  (sbcl + CCL, the deeply-evidenced impls) and document LW conformance as a
  qualified/fallback tier, rather than weakening the contract to its lowest common
  shape — but verify against what the contract actually needs to *guarantee*.

## Done when

- CL-family contract spec written **main-tier** (`docs/specs/`-style, decided in
  the node brief), specifying both layers and the LispWorks posture.
- Family-axis ADR raised: scopes the ADR-0011 exception for same-language
  families; cites Objective-CL's per-impl-breakage post-mortem (020 §C3) as the
  rationale for *spec-shared, implementation-hermetic*. Does **not** reopen the
  CFFI question (ADR-0005) or overturn ADR-0011's substrate isolation.

## Decisions (running log)

**C1 — Normative boundary: observable behaviour is normative; the metaclass
mechanism is implementation-private.** (Grilled, user-chosen 2026-06-20.) The
contract specifies the *application-facing surface* — `ns:` package, class/gf/
selector naming, `make-instance`→alloc/init, `slot-value`→ivar access, the
condition hierarchy, and a **portable subclassing macro `define-objc-subclass`**
— as observable behaviour. The `objc-class` **metaclass is SBCL/CCL's private
conformance mechanism, *not* normative surface**: the macro expands to
`(defclass … (:metaclass objc-class))` on SBCL/CCL and to `standard-class` +
`standard-objc-object` on LispWorks (§B1). Consequence: **LispWorks is a
first-class conformant member**, not a fallback tier — the open question from the
brief is resolved by *lowering* the metaclass out of the contract rather than
privileging it. This **corrects the `CONTEXT.md` glossary**, which currently
mislists "the `objc-class` metaclass / MOP protocol" as part of the *shared
surface*; the research (§7.6 LW divergence, §C3 Objective-CL post-mortem) shows
the only sustainable cross-impl surface is spec-level (package/names/macros/
conditions), never a shared mechanism. The macro is **spec-shared, implementation-
hermetic** — exactly like `make-instance` (in the contract; wired per-impl) — so
it does not breach D5 / ADR-0011 (no shared binding *code*; each impl implements
the macro in its own emitter/runtime). "Adopt CCL wholesale" (020 §7.2) still
holds for *naming/package/reader-macro conventions*; subclassing is the one place
the surface is wrapped in a portable macro to keep LW first-class.

**C2 — Method definition: separate `define-objc-method` is canonical; inline
`(:methods …)` is contract-permitted sugar.** (Grilled, user-chosen 2026-06-20.)
The normative method-definition form is a **separate `define-objc-method`**
(matching CCL `objc:defmethod` and Objective-CL `define-objective-c-method` — both
separate forms, §B4/§C3), CLOS-`defmethod`-style with `call-next-method` and
explicit parameter types. It supports incremental method addition and the delegate
pattern (many protocol methods on one subclass). The contract *also* permits an
inline `(:methods …)` clause in `define-objc-subclass` as **sugar that expands to
`define-objc-method`**, for the define-class-and-its-methods-together case. Minimal
normative core (one form), precedent-aligned, ergonomic common case.

**C3 — ADR-0033 scopes a *general* exception gated on a sharp precondition; CL is
the only family that currently meets it.** (Grilled 2026-06-20; user refined the
criterion.) The exception to ADR-0011 is stated as a **general principle** so it
is a reusable decision criterion, but the precondition is **not** "demand for
portable app source" — it is **the family must have a single, standardized,
well-accepted object/interface model portable across its implementations.** CL
meets it: **ANSI CLOS + AMOP** is one standardized object model shared by every
impl, so a spec-level contract has something concrete to bind to. The **Scheme
family is *ineligible*, not opted-out** (user steer): Scheme is fractured — not
all Schemes have an object system, and those that do (Racket classes, TinyCLOS,
Gerbil's `defclass`/MOP) are *quite different* with no well-accepted portable
model; there is nothing for a cross-impl contract to bind to. "It would be a
different argument if there were a well-accepted model portable across Scheme
implementations" — eligibility is conditional on such a model *existing*, and for
Scheme it does not. So ADR-0033: general criterion, instantiated for CL, Scheme
fails the precondition (not a choice). ADR-0011 substrate isolation unchanged;
this remains a *spec-level interface* exception, never a shared-substrate one.

## Notes

- Spec-level share **only** — never shared binding code (the rejected
  "portable CFFI layer"). Different FFI per impl is the whole point.

# 010-contract-and-family-adr

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

## Notes

- Spec-level share **only** — never shared binding code (the rejected
  "portable CFFI layer"). Different FFI per impl is the whole point.

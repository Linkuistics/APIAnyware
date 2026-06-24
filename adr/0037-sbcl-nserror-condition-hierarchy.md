# SBCL surfaces `NSError**`/`NSException` as a flat `ns:objc-error` condition hierarchy

**Status:** accepted

Designs the **condition hierarchy** the CL-family interface contract
(**ADR-0033**, spec §3.7) declared but deferred (grove leaf
`030-design/030-lifetime-threading-conditions`, C2/Q8). The contract already fixed
the *direction* — Cocoa errors surface as **signalled CL conditions**, *not* as
returned `(values result error)` pairs (the CL idiom for `NSError**`), with a named
`ns:` root all such conditions descend from. This ADR confirms the root name and
designs the sub-hierarchy, slots, restarts, and mechanics. The prior-art survey
found **zero** evidence here (research §C2) — this is first-principles design.

## Decision

A **flat hierarchy, split by source**:

- **Root `ns:objc-error`** (subclass of CL `error`) — confirms the contract's
  provisional name. The stable, family-portable `handler-case` target.
- **`ns:cocoa-error`** (`: ns:objc-error`) — the **`NSError**` out-parameter** path.
  Carries the bound `ns:ns-error` instance, with `domain` / `code` / `user-info` /
  `localized-description` readers that delegate to it.
- **`ns:objc-exception`** (`: ns:objc-error`) — the **`NSException`** path. Carries
  the exception, with `name` / `reason` / `user-info` readers.

The condition types are deliberately **distinct symbols** from the MOP-projected
CLOS classes `ns:ns-error` and `ns:ns-exception` (ADR-0034): the signalled CL
*condition* and the bound ObjC *object* are different things. The condition wraps
the object; it does not reuse its name.

**No per-(domain×code) subclasses.** Callers branch on the `domain` / `code`
readers inside a handler. Restarts are **minimal**: a runtime `signal-cocoa-error`
helper establishes `use-value` (return a caller-supplied substitute as the call's
result) and `continue` / `return-nil` (proceed with `nil`); `retry` (re-sending the
ObjC message) is deferred until a sample app needs it.

## Mechanics

- **Key on the primary return value, not on the error being set.** ObjC signals
  failure by returning `nil`/`NO` **and** populating `NSError**`; the out-param may
  hold garbage on success. The generated method signals **only** when the primary
  return indicates failure (`nil` for object returns, `NO` for `BOOL` returns), per
  Apple's "check the return value, not the error" rule.
- **One signaller for two sources.** The **same** `ns:cocoa-error` signaller serves
  both the direct ObjC `NSError**` path and the **Swift-`throws` trampoline**: a
  `ThrowsBridge` (the gerbil ADR-0029 analogue, in `libAPIAnywareSbcl`) surfaces the
  Swift error as an `NSError**` out-param across the flat C ABI, which feeds the
  identical signaller. The condition surface is the contract's; the bridge is the
  trampoline layer below it.
- **Pool unwinds safely.** `with-autorelease-pool` is built on `unwind-protect`, so
  a signalled non-local exit through a pool body still drains the pool — reclaiming
  the very concern chez **ADR-0006** avoided by choosing *not* to raise. The CL
  family pays the unwind cost deliberately because signalled conditions are the
  contract's normative idiom.

## Considered options

- **Flat, split by source (chosen).** Smallest normative contract surface; trivial
  for every CL impl (SBCL/CCL/LispWorks/AllegroCL) to conform to portably; the
  `domain`/`code` readers cover the branching real callers do.
- **Curated well-known-domain subclasses** (`ns:url-error`, `ns:posix-error`, …
  under `ns:cocoa-error`). Rejected: buys type-based `handler-case` for a handful of
  domains at the cost of a larger contract surface every family member must
  reproduce — net negative on the contract-portability axis (ADR-0033).
- **Fully generated per-domain taxonomy** from the IR's error-domain constants.
  Rejected: most CL-idiomatic type dispatch, but bloats the normative contract,
  imposes a heavy per-impl conformance burden, and the domain space is partly
  framework-defined (dynamic) — a static taxonomy is always incomplete.
- **Return `(values result error)` (chez ADR-0006).** Already rejected *at the
  contract level* (ADR-0033): CL idiom is signalled conditions + restarts, not
  error tuples. Recorded here only as the cross-target contrast.

## Consequences

- **Back-fills contract spec §3.7** with the confirmed root (`ns:objc-error`), the
  two source-branches, the readers, and the restart set. SBCL conforms by the
  metaclass-backed mechanism; other family members realize the *same* surface
  through their own FFIs (ADR-0033 C1).
- **Hard to reverse:** every fallible generated method's surface and the contract's
  error-handling face carry this shape; changing it later is a cross-binding +
  cross-app rewrite.
- The `signal-cocoa-error` helper and the three condition types live in the sbcl
  runtime `objc` cluster; the emitter routes `NSError**`-bearing selectors to the
  signaller (build leaf `050`); the `ThrowsBridge` lands with the trampoline layer
  (leaf `040`).
- **`NSException` capture is secondary.** Converting an `NSException` to
  `ns:objc-exception` requires the native dispatch core to `@catch` it; the primary
  design is the `NSError**` path. The hierarchy *accommodates* `NSException` (the
  class exists); the catching mechanism is scoped with the native core in `050` and
  is not load-bearing for the common error surface.
- Cross-target: chez **ADR-0006** (the `(values result error)` contrast), gerbil
  **ADR-0029** (`ThrowsBridge`), family contract **ADR-0033** §3.7.

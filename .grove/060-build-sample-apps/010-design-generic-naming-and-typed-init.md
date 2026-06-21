# 010-design-generic-naming-and-typed-init

**Kind:** planning

## Goal

Resolve the two cross-cutting blockers the first real multi-framework app load
(`020-hello-window`) surfaced, BEFORE the app ladder proceeds. Both block every app
(each coloads ≥2 frameworks and constructs typed-init objects). Grill the design,
raise ADR(s), amend the CL-family contract spec §3.2, then decompose into the emitter/
runtime fix leaves. See `020-hello-window.md` running log for the full discovery.

## The two blockers

**B1 — cross-framework generic arity collisions (contract-level).** Kebab-casing drops
the selector `:`, so `foo` (0-arg) and `foo:` (1-arg action) both map to `ns:foo` at
different arities. Foundation emits `(defgeneric ns:cancel (receiver))`; AppKit emits
`(defgeneric ns:cancel (receiver arg0))` → CLOS rejects the incongruent redefinition at
LOAD. The emitter's `generic_arity_conflicts` assumed this was "empty in practice" AND
only runs per-framework (never sees the cross-framework clash). Scope (3 frameworks):
cross-fw `cancel/stop/terminate` + 14 within-AppKit (`activate hide start-animation…`);
grows with framework count.

- **User leaning (2026-06-21): collision-rename the action selector** — keep clean
  fixed-arity generics; the 1-arg action shape gets a distinct `ns:` symbol so `foo`
  (0-arg) and `foo:` (1-arg) no longer collide. Preserves arity clarity + the
  complete-API guarantee (ADR-0025 — no dropped methods). COST: adds a naming rule to
  the portable contract (§3.2), so it must be specified precisely (what the renamed
  action symbol is, deterministically, and how it stays portable across the CL family).
  Alternatives weighed + not chosen: `&optional`-padding; uniform `&rest`; first-wins
  drop (rejected — lossy). Grilling must pin the exact rename rule.
- Needs a GLOBAL generic pass (per-name arity reconciliation across ALL frameworks),
  touching `emit_generics` + `emit_class` (the defmethod side) + the contract spec §3.2.
  ADR-worthy (the §6d/naming axis — likely a new ADR in the 0033–0038 family).

**B2 — typed multi-arg ObjC inits not wired (emitter + runtime).** `make-instance` →
`aw-apply-init` (objc.lisp) handles only 0/1-arg **id** inits (`ecase (length kw-list)
(0)(1)`, args via `aw-ptr`); `register-objc-init` bakes keywords but **no arg types**.
So `NSWindow`'s `initWithContentRect:styleMask:backing:defer:` (NSRect by value + 2 enums
+ BOOL) cannot be constructed via the contract path (§3.3). Flagged as a "documented
refinement" in the runtime + design spec §8 — now due. Fix: emitter bakes per-arg
sb-alien types into `register-objc-init`; runtime marshals a typed `objc_msgSend`
(structs by value, scalars, bools, ids). Less of a design fork than B1 — mechanical,
but spans emitter + runtime; confirm the baked-type representation in grilling.

## Done when

- ADR(s) raised for B1 (+ B2 if it warrants one); contract spec §3.2 amended for the
  rename rule; CONTEXT.md updated for any new term.
- The tree is grown with the emitter/runtime fix leaves (this leaf decomposes), OR the
  fixes are small enough to land here — decided during grilling.
- A clean regenerate (`--target sbcl`) + the full Foundation+AppKit+CoreGraphics load
  (via `apps/_support/load-bindings.lisp`) succeeds, and NSWindow constructs via
  `make-instance` with its designated-init initargs. That green load is what unblocks
  `020-hello-window`.

## Notes

- This leaf is design that 030-design did not catch; placed inside 060 (ahead of the
  apps) because the apps are its forcing function and consumer.
- Pace for the apps themselves: checkpoint-each-app (build+VM-verify one, report, wait).

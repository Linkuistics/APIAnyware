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

## Outcome (COMPLETE 2026-06-21)

Both blockers resolved + a third finding fixed; design recorded in **ADR-0039**
(selector-structure-preserving naming) + **ADR-0040** (typed init appliers + FP-trap
masking), contract spec §3.2 amended, CONTEXT.md updated. Acceptance met: a clean
`--target sbcl` regenerate, the full Foundation+CoreGraphics+AppKit tree loads (5.3 s,
all classes finalize), and **NSWindow constructs via `make-instance` with its 4-arg
designated init** (by-value `NSRect` + 2 enums + `BOOL`) and a title round-trips. All
emit-sbcl tests + all 7 runtime smokes green.

- **B1 fixed by D1 alone** (no reconciliation pass): `naming::generic_name` renders each
  `:`→`_`, hump→`-`. Goldens re-blessed; `generic_arity_conflicts` now never fires.
- **B2 fixed by D3:** `register-objc-init` bakes a typed applier closure (`&optional`,
  legacy fallback preserved); `aw-apply-init` funcalls it. Any arity / by-value struct.
- **NEW finding (now in ADR-0040):** SBCL enables IEEE FP traps by default; AppKit's NaN/∞
  intermediates crash any GUI app. Runtime masks traps (`aw-mask-fp-traps`) at load + in
  the startup hook. Plus `aw-with-rect`/`-point`/`-size` stack-allocating geometry macros
  (by-value, non-leaking) — the apps' geometry primitive.
- **020-hello-window is UNBLOCKED.**

## Running decision log (grilling, 2026-06-21)

- **D1 — selector structure is PRESERVED via `colon → _`.** Every ObjC selector renders
  each `:` as `_` and each camelCase hump as `-` (`objectAtIndex:` → `ns:object-at-index_`,
  `setTitle:` → `ns:set-title_`, `drawTitle:withFrame:inView:` →
  `ns:draw-title_with-frame_in-view`, `cancel` → `ns:cancel`, `cancel:` → `ns:cancel_`).
  The two separator classes never merge, so the selector→symbol map is **injective** —
  the B1 arity collisions vanish (no rename table needed). Chosen over collision-only
  underscoring because the `_` **preserves the argument-description nature** of ObjC
  selectors (the bare `-` form erased the colon, hiding "takes an argument"). User-chosen
  2026-06-21. **CROSS-TARGET RULE:** "preserve selector structure" should become a macOS-API
  binding rule across ALL targets (racket/chez/gerbil) — captured for those groves.
- **D2 — namespaces: single `ns:` package; integrity is an ANALYSIS-phase invariant, NOT
  an emitter check.** Selectors/generics stay one global namespace (ObjC SELs are
  process-global; the class graph spans frameworks so CLOS needs one generic per selector
  for cross-framework override/`call-next-method`). Non-selector names have framework homes;
  the retained `NS`/`CG`/`WK` prefixes ARE the namespace reflection (0 cross-fw collisions
  across Foundation+AppKit+CoreGraphics). **Key:** macOS's surface is collision-free by
  construction (globally-unique class names / C symbols / selector strings), and D1's
  naming is **injective**, so it introduces no collision macOS didn't have → **no
  emitter-side collision detector**. If integrity is ever violated (e.g. acronym-table
  non-injectivity), that is a SHARED analysis/collection-phase concern, caught once for
  all targets — the SBCL emitter "shouldn't need to even check" (user, 2026-06-21).
- **D1 consequence — B1 needs NO reconciliation pass.** Because `colon→_` is injective,
  distinct selectors map to distinct symbols and identical selectors (same ObjC SEL across
  frameworks) map to the same symbol at the same arity. So per-framework `generics.lisp`
  files compose without clashing — the fix is the naming change ALONE (no global generic
  pass, no rename table, no first-wins drop). `generic_arity_conflicts` becomes a
  defensive assert that should never fire.
- **D3 — typed multi-arg inits (B2).** Mechanical: emitter bakes per-arg sb-alien types into
  `register-objc-init`; runtime `aw-apply-init` marshals a typed `objc_msgSend`. No fork.

## Notes

- This leaf is design that 030-design did not catch; placed inside 060 (ahead of the
  apps) because the apps are its forcing function and consumer.
- Pace for the apps themselves: checkpoint-each-app (build+VM-verify one, report, wait).

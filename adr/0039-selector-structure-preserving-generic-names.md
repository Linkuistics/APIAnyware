# Selector-structure-preserving generic names — each `:` → `_`, each camelCase hump → `-`

Decides how the **sbcl** target maps an ObjC selector to its `ns:` generic-function
symbol, refining the contract's §3.2 naming rule (**ADR-0033**) and the SBCL dispatch
design (**ADR-0034** §2, "one `defgeneric` per selector"). Surfaced by the first real
multi-framework app load (`060-build-sample-apps/020-hello-window`), which it unblocks.
Applies the **complete-API** model (**ADR-0025**): the bound surface is the whole macOS
API, which is collision-free by construction.

## Context — the colon-dropping kebab collided distinct selectors

The original SBCL naming (`naming::generic_name`) kebab-cased a selector's
colon-delimited components and **joined them with `-`**, dropping the colon:
`objectAtIndex:` → `ns:object-at-index`, `cancel:` → `ns:cancel`. That erased the one
bit of structure that distinguishes an ObjC selector's *arity*: `cancel` (0-arg, e.g.
`-[NSOperation cancel]`) and `cancel:` (1-arg, the action shape) **both** mapped to
`ns:cancel`. The emitter assumed ("`generic_arity_conflicts` … empty in practice") that
distinct selectors rarely collide post-kebab. The first Foundation+AppKit load disproved
it: Foundation emitted `(defgeneric ns:cancel (receiver))`, AppKit emitted
`(defgeneric ns:cancel (receiver arg0))`, and CLOS **rejects the incongruent
redefinition at load** — the whole binding fails to load. Scope: cross-framework
`cancel`/`stop`/`terminate` plus ~14 within-AppKit, growing with framework count. The
camelCase-vs-colon merge also collided genuine multi-arg selectors —
`drawTitleWithFrame:inView:` (2 args) and `drawTitle:withFrame:inView:` (3 args) both
kebabed to `draw-title-with-frame-in-view`.

The check ran per-framework and only WARNed, so it never even saw the cross-framework
clash, and its "first-arity-wins" emission still produced one incongruent `defgeneric`
per framework.

## Decision — preserve the selector's structure in the symbol

Map an ObjC selector to its `ns:` generic-function symbol by rendering **each colon as
`_`** and **each camelCase hump as `-`** (acronym-aware per component). The two separator
classes never merge, so the map is **injective over selector strings**:

| selector | generic |
|---|---|
| `length` | `ns:length` |
| `cancel` | `ns:cancel` |
| `cancel:` | `ns:cancel_` |
| `objectAtIndex:` | `ns:object-at-index_` |
| `setObject:forKey:` | `ns:set-object_for-key_` |
| `drawTitleWithFrame:inView:` | `ns:draw-title-with-frame_in-view_` |
| `drawTitle:withFrame:inView:` | `ns:draw-title_with-frame_in-view_` |

Consequences:

- **No collisions, by construction.** macOS class names / C symbols / selector strings
  are globally unique; an injective name map introduces none. So the SBCL emitter needs
  **no global generic-reconciliation pass, no rename table, and no collision detector** —
  the pre-existing `generic_arity_conflicts` becomes a defensive assert that never fires.
  A distinct ObjC `SEL` shared across frameworks (e.g. `objectAtIndex:`) maps to the same
  symbol at the same arity, so CLOS correctly unifies it into one cross-framework generic
  (preserving override / `call-next-method` across the framework-spanning class graph).
- **Integrity is an analysis-phase invariant, not an emitter check.** If a collision ever
  *did* arise it would mean a naming non-injectivity (e.g. an acronym-table case fold) —
  a shared `collect`/`analyse` concern caught once for all targets, not re-checked per
  emitter.
- **The `_` is a feature, not a workaround.** It preserves the *argument-description
  nature* of an ObjC selector — `ns:object-at-index_` keeps the "takes an argument"
  signal the bare-`-` form erased. (User decision, 2026-06-21; chosen over a
  collision-only underscore, `&optional`-padding, uniform `&rest`, and lossy first-wins.)

### Cross-target applicability

This is a property of **macOS-API selectors**, not of SBCL: the colon carries the
arg-structure on every target. "Preserve selector structure" is therefore proposed as a
**cross-target naming rule** (racket / chez / gerbil) — captured here for those targets'
groves to adopt; only SBCL realizes it in this grove.

## Alternatives rejected

- **Collision-only underscore (rename only the colliding `foo:`).** Needs a complete-API
  collision table and treats the common case as special; the unconditional rule is
  simpler and more regular.
- **Uniform `(receiver &rest args)` generics.** Congruent at any arity but loses arity
  info and forces every method body to destructure — least idiomatic.
- **First-arity-wins drop.** Lossy — drops the losing selector's methods, violating the
  complete-API guarantee (ADR-0025).

## Consequences for code

`naming::generic_name` is the single source of truth; `emit_generics` / `emit_class` /
`emit_protocol` / the facade all route through it, so the change propagates everywhere.
The TestKit + Foundation goldens were re-blessed. Swift-native residual method generics
(`swift_method_generic_name`, label-joined with `-`) are unchanged: a residual method has
no ObjC selector, and its name never carries `_`, so it cannot collide with an ObjC
generic — they stay distinct generics (the lockstep still folds both into
`collect_generics`).

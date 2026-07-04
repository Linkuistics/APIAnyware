# The complete-API binding model and trampoline elision

Each target's binding is *abstractly* a **complete C-ABI re-export of the entire
macOS API** — every Objective-C **and** Swift-native declaration, surfaced to the
target language through a per-target native (Swift) library that vends the whole
API behind a flat C ABI, with a thin static target-language surface over it. This
is the **pure form** of the ADR-0010 design goal ("the per-target native library
*is* the binding"): in the limit the library *is* the API, and the scripting side
is a loader.

The practical form applies **trampoline elision** — the direct-binding
optimisation. Wherever a target can reach an API *without* a re-export, it binds
the API **directly** and skips the trampoline: ObjC methods via `objc_msgSend`,
constants as native target-language literals. Only the **residual that is not
directly reachable** is routed through the native library's C-ABI re-export — a
**trampoline** — chiefly the **Swift-native delta** (USR `s:`, reachable only
across the Swift ABI) plus **pointer-valued constants** (a runtime address can't
be a target-language literal).

The three current targets — racket, chez, gerbil — are the **fully-elided limit**
of this model, **not** an ObjC-only deviation from it. They are all-ObjC, all
directly reachable, with a trampoline library that is ~empty. They look
"ObjC-only" only because the optimisation has nothing left to trampoline; the
binding model under them is already the complete-API one. Framing the current
targets as the optimised case (rather than as a narrower design) is the load-
bearing reframing of this ADR: it means covering Swift-native APIs is *filling in
the elided residual*, not bolting a second mechanism onto an ObjC binding.

This ADR is the user-confirmed charter recorded durably (see the project memory
`project-complete-api-model-and-swift-coverage`, incorporated into this grove's
inbox 2026-06-15). It **refines ADR-0010** with the complete-API framing and the
elision optimisation, and is governed by **ADR-0011** (each target's native
library is hermetically isolated — the trampoline layer is per-target, not a
shared substrate). It stays deliberately at the **model level**: the IR-boundary
changes that make the direct-vs-trampoline split explicit, and the concrete
structure of the trampoline library, are separate decisions taken in their own
ADRs/specs by later leaves of this grove (the IR boundary in 030, the racket
trampoline in 040). This ADR must not pre-empt them.

## Why this is recorded now (the accidental ceiling)

The model is being enshrined *because the shared `collect → analyse` pipeline was
silently enforcing an ObjC-only ceiling that the design never intended*. Traced
evidence (file:line as of this grove's 010-plan, 2026-06-15):

- **The Swift-native delta is dropped at extraction.**
  `non_c_linkable_skip_reason()`
  (`collection/crates/extract-swift/src/declaration_mapping.rs:164-175`) filters
  every top-level `Func`/`Var` whose USR starts `s:` as `SWIFT_NATIVE` —
  recorded in `skipped_symbols`, never surfaced. (The same filter also drops
  `c:@macro@` preprocessor symbols and `c:@Ea@`/`c:@EA@` anonymous enum members
  under separate reasons.) These dropped `s:` functions and constants are exactly
  the residual this model says should be *trampolined*, not discarded.
- **Three ABI kinds are silently un-walked** — worse than dropped, because they
  are not even recorded as skipped. Nodes of kind `Macro`, `TypeAlias`, and
  `AssociatedType` fall through to a bare `_ => {}`
  (`collection/crates/extract-swift/src/declaration_mapping.rs:~102`).
- **Swift *types* are retained, not dropped** — `map_class`/`map_struct`/
  `map_enum`/`map_protocol` run regardless of `s:` USR, and `merge.rs`
  (`merge_swift_into_objc`) folds Swift-only classes/protocols/enums/structs into
  the merged framework IR. So the type surface already flows to the emitters; it
  is the *callable* surface (functions, constants) and the un-walked kinds that
  are missing.
- **Provenance is dead metadata.** `DeclarationSource`
  (`ObjcHeader | SwiftInterface`, `collection/crates/types/src/provenance.rs:60`)
  is *written* during collection but **read nowhere** in `analysis/` or
  `generation/` (verified: the only downstream `.source` reads are the unrelated
  `AnnotationSource`). Consequence: emitters emit `objc_msgSend`-style bindings
  for **all** retained classes — correct for `@objc`-bridged Swift classes (real
  ObjC-runtime presence), but **latently wrong** for genuinely Swift-native ones
  (value types, generics, associated-type protocols, async). The
  direct-vs-trampoline boundary is therefore *accidental* today, not chosen.

⇒ Recording the model makes the boundary **explicit and intended**: this grove is
both **additive** (recover the dropped `s:` functions/constants, cover the
un-walked kinds to the bindable extent, build the trampoline library) and
**corrective** (make `source`/reachability load-bearing so direct-vs-trampoline
is a decided property, not an emergent accident).

## Considered options

- **Leave the model implicit (status quo).** The targets are de-facto ObjC-only;
  the Swift delta is dropped at extraction and nobody records why. Cheapest, but
  it cements the accidental ceiling as if it were the design, mis-frames the
  next target author ("APIAnyware binds ObjC"), and leaves the dead `source`
  metadata as a trap — emitters silently mis-bind Swift-native classes with no
  decision recorded anywhere.
- **Record a "Swift bridge" as a second, parallel mechanism.** Treat Swift-native
  coverage as a bolt-on bridge beside the ObjC binding. Rejected: it frames the
  current targets as the *base* case and Swift as the *exception*, which is
  backwards — it would grow two coordinate mechanisms and two mental models per
  target, fighting ADR-0010's "the native library is the binding" unification.
- **Complete-API model with trampoline elision (chosen).** One model: the binding
  is the whole API behind a flat C ABI; elision is an *optimisation of that one
  model*, and the current targets are its fully-optimised limit. Swift-native
  coverage is "fill in the residual the optimisation left," not a second
  mechanism. One mental model per target, and the reframing makes the existing
  targets retroactively correct-by-design rather than deviations.

## Consequences

- **"ObjC-only target" is retired as a description.** The current targets are the
  fully-elided limit of the complete-API model; docs and future ADRs frame them
  that way. The canonical statement lives in `CONTEXT.md` (the *Complete-API
  binding model*, *Trampoline*, *Trampoline elision* glossary entries, already
  landed) and the README design-goal section.
- **`source`/reachability becomes load-bearing.** Making the direct-vs-trampoline
  split a decided property is the corrective half of the grove. The *mechanism*
  (how the IR carries reachability, how the dropped `s:` symbols are recovered,
  the pointer-constant rule) is decided in 030, not here.
- **A per-target trampoline library is established.** Each target's native (Swift)
  library gains C-ABI trampolines re-exporting its Swift-native residual; the
  emitter binds them. Per ADR-0011 this layer is per-target and shares no
  substrate. The concrete structure is decided per target (racket first, in 040).
- **The model applies to every target, current and future.** racket/chez/gerbil
  are re-run and re-verified under it within this grove; `add-sbcl-clos-target`
  resumes with its paused Swift library reframed as *the trampoline layer of this
  model* (the dependency this grove unblocks).
- **Refines ADR-0010, governed by ADR-0011, deepens ADR-0005.** The idiomatic
  per-target mapping is delivered through the native library that *is* the
  complete-API binding; isolation keeps each target's trampoline layer its own.

See `CONTEXT.md` (*Complete-API binding model* / *Trampoline* / *Trampoline
elision*) for the canonical glossary statement, ADR-0010 for the design goal this
refines, and ADR-0011 for the isolation clause that governs the trampoline layer.

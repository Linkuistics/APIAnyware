# add-swift-native-api-coverage — brief

## Goal

Make every target's binding cover the **whole** macOS API — Objective-C **and**
Swift-native — by realising the **complete-API binding model** (each target is
abstractly a complete C-ABI re-export of the macOS API; in practice we *elide
the trampoline* wherever the target reaches an API directly, and only
**trampoline** the residual it can't). Fix this for **all** current targets
(racket, chez, gerbil) and record the model durably, **before**
`add-sbcl-clos-target` resumes (its paused Swift library becomes the trampoline
layer of this model).

Founding charter (incorporated from inbox 2026-06-15): see
`.grove/done/` history / the project memory
`project-complete-api-model-and-swift-coverage`. Refines **ADR-0010** /
**ADR-0011**.

## Done when

- The complete-API model + trampoline-elision optimisation is **recorded**: a new
  ADR refining ADR-0010, the three glossary terms in `CONTEXT.md`, and the model
  stated in the README/design-goal preamble.
- The pipeline **stops silently dropping** the Swift-native delta it can bind, and
  the **trampoline mechanism** (per-target Swift library re-exporting Swift-ABI
  APIs behind a flat C ABI) is established so those APIs become reachable.
- The full pipeline is **re-run for every target** (racket, chez, gerbil) and
  each is **re-verified** (incl. VM-verify per the project's done-bar).

## Decomposition

Grown by 010-plan. Strategy (D1/D2/D3 in `010-plan.md`): **mechanism first,
frontier grows**; prove the vertical slice on **racket**, then extend to chez +
gerbil; record the model up front.

- **020-record-the-model** — ADR-0025 (refine ADR-0010) + README; CONTEXT terms
  already landed this session.
- **030-ir-boundary** — the one *shared-pipeline* change: make `source`/reachability
  load-bearing; recover dropped `s:` funcs/constants; pointer-constant rule.
- **040-racket-trampoline** — extend `libAPIAnywareRacket` to vend C-ABI
  trampolines; racket emitter binds them.
- **050-racket-rerun-verify** — full rerun + VM-verify (TestAnyware).
- **060-chez-extend** — port to chez (Swift dylib); resolve the ADR-0011
  shared-source question.
- **070-gerbil-extend** — hard case (no Swift dylib, ADR-0017); evaluate Swift
  dylib as a possible build-time win (N1); rerun + VM-verify. Gates grove-finish
  and unpauses `add-sbcl-clos-target`.

## Pointers

- `collection/crates/extract-swift/src/declaration_mapping.rs` — the extract→IR
  mapping; `non_c_linkable_skip_reason()` (≈l.164) is the drop filter.
- `collection/crates/extract-swift/src/merge.rs` — `merge_swift_into_objc`
  (Swift-only classes/types added to the ObjC framework IR).
- `collection/crates/types/src/provenance.rs` — `DeclarationSource`
  (`ObjcHeader | SwiftInterface`).
- `collection/crates/types/src/ir.rs` — the IR vocabulary.
- ADR-0010 (native library is the binding), ADR-0011 (hermetic isolation).

## Notes — perimeter traced in 010-plan (2026-06-15)

The defect is **narrower and broader** than the charter's first read:

1. **Drop perimeter (narrow & precise).** Only **top-level `Func`/`Var` nodes
   whose USR starts `s:`** are filtered → recorded in `skipped_symbols` with
   reason `SWIFT_NATIVE` (`declaration_mapping.rs:164-175`, applied at
   `:72-100`). Also dropped: `c:@macro@` (preprocessor) and `c:@Ea@/@EA@`
   (anonymous enum members) — separate reasons.
2. **Silently un-walked (worse than dropped — not even recorded).** ABI nodes of
   kind `Macro`, `TypeAlias`, `AssociatedType` are skipped entirely
   (`declaration_mapping.rs:~102`).
3. **Swift *types* are RETAINED, not dropped.** `map_class/_struct/_enum/
   _protocol` always run regardless of `s:` USR; `merge.rs` adds Swift-only
   classes/protocols/enums/structs/functions/constants to the merged framework.
   They carry `source: SwiftInterface` and preserve their `s:` USR in
   `doc_refs`. So they already flow into the emitters.
4. **`source` is DEAD metadata.** `DeclarationSource` is *written* in collection
   (extract-objc / extract-swift) but **read nowhere** in `analysis/` or
   `generation/`. Consequence: emitters emit `objc_msgSend`-style bindings for
   **all** retained classes — fine for `@objc`-bridged Swift classes (real ObjC
   runtime presence), **latently broken** for genuinely Swift-native ones
   (value types, generics, associated-type protocols, async). Enum captured with
   sentinel `enum_type = Primitive("swift_enum")`; structs captured without a
   usable constructor path.

⇒ This grove is **additive** (recover dropped `s:` funcs/constants; cover the
un-walked kinds to the bindable extent; build the trampoline) **and
corrective** (make `source` load-bearing so the direct-vs-trampoline boundary is
explicit rather than accidental).

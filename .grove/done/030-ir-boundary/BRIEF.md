# 030-ir-boundary — brief

**Kind:** node (design + build)

## Goal

Make the **direct-vs-trampoline boundary** an explicit, *designed* property of the
shared `collect → analyse` pipeline (ADR-0011 shared analysis), and **stop silently
dropping** the residual we intend to bind. This is the grove's **only**
shared-pipeline change; everything downstream is per-target. Get the contract right
before 040.

## Resolved by grilling (2026-06-15)

Two load-bearing forks were settled with the user; the remaining open items are
code-investigation, not user judgement, and belong to `010-design`.

- **D1 — reachability representation: facts only; emitters derive.** The IR carries
  the **raw facts** (`DeclarationSource`, USR-kind, pointer-ness, type-shape) and
  **no** shared `Direct | Trampoline` classification field. Each emitter derives the
  boundary locally. *Rationale:* reachability is genuinely **per-target** in the
  limit (a target with no Swift FFI may trampoline what another binds directly); a
  shared default would falsely imply one shared answer, against ADR-0011. The
  cross-emitter duplication of the classification logic is the accepted cost (same
  ADR-0010/0011 economics as elsewhere).
- **D2 — D1 scope: additive + corrective.** This increment fixes **both** halves:
  - *Additive:* stop routing top-level `s:` `Func`/`Var` to `skipped_symbols`;
    retain them carrying their facts so they reach the emitter to be trampolined.
    Pointer-valued constants likewise retained with a pointer-ness fact.
  - *Corrective:* make `source`/reachability **load-bearing** so the emitter, from
    the facts, **skips** genuinely Swift-native non-`@objc` types instead of emitting
    the latently-broken `objc_msgSend` bindings it emits today.
  - *Deferred to a later frontier leaf:* walking/recovering `Macro`, `TypeAlias`,
    `AssociatedType` ABI nodes. ("Mechanism first, frontier grows.")

## Still open — for 010-design (code investigation, then ADR + spec)

- **The `@objc` fact.** "Emitter skips Swift-native non-`@objc` types" only works if
  the IR carries a fact distinguishing an `@objc`-bridged Swift class (real
  ObjC-runtime presence → bind directly) from a genuinely Swift-native one (skip /
  trampoline). `DeclarationSource: SwiftInterface` does **not** distinguish them —
  both originate in `.swiftinterface`. **First task of 010-design:** verify whether
  `@objc`-ness is captured in the swift-api-digester nodes / current IR, and if not,
  decide how it is carried.
- **Pointer-constant detection rule.** Define what marks a constant pointer-valued
  (so the emitter routes it to a trampoline rather than a literal).
- **The skipped → retained mechanism.** How recovered `s:` funcs/Vars are retained
  (regular `Func`/`Var` nodes carrying facts) without re-introducing the broken
  paths, and what (if anything) still lands in `skipped_symbols`.
- **Emitter contract.** The cross-target contract for deriving direct-vs-trampoline
  from the facts (consumed concretely by 040 racket, then chez/gerbil).
- **Output:** an ADR (allocate the next free number — 0025 is taken by this grove)
  + a design spec; goldens/snapshot impact noted for 020-build.

## Children

- **010-design** — verify fact-availability (esp. `@objc`-ness), pin the IR facts +
  pointer-constant rule + emitter contract; write the ADR + spec.
- **020-build** — implement the shared-pipeline change (extract-swift + types +
  analyse): stop the drop, carry the facts, record deferred kinds as
  skipped-with-reason; update collected/snapshot goldens; verify the residual flows
  through to enriched IR.

## Pointers

- `collection/crates/extract-swift/src/declaration_mapping.rs` — `non_c_linkable_skip_reason()` (l.164) drop filter; un-walked kinds at `~l.102`.
- `collection/crates/extract-swift/src/merge.rs` — `merge_swift_into_objc`.
- `collection/crates/types/src/provenance.rs` — `DeclarationSource` (dead downstream).
- `collection/crates/types/src/ir.rs` — IR vocabulary.
- ADR-0025 (the complete-API model this leaf makes mechanical), ADR-0010, ADR-0011.

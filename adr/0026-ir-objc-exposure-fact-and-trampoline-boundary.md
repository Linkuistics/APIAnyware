# The `objc_exposed` IR fact and the direct-vs-trampoline emitter contract

Refines **ADR-0025** (the complete-API binding model and trampoline elision) by
deciding the *mechanism* ADR-0025 deliberately deferred: how the shared
`collect → analyse` IR carries the facts that let each emitter derive the
**direct-vs-trampoline boundary**, and what the cross-target emitter contract over
those facts is. Governed by **ADR-0011** (the trampoline layer is per-target; only
the analysis/IR is shared) and **ADR-0010** (the native library is the binding).

This is the single shared-pipeline decision; everything downstream of it is per-target
(racket first, in ADR-0027).

## Context — what the investigation found (2026-06-15)

The boundary design rests on three empirical findings, all verified against
swift-api-digester output and the current IR types:

1. **The `@objc` fact is already in hand, carried twice and in agreement.**
   Running `swift-api-digester -dump-sdk` on a synthetic module with both an
   `@objc` class and a pure-Swift class shows every `@objc`-annotated declaration
   carries **both** `declAttributes: ["ObjC"]` **and** a clang-style `c:` USR
   (e.g. `c:@M@Probe@objc(cs)ObjcExposed`), while pure-Swift declarations carry
   neither (`s:`-mangled USR, empty `declAttributes`). The **USR prefix** is the
   load-bearing signal — it is exactly what the existing drop filter
   `non_c_linkable_skip_reason()` already keys on. No new digester field is
   needed.

2. **`DeclarationSource` is the wrong fact, and `ir::Class` carries no fact at
   all.** `DeclarationSource` (`ObjcHeader | SwiftInterface`) cannot drive the
   boundary: an `@objc` Swift class is `SwiftInterface` yet ObjC-runtime
   reachable. Worse, `ir::Class` has **no `source` and no `usr` field** — so the
   corrective half ("skip genuinely Swift-native classes") *requires* adding a
   new fact to `Class` regardless of framing. So the direct-vs-trampoline boundary
   is driven by an explicit `objc_exposed` fact on `ir::Class`, which is what
   ADR-0025's "make `source`/reachability load-bearing" resolves to in the IR.

3. **The USR test is three-way, not `c:` vs `s:`.** `c:@macro@` (preprocessor)
   and `c:@Ea@`/`c:@EA@` (anonymous-enum members) start with `c:` but are **not**
   dlsym-able. The classifier is: `s:` → Swift-native (retain, trampoline);
   `c:@macro@`/`c:@Ea@`/`c:@EA@` → unrepresentable (still skip); everything else
   (`c:@F@`, `c:@`, `So…`) → directly reachable (retain, direct).

## Decision

### 1. Carry a single derived fact: `objc_exposed: bool`

Add a boolean **`objc_exposed`** to every IR declaration node that has a USR —
`Class`, `Method`, `Property`, `Protocol`, `Enum`, `Struct`, `Function`,
`Constant`. It records one fact: *is this declaration reachable through the
ObjC/C runtime without crossing the Swift ABI?* It is **not** a
`Direct | Trampoline` classification (ADR-0025/D1 forbids a shared
classification field) — the boundary is derived per-target from this fact plus
the type shape.

- **Derived once, in collection, by one shared classifier.** `extract-swift`
  computes `objc_exposed` from the node's USR prefix via a single classifier that
  *subsumes* the current `non_c_linkable_skip_reason()` (so the prefix knowledge
  lives in exactly one place). `extract-objc` sets `objc_exposed: true` for
  everything it produces (clang `c:`/`So` cursors are ObjC-runtime reachable by
  construction).
- **Default true, serialized only when false.** The field defaults to `true` on
  deserialization and is omitted from JSON when true. Consequence: existing ObjC
  goldens are unchanged, and the golden diff is a **precise audit of the
  trampoline residual** — only Swift-native nodes acquire `objc_exposed: false`.
- **Per-member granularity.** Carrying the fact on `Method`/`Property` (not only
  `Class`) handles a merged `@objc` class that has individual `s:`-only members:
  the class is `objc_exposed: true` (bind directly) while a specific Swift-native
  method on it is `objc_exposed: false` (trampoline/skip). This falls out of the
  merge path naturally, since a Swift `s:` method merged onto an ObjC class
  carries its own `objc_exposed: false`.

Pointer-ness is **not** a carried fact: it is already encoded in
`constant_type: TypeRef`. The emitter derives it (see §3).

### 2. Skipped → retained mechanism

Refactor `non_c_linkable_skip_reason()` into a classifier that returns one of
three dispositions for a top-level `Func`/`Var`:

- **Swift-native** (`s:`) → **retain** as a regular `ir::Function` / `ir::Constant`
  with `objc_exposed: false` (previously routed to `skipped_symbols` under
  `SWIFT_NATIVE`). The `SWIFT_NATIVE` skip reason is **retired from the drop
  path** — Swift-native top-level declarations are now bound (trampolined), not
  dropped.
- **Unrepresentable** (`c:@macro@`, `c:@Ea@`, `c:@EA@`) → **still skip**, recorded
  in `skipped_symbols` under `PREPROCESSOR_MACRO` / `ANONYMOUS_ENUM_MEMBER` as
  today (no dylib symbol exists; nothing to bind or trampoline).
- **Direct** (everything else) → **retain** with `objc_exposed: true` (unchanged
  behaviour).

Additionally, the silently un-walked ABI kinds `Macro`/`TypeAlias`/
`AssociatedType` (the `_ => {}` fall-through) are **recorded in `skipped_symbols`
with a `deferred_abi_kind` reason** rather than vanishing. *Recording* them is in
scope; *recovering/walking* them remains a deferred frontier
(ADR-0025, "mechanism first, frontier grows"). After this change
`skipped_symbols` means "genuinely cannot be represented or is deferred", never
"Swift-native and therefore dropped".

### 3. The cross-target emitter contract (derived, per-target)

Each emitter derives the boundary locally from the facts (ADR-0025/D1). The
shared contract — implemented first by 040 (racket), then chez/gerbil — is:

For a retained declaration `d`:

- `d.objc_exposed == true` → **bind directly** (the elided limit: ObjC methods via
  `objc_msgSend`, constants per the constant sub-rule below). Unchanged from
  today.
- `d.objc_exposed == false` AND the target's native library can re-export `d`
  (a top-level function, a pointer-constant; methods at a later frontier) →
  **trampoline** (a C-ABI re-export in the per-target native Swift library;
  ADR-0010/0011).
- `d.objc_exposed == false` AND `d` cannot yet be trampolined (a Swift-native
  class / value type / generic / associated-type protocol in the current
  frontier) → **skip** (emit nothing). This is the corrective fix: today the
  emitter emits latently-broken `objc_msgSend` bindings for these; the contract
  makes it emit nothing instead, until the frontier grows to cover them.

**Constant sub-rule** — independent of `objc_exposed`, the emitter chooses
literal-vs-runtime-read from `constant_type`:

- *pointer-valued* = `TypeRefKind` one of `Class | Id | Pointer | CString | Block
  | FunctionPointer | Selector | ClassRef | Instancetype | Struct`, or an `Alias`
  resolving to one of those. A pointer-valued constant's value is a runtime
  address and **cannot** be a target-language literal.
- *literal-able* = scalar `Primitive` (excluding `void`) or an enum-typed `Alias`
  (`underlying_primitive` set).

Combined: `objc_exposed && scalar` → literal (or numeric dlsym, existing);
`objc_exposed && pointer-valued` → runtime address read via dlsym (existing,
e.g. the `macro_value` CFString path); `!objc_exposed` → trampoline (Swift ABI
re-export), with pointer-ness governing the trampoline's return marshalling.

For the **racket vertical slice (040)** this concretely means: Swift-native
classes are skipped (stop the broken `objc_msgSend`); Swift-native top-level
functions and pointer-constants are trampolined through `libAPIAnywareRacket`;
all ObjC declarations are bound directly, unchanged.

## Considered options

- **Reuse `DeclarationSource` as the boundary.** Rejected: it does not
  distinguish `@objc`-bridged from genuinely Swift-native (both are
  `SwiftInterface`), and `ir::Class` does not carry it anyway.
- **Carry the raw `usr` and let each emitter parse the `s:`/`c:` prefix.**
  Rejected: it duplicates the three-way prefix-classification (including the
  `c:@macro@` / `c:@Ea@` edge cases) across racket/chez/gerbil emitters, when
  that knowledge already lives in one place in collection. The DRY cost is real
  and the edge cases are easy to get subtly wrong per-emitter.
- **Add a shared `reachability: Direct | Trampoline` classification field.**
  Rejected by ADR-0025/D1: reachability is genuinely per-target in the limit (a
  target with no Swift FFI may trampoline what another binds directly), so a
  shared classification would falsely imply one answer. `objc_exposed` is a
  *fact*; the classification stays per-emitter.
- **Derived boolean `objc_exposed`, computed once in collection (chosen).** One
  fact, one classifier, no USR re-parsing downstream, the per-target derivation
  preserved, and a golden diff that precisely audits the trampoline residual.

## Consequences

- **IR schema change.** `objc_exposed: bool` (default true,
  `skip_serializing_if` true) is added to eight IR structs. Every struct literal
  constructing them across `collection/`, `analysis/`, and tests must add the
  field — mechanical churn.
- **`non_c_linkable_skip_reason()` is replaced** by a three-way classifier shared
  with the `objc_exposed` derivation. `SWIFT_NATIVE` is retired from the drop
  path; a `deferred_abi_kind` reason is added for the un-walked kinds.
- **Golden / snapshot impact.** Collected goldens gain
  `objc_exposed: false` on newly-retained Swift-native top-level funcs/constants
  **and** on already-retained Swift-native types (classes/enums/structs/protocols
  with `s:` USRs, which already flow through). `skipped_symbols` loses its
  `SWIFT_NATIVE` entries (those symbols become functions/constants) and gains
  `deferred_abi_kind` entries. `objc_exposed` rides additively through
  resolve/annotate/enrich.
- **Emitter contract is specified, not yet implemented.** 040 (racket) is the
  first implementor; chez/gerbil follow. The full mechanical contract — field
  placements, classifier pseudocode, the pointer-valued type list, the golden
  impact, and the emitter decision tree — is in
  `targets/_shared/docs/design/2026-06-15-ir-objc-exposure-boundary.md`.
- **Refines ADR-0025, governed by ADR-0011, deepens ADR-0010.** The fact makes
  the direct-vs-trampoline boundary an explicit, decided property of the shared
  IR; the derivation and the trampoline layer stay per-target.

See `CONTEXT.md` (*`objc_exposed` (ObjC-exposure fact)*) for the glossary entry,
ADR-0025 for the model this mechanises, and the design spec above for the
implementation-level contract.
</content>
</invoke>

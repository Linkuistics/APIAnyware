# Design spec — the `objc_exposed` IR fact and the direct-vs-trampoline boundary

**Date:** 2026-06-15
**Status:** specifies the implementation of ADR-0026 (refines ADR-0025)
**Implemented by:** `030-ir-boundary/020-build` (shared pipeline); consumed first
by `040-racket-trampoline` (emitter).

This is the implementation-level contract for the one shared-pipeline change of
the `add-swift-native-api-coverage` grove. ADR-0026 records *what* and *why*;
this spec records *how*, in enough detail to implement 020-build and 040 without
re-deriving the design.

## 1. The fact: `objc_exposed: bool`

One boolean recording: *is this declaration reachable through the ObjC/C runtime
without crossing the Swift ABI?* Added to the eight IR declaration structs in
`collection/crates/types/src/ir.rs`:

`Class`, `Method`, `Property`, `Protocol`, `Enum`, `Struct`, `Function`,
`Constant`.

Field definition (identical on each struct):

```rust
/// Whether this declaration is reachable through the ObjC/C runtime without
/// crossing the Swift ABI (clang `c:`/`So` USR cursor, or an `@objc` Swift
/// decl). False for genuinely Swift-native declarations (`s:` USR) that need a
/// trampoline. Drives the per-target direct-vs-trampoline boundary (ADR-0026).
/// Defaults true (the fully-elided ObjC limit) and is omitted from JSON when
/// true, so the golden diff audits exactly the trampoline residual.
#[serde(default = "crate::serde_helpers::default_true", skip_serializing_if = "std::ops::Not::not_eq_true")]
pub objc_exposed: bool,
```

Implementation notes:

- Add `pub fn default_true() -> bool { true }` to `serde_helpers`.
- `skip_serializing_if` must be a predicate that is true when the value is
  `true`. Implement a tiny helper rather than relying on a non-existent method —
  e.g. `fn is_true(b: &bool) -> bool { *b }` and
  `skip_serializing_if = "crate::serde_helpers::is_true"`. (Do **not** use the
  `not_eq_true` placeholder above literally; it is illustrative.)
- Because Rust requires all fields at construction, **every** `ir::Class { … }`,
  `ir::Method { … }`, … literal in `collection/`, `analysis/`, and their tests
  must add `objc_exposed: <value>`. This is the bulk of 020-build's mechanical
  churn. In test literals where the value is irrelevant, `objc_exposed: true`
  (the default) keeps existing assertions stable.

## 2. The shared classifier (collection)

Replace `non_c_linkable_skip_reason()` in
`collection/crates/extract-swift/src/declaration_mapping.rs` with a classifier
that both decides retention/skip **and** yields `objc_exposed`. One place owns
the USR-prefix knowledge.

```rust
enum UsrDisposition {
    /// Directly reachable: retain with objc_exposed = true.
    Direct,
    /// Swift-native: retain with objc_exposed = false (→ trampoline downstream).
    SwiftNative,
    /// Unrepresentable: do not retain; record in skipped_symbols with `reason`.
    Skip(&'static str),
}

fn classify_usr(node: &AbiNode) -> UsrDisposition {
    let Some(usr) = node.usr.as_deref() else {
        // No USR: treat as directly reachable (missing metadata is not
        // evidence of non-linkability; every real digester node has a USR).
        return UsrDisposition::Direct;
    };
    if usr.starts_with("s:") {
        UsrDisposition::SwiftNative
    } else if usr.starts_with("c:@macro@") {
        UsrDisposition::Skip(skipped_symbol_reason::PREPROCESSOR_MACRO)
    } else if usr.starts_with("c:@Ea@") || usr.starts_with("c:@EA@") {
        UsrDisposition::Skip(skipped_symbol_reason::ANONYMOUS_ENUM_MEMBER)
    } else {
        UsrDisposition::Direct
    }
}
```

`objc_exposed` for any node = `!matches!(classify_usr(node), SwiftNative)` —
equivalently, `Direct` and `Skip` are both ObjC/C-cursor'd; only `SwiftNative`
is `s:`. (Skip nodes are never retained, so their `objc_exposed` is moot.)

`extract-objc` sets `objc_exposed: true` unconditionally for every node it
produces (clang `c:`/`So` cursors).

## 3. Skipped → retained mechanism (top-level `Func`/`Var`)

In `map_abi_to_framework`, the `"Func"` and `"Var"` arms become:

```rust
match classify_usr(child) {
    UsrDisposition::SwiftNative => {
        // additive change: retain, do NOT push to skipped_symbols
        if let Some(mut f) = map_top_level_function(child) {  // or constant
            f.objc_exposed = false;
            functions.push(f);
        }
    }
    UsrDisposition::Skip(reason) => {
        skipped_symbols.push(ir::SkippedSymbol { name, kind, reason: reason.into() });
    }
    UsrDisposition::Direct => {
        if let Some(f) = map_top_level_function(child) { functions.push(f); } // objc_exposed defaults true
    }
}
```

The deferred ABI kinds change from the silent `_ => {}` to a recorded skip:

```rust
"Macro" | "TypeAlias" | "AssociatedType" => {
    skipped_symbols.push(ir::SkippedSymbol {
        name: child.name.clone(),
        kind: child.decl_kind.clone().unwrap_or_default().to_lowercase(),
        reason: skipped_symbol_reason::DEFERRED_ABI_KIND.into(),
    });
}
"Import" => {} // still ignored
```

Add to `collection/crates/types/src/skipped_symbol_reason.rs`:

```rust
/// Applied by extract-swift to ABI nodes of kind Macro / TypeAlias /
/// AssociatedType that are not yet walked. Recovery is deferred to a later
/// frontier leaf (ADR-0025/D2); recording them here makes the drop auditable
/// instead of silent.
pub const DEFERRED_ABI_KIND: &str =
    "deferred_abi_kind: Macro/TypeAlias/AssociatedType ABI node not yet walked \
     (recovery deferred to a later frontier leaf)";
```

`SWIFT_NATIVE` is no longer emitted (Swift-native top-level decls are retained).
Keep the constant defined for one release for changelog/audit clarity, or remove
it — implementor's call; if removed, drop its one usage and the merge test that
references the string.

Type-mapper nodes that already produce IR types (`map_class`/`map_struct`/
`map_enum`/`map_protocol` and their members) set `objc_exposed` from
`classify_usr(node)` per node — so a Swift-native class gets `objc_exposed:
false`, an `@objc` Swift class gets `true`, and an `s:` method merged onto an
ObjC class carries its own `false`.

## 4. Pointer-constant rule (derivation, no new field)

Pointer-ness is derived from `constant_type: TypeRef` — it is **not** carried.
Specify a shared helper (each emitter implements its own copy, per ADR-0011, or
a shared analysis helper if one already exists):

```text
is_pointer_valued(t: TypeRef) -> bool:
  pointer-valued when t.kind ∈ {
      Class, Id, Pointer, CString, Block, FunctionPointer,
      Selector, ClassRef, Instancetype, Struct
  }
  or t.kind == Alias whose resolved target is pointer-valued
  (Alias with underlying_primitive set → scalar → NOT pointer-valued)
  literal-able otherwise: Primitive (≠ void), enum-typed Alias
```

## 5. Emitter contract (consumed by 040, then chez/gerbil)

Per retained declaration `d`:

| `d.objc_exposed` | trampolinable by target? | emitter action |
|---|---|---|
| `true` | — | **bind directly** (msgSend / literal / dlsym; unchanged) |
| `false` | yes (top-level fn, pointer-const; methods later) | **trampoline** (C-ABI re-export in the per-target native Swift lib) |
| `false` | no (Swift-native class/value-type/generic, current frontier) | **skip** (emit nothing — the corrective fix) |

Constant literal-vs-runtime choice (combines with the table):

- `objc_exposed && !is_pointer_valued` → emit a target literal (or numeric dlsym).
- `objc_exposed && is_pointer_valued` → runtime address read (dlsym; existing,
  e.g. the `macro_value` CFString path).
- `!objc_exposed` → trampoline (Swift ABI re-export); `is_pointer_valued`
  governs how the trampoline marshals its return.

**Racket vertical slice (040):**

- Swift-native classes (`objc_exposed == false`) → **skip** — stop emitting the
  latently-broken `objc_msgSend` bindings emitted today.
- Swift-native top-level functions / pointer-constants → **trampoline** through
  `libAPIAnywareRacket`; the racket emitter binds the C-ABI entry.
- All ObjC declarations → bind directly, unchanged.

## 6. Goldens / snapshot impact (020-build done-bar)

- **Collected goldens** gain `objc_exposed: false` on: newly-retained
  Swift-native top-level funcs/constants; already-retained Swift-native types
  (classes/enums/structs/protocols carrying `s:` USRs) and their members.
- **`skipped_symbols`** loses `SWIFT_NATIVE` entries (now retained as
  funcs/constants) and gains `deferred_abi_kind` entries for the previously
  silent Macro/TypeAlias/AssociatedType nodes.
- **Synthetic-TestKit snapshot** expectations update accordingly.
- **resolve / annotate / enrich snapshots**: `objc_exposed` rides additively;
  affected frameworks' enriched IR changes only by the added field.
- Per `feedback-regenerate-pipeline-aggressively`: re-run the affected stages
  (`collect → resolve → annotate → enrich`) and confirm recovered `s:`
  funcs/constants and the new fact survive into the enriched IR a real target
  reads — do not trust stale checkpoints.

## 7. Out of scope (deferred frontier — ADR-0025/D2)

- Walking/recovering `Macro` / `TypeAlias` / `AssociatedType` (now *recorded* as
  skipped, not recovered).
- Per-method trampolining of Swift-native methods on otherwise-ObjC classes (the
  fact is carried per-method now; the emitter trampoline path for methods is a
  later frontier — 040 skips them, as for Swift-native classes).
- Giving Swift-native enums real raw values / structs a usable constructor path
  (today's sentinel `enum_type = Primitive("swift_enum")` and constructor-less
  structs remain; they are skipped via `objc_exposed == false`).
</content>

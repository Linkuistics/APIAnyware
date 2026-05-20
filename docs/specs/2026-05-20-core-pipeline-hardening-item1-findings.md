# Core Pipeline Hardening — Item 1 Findings: Orphaned-Framework Root-Cause Investigation

**Date:** 2026-05-21
**Status:** DONE (round 2 — supersedes round 1)
**Task:** 5 of the Core Pipeline Hardening plan

> **Round-2 note.** Round 1 proposed the `has_native_types` signal and concluded that
> only `_AppIntents_SwiftUI` and `_SwiftData_CoreData` were broken. That conclusion was
> **wrong**: round 1 never enumerated the foreign-node `declKind`s of the four disputed
> `_*_SwiftUI` frameworks. Round 2 dumped all of them and found that **every one has
> foreign `Class` nodes** that `has_native_types` would wrongly drop. Sections 5–10 below
> are fully rewritten. Sections 2–4 (ABI shapes, per-node signal failure) are unchanged
> and still valid.

---

## 1. Executive Summary

The over-aggressive filter is `is_foreign_module_type_decl` in
`collection/crates/extract-swift/src/declaration_mapping.rs`. It drops **every** top-level
`Class`/`Protocol`/`Struct`/`Enum` whose `moduleName` ≠ framework name.

The frameworks it wrongly orphans are **cross-import overlays**: SDK frameworks whose
*entire* (or majority) public API is `extension`s on types owned by the two bridged
modules. Apple names them with the underscore convention `_<ModuleA>_<ModuleB>` (e.g.
`_RealityKit_SwiftUI` = the RealityKit ⇄ SwiftUI bridge). For an overlay, the digester
emits the bridged types as foreign top-level nodes — that *is* the overlay's API surface,
so the filter must keep them.

Round 1's `has_native_types` proxy misfires: four of the six plan-named overlays
(`_RealityKit_SwiftUI`, `_PhotosUI_SwiftUI`, `_SwiftData_SwiftUI`, `_WebKit_SwiftUI`) DO
have a handful of native helper structs, so `has_native_types` is `true` for them and
their foreign nodes — **including foreign `Class` nodes** — would stay dropped.

**The correct signal is a direct, framework-level classification: is the framework a
cross-import overlay?** A cross-import overlay is identified by its root module name
matching the `_<A>_<B>` underscore convention. For overlays, foreign type decls are kept;
for non-overlays they are dropped.

All evidence below is from `swift-api-digester -dump-sdk` runs against
`MacOSX26.5.sdk` (`-sdk-version 25F70`), `json_format_version: 8`.

---

## 2. ABI JSON Shape: Keep Case (`_AppIntents_SwiftUI`)

Dump command (this machine's `xcrun` default-SDK resolution is broken — `--sdk macosx`
is mandatory):
```bash
xcrun swift-api-digester -dump-sdk -module _AppIntents_SwiftUI \
  -o /tmp/_AppIntents_SwiftUI.abi.json \
  -sdk "$(xcrun --sdk macosx --show-sdk-path)" 2>/dev/null
```

Root name: `_AppIntents_SwiftUI`. Total top-level children: 14 (6 Import + 8 type decls).
**All 8 type decls have `moduleName` pointing to a foreign module.**
There are zero nodes with `moduleName == "_AppIntents_SwiftUI"`.

Representative keep node (verbatim significant fields):

```json
{
  "kind": "TypeDecl",
  "name": "IntentParameter",
  "declKind": "Class",
  "usr": "s:10AppIntents15IntentParameterC",
  "moduleName": "AppIntents",
  "isExternal": true,
  "hasMissingDesignatedInitializers": true
}
```

```json
{
  "kind": "TypeDecl",
  "name": "NSManagedObjectModel",
  "declKind": "Class",
  "usr": "c:objc(cs)NSManagedObjectModel",
  "moduleName": "CoreData",
  "isExternal": true
}
```
(The second is from `_SwiftData_CoreData`, the other zero-native-type overlay.)

Children of every keep-case foreign node:
- All children have `"isFromExtension": true`
- All children have `"moduleName": "<current_framework>"` (e.g., `_AppIntents_SwiftUI`)

Example child:
```json
{
  "kind": "Function",
  "name": "requestConfirmation",
  "declKind": "Func",
  "moduleName": "_AppIntents_SwiftUI",
  "isFromExtension": true
}
```

---

## 3. ABI JSON Shape: Drop Case (`CreateMLComponents`)

Root name: `CreateMLComponents`. Total type decls: 179 (176 native + 3 foreign).

The 3 foreign nodes (verbatim):

```json
{ "kind": "TypeDecl", "name": "Sequence",     "declKind": "Protocol", "usr": "s:ST",                    "moduleName": "Swift",       "isExternal": true }
{ "kind": "TypeDecl", "name": "LazySequence", "declKind": "Struct",   "usr": "s:s12LazySequenceV",      "moduleName": "Swift",       "isExternal": true }
{ "kind": "TypeDecl", "name": "DataFrame",    "declKind": "Struct",   "usr": "s:11TabularData0B5FrameV","moduleName": "TabularData", "isExternal": true }
```

Children of every drop-case foreign node are **structurally identical** to keep-case
children: all have `"isFromExtension": true` and `"moduleName": "CreateMLComponents"`.

```json
{ "kind": "Function", "name": "mapAnnotations", "declKind": "Func", "moduleName": "CreateMLComponents", "isFromExtension": true }
```

---

## 4. Comparison: Why Per-Node Signals Fail

Verified by dumping all 8 frameworks and inspecting every foreign node and all of its
children. **Every per-node and per-child field is identical between keep and drop cases.**

| Signal candidate | Keep case (e.g. `Entity` in `_RealityKit_SwiftUI`) | Drop case (e.g. `Sequence` in `CreateMLComponents`) | Discriminates? |
|---|---|---|---|
| `isExternal` on the type node | `true` | `true` | **No** |
| `isFromExtension` on the type node itself | absent | absent | **No** |
| All member children have `isFromExtension: true` | Yes | Yes | **No** |
| All member children have `moduleName == framework` | Yes | Yes | **No** |
| Node's `moduleName != framework_name` | Yes | Yes | **No** |
| Any overlay/cross-import flag in ABIRoot metadata | (none exists) | (none exists) | **No** |

The ABIRoot top-level metadata is just `{kind, name, printedName, json_format_version,
tool_arguments}` — there is **no** overlay or cross-import flag anywhere in the digester
JSON, neither on the root nor on any node. The discriminator must therefore be derived
from the framework's identity, not read from a field.

`has_native_types` (round 1's proxy) is also non-discriminating — see §6.

---

## 5. Q1 — Foreign-node `declKind`s for ALL eight frameworks

Produced with a python pass over the dumped JSON that lists **every** top-level type node
(no filtering), classifying each as native (`moduleName == root.name`) or foreign.

| Framework | native types | foreign types | foreign `declKind` breakdown | foreign **`Class`** nodes |
|---|---|---|---|---|
| `_AppIntents_SwiftUI`  | 0  | 8 | Class×1, Struct×4, Protocol×3 | **`IntentParameter`** |
| `_SwiftData_CoreData`  | 0  | 1 | Class×1                        | **`NSManagedObjectModel`** |
| `_RealityKit_SwiftUI`  | 14 (Struct×12, Protocol×2) | 8 | Class×2, Struct×4, Protocol×2 | **`MeshResource`, `Entity`** |
| `_PhotosUI_SwiftUI`    | 4 (Struct×4) | 2 | Class×1, Protocol×1            | **`PHLivePhoto`** |
| `_SwiftData_SwiftUI`   | 2 (Struct×2) | 8 | Class×1, Struct×5, Protocol×2  | **`ModelContext`** |
| `_WebKit_SwiftUI`      | 1 (Struct×1) | 3 | Class×1, Struct×1, Protocol×1  | **`WebPage`** |
| `CoreTransferable`     | 11 (Struct×9, Protocol×2) | 6 | Class×1, Struct×4, Enum×1 | `NSItemProvider` (correctly dropped — see §8) |
| `CreateMLComponents`   | 176 (Struct×137, Enum×16, Protocol×22, Class×1) | 3 | Struct×2, Protocol×1 | none |

Full foreign-node listings (name / declKind / moduleName):

- **`_RealityKit_SwiftUI`** — `View`/Protocol/SwiftUICore, `ShapeExtrusionOptions`/Struct/RealityFoundation, **`MeshResource`/Class/RealityFoundation**, **`Entity`/Class/RealityFoundation**, `Binding`/Struct/SwiftUICore, `EnvironmentValues`/Struct/SwiftUICore, `GestureComponent`/Struct/RealityFoundation, `Gesture`/Protocol/SwiftUICore
- **`_PhotosUI_SwiftUI`** — **`PHLivePhoto`/Class/Photos**, `View`/Protocol/SwiftUICore
- **`_SwiftData_SwiftUI`** — **`ModelContext`/Class/SwiftData**, `AppStorage`/Struct/SwiftUI, `SceneStorage`/Struct/SwiftUI, `View`/Protocol/SwiftUICore, `Scene`/Protocol/SwiftUI, `DocumentGroup`/Struct/SwiftUI, `NewDocumentAction`/Struct/SwiftUI, `EnvironmentValues`/Struct/SwiftUICore
- **`_WebKit_SwiftUI`** — `View`/Protocol/SwiftUICore, **`WebPage`/Class/WebKit**, `NavigationAction`/Struct/WebKit
- `_AppIntents_SwiftUI` — **`IntentParameter`/Class/AppIntents**, `IntentParameterContext`/Struct/AppIntents, `IntentResult`/Protocol/AppIntents, `Toggle`/Struct/SwiftUI, `View`/Protocol/SwiftUICore, `ModifiedContent`/Struct/SwiftUICore, `AppIntent`/Protocol/AppIntents, `Button`/Struct/SwiftUI
- `_SwiftData_CoreData` — **`NSManagedObjectModel`/Class/CoreData**

**Answer to Q1: every one of the four disputed `_*_SwiftUI` frameworks has at least one
foreign `Class` node.** Round 1's "fine by design" verdict is refuted: under
`has_native_types` those classes stay dropped, leaving all four at `classes = 0` and
failing the plan's Task 7 criterion.

---

## 6. Q2 — The cross-import overlay signal

Three candidate signals were evaluated against actual evidence.

### Candidate A — `has_native_types` (round 1's proposal)

A framework "has native types" if any top-level type decl has `moduleName == root.name`.
Drop foreign nodes iff `has_native_types == true`.

**Rejected.** It is a proxy for "is this an overlay", and it misfires on the common case
of a *mixed* overlay — an overlay that carries a few native option/config structs
alongside its extensions:

| Framework | overlay? | native types | `has_native_types` | rule verdict | correct? |
|---|---|---|---|---|---|
| `_AppIntents_SwiftUI` | yes | 0 | false | keep | ✓ |
| `_SwiftData_CoreData` | yes | 0 | false | keep | ✓ |
| `_RealityKit_SwiftUI` | yes | 14 | true | **drop** | ✗ loses `Entity`, `MeshResource` |
| `_PhotosUI_SwiftUI` | yes | 4 | true | **drop** | ✗ loses `PHLivePhoto` |
| `_SwiftData_SwiftUI` | yes | 2 | true | **drop** | ✗ loses `ModelContext` |
| `_WebKit_SwiftUI` | yes | 1 | true | **drop** | ✗ loses `WebPage` |

`has_native_types` only happens to be correct for the two overlays that have *zero*
native types. It is wrong for every mixed overlay.

### Candidate B — an overlay/cross-import flag in the ABI JSON

**Does not exist.** The ABIRoot carries only `{kind, name, printedName,
json_format_version, tool_arguments}`. No node — root or otherwise — has an `overlay`,
`crossImport`, or producing-module field. Confirmed by dumping the non-`children` keys of
`_RealityKit_SwiftUI`, `CreateMLComponents`, `CoreTransferable`, `_AppIntents_SwiftUI`.

### Candidate C — the `_<A>_<B>` underscore-prefixed module-name convention  ✅ CHOSEN

Apple's cross-import overlays follow a fixed naming convention: a leading underscore,
then two non-empty module-name tokens joined by an underscore: `_<ModuleA>_<ModuleB>`.
The module's `root.name` *is* this string (verified: `root.name == "_RealityKit_SwiftUI"`
etc.).

Physical-layout evidence (`MacOSX26.5.sdk/System/Library/Frameworks/`):

- Each overlay is its own `.framework` directory containing a matching
  `Modules/<name>.swiftmodule`, so `discover_swift_modules` in `digester.rs` finds them
  as ordinary modules — they are **not** special-cased anywhere in collection today.
- The SDK has **33** underscore-prefixed framework directories. **32** match `_<A>_<B>`
  (all the cross-import overlays — `_AppIntents_AppKit`, `_AppIntents_SwiftUI`,
  `_ARKit_SwiftUI`, `_AVKit_SwiftUI`, `_CoreData_CloudKit`, `_GeoToolbox_AppIntents`,
  `_PhotosUI_WidgetKit`, `_RealityKit_SwiftUI`, `_SwiftData_CoreData`,
  `_SwiftData_SwiftUI`, `_WebKit_SwiftUI`, … 32 total). Exactly **one**,
  `_LocationEssentials`, is underscore-prefixed but has **no internal underscore** — and
  it is correctly NOT an overlay (its dump has 0 native and 0 foreign type decls).
- `CreateMLComponents` and `CoreTransferable` are ordinary frameworks: no leading
  underscore, so they correctly do **not** match.

Collection does **not** already classify modules as overlays and does not carry a
producing-module name; module discovery is purely directory-name based. So the signal
must be computed in `extract-swift`.

**Why C is the most robust signal.** It is a direct, total classification of "is this an
overlay" rather than a proxy. It is computable from data the parser already has
(`root.name`), needs no new ABI field (B does not exist), and does not misfire on mixed
overlays (A's defect). Its only requirement is a precise definition of the name pattern
that excludes the single false positive `_LocationEssentials` — handled by requiring at
least one *internal* underscore between two non-empty tokens (see §7).

---

## 7. Q3 — The correct rule for `is_foreign_module_type_decl`

### Prose

A top-level `Class`/`Protocol`/`Struct`/`Enum` whose `moduleName` differs from the
framework's `root.name` is:

- **kept** when the framework is a **cross-import overlay** — its foreign type decls are
  the bridged types that carry the overlay's entire API surface;
- **dropped** otherwise — in a normal framework a foreign type decl is a spurious
  extension container and keeping it would mis-attribute the framework's extension
  members to that foreign type.

A framework is a **cross-import overlay** iff its `root.name` matches the pattern
`_<A>_<B>[_<C>…]`: a leading underscore, followed by **two or more non-empty,
underscore-free tokens** joined by underscores. Equivalently: the name starts with `_`
and, after stripping the leading `_`, splitting on `_` yields ≥ 2 parts that are all
non-empty.

This requirement of an *internal* underscore is what excludes `_LocationEssentials`
(leading underscore, but only one token after stripping → not an overlay).

The overlay test is on the framework name only; it does not depend on any node field, so
it is computed once per `map_abi_to_framework` call and passed into the filter.

### Pseudocode

```rust
/// True iff `root.name` follows Apple's cross-import overlay convention
/// `_<ModuleA>_<ModuleB>[...]`: leading underscore, then ≥2 non-empty
/// underscore-free tokens. Excludes plain underscore-prefixed private
/// modules such as `_LocationEssentials` (no internal underscore).
fn is_cross_import_overlay(framework_name: &str) -> bool {
    let Some(body) = framework_name.strip_prefix('_') else {
        return false;
    };
    let parts: Vec<&str> = body.split('_').collect();
    parts.len() >= 2 && parts.iter().all(|p| !p.is_empty())
}

fn map_abi_to_framework(doc, sdk_version) -> ir::Framework {
    let root = &doc.root;
    let is_overlay = is_cross_import_overlay(&root.name);
    for child in &root.children {
        if is_foreign_module_type_decl(child, &root.name, is_overlay) {
            continue;
        }
        // ... normal processing ...
    }
}

/// Drop a foreign-module type decl unless the framework is a cross-import
/// overlay (in which case the foreign type decls ARE the overlay's API).
fn is_foreign_module_type_decl(
    node: &AbiNode,
    framework_name: &str,
    is_overlay: bool,
) -> bool {
    let is_type_decl = matches!(
        node.decl_kind.as_deref(),
        Some("Class") | Some("Protocol") | Some("Struct") | Some("Enum"),
    );
    if !is_type_decl {
        return false;
    }
    match node.module_name.as_deref() {
        None => false,                       // missing data: keep
        Some(m) if m == framework_name => false, // native: keep
        Some(_) => !is_overlay,              // foreign: drop unless overlay
    }
}
```

### Data the rule needs

- `root.name` — already on `AbiDocument` / `AbiNode`.
- `node.module_name: Option<String>` — already parsed (`abi_types.rs:56`).
- `node.decl_kind: Option<String>` — already parsed (`abi_types.rs:44`).

**No change to `AbiNode`, the serde parser, or the JSON schema is required.** The only
change is in `declaration_mapping.rs`:

1. add `is_cross_import_overlay(&str) -> bool`;
2. compute `is_overlay` once in `map_abi_to_framework`;
3. add the `is_overlay: bool` parameter to `is_foreign_module_type_decl` and flip the
   final arm from `module != framework_name` to `!is_overlay && module != framework_name`.

### Why this is safe for the drop case

`CreateMLComponents` does not start with `_` → `is_overlay = false` → its foreign
`Sequence` / `LazySequence` / `DataFrame` nodes are still dropped. The
`mapAnnotations`/`mapFeatures` propagation bug stays fixed.

### Why this is correct for the keep case

All six plan-named modules match `_<A>_<B>` → `is_overlay = true` → their foreign type
decls (including the `Class` nodes in §5) are kept. Their native helper structs are
unaffected (native nodes are kept regardless).

---

## 8. Q4 — CoreTransferable

`CoreTransferable` is **not** a cross-import overlay: the name has no leading underscore,
so `is_cross_import_overlay("CoreTransferable") == false`. Under the §7 rule its 6 foreign
nodes (`Never`/Enum/Swift, `AttributedString`/Struct/Foundation, `Data`/Struct/Foundation,
`String`/Struct/Swift, `URL`/Struct/Foundation, `NSItemProvider`/Class/Foundation) are
**dropped** — including the foreign `Class` `NSItemProvider`.

This is **correct**. Those 6 nodes are extension containers: `CoreTransferable` adds
`Transferable` conformances to stdlib/Foundation types via `extension`. They are not part
of `CoreTransferable`'s own declared API. `CoreTransferable`'s real surface is its 11
native type decls — the `Transferable` and `TransferRepresentation` protocols plus 9
native structs (`CodableRepresentation`, `DataRepresentation`, `FileRepresentation`,
`ProxyRepresentation`, …), all with `moduleName: "CoreTransferable"` — and those are kept.

`CoreTransferable` therefore has **0 classes by design** — it is a pure
protocol/struct framework. Round 1's verdict on `CoreTransferable` stands; the §7 rule
reaches the same outcome via the overlay test instead of `has_native_types`.

---

## 9. Q5 — Reconciliation with the plan's Task 7 criterion

### Predicted post-fix class counts (filter fix from §7 only)

For each framework, the `classes` count after the §7 rule equals the number of kept
nodes with `declKind == "Class"`. Overlays keep their foreign classes; non-overlays do
not.

| Module | overlay? | foreign `Class` nodes kept | native `Class` nodes | **predicted `classes` after fix** |
|---|---|---|---|---|
| `_AppIntents_SwiftUI` | yes | `IntentParameter` | 0 | **1** (non-zero ✓) |
| `_RealityKit_SwiftUI` | yes | `MeshResource`, `Entity` | 0 | **2** (non-zero ✓) |
| `_PhotosUI_SwiftUI`   | yes | `PHLivePhoto` | 0 | **1** (non-zero ✓) |
| `_SwiftData_SwiftUI`  | yes | `ModelContext` | 0 | **1** (non-zero ✓) |
| `_SwiftData_CoreData` | yes | `NSManagedObjectModel` | 0 | **1** (non-zero ✓) |
| `_WebKit_SwiftUI`     | yes | `WebPage` | 0 | **1** (non-zero ✓) |

**(a) All six plan-named modules are restored to a non-zero class count by the §7 filter
fix alone.** This is the corrected result: round 1's claim that four of them have "no
class API" was an artefact of never enumerating their foreign `declKind`s. Every one of
the six has at least one foreign `Class` node, and the overlay rule keeps it.

**(b) Modules that legitimately have no class API.** Of the frameworks examined, only
`CoreTransferable` and `CreateMLComponents` have `classes` that stay near-zero after the
fix — and that is correct (`CoreTransferable` = 0 by design; `CreateMLComponents` keeps
its 1 native class, drops the foreign struct/protocol). **Neither is in the Task 7 list,
so no plan-named module needs a class-count waiver.**

**The `annotate` gap (separate follow-up, file regardless).** `annotate` iterates only
`framework.classes`. A framework whose API is entirely structs/protocols (e.g.
`CoreTransferable`, or an overlay whose foreign nodes were all structs/protocols) would
still receive **0 annotations** even when collection is correct, because annotation never
visits `protocols`/`structs`/`enums`. This is a real downstream gap, **independent of the
filter fix**, and it must be filed as its own follow-up task:

> **Follow-up FU-1 — `annotate` must iterate protocols/structs/enums, not only classes.**
> Today `annotate` walks `framework.classes` exclusively, so any framework whose public
> API is non-class (`CoreTransferable`, and the struct/protocol-heavy overlays) gets zero
> annotations even with correct collection. Extend annotation to cover
> `protocols`/`structs`/`enums`. Owner: a post-Task-7 task. Not gated on Task 6.

(Note: with the §7 fix all six Task-7 modules *do* have classes, so FU-1 is not a
blocker for Task 7 — but it is required for those frameworks' non-class API to be
annotated, and for `CoreTransferable` to be annotated at all.)

**(c) Corrected Task 7 success criterion.**

> Re-collect the six cross-import overlay modules `_AppIntents_SwiftUI`,
> `_RealityKit_SwiftUI`, `_PhotosUI_SwiftUI`, `_SwiftData_SwiftUI`, `_SwiftData_CoreData`,
> `_WebKit_SwiftUI`. After the §7 filter fix, **each must report a non-zero `classes`
> count** with at least the foreign `Class` node(s) named in §5 present
> (`_AppIntents_SwiftUI`→`IntentParameter`; `_RealityKit_SwiftUI`→`Entity`,`MeshResource`;
> `_PhotosUI_SwiftUI`→`PHLivePhoto`; `_SwiftData_SwiftUI`→`ModelContext`;
> `_SwiftData_CoreData`→`NSManagedObjectModel`; `_WebKit_SwiftUI`→`WebPage`).
> Additionally, a control non-overlay framework (`CreateMLComponents`) must **not** gain
> any of its foreign `Sequence`/`LazySequence`/`DataFrame` nodes — its `protocols`/
> `structs` must exclude those names. The "non-zero class count" criterion as originally
> written is correct for all six modules; no waiver is needed. (Annotation coverage of
> non-class API is tracked separately as follow-up FU-1 and is out of Task 7 scope.)

---

## 10. Q6 — `AbiNode` / parser status

`AbiNode` in `collection/crates/extract-swift/src/abi_types.rs` **already has every field
the §7 rule needs**:

- `module_name: Option<String>` (line 56) — the foreign-module discriminator.
- `decl_kind: Option<String>` (line 44) — the type-decl gate.
- `name: String` (line 28) on the root `AbiNode` — supplies `root.name`.

`is_cross_import_overlay` is a pure function of `root.name`; the overlay flag is a derived
per-document property, not a node field.

**Task 6 does NOT need to extend `AbiNode`, change the serde deserialisation, or touch
the digester.** The change is confined to `declaration_mapping.rs`.

---

## 11. Test Fixtures for Task 6

The §7 rule must be locked in by tests with **exact** field values. The current foreign
tests (`foreign_module_protocol_with_extension_methods_is_skipped`,
`foreign_module_struct_with_extension_methods_is_skipped`) already use the non-overlay
framework name `"CreateMLComponents"`, so they **remain valid drop cases with no fixture
change** — `is_cross_import_overlay("CreateMLComponents") == false`. Add the keep cases.

### Keep fixture A — overlay with a foreign `Class` (must be retained)

```text
AbiDocument {
  root: AbiNode {
    name: "_RealityKit_SwiftUI",          // matches _<A>_<B> → is_overlay = true
    children: [
      AbiNode {
        kind: "TypeDecl",
        decl_kind: Some("Class"),
        name: "Entity",
        module_name: Some("RealityFoundation"),  // foreign module
        children: [
          AbiNode {
            kind: "Function",
            decl_kind: Some("Func"),
            name: "components",
            module_name: Some("_RealityKit_SwiftUI"),
            is_from_extension: true,
          }
        ],
      }
    ],
  }
}
```
Assertion: `framework.classes` MUST contain a class named `Entity`.

### Keep fixture B — overlay with ZERO native types (round-1 case, still must pass)

```text
AbiDocument {
  root: AbiNode {
    name: "_AppIntents_SwiftUI",           // is_overlay = true; no native type decls
    children: [
      AbiNode {
        kind: "TypeDecl",
        decl_kind: Some("Class"),
        name: "IntentParameter",
        module_name: Some("AppIntents"),    // foreign module
        children: [ /* requestConfirmation, is_from_extension: true */ ],
      }
    ],
  }
}
```
Assertion: `framework.classes` MUST contain `IntentParameter`.

### Drop fixture — non-overlay framework, foreign node must be suppressed

```text
AbiDocument {
  root: AbiNode {
    name: "CreateMLComponents",            // no leading '_' → is_overlay = false
    children: [
      AbiNode {                            // native sibling (optional; rule does not need it)
        kind: "TypeDecl",
        decl_kind: Some("Struct"),
        name: "NativeType",
        module_name: Some("CreateMLComponents"),
        children: [],
      },
      AbiNode {
        kind: "TypeDecl",
        decl_kind: Some("Protocol"),
        name: "Sequence",
        module_name: Some("Swift"),        // foreign module
        children: [ /* mapAnnotations, is_from_extension: true */ ],
      }
    ],
  }
}
```
Assertion: `framework.protocols` MUST NOT contain `Sequence`.

> Note: unlike round 1's `has_native_types` rule, the drop fixture does **not** require a
> native sibling — the §7 rule drops foreign nodes purely because the framework name is
> not overlay-shaped. The existing two drop tests therefore need **no edit**.

### Overlay-name boundary test (lock in the `_LocationEssentials` exclusion)

A direct unit test on `is_cross_import_overlay` (exact expected values):

| input | expected |
|---|---|
| `_RealityKit_SwiftUI` | `true` |
| `_AppIntents_SwiftUI` | `true` |
| `_SwiftData_CoreData` | `true` |
| `_WebKit_SwiftUI` | `true` |
| `_LocationEssentials` | `false` — leading `_` but no internal underscore |
| `CreateMLComponents` | `false` — no leading underscore |
| `CoreTransferable` | `false` — no leading underscore |
| `Foundation` | `false` |
| `_` | `false` — empty body |
| `_Foo_` | `false` — trailing empty token |

---

## 12. Scope Summary for Task 6

Task 6 should, **in `collection/crates/extract-swift/src/declaration_mapping.rs` only**:

1. Add `fn is_cross_import_overlay(framework_name: &str) -> bool` (§7 pseudocode).
2. In `map_abi_to_framework`, compute `let is_overlay = is_cross_import_overlay(&root.name);`
   once, before the child loop.
3. Add an `is_overlay: bool` parameter to `is_foreign_module_type_decl` and change its
   final match arm from `module != framework_name` to
   `!is_overlay && module != framework_name`.
4. Add tests: keep fixture A (overlay + foreign Class), keep fixture B (zero-native
   overlay), the `is_cross_import_overlay` boundary table (§11). The two existing drop
   tests stay as-is — they already use a non-overlay name.

**No changes to `AbiNode`, serde deserialisation, `digester.rs`, or the JSON schema.**

## 13. Follow-ups to file (for the orchestrator)

- **FU-1 — `annotate` must iterate protocols/structs/enums, not only `framework.classes`.**
  Independent of Task 6/7. Without it, non-class framework API (`CoreTransferable`, and
  the struct/protocol members of the overlays) receives zero annotations even when
  collection is correct. Not a Task 7 blocker (all six Task-7 modules have classes after
  the §7 fix), but required for complete annotation coverage.

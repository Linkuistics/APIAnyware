# Core Pipeline Hardening — Item 1 Findings: Orphaned-Framework Root-Cause Investigation

**Date:** 2026-05-21  
**Status:** DONE  
**Task:** 5 of the Core Pipeline Hardening plan

---

## 1. Executive Summary

Only **two** frameworks are truly orphaned by the over-aggressive foreign-module filter:
`_AppIntents_SwiftUI` and `_SwiftData_CoreData`. The other five frameworks listed in the
spec (`_RealityKit_SwiftUI`, `CoreTransferable`, `_PhotosUI_SwiftUI`, `_SwiftData_SwiftUI`,
`_WebKit_SwiftUI`) have `0 classes` by design — they are pure Swift protocol/struct
frameworks — but do contain native structs and/or protocols that survive the filter correctly.

The discriminating signal is a **framework-level property**: whether the framework has any
natively-owned type declarations (nodes whose `moduleName` equals the framework name). Pure
overlay frameworks with zero native types must keep their foreign extension-container nodes
because those ARE the API surface.

---

## 2. ABI JSON Shape: Keep Case (`_AppIntents_SwiftUI`)

Dump command:
```
xcrun swift-api-digester -dump-sdk -module _AppIntents_SwiftUI \
  -o /tmp/_AppIntents_SwiftUI.abi.json \
  -sdk "$(xcrun --sdk macosx --show-sdk-path)"
```

Root name: `_AppIntents_SwiftUI`. Total top-level children: 14 (6 Import + 8 type decls).
**All 8 type decls have `moduleName` pointing to a foreign module.**
There are zero nodes with `moduleName == "_AppIntents_SwiftUI"`.

Representative keep nodes (verbatim significant fields):

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
(The second is from `_SwiftData_CoreData`, the other orphaned framework.)

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

The 3 foreign nodes:

```json
{
  "kind": "TypeDecl",
  "name": "Sequence",
  "declKind": "Protocol",
  "usr": "s:ST",
  "moduleName": "Swift",
  "isExternal": true
}
```

```json
{
  "kind": "TypeDecl",
  "name": "LazySequence",
  "declKind": "Struct",
  "usr": "s:s12LazySequenceV",
  "moduleName": "Swift",
  "isExternal": true
}
```

```json
{
  "kind": "TypeDecl",
  "name": "DataFrame",
  "declKind": "Struct",
  "usr": "s:11TabularData0B5FrameV",
  "moduleName": "TabularData",
  "isExternal": true
}
```

Children of every drop-case foreign node are **structurally identical** to keep-case children:
all have `"isFromExtension": true` and `"moduleName": "CreateMLComponents"`.

Example:
```json
{
  "kind": "Function",
  "name": "mapAnnotations",
  "declKind": "Func",
  "moduleName": "CreateMLComponents",
  "isFromExtension": true
}
```

---

## 4. Comparison: Why Per-Node Signals Fail

| Signal candidate | Keep case (e.g. `IntentParameter`) | Drop case (e.g. `Sequence`) | Discriminates? |
|---|---|---|---|
| `isExternal` on the type node | `true` | `true` | **No** |
| `isFromExtension` on the type node itself | absent | absent | **No** |
| All children have `isFromExtension: true` | Yes | Yes | **No** |
| All children have `moduleName == framework` | Yes | Yes | **No** |
| Node's `moduleName != framework_name` | Yes | Yes | **No** |

Every per-node field is **identical** between keep and drop cases. The ABI JSON carries no
per-node flag that distinguishes "I am in a pure-overlay framework" from "I am an incidental
extension container in a mixed framework."

---

## 5. The Discriminating Signal

**Signal: whether the framework has any natively-owned type declarations.**

A type declaration is natively owned when its `moduleName` equals the root node's `name`
(the framework being dumped). Call this property `has_native_types`.

Observed values:

| Framework | Native types (moduleName == fw) | Foreign types | has_native_types | Correct action for foreign nodes |
|---|---|---|---|---|
| `_AppIntents_SwiftUI` | 0 | 8 | **false** | **KEEP** |
| `_SwiftData_CoreData` | 0 | 1 | **false** | **KEEP** |
| `_RealityKit_SwiftUI` | 14 (12 Struct + 2 Protocol) | 8 | true | drop |
| `CoreTransferable` | 11 (9 Struct + 2 Protocol) | 6 | true | drop |
| `_PhotosUI_SwiftUI` | 4 (Struct) | 2 | true | drop |
| `_SwiftData_SwiftUI` | 2 (Struct) | 8 | true | drop |
| `_WebKit_SwiftUI` | 1 (Struct) | 3 | true | drop |
| `CreateMLComponents` | 176 | 3 | true | drop |

This signal cleanly separates the two orphaned frameworks from all correct-behavior frameworks.
It also handles `CreateMLComponents` correctly (176 native types → foreign nodes are dropped).

---

## 6. Refined Rule for `is_foreign_module_type_decl`

### Prose

Drop a foreign type declaration (one whose `moduleName` differs from the framework name) **only
if the framework also declares at least one natively-owned type**. If the framework contains
no natively-owned type declarations, every foreign node represents the framework's actual API
surface (extensions on external types) and must be kept.

### Pseudocode

```
fn map_abi_to_framework(doc, sdk_version):
    root = doc.root
    framework_name = root.name

    // Pre-scan: is this a pure extension-only overlay?
    has_native_types = root.children.any(|n|
        n.decl_kind in {Class, Protocol, Struct, Enum} &&
        n.module_name == Some(framework_name)
    )

    for child in root.children:
        if is_foreign_module_type_decl(child, framework_name, has_native_types):
            continue
        // ... normal processing ...

fn is_foreign_module_type_decl(node, framework_name, has_native_types) -> bool:
    if node.decl_kind not in {Class, Protocol, Struct, Enum}:
        return false
    match node.module_name:
        None       => false                          // missing data: keep
        Some(m) if m == framework_name => false      // native: keep
        Some(_)    => has_native_types               // foreign: drop iff framework has own types
```

### Why this is safe for the drop case

`CreateMLComponents.Sequence` is dropped because `has_native_types = true`. The extension
members (`mapAnnotations`, `mapFeatures`) on `Sequence` do not reach the IR as members of a
`CreateMLComponents`-owned protocol node. The propagation bug is prevented.

### Why this is correct for the keep case

`_AppIntents_SwiftUI.IntentParameter` is kept because `has_native_types = false`. The
extension methods added by `_AppIntents_SwiftUI` on `IntentParameter` (e.g.
`requestConfirmation`) are the framework's entire API surface and correctly reach the IR.
Same for `_SwiftData_CoreData.NSManagedObjectModel.makeManagedObjectModel`.

---

## 7. AbiNode Field Status

`AbiNode` in `collection/crates/extract-swift/src/abi_types.rs` **already has all required
fields**. The `module_name: Option<String>` field (line 56) is the only node-level field
the refined rule needs. No new field needs to be added to the struct or the serde parser.

The `has_native_types` value is computed from the set of sibling nodes at the
`map_abi_to_framework` call site — it is a derived property of the ABIRoot children, not
a field on any individual `AbiNode`.

**Task 6 does NOT need to extend `AbiNode`.**

---

## 8. Test Fixtures for Task 6

### Keep fixture (pure overlay — foreign node must be retained)

```
AbiDocument {
    root: AbiNode {
        name: "_AppIntents_SwiftUI",           // framework has NO native type decls
        children: [
            AbiNode {
                decl_kind: Some("Class"),
                name: "IntentParameter",
                module_name: Some("AppIntents"),  // foreign module
                // isExternal: true (not parsed by AbiNode currently, not needed)
                children: [
                    AbiNode {
                        decl_kind: Some("Func"),
                        name: "requestConfirmation",
                        module_name: Some("_AppIntents_SwiftUI"),
                        is_from_extension: true,
                    }
                ]
            }
        ]
    }
}
```

Assertion: `framework.classes` must contain `IntentParameter`.

### Drop fixture (mixed framework — foreign node must be suppressed)

```
AbiDocument {
    root: AbiNode {
        name: "CreateMLComponents",
        children: [
            // At least one NATIVE type:
            AbiNode {
                decl_kind: Some("Struct"),
                name: "NativeType",
                module_name: Some("CreateMLComponents"),
                children: []
            },
            // Foreign extension container:
            AbiNode {
                decl_kind: Some("Protocol"),
                name: "Sequence",
                module_name: Some("Swift"),       // foreign module
                children: [
                    AbiNode {
                        decl_kind: Some("Func"),
                        name: "mapAnnotations",
                        module_name: Some("CreateMLComponents"),
                        is_from_extension: true,
                    }
                ]
            }
        ]
    }
}
```

Assertion: `framework.protocols` must NOT contain `Sequence`; it must contain only (or
include) types with `module_name == "CreateMLComponents"`.

---

## 9. CoreTransferable Sub-Case Verdict

`CoreTransferable` is **not broken by the filter**. It has 11 native types
(`Transferable` protocol, `TransferRepresentation` protocol, and 9 structs including
`CodableRepresentation`, `DataRepresentation`, `FileRepresentation`, etc.) all with
`moduleName: "CoreTransferable"`. The filter correctly drops its 6 foreign extension
containers (`Never`, `AttributedString`, `Data`, `String`, `URL`, `NSItemProvider`) and
keeps the 11 native types.

The collected IR for `CoreTransferable` showing `classes=0, protocols=2, structs=9` is
**correct expected behavior** — CoreTransferable is a pure Swift protocol/struct framework
with no Objective-C or Swift class declarations.

The `CoreTransferable` issue is **not caused by `is_foreign_module_type_decl`** and
requires no fix from Task 6. If downstream annotation/analysis only iterates
`framework.classes`, that is a separate gap (unrelated to collection) and should be
filed as a follow-up task.

---

## 10. Scope Summary for Task 6

Task 6 should:

1. Refactor `map_abi_to_framework` in
   `collection/crates/extract-swift/src/declaration_mapping.rs` to pre-scan
   `root.children` for native type declarations before the main loop.

2. Pass `has_native_types: bool` into the filter (either as a parameter or by
   restructuring the call site).

3. Adjust the filter predicate: foreign type decls are dropped iff
   `has_native_types == true`.

4. Add two synthetic test cases:
   - **Keep case**: pure overlay (no native types) — foreign Class/Protocol/Struct
     with children `isFromExtension: true` MUST be emitted.
   - **Drop case**: mixed framework (has at least one native type) — foreign node
     with `isFromExtension: true` children MUST be suppressed.
     The existing `foreign_module_protocol_with_extension_methods_is_skipped` and
     `foreign_module_struct_with_extension_methods_is_skipped` tests need an update:
     they must add a native sibling to trigger `has_native_types = true`.

No changes to `AbiNode` struct or serde deserialisation are required.

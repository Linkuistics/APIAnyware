# gerbil-trampoline-runtime-name-k41

**Kind:** work (per-target follow-up to `fix-objc-runtime-class-naming-k38`)

## Goal

Apply the **dual-name trampoline fix** to `emit-gerbil` so the gerbil target's Swift
trampoline (`libAPIAnywareGerbil`, ADR-0029) compiles after the k38 shared-IR change, and a
renamed ObjC class (NSScanner → Scanner) is reachable through gerbil's natural
construct/dispatch paths.

## Why this exists

k38 fixed the **shared collection** layer: `ir::Class.name` now carries the **ObjC runtime
name** (Swift↔ObjC merge unifies overlay/clang duplicates) and `ir::Class.swift_name` carries
the **Swift overlay name**. Global, so gerbil's Swift trampoline now emits
`Unmanaged<Foundation.NSScanner>` — which **does not compile** (obsoleted; it's `Scanner`).
The fix is per-target (each emitter owns its `trampoline.rs`).

> Note: gerbil's k38-attributable golden change (the `foundation.ss` facade dedup) was
> **already accepted** in the k38 commit; this leaf is the **Swift trampoline** half.

## Done when

- `emit-gerbil` mirrors the **emit-sbcl** precedent (`generation/crates/emit-sbcl/src/trampoline.rs`):
  a `swift_owner` (default = runtime `owner`), **remapped from the owning class's `swift_name`
  in `collect_trampolines`**; the `@_cdecl` body's receiver type / `Type(labels:)` constructor
  uses `swift_owner`, while the **entry symbol + gerbil dispatch identity stay on the runtime
  `owner`**.
- `swift build --target APIAnywareGerbil` compiles (regenerate gerbil first:
  `cargo run -p apianyware-macos-generate -- --target gerbil`). NB the **gcc-15 shim** for any
  gxc steps (see memory "gerbil gcc-15 drift") — but the Swift dylib build itself is `swiftc`.
- The renamed-class registry/auto-wrap works (gerbil's `register-objc-class!`).
- Any further gerbil goldens touching renamed classes refreshed (`UPDATE_GOLDEN=1`).

## Pointers

- Precedent: emit-sbcl `trampoline.rs` (`swift_owner` field; `swift_owner_of` remap in
  `collect_trampolines`; `let owner = format!("{}.{}", module, t.swift_owner)`).
- Shared IR: `ir::Class.swift_name` (`collection/crates/types/src/ir.rs`); set in `extract-swift`
  `map_class` (`objc_runtime_class_name`); carried in `merge_swift_into_objc`.
- Glossary: `CONTEXT.md` → "ObjC runtime class name (vs Swift-overlay name)".

# chez-trampoline-runtime-name-k40

**Kind:** work (per-target follow-up to `fix-objc-runtime-class-naming-k38`)

## Goal

Apply the **dual-name trampoline fix** to `emit-chez` so the chez target's Swift trampoline
(`libAPIAnywareChez`) compiles after the k38 shared-IR change, and a renamed ObjC class
(NSScanner → Scanner) is reachable through chez's natural construct/dispatch paths.

## Why this exists

k38 fixed the **shared collection** layer: `ir::Class.name` now carries the **ObjC runtime
name** (so the Swift↔ObjC merge unifies overlay/clang duplicates) and `ir::Class.swift_name`
carries the **Swift overlay name**. Global, so chez's Swift trampoline now emits
`Unmanaged<Foundation.NSScanner>` — which **does not compile** (obsoleted; it's `Scanner`).
The fix is per-target (each emitter owns its `trampoline.rs`).

## Done when

- `emit-chez` mirrors the **emit-sbcl** precedent (`generation/crates/emit-sbcl/src/trampoline.rs`):
  a `swift_owner` (default = runtime `owner`), **remapped from the owning class's `swift_name`
  in `collect_trampolines`**; the `@_cdecl` body's receiver type / `Type(labels:)` constructor
  uses `swift_owner`, while the **entry symbol + chez dispatch identity stay on the runtime
  `owner`**.
- `swift build --target APIAnywareChez` compiles (regenerate chez first:
  `cargo run -p apianyware-macos-generate -- --target chez`).
- The renamed-class registry/auto-wrap works (chez's `register-objc-class!` analogue).
- **Refresh chez's goldens** if any cover renamed classes / SDK-drifted (`UPDATE_GOLDEN=1`); see
  repo-root `TODO.md` (racket/chez goldens predate SDK 26.5).

## Pointers

- Precedent: emit-sbcl `trampoline.rs` (`swift_owner` field; `swift_owner_of` remap in
  `collect_trampolines`; `let owner = format!("{}.{}", module, t.swift_owner)`).
- Shared IR: `ir::Class.swift_name` (`collection/crates/types/src/ir.rs`); set in `extract-swift`
  `map_class` (`objc_runtime_class_name`); carried in `merge_swift_into_objc`.
- Glossary: `CONTEXT.md` → "ObjC runtime class name (vs Swift-overlay name)".

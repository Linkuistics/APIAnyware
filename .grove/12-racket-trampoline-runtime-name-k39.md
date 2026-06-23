# racket-trampoline-runtime-name-k39

**Kind:** work (per-target follow-up to `fix-objc-runtime-class-naming-k38`)

## Goal

Apply the **dual-name trampoline fix** to `emit-racket` so the racket target's Swift
trampoline (`libAPIAnywareRacket`) compiles after the k38 shared-IR change, and a
renamed ObjC class (NSScanner → Scanner) is reachable through racket's natural
construct/dispatch paths.

## Why this exists

k38 fixed the **shared collection** layer: `ir::Class.name` now carries the **ObjC
runtime name** (so the Swift↔ObjC merge unifies overlay/clang duplicates) and a new
`ir::Class.swift_name` carries the **Swift overlay name**. That change is global, so the
racket emitter's Swift trampoline now emits `Unmanaged<Foundation.NSScanner>` — which
**does not compile** (Swift obsoleted the ObjC name; it's `Scanner`). The fix is per-target
because each emitter has its own `trampoline.rs`.

## Done when

- `emit-racket` mirrors the **emit-sbcl** precedent (`generation/crates/emit-sbcl/src/trampoline.rs`):
  the trampoline carries a `swift_owner` (defaulting to the runtime `owner`), **remapped from
  the owning class's `swift_name` in `collect_trampolines`**; the `@_cdecl` body's receiver
  type / `Type(labels:)` constructor uses `swift_owner`, while the **entry symbol + the racket
  dispatch identity stay on the runtime `owner`** (so both sides of the C boundary agree and
  the registry keys on the live `class_getName`).
- `swift build --target APIAnywareRacket` compiles (regenerate racket first:
  `cargo run -p apianyware-macos-generate -- --target racket`).
- The renamed-class registry/auto-wrap works (racket's analogue of sbcl's `aw-resolve-bound-class`).
- **Refresh racket's SDK-26.5-stale goldens** (`UPDATE_GOLDEN=1`) — note these goldens predate
  the current SDK (the `appkit_subset` `NSTextView.characterIndex(for:)` drift is pre-existing,
  unrelated to k38; see repo-root `TODO.md`). Accept the dedup + SDK-refresh together as a
  deliberate goldens-as-truth pass.

## Pointers

- Precedent: emit-sbcl `trampoline.rs` (`swift_owner` field on `MethodTrampoline`/`InitTrampoline`;
  the `swift_owner_of` remap in `collect_trampolines`; `let owner = format!("{}.{}", module, t.swift_owner)`).
- Shared IR: `ir::Class.swift_name` (`collection/crates/types/src/ir.rs`); set in
  `extract-swift` `map_class` (`objc_runtime_class_name`); carried in `merge_swift_into_objc`.
- Glossary: `CONTEXT.md` → "ObjC runtime class name (vs Swift-overlay name)".

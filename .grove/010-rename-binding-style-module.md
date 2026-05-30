# 010-rename-binding-style-module

**Kind:** work

## Goal
Rename `generation/crates/emit/src/binding_style.rs` → `language_emitter.rs`. The
filename is a misleading vestige of the retired paradigm dimension (ADR-0004):
the `BindingStyle` enum is gone, and the file now holds only the language-emitter
abstraction (`LanguageInfo`, `LanguageEmitter`, `EmitResult`). Surfaced at
grove-finish; closes the root brief's "every place `BindingStyle` threads … is
gone" criterion.

## Context
- Module declared at `emit/src/lib.rs:8` (`pub mod binding_style;`); imported at 6
  sites: emit-chez `emit_framework.rs`, emit-racket `emit_framework.rs` +
  `tests/snapshot_test.rs` + `tests/runtime_load_test.rs`, cli `registry.rs` +
  `generate.rs`.
- `language_emitter.rs` matches the trait it defines and the descriptive
  sibling names (`ffi_type_mapping.rs`, `code_writer.rs`). No name collision.
- The file's header doc-comment is already style-free; keep it.

## Done when
- File `git mv`d to `language_emitter.rs`; `lib.rs` mod decl updated.
- All 6 `apianyware_macos_emit::binding_style::…` imports updated to
  `::language_emitter::…`.
- `cargo build --workspace` clean; emit-core/emit-chez/emit-racket unit tests
  green (same pass counts as before: 67/53/140/7). The 2 pre-existing racket
  snapshot failures are unrelated (inbox observation) and must not change.

## Notes
- Pure rename + import-path update; no behaviour change.

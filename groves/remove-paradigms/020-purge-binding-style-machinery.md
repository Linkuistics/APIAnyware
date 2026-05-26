# 020-purge-binding-style-machinery

**Kind:** work

## Goal
Delete the `BindingStyle` machinery and the now-orphaned
`supported_styles` / `default_style` plumbing, and flatten the
`generated/oo/` output directory. **Does not** rename
`racket-oo` → `racket`; the rename is a later leaf.

## Context
- ADR-0004 (raised by leaf 010) governs.
- Touch surface, from the pre-grilling scan:
  - `generation/crates/emit/src/binding_style.rs` — enum, trait,
    `LanguageInfo`, the misleading multi-paradigm docstring.
  - `generation/crates/emit/src/lib.rs`, `src/snapshot_testing.rs`.
  - `generation/crates/emit-racket-oo/src/emit_framework.rs` — trait
    impl signature.
  - `generation/crates/emit-racket-oo/tests/snapshot_test.rs`,
    `tests/runtime_load_test.rs`.
  - `generation/crates/cli/src/main.rs`, `src/registry.rs`,
    `src/generate.rs`.
  - Generated output paths under
    `generation/targets/racket-oo/generated/oo/`.
- `EmitResult` is **not** paradigm-coded — `classes`, `protocols`,
  `enums`, `functions`, `constants` are all populated by the Racket
  emitter today (confirmed by grep of `emit-racket-oo` and the snapshot
  tests). Leave the struct alone.

## Done when
- `BindingStyle` enum and `BindingStyle::from_str_name` are deleted.
- `LanguageInfo::supported_styles` and `default_style` fields are
  deleted; `LanguageInfo` shrinks to what reads naturally without them
  (likely `{ id, display_name }`).
- `LanguageEmitter::emit_framework` loses its `style` parameter; the
  Racket impl and all call sites are updated.
- The "Languages with multiple paradigms…" module docstring at the head
  of `binding_style.rs` is rewritten honestly, **or** the file's
  surviving contents are folded into `emit/src/lib.rs` and the file is
  deleted — whichever reads better at the point of edit.
- Output paths flatten: `generation/targets/racket-oo/generated/oo/<fw>/`
  → `generation/targets/racket-oo/generated/<fw>/`. (The slug stays
  `racket-oo` at this stage — the rename is a later leaf.)
- Snapshot fixtures are regenerated for the new layout;
  `cargo test -p emit-racket-oo` and the full pipeline (collect →
  analyse → generate) pass.
- Verification: `rg 'BindingStyle|supported_styles|default_style|generated/oo/'`
  returns no hits in `generation/` outside of historical docs.

## Notes
- Per standing "regenerate aggressively" guidance: rerun the full
  pipeline after the edits; don't trust stale snapshots as evidence.
- One focused commit by default. If the diff genuinely splits into two
  unrelated review concerns (machinery deletion vs. output-path
  flatten), this leaf becomes a planning task and grows two children —
  but only if there's a real reason.
- GUI smoke of any sample app belongs to a later validation leaf,
  driven from a macOS VM via TestAnyware. Not this leaf.

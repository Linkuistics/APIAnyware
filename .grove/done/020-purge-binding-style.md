# 020-purge-binding-style

**Kind:** work

## Goal
Delete `BindingStyle` and every place it threads through the codebase, so
emitters take no style parameter and `LanguageInfo` has no
`supported_styles` / `default_style`. Flatten `generated/oo/<framework>/`
output paths to `generated/<framework>/`. `cargo test --workspace` stays
green; the racket pipeline produces the same output it did before, modulo
the path flattening.

## Context
- `docs/adr/0004-retire-paradigm-dimension.md` (from leaf 010) — the
  authority for this change.
- `generation/crates/emit/src/binding_style.rs` — the file to gut. Decide
  whether to delete it entirely or shrink it to a slimmed-down
  `LanguageInfo` only; pick whichever reads cleaner.
- `generation/crates/cli/src/registry.rs` (lines 16, 73, 75, 78, 81, 97)
  — current call site for the registered `RacketEmitter`; the
  `emit_framework` signature change ripples here.
- `generation/crates/emit-racket-oo/` — the one extant emitter; its
  `emit_framework` signature changes; snapshot golden files under
  `tests/golden/oo/` move up one level.
- `generation/crates/emit/` and any other crate that imports
  `BindingStyle` — grep first to size the diff.

## Done when
- `rg BindingStyle` returns nothing in the source tree.
- `LanguageEmitter::emit_framework` takes no style argument; all call
  sites updated.
- `LanguageInfo` has no `supported_styles` / `default_style` fields; the
  struct-init sites are updated.
- `generated/oo/...` and `tests/golden/oo/...` paths are flattened
  (e.g. `tests/golden/racket-oo/oo/testkit/` → `tests/golden/racket-oo/testkit/`).
- `cargo test --workspace` is green.
- A regeneration of the racket pipeline against a real framework
  produces byte-identical output to before, modulo the `oo/` path
  flattening.
- **Not in scope:** renaming `racket-oo` → `racket`. That's a separate
  leaf seeded by the planning task that follows this one. Keep the diff
  about *retiring the dimension*, nothing else.

## Notes
The change is mechanical but touches trait signatures, the registry,
snapshot paths, and tests. Discipline: one focused commit, *only* the
paradigm retirement — no opportunistic renames, no opportunistic
cleanups in adjacent files. Those have their own leaves coming.

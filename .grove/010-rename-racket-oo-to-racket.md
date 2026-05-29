# 010-rename-racket-oo-to-racket

**Kind:** work  (may raise one ADR for the chosen `Target*` names)

## Goal
Rename the target from `racket-oo` to `racket` everywhere, and reconcile the
generic `Language*` → `Target*` trait/CLI naming in the same sweep. After this
leaf, no `racket-oo` token remains and the canonical vocabulary (target,
`--target`, `TargetEmitter`/`TargetInfo`) matches `CONTEXT.md`.

## Context
- `CONTEXT.md` "Flagged ambiguities": the Rust trait is `LanguageEmitter` /
  `LanguageInfo`, the CLI flag is `--lang`, but the on-disk unit is a **target**.
  This leaf resolves that ambiguity by renaming the trait/flag too (per decision:
  "do everything at once").
- Token sites found so far (not exhaustive — grep before editing):
  - `generation/targets/racket-oo/` (dir)
  - `generation/crates/emit-racket-oo/`, `generation/crates/bundle-racket-oo/` (crate dirs + Cargo.toml names + any path/`use` refs)
  - registered target / `--lang` *value* `racket-oo`
  - `knowledge/targets/racket-oo.md`, `knowledge/matrix/*/racket-oo.md`
  - `swift/Sources/APIAnywareRacket/`, `swift/Tests/APIAnywareRacketTests/`, `RacketFFI.swift`, `libAPIAnywareRacket.dylib`
  - `docs/specs/*racket*`, `docs/superpowers/plans/*racket*`

## Done when
- `rg -n 'racket-oo'` returns nothing (or only deliberately-historical hits, each justified).
- Trait/flag renamed: `LanguageEmitter`/`LanguageInfo` → `TargetEmitter`/`TargetInfo` (or agreed names); `--lang` → `--target`.
- Workspace builds (`cargo build`) and existing tests pass.
- `CONTEXT.md` updated: the "Flagged ambiguities" Target-vs-Language note is resolved/removed; `racket` is the only target name.

## Notes
- This is first by explicit decision so 020–050 edit final paths/names.
- The `Target*` rename is cross-target (affects the CLI and the planned `chez`
  target's registration too) — keep it a pure rename, no behavioural change.
- If the new trait/flag names involve a real trade-off (e.g. `--target` vs
  `--lang` back-compat alias), raise a short ADR; otherwise skip it.
- Watch for the `dylib` symlink in `generation/targets/racket-oo/lib/` pointing
  into `swift/.build/...`; the rename may require rebuilding the Swift product.

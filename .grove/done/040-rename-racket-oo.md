# 040-rename-racket-oo

**Kind:** work

## Goal
Rename the `racket-oo` slug to `racket` everywhere — crates, on-disk
directories, CLI string, golden test paths, knowledge files, doc/comment
mentions. No behavioural change; one focused mechanical commit. After this
leaf, the only `oo` left in the repo is what the rename can't touch (the
substring inside unrelated words like `cocoa`, `foundation`, etc.).

## Context

### Scope (the three axes)

1. **Crate names + workspace wiring.**
   - `generation/crates/emit-racket-oo/` → `generation/crates/emit-racket/`
   - `generation/crates/bundle-racket-oo/` → `generation/crates/bundle-racket/`
   - Cargo package names: `apianyware-macos-emit-racket-oo` →
     `apianyware-macos-emit-racket`; `apianyware-macos-bundle-racket-oo` →
     `apianyware-macos-bundle-racket`.
   - Root `Cargo.toml` `[workspace] members` and `[workspace.dependencies]`
     entries.
   - `generation/crates/cli/Cargo.toml` dep entry.
   - Inside the renamed `emit-racket` crate: the public struct
     `RacketEmitter` stays as-is (it's already paradigm-free); the constant
     `RACKET_LANGUAGE_INFO` stays.

2. **On-disk target tree.**
   - `generation/targets/racket-oo/` → `generation/targets/racket/`
     (everything under it: `apps/`, `docs/`, `generated/`, `lib/`, `runtime/`,
     `test-results/`, `tests/`, `README.md`).
   - The symlink `generation/targets/racket-oo/lib/libAPIAnywareRacket.dylib`
     resolves to a Swift `.build/` path — recreate it under the new
     location.

3. **String slug `"racket-oo"` → `"racket"`.**
   - `LanguageInfo.id` in `emit_framework.rs`: `id: "racket-oo"` → `"racket"`.
   - `LanguageInfo.display_name`: `"Racket OO"` → `"Racket"`.
   - Golden test paths under `generation/crates/emit-racket-oo/tests/golden/`
     stay in place (the directory moves with the crate); the test
     `GoldenTest::new(&golden_dir(), "racket-oo")` calls update to `"racket"`.
   - Snapshot output dir `tests/golden/<target>/<framework>/` — the
     `<target>` path component goes from `racket-oo` to `racket` wherever
     it's referenced.
   - `knowledge/targets/racket-oo.md` → `knowledge/targets/racket.md`.
   - `knowledge/matrix/<app>/racket-oo.md` → `racket.md` (for each of:
     hello-window, counter, ui-controls-gallery — and anywhere else they
     exist).
   - Every doc/spec mention in `docs/specs/*.md`, `docs/superpowers/plans/*.md`,
     `docs/codesigning-identity.md`, `docs/adding-a-language-target.md`,
     `generation/docs/emitter-contract.md`, `knowledge/README.md`,
     `knowledge/apps/_index.md`, `knowledge/apps/scenekit-viewer/spec.md`,
     and the target's own READMEs.
   - Source comments in `bundle-racket-oo` (now `bundle-racket`) and the
     CLI registry test names (`registry_contains_racket_oo` →
     `registry_contains_racket`).

### What this leaf does **not** touch
- The Rust trait `LanguageEmitter` and the CLI flag `--lang` — keep both.
  The Target-vs-Language ambiguity flagged in `CONTEXT.md` is **out of
  scope** for this leaf (per root `BRIEF.md` and the explicit answer in the
  030 grilling).
- Any pre-existing snapshot drift from the paradigm purge: regenerate
  goldens normally, but don't chase orthogonal drift.

### Useful pre-built lists
- `grep -rlEn 'racket-oo|RacketOo|racket_oo' generation/ tests/ knowledge/ docs/ Cargo.toml --include='*.rs' --include='*.toml' --include='*.md'` —
  43 files at the time this leaf was seeded.
- Three directories to `git mv`: see "On-disk target tree" above.

## Done when
- Workspace builds: `SDKROOT=macosx cargo build --workspace` clean.
- Tests pass: `SDKROOT=macosx cargo test --workspace` green. Pre-existing
  LLM-annotation / SDK-path drift in foundation/appkit subset snapshots is
  not in scope here; flag in the commit message if it's still red after
  the rename, do not chase.
- `grep -rEn 'racket-oo|racket_oo' generation/ tests/ knowledge/ docs/ Cargo.toml --include='*.rs' --include='*.toml' --include='*.md'`
  returns no hits (modulo `LICENSES/` and `.grove/done/` if any old leaf
  mentions it).
- CLI `cargo run -p apianyware-macos-cli -- --list-languages` prints
  `racket   Racket` (not `racket-oo   Racket OO`).
- `generation/targets/racket/lib/libAPIAnywareRacket.dylib` symlink resolves.

## Notes
- One focused commit per grove constraint. Stage all renames + sed +
  goldens together; the diff is large but reviewable as a single mechanical
  pass.
- If goldens drift in a way that isn't just the path component changing,
  stop and investigate before committing — that signals an emitter change
  the purge missed.
- The `bundle-racket-oo/tests/bundle_apps.rs` test fixture builds a
  symlink named `bindings/` pointing at the real target tree; the path
  literal `racket-oo` becomes `racket` there too.

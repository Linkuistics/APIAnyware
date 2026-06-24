# shared-seam-k15

**Kind:** work

## Goal

The cross-cutting finalization after all four per-target material moves (k11–k14): fix
the shared, target-agnostic path references and confirm the phase tree is empty. Read
node `BRIEF.md` first. This leaf is small but touches files shared by all targets, so it
deliberately runs **last**.

## Work items

1. **`.gitignore` — wholesale rewrite.** Rewrite every `generation/targets/...` and
   `swift/Sources/APIAnyware<T>/Generated/` pattern to the new `targets/<t>/...` homes,
   **preserving every exception exactly**:
   - `generation/targets/*/generated/` → `targets/*/bindings/macos/generated/...` (emitted)
   - chez: `apianyware/*` except `apianyware/runtime` → new `targets/chez/bindings/macos/generated/*`
     except `.../runtime`
   - gerbil: `lib/*` except `lib/runtime` + `lib/gerbil.pkg` → new gerbil generated root
   - the `*/runtime/compiled/`, `*/apianyware/runtime/compiled/`, `*/apps/*/compiled/`,
     `*/apps/*/build/` bytecode/build caches → new `app-implementations/macos/*/...` +
     `bindings/macos/.../compiled` paths
   - `swift/Sources/APIAnyware<T>/Generated/` (×4) → `targets/<t>/adapters/macos/sources/Generated/`
   Verify with `git status` that no previously-ignored path is now accidentally tracked
   (and vice-versa).
2. **`generate-cli`** — `src/main.rs` `--output-dir` default `"generation/targets"` and the
   per-target output-subdir logic in `generate.rs`/`emit/src/target_emitter.rs`
   (`output_subdir`): the canonical output home changed from `generation/targets/<t>/lib`
   to `targets/<t>/bindings/macos/generated`. Repoint the default + the subdir computation
   so a real regeneration lands in the new tree. Update the surrounding doc comments.
3. **`emit/src/target_emitter.rs` + `generate.rs` doc comments** — the `generation/targets/<id>/`
   references in `///`/`//!` docs → new homes.
4. **`platforms/macos/tools/scripts/regenerate-stale-pipeline.sh`** — repoint its
   `generation/targets` references to the new output tree.
5. **`swift/Package.swift` umbrella** — confirm all 4 modules + test targets now carry
   explicit `path:` into `targets/<t>/adapters/macos/`. Leave the umbrella at
   `swift/Package.swift` (repoint, not split) with a TODO: "workstream 6 (adapter model)
   may split into per-target `targets/<t>/adapters/macos/Package.swift`." Verify
   `swift package describe` resolves all four.
6. **Confirm `generation/targets/` is empty** (only empty dirs may remain; their removal is
   `migration-finalize-k10`'s job). `git grep generation/targets -- ':!*.md' ':!.grove/'`
   should return only intentional historical doc references, no live code/script paths.

## Done when

`.gitignore` + `generate-cli` + `emit` docs + regenerate script + Package.swift umbrella
all repointed; `cargo test` no-new-failures (the 4 pre-existing env failures unchanged);
`swift package describe` resolves; `generation/targets/` empty of tracked code/material;
committed as `shared-seam-k15`. This retires the last child → node `move-target-material-k8`
has no live leaf (cascade-check the parent `skeleton-k2`).

## Notes

This leaf carries **no per-target judgment** — purely the shared seam. If a `generation/targets`
reference surfaces here that is genuinely target-specific, it belongs back in that target's
leaf, not here (but those retired already; just fix it and note it).

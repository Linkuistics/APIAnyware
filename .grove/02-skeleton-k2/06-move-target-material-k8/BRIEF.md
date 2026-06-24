# move-target-material-k8 — brief

**Node kind:** work-node (decomposed per-target; 5 ordered child leaves below).

## Goal

Relocate the per-target emitted/runtime material + Swift adapters out of the phase
tree (`generation/targets/<t>/`, `swift/Sources|Tests/APIAnyware<T>`) into the §18
target shape under `targets/<t>/`, and fix every build-affecting path reference so
`cargo test` stays green (no *new* failures) and each runnable smoke locates its inputs
from the new home. After all 5 children retire, `generation/targets/` is empty (the
empty dir itself is removed by `migration-finalize-k10`, not here).

## Why decomposed (discovered while bootstrapping k8)

The four targets are **not four copies of one move** — each has a *distinct* layout, so
the generic map below resolves differently per target, and the `.gitignore` encodes
per-target exceptions that must be preserved exactly. Bundling four different
resolutions + a shared seam into one commit is the "rushing" the original leaf warned
against. Per-target leaves give reviewable, bisectable, fresh-context commits that cut
along the **hermetic-isolation grain** (ADR-0010/0011) the architecture is built on.
The original leaf's Notes pre-authorized exactly this split.

## Shared conventions (apply in every child)

§18 target shape + §42 generated/build/reports naming. Generic map (resolve against
each target's **actual `git ls-files`** — see per-child briefs):

```text
<t>/<emitted>      → targets/<t>/bindings/macos/generated   (emitted binding source)
<t>/lib/*.dylib    → targets/<t>/bindings/macos/build       (built dylib = build product, §42)
<t>/apps           → targets/<t>/app-implementations/macos
<t>/docs           → targets/<t>/docs
<t>/test-results   → targets/<t>/bindings/macos/reports     (§42 reports)
<t>/tests          → targets/<t>/bindings/macos/tests
swift/Sources/APIAnyware<T>      → targets/<t>/adapters/macos/sources       (§45.12 native adapter)
swift/Tests/APIAnyware<T>Tests   → targets/<t>/adapters/macos/tests
```

(The exact `<emitted>` and `<runtime>` home differ per target — chez emits into
`apianyware/`, racket into gitignored `generated/` with a hand-written top-level
`runtime/`, gerbil/sbcl keep an emitted+runtime `lib/`. Each child brief states its own.)

- **Package.swift — per-target split (CORRECTED in k11; the original "repoint the
  umbrella" plan is infeasible).** SwiftPM **forbids a target `path:` outside the
  package root** (`error: target '…' is outside the package root`), so a target
  whose sources live under `targets/<t>/adapters/macos/` *cannot* be referenced
  from `swift/Package.swift`. Instead, each target gets its **own**
  `targets/<t>/adapters/macos/Package.swift` (in-root `sources/` + `tests/` paths)
  and is **removed from the umbrella** — the per-target split the brief had deferred
  to workstream 6, brought forward by necessity (user decision, k11). Racket did
  this in k11. **For chez/gerbil/sbcl this is bigger than it was for racket:** they
  have `swift build --product APIAnyware<T>` consumers (gerbil
  `lib/runtime/tests/run-*.sh`, sbcl per-app `build.sh`/`run.lisp`/smokes, chez
  `runtime/tests/smoke-*.sls`) plus dylib symlinks that all point at the umbrella's
  `swift/.build/` — each per-target leaf must repoint **its** target's consumers +
  symlink to the new per-target `…/adapters/macos/.build/`. The `.v26` platform
  floor (ADR-0030) must carry into each per-target manifest. The shared-seam leaf
  k15 finalizes whatever residual remains in `swift/Package.swift` (empty it / drop
  it once all four have split out).
- **Dylib home vs §42 `build/` (heads-up from k11).** The generic map sends
  `<t>/lib/*.dylib → bindings/macos/build` per §42, but check whether the target's
  runtime loads the dylib by a single hardcoded relative dir (racket: `../lib/`,
  used identically in-tree *and* inside the bundle). If so, moving it to `build/`
  forces that one load-path to diverge between contexts — a workstream-6
  reconciliation. Racket therefore kept its dylib at `bindings/macos/lib/` (pure
  relocate, TODO recorded in its `bindings/macos/README.md`). Assess per target;
  prefer a behaviour-preserving home + TODO over a load-path change in the skeleton.
- **`.gitignore`:** do **not** touch per-target — the gitignored emitted/`Generated/`
  files are *absent* in a clean checkout, so a stale pattern causes no `git status` noise
  and tracked files (moved by `git mv`) stay tracked regardless. The shared-seam leaf
  rewrites all `generation/targets/...` + `swift/Sources/APIAnyware<T>/Generated/`
  patterns **once**, preserving every exception (chez `apianyware/runtime`, gerbil
  `lib/runtime` + `lib/gerbil.pkg`).
- **Doc-comment path refs** (`//!`/`///` in moved-target Rust crates that mention
  `generation/targets/<t>/...`): update for accuracy as part of that target's leaf —
  mechanical, not build-affecting.
- Use `git mv` (history-preserving); move directory-at-a-time where possible.

## Verification bar (every child + the seam)

`SDKROOT=macosx`. **Baseline established at decomposition** (`cargo test --no-fail-fast`,
whole workspace, this host): everything green **except** two binaries with *pre-existing
environmental* failures — they read **gitignored emitted bindings absent in a clean
checkout** (and gerbil's toolchain is absent on this host):
- `apianyware-bundle-racket --test bundle_apps`: 3 failing
  (`bundles_hello_window_into_app_directory`, `bundles_every_sample_app`,
  `bundle_has_no_compiled_directories_anywhere`)
- `apianyware-bundle-gerbil --test bundle_apps`: 1 failing (`computes_hello_window_closure`)

**Done-bar = introduce no NEW failures.** Those 4 tests stay failing for the *same*
environmental reason, but with their hardcoded `generation/targets/<t>/...` fixture paths
**updated to the new homes** (else they'd be a *different* kind of broken — dangling
phase paths). Toolchains present here: cargo, swift, racket, chez, sbcl; **gerbil
absent** (gxc/gxi) → gerbil's *language* smoke is path-checked only, not run. `swift build`
green is NOT a bar (needs regenerated `Generated/` trampolines absent on this host —
later workstream); verify Package.swift path-correctness via `swift package describe`.

## Children — ordered (per-target first, shared seam last)

1. **`move-racket-material-k11`** — racket has the richest layout (top-level `runtime/`
   25 files + `tests/` 9 files, gitignored `generated/`, dylib in `lib/`, 14-file Swift
   adapter). Hand-written `runtime/` → `bindings/macos/runtime` + TODO. Fixes
   bundle-racket's 3 hardcoded-path tests.
2. **`move-chez-material-k12`** — chez emits into `apianyware/` (gitignore-excepted
   `apianyware/runtime`), `lib/` = dylib only; 8-file Swift adapter.
3. **`move-gerbil-material-k13`** — gerbil `lib/` = package root (gitignore-excepted
   `lib/runtime` + `lib/gerbil.pkg`); smokes under `lib/runtime/tests/`; 3-file adapter.
   Fixes bundle-gerbil's 1 hardcoded-path test. (gerbil smoke path-checked, not run.)
4. **`move-sbcl-material-k14`** — sbcl `lib/runtime/` Lisp + gitignored emitted;
   per-app `build.sh` under `apps/*/`; smoke `lib/runtime/tests/run-integration-smoke.sh`;
   6-file adapter.
5. **`shared-seam-k15`** — the cross-cutting finalization: `.gitignore` wholesale
   rewrite (preserve all exceptions); `generate-cli` `--output-dir` default + output-path
   logic; `emit/src/target_emitter.rs` + `generate.rs` doc comments;
   `platforms/macos/tools/scripts/regenerate-stale-pipeline.sh`; Package.swift umbrella
   header + workstream-6 split TODO; confirm `generation/targets/` empty + `cargo test`
   no-new-failures.

## Done when

All 5 child leaves retired: per-target material + Swift adapters under `targets/<t>/`,
the shared seam fixed, `cargo test` shows no new failures, runnable smokes locate inputs
from new homes, `generation/targets/` empty. On node retirement, promote any live
convention (the generated/build/reports placement decision; the repoint-umbrella choice)
to the parent brief / an ADR if it earned one.

## Pointers

- `REFACTOR.md` §18 (target shape), §42 (generated/build/reports), §45.12 (native adapter).
- Parent `skeleton-k2` brief — SC5 (buildability slicing), SC6 (relocate-not-restructure).
- Memories: `swift build --product` (not `--target`) to relink dylibs; gerbil gcc-15 shim;
  enriched-IR/emitted-lib gitignored (tests skip-as-pass without local material);
  VM-verify is a *later* workstream's bar.

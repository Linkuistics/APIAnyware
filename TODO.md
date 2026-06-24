# TODO

Cross-target findings parked here (the grove inbox is being retired by a grove update).
Per-target work that belongs to an active grove is tracked as a grove leaf instead.

## Skeleton refactor — deferred-content index (`structural-refactoring` grove)

The skeleton node (`skeleton-k2`) created the five-domain tree and relocated
existing material, but authors **zero new content** (SC6). Every deferred content
artifact is pinned by a co-located `TODO (workstream N)` marker in its placeholder
README. This index confirms those markers are in place, by workstream:

| WS | What is owed | Marker(s) |
|----|--------------|-----------|
| 2 — spec-format / `.apiw` DSL | the `.apiw` DSL the pattern-kind / app-kind / annotation files are written in | `semantic/pattern-kinds/README.md`, `platforms/macos/app-kinds/README.md` |
| 3 — semantic model | pattern-kind definitions + semantic vocabulary docs | `semantic/README.md`, `semantic/docs/README.md`, `semantic/pattern-kinds/README.md` |
| 4 — platform model | `platform.yaml`, per-family `extracted.yaml`/`resolved.yaml`, app-kinds, platform tests/docs, **and the IR relocation `analysis/ir/` → `platforms/macos/api/`** | `platforms/README.md`, `platforms/macos/README.md`, `platforms/macos/api/README.md`, `platforms/macos/app-kinds/README.md`, `platforms/macos/docs/README.md`, `platforms/macos/tests/README.md` |
| 5 — LLM analysis side-channel | reshape flat `*.llm.json` set into per-family `annotations.apiw` | `platforms/macos/api/_llm-annotations/README.md` |
| 6 — target model | generated bindings, app-implementations, capability profiles, idiom catalogues, policies, per-target `Package.swift` reshape; re-sync the new-target guide's step paths | `targets/README.md`, `targets/racket/bindings/macos/README.md`, `targets/chez/bindings/macos/README.md`, `targets/_shared/docs/adding-a-language-target.md` |
| 7 — apps | author/extract `apps/macos/<app>/` specs; finalize the spec structure | `apps/README.md`, `apps/macos/README.md` |
| 8 — schemas + validation | formal schema definitions | `schemas/README.md`, `schemas/docs/README.md` |
| 9 — testing architecture | the multi-layer test model + TestAnyware/AppSpec integration docs | `platforms/macos/tests/README.md`, `semantic/docs/testing/general.md` |

### Residual pre-refactor path strings in co-located docs (doc-resync)

The build/test tree is green and **executed** artifacts that referenced moved
scripts were repointed in `migration-finalize-k10` (the `Makefile` drift-check
target and `.claude/commands/analyze.md`). What remains is prose:

- **IR-checkpoint paths** (`analysis/ir/{resolved,annotated,enriched,llm-summaries}`,
  `collection/ir/collected`) in the pipeline how-to docs, the annotate scripts, and
  `.gitignore` are **correct as written** — IR relocation is deferred to **ws4**, so
  those paths still describe where the pipeline writes today. They resolve when ws4
  moves the IR under `platforms/macos/api/`.
- **Moved-script / moved-crate paths** (`analysis/scripts/`, `collection/crates/`,
  `generation/targets/`) survive in *live reference* docs
  (`platforms/macos/docs/annotation-workflow.md`, `semantic/docs/analysis.md`). These
  are non-build-critical and were left at skeleton stage (SC6 — no doc-prose rewrite);
  fold the resync into the workstream that next edits each doc (ws4/ws5 for the
  annotation pipeline docs).
- **Historical records** (ADRs, dated `process/` plans, PRDs, captured spike `.txt`)
  keep their original path strings deliberately — rewriting them would falsify the
  record.

### Bundle-test skip-as-pass + a parked example (gerbil + racket)

`migration-finalize-k10` made the emit-dependent bundler tests skip-as-pass when the
**gitignored emitted binding tree is absent** (a clean checkout with no local
`apianyware-generate` run), matching the snapshot tests' discipline. Before this they
ran and failed with `ImportNotFound` / `ResolveRequire: generated/… does not exist` —
on `main` too — because their present-guards keyed on *committed* files (gerbil's
`runtime/objc.ss`, racket's app entry + `swiftc`) that say nothing about emit output.
Fixed guards: `gerbil_tree_present()` now gates on emitted `lib/appkit/nsapplication.ss`;
racket adds `racket_emit_present()` (`generated/appkit/nsapplication.rkt`) to its three
sample-app bundling tests. Real bundling coverage remains the per-app VM-verify leaves.

Two residual ws6 items (the bundler still wants a single colocated root — the tests
stitch one with a symlink fixture):

- `targets/racket/tools/bundle-racket/examples/bundle_app.rs` still reads app specs from
  `knowledge/apps/<app>/spec.md`; its own doc comment already parks it for ws6 (cannot
  bundle from the new tree until the bundler learns the apps-root/bindings-root split).
  The matching test path was repointed to `apps/macos/<app>/docs/spec.md`.
- Teach the bundler the apps-root / bindings-root split natively so the symlink fixture
  (`racket_root`/`gerbil_root`/`chez_root`) is no longer needed (root brief item 6).

> Note: chez's closure-walk test (`computes_hello_window_collision_set`) has the same
> committed-runtime guard shape but is `#[ignore]`d (heavy, ~75 s, needs chez), so it
> does not run in the default sweep; fold an emit-present guard into it whenever ws6
> next touches the chez bundler.

## ✅ RESOLVED — Swift-overlay class names vs ObjC runtime names break auto-wrap / construct

**Surfaced by:** `add-sbcl-clos-target` leaf 060/030 (swift-native-probe), 2026-06-21.
**Resolved:** `add-sbcl-clos-target` leaf `fix-objc-runtime-class-naming-k38`, 2026-06-23 —
fixed at the **shared collection** layer, so **all targets** (racket/chez/gerbil/sbcl) are
covered at once; the per-target rollout this TODO tracked is **discharged**.

### The defect (was)

Classes whose **Swift overlay** drops or renames the `NS` prefix (`Scanner`→`NSScanner`,
`FileHandle`→`NSFileHandle`, the `Unit*` family, the private `_NSKeyValueObservation`, …)
reached the IR under their Swift import name. Worse than a naming bake: the Swift overlay
(`Scanner`, USR `c:objc(cs)NSScanner`) and the clang ObjC class (`NSScanner`) were **two IR
classes for one runtime class**, because `merge_swift_into_objc` matches by `name` — so the
Swift-native methods and the ObjC methods landed on *different* CLOS classes, and the
overlay-named one (`ns:scanner`, registered `"Scanner"`) matched no live object.

### The fix

`collection/crates/extract-swift` `map_class` now keys an ObjC-bridged class on its **ObjC
runtime name recovered from the clang USR** (`objc_runtime_class_name`: `c:objc(cs)NSScanner`
and the `@M@…@objc(cs)` form → `NSScanner`). The existing by-name merge then **unifies** each
overlay with its clang twin into a single class registered under the live runtime name,
carrying both the ObjC init/methods and the Swift-native residual. ~31 Foundation duplicate
classes collapsed. Regression test: `objc_bridged_class_uses_runtime_name_from_usr` (+ infixed
/ idempotent / swift-native guards). Worked analysis:
`generation/targets/sbcl/apps/swift-native-probe/learnings.md`.

## racket / chez snapshot goldens are stale vs the current SDK (MacOSX26.5)

**Surfaced by:** verifying k38 (2026-06-23). The `emit-racket` real-IR snapshot subset tests
(`snapshot_racket_foundation_subset`, `snapshot_racket_appkit_subset`) fail **locally** against
SDK-26.5 enriched IR with drift unrelated to any code change — e.g. AppKit gained
`NSTextView.characterIndex(for:)`. Their goldens were bootstrapped on an older SDK (the racket
grove era). These tests **skip-as-pass without local IR**, so CI is green; the failure only
shows locally once the pipeline has been run. **Fix:** a deliberate goldens-as-truth refresh
(`UPDATE_GOLDEN=1`) on a controlled full pipeline run for the current SDK — a maintenance pass,
not part of any feature change (so SDK drift is not folded into an unrelated commit). sbcl and
gerbil goldens are already current (they were the only Foundation file that k38's dedup
changed, and that change was accepted).

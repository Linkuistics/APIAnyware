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
| 2 — spec-format / `.apiw` DSL | ✅ **DONE 2026-06-24** (`spec-format-k16` retired): the `.apiw` KDL DSL + parser + KDL Schema + the per-family triad + the convention-datalog tier all shipped (ADR-0046/0047). The pattern-kind / app-kind / annotation *content* written in it is ws3/ws4/ws7 (rows below). | `semantic/pattern-kinds/README.md`, `platforms/macos/app-kinds/README.md` (DSL reference discharged) |
| 3 — semantic model | ✅ **DONE 2026-06-25** (`semantic-model-k27` node, children k28–k31 retired): the pattern-kind `.apiw` KDL Schema + `semantic/tools/patterns` registry crate + 16 authored kind definitions (k28); first-class pattern-instance carriage in `resolved.json` (k29); the `apianyware-pattern-detection` convention datalog (k30); and the semantic-vocabulary docs — `semantic/docs/{overview,pattern-model}.md` + the `api-pattern-catalog.md` rewrite — with the `semantic/README.md`, `semantic/docs/README.md`, and `semantic/pattern-kinds/README.md` placeholders discharged (k31). ADR-0048 (D1–D8, DP1–DP4); PRD `prd/2026-06-25-semantic-pattern-kind-model.md`. | placeholders discharged |
| 4 — platform model | `platform.yaml`, app-kinds, platform tests/docs (**the IR relocation `analysis/ir/` → per-family `platforms/macos/api/<Framework>/{extracted,resolved}.json` was reassigned to and done by ws2's `pipeline-cutover-k20`**) | `platforms/README.md`, `platforms/macos/README.md`, `platforms/macos/app-kinds/README.md`, `platforms/macos/docs/README.md`, `platforms/macos/tests/README.md` |
| 5 — LLM analysis side-channel | ✅ **DONE 2026-06-25** (`llm-side-channel-k43` node, children k44–k49 retired): realized as a **lean mechanism over git + the pipeline** (ADR-0050), not a staging subsystem — git is the propose→review→accept boundary (`accepted-LLM` ≡ a committed `source llm` fact). The §4 disagreement/precedence audit stamps per-fact `source` + `superseded-by` into `resolved.json` at resolve time (emit-invisible → golden-neutral; `AnnotationSource` reconciled to the §4 vocab in k44, the resolve-time audit in k45); `apianyware-analyze annotations stale` (k46) + `annotations audit` (k47) replace the two analysis scripts; the `analyze` command/skill + `annotation-{workflow,subagent-prompt}.md` reworked over `.apiw` (k48); and `retire-tooling-k49` deleted the dead bash/python/external-API scaffolding (`check-llm-annotation-drift.sh`, `audit-llm-redundancy.py`, `regenerate-stale-pipeline.sh`, `llm-annotate.sh`, `config.example.toml`, `llm-annotate-orchestration.md`, `prompt-template.md`) and repointed `Makefile` `lint-annotations` onto the subcommands. The flat `*.llm.json` → per-family `annotations.apiw` **reshape itself was done by ws2's `pipeline-cutover-k20`**. | scaffolding retired; `Makefile` `lint-annotations` repointed |
| 6 — target model | generated bindings, app-implementations, capability profiles, idiom catalogues, policies, per-target `Package.swift` reshape; re-sync the new-target guide's step paths | `targets/README.md`, `targets/racket/bindings/macos/README.md`, `targets/chez/bindings/macos/README.md`, `targets/_shared/docs/adding-a-language-target.md` |
| 7 — apps | author/extract `apps/macos/<app>/` specs; finalize the spec structure | `apps/README.md`, `apps/macos/README.md` |
| 8 — schemas + validation | formal schema definitions | `schemas/README.md`, `schemas/docs/README.md` |
| 9 — testing architecture | the multi-layer test model + TestAnyware/AppSpec integration docs | `platforms/macos/tests/README.md`, `semantic/docs/testing/general.md` |

### Residual pre-refactor path strings in co-located docs (doc-resync)

The build/test tree is green and **executed** artifacts that referenced moved
scripts were repointed in `migration-finalize-k10` (the `Makefile` drift-check
target and `.claude/commands/analyze.md`). What remains is prose:

- **IR-checkpoint paths** (`analysis/ir/{resolved,annotated,enriched,llm-summaries}`,
  `collection/ir/collected`) are **gone from the active pipeline** as of ws2's
  `pipeline-cutover-k20`: collect/analyze/generate + `.gitignore` use the per-family
  triad under `platforms/macos/api/<Framework>/` (`extracted.json` / `annotations.apiw` /
  `resolved.json`). The LLM side-channel **workflow** scripts that still named the old
  paths were **retired** by ws5's `retire-tooling-k49` (`check-llm-annotation-drift.sh`,
  `audit-llm-redundancy.py`, `regenerate-stale-pipeline.sh`, `llm-annotate*`,
  `prompt-template.md`); their function now lives in `apianyware-analyze annotations
  {stale,audit}` + the `.claude/commands/analyze.md` orchestration.
- **Moved-script / moved-crate paths** (`analysis/scripts/`, `collection/crates/`,
  `generation/targets/`) — `platforms/macos/docs/annotation-workflow.md` was **reworked
  over `.apiw`** by ws5's `orchestration-skill-k48`, so the residual is
  `semantic/docs/analysis.md`: a non-dated analysis-gotchas doc still describing the
  **pre-cutover** pipeline (`.llm.json`, `analysis/ir/` checkpoints) and the now-**deleted**
  annotation scripts. Broadly stale vs ws2's cutover, not just this leaf — non-build-critical;
  fold its rewrite into the next workstream that edits `semantic/` analysis docs (a standalone
  doc-resync, no longer owned by ws4/ws5).
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

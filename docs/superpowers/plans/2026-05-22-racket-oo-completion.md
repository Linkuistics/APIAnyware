# Racket-OO Target — Phase-Cycle Retirement & Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retire the Ravel-Lite phase-cycle machinery from the last two workstreams that still use it (`modaliser-racket`, `racket`), and leave the `racket` target tracked by a superpowers spec + plan with a verified, completed backlog.

**Architecture:** Five work items from `docs/specs/2026-05-22-racket-completion-design.md`. Items A/B/C/E are file/doc operations (deletions, archival, distillation, doc updates). Item D is the real code work — four independent backlog tasks (D1–D4). The orchestrator owns pipeline regeneration and the verification gate; implementation subagents return source diffs only.

**Tech Stack:** Rust (the pipeline crates), Racket (`racket` runtime + generated bindings + sample apps), Markdown/YAML (`LLM_STATE`, `knowledge`, `docs`).

---

## Execution context

**Authoritative spec:** `docs/specs/2026-05-22-racket-completion-design.md`. Read it before starting. This plan implements it; on any conflict the spec wins.

**Worktree.** All work happens in the git worktree on branch `worktree-racket-completion`. Run every command from the worktree root. Repo-relative paths in this plan are relative to that root.

**The host `xcrun` is broken.** Prefix every SDK-touching command (collect, extract tests, `swift test`, `swift-api-digester`) with:

```bash
export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
```

**Build artifacts are gitignored.** `collection/ir/collected/`, `analysis/ir/*`, and `generation/targets/racket/generated/` are not in git. Task 0 materializes them. They may already be present (stale) in this worktree — Task 0 regenerates regardless; never trust a stale checkpoint as evidence.

**Pipeline regeneration is orchestrator-owned.** `analysis/ir/*` and `generated/` are shared mutable state. Implementation subagents return *source diffs only*. The orchestrator serializes `collect → resolve → annotate → enrich → generate` and owns the 0-enrichment-violations gate. Do **not** delegate regeneration.

**Note on the `analyze` invocation.** The bare `cargo run -p apianyware-macos-analyze` (no subcommand) uses `llm_dir=None` and does **not** load the checked-in `.llm.json` files. Always run the stages explicitly (see Task 0) so LLM annotations are included.

**Two-stage review.** For every returned diff: (1) spec-compliance review against `docs/specs/2026-05-22-racket-completion-design.md`, then (2) code-quality review. Run the verification gate (Task F's gate) before each commit.

**Shared-file caution.** Tasks D2, D3, and D4 all add tests to the *same* file — `generation/crates/emit-racket/tests/runtime_load_test.rs`. They must be executed and committed **sequentially**, not in parallel, to avoid edit conflicts.

**Terminology.** GUI verification uses **TestAnyware** (`{{DEV_ROOT}}/TestAnyware/`) — never run GUI apps directly from the CLI. Do not use the retired "guivision"/GUIVisionVMDriver name.

---

## Task 0: Baseline — materialize the pipeline and confirm green

**Files:** none modified. Orchestrator-run; no subagent; no commit (all outputs gitignored).

- [ ] **Step 1: Confirm the branch**

Run: `git branch --show-current`
Expected: `worktree-racket-completion`

- [ ] **Step 2: Export `SDKROOT` and regenerate the pipeline from scratch**

```bash
export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
cargo run -p apianyware-macos-collect                                          # ~2 min
cargo run -p apianyware-macos-analyze -- resolve
cargo run -p apianyware-macos-analyze -- annotate --llm-dir analysis/ir/llm-annotations
cargo run -p apianyware-macos-analyze -- enrich
cargo run -p apianyware-macos-generate
```

Expected: `enrich` reports **0 enrichment violations**; `generate` completes without error and populates `generation/targets/racket/generated/`.

- [ ] **Step 3: Confirm the workspace is green**

```bash
cargo test --workspace
cargo clippy --workspace --all-targets
make lint-annotations
```

Expected: tests pass, clippy clean, `make lint-annotations` exits 0. If anything fails here, stop — the baseline must be green before any task begins. (`make lint-annotations` may flag the pre-existing FU-1/FU-2 follow-ups; confirm the failure set matches what `LLM_STATE/overview.md` already documents as known-open, and exits 0 only if those are resolved — if it exits non-zero on the documented follow-ups, record that as the known baseline and proceed.)

- [ ] **Step 4: Confirm the emit-racket package name**

Run: `grep '^name' generation/crates/emit-racket/Cargo.toml`
Record the package name (expected `apianyware-macos-emit-racket`). Use it wherever this plan writes `-p apianyware-macos-emit-racket`.

- [ ] **Step 5: Confirm the runtime-load harness is green**

```bash
RUNTIME_LOAD_TEST=1 cargo test -p apianyware-macos-emit-racket --test runtime_load_test -- --nocapture
```

Expected: all `runtime_*` tests pass (the harness requires `racket` and `raco` on `PATH`; if absent, install them — the harness self-skips otherwise and that is not a green baseline).

---

## Task A: Delete the `modaliser-racket` workstream

**These deletions are deliberate and pre-authorized** — `modaliser-racket` is being abandoned for a later fresh restart from `~/Development/Modaliser`. Delete precisely per the path list; do not preserve or second-guess.

**Files:**
- Delete: `LLM_STATE/apps/modaliser-racket/` (whole directory)
- Delete: `LLM_STATE/apps/` (now empty)
- Delete: `generation/targets/racket/apps/modaliser/` (whole directory, including `build/`)
- Delete: `knowledge/apps/modaliser/` (whole directory)
- Modify: `knowledge/apps/_index.md`
- Modify: `generation/targets/racket/apps/README.md`

> **Investigation note.** `bundle-racket`'s `bundles_every_sample_app` test discovers apps by `apps/<name>/<name>.rkt`. The modaliser directory has no `modaliser.rkt` entry (only `main.rkt`/`modaliser-impl.rkt`), so it was never bundled by that test — deletion is build-safe. Every other code reference to "modaliser" is a comment or a unit-test string fixture (`title_case_kebab("modaliser")`, `AppSpec::from_script_name("modaliser")`), none of which touch the deleted directory. Step 4 verifies this.

- [ ] **Step 1: Delete the three directories and the emptied `apps/`**

```bash
git rm -r LLM_STATE/apps/modaliser-racket
git rm -r generation/targets/racket/apps/modaliser
git rm -r knowledge/apps/modaliser
```

`LLM_STATE/apps/` is now empty; remove it (it holds no tracked files after the `git rm`, so just ensure the directory is gone):

```bash
rmdir LLM_STATE/apps 2>/dev/null || true
```

- [ ] **Step 2: Drop the modaliser row from `knowledge/apps/_index.md`**

Delete the table row for app #8 (`modaliser`). The catalogue table then lists 7 apps. Leave the other rows and the "Retired:" note as-is. (Row numbers 1–7 already correspond to the surviving apps; do not renumber unless the modaliser row was not last — verify it is the last row before deleting.)

- [ ] **Step 3: Clean `generation/targets/racket/apps/README.md`**

Remove the "culminating in Modaliser as the capstone" phrasing (the file currently ends its intro with that). Replace the stale step 5 reference (`Check the target plan: {{PROJECT}}/LLM_STATE/targets/racket/backlog.md`) — `backlog.md` is being deleted by Task B — with a pointer to this design + plan:

```
5. Check the target plan: `{{PROJECT}}/docs/specs/2026-05-22-racket-completion-design.md`
   and `{{PROJECT}}/docs/superpowers/plans/2026-05-22-racket-completion.md`
```

Leave the "All GUI testing uses TestAnyware" section unchanged.

- [ ] **Step 4: Grep for stragglers and resolve each**

```bash
grep -rIn --exclude-dir=.git --exclude-dir=generated --exclude-dir=ir -i modaliser . | grep -v '.claude/worktrees'
```

Expected remaining hits, and their disposition:
- `docs/specs/2026-04-16-...`, `docs/specs/2026-04-19-...`, `docs/specs/2026-05-20-...`, `docs/superpowers/plans/2026-05-20-...`, `docs/specs/2026-05-22-racket-completion-design.md` — **leave**: historical design records / this workstream's own spec, which deliberately names modaliser.
- `generation/crates/bundle-racket/src/{bundle,deps,spec}.rs`, `tests/{bundle_apps,info_plist_overrides,signing_identity}.rs` — **leave**: comments and unit-test string fixtures, no path dependency.
- `generation/crates/emit-racket/tests/runtime_load_test.rs` — **leave**: a single comment ("the platform-unavailable extern leak surfaced by Modaliser-Racket").
- `generation/targets/racket/runtime/dynamic-class.rkt`, `runtime/objc-interop.rkt` — **leave**: design-note comments naming Modaliser as an example consumer.
- `knowledge/apps/drawing-canvas/spec.md` — **leave**: architectural cross-reference ("Modaliser uses the same mechanism").
- `knowledge/testanyware/strategies/modal-overlay-apps.md` — **leave**: a placeholder stub.
- `LLM_STATE/project-workflow.md`, `LLM_STATE/overview.md` — **handled by Task E** (do not edit here, to avoid two tasks touching the same files).

If the grep surfaces a *code or build* reference not in the "leave" list above, resolve it before proceeding.

- [ ] **Step 5: Verify the build still passes**

```bash
cargo test --workspace
cargo clippy --workspace --all-targets
RUNTIME_LOAD_TEST=1 cargo test -p apianyware-macos-emit-racket --test runtime_load_test
```

Expected: all green — no test or build target referenced the deleted directories.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "$(cat <<'EOF'
chore(racket): delete the abandoned modaliser-racket workstream

Item A of the racket phase-cycle retirement. The Racket Modaliser
attempt is abandoned; it will be restarted later from ~/Development/Modaliser.
Removes LLM_STATE/apps/modaliser-racket/, generation/targets/racket/apps/modaliser/,
and knowledge/apps/modaliser/, plus references in the app catalogue and apps README.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task C: Distil `racket` learnings into `knowledge/targets/racket.md`

Runs **before Task B** so `memory.yaml` is still at its original path. A subagent rewrites the knowledge doc; the orchestrator reviews it.

**Files:**
- Modify (rewrite): `knowledge/targets/racket.md`
- Read-only source: `LLM_STATE/targets/racket/memory.yaml`

**Done when:** `knowledge/targets/racket.md` is a self-contained reference for the `racket` target that does not depend on the archived `memory.yaml`.

- [ ] **Step 1: Audit `memory.yaml` against the current doc**

The subagent reads `LLM_STATE/targets/racket/memory.yaml` (563 lines) in full and the current `knowledge/targets/racket.md` (105 lines). Every durable, still-true learning in `memory.yaml` must survive into the knowledge doc; anything later commits made false must be dropped (verify against the tree before copying).

- [ ] **Step 2: Exclude the verified-stale entries**

Do **not** copy these — they were made false by later work, or are point-in-time censuses:

| Stale item | Why excluded |
|---|---|
| The existing "Layout caveats for delegate callbacks" section (NSInteger via the arm64 `x0`-smuggle, `(ptr-add #f count)`) | `runtime/delegate.rkt` now supports `'int` and `'long` return kinds — the workaround is obsolete. Replace with a "delegate return kinds `'void`/`'bool`/`'id`/`'int`/`'long`" note. |
| Dated Discovery "🔴 NSEdgeInsets not in geometry struct alias list — omit from apps" | Fixed — `NSEdgeInsets` is in `is_known_geometry_struct` / `ffi_type_mapping.rs`. |
| Dated Discovery "🔴 NSTableViewDataSource NSInteger return needs the arm64 x0-smuggle until the delegate runtime grows `'int` returns" | Same — the delegate runtime grew `'int`/`'long` returns. |
| `memory.yaml`'s "9 sample apps" / "all 4 sample apps" enumerations (incl. `counter`, `file-lister`) | Those apps were retired; `runtime_load_test.rs`'s `APPS` array still carries stale `counter`/`file-lister` ghosts. State the *mechanism* (apps registered in `APPS`), not a count. |
| `default-constructor` "~73% / 5,304 classes" census | Mechanism is durable; the percentages drift on every re-collect. Keep the mechanism + `has_explicit_constructor` trigger; drop the numbers. |
| All `TestAnyware`-operational entries (`vm-start.sh`, per-VM connection specs, etc.) | Out of scope for a language-target reference doc; reference the VM workflow only generically. |

- [ ] **Step 3: Rewrite `knowledge/targets/racket.md` to this section structure**

```
# racket — Target Reference

## 1. Overview
   - "OO" is a target name only — generated files are #lang racket/base, zero
     Racket class system; ObjC inheritance flattened at emit time; protocols
     emit delegate factories; make-dynamic-subclass is the only genuine OO
     mechanism. IR schema deltas from base IR.
## 2. Emitter architecture
   2.1 File layout & require blocks — dylib/runtime path depths (class/protocol/app),
       the `->` ffi-unsafe-vs-racket-contract rename, framework-dylib + get-ffi-obj.
   2.2 What gets emitted / filtered — variadic+inline skipped, selector `(` filtering,
       function vs class framework subsets, FunctionPointer/Block auto-warn.
   2.3 Class & property emission — contract-export plumbing, class/instance selector
       disambiguation, collision sets, class-property `self` omission, default
       constructor synthesis (mechanism only), tell #:type matching, make-nsrect forms.
   2.4 Protocol emission — delegate factories, fixed contract shape, param/return hashes.
## 3. Contract design — three contract mappers, class-wrapper contracts, per-file
   inline class predicates, nullable typed returns, provide/contract rest-arg limit.
## 4. FFI type-coercion rules — coerce-arg, collection-time type resolution, unsigned
   enum canonicalization, record typedefs → Struct, const char* → CString, cstruct
   provide list, struct-typed global constants via ffi-obj-ref, generic-type-param
   heuristic, libdispatch id→pointer, CFSTR via _make-cfstr, property dedup by getter.
## 5. Non-linkable & unavailable symbol filtering — the six extractor filters,
   four-level platform-availability filters, header-declared ≠ dylib-exported,
   emit-time dylib-unexported filter.
## 6. Synthetic pseudo-frameworks & subframeworks — structure & hookup, libdispatch
   ffi-lib = libSystem, symlinked-subframework resolution, subframework allowlist.
## 7. Runtime library
   7.1 Object model — objc-object? struct vs cpointer, tell receiver coerce-arg,
       borrow/wrap-objc-object, precise GC registries, with-autorelease-pool begin0.
   7.2 Delegates & protocols — make-delegate handlers, #:param-types coercion,
       delegate return kinds 'void/'bool/'id/'int/'long, encoding q = NSInteger.
   7.3 ObjC subclassing — dynamic-class.rkt surface, define-objc-subclass macro,
       encoding parser (stack-offset digits, balanced delimiters).
   7.4 Concurrency & threading — green threads dead under nsapplication-run, GCD
       main-thread dispatch, _cprocedure unsafe from foreign OS threads, places.
   7.5 Memory — Racket CS malloc returns GC memory, never free.
   7.6 Runtime helper files — cf-bridge, nsview-helpers, ax/cgevent/spi-helpers,
       objc-interop, app-menu typed objc_msgSend for SEL params.
## 8. Verification — three verification layers, the runtime-load harness
   (RUNTIME_FILES / LIBRARY_LOAD_CHECKS / APPS; standing rule to extend), snapshot
   infrastructure, raco make for apps, UPDATE_GOLDEN, gitignored generated/.
## 9. Sample apps & bundling — why .app bundles (CFBundleName/TCC), the two-crate
   story, bundle_app CLI, Resources/racket-app layout, new-app = spec.md only,
   two-stage signing. Current app list: 7 apps (hello-window, ui-controls-gallery,
   note-editor, mini-browser, drawing-canvas, scenekit-viewer, pdfkit-viewer).
## 10. UI / framework gotchas — NSStackView baseline alignment, widget quirks
   (NSStepper, radio buttons, NSScrollView), NSColor RGB color space,
   PDFView notification observer pattern, NSSavePanel completion block.
```

Preserve the still-true prose from the current doc (the "Sample app bundling" and "Toolbar baseline alignment" sections) and fold the "Dated Discoveries" facts into §10 (de-dated — they are durable framework facts, not session events).

- [ ] **Step 4: Verify self-containment**

Read the rewritten `knowledge/targets/racket.md`. Confirm it references no information that exists only in `memory.yaml`. Confirm it does not say "guivision".

- [ ] **Step 5: Commit**

```bash
git add knowledge/targets/racket.md
git commit -m "$(cat <<'EOF'
docs(racket): distil memory.yaml learnings into the target reference

Item C of the racket phase-cycle retirement. Rewrites
knowledge/targets/racket.md as a self-contained racket reference so the
Ravel-Lite memory.yaml can be archived. Drops entries later commits made false
(delegate 'int/'long returns, NSEdgeInsets fix) and point-in-time censuses.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task B: Retire the `racket` phase machinery

Mirror the `core` migration (`LLM_STATE/core/archive/`).

**Files:**
- Create: `LLM_STATE/targets/racket/archive/README.md`
- Move: `LLM_STATE/targets/racket/memory.yaml` → `archive/memory.yaml`
- Move: `LLM_STATE/targets/racket/session-log.yaml` → `archive/session-log.yaml`
- Delete: `LLM_STATE/targets/racket/{phase.md, pre-work.sh, prompt-work.md, prompt-triage.md, work-baseline, dream-baseline, compact-baseline, latest-session.yaml, backlog.yaml, related-plans.md}`

> **Note.** The design spec's explicit delete list omits `compact-baseline`, but Item B's done-criterion is "`racket/` contains only `archive/`". `compact-baseline` is plainly Ravel-Lite machinery (the `core` migration deleted its `compact-baseline`), so it is deleted here too.

- [ ] **Step 1: Create the archive directory and move the two history files**

```bash
mkdir -p LLM_STATE/targets/racket/archive
git mv LLM_STATE/targets/racket/memory.yaml LLM_STATE/targets/racket/archive/memory.yaml
git mv LLM_STATE/targets/racket/session-log.yaml LLM_STATE/targets/racket/archive/session-log.yaml
```

- [ ] **Step 2: Write `LLM_STATE/targets/racket/archive/README.md`**

```markdown
# Archived racket-workstream state

`memory.yaml` and `session-log.yaml` are the read-only record of the
Ravel-Lite-driven `racket` target sessions.

The Ravel-Lite work→reflect→triage phase cycle has been retired for the
`racket` workstream. The `racket` target is now tracked by:

- `docs/specs/2026-05-22-racket-completion-design.md` — design
- `docs/superpowers/plans/2026-05-22-racket-completion.md` — implementation plan

The durable learnings from `memory.yaml` are distilled into
`knowledge/targets/racket.md`, which is the self-contained `racket`
reference. These two files are kept only as historical record.

With this migration `LLM_STATE/` contains no live phase-cycle machinery.
```

- [ ] **Step 3: Delete the Ravel-Lite machinery**

```bash
git rm LLM_STATE/targets/racket/phase.md \
       LLM_STATE/targets/racket/pre-work.sh \
       LLM_STATE/targets/racket/prompt-work.md \
       LLM_STATE/targets/racket/prompt-triage.md \
       LLM_STATE/targets/racket/work-baseline \
       LLM_STATE/targets/racket/dream-baseline \
       LLM_STATE/targets/racket/compact-baseline \
       LLM_STATE/targets/racket/latest-session.yaml \
       LLM_STATE/targets/racket/backlog.yaml \
       LLM_STATE/targets/racket/related-plans.md
```

(`pre-work.sh` only delegated to `analysis/scripts/regenerate-stale-pipeline.sh`; that script is repo-local and stays.)

- [ ] **Step 4: Verify the directory contains only `archive/`**

Run: `find LLM_STATE/targets/racket -type f | sort`
Expected exactly:
```
LLM_STATE/targets/racket/archive/README.md
LLM_STATE/targets/racket/archive/memory.yaml
LLM_STATE/targets/racket/archive/session-log.yaml
```

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "$(cat <<'EOF'
chore(racket): retire the Ravel-Lite phase-cycle machinery

Item B of the racket phase-cycle retirement. Archives memory.yaml and
session-log.yaml under LLM_STATE/targets/racket/archive/ as read-only
history, and deletes the phase-cycle files. LLM_STATE now holds no live
phase machinery.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task D1: SceneKit Viewer msgSend-alias cleanup

**Files:**
- Modify: `generation/targets/racket/apps/scenekit-viewer/scenekit-viewer.rkt`

The protocol-inherited-methods fix (commit `0901f23`) has propagated: `scnnode-run-action` and `scnview-set-autoenables-default-lighting!` now generate as proper bindings, already imported by the app via `require` lines 29 and 31. The app-local typed `objc_msgSend` aliases are dead workarounds.

> **Verified replacements** (in `generation/targets/racket/generated/oo/scenekit/`):
> - `scnview-set-autoenables-default-lighting!` — `(scnview? boolean?) -> void?`, in `scnview.rkt`.
> - `scnnode-run-action` — `(scnnode? (or/c string? objc-object? #f)) -> void?`, in `scnnode.rkt`. Note: **no trailing `!`**.

- [ ] **Step 1: Remove the alias block**

In `scenekit-viewer.rkt`, delete the entire block at lines ~65–89 — the `;; --- Typed objc_msgSend aliases ...` comment (lines ~65–73) through the `scn-view-set-autoenables-default-lighting!` definition (line ~89). This removes `_objc-lib`, `_msg-run-action`, `_msg-set-autoenables-default-lighting`, `sel-run-action`, `sel-set-autoenables-default-lighting`, `node-run-action!`, and `scn-view-set-autoenables-default-lighting!`.

- [ ] **Step 2: Update the file docstring**

The header docstring (lines ~8–14) describes the two protocol-inherited methods reached via typed `objc_msgSend` aliases. Remove or update that paragraph so it no longer describes the deleted workaround.

- [ ] **Step 3: Repoint the two call sites**

- Line ~147: `(scn-view-set-autoenables-default-lighting! scn-view #t)` → `(scnview-set-autoenables-default-lighting! scn-view #t)`
- Line ~197: `(node-run-action! geometry-node spin-action)` → `(scnnode-run-action geometry-node spin-action)`

- [ ] **Step 4: Confirm no `objc_msgSend` alias remains**

Run: `grep -n -i 'objc_msgsend\|_objc-lib\|sel_registerName' generation/targets/racket/apps/scenekit-viewer/scenekit-viewer.rkt`
Expected: no matches.

- [ ] **Step 5: Verify the app loads (raco make)**

```bash
raco make generation/targets/racket/apps/scenekit-viewer/scenekit-viewer.rkt
```

Expected: compiles with no error (the replacement bindings resolve from the existing `require`s). This needs `generation/targets/racket/generated/` present from Task 0.

- [ ] **Step 6: Verify the viewer renders in a VM (TestAnyware)**

Build the `scenekit-viewer` bundle and render it in a macOS VM with TestAnyware — **never run the GUI app directly from the CLI**. Follow `knowledge/testanyware/general.md`:

```bash
cargo run --example bundle_app -p apianyware-macos-bundle-racket -- scenekit-viewer
# TestAnyware: start VM, share ./generation/targets/racket, launch the .app, screenshot
```

Expected: the SceneKit viewer window renders the 3D scene (a shaded geometry node) and the spin animation runs — i.e. `scnnode-run-action` and `scnview-set-autoenables-default-lighting!` behave as the aliases did. Capture a screenshot as evidence.

- [ ] **Step 7: Commit**

```bash
git add generation/targets/racket/apps/scenekit-viewer/scenekit-viewer.rkt
git commit -m "$(cat <<'EOF'
refactor(scenekit-viewer): drop obsolete objc_msgSend aliases (D1)

The protocol-inherited-methods fix (0901f23) means scnnode-run-action and
scnview-set-autoenables-default-lighting! now generate as proper bindings.
Removes the dead app-local typed objc_msgSend workarounds and repoints the
call sites at the generated bindings. Viewer render re-verified in a VM.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task D2: `define-objc-subclass` struct-encoding test coverage

**Files:**
- Modify: `generation/crates/emit-racket/tests/runtime_load_test.rs` (add one `#[test]` fn)

The existing test `runtime_objc_subclass_macro` exercises only plain-primitive method encodings (`hash`, `isEqual:`). It does not exercise `#:arg-types`, nor a struct-typed encoding, nor the nested balanced-delimiter (`{...}`) parser in `runtime/objc-subclass.rkt` (`read-balanced`). D2 adds that coverage.

> **Approach.** Mirror the existing `runtime_objc_subclass_macro` function (`runtime_load_test.rs`, lines ~474–614) exactly for scaffolding: `skip_unless_enabled` gate, tempdir, `copy_runtime` / `copy_lib`, embed a Racket script string, `racket <script>`, `panic!` on non-zero exit. To exercise the nested-`{...}` parser, the subclass must override a superclass method whose ObjC type encoding contains a nested struct — `NSView`'s `drawRect:` has encoding `v…@0:8{CGRect={CGPoint=dd}{CGSize=dd}}…`. `NSView` must be registered with the ObjC runtime, so the Racket script first loads AppKit via `ffi-lib`. The parser internals (`read-balanced` etc.) are not `provide`d by `objc-subclass.rkt`, so the test must go through `define-objc-subclass`.

- [ ] **Step 1: Write the new test**

Add `runtime_objc_subclass_struct_encoding` to `runtime_load_test.rs`. Scaffold it identically to `runtime_objc_subclass_macro`. The embedded Racket script:

```racket
#lang racket/base
(require ffi/unsafe
         (file "<TEMP>/runtime/dynamic-class.rkt")
         (file "<TEMP>/runtime/objc-subclass.rkt"))

;; NSView must be registered with the ObjC runtime before we subclass it.
(void (ffi-lib "/System/Library/Frameworks/AppKit.framework/AppKit"))

;; Inference path: drawRect: has a nested-struct encoding
;;   v…@0:8{CGRect={CGPoint=dd}{CGSize=dd}}…  → exercises read-balanced recursion.
(define drew (box #f))
(define-objc-subclass D2InferView NSView
  [(drawRect:) (lambda (self dirty-rect) (set-box! drew #t))])
(unless D2InferView (eprintf "FAIL: D2InferView not registered~n") (exit 1))

;; Explicit-override path: #:arg-types / #:ret-type bypass inference.
(define-objc-subclass D2ExplicitView NSView
  [(tag) #:arg-types () #:ret-type _long (lambda (self) 7)])
(unless D2ExplicitView (eprintf "FAIL: D2ExplicitView not registered~n") (exit 1))

(printf "OK: define-objc-subclass struct-encoding — checks passed~n")
```

The Rust side substitutes `<TEMP>` with the absolute tempdir path (use the same path-substitution idiom as the sibling tests — e.g. `racket_string_literal`). Keep the `(file ...)` wrapper on require paths (raw path strings trip `module-path?`).

- [ ] **Step 2: Run the test**

```bash
RUNTIME_LOAD_TEST=1 cargo test -p apianyware-macos-emit-racket --test runtime_load_test runtime_objc_subclass_struct_encoding -- --nocapture
```

Expected: PASS. If it FAILS, the failure is real — investigate (systematic-debugging) whether the encoding parser or `define-objc-subclass` is genuinely broken before adjusting the test. Adjust selector/encoding choices only if the chosen selector turns out not to carry a nested-struct encoding; the nested-`{...}` path must remain exercised.

- [ ] **Step 3: Run the full harness to confirm no regression**

```bash
RUNTIME_LOAD_TEST=1 cargo test -p apianyware-macos-emit-racket --test runtime_load_test
cargo clippy --workspace --all-targets
```

Expected: all green, clippy clean.

- [ ] **Step 4: Commit**

```bash
git add generation/crates/emit-racket/tests/runtime_load_test.rs
git commit -m "$(cat <<'EOF'
test(racket): cover define-objc-subclass struct encodings (D2)

Adds runtime_objc_subclass_struct_encoding to the runtime-load harness:
exercises the nested balanced-delimiter ({...}) encoding parser via an
NSView/drawRect: override, and the #:arg-types/#:ret-type explicit-override
path. Previously only plain-primitive encodings were covered.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task D3: Default-constructor harness checks

**Files:**
- Modify: `generation/crates/emit-racket/tests/runtime_load_test.rs` (add one `#[test]` fn)

The runtime-load harness has no explicit check that synthesized constructors actually construct. D3 adds checks for `NSAlert`, `NSColorPanel`, `NSStackView`, `NSSavePanel`, `NSOpenPanel`.

> **Spec deviation — read before implementing.** The design spec's D3 says "check that the synthesized `make-<class>` constructors actually construct" for all five classes. The emitter only synthesizes a zero-arg `make-<class>` for classes with **no explicit init selector** (`has_explicit_constructor` in `emit_class.rs`). Of the five, only **`NSAlert`** qualifies (`make-nsalert`). `NSColorPanel`, `NSSavePanel`, `NSOpenPanel` have explicit init selectors and class-factory accessors; `NSStackView` has explicit init selectors. They get `make-<class>-init-…` / factory bindings, never a bare `make-<class>`. This is a structural fact (those classes have real SDK init selectors), not staleness. D3 therefore tests each class's *actual* constructive entry point — faithful to the spec's intent ("confirm they construct cleanly"), which is what the D3 done-criterion ("the new tests are added and green") requires. The orchestrator must flag this deviation in the spec-compliance review and the final report.

> **Approach.** Mirror `runtime_block_nil_guard` for scaffolding. The constructors live in generated AppKit files, so the test must emit AppKit/Foundation — use `build_harness_tree` (emits all `REQUIRED_FRAMEWORKS`) plus the `load_required_frameworks` skip path, not bare `copy_runtime`. AppKit construction runs on the main thread; a non-`nsapplication-run` script's module body runs on the main thread, so this is fine.

- [ ] **Step 1: Write the new test**

Add `runtime_default_constructors` to `runtime_load_test.rs`. Scaffold it like `runtime_block_nil_guard` but use `build_harness_tree` (as `runtime_load_libraries_via_dynamic_require` does). The embedded Racket script:

```racket
#lang racket/base
(require ffi/unsafe
         (file "<TEMP>/runtime/type-mapping.rkt")
         (file "<TEMP>/generated/oo/appkit/nsalert.rkt")
         (file "<TEMP>/generated/oo/appkit/nscolorpanel.rkt")
         (file "<TEMP>/generated/oo/appkit/nsstackview.rkt")
         (file "<TEMP>/generated/oo/appkit/nssavepanel.rkt")
         (file "<TEMP>/generated/oo/appkit/nsopenpanel.rkt"))

(define (check name v)
  (unless v (eprintf "FAIL: ~a returned #f/nil~n" name) (exit 1)))

;; NSAlert — genuine synthesized zero-arg default constructor.
(check "make-nsalert" (make-nsalert))
;; NSStackView — explicit init selector.
(check "make-nsstackview-init-with-frame"
       (make-nsstackview-init-with-frame (make-nsrect 0 0 100 100)))
;; NSColorPanel / NSSavePanel / NSOpenPanel — class-factory accessors.
(check "nscolorpanel-shared-color-panel" (nscolorpanel-shared-color-panel))
(check "nssavepanel-save-panel"          (nssavepanel-save-panel))
(check "nsopenpanel-open-panel"          (nsopenpanel-open-panel))

(printf "OK: default/factory constructors — 5 checks passed~n")
```

The Rust side substitutes `<TEMP>` with the absolute tempdir path. Before writing the script, **confirm the exact binding names** against the freshly generated `generation/targets/racket/generated/oo/appkit/{nsalert,nscolorpanel,nsstackview,nssavepanel,nsopenpanel}.rkt` (`grep '(define (make-' …` and `grep 'shared-color-panel\|save-panel\|open-panel' …`) — adjust any name that differs. `make-nsrect` is provided by `runtime/type-mapping.rkt`.

- [ ] **Step 2: Run the test**

```bash
RUNTIME_LOAD_TEST=1 cargo test -p apianyware-macos-emit-racket --test runtime_load_test runtime_default_constructors -- --nocapture
```

Expected: PASS (5 checks). If a constructor returns `#f`/nil, investigate whether that class genuinely fails to construct (systematic-debugging) before changing the test.

- [ ] **Step 3: Run the full harness + clippy**

```bash
RUNTIME_LOAD_TEST=1 cargo test -p apianyware-macos-emit-racket --test runtime_load_test
cargo clippy --workspace --all-targets
```

Expected: all green.

- [ ] **Step 4: Commit**

```bash
git add generation/crates/emit-racket/tests/runtime_load_test.rs
git commit -m "$(cat <<'EOF'
test(racket): harness checks for class constructors (D3)

Adds runtime_default_constructors: verifies NSAlert (synthesized make-nsalert),
NSStackView (explicit init), and NSColorPanel/NSSavePanel/NSOpenPanel (class
factory accessors) actually construct. Of the five, only NSAlert has a
synthesized zero-arg make-<class>; the others have explicit SDK init selectors,
so the test exercises each class's real constructive entry point.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task D4: Framework-coverage deepening

**Files:**
- Modify: `generation/crates/emit-racket/tests/runtime_load_test.rs` (extend `REQUIRED_FRAMEWORKS`; add one `#[test]` fn)

Current framework coverage is shallow load checks; `CoreGraphics` is in `REQUIRED_FRAMEWORKS` with one `dynamic-require` of `functions.rkt`, and `AVFoundation`/`MapKit` are absent entirely. D4 adds deeper tests that construct values, call functions, and assert results.

> **Approach.** Add `"AVFoundation"` and `"MapKit"` to `REQUIRED_FRAMEWORKS` so `build_harness_tree` emits them; add any framework they transitively `require` (e.g. `CoreMedia`, `CoreLocation`) if the dynamic-require fails without it. Deep tests target deterministic C functions (no GUI, no main-thread constraint). `CoreGraphics` is fully covered by `runtime/type-mapping.rkt` cstructs; `MapKit`/`AVFoundation` struct types may not be — prefer scalar-returning and object-constructing entry points there. Exact assertions are scoped during implementation (the spec allows this) — the bar is "more than 'the module loads'."

- [ ] **Step 1: Extend `REQUIRED_FRAMEWORKS`**

In `runtime_load_test.rs`, add `"AVFoundation"` and `"MapKit"` to the `REQUIRED_FRAMEWORKS` array (lines ~60–74).

- [ ] **Step 2: Write the deep test**

Add `runtime_framework_deep_checks` to `runtime_load_test.rs`. Scaffold like `runtime_block_nil_guard` but `build_harness_tree(temp.path(), &frameworks)` first (with the `load_required_frameworks` skip path). The embedded Racket script — confirm every binding name against the freshly generated `generated/oo/{coregraphics,avfoundation,mapkit}/` files before finalizing:

```racket
#lang racket/base
(require ffi/unsafe
         (file "<TEMP>/runtime/type-mapping.rkt")
         (file "<TEMP>/generated/oo/coregraphics/functions.rkt")
         (file "<TEMP>/generated/oo/coregraphics/constants.rkt")
         (file "<TEMP>/generated/oo/mapkit/functions.rkt")
         (file "<TEMP>/generated/oo/avfoundation/functions.rkt"))

(define (expect name actual expected)
  (unless (equal? actual expected)
    (eprintf "FAIL: ~a = ~s, expected ~s~n" name actual expected) (exit 1)))
(define (expect-true name v)
  (unless v (eprintf "FAIL: ~a was false~n" name) (exit 1)))

;; CoreGraphics — affine-transform predicates (deterministic).
(expect "CGAffineTransformIsIdentity(identity)"
        (CGAffineTransformIsIdentity CGAffineTransformIdentity) #t)
(expect "CGAffineTransformIsIdentity(scale 2)"
        (CGAffineTransformIsIdentity (CGAffineTransformMakeScale 2.0 2.0)) #f)

;; MapKit — scalar geometry (deterministic, no struct round-trip needed).
(expect-true "MKMapPointsPerMeterAtLatitude(0) > 0"
             (> (MKMapPointsPerMeterAtLatitude 0.0) 0.0))

;; AVFoundation — aspect-fit geometry (deterministic).
;; Confirm the exact binding name + arg shape from generated avfoundation/functions.rkt.
;; (e.g. AVMakeRectWithAspectRatioInsideRect on a known size inside a known rect)

(printf "OK: framework deep checks passed~n")
```

If a CG/MK/AV function takes or returns a C struct type that `runtime/type-mapping.rkt` does not provide, either (a) pick a different deterministic function in that framework that uses only covered types, or (b) for MapKit, fall back to constructing a real object (`make-mkpointannotation-init-with-coordinate` with a `CLLocationCoordinate2D`) and asserting the `mkpointannotation?` predicate. Keep at least one genuine *assertion* (not just a load) per framework.

- [ ] **Step 3: Run the test**

```bash
RUNTIME_LOAD_TEST=1 cargo test -p apianyware-macos-emit-racket --test runtime_load_test runtime_framework_deep_checks -- --nocapture
```

Expected: PASS. If a `dynamic-require` fails for a missing transitive framework, add it to `REQUIRED_FRAMEWORKS` and retry. If an assertion fails, investigate whether the binding is genuinely wrong before adjusting the expectation.

- [ ] **Step 4: Run the full harness + clippy**

```bash
RUNTIME_LOAD_TEST=1 cargo test -p apianyware-macos-emit-racket --test runtime_load_test
cargo clippy --workspace --all-targets
```

Expected: all green.

- [ ] **Step 5: Commit**

```bash
git add generation/crates/emit-racket/tests/runtime_load_test.rs
git commit -m "$(cat <<'EOF'
test(racket): deeper framework coverage for CG/AVF/MapKit (D4)

Adds AVFoundation and MapKit to REQUIRED_FRAMEWORKS and a new
runtime_framework_deep_checks test that constructs values, calls functions,
and asserts results — CoreGraphics affine-transform predicates, MapKit scalar
geometry, AVFoundation aspect-fit geometry — beyond the prior shallow load
checks.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task E: Update `LLM_STATE` cross-cutting docs

**Files:**
- Modify: `LLM_STATE/overview.md`
- Modify: `LLM_STATE/project-workflow.md`

**Done when:** neither file describes any workstream as phase-cycle-driven; both point at this design + plan; the sample-app count is 7.

- [ ] **Step 1: Update `LLM_STATE/overview.md`**

- In the **Plans** section: replace the "Racket Target" table row and the paragraph "The Racket target plan still uses the Ravel-Lite phase cycle … `run.sh`" with a pointer to the new design + plan, mirroring how the `core` paragraph above it reads:

  ```
  The **racket target** is tracked by
  `docs/specs/2026-05-22-racket-completion-design.md` (design) and
  `docs/superpowers/plans/2026-05-22-racket-completion.md` (plan). Its prior
  Ravel-Lite phase-cycle state is archived under
  `LLM_STATE/targets/racket/archive/`.
  ```

- In the **Targets** table: change the `racket` row's "Apps Done" cell from `3/7` to `7/7` (all seven surviving sample apps are built — `modaliser` was deleted in Task A). Leave the `racket-functional` row.

- [ ] **Step 2: Update `LLM_STATE/project-workflow.md`**

- Remove the phase-cycle framing: the bullet "`LLM_STATE/targets/{target}/backlog.md` — per-target backlogs (still on the Ravel-Lite phase cycle)" should be replaced with a pointer to the racket design + plan (and note that core is likewise plan-tracked).
- Drop the two "Modaliser as the capstone" references (the intro paragraph "culminating in Modaliser as the capstone proving a target's bindings are production-ready", and the "App Progression" line "Simple -> complex -> Modaliser capstone"). Reword to describe the app progression as simple→complex without naming the abandoned Modaliser app (e.g. "culminating in a capstone app").
- Leave the "GUI Testing With TestAnyware" section as-is (TestAnyware terminology is already correct). Leave `template.md` / `new-language-guide.md` references as-is — out of scope per the design spec.

- [ ] **Step 3: Verify**

```bash
grep -rIn -i 'ravel-lite\|phase cycle\|phase-cycle' LLM_STATE/overview.md LLM_STATE/project-workflow.md
grep -rIn -i 'modaliser\|guivision' LLM_STATE/overview.md LLM_STATE/project-workflow.md
```

Expected: no "phase cycle"/"Ravel-Lite" framing describing a live workstream; no `modaliser` or `guivision` references. (A historical mention that the cycle *was* retired is acceptable; a claim that a workstream still uses it is not.)

- [ ] **Step 4: Commit**

(The `guivision → TestAnyware` corrections to `README.md` and the design spec were committed in the setup commit before execution began — do not re-add them here.)

```bash
git add LLM_STATE/overview.md LLM_STATE/project-workflow.md
git commit -m "$(cat <<'EOF'
docs(racket): retire phase-cycle framing in LLM_STATE (Item E)

Item E of the racket phase-cycle retirement. overview.md and
project-workflow.md no longer describe any workstream as phase-cycle-driven
and now point at the racket design + plan; sample-app count corrected to 7.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task F: Final verification gate

**Files:** none modified. Orchestrator-run.

- [ ] **Step 1: Regenerate the pipeline from scratch**

```bash
export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
cargo run -p apianyware-macos-collect
cargo run -p apianyware-macos-analyze -- resolve
cargo run -p apianyware-macos-analyze -- annotate --llm-dir analysis/ir/llm-annotations
cargo run -p apianyware-macos-analyze -- enrich
cargo run -p apianyware-macos-generate
```

Expected: **0 enrichment violations**; `generate` completes cleanly.

- [ ] **Step 2: Run the full verification gate**

```bash
cargo test --workspace
cargo clippy --workspace --all-targets
RUNTIME_LOAD_TEST=1 cargo test -p apianyware-macos-emit-racket --test runtime_load_test
make lint-annotations
(cd swift && swift test)            # SDKROOT already exported
```

Expected: Rust tests pass; clippy clean; runtime-load harness green (including the three new D2/D3/D4 tests); `make lint-annotations` exits 0; `swift test` green.

- [ ] **Step 3: Confirm the Success Criteria**

Verify each against the tree:
- `LLM_STATE/` contains no live phase-cycle machinery — only `LLM_STATE/targets/racket/archive/` retains historical record. (`find LLM_STATE -name phase.md -o -name '*-baseline' -o -name 'backlog.yaml'` → empty.)
- No `modaliser` path or reference survives outside that archive and historical specs (re-run the Task A Step 4 grep).
- No `guivision` reference survives outside the read-only archives (`grep -rIl -i guivision --exclude-dir=.git .` → only `LLM_STATE/*/archive/*` and the deleted-by-now `backlog.yaml` absent).
- `knowledge/targets/racket.md` is self-contained.
- D1–D4 complete and verified (D1 by VM render, D2–D4 by the harness).
- `LLM_STATE/overview.md` and `project-workflow.md` describe no workstream as phase-cycle-driven and point at this design + plan.

- [ ] **Step 4: Finishing the branch**

Use the superpowers:finishing-a-development-branch skill to decide integration (merge / PR / cleanup).

---

## Self-review notes

- **Spec coverage:** Item A → Task A; Item B → Task B; Item C → Task C; Item D (D1–D4) → Tasks D1–D4; Item E → Task E. The three already-done backlog items (`LIBRARY_LOAD_CHECKS`/`RUNTIME_FILES` audit, CF struct-globals gap, Modaliser P3 contracts) are deliberately not tasked, per the spec.
- **Ordering:** Task 0 (baseline) → A → C (reads `memory.yaml` before B archives it) → B → D1 → D2 → D3 → D4 (D2/D3/D4 serialized — same file) → E → F.
- **Known deviations flagged in-plan:** (1) `compact-baseline` deleted in Task B though the spec's explicit list omits it (required by Item B's done-criterion). (2) D3 tests each class's real constructor because only `NSAlert` has a synthesized `make-<class>` — faithful to D3's intent. Both must appear in the orchestrator's final report.

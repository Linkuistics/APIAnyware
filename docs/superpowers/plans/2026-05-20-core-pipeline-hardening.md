# Core Pipeline Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close the four genuinely-open core-pipeline backlog items and retire the Ravel-Lite phase-cycle machinery, leaving the pipeline regenerated, verified, and self-documenting.

**Architecture:** Five sequential sessions, each ending with a review checkpoint and commit. The orchestrating session dispatches subagents for investigation and TDD implementation but never delegates pipeline regeneration or the verification gate — `analysis/ir/*` and `generation/targets/*/generated/` are shared mutable state and concurrent regeneration would race the mtime-based freshness check in `regenerate-stale-pipeline.sh`.

**Tech Stack:** Rust workspace (collection/analysis/generation crates), Swift dylibs, Racket runtime, libclang + swift-api-digester for extraction, `make` for the new annotation gate.

**Source spec:** `docs/specs/2026-05-20-core-pipeline-hardening-design.md`

---

## Working Environment

The pipeline's IR checkpoints (`collection/ir/collected/`, `analysis/ir/*`) and generated output (`generation/targets/racket/generated/`) are **gitignored build artifacts** — a fresh worktree has none of them. Task 1 materializes them. Every later session assumes Task 1 has run in the current checkout.

Investigation-gated tasks are marked **[INVESTIGATION-GATED]**: their implementation code is determined by a preceding investigation step, so those steps describe the procedure and decision rather than pre-written code. This is deliberate, not a placeholder.

---

## Session 0 — Re-baseline & retire Ravel-Lite

### Task 1: Establish the verified pipeline baseline

**Files:**
- No file changes — this is a verification gate.

- [ ] **Step 1: Materialize the collected IR**

If `collection/ir/collected/` is absent or empty, run the SDK extraction (requires Xcode / libclang / swift-api-digester, ~2 min):

```bash
cargo run -p apianyware-macos-collect
```

Alternatively copy `collection/ir/collected/` from an existing checkout.

- [ ] **Step 2: Run the full pipeline**

```bash
./analysis/scripts/regenerate-stale-pipeline.sh
```

Expected: stages `analyze` and `generate` run (or report "up to date"), exit 0.

- [ ] **Step 3: Verify the workspace is green**

```bash
cargo test --workspace
cd swift && swift test && cd ..
cargo clippy --workspace
```

Expected: all tests pass, clippy clean. Record the test counts (README cites ~248 Rust + ~64 Swift) — a later regression should be measured against these.

- [ ] **Step 4: Confirm 0 enrichment violations**

```bash
cargo run -p apianyware-macos-analyze -- enrich 2>&1 | grep -i "violation" || echo "no violations reported"
```

Expected: no violation lines. If violations appear, STOP — the baseline is not clean; investigate before continuing.

No commit — nothing changed.

### Task 2: Retire the Ravel-Lite phase-cycle machinery

> **COMPLETED 2026-05-20**, ahead of plan execution. `LLM_STATE/core/memory.yaml`
> and `session-log.yaml` were archived to `LLM_STATE/core/archive/` (with a
> `README.md`); the phase scripts (`phase.md`, `pre-work.sh`, `prompt-work.md`,
> `*-baseline`, `dream-*`, `latest-session.yaml`, `backlog.yaml`) were deleted;
> `LLM_STATE/overview.md` and `project-workflow.md` were updated. **Skip this
> task** — verify the above is present and move to Task 3.

**Files:**
- Create: `LLM_STATE/core/archive/` (directory)
- Modify (move into archive): `LLM_STATE/core/memory.yaml`, `LLM_STATE/core/session-log.yaml`
- Delete: `LLM_STATE/core/phase.md`, `pre-work.sh`, `prompt-work.md`, `work-baseline`, `reflect-baseline`, `triage-baseline`, `compact-baseline`, `dream-baseline`, `dream-word-count`, `latest-session.yaml`, `backlog.yaml`
- Modify: `LLM_STATE/overview.md`, `LLM_STATE/project-workflow.md`

- [ ] **Step 1: Archive the reference state**

```bash
mkdir -p LLM_STATE/core/archive
git mv LLM_STATE/core/memory.yaml LLM_STATE/core/archive/memory.yaml
git mv LLM_STATE/core/session-log.yaml LLM_STATE/core/archive/session-log.yaml
```

- [ ] **Step 2: Delete the Ravel-Lite machinery**

```bash
git rm LLM_STATE/core/phase.md LLM_STATE/core/pre-work.sh \
       LLM_STATE/core/prompt-work.md LLM_STATE/core/work-baseline \
       LLM_STATE/core/reflect-baseline LLM_STATE/core/triage-baseline \
       LLM_STATE/core/compact-baseline LLM_STATE/core/dream-baseline \
       LLM_STATE/core/dream-word-count LLM_STATE/core/latest-session.yaml \
       LLM_STATE/core/backlog.yaml
```

- [ ] **Step 3: Add an archive README**

Create `LLM_STATE/core/archive/README.md`:

```markdown
# Archived core-workstream state

`memory.yaml` and `session-log.yaml` are the read-only record of the
Ravel-Lite-driven core pipeline sessions (through session 51, 2026-04-28).
The Ravel-Lite phase cycle has been retired; the core workstream is now
tracked by `docs/specs/2026-05-20-core-pipeline-hardening-design.md` and
`docs/superpowers/plans/2026-05-20-core-pipeline-hardening.md`.

Pipeline learnings from `memory.yaml` are distilled into `knowledge/pipeline/`.
```

- [ ] **Step 4: Update LLM_STATE/overview.md**

Open `LLM_STATE/overview.md`. In the "## Plans" section, remove the `Core Pipeline | LLM_STATE/core/ | ./LLM_STATE/core/run.sh` row and the paragraph describing `backlog.md`/`phase.md`/`prompt-*.md`/`run.sh`. Replace with:

```markdown
The core pipeline is tracked by `docs/specs/2026-05-20-core-pipeline-hardening-design.md`
(design) and `docs/superpowers/plans/2026-05-20-core-pipeline-hardening.md` (plan).
```

Leave the "## Core Pipeline", "## Targets", and "## Cross-Cutting Blockers" sections intact.

- [ ] **Step 5: Update LLM_STATE/project-workflow.md**

Open `LLM_STATE/project-workflow.md`. Remove references to `../Ravel-Lite/README.md`, the phase cycle, and `create-plan.md`. Change the coding-standards line so it points at `README.md`'s Coding Conventions instead of `../Ravel-Lite/defaults/fixed-memory/coding-style*.md`. Keep the Knowledge System, Adding To The Matrix, App Bundling, GUI Testing, and Pipeline Changes sections.

- [ ] **Step 6: Verify nothing else references the deleted files**

```bash
grep -rn "LLM_STATE/core/\(phase\|pre-work\|prompt-work\|backlog\|run\.sh\)\|Ravel-Lite" \
  --include='*.md' --include='*.sh' --include='*.rs' . | grep -v archive/
```

Expected: no results (or only the spec/plan docs, which are fine). Fix any stragglers.

- [ ] **Step 7: Commit**

```bash
git add -A LLM_STATE/
git commit -m "chore: retire Ravel-Lite phase-cycle machinery from LLM_STATE/core"
```

### Task 3: Prune the hardcoded UI class list (Item 2, part 1)

**Files:**
- Modify: `analysis/crates/annotate/src/heuristics.rs:287-324` (the list) and the `derive_threading` tests in the same file (the explorer located them near lines 603-665).
- Test: `analysis/crates/annotate/src/heuristics.rs` (in-file `#[cfg(test)]` module).

- [ ] **Step 1: Replace the existing threading test with attribute-aware tests**

In `heuristics.rs`, find the test `test_threading_ui_class` (asserts `derive_threading` flags `NSWindow` as `MainThreadOnly`). Replace it with these three tests:

```rust
#[test]
fn appkit_class_not_main_thread_without_swift_attributes() {
    // AppKit classes no longer appear in the hardcoded list — they reach
    // the heuristic via swift_attributes (NS_SWIFT_UI_ACTOR / @MainActor).
    assert_eq!(derive_threading("NSWindow", "someMethod", &[]), None);
}

#[test]
fn appkit_class_main_thread_via_swift_attributes() {
    assert_eq!(
        derive_threading("NSWindow", "someMethod", &["MainActor".to_string()]),
        Some(ThreadingConstraint::MainThreadOnly)
    );
}

#[test]
fn uikit_class_still_main_thread_from_hardcoded_list() {
    assert_eq!(
        derive_threading("UIView", "someMethod", &[]),
        Some(ThreadingConstraint::MainThreadOnly)
    );
}
```

- [ ] **Step 2: Run the tests to verify the first one fails**

```bash
cargo test -p apianyware-macos-annotate appkit_class_not_main_thread_without_swift_attributes
```

Expected: FAIL — `NSWindow` is still in the hardcoded list, so `derive_threading` returns `Some(MainThreadOnly)`, not `None`.

- [ ] **Step 3: Prune the AppKit names from the list**

In `heuristics.rs`, replace the `main_thread_classes` array (lines 287-324) with the UIKit-only set:

```rust
    // UIKit classes are main-thread-only. AppKit classes are not listed
    // here: every NS_SWIFT_UI_ACTOR / @MainActor-decorated AppKit class
    // reaches this heuristic via `class_swift_attributes` above, so a
    // hardcoded AppKit list would be dead code.
    let main_thread_classes = [
        "UIView",
        "UIWindow",
        "UIButton",
        "UILabel",
        "UITextField",
        "UITableView",
        "UICollectionView",
        "UIViewController",
    ];
```

Update the comment block above the list (lines 286-ish) accordingly.

- [ ] **Step 4: Run the tests to verify all pass**

```bash
cargo test -p apianyware-macos-annotate
```

Expected: PASS — all three new tests pass; no other annotate test regresses.

- [ ] **Step 5: Commit**

```bash
cargo +nightly fmt
git add analysis/crates/annotate/src/heuristics.rs
git commit -m "feat(annotate): prune derive_threading UI list to UIKit-only"
```

### Task 4: Wire the annotation guardrail (Item 2, part 2)

**Files:**
- Create: `Makefile` (repo root — none exists today)

- [ ] **Step 1: Create the Makefile**

Create `Makefile` at the repo root:

```makefile
# APIAnyware-MacOS task runner.
#
# lint-annotations — gate against stale / redundant LLM annotations.
#   Replaces the retired Ravel-Lite triage pre-hook. Requires the pipeline
#   to have been run at least once (analysis/ir/ checkpoints must exist).

.PHONY: lint-annotations

lint-annotations:
	./analysis/scripts/check-llm-annotation-drift.sh --skip-regen
	mkdir -p /tmp/empty-llm-dir /tmp/heuristic-only-annotated
	cargo run --release -q -p apianyware-macos-analyze -- annotate \
		--output-dir /tmp/heuristic-only-annotated --llm-dir /tmp/empty-llm-dir
	python3 ./analysis/scripts/audit-llm-redundancy.py
```

The drift check runs first; `make` aborts the target if it exits non-zero (drift detected). The redundancy audit is informational and always exits 0.

- [ ] **Step 2: Run the target to verify it works**

```bash
make lint-annotations
```

Expected: the drift check prints `ok: all N .llm.json files validate ...` and exits 0; the redundancy audit prints its `redundant_active` / `orphaned` / `net_additive` summary. If the drift check reports drift, that is a real finding — STOP and resolve it before committing.

- [ ] **Step 3: Commit**

```bash
git add Makefile
git commit -m "build: add make lint-annotations annotation-staleness gate"
```

**Session 0 checkpoint:** Pipeline verified green, Ravel-Lite machinery retired, Item 2 complete. Review the four commits before proceeding.

---

## Session 1 — Orphaned Swift-only frameworks (Item 1)

### Task 5: [INVESTIGATION-GATED] Identify the discriminating signal

**Files:**
- Create: `docs/specs/2026-05-20-core-pipeline-hardening-item1-findings.md` (investigation record)

- [ ] **Step 1: Dump the ABI JSON for an affected module**

```bash
xcrun swift-api-digester -dump-sdk -module _AppIntents_SwiftUI \
  -o /tmp/_AppIntents_SwiftUI.abi.json \
  -sdk "$(xcrun --show-sdk-path)" 2>/dev/null
python3 -m json.tool /tmp/_AppIntents_SwiftUI.abi.json | head -120
```

Identify each top-level `Class`/`Protocol`/`Struct`/`Enum` node, its `moduleName`, and any flags (`isExternal`, `isFromExtension`, declarations of children).

- [ ] **Step 2: Dump the ABI JSON for a known correct-to-drop case**

The session-48 fix targeted spurious foreign re-emissions such as `CreateMLComponents` re-emitting `Sequence` (`moduleName: "Swift"`). Dump that module the same way and inspect the foreign node:

```bash
xcrun swift-api-digester -dump-sdk -module CreateMLComponents \
  -o /tmp/CreateMLComponents.abi.json -sdk "$(xcrun --show-sdk-path)" 2>/dev/null
python3 -c "import json; d=json.load(open('/tmp/CreateMLComponents.abi.json')); \
  [print(n.get('name'), n.get('declKind'), n.get('moduleName'), \
  {k:v for k,v in n.items() if k not in ('name','declKind','moduleName','children')}) \
  for n in d.get('ABIRoot',d).get('children',[]) if n.get('declKind') in \
  ('Class','Protocol','Struct','Enum')]"
```

- [ ] **Step 3: Compare and choose the signal**

Compare the foreign nodes in the keep case (`IntentParameter` in `_AppIntents_SwiftUI`) and the drop case (`Sequence` in `CreateMLComponents`). Identify a field or structural property that distinguishes "this framework legitimately extends and surfaces this external type" from "this is a spurious container for our extension members". Candidate signals named in the spec: an `isExternal`/`isFromExtension` flag; whether the node's children are exclusively extension members; whether the type also appears as a primary decl in its own framework's collected IR.

- [ ] **Step 4: Record the findings**

Write `docs/specs/2026-05-20-core-pipeline-hardening-item1-findings.md` documenting: the observed ABI shapes for both cases, the chosen discriminating signal, the precise refined rule for `is_foreign_module_type_decl`, and whether `CoreTransferable` (a Swift-only protocol/struct framework with genuinely 0 classes) is fixed by this change or is a distinct issue. Commit it:

```bash
git add docs/specs/2026-05-20-core-pipeline-hardening-item1-findings.md
git commit -m "docs: record orphaned-framework root-cause investigation"
```

### Task 6: [INVESTIGATION-GATED] Refine the foreign-module filter

**Files:**
- Modify: `collection/crates/extract-swift/src/declaration_mapping.rs:171-193` (`is_foreign_module_type_decl`)
- Test: `collection/crates/extract-swift/src/declaration_mapping.rs` (in-file `#[cfg(test)]` module)

- [ ] **Step 1: Write the failing tests**

Add two tests to the `#[cfg(test)]` module in `declaration_mapping.rs`. Construct the `AbiNode` fixtures following the existing test patterns in that file (reuse the existing node constructor/struct-literal style — do not invent fields). One test asserts the **keep** case (an extended external class like `IntentParameter`, `moduleName` ≠ framework, but carrying the signal chosen in Task 5) is NOT treated as a foreign-module decl; the other asserts the **drop** case (a spurious re-emission like `Sequence`) still IS:

```rust
#[test]
fn keeps_legitimately_extended_external_class() {
    // _AppIntents_SwiftUI surfaces IntentParameter (moduleName "AppIntents")
    // as part of its own API — it must NOT be dropped.
    let node = /* AbiNode fixture: declKind=Class, module_name="AppIntents",
                  plus the keep-signal identified in Task 5 */;
    assert!(!is_foreign_module_type_decl(&node, "_AppIntents_SwiftUI"));
}

#[test]
fn drops_spurious_foreign_reemission() {
    // CreateMLComponents re-emits Swift.Sequence purely as an extension
    // container — it must still be dropped.
    let node = /* AbiNode fixture: declKind=Protocol, module_name="Swift",
                  without the keep-signal */;
    assert!(is_foreign_module_type_decl(&node, "CreateMLComponents"));
}
```

Fill the fixture bodies using the signal and rule from `item1-findings.md`.

- [ ] **Step 2: Run the tests to verify the keep test fails**

```bash
cargo test -p apianyware-macos-extract-swift keeps_legitimately_extended_external_class
```

Expected: FAIL — the current `module != framework_name` rule drops the keep case.

- [ ] **Step 3: Implement the refined rule**

Modify `is_foreign_module_type_decl` to apply the discriminating signal from `item1-findings.md`: a node is a foreign-module decl (drop) only when `moduleName` ≠ framework AND it lacks the keep-signal. Update the doc comment to explain the keep/drop distinction.

- [ ] **Step 4: Run the tests to verify all pass**

```bash
cargo test -p apianyware-macos-extract-swift
```

Expected: PASS — both new tests pass; no existing extract-swift test regresses (the session-48 golden tests for the foreign-module filter must still hold).

- [ ] **Step 5: Commit**

```bash
cargo +nightly fmt
git add collection/crates/extract-swift/src/declaration_mapping.rs
git commit -m "fix(extract-swift): keep extended external classes in synthetic cross-framework modules"
```

### Task 7: Re-collect and verify the affected frameworks

**Files:**
- No source changes — regeneration + verification.

- [ ] **Step 1: Re-run collection**

```bash
cargo run -p apianyware-macos-collect
```

- [ ] **Step 2: Verify the `_*_SwiftUI` modules now have classes**

```bash
for fw in _AppIntents_SwiftUI _RealityKit_SwiftUI _PhotosUI_SwiftUI \
          _SwiftData_SwiftUI _SwiftData_CoreData _WebKit_SwiftUI; do
  n=$(python3 -c "import json; print(len(json.load(open('collection/ir/collected/$fw.json'))['classes']))" 2>/dev/null || echo MISSING)
  echo "$fw: $n classes"
done
```

Expected: each module reports a non-zero class count. If any is still 0, the refined filter did not cover it — return to Task 5 for that module.

- [ ] **Step 3: Re-run resolve, annotate, enrich**

```bash
./analysis/scripts/regenerate-stale-pipeline.sh
```

Expected: exit 0, 0 enrichment violations.

- [ ] **Step 4: Settle the CoreTransferable sub-case**

Per `item1-findings.md`, `CoreTransferable` genuinely has 0 classes. Confirm whether its annotations (if any) target protocol methods and whether `annotate` iterates protocol methods. If `CoreTransferable` is fully handled, note it. If it is a distinct bug (annotate not iterating protocols), file it: create `docs/specs/2026-05-20-coretransferable-followup.md` with a one-paragraph problem statement and add a note to the findings doc. Do not expand this task to fix it.

- [ ] **Step 5: Run the full test suite and commit any follow-up doc**

```bash
cargo test --workspace
git add docs/specs/ 2>/dev/null && git commit -m "docs: file CoreTransferable annotation follow-up" || echo "no follow-up doc to commit"
```

**Session 1 checkpoint:** The extract-swift filter is refined, the `_*_SwiftUI` modules carry classes again, the pipeline re-runs clean, and the CoreTransferable sub-case is resolved or filed. Review before proceeding.

---

## Session 2 — Emitter contract tightening (Item 3)

### Task 8: Class-specific receiver predicate (Gap A)

**Files:**
- Modify: `generation/crates/emit-racket/src/emit_class.rs` — the receiver contract (`SELF_CONTRACT` at line 318, used at the instance-method loop line 521 and the property-accessor `self_arg`).
- Test: `generation/crates/emit-racket/src/emit_class.rs` (in-file tests `test_instance_method_contract`, `test_class_file_has_provide_contract`).
- Golden: `generation/crates/emit-racket/tests/golden/oo/`, `golden-foundation/oo/`, `golden-appkit/oo/`.

- [ ] **Step 1: Confirm the class's own predicate is in scope**

Read `emit_class_predicates` and the call site that passes `class_names` to it. The receiver contract `<class>?` (e.g. `tkbutton?`) must be defined in the class's own generated file. If `emit_class_predicates` only emits predicates for *referenced* classes, the class's own name must be added to that set. Note the finding before editing.

- [ ] **Step 2: Write/adjust the failing unit test**

In `emit_class.rs`'s test module, update `test_instance_method_contract` so it asserts the receiver contract is the class-specific predicate, not the generic `objc-object?`. For a TestKit class `TKButton` with an instance method, assert the generated contract begins with `(c-> tkbutton? ...`:

```rust
#[test]
fn instance_method_contract_uses_class_specific_receiver() {
    // Build a one-class framework with one instance method (reuse the
    // existing test-fixture helpers in this module), emit it, and assert:
    assert!(contract.starts_with("(c-> tkbutton?"));
}
```

- [ ] **Step 3: Run the test to verify it fails**

```bash
cargo test -p apianyware-macos-emit-racket instance_method_contract_uses_class_specific_receiver
```

Expected: FAIL — the receiver is currently `objc-object?`.

- [ ] **Step 4: Implement the receiver-predicate change**

In `emit_class.rs`: replace the use of the `SELF_CONTRACT` constant in the instance-method loop (line 521) and in the property-accessor `self_arg` with `make_class_predicate_name(&cls.name)`. If Step 1 found the class's own predicate is not emitted in its file, also add the class's own name to the set passed to `emit_class_predicates`. Keep `SELF_CONTRACT` only if some path genuinely still needs the generic predicate; otherwise remove it. Update the doc comment at lines 310-318.

- [ ] **Step 5: Run unit tests**

```bash
cargo test -p apianyware-macos-emit-racket --lib
```

Expected: PASS for the unit tests. The golden snapshot tests will still fail — that is expected and handled next.

- [ ] **Step 6: Update and review the golden snapshots**

```bash
UPDATE_GOLDEN=1 cargo test -p apianyware-macos-emit-racket
git diff --stat generation/crates/emit-racket/tests/golden*
git diff generation/crates/emit-racket/tests/golden/oo/tkbutton.rkt
```

Review the diff: the change must be uniform — every method/accessor contract's first argument changes from `objc-object?` to the class predicate, and each class file gains its own predicate definition. Nothing else should move. If anything else changed, investigate before accepting.

- [ ] **Step 7: Run the full suite and commit**

```bash
cargo test -p apianyware-macos-emit-racket
cargo +nightly fmt
git add generation/crates/emit-racket/
git commit -m "feat(emit-racket): class-specific receiver predicate in generated contracts"
```

### Task 9: [INVESTIGATION-GATED] Tighten integer contracts (Gap B)

**Files:**
- Modify: `generation/crates/emit-racket/src/emit_functions.rs:34-49` (`map_contract` primitive arm) and possibly `normalize_primitive`.
- Test: `generation/crates/emit-racket/src/emit_functions.rs` (in-file tests near lines 305-342).
- Golden: as Task 8.

- [ ] **Step 1: Identify what actually falls through to `any/c`**

`map_contract` (`emit_functions.rs:34`) already maps `int8/16/32/64` → `exact-integer?` and `uint8/16/32/64` → `exact-nonnegative-integer?`; line 48 sends every *unrecognized* primitive name to `any/c`. Find which integer-typed primitives reach line 48 in real output:

```bash
grep -rhoE '\(c-> [^)]*any/c[^)]*\)' generation/targets/racket/generated/ | sort -u | head -40
```

Then trace, for a sampled method, the primitive `name` reaching `map_contract` and what `normalize_primitive` does with it. Determine whether the gap is unrecognized canonical names (e.g. `int`, `long`, `nsinteger`) or a `normalize_primitive` that fails to canonicalize them.

- [ ] **Step 2: Write the failing test**

In `emit_functions.rs`'s test module, add a test asserting the integer primitive name(s) found in Step 1 map to `exact-integer?` / `exact-nonnegative-integer?` rather than `any/c`. Follow the existing `map_contract` test pattern (lines 305-342). Example shape:

```rust
#[test]
fn integer_primitive_maps_to_exact_integer() {
    let t = /* TypeRef::primitive with the name found in Step 1 */;
    assert_eq!(map_contract(&t, false), "exact-integer?");
}
```

- [ ] **Step 3: Run the test to verify it fails**

```bash
cargo test -p apianyware-macos-emit-racket integer_primitive_maps_to_exact_integer
```

Expected: FAIL — the name currently falls through to `any/c`.

- [ ] **Step 4: Implement the fix**

Per Step 1: either add the missing integer names to the recognized arms of `map_contract` (preserving signed → `exact-integer?` / unsigned → `exact-nonnegative-integer?`), or fix `normalize_primitive` to canonicalize them to the existing `int*`/`uint*` names. Prefer fixing `normalize_primitive` if the gap is non-canonical names, so the FFI mapper benefits too.

- [ ] **Step 5: Run unit tests and update goldens**

```bash
cargo test -p apianyware-macos-emit-racket --lib
UPDATE_GOLDEN=1 cargo test -p apianyware-macos-emit-racket
git diff generation/crates/emit-racket/tests/golden/oo/tkbutton.rkt
```

Expected unit tests PASS; golden diff shows integer contracts changing `any/c` → `exact-integer?`/`exact-nonnegative-integer?` and nothing else.

- [ ] **Step 6: Run the full suite and commit**

```bash
cargo test -p apianyware-macos-emit-racket
cargo +nightly fmt
git add generation/crates/emit-racket/
git commit -m "feat(emit-racket): tighten integer contracts from any/c to exact-integer?"
```

**Session 2 checkpoint:** Generated contracts use class-specific receivers and tightened integer types; goldens updated and reviewed. Review before proceeding.

---

## Session 3 — Stable codesigning identity (Item 4)

### Task 10: Document and create the self-signed signing identity

**Files:**
- Create: `docs/codesigning-identity.md`

- [ ] **Step 1: Write the certificate recipe**

Create `docs/codesigning-identity.md` documenting how to create a persistent self-signed code-signing certificate named **`APIAnyware Local Signing`**:

```markdown
# Local code-signing identity

Sample-app bundles are signed with a persistent self-signed certificate so the
binary CDHash is stable across rebuilds and macOS TCC grants (Accessibility,
Screen Recording, …) survive a rebuild. Create it once per machine.

## Create the certificate

Keychain Access → Certificate Assistant → "Create a Certificate…":
- Name: `APIAnyware Local Signing`
- Identity Type: Self-Signed Root
- Certificate Type: **Code Signing**
- Let me override defaults: not required

Leave it in the **login** keychain.

## Verify

    security find-identity -p codesigning -v

`APIAnyware Local Signing` must appear in the list. The bundler
(`apianyware-macos-bundle-racket`) uses it automatically when present and
falls back to ad-hoc signing (with a warning) when it is absent.
```

- [ ] **Step 2: Create the certificate and verify**

Follow the recipe to create the certificate, then:

```bash
security find-identity -p codesigning -v | grep "APIAnyware Local Signing"
```

Expected: the identity is listed.

- [ ] **Step 3: Commit**

```bash
git add docs/codesigning-identity.md
git commit -m "docs: document the local self-signed code-signing identity"
```

### Task 11: Wire the identity into bundle-racket

**Files:**
- Modify: `generation/crates/bundle-racket/src/bundle.rs` (`AppSpec::from_script_name` at lines 58-70; add an identity-resolution helper)
- Test: `generation/crates/bundle-racket/src/bundle.rs` (in-file `#[cfg(test)]` module)

- [ ] **Step 1: Write the failing test**

Add a test asserting that `AppSpec::from_script_name` resolves `signing_identity` to the convention identity when it is available, and to `None` otherwise. Because the result depends on the host keychain, test the resolver helper directly with an injectable lookup:

```rust
#[test]
fn resolves_convention_identity_when_present() {
    assert_eq!(
        resolve_signing_identity(|_name| true),
        Some("APIAnyware Local Signing".to_string())
    );
}

#[test]
fn falls_back_to_none_when_identity_absent() {
    assert_eq!(resolve_signing_identity(|_name| false), None);
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cargo test -p apianyware-macos-bundle-racket resolves_convention_identity_when_present
```

Expected: FAIL — `resolve_signing_identity` does not exist.

- [ ] **Step 3: Implement the resolver and wire it in**

In `bundle.rs`, add:

```rust
/// The persistent self-signed identity documented in docs/codesigning-identity.md.
pub const LOCAL_SIGNING_IDENTITY: &str = "APIAnyware Local Signing";

/// Resolve the signing identity to bake into bundled apps. Uses the
/// persistent local identity when the keychain has it (stable CDHash
/// across rebuilds), otherwise `None` (link-time ad-hoc — bundling still
/// works, but TCC grants reset on rebuild).
pub fn resolve_signing_identity(is_available: impl Fn(&str) -> bool) -> Option<String> {
    if is_available(LOCAL_SIGNING_IDENTITY) {
        Some(LOCAL_SIGNING_IDENTITY.to_string())
    } else {
        tracing::warn!(
            identity = LOCAL_SIGNING_IDENTITY,
            "code-signing identity not found; bundling with ad-hoc signature \
             (TCC grants will reset on rebuild — see docs/codesigning-identity.md)"
        );
        None
    }
}

/// Query the keychain for a code-signing identity by name.
fn keychain_has_identity(name: &str) -> bool {
    std::process::Command::new("security")
        .args(["find-identity", "-p", "codesigning", "-v"])
        .output()
        .map(|o| String::from_utf8_lossy(&o.stdout).contains(name))
        .unwrap_or(false)
}
```

Change `AppSpec::from_script_name` (line 68) so `signing_identity` is `resolve_signing_identity(keychain_has_identity)` instead of `None`. Update the doc comment on the `signing_identity` field (lines 42-48).

- [ ] **Step 4: Run the tests to verify they pass**

```bash
cargo test -p apianyware-macos-bundle-racket
```

Expected: PASS — both resolver tests pass; existing bundle tests unaffected.

- [ ] **Step 5: Commit**

```bash
cargo +nightly fmt
git add generation/crates/bundle-racket/src/bundle.rs
git commit -m "feat(bundle-racket): sign bundled apps with the persistent local identity"
```

### Task 12: Verify CDHash stability and TCC survival in-VM

**Files:**
- No source changes — verification.

- [ ] **Step 1: Bundle a sample app twice and compare CDHash**

```bash
cargo run --example bundle_app -p apianyware-macos-bundle-racket -- hello-window
codesign -dvvv "generation/targets/racket/apps/hello-window/build/Hello Window.app" 2>&1 | grep CDHash
cargo run --example bundle_app -p apianyware-macos-bundle-racket -- hello-window
codesign -dvvv "generation/targets/racket/apps/hello-window/build/Hello Window.app" 2>&1 | grep CDHash
```

Expected: the two `CDHash` values are identical. If they differ, the identity is not being applied — return to Task 11.

- [ ] **Step 2: Verify TCC-grant survival in a TestAnyware VM**

Follow the TestAnyware workflow in `README.md` ("GUI Testing with TestAnyware"). Bundle an app that needs a TCC permission (e.g. the Modaliser app, which uses Accessibility), grant the permission in-VM, rebuild and re-deploy the app, relaunch, and confirm the permission is still granted (the app does not re-prompt).

- [ ] **Step 3: Record the result**

Append a "## Verification" section to `docs/codesigning-identity.md` noting the CDHash-stability and TCC-survival results, then commit:

```bash
git add docs/codesigning-identity.md
git commit -m "docs: record codesigning verification results"
```

**Session 3 checkpoint:** Bundled apps are signed with the persistent identity, CDHash is stable, TCC grants survive rebuilds. Review before proceeding.

---

## Session 4 — Final integration

### Task 13: Full from-scratch pipeline regeneration and workspace verification

**Files:**
- No source changes — full regeneration.

- [ ] **Step 1: Regenerate the pipeline from scratch**

```bash
rm -rf analysis/ir/resolved analysis/ir/annotated analysis/ir/enriched
cargo run -p apianyware-macos-collect
cargo run -p apianyware-macos-analyze
cargo run -p apianyware-macos-generate
```

- [ ] **Step 2: Confirm 0 enrichment violations**

```bash
cargo run -p apianyware-macos-analyze -- enrich 2>&1 | grep -i "violation" || echo "no violations"
```

Expected: no violations.

- [ ] **Step 3: Full workspace verification**

```bash
cargo test --workspace
cd swift && swift test && cd ..
cargo clippy --workspace
make lint-annotations
```

Expected: all green; `make lint-annotations` exits 0. Compare test counts against the Task 1 baseline — counts should be equal or higher (new tests added), never lower.

No commit — regenerated artifacts are gitignored.

### Task 14: Distil pipeline learnings into knowledge/pipeline/

**Files:**
- Create/modify: `knowledge/pipeline/*.md` (follow the existing `knowledge/pipeline/` structure)

- [ ] **Step 1: Extract the learnings**

Dispatch a subagent to read `LLM_STATE/core/archive/memory.yaml` and extract the durable pipeline learnings (extraction fragilities — libclang UTF-8 panics, tokenize aborts, foreign-module re-emission; analysis fragilities — checkpoint staleness, annotation drift, block-parameter merge). Map each to the appropriate `knowledge/pipeline/{area}.md` file per `knowledge/CLAUDE.md`'s rules. The subagent returns proposed additions; it does not write files.

- [ ] **Step 2: Review and apply**

Review the subagent's proposed additions for accuracy against the current code (memory.yaml is historical — verify before recording). Apply the accurate ones to `knowledge/pipeline/`. Skip anything already documented or already fixed.

- [ ] **Step 3: Commit**

```bash
git add knowledge/pipeline/
git commit -m "docs(knowledge): distil pipeline learnings from archived memory.yaml"
```

### Task 15: Update project status documents

**Files:**
- Modify: `README.md` ("Current Status"), `LLM_STATE/overview.md` ("Core Pipeline" table)

- [ ] **Step 1: Update README.md**

In `README.md`'s "Current Status" section, update any figures changed by this work (the `_*_SwiftUI` frameworks now carry classes; the framework count may change). Keep the section accurate and concise.

- [ ] **Step 2: Update LLM_STATE/overview.md**

In `overview.md`'s "Core Pipeline" table, mark the four hardening items resolved and note the date. Remove any line rendered obsolete by Session 0's Ravel-Lite retirement.

- [ ] **Step 3: Final verification and commit**

```bash
cargo test --workspace
git add README.md LLM_STATE/overview.md
git commit -m "docs: update project status after core pipeline hardening"
```

**Session 4 checkpoint:** Pipeline regenerated from scratch and fully verified, learnings captured, status documents current. The plan is complete.

---

## Done-When (whole plan)

- All four work items closed; any genuinely-separable sub-case (e.g. CoreTransferable) filed as a scoped follow-up.
- Pipeline regenerated from scratch with 0 enrichment violations; `cargo test --workspace` and `swift test` green.
- `make lint-annotations` gates annotation staleness without the Ravel-Lite phase cycle.
- `LLM_STATE/core/` contains only the `archive/` reference material; no live phase machinery remains.
- Pipeline learnings captured in `knowledge/pipeline/*`.
- `README.md` and `LLM_STATE/overview.md` reflect the post-hardening state.

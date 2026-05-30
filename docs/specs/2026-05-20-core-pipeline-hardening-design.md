# Core Pipeline Hardening

A multi-session plan to close the genuinely-open core-pipeline backlog, retire
the Ravel-Lite phase-cycle machinery, and leave the Collection → Analysis →
Generation pipeline regenerated, verified, and self-documenting.

## Context

The core pipeline reached a clean, verified checkpoint at session 51
(2026-04-28): 284 frameworks collected, annotated, and enriched with 0
verification violations, and Racket bindings generated for all 283
discovered frameworks. The workstream is not mid-crisis — it sits at a stable
checkpoint with a small cleanup backlog.

Two things motivate a fresh plan:

1. **The Ravel-Lite phase-cycle machinery is being retired.** The workstream was
   driven by `../Ravel-Lite`'s work→reflect→triage cycle, with state in
   `LLM_STATE/core/` (`phase.md`, `pre-work.sh`, `prompt-work.md`, `*-baseline`,
   `backlog.yaml`, `session-log.yaml`, `memory.yaml`). That dependency is going
   away; the remaining work needs a home that does not assume the phase cycle.

2. **The backlog was scattered and partly stale.** Open items lived in three
   places — `backlog.yaml` (2 tasks), the session-51 "what to try next" list,
   and `memory.yaml`'s known-issues entries. Verification against the current
   tree found that **two of the candidate fixes were already shipped** (the
   `BOOL`→`_bool` mapping and `make-objc-block` accepting `#f`); the
   `memory.yaml` notes simply pre-dated the commits that fixed them. This spec
   records only the work that is genuinely still open.

This is a **hardening** effort. It deliberately excludes the functional emitter,
new language targets, and new sample apps.

## Goal

Close every genuinely-open core-pipeline item, retire the Ravel-Lite machinery,
and leave:

- the pipeline regenerated from scratch and verified (Rust + Swift tests green,
  0 enrichment violations);
- annotation-staleness guardrails wired into a phase-cycle-independent gate;
- pipeline learnings distilled from `memory.yaml` into `knowledge/pipeline/`;
- `LLM_STATE/core/` reduced to archived reference material.

## Working Environment

The pipeline's IR checkpoints (`collection/ir/collected/`, `analysis/ir/*`) and
generated output (`generation/targets/racket/generated/`) are **gitignored
build artifacts**. A fresh git worktree therefore contains none of them. Before
any session that inspects or regenerates the pipeline, the executor must
materialize the collected IR — either by running
`cargo run -p apianyware-macos-collect` (requires Xcode / libclang /
swift-api-digester; ~2 min) or by copying `collection/ir/collected/` from an
existing checkout. Session 0 establishes this baseline explicitly.

## Scope

### In scope

Four work items (see Work Items below):

- Item 1 — Orphaned Swift-only frameworks (collection correctness)
- Item 2 — Annotation guardrails (tooling)
- Item 3 — Emitter contract tightening (generation)
- Item 4 — Stable codesigning identity (tooling/bundling)

### Out of scope

- `emit-racket-functional` and the racket-functional target
- New language targets (Chez, Gerbil, Haskell, etc.)
- New sample apps
- The `BOOL`→`_bool` FFI mapping — **verified already correct** on current main
  (`ffi_type_mapping.rs` maps `bool`→`_bool`; `normalize_primitive_name`
  lowercases `BOOL`; golden files emit `_bool`/`boolean?`).
- `make-objc-block` accepting `#f` — **verified already done**
  (`block.rkt` returns `(values #f #f)` for a `#f` proc, with a passing test in
  `tests/test-block-creation.rkt`).

## Work Items

### Item 1 — Orphaned Swift-only frameworks

**Problem.** Seven synthetic Swift-only cross-framework modules
(`_AppIntents_SwiftUI`, `CoreTransferable`, `_RealityKit_SwiftUI`,
`_PhotosUI_SwiftUI`, `_SwiftData_SwiftUI`, `_SwiftData_CoreData`,
`_WebKit_SwiftUI`) have 0 classes in their **collected** IR
(`collection/ir/collected/<fw>.json`), so they have 0 classes through resolve
and annotate. `annotate` iterates `framework.classes`
(`analysis/crates/annotate/src/lib.rs`), so a framework with 0 classes
contributes 0 annotations regardless of any `.llm.json` file on disk.

**Confirmed root cause (primary).** `is_foreign_module_type_decl` in
`collection/crates/extract-swift/src/declaration_mapping.rs:171-193` drops every
top-level `Class`/`Protocol`/`Struct`/`Enum` whose `moduleName` differs from the
framework name:

```rust
match node.module_name.as_deref() {
    Some(module) => module != framework_name,
    None => false,
}
```

This was added (session 48) to suppress *spurious foreign re-emissions* — e.g.
the digester re-emitting `Sequence` (`moduleName: "Swift"`) as a container for
`CreateMLComponents`'s extension members. But it cannot distinguish those from
*legitimately-extended external classes*: `swift-api-digester -dump-sdk -module
_AppIntents_SwiftUI` emits `IntentParameter` with `moduleName: "AppIntents"`,
which is a real class `_AppIntents_SwiftUI` extends and whose extension members
are the framework's actual API surface. The filter drops it, leaving
`_AppIntents_SwiftUI` with 0 classes.

**Investigation required.** The fix must refine the filter to keep legitimately-
extended external classes while still dropping spurious re-emissions. The
discriminating signal must be determined empirically by inspecting the
swift-api-digester ABI JSON for an affected module versus a known
correct-to-drop case (CreateMLComponents/`Sequence`). Candidate signals: whether
the node carries an `isExternal`/`isFromExtension` flag; whether its children
are all extension members; whether the same type also appears as a non-foreign
decl elsewhere. The investigation picks the signal; the fix implements it
TDD-first with synthetic ABI-node fixtures covering both the keep and drop
cases.

**CoreTransferable sub-case.** `CoreTransferable` genuinely defines no classes —
it is a Swift-only protocol/struct framework. Its collected IR contains
protocols and structs but legitimately 0 classes. If it has annotations they
target protocol methods, and `annotate` only iterates `framework.classes`. The
investigation must determine whether `CoreTransferable` is fixed by the
extract-swift filter change or is a distinct issue (annotate not iterating
protocol methods); if distinct, file it as a follow-up rather than expanding
this item.

**Annotation discrepancy.** `backlog.yaml` claimed these 7 frameworks have
`.llm.json` files totalling 96 annotations; IR inspection on current main found
0 annotations present for them. The investigation must establish the true state
and decide whether re-annotating the affected frameworks (after classes are
restored) is in scope for this item or a follow-up. The done-criteria below do
not assume a specific annotation count.

**Done when.** The extract-swift filter is refined with regression tests
covering both the keep case (an extended external class) and the drop case (a
spurious foreign re-emission); collection is re-run for the affected frameworks;
the `_*_SwiftUI` modules show a non-zero class count in collected IR; resolve
and annotate are re-run; and the `CoreTransferable` sub-case is either resolved
or filed as a scoped follow-up.

### Item 2 — Annotation guardrails

**Problem.** `analysis/scripts/check-llm-annotation-drift.sh` (exit non-zero on
`.llm.json` files staled by extraction method-set changes; accepts
`--skip-regen` for the fast path) and `analysis/scripts/audit-llm-redundancy.py`
(categorizes frameworks into `redundant_active` / `orphaned` / `net_additive`)
both exist and are verified, but are wired into no automated gate. The original
plan targeted a Ravel-Lite triage pre-hook; that home is being retired.

**Fix.**

- Create a `Makefile` at the repo root (the project has none today) with a
  `lint-annotations` target that runs `check-llm-annotation-drift.sh
  --skip-regen` and `audit-llm-redundancy.py`. The target exits non-zero when
  the drift check exits non-zero. (`audit-llm-redundancy.py` always exits 0 and
  requires a heuristic-only checkpoint at `/tmp/heuristic-only-annotated`; the
  target builds that prerequisite first, per the script's docstring.)
- Prune the hardcoded UI class list in `derive_threading`
  (`analysis/crates/annotate/src/heuristics.rs:287-324`) to UIKit-only names.
  The list currently holds 27 AppKit names (`NSView` … `NSBitmapImageRep`) and 8
  UIKit names (`UIView` … `UIViewController`). `derive_threading` already
  receives `&class.swift_attributes` and checks `is_main_actor_attribute` before
  the list, so every `NS_SWIFT_UI_ACTOR`-decorated AppKit class now reaches the
  heuristic via `swift_attributes` — the 27 AppKit entries are dead code.
  Update the threading tests in the same file accordingly.

**Done when.** `make lint-annotations` runs both checks and exits non-zero on
drift; the UI class list contains only the 8 UIKit names; `cargo test
--workspace` green.

### Item 3 — Emitter contract tightening

The Racket emitter's generated `provide/contract` forms are partly tightened
already: the receiver uses `objc-object?` (not `any/c`), concrete `Class`-typed
parameters and returns use class-specific predicates, selectors use `string?`.
Two gaps remain.

**Gap A — generic receiver.** Every instance-method contract uses the generic
`SELF_CONTRACT = "objc-object?"` (`emit-racket/src/emit_class.rs:318`).
Because generated method names are class-scoped (`tkbutton-hidden`), the
receiver can be tightened to the class-specific predicate (`tkbutton?`), which
catches passing the wrong object class at the contract boundary. The class
predicates are already generated by `emit_class_predicates` /
`make_class_predicate_name`.

**Gap B — `NSInteger`/`NSUInteger` fall through to `any/c`.** Integer-typed
parameters and returns that the FFI contract mapper does not recognize fall
through to `any/c` (`map_contract` in `emit_functions.rs`; visible in goldens as
`[tkbutton-tag (c-> objc-object? any/c)]`). Tighten recognized integer types to
`exact-integer?`.

**Fix.** Implement both gaps in `emit-racket`. Expect **large golden-snapshot
churn** — the receiver change touches the contract line of every generated
method in every framework. Update goldens with `UPDATE_GOLDEN=1` and review the
diff for correctness (the change should be uniform: `objc-object?` →
`<class>?`).

**Done when.** Instance-method contracts use the class-specific receiver
predicate; `NSInteger`/`NSUInteger` contracts emit `exact-integer?`; golden
snapshots updated and the diff reviewed; `cargo test --workspace` green;
racket regenerated.

### Item 4 — Stable codesigning identity

**Problem.** Sample-app `.app` bundles are codesigned ad-hoc (link-time `-` on
arm64), producing a new CDHash on every rebuild and invalidating TCC grants
(Accessibility, Screen Recording, etc.). The mechanism to fix this already
exists: `StubConfig.signing_identity: Option<String>` and `codesign_path`
(`codesign --force --sign <identity>`) in `generation/crates/stub-launcher/`.
What is missing is a *persistent identity* and the wiring to use it by default.

**Fix.**

- Create and document a persistent self-signed codesigning certificate (a
  documented `security`/`certtool` recipe the user runs once on their machine;
  no Apple Developer account required).
- Wire that identity as the default `signing_identity` in
  `apianyware-macos-bundle-racket` so every bundled racket app is signed
  with the stable identity, giving a CDHash that is constant across rebuilds.
- Verify in a TestAnyware VM that a TCC grant (e.g. Accessibility for the
  Modaliser app) survives a rebuild-and-relaunch cycle.

**Done when.** `bundle-racket` signs bundled apps with the persistent
identity; the same app rebuilt twice produces an identical CDHash (verified with
`codesign -dvvv`); a TCC grant survives a rebuild in-VM; the certificate-
creation recipe is documented.

## Plan Structure

Five sequential sessions, each ending with a review checkpoint so the plan is
resumable across sessions. The orchestrating session dispatches subagents for
investigation and TDD implementation; it does **not** delegate pipeline
regeneration or the verification gate.

### Why serial, orchestrator-owned regeneration

`analysis/ir/*` checkpoints and `generation/targets/racket/generated/` are
shared mutable state. `regenerate-stale-pipeline.sh` decides freshness by
comparing newest-input-mtime to newest-output-mtime; two agents regenerating
concurrently would race that comparison and mask each other's staleness.
Subagents therefore return *source diffs only*; the orchestrator serializes
resolve→annotate→enrich→generate and owns the 0-violations gate.

### Sessions

**Session 0 — Re-baseline & retire Ravel-Lite.**

- Materialize the collected IR (`cargo run -p apianyware-macos-collect`, or copy
  `collection/ir/collected/` from an existing checkout — see Working
  Environment).
- Verify the pipeline is green: `cargo test --workspace`, `cd swift && swift
  test`, run `analysis/scripts/regenerate-stale-pipeline.sh`, confirm 0
  enrichment violations.
- Archive `LLM_STATE/core/memory.yaml` and `session-log.yaml` to
  `LLM_STATE/core/archive/`; delete the Ravel-Lite machinery: `phase.md`,
  `pre-work.sh`, `prompt-work.md`, `work-baseline`, `reflect-baseline`,
  `triage-baseline`, `compact-baseline`, `dream-baseline`, `dream-word-count`,
  `latest-session.yaml`, `backlog.yaml`.
- Keep `analysis/scripts/regenerate-stale-pipeline.sh` — it lives in the repo,
  not Ravel-Lite, and remains useful.
- Update `LLM_STATE/overview.md` and `LLM_STATE/project-workflow.md` to drop
  phase-cycle references, point at this plan, and fix the dangling
  `../Ravel-Lite/` coding-standards reference (the canonical source is
  `README.md`'s Coding Conventions).
- Implement Item 2 (annotation guardrails) — small, and it establishes the
  staleness safety net for later sessions.

**Session 1 — Orphaned Swift-only frameworks (Item 1).** A subagent inspects the
swift-api-digester ABI JSON for an affected module and a known correct-to-drop
case, and proposes the discriminating signal; the orchestrator reviews the
hypothesis before any fix is written; a subagent implements the refined filter
TDD-first with synthetic keep/drop fixtures; the orchestrator re-runs collection
for the affected frameworks plus resolve and annotate, and confirms a non-zero
class count. The `CoreTransferable` sub-case is resolved or filed as a follow-up.

**Session 2 — Emitter contract tightening (Item 3).** Implement the
class-specific receiver predicate and the `NSInteger`/`NSUInteger` tightening;
regenerate racket; update and review golden snapshots; verify.

**Session 3 — Stable codesigning identity (Item 4).** Document the self-signed
certificate recipe; wire the identity as the `bundle-racket` default; verify
CDHash stability and TCC-grant survival in a TestAnyware VM.

**Session 4 — Final integration.** Full pipeline regenerate from scratch; full
workspace verification (Rust + Swift tests, 0 enrichment violations); distil
`memory.yaml`'s pipeline learnings into `knowledge/pipeline/*`; update
`README.md` and `LLM_STATE/overview.md` status; final commit.

### Subagent strategy

| Session | Subagent role | Suggested type |
|---|---|---|
| 0 | none — orchestrator does verification + small wiring directly | — |
| 1 | inspect ABI JSON & propose signal; then implement the refined filter | Explore (investigation), general-purpose (TDD impl) |
| 2 | implement receiver-predicate + integer-contract changes TDD-first | general-purpose |
| 3 | implement codesigning wiring TDD-first | general-purpose |
| 4 | distil `memory.yaml` into `knowledge/pipeline/*` | general-purpose |

Each implementation subagent works TDD-first, returns a diff, and the
orchestrator reviews it before regeneration.

## Verification

Every session ends with the same gate before its checkpoint commit:

- `cargo test --workspace` green
- `cd swift && swift test` green (sessions touching Swift code)
- `cargo clippy --workspace` clean
- `cargo +nightly fmt` applied
- For sessions that change pipeline source:
  `analysis/scripts/regenerate-stale-pipeline.sh` re-run, 0 enrichment
  violations
- For sessions that change emitter source: golden snapshots updated and reviewed

Session 4 additionally requires a from-scratch pipeline regeneration, not an
incremental one.

## Coding Standards

Per `README.md`'s Coding Conventions: TDD, descriptive names, small files,
`thiserror` for library errors / `anyhow` for CLI, `tracing` macros only,
bounded channels only, no `unwrap`/`expect` in production code, import grouping
stdlib→external→local, `cargo +nightly fmt` before committing.

## Disposition of LLM_STATE/core

| File | Disposition |
|---|---|
| `memory.yaml`, `session-log.yaml` | Archived as read-only reference; pipeline learnings distilled into `knowledge/pipeline/*` in Session 4 |
| `backlog.yaml` | Deleted — superseded by this plan |
| `phase.md`, `pre-work.sh`, `prompt-work.md` | Deleted — Ravel-Lite machinery |
| `work-baseline`, `reflect-baseline`, `triage-baseline`, `compact-baseline`, `dream-baseline`, `dream-word-count` | Deleted — Ravel-Lite machinery |
| `latest-session.yaml` | Deleted — Ravel-Lite machinery |
| `regenerate-stale-pipeline.sh` (in `analysis/scripts/`) | **Kept** — repo-local, still useful |

`LLM_STATE/overview.md`, `LLM_STATE/project-workflow.md`,
`LLM_STATE/new-language-guide.md`, and the `LLM_STATE/targets/` and
`LLM_STATE/apps/` trees are unrelated to the core workstream and are left
untouched by this plan, except for the phase-cycle references removed from
`overview.md` and `project-workflow.md` in Session 0.

## Success Criteria

- All four work items closed (or, for any genuinely-separable sub-case, filed as
  a scoped follow-up rather than left implicit).
- Pipeline regenerated from scratch with 0 enrichment violations.
- `make lint-annotations` gates annotation staleness without the Ravel-Lite
  phase cycle.
- `LLM_STATE/core/` contains only archived reference material; no live phase
  machinery.
- Pipeline learnings captured in `knowledge/pipeline/*`.
- `README.md` and `LLM_STATE/overview.md` reflect the post-hardening state.

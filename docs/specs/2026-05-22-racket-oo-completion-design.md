# Racket-OO Target — Phase-Cycle Retirement & Completion

Retire the Ravel-Lite phase-cycle machinery from the last two workstreams still
using it — `LLM_STATE/apps/modaliser-racket/` and `LLM_STATE/targets/racket-oo/` —
and leave the `racket-oo` target tracked by a superpowers spec/plan with an
honest, verified completion backlog.

## Context

The project's pipeline work was historically driven by the Ravel-Lite
work→reflect→triage phase cycle, with per-workstream state in `LLM_STATE/<name>/`
(`phase.md`, `pre-work.sh`, `prompt-work.md`, `backlog.yaml`, `memory.yaml`,
`session-log.yaml`, `*-baseline`, `latest-session.yaml`).

The Core Pipeline Hardening effort
(`docs/specs/2026-05-20-core-pipeline-hardening-design.md`) retired that
machinery for `LLM_STATE/core/`: it archived `memory.yaml` / `session-log.yaml`
under `LLM_STATE/core/archive/`, deleted the phase machinery, distilled the
durable learnings into `knowledge/pipeline/*`, and re-pointed
`LLM_STATE/overview.md` / `LLM_STATE/project-workflow.md` at the new design and
plan. That effort deliberately left the `apps/` and `targets/` trees untouched as
a separate workstream.

This spec is that separate workstream. Two workstreams remain on the phase cycle:

- **`LLM_STATE/apps/modaliser-racket/`** — a Racket re-implementation of the
  Modaliser menu-bar app. This workstream is being **abandoned**: the Racket
  Modaliser will be restarted later from the current `~/Development/Modaliser`
  implementation, so the existing attempt and all its tracking carry no forward
  value.
- **`LLM_STATE/targets/racket-oo/`** — the Racket-OO language target. This
  workstream is **past build-out**: the `emit-racket-oo` emitter, the 18-file
  runtime, C-API emission, snapshot/runtime test harnesses, 7 sample apps, and
  an 833-line developer guide are all done. What remains is a modest completion
  backlog.

## Goal

- Delete the abandoned `modaliser-racket` workstream and its implementation
  outright — a clean slate for the eventual restart.
- Retire the Ravel-Lite machinery from `racket-oo`: archive its history, distil
  its learnings, delete the phase files.
- Leave `racket-oo` tracked by this design spec plus a superpowers
  implementation plan, with a completion backlog that has been **verified
  against the current tree** rather than copied from a stale `backlog.yaml`.
- Leave `LLM_STATE/` containing no live phase machinery.

## Verified backlog state

The `racket-oo` `backlog.yaml` was checked item-by-item against the current
repository (the full pipeline was regenerated 2026-05-22, so generated output is
current). Three candidate items were found **already done** and are excluded:

| Candidate item | Finding |
|---|---|
| `LIBRARY_LOAD_CHECKS` / `RUNTIME_FILES` audit | Already current — `RUNTIME_FILES` matches all 18 runtime files, no drift. Excluded. |
| CF struct globals gap (`kCFTypeDictionaryKeyCallBacks` et al.) | Already closed — the symbol is now in collected IR and emitted in `generated/oo/corefoundation/constants.rkt`. Excluded. |
| Modaliser P3 "Racket binding contracts" | Already done — generated bindings emit `provide/contract` throughout. Excluded. |

Stale metadata also corrected: the `backlog.yaml` claims 9 sample apps; the tree
has **7** (`hello-window`, `ui-controls-gallery`, `drawing-canvas`,
`pdfkit-viewer`, `scenekit-viewer`, `mini-browser`, `note-editor`). `counter` and
`file-lister` are absent. The "≥2 more sample apps" dependency is satisfied.

## Scope

### In scope

- Item A — Delete the `modaliser-racket` workstream and implementation.
- Item B — Retire the `racket-oo` phase machinery (archive + delete).
- Item C — Distil `racket-oo` learnings into `knowledge/targets/racket-oo.md`.
- Item D — The verified `racket-oo` completion backlog (four items).
- Item E — Update `LLM_STATE/overview.md` / `project-workflow.md`.

### Out of scope

- The `racket-functional` target and its emitter.
- New sample apps, and the future Racket Modaliser restart.
- `LLM_STATE/targets/template.md` — the new-target methodology template. It
  documents the now-retired phase cycle and is therefore stale, but choosing the
  replacement new-target methodology is a separate decision; this spec leaves the
  file in place and flags it.
- The three backlog items verified already-done (see table above).

## Work Items

### Item A — Delete the `modaliser-racket` workstream

The Racket Modaliser attempt is abandoned; it will be restarted from
`~/Development/Modaliser`. Delete, in full:

- `LLM_STATE/apps/modaliser-racket/` — the phase-cycle plan, `memory.yaml`,
  `session-log.yaml`, and `artifacts/`. After deletion `LLM_STATE/apps/` is
  empty; remove that directory too.
- `generation/targets/racket-oo/apps/modaliser/` — the Racket implementation
  (`modaliser-impl.rkt`).
- `knowledge/apps/modaliser/` — the six distilled knowledge files.

Then clean every reference to the deleted workstream:

- `knowledge/apps/_index.md` — drop the modaliser entry.
- `generation/targets/racket-oo/apps/README.md` — drop modaliser from the app
  list.
- `LLM_STATE/overview.md` — drop any modaliser/apps mention.
- Grep the tree (`docs/`, `knowledge/`, `LLM_STATE/`, `README.md`) for remaining
  `modaliser` references and resolve each.

**Done when.** No `modaliser` path or reference remains outside the historical
`LLM_STATE/targets/racket-oo/archive/` record (see Item B); `cargo test`,
`cargo clippy`, and the racket runtime-load harness still pass (the deleted app
must not be referenced by any test or build target).

### Item B — Retire the `racket-oo` phase machinery

Mirror the `core` migration. In `LLM_STATE/targets/racket-oo/`:

- **Archive** `memory.yaml` and `session-log.yaml` to
  `LLM_STATE/targets/racket-oo/archive/`, with an `archive/README.md` modelled on
  `LLM_STATE/core/archive/README.md`: state that the phase cycle is retired for
  `racket-oo`, that the two files are a read-only historical record, and that the
  workstream is now tracked by this design and its plan.
- **Delete** the Ravel-Lite machinery: `phase.md`, `pre-work.sh`,
  `prompt-work.md`, `prompt-triage.md`, `work-baseline`, `dream-baseline`,
  `latest-session.yaml`, `backlog.yaml`, `related-plans.md`.
- `pre-work.sh` only delegates to `analysis/scripts/regenerate-stale-pipeline.sh`;
  that script is repo-local and stays.

**Done when.** `LLM_STATE/targets/racket-oo/` contains only `archive/`; no
phase-cycle file remains.

### Item C — Distil `racket-oo` learnings into knowledge

`knowledge/targets/racket-oo.md` already exists. Before `memory.yaml` is archived
out of easy reach, audit that file against the ~62k `memory.yaml` and extend it
so every durable, still-true learning survives — emitter/runtime invariants, FFI
type-coercion rules, the non-linkable-symbol filters, dylib-path conventions,
selector filtering, the synthetic pseudo-framework structure, the three
verification layers, and so on. Drop anything `memory.yaml` recorded that later
commits made false (verify before copying — the `core` distillation found stale
entries).

**Done when.** `knowledge/targets/racket-oo.md` is a self-contained reference for
the `racket-oo` target that does not depend on the archived `memory.yaml`.

### Item D — `racket-oo` completion backlog

Four verified-open items. Each is independently shippable.

**D1 — SceneKit Viewer msgSend-alias cleanup.** Commit `0901f23`
(protocol-inherited methods) has propagated: `scnnode-run-action` and
`scnview-set-autoenables-default-lighting!` now generate as proper bindings. The
two obsolete typed `objc_msgSend` aliases in
`generation/targets/racket-oo/apps/scenekit-viewer/scenekit-viewer.rkt`
(lines ~75–89) and their call sites (~147, ~197) are now dead workarounds.
Remove the aliases, repoint the call sites at the generated bindings, and verify
the viewer still renders (VM visual check — see Verification).

**D2 — `define-objc-subclass` test coverage.** Only `drawing-canvas` exercises
`define-objc-subclass` today. Add at least one more test that exercises
`#:arg-types` / `#:ret-type` overrides and the struct-type encoding parser,
including the nested balanced-delimiter (`{...}`) case.

**D3 — Default-constructor harness checks.** `make-<class>` is synthesized for
most classes, but the runtime-load harness
(`generation/crates/emit-racket-oo/tests/runtime_load_test.rs`) has no explicit
check that the synthesized constructors actually construct. Add harness checks
for a representative set: `NSAlert`, `NSColorPanel`, `NSStackView`,
`NSSavePanel`, `NSOpenPanel`.

**D4 — Framework-coverage deepening.** Current framework tests are shallow load
checks. Add targeted deeper tests for `CoreGraphics`, `AVFoundation`, and
`MapKit` — construct values, call functions, assert results. Exact assertions are
scoped during implementation; the bar is "more than 'the module loads'."

**Done when.** D1: no `objc_msgSend` alias remains in `scenekit-viewer.rkt` and
the viewer renders. D2–D4: the new tests are added and green.

### Item E — Update `LLM_STATE` cross-cutting docs

Update `LLM_STATE/overview.md` and `LLM_STATE/project-workflow.md` to drop the
"`racket-oo` still uses the Ravel-Lite phase cycle" framing and point at this
design and its implementation plan, exactly as the `core` migration re-pointed
them. Correct the sample-app count to 7.

**Done when.** Neither file describes any workstream as phase-cycle-driven.

## Disposition of `LLM_STATE`

| Path | Disposition |
|---|---|
| `LLM_STATE/apps/modaliser-racket/` (all) | **Deleted** — workstream abandoned |
| `LLM_STATE/apps/` (now empty) | **Deleted** |
| `generation/targets/racket-oo/apps/modaliser/` | **Deleted** — implementation abandoned |
| `knowledge/apps/modaliser/` (all) | **Deleted** — clean slate for the restart |
| `LLM_STATE/targets/racket-oo/memory.yaml`, `session-log.yaml` | **Archived** to `archive/` (read-only history) |
| `LLM_STATE/targets/racket-oo/{phase.md, pre-work.sh, prompt-work.md, prompt-triage.md, work-baseline, dream-baseline, latest-session.yaml, backlog.yaml, related-plans.md}` | **Deleted** — Ravel-Lite machinery |
| `analysis/scripts/regenerate-stale-pipeline.sh` | **Kept** — repo-local, still useful |
| `LLM_STATE/targets/template.md` | **Kept** — stale but out of scope (see Scope) |
| `knowledge/targets/racket-oo.md` | **Kept and extended** (Item C) |

## Verification

- `cargo test --workspace` and `cargo clippy --workspace --all-targets` green.
- `cd swift && swift test` green (for any item touching Swift).
- The racket runtime-load harness green; `make lint-annotations` exits 0.
- For Item D items that change emitter source or sample apps: regenerate the
  pipeline and confirm 0 enrichment violations.
- D1's viewer render is verified in a VM with `GUIVisionVMDriver` (never run GUI
  apps directly from the CLI); D3/D4 are covered by the harness.
- SDK-touching commands (collect, extract tests, `swift test`,
  `swift-api-digester`) must be run with `SDKROOT` exported — the host `xcrun`
  default-SDK resolution is broken.

## Success Criteria

- `LLM_STATE/` contains no live phase-cycle machinery; only
  `LLM_STATE/targets/racket-oo/archive/` retains historical record.
- No `modaliser` path or reference survives outside that archive.
- `knowledge/targets/racket-oo.md` is a self-contained `racket-oo` reference.
- The four Item D backlog items are complete and verified, or any genuinely
  separable remainder is filed as a scoped follow-up.
- `LLM_STATE/overview.md` and `project-workflow.md` describe no workstream as
  phase-cycle-driven and point at this design and plan.
- The full verification gate is green.

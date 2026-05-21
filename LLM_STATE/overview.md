# APIAnyware Status

At-a-glance view of the project. Updated at session boundaries.

## Plans

The **core pipeline** is tracked by `docs/specs/2026-05-20-core-pipeline-hardening-design.md`
(design) and `docs/superpowers/plans/2026-05-20-core-pipeline-hardening.md` (plan).
Its prior Ravel-Lite phase-cycle state is archived under `LLM_STATE/core/archive/`.

| Plan | Location | Run |
|------|----------|-----|
| Racket OO Target | `LLM_STATE/targets/racket-oo/` | `./LLM_STATE/targets/racket-oo/run.sh` |

The Racket OO target plan still uses the Ravel-Lite phase cycle — its directory
contains `backlog.md`, `session-log.md`, `memory.md`, `phase.md`,
`prompt-{work,reflect,triage}.md`, and `run.sh`.

## Core Pipeline

| Area | Status | Notes |
|------|--------|-------|
| ObjC class collection | done | libclang-based, typedef resolution at extraction time |
| ObjC protocol collection | done | |
| ObjC enum collection | done | |
| C function collection | done | 858 CF, 777 CG, 186 Foundation, 676 Security |
| C enum/constant collection | done | VarDecl + EnumDecl; #define constants not captured |
| C callback type collection | done | FunctionPointer TypeRefKind with full signatures |
| Resolution (inheritance) | done | |
| Annotation (heuristic + LLM) | done | Three-step subagent workflow: llm-extract → subagent → annotate --llm-dir |
| Enrichment | done | per-framework verification fix applied, isolation tests added |
| Stub launcher | done | `apianyware-macos-stub-launcher` — per-app Swift stubs for TCC |

**Core Pipeline Hardening — complete 2026-05-21.** The four hardening items in
`docs/specs/2026-05-20-core-pipeline-hardening-design.md` are closed:

- **Item 1 — orphaned Swift-only frameworks:** `extract-swift`'s foreign-module
  filter keeps cross-import overlays' bridged type decls, so the six `_*_SwiftUI`
  / `_SwiftData_*` modules regained their classes.
- **Item 2 — annotation guardrails:** `make lint-annotations` gates annotation
  staleness; `derive_threading`'s hardcoded UI class list pruned to UIKit-only.
- **Item 3 — emitter contract tightening:** generated Racket contracts use a
  class-specific receiver predicate, and integer / enum-typedef contracts
  respect signedness.
- **Item 4 — stable codesigning identity:** `bundle-racket-oo` signs bundled
  apps with the persistent `APIAnyware Local Signing` identity — verified to
  give a stable CDHash so macOS TCC grants survive rebuilds.

Two annotation-staleness follow-ups remain open, out of hardening scope:
FU-1 (`annotate` walks only `framework.classes`) and FU-2 (stale
`SharedWithYouCore.llm.json`), tracked in
`docs/specs/2026-05-20-coretransferable-followup.md`. `make lint-annotations`
correctly flags both until they are addressed.

## Targets

| Target | Status | Styles | Apps Done | Notes |
|--------|--------|--------|-----------|--------|
| racket-oo | active | oo (done), c-api (done), functional (not started) | 3/7 | Next: remaining apps |
| racket-functional | not started | functional | 0/7 | Needs functional emitter |

## Cross-Cutting Blockers

- racket-functional style blocked on functional emitter implementation

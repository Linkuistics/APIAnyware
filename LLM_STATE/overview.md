# APIAnyware Status

At-a-glance view of the project. Updated at session boundaries.

## Plans

| Plan | Location | Run |
|------|----------|-----|
| Core Pipeline | `LLM_STATE/core/` | `./LLM_STATE/core/run.sh` |
| Racket OO Target | `LLM_STATE/targets/racket-oo/` | `./LLM_STATE/targets/racket-oo/run.sh` |

Each plan directory contains `backlog.md` (task backlog), `session-log.md` (history),
`memory.md` (distilled learnings), `phase.md` (current phase), `prompt-{work,reflect,triage}.md`
(phase prompts), and `run.sh` (generic cycle driver).
See `../Ravel-Lite/README.md` for the phase cycle spec.

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

## Targets

| Target | Status | Styles | Apps Done | Notes |
|--------|--------|--------|-----------|--------|
| racket-oo | active | oo (done), c-api (done), functional (not started) | 3/7 | Next: remaining apps |
| racket-functional | not started | functional | 0/7 | Needs functional emitter |

## Cross-Cutting Blockers

- racket-functional style blocked on functional emitter implementation

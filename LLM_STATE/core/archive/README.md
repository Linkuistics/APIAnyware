# Archived core-workstream state

`memory.yaml` and `session-log.yaml` are the read-only record of the
Ravel-Lite-driven core pipeline sessions (through session 51, 2026-04-28).

The Ravel-Lite work→reflect→triage phase cycle has been retired for the core
workstream. The core pipeline is now tracked by:

- `docs/specs/2026-05-20-core-pipeline-hardening-design.md` — design
- `docs/superpowers/plans/2026-05-20-core-pipeline-hardening.md` — implementation plan

Pipeline learnings from `memory.yaml` are distilled into `knowledge/pipeline/`
as part of that plan's final session.

The `LLM_STATE/targets/` plans (e.g. racket-oo) still use the Ravel-Lite phase
cycle — only the core workstream was migrated.

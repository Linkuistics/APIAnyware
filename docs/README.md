# Documentation

APIAnyware is a matrix project: N language **targets** × M sample **apps**.
A target is a language+paradigm combination (e.g. `racket`) with its own emitter
crate, runtime, generated output, and apps.

Documentation is organised into two tiers.

## Main tier — this `docs/` tree

Cross-cutting, shared-across-all-targets documentation. Read this to understand
the pipeline, the conventions, and the decisions that bind every target.

| Path | What lives here |
|------|-----------------|
| `adr/` | Central decision log for **all** targets, with global numbering. ADRs are the one exception to co-location — the graph crosses target boundaries (supersessions, cross-target citations), so it stays unified here. |
| `pipeline/` | Shared collect → analyse → generate discoveries: `collection.md`, `analysis.md`, `type-mapping.md`, `annotation-workflow.md`, `api-pattern-catalog.md`, `enrich-rules.md`, `memory-architecture.md`, `emitter-contract.md`. |
| `specs/` | Cross-cutting design specs (workspace, app portfolio, core-pipeline hardening, grove skill). Per-target design specs co-locate in their target unit. |
| `research/` | Cross-cutting research / spikes. Per-target spikes co-locate in their target unit. |
| `apps/` | Language-agnostic app portfolio: per-app `spec.md`, `test-strategy.md`, and target-independent `learnings.md`; `_index.md` lists the portfolio. |
| `testing/` | TestAnyware GUI-testing methodology (`general.md`) and reusable `strategies/`. |
| `guides/` | Authoring guides: `adding-a-language-target.md`, `codesigning-identity.md`. |
| `prd/` | Product requirement docs — human-facing agreement checkpoints. |

## Per-language tier — co-located in the target unit

Everything specific to one target lives with that target, under
`generation/targets/<lang>/`:

```
generation/targets/<lang>/
  README.md                    # target overview / index
  docs/
    reference.md               # deep target reference (FFI patterns, runtime quirks)
    developer-guide.md         # user-facing app-writing guide (where present)
    design/                    # per-target design specs
    research/                  # per-target spikes
  apps/<app>/
    README.md
    learnings.md               # realization notes for this app in this target
  test-results/<app>/report.md # VM-verify reports (already co-located)
```

This co-location extends the hermetic-isolation principle (ADR-0011) to
documentation. See the co-location ADR for the full rationale.

## Workflows

- **Adding a target** — see `docs/guides/adding-a-language-target.md`. Producing
  the per-language doc structure above is an explicit, sequenced step of adding a
  target; a target is not done until its docs exist in that structure.
- **Adding an app** — create `docs/apps/<name>/` (`spec.md`, `learnings.md`,
  `test-strategy.md`), add it to `docs/apps/_index.md`, and for each target create
  `generation/targets/<lang>/apps/<name>/learnings.md`.
- **Pipeline changes** — when app or generation work reveals a collection or
  analysis bug, fix it in the core pipeline, regenerate the affected targets, and
  capture the learning in `docs/pipeline/<area>.md`.

## Conventions for learnings

- **Never duplicate** — if a learning applies to a broader tier, record it there,
  not in a narrower file.
- **Date entries** — prefix with `**YYYY-MM-DD:**` so staleness is visible.
- **Promote eagerly** — if a per-app learning turns out to be target-universal,
  move it up to the target reference; if target-universal, to the pipeline tier.
- **Priority codes** — use 🔴 (critical), 🟡 (useful), 🟢 (informational).

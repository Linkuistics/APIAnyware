# skeleton-k2

**Kind:** planning

## Goal

Plan and then drive the **structural skeleton** — the first workstream of the
`structural-refactoring` grove (root brief decomposition item 1). Create the five
domains (`semantic/`, `platforms/`, `apps/`, `targets/`, `schemas/`), rename
`APIAnyware-MacOS` → `APIAnyware` internally, redistribute the Rust crates into the
domains under one workspace (ADR-0043), relocate existing material, co-locate docs,
slim the README to a map, and add placeholder skeletons — **keeping the JSON-IR
pipeline building at every step** (D4 skeleton-first). This planning leaf grills the
open skeleton decisions, then decomposes into work leaves.

## Context (inherited — see `grove-llm brief-chain`)

Settled at the root (planning leaf `plan-k1`):
- **D1** full re-architecture scope.
- **D2** toolchain distributed by served-domain (ADR-0043), not a central `tools/`.
- **D3** one Cargo workspace, distributed members.
- **D4** skeleton-first sequencing.

Read `REFACTOR.md` (esp. §9 target structure, §10 doc-placement rule, §40 the
16-step skeleton sequence, §41 naming, §42 generated/build/reports, §45 success
criteria) and `CONTEXT.md`.

## Open decisions to grill

- **C1 — shared projection substrate** (`emit` + `emit::naming` acronym table):
  exact home (a clearly-non-target shared area under `targets/`? `semantic/`? — note
  CONTEXT.md calls the acronym table "shared analysis-level data").
- **C2 — shared model crates** (`types`, `datalog`/`resolve`/`enrich`, `annotate`):
  exact domain homes; confirm `semantic/tools/` for the model/analysis crates.
- **ADR home in the new tree.** `REFACTOR.md` §10 dissolves the top-level `docs/`,
  but ADRs are a connected cross-target graph that CONTEXT.md keeps central. Where do
  central ADRs live post-refactor (`semantic/docs/adr/`? a root `adr/`?).
- **Rename split + mechanics.** Internal renames done in-grove; the physical dir `mv`
  is a post-merge manual step (root brief Notes). Settle the exact internal surface
  (package names, path strings, identity refs) and leave the migration note.
- **Buildability slicing.** How fine-grained are the buildable checkpoints — per-crate
  move with `cargo build` green each time, or per-domain batches? Golden-test paths,
  include paths, and `generation/targets/<t>/` runtime/app references will move.
- **Placeholder skeletons.** What minimal scaffolding (READMEs, empty domain dirs,
  `semantic/pattern-kinds/` + `schemas/` placeholders) lands now vs. in later nodes.

## Done when

Skeleton decisions settled (ADRs where warranted); this leaf decomposed into the
ordered work leaves that execute the move; `grove-llm pick` returns the first.

## Notes

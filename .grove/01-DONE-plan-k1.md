# plan-k1

**Kind:** planning

## Goal

Plan the `structural-refactoring` grove: the refactor described in `REFACTOR.md`
— rename `APIAnyware-MacOS` → `APIAnyware` and re-architect the repository from
its current *pipeline-phase* shape (`collection/` → `analysis/` → `generation/`)
into the five *domain* partitions (`semantic/`, `platforms/`, `apps/`,
`targets/`, `schemas/`), with documentation co-located beside its subject and the
platform-neutral structure able to absorb Linux/.NET and many target languages.

This planning leaf grills the foundational, tree-shaping decisions and grows the
root's first decomposition. Detailed subsystem design (DSL grammar, YAML schema,
pattern model, capability-profile format, …) is deferred to child planning
leaves — grove decomposes lazily.

## Context

- Source of truth: `REFACTOR.md` (the agreed target architecture).
- Current architecture is captured in `CONTEXT.md` (the glossary) — complete-API
  binding model, hermetic per-target isolation, trampolines, 4 live targets
  (racket/chez/gerbil/sbcl), JSON enriched IR with goldens.
- The current tree is organized by *pipeline phase*; REFACTOR.md's five domains
  are organized by *domain*. These are orthogonal axes — the refactor is a
  re-projection, not a move.
- Sharp unresolved tension: the five domains house data/specs/docs but give **no
  home to the Rust toolchain crates** that produce them.

## Done when

- The foundational tree-shaping decisions are settled (scope, toolchain home,
  sequencing, rename mechanics, format-migration ordering) and recorded as ADRs
  where they clear the ADR bar.
- The root `BRIEF.md` carries the grove Goal / Done-when / Decomposition.
- The root is decomposed into its first child nodes/leaves; `grove-llm pick`
  returns the next live leaf.

## Decisions (running log)

### D1 — Scope: full re-architecture (settled)

This grove delivers the **full re-architecture**, not just the structural move:
the 5-domain restructure + rename **plus** the `.apiw` DSL + parser, the
canonical/resolved YAML interchange (replacing today's JSON enriched IR),
first-class semantic pattern-kind entities, per-target capability profiles, the
representability model, conformance-report machinery, and the LLM side-channel
rework. (User choice, 2026-06-23.) A near-rewrite of the data model — so
buildability sequencing and the data-model migration are first-class planning
concerns, not afterthoughts.

### D2 — Toolchain placement: distribute by served-domain (settled)

The Rust crates are **distributed into the domain each one serves**, not gathered
in a top-level `tools/`. (User choice, 2026-06-23, over my recommendation of a
single `tools/` workspace — accepting the path-deps-span-tree and shared-owner
costs I flagged.) The allocation **principle**, read off the user's own preview:
a tool lives under the domain it serves —

- extractors (`extract-objc`, `extract-swift`) → `platforms/<platform>/…`
- `.apiw` DSL parser + validator → `schemas/…`
- the resolver / semantic-graph builder (`resolve`, and likely `datalog`/`enrich`)
  → `semantic/…`
- emitters (`emit-<t>`) + bundlers (`bundle-<t>`) + `stub-launcher` → `targets/<t>/…`

Open consequences this principle does **not** settle, grilled next:
- **C1 — the shared-across-targets emitter substrate** (`emit` + `emit::naming`
  acronym table, which CONTEXT.md calls "shared analysis-level data"): serves
  *all* targets, so no single `targets/<t>/` owns it.
- **C2 — the shared IR `types` crate** and the Cargo workspace shape (one
  workspace with distributed members vs. many).

### D3 — Cargo workspace: one workspace, distributed members (settled)

A single `[workspace]` at repo root whose `members` point at crate paths scattered
across the domains (user choice, 2026-06-23). Preserves tree-wide
`cargo build`/`test`/`fmt --all` and lets shared crates be referenced by path for
free. This neutralizes the build-survival cost of D2's distribution.

**Provisional placement principle (to be finalized by the skeleton work-node, not
grilled here — it is a reversible `git mv`, below the ADR bar):**

- shared semantic-model crates (`types`; analysis crates `datalog`/`resolve`/`enrich`)
  → `semantic/tools/` (user signalled `resolve` → `semantic/`)
- shared projection substrate (`emit` + `emit::naming`) → a clearly-non-target
  shared area under `targets/` (§7.2 "projection lives in targets"); the
  acronym-table-as-analysis-data question (CONTEXT.md) is a skeleton-node detail.
- `annotate` (LLM side-channel) → `platforms/` or a tooling spot — skeleton-node call.

→ **C1/C2 deferred to the skeleton work-node.** Not tree-shaping; recorded, moved on.

## Notes

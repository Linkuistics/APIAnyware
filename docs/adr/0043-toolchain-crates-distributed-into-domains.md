# Toolchain crates are distributed into the five domains, not gathered in a central `tools/`

**Status:** accepted

The `structural-refactoring` grove re-architects the repository from its
*pipeline-phase* shape (`collection/` → `analysis/` → `generation/`) into the five
*domain* partitions of `REFACTOR.md` §8–§9 — `semantic/`, `platforms/`, `apps/`,
`targets/`, `schemas/`. Those domains house **data, specs, and docs**; they give no
home to the ~20 Rust crates that *produce* that material. We decided to **distribute
each crate into the domain it serves** rather than gather the workspace under one
top-level `tools/` (or keep the old phase directories), keeping a **single Cargo
workspace** whose `members` point at the scattered crate paths so tree-wide
`cargo build` / `test` / `fmt --all` survive.

This realizes `REFACTOR.md`'s organizing rule — *"documentation lives with its
subject"* (§7.4, §10) — extended from docs to the tooling itself: the code that
extracts a platform lives with that platform; the code that emits a target lives
with that target.

## Context

The current tree partitions by pipeline phase; the target tree partitions by domain.
The two axes are **orthogonal**, so the refactor is a re-projection, not a move. The
crates split cleanly along the served-domain axis for the *leaf* crates
(`extract-objc`/`extract-swift` serve a platform; `emit-<t>`/`bundle-<t>` serve a
target), but a handful are genuinely cross-cutting (`types`, the shared `emit`
substrate incl. the `naming` acronym table, the analysis crates) and have no single
domain owner — see Consequences.

## Decision

1. **Distribute by served-domain.** extractors → `platforms/<platform>/…`; the `.apiw`
   DSL parser + validator → `schemas/…`; the resolver / semantic-graph builder →
   `semantic/…`; emitters + bundlers + `stub-launcher` → `targets/<t>/…`.
2. **One workspace, distributed members.** A single `[workspace]` at the repo root
   lists every crate by its in-domain path. Shared crates are referenced by path for
   free; no per-domain workspaces, no publishing, no duplication.
3. **Shared crates' exact home is a skeleton-step detail** (a reversible `git mv`,
   below this ADR's altitude): provisionally, shared semantic-model crates (`types`,
   `datalog`/`resolve`/`enrich`) → `semantic/tools/`; the shared projection substrate
   (`emit` + `naming`) → a clearly-non-target shared area under `targets/` (§7.2
   "projection lives in targets").

## Considered options

- **Single top-level `tools/` workspace** (the recommended-against alternative). The
  conventional choice — one cohesive home for the machine, the five domains kept pure
  data/specs/docs. Rejected by the user in favour of maximizing "code lives with its
  subject"; the path-deps-span-tree and shared-owner costs were accepted knowingly.
- **Keep the phase directories at top level.** Minimal churn, but leaves the old
  phase-axis dirs beside the new domain dirs — the "scattered files / must infer the
  architecture" failure `REFACTOR.md` §40.14 + success-criterion 14 warn against.

## Consequences

- The root `Cargo.toml` `members` list enumerates crates across all five domains —
  cosmetically noisier, mechanically fine.
- **Cross-cutting crates** (`types`, `emit`/`naming`, the analysis crates) have no
  single domain owner; their placement is decided when the skeleton work-node moves
  them, not here. `CONTEXT.md` records `naming` as "shared analysis-level data," which
  pulls it toward `semantic/` even though emitters consume it — a tension the skeleton
  node resolves.
- Per-target hermetic isolation (ADR-0010/0011) is about *runtime/output*, not emitter
  *code*: the shared `emit` substrate stays shared, so "distribute to targets" cannot
  mean "duplicate `emit` per target."

See `REFACTOR.md` (§8–§10, §40), the grove root `BRIEF.md`, and the
`structural-refactoring` planning leaf `plan-k1` running log (decisions D1–D4).

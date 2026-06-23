# skeleton-k2 — brief

**Node kind:** work-node (planning done; 8 ordered work leaves below).

## Goal

Drive the **structural skeleton** — the first workstream of the
`structural-refactoring` grove (root brief decomposition item 1). Create the five
domains (`semantic/`, `platforms/`, `apps/`, `targets/`, `schemas/`), rename
`APIAnyware-MacOS` → `APIAnyware` internally, redistribute the Rust crates into the
domains under one workspace (ADR-0043), relocate existing material, co-locate docs,
slim the README to a map, and add placeholder skeletons — **keeping the JSON-IR
pipeline building at every step** (D4 skeleton-first). No new content artifacts: the
`.apiw` DSL, YAML interchange, capability profiles, pattern-kind definitions, and
schemas are *later* workstreams (SC6).

## Context (inherited — see `grove-llm brief-chain`)

Settled at the root (planning leaf `plan-k1`):
- **D1** full re-architecture scope.
- **D2** toolchain distributed by served-domain (ADR-0043), not a central `tools/`.
- **D3** one Cargo workspace, distributed members.
- **D4** skeleton-first sequencing.

Read `REFACTOR.md` (esp. §9 target structure, §10 doc-placement rule, §14 platform
structure, §18 target structure, §40 the 16-step skeleton sequence, §41 naming,
§42 generated/build/reports, §45 success criteria) and `CONTEXT.md`. The settled
skeleton decisions (SC1–SC7) + the final crate→domain map are in the running log
below — **read them before executing any child leaf.**

## Children — ordered work leaves (SC5: per-domain batches; each ends green)

Each leaf is one focused session = one commit, ending with `cargo build`/`cargo test`
green (move-crate-by-crate within the session so even the intermediate state builds).
Each move leaf edits the root `Cargo.toml` `members` + `[workspace.dependencies]`
path values for the crates it moves.

1. **`domains-skeleton-k3`** — create the 5 domain dirs + `targets/_shared/` + the
   empty home dirs (`semantic/{docs,pattern-kinds}`, `platforms/macos/{docs,api,
   app-kinds,tests}`, `apps/macos`, `schemas/docs`, root `adr/`) with placeholder
   READMEs + TODO markers. **No moves** — pipeline builds untouched. Record the new
   structural vocabulary in `CONTEXT.md` (the realizing node, per root brief).
2. **`internal-rename-k4`** — SC7: rename `apianyware-macos-*` → `apianyware-*`
   everywhere (no path changes). build+test+fmt green.
3. **`move-semantic-k5`** — `git mv` `types, datalog, resolve, enrich, analyze-cli`
   → `semantic/tools/`. build green.
4. **`move-platforms-k6`** — `git mv` `extract-objc, extract-swift, annotate,
   collect-cli` → `platforms/macos/tools/`; relocate `analysis/ir/llm-annotations/`
   + `analysis/scripts/` to their platform home. build + annotation-drift check green.
5. **`move-target-crates-k7`** — `git mv` `emit, stub-launcher, generate-cli` →
   `targets/_shared/tools/`; `emit-<t>, bundle-<t>` → `targets/<t>/tools/` (4 targets).
   build green.
6. **`move-target-material-k8`** — relocate `generation/targets/<t>/` emitted material
   → `targets/<t>/` (bindings/generated, apps→app-implementations, docs, runtime,
   test-results→reports) + `swift/Sources/APIAnyware<T>` → `targets/<t>/adapters/macos/`;
   fix all golden/test/build-script paths. `cargo test` + per-target smokes green.
   (May further split per-target if a session can't hold it.)
7. **`co-locate-docs-k9`** — distribute `docs/` by subject (§10); `docs/adr/` → root
   `adr/` (+ rewrite ~45 cross-refs, ADR-0045); root `prd/` for PRDs; slim `README.md`
   to a repo map (§11); home `website/`.
8. **`migration-finalize-k10`** — TODO sweep (§40.16); post-merge physical-`mv`
   migration note; remove emptied `collection/ analysis/ generation/`; final
   `cargo build && cargo test && cargo fmt --all` + drift check; confirm §45 success
   criteria hold structurally.

## Done when

All 8 child leaves retired: the repo is the five-domain tree, internally renamed, the
JSON-IR pipeline builds + tests green, docs co-located, README a map, and §45's
structural success criteria hold (the data-model/content rewrites remain for
workstreams 2–9). On node retirement, promote SC-decisions still live to the root
brief / ADRs / glossary.

## Pointers

- `REFACTOR.md` — target architecture (source of truth).
- ADR-0043 (toolchain distribution), **ADR-0044** (emit→`targets/_shared/`),
  **ADR-0045** (ADRs→root `adr/`), ADR-0024 (docs co-location), ADR-0010/0011
  (hermetic isolation).
- Root `BRIEF.md` — the nine-workstream decomposition (skeleton is item 1).

## Decisions (running log)

### Crate-home convention (settled)

Rust crates live under a `tools/` subdirectory of the domain they serve — shared
crates under `<domain>/tools/<crate>/`, per-target crates under
`targets/<t>/tools/<crate>/`. §14/§18 give specs/data homes but none for the Rust
code; `tools/` is the needed addition. Keeps each crate co-located with its subject
(ADR-0043) while leaving the `api/`, `idioms/`, `adapters/`, … data trees clean.

### SC1 — shared projection substrate `emit` → `targets/_shared/tools/` (settled)

The `emit` crate (incl. the `naming` acronym table) goes to
`targets/_shared/tools/emit/`. (User choice, 2026-06-23, over the `semantic/`
alternative.) Projection is the targets domain's job (REFACTOR §7.2 "projection
lives in targets"); emit is consumed by all 4 emitters + the generate CLI and by
**zero** analysis crates, so by "code lives with its consumers/subject" it is
target-domain expression machinery, just shared across targets. A `targets/_shared/`
area is *domain-placed*, not the central `tools/` ADR-0043 rejected; ADR-0011
hermetic isolation governs runtime/output, not emitter code (ADR-0043 Consequences).
CONTEXT.md's "naming is shared analysis-level data" refers to the table *data*, not
the emit *code* — splitting code from data was rejected as skeleton-stage
over-engineering. **Precedent:** pulls `stub-launcher` + the generate CLI toward
`targets/_shared/tools/` too. ADR-worthy (resolves the documented
CONTEXT.md ↔ ADR-0043 tension).

### SC2 — `annotate` → `platforms/macos/tools/` (settled)

The LLM annotation tool goes to `platforms/macos/tools/annotate/`, not
`semantic/tools/`. (User choice, 2026-06-23.) Symmetry with the extractors: both
produce platform-level artifacts — extract-* → `platforms/macos/api/<f>/extracted.yaml`,
annotate → `platforms/macos/api/<f>/annotations.apiw` (§14); the tool lives where its
output lands. Splits the old C2 grouping: **platform-level producers**
(`extract-objc`, `extract-swift`, `annotate`) → `platforms/macos/tools/`;
**semantic-graph builders** (`types`, `datalog`, `resolve`, `enrich`) →
`semantic/tools/`. Workstream 5 (LLM side-channel) may relocate later — this is a
reversible `git mv`, below the ADR bar.

### SC3 — phase CLIs distributed to served domains (settled)

The three orchestrator binaries follow D2: `collect`-cli → `platforms/macos/tools/`,
`analyze`-cli → `semantic/tools/`, `generate`-cli → `targets/_shared/tools/` (it
consumes the relocated `emit`). (User choice, 2026-06-23.) Not merged into one driver
(a redesign, out of skeleton scope) and not gathered in a shared `tools/` (a mini
central `tools/`, against D2). Pipeline discoverability is the root README's job
(§11), not co-location.

### SC4 — central ADRs → root `adr/` (settled)

ADRs move `docs/adr/` → root `adr/`. (User choice, 2026-06-23.) A small, focused
top-level dir is *not* the "large top-level `docs/`" §10 forbids; it honors
CONTEXT.md/ADR-0024 (central log, global numbering, cross-target supersession graph)
and is the honest home for a decision graph owned by no single domain. Cost: a
one-time mechanical rewrite of `docs/adr/NNNN…` cross-references in code + docs (a
work-leaf step). ADR-worthy / amends ADR-0024 (which assumed `docs/adr/`).

### SC5 — buildability slicing: per-domain batches, ~8 work leaves (settled)

Each work leaf is one focused session ending with `cargo build`/`test` green at its
single commit; *within* a session, move crate-by-crate so even the intermediate
state builds. (User choice, 2026-06-23, over per-crate micro-leaves = runaway tree,
and coarse ~3-leaf big-bang = un-reviewable moves.) The workspace `members` +
`[workspace.dependencies]` path values are edited in each move leaf for the crates it
moves, keeping the build green per leaf. The heavy targets move is **pre-split** into
crates-then-material (leaves 5/6) so neither session is oversized.

### SC6 — placeholder scope: homes + READMEs + relocate + TODOs only (settled)

The skeleton lands empty home dirs with placeholder READMEs (so §45.13 "obvious place
exists" holds), relocates existing material into them, and leaves TODO markers
(§40.16) where content is owed — and authors **zero** new content artifacts (no
`.apiw` DSL, no new YAML schemas, no pattern-kind definitions; those are workstreams
2/3/8). (User choice, 2026-06-23.) Keeps the skeleton/content boundary crisp.

### SC7 — rename-first, isolated leaf (settled)

Leaf 2 does the whole `apianyware-macos-*` → `apianyware-*` rename (Cargo `[package]
name` + `[workspace.dependencies]` keys + the 3 bin names + Rust `use apianyware_macos_*`
underscore forms + literal `APIAnyware-MacOS` identity strings) with **no path
changes** (build+test+fmt green), then move-leaves change only paths, never names.
(User choice, 2026-06-23.) Clean separation, each step independently verifiable. Sized
~435 `apianyware-macos` + ~59 `APIAnyware-MacOS` occurrences. The physical dir mv
`~/Development/APIAnyware-MacOS` → `…/APIAnyware` stays a **post-merge manual step**
(root brief Notes) + a migration note authored in the finalize leaf.

### Final crate→domain map (settled, all SC decisions)

```text
semantic/tools/         types, datalog, resolve, enrich, analyze-cli
platforms/macos/tools/  extract-objc, extract-swift, annotate, collect-cli
targets/_shared/tools/  emit, stub-launcher, generate-cli
targets/<t>/tools/      emit-<t>, bundle-<t>   (racket, chez, gerbil, sbcl)
```

ADRs raised this session: **0044** (SC1, shared emit substrate → `targets/_shared/`),
**0045** (SC4, central ADRs → root `adr/`, refines 0024).

## Notes

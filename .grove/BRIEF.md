# structural-refactoring — brief

## Goal

Execute the refactor in `REFACTOR.md`: rename `APIAnyware-MacOS` → `APIAnyware`
and re-architect the repository from its current *pipeline-phase* shape
(`collection/` → `analysis/` → `generation/`) into the five *domain* partitions —
`semantic/`, `platforms/`, `apps/`, `targets/`, `schemas/` — platform-neutral
(able to absorb Linux/.NET and many target languages), with documentation
co-located beside its subject and no large top-level `docs/`.

**Scope is the full re-architecture** (decision D1), not just the directory move:
alongside the structural restructure this grove delivers the `.apiw` DSL + parser,
the canonical/resolved YAML interchange (replacing today's JSON enriched IR),
first-class semantic pattern-kind + relationship entities, per-target capability
profiles, the representability model, conformance-report machinery, and the LLM
side-channel rework.

## Done when

`REFACTOR.md` §45's success criteria hold: renamed to `APIAnyware`; macOS source
material under `platforms/macos/`; target material under `targets/<t>/`; common
app specs under `apps/<platform>/<app>/` and target implementations under
`targets/<t>/app-implementations/<platform>/<app>/`; docs local to their subject;
root README a map only; structure absorbs Linux/.NET and many targets without
redesign; projection absent from platform specs; native adapters represented as
platform/target artifacts; and an obvious home exists for schemas, pattern-kinds,
idiom catalogues, adapter specs, binding docs, conformance reports, and tests.

## Decomposition

Nine workstreams; **skeleton-first** sequencing (D4 — buildable at every step, the
risky data-model rewrite lands in a stable, well-homed tree). Materialized
**lazily**: only the first node exists now; later nodes are grown as earlier ones
retire (do not pre-spawn all nine — runaway-tree anti-pattern).

1. **skeleton** *(first node — planning leaf `02`)* — create the 5 domains; rename
   internal references; redistribute the crates into domains under one workspace
   (ADR-0043); relocate existing material; co-locate docs; slim the README; add
   placeholder skeletons. Keep the JSON-IR pipeline building throughout.
2. **spec-format / data-model** — `.apiw` DSL + parser → canonical/resolved YAML,
   replacing the JSON enriched IR. (Done in place in the new tree.)
3. **semantic model** — `semantic/`: pattern-kinds + relationship entities as
   first-class semantic entities; the semantic vocabulary docs.
4. **platform model** — `platforms/macos/`: extracted/annotations/resolved per API
   family; app-kinds; platform-level semantic tests.
5. **LLM analysis side-channel** — annotations cached / regenerable / diffable /
   reviewable / provenance-tracked / confidence-scored; fact-precedence rules.
6. **target model** — `targets/<t>/`: capability profiles, idiom catalogues,
   policies, adapter specs, bindings, conformance — reshaping the 4 live targets
   (racket/chez/gerbil/sbcl).
7. **apps** — `apps/macos/` common specs + `targets/<t>/app-implementations/`.
8. **schemas + validation** — `schemas/`: formal validation of every artifact.
9. **testing architecture** — the multi-layer test model (§33), TestAnyware /
   AppSpec integration (§34).

(2)–(9) interleave once the skeleton lands; (2) is the spine most others consume.

## Pointers

- `REFACTOR.md` — the agreed target architecture (the grove's source of truth).
- `CONTEXT.md` — the glossary / current architecture (complete-API binding model,
  hermetic per-target isolation, trampolines, JSON enriched IR + goldens). Glossary
  updates for the *new* domain vocabulary are deferred to the nodes that realize
  them (lazy).
- `docs/adr/0043-toolchain-crates-distributed-into-domains.md` — D2/D3.
- Foundational decisions D1–D4: planning leaf `plan-k1` running log.

## Notes

**Rename mechanics (constraint, not yet a decision):** this grove runs in a
worktree *inside* `APIAnyware-MacOS/.grove-worktrees/structural-refactoring`, so
the **physical** directory rename `~/Development/APIAnyware-MacOS` →
`~/Development/APIAnyware` cannot be done from inside the worktree and must be a
final **manual** step after the grove merges to main and its worktree is removed.
The grove does all **internal** renaming (Cargo package names `apianyware-macos-*`
→ `apianyware-*`, path strings, doc/identity references). The skeleton node owns
the precise split + a migration note for the post-merge `mv`.

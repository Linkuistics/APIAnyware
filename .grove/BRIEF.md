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

1. **skeleton** ✅ *(node `skeleton-k2`, complete 2026-06-24)* — created the 5 domains;
   renamed internal references (`apianyware-macos-*` → `apianyware-*`); redistributed
   the crates into domains under one workspace (ADR-0043); relocated existing material;
   co-located docs; slimmed the README to a map; added placeholder skeletons. JSON-IR
   pipeline builds + 71 test suites green throughout. §45 holds structurally (content
   rewrites remain for 2–9). See **Skeleton outcomes** below.
2. **spec-format / data-model** ✅ *(node `spec-format-k16`, complete 2026-06-24)* —
   `.apiw` KDL DSL + parser + KDL Schema + the per-family spec triad
   (`extracted.json` / `annotations.apiw` / `resolved.json`), replacing the JSON
   enriched IR; pipeline cut over to the triad (4→3 stages, `resolved`→`linked`
   rename); convention heuristics re-expressed as `ascent` datalog rules and
   `heuristics.rs` retired. The spine ws3–6 consume. See **Spec-format outcomes**
   below. (ADR-0046/0047; machine IR stayed JSON per the k17 KDL-serde NO-GO.)
3. **semantic model** ✅ *(node `semantic-model-k27`, complete 2026-06-25)* —
   `semantic/`: patterns + relationships unified as first-class authored
   **pattern-kinds** (ADR-0048, relationships folded in); the `.apiw` kind schema +
   `semantic/tools/patterns` registry + 16 authored kinds (k28); the `resolved.json`
   pattern-**instance** carriage replacing `api_patterns` (k29); the
   `apianyware-pattern-detection` convention datalog (k30); the semantic-vocabulary
   docs (k31). Goldens unmoved throughout. See **Semantic-model outcomes** below.
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

## Skeleton outcomes (promoted from `skeleton-k2` on retirement)

Durable decisions later workstreams depend on:

- **Crate-home convention.** Rust crates live under a `tools/` subdirectory of the
  domain they serve: shared crates at `<domain>/tools/<crate>/`, per-target crates at
  `targets/<t>/tools/<crate>/`. Refines ADR-0043 (toolchain distributed by domain).
  Any workstream adding a crate (esp. ws6 target model) follows this. The current
  crate→domain map is the root `Cargo.toml` `members` list (the README §11 is the
  human-facing pipeline map).
- **ADRs raised by the skeleton:** **0044** (shared `emit` substrate → `targets/_shared/`),
  **0045** (central ADRs → root `adr/`, refines 0024). ADR-0043 (toolchain distribution)
  pre-dates the node.
- **Deferred content is pinned** by co-located `TODO (workstream N)` markers in each
  placeholder README; `TODO.md` carries the per-workstream index + residual doc
  path-drift (notably the IR relocation `analysis/ir/` → `platforms/macos/api/`, owned
  by **ws4**). The skeleton authored **zero** new content artifacts (SC6).

## Spec-format outcomes (promoted from `spec-format-k16` on retirement)

Durable decisions/handoffs later workstreams depend on (the format detail itself lives
in `CONTEXT.md` "Spec format / data model" + ADR-0046/0047, read every session):

- **Per-fact `convention:<rule>` provenance carriage → deferred to ws5.** The
  convention facets (`apianyware-conventions`) *compute* a per-fact/per-index
  `convention:<rule>` stamp, but the `flip-retire-k26` cutover keeps it **off-disk**:
  assembled convention annotations stay byte-identical to the legacy heuristic output
  (`source = Heuristic`, no provenance). The richer rollout — per-fact stamps on
  `ParamOwnership`/`BlockParamAnnotation` + per-method threading/error, the `.apiw`
  schema/writer + machine serde, emit consumers, and the ADR-0046 §4
  disagreement/precedence audit (winner stamped + losers as `superseded-by`) — is
  **ws5's** (it owns "provenance-tracked" + "fact-precedence rules"; no consumer exists
  yet). The seam (ADR-0046 §4 / ws2 running-log D): **ws2 defines the carriage, ws5
  builds the mechanism.** Steer (user, k26): `annotate` runs *once per SDK update*, so
  keep the carriage minimal — annotate the canonical API, don't over-engineer
  prose-derived extras.
- **Convention tier is `ascent` datalog rules** (ADR-0047): `apianyware-conventions`
  is now the convention producer; `annotate` consumes its four facet maps by
  `(receiver, selector)`. `heuristics.rs` is retired. Runtime-loadable rules remain a
  deferred enhancement; any later rule change is a normal pipeline rebuild.
- **Goldens-as-truth is the convention-equivalence gate.** Emit goldens (Foundation +
  AppKit curated subsets + TestKit synthetic, across racket/chez/gerbil/sbcl) are the
  standing regression guard now that the `*_equivalence.rs` characterization scaffold is
  gone. Foundation `resolved.json` regenerates byte-identical pre/post-flip.
- **ws8 boundary** (recorded in `CONTEXT.md` + `schemas/`): ws2 authored only the
  `.apiw` KDL Schema + the `validate_apiw` step; ws8 owns validation tooling/CI, JSON
  Schema for the machine `extracted.json`/`resolved.json`, and the
  app-kind/AppSpec/capability-profile/conformance-report schemas.

## Semantic-model outcomes (promoted from `semantic-model-k27` on retirement)

Durable decisions/handoffs later workstreams depend on (the model vocabulary lives in
`CONTEXT.md` "Semantic model" + ADR-0048 + the PRD
`prd/2026-06-25-semantic-pattern-kind-model.md`; the prose in
`semantic/docs/{overview,pattern-model,api-pattern-catalog}.md`):

- **Two-level model, two domains.** A **pattern-kind** (roles + laws; framework- *and*
  target-independent) is authored in `semantic/pattern-kinds/<kind>.apiw`; a
  **pattern-instance** (a kind bound to a concrete framework, provenance-stamped) is
  *platform* knowledge carried in `platforms/macos/api/<F>/resolved.json`, replacing the
  old `Framework.api_patterns`. Relationships (§31) fold *into* pattern-kinds — one
  entity, one schema, one registry, one provenance path (ADR-0048 D1/D4). Instance ids
  are content-derived (DP4); cross-framework instances home to the kind's `primary` role's
  framework (DP3).
- **Crate homes:** kind registry + `.apiw` parse + §30 controlled vocab + focused validator
  in the new `semantic/tools/patterns`; convention-tier instance **detection** (datalog) in
  `platforms/macos/tools/pattern-detection`; instance **carriage** extends
  `semantic/tools/{types,resolve}`.
- **ws5 seam (D6):** ws3 defined only the instance provenance *carriage*
  (`source`/`confidence`/`provenance`; precedence `manual > llm > convention > extraction`).
  The per-fact cache / regen / review-accept / diff *workflow* + the disagreement-precedence
  audit is **ws5's** — mirrors the k26 convention-fact seam.
- **ws6 seam:** ws6 projects kinds to target idioms via the `emit/pattern_dispatch` seam; the
  semantic model is ws6's *input*, **not** the projection spec (the model stays
  target-independent — projection lives in `targets/`, never `semantic/`).
- **ws8 seam (D7):** ws3 authored the pattern-kind `.apiw` KDL Schema + focused in-crate
  validator (`schemas/spec-format/pattern-kinds.kdl-schema`); ws8 still owns the *machine*
  JSON Schema (extracted/resolved), validation tooling/CI, and the app-kind/AppSpec/
  conformance-report schemas.
- **ws9:** the semantic model informs the semantic-layer tests (multi-layer test model).

## Notes

**Rename mechanics (post-merge manual step):** this grove runs in a worktree *inside*
`APIAnyware-MacOS/.grove-worktrees/structural-refactoring`, so the **physical** directory
rename `~/Development/APIAnyware-MacOS` → `~/Development/APIAnyware` cannot be done from
inside the worktree and is a final **manual** step after the grove merges to main and its
worktree is removed. The grove did all **internal** renaming (Cargo package names, path
strings, doc/identity references) in `internal-rename-k4`. The precise post-merge step +
host-side path references (Claude memory dir, GitHub repo URL) are documented in the root
**`MIGRATION.md`** (authored by `migration-finalize-k10`).

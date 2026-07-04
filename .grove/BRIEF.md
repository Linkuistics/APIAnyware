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
4. **platform model** ✅ *(node `platform-model-k32`, complete 2026-06-25)* —
   `platforms/macos/`: the authored **`platform.apiw`** manifest (k33); the seven
   **app-kinds** as a distinct authored registry (ADR-0049; k34/k35/k36); the
   platform-level **semantic-test declarations** (two families + fixtures, declared
   not executed; k37/k38–k41); and the **platform-model docs** (k42). Built *around*
   the per-family triad ws2 already relocated; projection-free throughout. Goldens
   unmoved. See **Platform-model outcomes** below.
5. **LLM analysis side-channel** ✅ *(node `llm-side-channel-k43`, complete 2026-06-25)* —
   the overlay made provenance-tracked / regenerable / diffable / reviewable as a **lean
   mechanism over git + the pipeline** (ADR-0050), not a staging subsystem: git is the
   propose→review→accept boundary; the §4 disagreement/precedence audit stamps per-fact
   `source` + `superseded-by` into `resolved.json` at resolve time (emit-invisible →
   golden-neutral; k44 vocab + k45 audit); `apianyware-analyze annotations {stale,audit}`
   (k46/k47) + the `.apiw`-driven `/analyze` orchestration (k48) replace the retired
   bash/python scaffolding (k49). See **LLM side-channel outcomes** below.
6. **target model** ✅ *(node `target-model-k50`, complete 2026-06-26)* —
   `targets/<t>/`: the authored target-model layer over the four live targets
   (racket/chez/gerbil/sbcl) — `target.apiw` descriptors (k51); the §20
   capability / §7.7 representability model (ADR-0051; k52); idiom catalogues +
   data-driven `pattern_dispatch` (k53); projection policies + adapter specs
   (k54); conformance (k55); the per-target §18/§22 doc sets (k56); the bundler
   apps/bindings-split reshape + new-target-guide resync (k61). All in the shared
   `targets/_shared/tools/target-model` crate; goldens unmoved throughout. See
   **Target-model outcomes** below.
7. **app model** ✅ *(node `app-model-k62`, complete 2026-07-04)* — `apps/macos/`: the
   common, target-independent app data. Reframed by exploration + user steer (ADR-0052): an
   app-spec is **not** a grove-native `.apiw` entity — it is authored against + run by the
   **external AppSpec toolkit** (`~/Development/AppSpec`, an LLM-driven reverse-gen/forward-gen/run
   toolkit that holds no app data), consumed under `apps/macos/<app>/`. ws7 built + ran that
   toolkit grove to completion (k65/k66 pause point), then took eight apps end-to-end
   (hello-window k64 + k77–k83), each a reverse-gen'd `spec.md` + two contracts + a forward-gen'd
   `#lang app-spec` suite, **each live-VM-verified ×4** (87 scenarios total). Finalized the
   canonical per-app layout (k84) and the portfolio index + conformance/coverage tie-in (k85). No
   machine manifest (D3); structural facts stay prose. See **App-model outcomes** below.
8. **schemas + validation** ✅ *(node `schema-validation-k149`, complete 2026-07-04)* — `schemas/`:
   formal validation of every artifact. Machine IR **un-retreated to KDL** (ADR-0046 §5, amended in
   place — the k17 no-go reversed on a fresh non-preserving-codec spike; D1/D3/D7); the
   machine-JSON-Schema seam every prior workstream deferred here **dissolved** → **one schema
   language + one engine** over all thirteen schemas (k153); the **one validation mechanism**
   `apianyware-validate` at `schemas/tools/validate/` + `make validate` (k154, D5/D6); the
   `schemas/docs/` validation-model prose (k155). The **ADR policy** steer (D9) landed here and
   became decomposition #10. See **Schemas + validation outcomes** below.
9. **testing architecture** ✅ *(node `testing-architecture-k156`, complete 2026-07-04)* — the
   multi-layer test model (§33) + TestAnyware/AppSpec integration (§34) delivered as a **documented
   federation**, not new test machinery (ADR-0053), homed in a new top-level **`testing/`** (the
   behaviour-axis twin of `schemas/`): `test-model.md` (§33 twelve-layer map → existing homes + honest
   gaps + §34 seam) + `README.md` (k157); the parked TestAnyware docs promoted + de-staled into
   `testing/` (k158). Docs-only; golden-neutral throughout. See **Testing-architecture outcomes** below.
10. **ADR consolidation** *(added 2026-07-04, user steer — see ADR policy below)* — compress the ADR
   corpus (0001–0052+) into a **minimum coherent set** of **current-state, in-place** ADRs: fold out
   every supersession chain and "Update — …" history section (e.g. ADR-0046's k26 provenance Update;
   any residue elsewhere), merge/retire redundant ADRs, so each ADR reads as the decision *as it now
   stands*. Runs **after ws9** (compress once the corpus is final) and **before grove-finish** (it
   dovetails with the finish cycle's "promote ADRs that outlive the grove" step). Materialize the
   leaf lazily when ws9 retires. **Split across two leaves on audit** (the corpus proved to warrant it,
   per the brief's decompose note): `adr-consolidation-k159` did the mechanical/structural cluster —
   strip `Status` lines, fold out supersession chains + dated `Update` sections, **delete ADR-0018**
   (dead tombstone → 0020) + **merge ADR-0045 into ADR-0024** (docs-placement = one decision), reconcile
   all citations, keep numbers / leave gaps (de-numbering NO — 744 citing files, golden-risk). Then
   `adr-workstream-narrative-to-current-state-k160` folds the **workstream-process narrative** out of the
   ADR bodies (stale "ws8 owns machine JSON Schema" notes now that ws8 dissolved that seam, future-tense
   "Seams for the remaining workstreams" sections, dangling `.grove/`-leaf pointers).

(2)–(9) interleave once the skeleton lands; (2) is the spine most others consume. (10) is a
documentation-hygiene pass gated on the design being final.

## ADR policy (user steer, 2026-07-04)

**ADRs represent the current state, are modified in place, and record no design history.** No "later
ADR supersedes an earlier one" chains; when a decision changes, **edit the owning ADR in place** and
delete the superseded framing. The corpus is kept to a **minimum coherent set**. This is effective
now: ws9 (and any later session) raises current-state / in-place ADRs, never new supersession chains;
the one-off compression of the *existing* corpus is workstream #10. (First application: ws8 folded the
machine-KDL decision into ADR-0046 in place rather than raising a superseding ADR-0053 — see the
`schema-validation-k149` running log D9.)

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

## Platform-model outcomes (promoted from `platform-model-k32` on retirement)

Durable decisions/handoffs later workstreams depend on (the model vocabulary lives in
`CONTEXT.md` "Platform model" + ADR-0049 + the design running-log D1–D5 in the
`platform-model-k32` brief; the prose in `platforms/macos/docs/{overview,api-extraction,
app-kinds,testing-obligations}.md`). The macOS platform is **four authored sub-models**
under `platforms/macos/`, all **projection-free** (the domain rule — platform states what
the API *means*, never how a target expresses it):

- **Platform manifest (D1).** A single authored, **policy-only** `platform.apiw` (`sdk`,
  `deployment-target` floor, framework **include/ignore policy**) — KDL not YAML
  (ADR-0046). The resolved 153-family roster + cross-family dep-graph stay **derived and
  uncommitted** (recomputable from `api/`; constraint 4). Crate
  `platforms/macos/tools/platform-manifest`; schema `schemas/spec-format/platform.kdl-schema`.
- **App-kinds (D2; ADR-0049).** A **distinct entity** (not a pattern-kind), its own
  authored `.apiw` registry — seven kinds (`cli-tool`/`gui-app`/`menu-bar-daemon`/
  `launch-agent`/`spotlight-importer`/`quicklook-extension`/`finder-sync-extension`)
  stating process/run-loop/termination/activation/bundle truth. Crate
  `platforms/macos/tools/app-kinds`; flat-enum schema `app-kind.kdl-schema` + focused
  cross-field validator. **Three orthogonal axes:** app-kind (platform category) vs
  ws7 app-spec (concrete app that *names* its kind) vs ws3 pattern-kind (API-usage),
  sharing only the authored-registry mechanism.
- **Platform-test declarations (D3).** Two families, **distinct entities sharing one
  mechanism** in crate `platforms/macos/tools/platform-tests`: `tests/api-semantics/
  <facet>.apiw` (per convention facet — the §30 source-weirdness a `(receiver,selector)`
  exhibits + expectations) and `tests/app-kinds/<kind>.apiw` (obligation bodies resolving
  each kind's `test-obligation` refs + fixtures). §30 weirdness is a **facet-conditional
  controlled vocab** enforced by the focused validator (its own §30 copy — no
  `semantic/` dep). Fixtures are **lazy + assertable**. Sibling schemas
  `api-semantics.kdl-schema` + `app-kind-tests.kdl-schema`.
- **Representability is wholly ws6 (D4).** The §7.7 statuses are per **target×platform**
  (ws6/§20 capability profiles); `platforms/` carries only the §30 **source-weirdness**
  vocabulary ws6 *consumes*. **No representability metadata in `platforms/`.**

Seams for the remaining workstreams:

- **ws5 seam:** the LLM analysis side-channel reworks the annotation *workflow* over the
  per-family `annotations.apiw` overlay; `platforms/macos/docs/annotation-workflow.md`
  carries a superseded→ws5 banner (its rewrite is ws5's, per the doc-resync TODO).
- **ws6 seam:** ws6 *consumes* the platform model — projects an **app-kind** to a target
  build (`.app`/Info.plist/launchd-plist), and reads the §30 **weirdness** to compute a
  representability status. The model is ws6's input, never the projection spec.
- **ws7 seam:** an app-spec (`apps/macos/<app>/`) **names** its app-kind (category↔instance).
- **ws8 seam:** ws4 authored the three `.apiw` KDL-Schemas (`platform`, `app-kind`,
  `api-semantics`/`app-kind-tests`) + focused in-crate validators; **ws8 owns** the
  *machine*-JSON schemas (`extracted.json`/`resolved.json`) + validation tooling/CI +
  the AppSpec/capability-profile/conformance-report schemas. (Mirror of the ws3 D7 seam.)
- **ws9 seam (D3):** ws4 **declares + schema-validates** the platform tests (never
  executes); **ws9** owns the multi-layer test model (§33) + the TestAnyware/AppSpec
  runner (§34) that drives a declaration against a *running* target binding; **ws6** owns
  per-target execution hooks. The declare-now / execute-later seam (mirror of ws3→ws8).

## LLM side-channel outcomes (promoted from `llm-side-channel-k43` on retirement)

Durable decisions/handoffs later workstreams depend on (the vocabulary lives in `CONTEXT.md`
"LLM side-channel workflow" + ADR-0050; the prose in
`platforms/macos/docs/annotation-{workflow,subagent-prompt}.md` + `.claude/commands/analyze.md`).
ws5 is a **lean mechanism over git + the pipeline, not a staging subsystem** — the overlay is
already a git-committed `.apiw` text file, so diff/review/accept come from git:

- **Git is the propose→review→accept boundary.** The §28 tier `accepted-LLM` ≡ a *committed*
  `source llm` fact — no staging store, `status` flag, or state machine. A subagent writes
  `source llm` into the working tree; a human accepts by committing the diff.
- **Two source vocabularies, two homes.** The authored overlay (`annotations.apiw`, committed)
  carries `source ∈ {llm, manual}`; the resolved graph (`resolved.json`, derived + gitignored)
  carries the full ladder `{extraction, convention:<rule>, llm, manual, unknown}` after the
  audit. Per-fact provenance + `superseded-by` live in `resolved.json` **only**, never the
  overlay. `AnnotationSource` reconciled to this vocab (k44).
- **The disagreement audit is golden-neutral by construction** (k45). At resolve time, per
  `(receiver, selector)` fact-slot: gather producers, apply §28 precedence, stamp the winner's
  `source`, record disagreeing losers as `superseded-by`, leave no-producer slots explicit
  `unknown`. It stamps *provenance*, not winning values → **emit-invisible → goldens cannot
  move**. This invariant gated every ws5 child and remains the regression guard for ws6+.
- **Staleness is live; regeneration is in Claude Code** (k46/k47). `apianyware-analyze
  annotations stale` set-diffs a family's committed overlay against the current **resolved API
  surface** (`resolved.json` — *not* `extracted.json`: the overlay mirrors the
  inheritance/conformance-flattened, Swift-renamed resolved surface) for orphaned / new-surface /
  shape-changed slots, exiting 1 to gate CI/Make; `annotations audit` reports disagreements +
  per-tier win distribution (informational, exit 0). Regeneration dispatches subagents per stale
  family, each writing `.apiw` directly (economic constraint [[llm_annotation_constraint]]).
- **Tooling home + orchestration** (k48/k49). The mechanism extends
  `platforms/macos/tools/annotate` + `apianyware-analyze` subcommands (no new crate); annotation
  is **platform** knowledge (never `semantic/`). The dead bash/python/external-API scaffolding is
  retired; `Makefile` `lint-annotations` gates on the subcommands; the workflow lives in
  `.claude/commands/analyze.md` + `platforms/macos/docs/annotation-{workflow,subagent-prompt}.md`.

Seams for the remaining workstreams:

- **ws6 seam:** ws6 *consumes* resolved provenance/confidence (projection / representability);
  ws5 only **produces** it. Emit stays provenance-blind.
- **ws8 seam:** ws5 extended the `.apiw` overlay schema (`source` → `{llm, manual}`) + the
  `resolved.json` Rust serde (full ladder + `superseded-by`); the *machine JSON Schema* for
  `resolved.json` + validation tooling/CI stay **ws8's** (mirror of the ws2/ws3/ws4 seams).

## Target-model outcomes (promoted from `target-model-k50` on retirement)

Durable decisions/handoffs later workstreams depend on (the vocabulary lives in
`CONTEXT.md` "Target model" + ADR-0051 + the `target-model-k50` brief's running log
D1–D7; the prose in each target's `docs/{overview,language-characteristics,ffi-model,
idiom-map,representability}.md` + `bindings/<platform>/docs/*.md`). The target model is the
**authored layer over the four already-shipped, VM-verified targets** — it reshapes their
homes + adds the model, it does not re-port them; per-target richness is affordable because
the LLM makes it so ([[maximize_target_idiom_and_perf]]):

- **Entity split: authored *input*, derived *status* (D1).** The §18 entities classify on the
  same authored-vs-derived axis ws4 used. **Authored, committed `.apiw`** under `targets/<t>/`:
  the **target descriptor** (`target.apiw` — §17 family/dialect/implementation/ffi-backend/
  runtime-model/projection-policy/adapter-strategy as data), the **capability profile**
  (`capability.apiw`), the **idiom catalogue** (`idioms/*.apiw`), the **projection policy**
  (`policies/<platform>/*.apiw`), the **adapter spec** (`adapters/<platform>/spec.apiw`), and the
  authored **judgment** slice of conformance (`conformance/<platform>.apiw`). **Derived,
  uncommitted** (recomputable → constraint 4): the per-API representability status and the
  conformance coverage / app-implementation status. **Prose `.md`**: the §18 target docs + §22
  binding mapping docs.
- **Capability/representability is a 7-rung ladder, derived as a floor (D2; ADR-0051).** One
  ladder unifies §20's levels and §7.7's statuses: `exact-static > exact-runtime >
  idiomatic-conventional > lossy-but-documented > unsafe-only > not-representable > research`.
  The **capability profile is authored + platform-INDEPENDENT** (keyed on a shared §20
  capability-dimension vocab in `targets/_shared`); a shared, target-independent
  **`weirdness → capability` map** bridges platform truth and target capability;
  `status(api, target)` = the worst rung over `{ profile[needs(w)] : w ∈ platform.weirdness(api) }`,
  defaulting to `exact-static` for an API with no §30 weirdness (the trampoline-elision limit).
  A second **app-form** capability face feeds per-app-kind feasibility, not per-API
  representability.
- **One shared crate; per-target data (D5).** All target-model machinery is target-independent →
  **one** crate `targets/_shared/tools/target-model` (submodules `descriptor/`, `capability/`,
  `idioms/`, `policy/`, `adapter_spec/`, `conformance/` + `vocab.rs` + `derive.rs`); the per-target
  `.apiw` files are **data** under `targets/<t>/`. Crate-home convention holds (per-target crates
  at `targets/<t>/tools/<crate>`; the shared emit substrate at `targets/_shared/`, ADR-0044).
- **Idiom projection: author + data-drive the seam; *applying* projection deferred (D3).** ws6
  authored the §21 idiom catalogue and refactored `classify_pattern` to **read the per-target
  catalogue** (`emit/pattern_dispatch`), verified golden-neutral. **Wiring the emitters to
  consume pattern-instances** (emit `with-bracket`/`make-foo` wrappers) moves goldens in all four
  targets + needs a per-target VM-verify → a clearly-scoped, **golden-INTENTIONAL** follow-on (a
  future grove), **not** folded into the authored-layer work. Mirrors ws3–ws5's
  "author the carriage, defer the consumer."
- **Per-target doc-set shape (child 6).** Each target carries **§18 target docs** at
  `targets/<t>/docs/{overview,language-characteristics,ffi-model,idiom-map,representability}.md`
  (a map + four deep-dives; `idiom-map.md` a thin pointer to the authoritative
  `idioms/docs/idiom-map.md`) and **§22 binding mapping docs** at
  `targets/<t>/bindings/<platform>/docs/{user-guide,platform-docs-mapping,api-coverage,
  unsafe-escape-hatches}.md` — every doc pointing at the target's authored `.apiw` entities and
  citing `apianyware-conformance` for derived coverage (constraint 4). A target with no
  `developer-guide.md` (chez/gerbil/sbcl) makes the §22 `user-guide.md` its primary user doc. The
  new-target guide (`targets/_shared/docs/adding-a-language-target.md`) bakes this in as Step 9.

Seams for the remaining workstreams:

- **ws7 (apps):** the common, target-independent **app-specs** live at `apps/macos/<app>/` (ws7);
  the per-target **app-implementations** already live at
  `targets/<t>/app-implementations/<platform>/<app>/` and are **ws6's** (the VM-verified sample
  apps) — ws6 only homes the conformance *report* over them. The bundlers read apps from the
  app-implementations root and the binding package from `bindings/<platform>/` natively
  (`bundler-reshape-k61`).
- **ws8 (schemas):** ws6 authored the `.apiw` **KDL Schemas** (`schemas/spec-format/{target,
  capability,idioms,policy,adapter-spec,conformance}.kdl-schema`) + focused in-crate validators;
  ws8 owns the **machine JSON Schema** for any derived report + validation tooling/CI (standing
  ws2/3/4/5 seam).
- **ws9 (testing):** ws9 owns the multi-layer test model + the TestAnyware/AppSpec runner;
  **per-target execution hooks are ws6's** (declare-now/execute-later). ws6's conformance `binding
  tests` field *references* test results; it does not build the runner.
- **Deferred *apply-projection* follow-on (D3):** turning on emitter consumption of
  pattern-instances is golden-intentional and lives in a **separate future grove**, not ws7/8/9.

## App-model outcomes (promoted from `app-model-k62` on retirement)

Durable decisions/handoffs the remaining workstreams depend on (the vocabulary lives in
`CONTEXT.md` "App model" + **ADR-0052** + the `app-model-k62` running log D1–D5; the prose in
`apps/README.md` + `apps/macos/README.md` + `apps/macos/docs/{_index,reverse-gen-workflow,
appspec-toolkit-seed}.md` + each app's `docs/`). ws7 turned out **not** to be an
entity-authoring workstream at all — exploration + a user steer reframed it as *homing +
reconciling the external AppSpec toolkit's data*:

- **The app-spec is external, not grove-native (D1 + D2′; ADR-0052).** An app-spec is authored
  against, and run by, the **external AppSpec project** (`~/Development/AppSpec`) — an LLM-driven,
  human-in-the-loop toolkit (reverse-gen a spec from an impl · forward-gen a suite from the spec ·
  run it against any impl in a live VM through TestAnyware) that **holds no app data**. The data
  lives here under `apps/macos/<app>/` in the toolkit's own **`#lang app-spec`** format; the grove
  does **not** reinvent it as `.apiw`. Three-layer boundary: **TestAnyware** (VM substrate) →
  **AppSpec** (toolkit + formats) → **APIAnyware `apps/macos/`** (the generated+validated data).
  The AppSpec toolkit grove was built, seeded, and **run to completion** during the k66 pause
  (three capabilities: reverse-gen/forward-gen/run).
- **Eight apps, all live-VM-verified ×4 (D2).** The finalized portfolio: hello-window ·
  ui-controls-gallery · note-editor · mini-browser · drawing-canvas · scenekit-viewer ·
  pdfkit-viewer · swift-native-probe — 87 `#lang app-spec` scenarios total; all app-kind
  `gui-app` (ADR-0049 instance side). Each per-app node was decomposed on entry and carried its
  own VM-verify done-bar ([[vm-verify-every-app]]); reds adjudicate to run-mechanism classes
  (OCR small-text, delayed-truncate, driver races) with the fact proven via a second channel —
  **no impl defect survived** in any app.
- **Canonical per-app layout (k84).** `docs/{spec,logging-contract,observable-state,run-results}.md`
  + `scenarios/*.rkt` + `run-values.rkt`; optional (present only when earned) `docs/learnings.md`,
  `run-values-<impl>.rkt`, `fixtures/`. Pre-AppSpec `test-strategy.md` checklists retired.
- **No machine manifest; structural facts as prose (D3, re-confirmed at k85).** The app↔app-kind
  binding, exercised pattern-kinds, and display-name stay **prose** in each `spec.md` structured
  header. The bundlers read the display-name from `spec.md`'s first H1 (zero-churn). A machine
  `app.apiw` is **deferred** (constraint 4) — k85 re-ran the "IF a real machine consumer
  materializes" test against the coverage tie-in and it resolved **no** (the tie-in reads the
  app-kind binding from each *target's* `conformance/macos.apiw`, never `apps/macos/`).
- **Coverage is derived, not hand-maintained (k85).** Per-target app status is derived on demand
  by `apianyware-conformance` (ws6 — scans `app-implementations/` + `reports/`, cross-checks
  authored judgment); the portfolio index `apps/macos/docs/_index.md` **points at** that report
  rather than duplicating it. Roster edges settled: **swift-native-method-probe** is a per-target
  verification probe (racket/chez/gerbil; sbcl method-port is a research item), **not** a
  portfolio app — no common AppSpec; **modaliser** is an external real-world reference app that
  informed the design, not a sample — nothing relocated (its `knowledge/` was untracked and is
  absent from the tree).

Seams for the remaining workstreams:

- **ws8 (schemas):** ws7 authored **no** grove-native AppSpec `.apiw` schema — the earlier "ws7
  may author the AppSpec KDL Schema + validator" presumption was **dropped** (D1): `#lang
  app-spec` is the external AppSpec project's format, and **AppSpec owns its own reader/validation**.
  So the standing ws2/3/4/5/6 "ws8 owns the machine JSON Schema" seam does **not** extend to
  AppSpec data — there is no grove-authored AppSpec artifact for ws8 to schema.
- **ws9 (testing):** ws9 owns the APIAnyware-side multi-layer test model (§33). The **AppSpec
  runner** (§34) that drives a suite against a running impl is the **external AppSpec project's**,
  already built + run to completion during the k66 pause — so ws9 integrates/references it rather
  than building it (the ws4/ws6 declare-now/execute-later mirror, but with the executor external).

## Schemas + validation outcomes (promoted from `schema-validation-k149` on retirement)

Durable decisions/handoffs the remaining workstreams depend on (the vocabulary lives in
`CONTEXT.md` "Validation (refactor workstream 8)" + **ADR-0046 §5** + the node running log D1–D10;
the prose in `schemas/docs/validation-model.md` + `schemas/README.md` + `schemas/spec-format/README.md`).
ws8 delivered the missing validation *layer* over the already-authored artifacts — it did **not**
re-author the twelve `.apiw` schemas ws2–ws6 own:

- **The machine IR un-retreated to KDL (D1/D3/D7; ADR-0046 §5, amended in place).** The ws8 spike
  (`machine-format-spike-k150`) measured the path k17 never tested — a **non-format-preserving** JiK
  codec over `serde_json::Value` — at ~2.4–3.2× typed `serde_json` (k17's ~84× tax was
  format-preservation, not KDL). User GO (D3). `extracted.json`/`resolved.json` → **`extracted.kdl`/
  `resolved.kdl`**; codec homes in `semantic/tools/spec-format`; **golden-neutral at the emit layer**
  (generator reads the same typed `Framework`; only on-disk encoding changed — held across k152).
  Codec depth = **Value-bridge** (D4); a native-serde JiK format (~1.3–1.5×) is a documented deferred
  trigger, built only if the generate-loop delta is ever felt.
- **One schema language, one engine — the machine-JSON-Schema seam dissolved (k153).** The moment the
  machine IR became KDL, "formal validation of every artifact" collapsed to **one** language (KDL
  Schema) + the **generic engine that already existed** (`apianyware_spec_format::validate_against_schema`).
  All thirteen `schemas/spec-format/*.kdl-schema` (twelve authored + `machine-ir.kdl-schema`) share it.
  **No JSON Schema anywhere.** The "ws8 owns the machine JSON Schema" seam ws2–ws6 each deferred here is
  therefore **retired, not fulfilled**. The machine schema is an **open** content model (additive-tolerant;
  pins spine/identity/scalars/`checkpoint` enum); the KDL Schema Language's lack of `$ref`/recursion sets
  its altitude (accept-any below the declaration entities).
- **One validation mechanism: `apianyware-validate` (D5/D6; k154).** A **lean tree-walking driver** at
  the new crate **`schemas/tools/validate/`** (`schemas/` is now an active **tool home** — D6; the generic
  *engine* stays in `semantic/tools/spec-format`, a semantic-domain concern). It dispatches every authored
  `.apiw` to its producing crate's validator and reports per-class; **coverage-as-a-guard** (an `.apiw`
  matching no rule is a failure) makes the "validate *every* artifact" promise self-enforcing. Wired to
  **`make validate`**. **Authored by default; machine IR opt-in `--machine`** (D10 — the format-preserving
  parse is ~2 s/MB → minutes-scale, so it must not run on every `make validate`; a `Value`-based fast-path
  engine is a deferred trigger). **CI deferred — none exists** (D5; net-new infra, out of ws8's lean scope).
  Three complementary layers: umbrella · per-crate registry guards (`cargo test`) · `lint-annotations` drift gate.
- **Derived reports stay on-demand (D8).** ws8 schemas the machine **IR** but **not** ad-hoc derived
  reports (conformance coverage, capability/representability) — they stay derived/uncommitted/un-schema'd
  (constraint 4; ws6/ws7 point at the report). Only conformance's *authored judgment slice* has a schema.
  **Reopen trigger:** IF a real machine consumer of a report materializes.
- **ADR policy: current-state, in-place, no supersession chains (D9).** The user's mid-session steer;
  already promoted to the **ADR policy** section above and externalized as decomposition **#10**. First
  applied here: the machine-format decision folded **into ADR-0046 in place** (not a superseding ADR-0053).

Seams for the remaining workstreams:

- **ws9 (testing):** ws8 owns **artifact validity** (is the KDL well-formed against its schema?); ws9 owns
  the **multi-layer test model** (§33) + TestAnyware/AppSpec integration (§34) — **does the binding
  behave?**. Orthogonal axes (a schema-valid artifact can still describe a broken binding). The AppSpec
  runner (§34) is the **external** AppSpec project's, already built (ws7 D1/ADR-0052) — ws9 integrates it.
- **#10 (ADR consolidation):** D9's policy is now standing (ws9 raises current-state/in-place ADRs, never
  new chains); the corpus-wide compression of ADRs 0001–0052 is **#10**, after ws9. A residual pre-existing
  ADR-0046 k26 provenance "Update" section is flagged for that step.

## Testing-architecture outcomes (promoted from `testing-architecture-k156` on retirement)

Durable decisions/handoffs #10 + grove-finish depend on (the vocabulary lives in `CONTEXT.md`
"Test model (workstream 9)" + **ADR-0053** + the `testing-architecture-k156` running log D1–D5; the
prose in `testing/{test-model.md,README.md,testanyware-workflow.md,strategies/}`). ws9 was **not** an
entity- or machinery-authoring workstream — like ws7 (homed external AppSpec) and ws8 (thin validation
layer), it **documents + homes** the test layers that already exist:

- **A documented federation, not a runner (D1; ADR-0053).** 9–10 of REFACTOR §33's twelve test layers
  already have real, verified homes scattered across the five source domains (spec-validity → ws8
  `apianyware-validate`; extraction → emit goldens ×4 + `extract-*/tests`; annotation → ws5
  `annotations {stale,audit}`; conformance → ws6 `apianyware-conformance`; sample-app/GUI → the
  **external** AppSpec suites; adapter-ABI → `adapters/*/tests`; packaging → `bundle-*/tests`). So ws9
  authored the **model** — `testing/test-model.md` maps each layer to its home, marks the honest gaps,
  names the external seam — and built **no runner and no crate**. Golden-neutral by construction (only
  Markdown). Rejected: a unified test-execution engine (net-new machinery contradicting three standing
  seams — runner-external, hooks-are-ws6, declare-now/execute-later).
- **Home: top-level `testing/` (D2).** The behaviour-axis twin of `schemas/` —
  `schemas/docs/validation-model.md` answers "is it well-formed?", `testing/test-model.md` answers
  "does it behave?". Doc-only (no `tools/`), consistent with the repo's non-domain top-level dirs
  (`adr/`, `prd/`, `process/`, `schemas/docs`); satisfies §45.13 ("obvious home for … tests"). Homes the
  promoted+de-staled TestAnyware methodology docs (`testanyware-workflow.md` + `strategies/`).
- **§34 seam is pure reference (D3).** The three-layer boundary **TestAnyware** (VM substrate) →
  **AppSpec** (external toolkit + `#lang app-spec`, holds no app data) → **APIAnyware** (`apps/macos/`
  data) is already settled (ADR-0052). `test-model.md` **describes** it and points at the external
  runner; it mints **no** test manifest, cross-layer index, or conformance tie-in (ws6 already derives
  per-app status). Reopen trigger: a machine consumer of a cross-layer test index materializes — none does.
- **Honest gaps stated as gaps (D4; §43).** Layer-6 api-semantics execution = **declared-not-executed**
  (ws4 declarations are schema-valid + honored-by-construction via goldens + incidentally exercised by
  AppSpec VM-verify, but no per-obligation runtime runner); layer-11 performance = **gap**; layer-12
  leak/lifetime/threading stress = **gap** (indirect coverage only). Each carries a reopen trigger. Same
  "build when the need is felt" class as ws8's on-demand reports.

Seam for the remaining step:

- **#10 (ADR consolidation):** **ADR-0053** was raised **current-state / in-place** per the D9 policy (a
  *new* decision recording federation-over-machinery + external-executor + top-level-home, **not** a
  supersession chain) — so it needs no rework in #10. #10 remains the corpus-wide compression of
  ADRs 0001–0052 (flagged residues: ADR-0046 §k26 provenance "Update"; ADR-0024's migration-narrative
  "Consequences"), gated on the design now being final, dovetailing with grove-finish's "promote ADRs
  that outlive the grove" step.

## Notes

**Rename mechanics (post-merge manual step):** this grove runs in a worktree *inside*
`APIAnyware-MacOS/.grove-worktrees/structural-refactoring`, so the **physical** directory
rename `~/Development/APIAnyware-MacOS` → `~/Development/APIAnyware` cannot be done from
inside the worktree and is a final **manual** step after the grove merges to main and its
worktree is removed. The grove did all **internal** renaming (Cargo package names, path
strings, doc/identity references) in `internal-rename-k4`. The precise post-merge step +
host-side path references (Claude memory dir, GitHub repo URL) are documented in the root
**`MIGRATION.md`** (authored by `migration-finalize-k10`).

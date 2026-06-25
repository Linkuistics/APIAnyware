# target-model-k50 — brief

**Kind:** planning

## Goal

Open **workstream 6** of the `structural-refactoring` grove (root brief decomposition #6): the
**target model** under `targets/<t>/` — capability profiles, idiom catalogues, policies, adapter
specs, bindings, and conformance — **reshaping the four live targets** (racket / chez / gerbil /
sbcl) from their current pipeline-era `generation/targets/<t>/` shape into the domain tree. This
is a **planning** leaf: grill the ws6 design with the user, raise ADRs / a PRD where decisions are
genuine agreement points, update `CONTEXT.md` inline as the target-model vocabulary resolves, and
**decompose into a node** (`leaf-decompose`) — doing only the first child this session.

## Context (root brief #6 + the consuming seams promoted from ws1–ws5)

ws6 is the workstream most of the earlier ones fed. The seams it must honour, already settled:

- **ws6 *consumes* the semantic model; it does not author it (ws3 seam).** ws6 projects
  pattern-**kinds** to target idioms via the `emit/pattern_dispatch` seam. The semantic model is
  ws6's **input** — projection lives in `targets/`, **never** `semantic/` (the model stays
  target-independent).
- **ws6 *consumes* the platform model (ws4 seam).** It projects an **app-kind** to a concrete
  target build (`.app` / Info.plist / launchd-plist) and reads the §30 **source-weirdness**
  vocabulary to compute a representability status. The platform model is ws6's input, never the
  projection spec.
- **Representability is wholly ws6 (ws4 D4).** The §7.7 statuses are per **target×platform** and
  belong to ws6's §20 **capability profiles**; `platforms/` carries only the §30 weirdness
  vocabulary ws6 consumes. No representability metadata lives in `platforms/`.
- **ws6 *consumes* resolved provenance/confidence (ws5 seam).** Projection / representability may
  read per-fact `source` + `confidence` from `resolved.json`; ws5 only **produces** it, and **emit
  stays provenance-blind** — a projection that branches on provenance is the new surface ws6 owns,
  not an emit change.
- **Crate-home convention (skeleton outcome).** Per-target crates live at
  `targets/<t>/tools/<crate>/`; the shared emit substrate is `targets/_shared/` (ADR-0044). Any
  crate ws6 adds or relocates follows this. The crate→domain map is the root `Cargo.toml` `members`.
- **Goldens-as-truth remains the regression gate.** The emit goldens (Foundation + AppKit curated
  subsets + TestKit synthetic, across racket/chez/gerbil/sbcl) guard every reshape; a moved golden
  is a bug unless the reshape *intends* an emit change (and then the golden update is deliberate).

## Grilling agenda (one question at a time — propose a recommended answer for each)

Open threads to settle before decomposing (not exhaustive — grove is for incremental discovery):

- **Skeleton-first sequencing.** What buildable-at-every-step order does the reshape take, so the
  risky bits land in a stable tree? (mirrors the root-brief D4 discipline.)
- **The target-model entities.** Which are authored `.apiw` artifacts (capability profiles, idiom
  catalogues, policies, adapter specs) vs derived/generated (bindings, conformance reports)? What
  does each look like, and where exactly under `targets/<t>/` does it home?
- **Capability profile / representability shape (§20 / §7.7).** The per-target×platform status
  model — its vocabulary, how it reads the §30 weirdness, and how a status is computed/validated.
- **Idiom catalogue + the `pattern_dispatch` projection seam.** How a pattern-kind projects to
  each target's idiom; how the catalogue is authored and consumed by emit.
- **Reshaping the 4 live targets.** Moving `generation/targets/<t>/` material into the domain tree
  (bindings, app-implementations, per-target `Package.swift`) without breaking goldens;
  re-syncing the new-target guide's step paths (`targets/_shared/docs/adding-a-language-target.md`).
- **ws7/ws8/ws9 boundaries.** App-implementations (`targets/<t>/app-implementations/<platform>/<app>/`)
  vs ws7 app-specs (`apps/macos/<app>/`); capability-profile / conformance-report **machine
  schemas** are ws8's; per-target test **execution hooks** are ws6's but the multi-layer runner is
  ws9's.

## Done when

The ws6 design is grilled to shared understanding; ADR(s) raised for the load-bearing decisions
(esp. the authored-vs-derived entity split + the representability home); `CONTEXT.md` carries the
new target-model vocabulary; and the leaf is **decomposed** into the `target-model-k50` node with
an ordered first child, that first child executed this session.

## Decisions (running log)

Captured inline as each grilling question settles (driving.md running-log habit).

### D1 — Entity split: authored *input*, derived *status*

The §18 target-model entities classify along the authored-vs-derived axis exactly as
ws4's manifest/roster split did (manifest authored, roster/dep-graph derived):

- **Authored, committed `.apiw`** — the genuinely *authored policy/knowledge* a human (or
  accepted-LLM) decides: the **target descriptor** (`target.apiw` — §17 language family /
  dialect / implementation / FFI backend / runtime model / projection policy / adapter
  strategy), the **capability profile** (`capability.apiw` — §20: what the impl *can*
  express, by representability level), the **idiom catalogue** (`idioms/*.apiw` — §21:
  source-concept → target idiom), the **projection policy** (`policies/<platform>/*.apiw`
  — §23), the **adapter spec** (`adapters/<platform>/spec.apiw` — §24–26 roles / runtime
  services / direct-call policy), and the **authored *judgment* slice of conformance**
  (`conformance/<platform>.apiw` — §37 unsupported features / research items / known
  issues / app-kind support call).
- **Derived, uncommitted** (recomputable → constraint 4, no rot) — the **per-API
  representability status** (§7.7 = capability profile × the platform's §30 source-weirdness
  for that API) and the **conformance coverage / app-implementation status** (computed from
  the generated bindings + the VM-verify reports already under `bindings/macos/reports/`).
- **Prose `.md`** — the §22 mapping docs (`bindings/<platform>/docs/{user-guide,
  platform-docs-mapping,api-coverage,unsafe-escape-hatches}.md`) and the §18 target docs
  (`docs/{overview,language-characteristics,ffi-model,idiom-map,representability}.md`).

This keeps representability **explicit** (§7.7) yet **computed, not snapshotted** — the
machine layer needs an authored capability profile to compute against, which is why the
docs-only minimal option was rejected; committing the status itself was rejected as
derivable-fact duplication (the ws4 "keep carriage minimal" / k26 steer).

### D2 — Capability profile shape + representability derivation

One **7-rung representability ladder** unifies §20's levels and §7.7's statuses (they are
the same ladder under two names — a glossary term, not two enums):
`exact-static` (≡ fully-represented) > `exact-runtime` (≡ runtime-represented) >
`idiomatic-conventional` (≡ conventionally-represented) > `lossy-but-documented`
(≡ lossily-represented) > `unsafe-only` > `not-representable` (≡ unsupported) > `research`.

- **Capability profile = authored, platform-INDEPENDENT.** Each target authors
  `capability.apiw` mapping a **§20 capability dimension** (a *shared controlled vocabulary*
  in `targets/_shared` — `foreign-thread-callbacks`, `struct-by-value`, `deterministic-cleanup`,
  …) → a ladder rung. It describes the *implementation*, so it is reusable across platforms
  (a CL impl "supports finalization" regardless of macOS) — the option that keyed the profile
  directly on macOS §30 weirdness tags was rejected for coupling intrinsic capability to one
  platform.
- **A shared, target-independent `weirdness → capability` map** (`targets/_shared`) is the
  bridge between platform truth and target capability: it says *which* §20 capability a given
  §30 source-weirdness demands (`may-reenter → foreign-thread-callbacks`). Target-independent
  because the demand is intrinsic to the difficulty, not the target.
- **Representability per API is DERIVED as a floor:** `status(api, target) =` the worst
  (lowest) ladder rung over `{ profile[needs(w)] : w ∈ platform.weirdness(api) }`. An API with
  **no** authored §30 weirdness tag defaults to `exact-static`/fully-represented — exactly the
  **trampoline-elision limit** (the vast directly-reachable ObjC surface is fully represented;
  only the weird / Swift-native residual drops down the ladder). Cheap to compute on demand,
  so it stays uncommitted (D1).
- **Two profile faces.** The per-API *semantic* capabilities above feed representability; the
  §36 **app-form** capabilities (`packaging`, `app-bundle`, `plugin`, `sandboxing`,
  `native-runtime-embedding`) are a second authored face feeding **per-app-kind feasibility**
  (the conformance `app-kind support` call, §37), not per-API representability.

### D3 — Idiom catalogue: author + data-drive the seam; defer *applying* projection

ws6 authors the §21 idiom catalogue as `.apiw` (D1) and **externalizes the existing,
currently-unconsumed `emit/pattern_dispatch` classifier onto it** — but does **not** turn on
generation this grove:

- **Author** `targets/<t>/idioms/<category>.apiw` — the §21 source-concept → target-construct
  mapping (`bracket → with-macro + unwind-protect`, `error-out → condition + multiple-values`,
  …) — plus the generated/maintained §21 idiom docs under `idioms/docs/`.
- **Data-drive the seam:** refactor `classify_pattern` (today a hardcoded Rust `match` on kind
  name, scheme-flavoured names baked in) to **read the per-target catalogue**; the shared `emit`
  crate keeps the plumbing, the per-target `.apiw` supplies the construct + naming. Verified
  golden-neutral: `classify_pattern`/`IdiomaticConstruct` have **zero callers** and every
  emitter is **pattern-blind** today (grep, 2026-06-25) — exactly the state ws3 left
  ("no consumer projects instances yet (ws6)").
- **Defer *applying* projection** — wiring the emitters to consume pattern-instances and emit
  `with-bracket`/`make-foo` wrappers **moves goldens in all four targets and needs a per-target
  VM-verify**, and would compete with each target's already-shipped hand-tuned idiom. That is a
  clearly-scoped, **golden-INTENTIONAL** follow-on (a late ws6 child or a future grove), not
  folded into the authored-layer work. Mirrors ws3–ws5's "author the carriage, defer the
  consumer."

### D4 — Target/implementation axis: flat dir, §17 facets as data, lazy 2nd impl

`targets/<t>/` stays **one implementation**. `target.apiw` carries §17's seven distinguishing
facets as *data* (`family`, `dialect`, `implementation`, `ffi-backend`, `runtime-model`,
`projection-policy`, `adapter-strategy`) — so the model is per-implementation even though the
directory is flat. **No `implementations/` subdir** until a *second* impl of one language is
actually built (then add it lazily, mirroring ws4's "add the 2nd platform lazily"); §18's
`implementations/gerbil-current.yaml` sketch is not materialized for a single impl (grove
anti-pattern: structure before the 2nd instance needs it). Family-level grouping (the CL-family
contract) stays **metadata** (`family` facet) + the existing `targets/_shared/docs/design/
2026-06-20-cl-family-interface-contract.md` — no `targets/<family>/<impl>/` directory rename
(rejected: moves 4 working trees + every path ref + goldens for grouping metadata already
expresses). A future `targets/ccl/` simply declares `family="common-lisp" implementation="ccl"`.

### D5 — Crate home: one shared `targets/_shared/tools/target-model` crate

All target-model machinery is **target-independent** (the schema is identical across
racket/chez/gerbil/sbcl; only the authored data differs), so it lives in **one** shared crate
`targets/_shared/tools/target-model` with **submodules per entity** (`descriptor/`, `capability/`,
`idioms/`, `policy/`, `adapter_spec/`, `conformance/`) plus `vocab.rs` (the §20 capability
dimensions + the `weirdness → capability` map) and `derive.rs` (the representability floor +
conformance-coverage derivation). Mirrors ws4's one-crate/submodules `apianyware-platform-tests`;
rejects per-target crates (4× duplicated machinery) and folding into `emit` (a rendering crate
should *consume* the model, not own it). The per-target `.apiw` files are **data** under
`targets/<t>/`. ws6 authors the `.apiw` **KDL Schemas** (`schemas/spec-format/{target,capability,
idioms,policy,adapter-spec,conformance}.kdl-schema`) + the focused in-crate validators; **ws8**
owns the *machine* JSON Schema + validation tooling/CI (the standing ws2/ws3/ws4 seam). The
derivation is surfaced via a thin CLI later (a child), not built before its consumer.

### D6 — Cross-workstream boundaries (confirmed standing seams, not new decisions)

- **ws7 (apps):** the common, target-independent **app-specs** live at `apps/macos/<app>/` (ws7);
  the per-target **app-implementations** already live at `targets/<t>/app-implementations/<platform>/
  <app>/` and are **ws6's** — they exist (the VM-verified sample apps), ws6 only homes the
  conformance *report* over them.
- **ws8 (schemas):** ws6 authors the `.apiw` **KDL Schemas** + focused in-crate validators; ws8
  owns the **machine JSON Schema** for any derived report + validation tooling/CI (standing
  ws2/3/4/5 seam).
- **ws9 (testing):** ws9 owns the multi-layer test model + the TestAnyware/AppSpec runner;
  **per-target execution hooks are ws6's** (declare-now/execute-later, the ws4 D3 mirror). ws6's
  conformance `binding tests` field *references* test results; it does not build the runner.
- **The bundler-reshape residuals are ws6's** (TODO.md "Two residual ws6 items"): teach
  `bundle-*` the apps-root / bindings-root split (kill the symlink fixture), fix
  `bundle-racket/examples/bundle_app.rs`'s stale `knowledge/apps/<app>/spec.md` read, and
  re-sync the new-target guide's step paths.

### D7 — Decomposition: seven children, skeleton-first; target-descriptor first

ws6 decomposes into seven build children (materialized **lazily** — only child 1 now; the rest
grow via `leaf-add` as earlier ones retire). Skeleton-first (D4 root discipline): every child
buildable + goldens-green.

1. **target-descriptor** *(first, this session)* — stand up the shared
   `targets/_shared/tools/target-model` crate (+ root `Cargo.toml` member) with its `descriptor/`
   submodule (parse `target.apiw` → serde + focused validator), `schemas/spec-format/
   target.kdl-schema`, and author `target.apiw` (§17 facets, D4) for all four targets. Smallest
   foundational unit; sets the authored-`.apiw` + KDL-Schema + focused-validator pattern the rest
   mirror (the ws4 platform-manifest-first move).
2. **capability + representability** — shared §20 capability-dimension vocab + `weirdness →
   capability` map + the 7-rung ladder + `capability.apiw` ×4 + `derive.rs` representability
   floor + schema + validator. **The candidate ADR (capability/representability model, D2) lands
   here** — the genuinely novel model (parallel to ADR-0048/0049).
3. **idioms + data-driven dispatch** — `idioms/<category>.apiw` ×4 + catalogue loader + refactor
   `classify_pattern` to consume it (golden-neutral, D3) + §21 idiom docs + schema.
4. **policy + adapter-spec** — `policies/<platform>/*.apiw` (§23) + `adapters/<platform>/spec.apiw`
   (§24–26, over the *existing* adapter code) ×4 + schemas + validators.
5. **conformance** — authored judgment `conformance/<platform>.apiw` ×4 + `derive.rs` coverage /
   app-status + the thin report-generating CLI surface + schema/validator.
6. **mapping + target docs** — §22 `bindings/<platform>/docs/*.md` + §18 `docs/*.md` ×4; discharge
   the per-target ws6 README markers.
7. **bundler reshape + guide resync** — the D6 bundler residuals + re-sync
   `targets/_shared/docs/adding-a-language-target.md` step paths.

**No PRD.** Like ws4, these decisions mostly *apply* existing decisions (the `.apiw` format,
crate-home convention, the domain rule, the ws3/4 schema/validator seam) + confirm boundaries;
the one genuinely novel model (capability/representability derivation) earns a single ADR at
child 2. The running log + glossary suffice.

## Notes

- Reference: `REFACTOR.md` §20 (capability profiles), §7.7 (representability), §45 (success
  criteria — `targets/<t>/` material, native adapters as platform/target artifacts, homes for
  idiom catalogues / adapter specs / binding docs / conformance reports). `CONTEXT.md` for the
  hermetic per-target isolation + trampoline model the four live targets already embody.
- The four live targets each already ship VM-verified bindings (racket/chez/gerbil/sbcl); ws6
  **reshapes their homes + adds the authored target-model layer over them** — it does not re-port
  them. Per-target richness is affordable because the LLM makes it so
  ([[maximize_target_idiom_and_perf]]).

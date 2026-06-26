# app-model-k62 — brief

**Kind:** planning

## Goal

Open **workstream 7** of the `structural-refactoring` grove (root brief decomposition #7):
the **app model** under `apps/macos/` — the common, target-independent **app-specs** that
every target's implementation is checked against (REFACTOR.md §15 / §7.8). This is a
**planning** leaf: grill the ws7 design with the user, raise ADRs / a PRD where decisions
are genuine agreement points, update `CONTEXT.md` inline as the app-model vocabulary
resolves, and **decompose into a node** (`leaf-decompose`) — doing only the first child this
session.

The app-specs already exist as co-located prose (`apps/macos/<app>/docs/{spec,learnings,
test-strategy}.md`, relocated by `co-locate-docs-k9`); ws7 **promotes them to a first-class,
authored entity** and finalizes the structure. The per-target **app-implementations** already
exist and are VM-verified (`targets/<t>/app-implementations/<platform>/<app>/`) — ws7 does
**not** re-author them; it authors the shared spec they all realize.

## Context (root brief #7 + the consuming seams promoted from ws3/ws4/ws6)

The seams ws7 must honour, already settled:

- **An app-spec *names* its app-kind (ws4 D2 seam).** The seven **app-kinds**
  (`cli-tool`/`gui-app`/`menu-bar-daemon`/`launch-agent`/`spotlight-importer`/
  `quicklook-extension`/`finder-sync-extension`) are a distinct authored registry at
  `platforms/macos/app-kinds/` (ADR-0049). Three **orthogonal axes** share only the
  authored-registry mechanism: **app-kind** (platform category) vs **app-spec** (a concrete
  app that *names* its kind — ws7) vs **pattern-kind** (API-usage — ws3). An app-spec is the
  *instance* side of the category↔instance relation with app-kind.
- **App-implementations are ws6's; the spec is ws7's (ws6 seam).** The per-target
  implementations live at `targets/<t>/app-implementations/<platform>/<app>/` and already
  ship (the VM-verified sample apps); ws6 homes the conformance *report* over them. ws7
  authors the **one** target-independent spec at `apps/macos/<app>/` that all four targets'
  implementations are checked against — kept **projection-free** (the same spec drives
  racket/chez/gerbil/sbcl and future targets alike, §45.11), mirroring the platform-model's
  "states what the API *means*, never how a target expresses it" rule.
- **The spec is already a bundler input.** The four bundlers read each app's display name
  from `apps/macos/<app>/docs/spec.md`'s first H1 (`bundler-reshape-k61`). Whatever ws7 makes
  the spec, that read (or its replacement) must keep working.
- **ws8 owns the machine schema (standing seam).** ws7 may author the AppSpec `.apiw` KDL
  Schema + a focused in-crate validator; the **machine JSON Schema** for any derived AppSpec
  artifact + validation tooling/CI stay **ws8's** (the ws2/3/4/5/6 mirror).
- **ws9 owns execution.** ws9 owns the multi-layer test model (§33) + the TestAnyware/AppSpec
  runner (§34) that drives a spec against a *running* target binding; ws7 **declares** the
  behavioural exemplar (§7.8), it does not build the runner (the declare-now/execute-later
  seam, the ws4 D3 mirror).
- **Goldens-as-truth remains the gate.** ws7 is spec authoring, not an emit change — a moved
  emit golden is a bug unless a child *intends* it (and then it is deliberate).

Current state: `apps/macos/` holds nine app dirs (`hello-window`, `ui-controls-gallery`,
`scenekit-viewer`, `pdfkit-viewer`, `mini-browser`, `note-editor`, `drawing-canvas`,
`swift-native-probe`, …) each with `docs/{spec,learnings,test-strategy}.md`, plus
`apps/macos/docs/` (the portfolio index + design). `apps/macos/README.md` records the ws7
TODO: "promote each `spec.md` to a first-class AppSpec, split spec vs. implementation-notes,
and reconcile the co-located per-app docs with the per-target implementations."

## Grilling agenda (one question at a time — propose a recommended answer for each)

Open threads to settle before decomposing (not exhaustive — grove is for incremental
discovery):

- **The app-spec entity.** Is the AppSpec an authored `.apiw` entity (like target/platform/
  pattern-kind), the existing prose `spec.md`, or a pairing (authored `.apiw` spec + prose
  rationale)? What fields does it carry (app-kind ref, behavioural exemplar / acceptance
  criteria §7.8, required APIs / pattern-kinds, fixtures), and what is authored vs derived?
- **Spec vs implementation-notes split.** Today `spec.md` mixes the target-independent
  exemplar with per-app realization. Where does the projection-free spec end and the
  per-target `learnings.md` (already under `app-implementations/`) begin?
- **The app-kind ↔ app-spec binding.** How an app-spec names its app-kind, and how the
  cross-field validity (does the app's behaviour fit its declared kind's process/run-loop/
  activation truth?) is checked — mirroring ws4's focused app-kind validator.
- **Skeleton-first sequencing.** What buildable-at-every-step order does ws7 take (mirrors
  the root D4 discipline)? Likely: the AppSpec entity + schema + one app first, then the
  portfolio, then the conformance/coverage tie-in.
- **ws8/ws9 boundaries.** Confirm AppSpec machine-JSON-Schema is ws8's; the AppSpec *runner*
  is ws9's; ws7 declares + schema-validates only.

## Status — grilled & decomposed (2026-06-26)

Design converged (see **Decisions** running log: D1, D2, D2′, D3, D5). This node is
the `app-model-k62` workstream; children materialize lazily (do **not** pre-spawn).

## Node done when (ws7 complete)

- The **foundation** is in place: `apps/macos/` defines the APIAnyware↔AppSpec↔TestAnyware
  relationship + data boundary (**ADR-0052**); `CONTEXT.md` carries the reconciled
  app-model vocabulary (AppSpec project + App/impl/scenario/scenario-suite/contract +
  reverse/forward-gen; the 3 "AppSpec" meanings disambiguated).
- The **reverse-gen workflow** is proven: at least one sample app has an LLM-generated,
  human-validated spec/PRD derived from its existing impl.
- The **AppSpec grove is built** (seed/PRD authored, grove initialized in
  `~/Development/AppSpec`), and a **pause-point** leaf marks the hand-off.
- Cross-grove **seeds** delivered (reverse/forward-gen, spec format, patterns/attack-vector
  interface).
- *(Post-pause, deferred — may become follow-on leaves or a later grove):* forward-gen
  suites + AppSpec-runner VM-verify for the apps; finalize the `apps/macos/` file layout
  once AppSpec's format firms; portfolio index + coverage tie-in.

## Children (materialized lazily — only the live ones exist on disk)

1. **`appspec-foundation-k63`** *(live, first child)* — the foundation: ADR-0052, the
   `CONTEXT.md` glossary reconcile, and the `apps/README.md` + `apps/macos/README.md`
   rewrite defining the boundary/relationship + the generated-spec model. Format-flexible;
   no per-app churn, no bundler change (keep `spec.md`). Skeleton-first.
2. *(next, add on retirement of k63)* — **reverse-gen exemplar**: LLM-generate
   hello-window's spec/PRD from its existing impl, human-validated; the worked template.
3. *(later)* — **build the AppSpec grove**: author the toolkit seed/PRD (D2′ vision),
   initialize the grove in `~/Development/AppSpec`, deliver the cross-grove seeds.
4. *(later)* — **pause point**: hand off to / run the AppSpec grove; resume after.
5. *(post-pause, deferred)* — forward-gen suites + VM-verify; layout finalize; portfolio.

## Decisions (running log)

Captured inline as each grilling question settles (driving.md running-log habit).

### Exploration findings (2026-06-26 — reframes the brief's core assumption)

The brief presumed an AppSpec would be a *grove-native* `.apiw` KDL entity with a
ws8 schema. Exploration + a user steer reveal an **established external project**
that already owns this concept:

- **`~/Development/AppSpec` is a real sibling project** (git remote
  `Linkuistics/AppSpec`), driven as its own grove. It is *"the single
  authoritative operational specification of an app's behaviour, written once and
  verified against every implementation end-to-end in a live macOS VM."* It owns:
  a **`#lang app-spec`** Racket DSL (scenarios authored as language source,
  ADR-0002), a **harness / driver / runner** (`runner/main.rkt`, `run.sh`) that
  installs a driver + executes scenarios, a **`testanyware-sdk`** that drives the
  live macOS VM through the `testanyware` CLI, and a **three-tier verification
  strategy** (hermetic unit → null-impl meaningful-failure smoke → live-VM
  shakedown, ADR-0004).
- **Its vocabulary is precise** (AppSpec `CONTEXT.md`): **App** (a native UI app,
  build-independent) · **Implementation/impl** (a concrete build under test,
  `--impl`; *avoid "target"*) · **Scenario** (one verifiable behaviour, a
  `#lang app-spec` file, impl-agnostic) · **Scenario suite** (an app's scenarios,
  colocated under `APIAnyware-MacOS/.../apps/<app>/scenarios/`) · **Contract**
  (conformance reqs every impl must satisfy — `logging-contract.md` +
  `observable-state.md`, which double as the porting guide) · **Driver / Harness /
  Runner**.
- **REFACTOR §34 already designates this as external + consumed:**
  `~/Development/AppSpec` for *target-independent app descriptions*,
  `~/Development/TestAnyware` for *behavioural/GUI test scripts*, and "APIAnyware
  should **consume or reference** these systems where appropriate." The LLM loop
  §34 spells out (read spec → read binding docs + idiom catalogue → generate impl →
  build → run TestAnyware → inspect → patch → repeat) **is** the user's stated
  vision (a spec detailed enough for an LLM to build the app in any language with
  testing as perfect feedback). §33 layer 8 = "AppSpec sample app tests".
- **Path drift the refactor created.** AppSpec's README + CONTEXT cite the
  *pre-refactor* homes: scenario suites at `APIAnyware-MacOS/knowledge/apps/<app>/`
  and per-impl `--impl` configs at `generation/targets/racket-oo/apps/<app>/`. The
  grove moved per-app prose docs to `apps/macos/<app>/docs/` (co-locate-docs-k9)
  and targets to `targets/<t>/`. Only **modaliser** has real scenario suites
  (`knowledge/apps/modaliser/`, on `main`); the grove's 9 sample apps have prose
  `spec.md` only (no `#lang app-spec` suites yet).
- **Three colliding "AppSpec" meanings to reconcile in the glossary:** (1) the
  external **AppSpec project** (the authority); (2) the grove briefs' loose use of
  "AppSpec" for "the common app-spec entity"; (3) the bundler Rust struct
  `apianyware_bundle_racket::AppSpec` (Info.plist/signing bundle config — unrelated).

Net: ws7 is **not** inventing a fresh `.apiw` AppSpec from scratch; it is homing /
referencing the **external AppSpec project's** app descriptions under
`apps/macos/<app>/`, reconciling them with the co-located prose, and (open) deciding
whether a thin grove-native structural manifest sits alongside. The grilling below
settles the relationship.

### D1 — Ownership: home + reference the external format (settled 2026-06-26)

**`apps/macos/<app>/` homes each app's target-independent AppSpec in the external
AppSpec project's own format; the grove does not reinvent it.** Each app dir holds
the **`#lang app-spec` scenario suite** (`scenarios/`), the per-app **contracts**
(`logging-contract.md` + `observable-state.md` — the porting guide every impl
satisfies), and a prose **description** (`docs/`). The external AppSpec runner
(`~/Development/AppSpec`) consumes this path over TestAnyware; **`#lang app-spec`
stays authoritative** and is **not** re-expressed as `.apiw`. **ws8 does not
schema-validate `#lang app-spec`** (the AppSpec project owns its reader/validation).

Consequences (collapses much of the brief's presumed scope):
- **No grove-native `.apiw` AppSpec entity, no `app.apiw` KDL schema, no focused
  in-crate validator crate.** The brief's "ws7 may author the AppSpec `.apiw` KDL
  Schema + validator" presumption is **dropped** — superseded by D1. ws7 is a
  *structural homing + reconciliation* workstream, not an entity-authoring one.
- ws7 **relocates** modaliser's scenario suite out of `knowledge/apps/modaliser/`
  into `apps/macos/modaliser/` and **repoints** the external AppSpec project's path
  references (`knowledge/apps/<app>/` → `apps/macos/<app>/`; per-impl `--impl`
  configs `generation/targets/racket-oo/` → `targets/<t>/app-implementations/...`).
  Changes *inside* the external AppSpec repo are seeded to the **AppSpec grove**
  (cross-grove inbox), not made by this grove — boundary confirmed in Q-boundary.
- The grove's 9 sample apps currently have prose `spec.md` only; promoting them to
  full `#lang app-spec` suites (the user's "detailed enough for LLM-build" vision)
  is the bulk of ws7's authoring.

### D2 — Scope: structure + full scenario suites for all sample apps (settled 2026-06-26)

**ws7's write-scope is the largest option: establish the AppSpec home structure +
relationship + reconciliation, AND author complete `#lang app-spec` scenario suites
for every sample app, each per-app live-VM-verified.** This realizes the user's
"perfect feedback / LLM-buildable in any language" vision in full (REFACTOR §34).

Finding: `knowledge/` in the main repo is **entirely untracked** — there are **no
committed scenario suites anywhere** in APIAnyware-MacOS today (AppSpec's `run.sh`
defaults to `../APIAnyware-MacOS/knowledge/apps/modaliser/scenarios/`, a dangling
path). So suite-authoring is greenfield, not relocation.

Decomposition implication (grove is for exactly this — a large effort split into
small VM-verified-per-app leaves; standing rule [[vm_verify_every_app]]):
- **Child 1 (this session): the structure/foundation** — the `apps/macos/` AppSpec
  layout + README defining the consume/reference relationship, prose reconciliation
  (`spec.md` → description; learnings → per-target impl-notes seam), glossary
  reconcile (adopt AppSpec vocab; flag the 3 "AppSpec" meanings), bundler
  display-name read repointed, external path-ref reconciliation. Skeleton-first: no
  suite yet.
- **Child 2: hello-window** — the first full `#lang app-spec` suite + contracts +
  live-VM-verify, the worked exemplar/template that proves the structure.
- **Children 3..N: one per remaining app** — full suite + contracts + VM-verify each
  (a leaf carries the VM-verify done-bar; CLI smoke never satisfies it).
- **Final child: portfolio index + conformance/coverage tie-in.**

### D3 — No machine manifest; structural facts as prose (settled 2026-06-26)

**No grove-native machine manifest.** The grove-domain structural facts — the
app↔app-kind binding (ADR-0049 instance side), the exercised pattern-kinds
(semantic coverage), the display-name — live in the **description prose** (a small
structured header in `docs/overview.md`). The **bundler reads the display-name from
the description's first H1** (as today, just repointed off `spec.md`). A machine
`app.apiw` manifest is **deferred** (constraint 4 — lazy): authored as its own leaf
only IF a real machine consumer materializes (e.g. the bundler projecting bundle
*type* from app-kind per ADR-0049, or `apianyware-conformance` computing pattern
coverage). Honors D1 (don't reinvent in `.apiw` without need).

### D2′ — REVISED: AppSpec is an external LLM-driven toolkit; the spec is *generated*, not hand-authored (settled 2026-06-26)

Two user steers reshaped D2. AppSpec (the project) is meant to be a **human-in-the-loop,
LLM-driven toolkit** with three capabilities (and **holds no app data**):
1. **reverse-gen** — point at an arbitrary app/impl → generate description/spec/PRD
   docs detailed enough to *reliably replicate* it (LLM-driven, human-annotated);
2. **forward-gen** — specs + best-practice guidelines + attack-vectors + patterns/
   anti-patterns → test suites that *correlate with* the specs (human-validated);
3. **run** — replay suites against any impl in a live VM (TestAnyware).
AppSpec will be *"largely dominated by prompts and workflows, rather than a lot of
coding of tools."* This mirrors APIAnyware's own **ws5 LLM side-channel** philosophy
(git is the propose→review→accept boundary; regenerable, annotated artifacts).

**Three-layer boundary:** **TestAnyware** (VM substrate) → **AppSpec** (LLM-driven
spec/test toolkit + formats, no app data) → **APIAnyware** `apps/macos/<app>/` (the
generated+annotated description/spec/PRD + generated+validated suites + contracts;
impls in `targets/<t>/app-implementations/`).

So the **earlier "all 9 suites" answer (D2) is superseded:** hand-authoring suites is
authoring the generator's *output* by hand. The durable human-adjacent artifact is the
**spec/PRD, LLM-generated from the existing implementation and human-validated** — and
this is do-able *now* in Claude Code (the LLM-driven tooling that already exists; the
standing economic constraint that LLM annotation runs inside Claude Code,
[[llm_annotation_constraint]]).

### D5 — ws7 is deliberately minimal; it builds the AppSpec grove + a pause point (settled 2026-06-26)

ws7 in *this* grove is deliberately minimal — it does **not** finalize a rigid
`apps/macos/` file format (that depends on what AppSpec settles a "formal spec" to be).
Its deliverables:
- **Foundation** — establish `apps/macos/` as the AppSpec-data home + the
  consume/reference **relationship** + the **data boundary** (ADR) + the reconciled
  **glossary**; keep it format-flexible. Bundler display-name read unchanged for now
  (keep `spec.md`; no premature rename → zero bundler churn).
- **Reverse-gen bootstrap** — LLM-generate the spec/PRD for the sample apps from their
  existing VM-verified impls (human-validated), starting with one worked exemplar that
  de-risks the AppSpec format.
- **Build the AppSpec grove** — author the AppSpec-toolkit seed/PRD (the D2′ vision)
  and seed/initialize the grove in `~/Development/AppSpec` (cross-grove via the
  `grove-meta` inbox). The AppSpec grove will be *"largely prompts + workflows."*
- **Pause point** — an ordinary leaf whose work is the hand-off: pause
  structural-refactoring, run the AppSpec grove to completion, resume here.
- **Deferred (post-pause)** — forward-gen test suites + AppSpec-runner VM-verify
  (depend on AppSpec tooling); finalize the `apps/macos/` layout once the format firms;
  the portfolio index + coverage tie-in.
- **Seeds to the AppSpec grove** — the generalized reverse/forward-gen, the spec/PRD
  format(s), and the **patterns/attack-vectors/guidelines interface** (which overlaps
  APIAnyware's own `semantic/pattern-kinds`, ws3 — flagged, not resolved here).

**ADR-0052** records the load-bearing decision (external toolkit + data boundary + no
grove-native `.apiw` AppSpec entity + the generated-spec model).

### Q4 finding — spec/impl-notes split is already largely correct (codebase-answered)

Exploration (not a user question — grilling.md "explore instead"): the split the
brief flagged is mostly already done. `apps/macos/<app>/docs/learnings.md` is
explicitly *"App-Universal Learnings — discoveries that apply regardless of which
target implements it"* (**target-independent → stays in `apps/`**);
`test-strategy.md` is a **TestAnyware validation checklist** (a prose precursor the
`#lang app-spec` scenario suite formalizes); and **per-target `learnings.md` already
exist** at `targets/<t>/app-implementations/macos/<app>/learnings.md` (ws6 homed the
realization notes). So ws7's reconciliation is a *mapping*, not a re-split:
`spec.md` → projection-free description; `test-strategy.md` → the scenario suite +
human expected-behaviour; app-universal `learnings.md` → kept. Per-target notes need
no move.

## Notes

- Reference: `REFACTOR.md` §15 (common app specs), §7.8 (behavioural exemplar), §45.11
  (projection-free, one spec drives all targets); ADR-0049 (app-kinds, the category ws7's
  app-specs instantiate); the existing `apps/macos/<app>/docs/` material + `apps/macos/docs/`
  portfolio; the root brief **Platform-model outcomes** (ws7 seam) + **Target-model outcomes**
  (ws7 seam).
- The four targets each already ship VM-verified app-implementations; ws7 authors the **shared
  spec over them** + finalizes the structure — it does not re-port them.
- **Scope discipline:** ws7 is the *common* app-spec layer (`apps/macos/`). Per-target
  app-implementation work is ws6's (done); the AppSpec machine schema is ws8's; the AppSpec
  runner is ws9's. If runner or schema-tooling work surfaces, externalize it to its owning
  workstream, don't absorb it.

# platform-model-k32 — brief

**Kind:** planning

## Goal

**Workstream 4** of the `structural-refactoring` grove: realize the **platform
model** under `platforms/macos/` — the source-platform semantic specifications
(REFACTOR §13/§14), the **app-kinds**, and the platform-level semantic tests.
This is a **planning leaf**: it opens with a grilling session to settle the
platform-model design, then **decomposes** the tree into build children (do the
**first child only** this session). Do not pre-author the model — grill first.

## Context (inherited — see `grove-llm brief-chain`)

- **Spine ws1–ws3 complete.** The five-domain skeleton (ws1), the `.apiw` DSL +
  per-family triad (ws2), and the first-class semantic pattern-kind/instance
  model (ws3) all landed. Crucially, **ws2's `pipeline-cutover-k20` already did
  the IR relocation** `analysis/ir/` → per-family
  `platforms/macos/api/<Framework>/{extracted.json, annotations.apiw,
  resolved.json}` — so the per-family triad **physically exists** for all 153
  families (see the `platforms/macos/api/` tree). ws4 builds the platform model
  *around* that existing triad; it does not move the IR again.
- **ws3 instances land here.** Pattern-**instances** are carried in
  `platforms/macos/api/<F>/resolved.json` (ws3's D1) — that carriage is ws4's
  platform-side neighbour. The platform model is where macOS-specific knowledge
  lives (the kind/instance split keeps `semantic/` universal).
- **REFACTOR.md (source of truth):** **§13** *Source platform semantic
  specifications*, **§14** *Platform directory structure*, §7.3 *App specs are
  common*, §7.7 *Representability must be explicit* (mind the ws6 boundary —
  target capability is §20/ws6). §29 *Specification format* (ws2 settled the
  `.apiw`/triad mechanics this reuses).
- **Placeholders to discharge (ws4 markers, TODO.md row 4):**
  `platforms/README.md`, `platforms/macos/README.md`,
  `platforms/macos/api/README.md`, `platforms/macos/app-kinds/README.md`,
  `platforms/macos/docs/README.md`, `platforms/macos/tests/README.md`.
- **Glossary:** `CONTEXT.md` (read every session) — add platform-model terms as
  they resolve (platform spec, app-kind, platform-level metadata, the
  platform/semantic boundary).

## Grilling agenda (open questions to settle — recommend, don't dictate)

These are the seams to interview through; the grilling settles them one at a time.

- **Platform-level metadata.** Is there a `platform.yaml` (or `.apiw`) describing
  the macOS platform itself — SDK/deployment floor, framework roster, family
  dependency graph — distinct from per-family specs? What does it carry, and what
  is derived vs. authored?
- **App-kinds.** What *is* a platform app-kind (a document-based app, a
  menu-bar/agent app, a single-window app, …)? How does it relate to ws7's common
  **app-specs** (`apps/macos/<app>/`) and to ws3's semantic **pattern-kinds**
  (same authored-registry shape, or different)? Where does it live?
- **Platform-level semantic tests.** What does ws4 own vs. ws9 (the multi-layer
  *testing architecture*, §33/§34)? Likely: ws4 authors the platform-semantic
  fixtures/expectations; ws9 owns the cross-cutting test model + TestAnyware/
  AppSpec integration. Pin the boundary.
- **Directory structure (§14).** Confirm/extend the `platforms/macos/` layout so
  it absorbs a second platform (Linux/.NET) without redesign — the grove's
  platform-neutrality success criterion (§45).
- **Representability boundary.** §7.7 wants representability explicit; settle
  whether any platform-side representability metadata is ws4's, or whether it is
  wholly a target-capability concern (ws6/§20). (The semantic docs already
  attribute the representability *model* to ws6 — confirm or correct.)

## Done when

- The platform-model design is **settled** (grilling complete; running decision
  log in this brief, terms in `CONTEXT.md`, ADRs raised *sparingly*, a PRD at a
  genuine agreement point if one is warranted).
- The leaf is **decomposed** into a node (`leaf-decompose`) with ordered,
  buildable, goldens-green build children — and the **first child** is authored
  and executed **this session** (the rest grow lazily as earlier ones retire).

## Notes (steers)

- **Planning task.** Grill one question at a time, propose a recommended answer
  for each, walk the design tree to shared understanding (`grilling.md`,
  `driving.md`). Commission a prior-art / fresh-context research leaf if a seam
  warrants it.
- **Lazy decomposition.** Do **not** pre-spawn all of ws4's children — grow as
  earlier ones retire (root brief). Skeleton-first (D4): every child buildable +
  goldens-green.
- **Seams to respect:** ws6 (target model) consumes platform specs but owns
  projection + capability profiles; ws7 (apps) owns the common app-specs +
  per-target app-implementations; ws9 owns the testing architecture. Keep ws4 to
  the *platform* model. The macOS material under `platforms/macos/` must stay
  platform-specific, not target- or projection-flavoured (the domain rule).
- After ws4's last child retires, the retire-cascade asks before treating
  workstream 4 done, then ws5 grows next (root brief decomposition).

## Decisions (running log)

Captured inline as each grilling question settles (driving.md running-log habit).

### D1 — Platform manifest: small authored `platform.apiw`, policy-only

A single authored manifest **`platforms/macos/platform.apiw`** (KDL, **not**
`platform.yaml` — ADR-0046 killed YAML; authored overlays are `.apiw`, machine
files JSON). It carries only the genuinely *authored policy* facts:

- `sdk` (e.g. `macosx`) and `deployment-target` floor — a real policy choice;
- the framework roster as a curated **include / ignore policy** (the ignore-list
  is an authored decision, cf. the post-M9 "framework ignore list" steer), **not**
  the resolved list.

The **resolved roster** (`ls api/`) and the **cross-family dependency graph** stay
*derived and uncommitted* — recomputable from the `api/<F>/` triad, so committing
them would duplicate derivable facts and rot (constraint 4; "keep carriage minimal"
k26 steer). Deviation from REFACTOR §14's literal `platform.yaml` is justified by
ADR-0046 and is glossary-worthy, not its own ADR (it *applies* an existing decision
rather than making a new hard-to-reverse one).

### D2 — App-kinds: distinct entity, own platform-domain crate

An app-kind is **macOS process-model truth** (entry/run-loop/termination model,
bundle type + required Info.plist keys + `LSUIElement`/extension-point identifiers,
test obligations) — a *distinct entity*, not a pattern-kind. It gets its **own
authored `.apiw` registry** (`platforms/macos/app-kinds/<kind>/kind.apiw` + `docs/`)
parsed/validated by a **new crate `platforms/macos/tools/app-kinds`** (crate-home
convention keeps platform truth in the platforms domain). The crate **mirrors the
`apianyware-patterns` mechanism** (parse + KDL-schema + controlled vocab + focused
validator) without reusing its entity. **Zero projection** in `kind.apiw` (no
"generate racket main"). Relationship axis: app-kind is the platform *category*; a
ws7 app-spec (`apps/macos/<app>/`) *names* its kind; pattern-kinds (ws3, `semantic/`)
are an orthogonal API-usage axis sharing only the authored-registry mechanism.

ws8 seam (mirrors ws3 D7): ws4 authors the app-kind `.apiw` KDL-Schema + the focused
in-crate validator; ws8 still owns machine-JSON schemas + CI validation tooling.

### D3 — Platform tests: ws4 declares + fixtures, ws9 executes

A platform-semantic test splits in two. **ws4 owns** the *declaration* half —
projection-free, target-independent **expectation declarations** (as `.apiw`,
ADR-0046) under `platforms/macos/tests/api-semantics/{ownership,callbacks,threading,
errors}.apiw` + per-app-kind obligations under `tests/app-kinds/<kind>.apiw` — plus
the raw **fixtures** (`tests/fixtures/{pasteboard,spotlight,sample-documents,
sample-images}/`). These are platform truth, **schema-validated (goldens-green) but
NOT executed** in ws4. **ws9 owns** the *execution* half — the multi-layer test model
(§33), the runner, and TestAnyware/AppSpec integration (§34) that drives a declaration
against a *running target binding* in a VM; per-target execution hooks are ws6. Same
declare-now / execute-later seam as ws3→ws8.

### D4 — Representability is wholly ws6; ws4 carries only source weirdness

Confirmed the semantic-docs attribution. The §7.7 statuses (`fully-` /
`conventionally-` / `lossily-represented`, `unsafe-only`, `unsupported`, `research`)
are per **target×platform** → ws6/§20 capability profiles. ws4 carries only the §30
**source-semantic difficulty** vocabulary (ownership/lifetime/threading/error
weirdness: `fork-unsafe`, `may-reenter`, `ownership-unknown`, `requires-message-pump`,
…) — platform truth that ws6 *consumes* to compute a status. **No representability
status or metadata in `platforms/`.** Keeps the domain rule clean (platform = what the
API means, including hard properties; target = how representable that meaning is).

### D5 — Decomposition: four children, skeleton-first; manifest first

ws4 decomposes into four build children (materialized **lazily** — only child 1 now;
the rest grow via `leaf-add` as earlier ones retire):

1. **platform-manifest** *(first, this session)* — author `platform.apiw` (D1) + its
   `.apiw` KDL-Schema + a focused validator; discharge `platforms/README.md` +
   `platforms/macos/README.md`. Smallest/most foundational; sets the authored-`.apiw`
   + focused-validator pattern child 2 mirrors.
2. **app-kinds** — new `platforms/macos/tools/app-kinds` crate (parse+schema+vocab+
   validator) + 7 `kind.apiw` + per-kind `docs/`; discharge `app-kinds/README.md`.
   Candidate ADR (the app-kind model, parallel to ADR-0048) belongs *here*.
3. **platform-tests** — `tests/api-semantics/*.apiw` + `tests/app-kinds/<kind>.apiw`
   + fixtures, schema-validated (not executed); discharge `tests/README.md`.
4. **platform-docs** — `docs/{overview,api-extraction,app-kinds,testing-obligations}.md`;
   discharge `docs/README.md` + finalize `api/README.md`.

**Directory structure (§14) needs no change** — the skeleton already materialized the
platform-neutral `platforms/<platform>/{api,app-kinds,docs,tests,tools}` shape; a second
platform (`linux`/`dotnet`) reuses it. Per-family `api/<F>/docs/` + `README.md` (§14
sketch) stay **lazy** — authored only where a family earns prose, never 153× boilerplate.

**No PRD.** These decisions mostly *apply* existing decisions (ADR-0046 format,
crate-home convention, the domain rule) + confirm boundaries — not a novel model like
ws3's pattern-kind work (which earned ADR-0048 + a PRD). The running log + glossary
suffice; the one candidate ADR (app-kind model) is child 2's.

## Platform-tests outcomes (promoted from `platform-tests-k37` on retirement)

The realized **platform test-declaration model** (D3) — the input the final child
`platform-docs` documents in `testing-obligations.md`. Full prose in
`platforms/macos/tests/README.md`; vocab in `CONTEXT.md` ("api-semantics declaration").

- **Two declaration families, distinct entities sharing only the mechanism** (D6, the
  ADR-0049 precedent), both in one crate `apianyware-platform-tests`
  (`platforms/macos/tools/platform-tests`) as **submodules-per-family**, each contracted
  by its own sibling KDL-Schema under `schemas/spec-format/`:
  - **`tests/app-kinds/<kind>.apiw`** (`app-kind-tests.kdl-schema`) — the obligation
    **bodies** resolving each app-kind's `test-obligation` refs into projection-free
    `expect`ations + the `fixture`s they read. The standing guard cross-resolves every
    body against the `apianyware-app-kinds` registry (no orphan body / unresolved ref).
  - **`tests/api-semantics/<facet>.apiw`** (`api-semantics.kdl-schema`) — per convention
    facet (ownership/callbacks/threading/errors = file stem), the §30 source-weirdness a
    `(receiver, selector)` shape exhibits + the expectations a binding must preserve.
- **§30 weirdness is a facet-conditional controlled vocab** (D7), enforced in the focused
  validator (`api_semantics::vocab`), **not** the schema (KDL-Schema can't state a
  conditional enum) — the facet selects the allowed token set; the §30 table is the
  crate's **own** copy (the platforms domain does not depend on `semantic/`).
- **Fixtures are lazy + assertable** (`fixtures-readme-k41`): authored only where a
  committed declaration references them — `fixtures/sample-documents/sample.txt`
  (quicklook/finder-sync) + `fixtures/spotlight/sample.txt` (spotlight), each a tiny text
  doc with known title/author/body so the ws9 runner can assert *extracted values match
  the fixture*. D5's `pasteboard/` + `sample-images/` skipped (no referrer). A standing
  guard (`every_fixture_ref_resolves`) makes the declaration↔fixture link an invariant.
- **Declare-now / execute-later seam (D3).** ws4 authors + **schema-validates** (never
  executes) the declarations; **ws9** owns the multi-layer test model (§33) + the
  TestAnyware/AppSpec runner (§34) that drives a declaration against a *running* target
  binding; **ws6** owns per-target execution hooks. Mirror of ws3→ws8.

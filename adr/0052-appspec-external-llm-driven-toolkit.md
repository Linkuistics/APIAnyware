# AppSpec is an external LLM-driven spec/test toolkit; APIAnyware consumes it

**Status:** accepted

**Raised by:** `structural-refactoring` grove, workstream 7 (app model,
`appspec-foundation-k63`).

**Relates to:** ADR-0049 (app-kinds as a distinct platform entity — the *category*
side whose *instance* side this workstream was presumed to author), ADR-0050 (the
ws5 LLM side-channel as a lean mechanism over git — the propose→review→accept
philosophy this ADR reuses for app specs), ADR-0046 (spec format / `.apiw`
KDL-everywhere — the convention this ADR deliberately does **not** extend to apps),
ADR-0024/0045 (docs co-located / central ADRs). Supersedes the ws7 brief's presumed
"ws7 authors the AppSpec `.apiw` KDL Schema + a focused in-crate validator" and the
ws8/ws9 seams that presumed a grove-native AppSpec entity.

## Context

REFACTOR §15 requires common, target-independent **app specs** under
`apps/<platform>/<app>/`; §7.8 frames generated apps as behavioural conformance
tests; §16 puts the per-target **implementations** under
`targets/<t>/app-implementations/`; §33 lists "AppSpec sample app tests" as a test
layer. The ws7 brief — written from those sections alone — presumed ws7 would mint a
*grove-native* AppSpec: an authored `.apiw` KDL entity (the **instance** side of
ADR-0049's app-kind **category**), with a ws8 machine schema and a ws9-built runner,
mirroring how ws3/ws4/ws6 each became an authored `.apiw` entity + KDL-Schema +
focused validator.

That presumption is wrong, and a reviewer will ask why. **REFACTOR §34 already names
two external sibling systems** and says APIAnyware should *"consume or reference"*
them: `~/Development/AppSpec` for *target-independent app descriptions* and
`~/Development/TestAnyware` for *behavioural/GUI test scripts*. **The AppSpec project
already exists** (git remote `Linkuistics/AppSpec`, itself driven as a grove): it owns
a `#lang app-spec` scenario DSL, a harness / **Driver** / runner, a `testanyware-sdk`
that drives a live macOS VM, a three-tier verification strategy, and a precise
vocabulary (App / Implementation / Scenario / Scenario suite / Contract). The runner
§34's brief presumed ws9 would build **already exists**; the spec format ws8 was to
schema-validate is `#lang app-spec`, owned **outside** this repo. Re-minting a
grove-native `.apiw` AppSpec would duplicate and fork an established external project.

Three further facts shaped the decision. **(1)** The AppSpec project deliberately
**holds no app data** — its own README states it contains *"only the language,
runner, SDK helpers, config schema, and self-tests"*, with per-app scenario suites +
contracts living downstream in the consumer. **(2)** The intended authoring model is
**LLM-driven, human-in-the-loop**: point at an existing app/implementation →
*reverse-generate* description/spec/PRD docs detailed enough to reliably replicate it
(human-annotated); then *forward-generate* test suites that correlate with those specs
from best-practice guidelines, attack vectors, and patterns/anti-patterns
(human-validated); then run the suites against any implementation. AppSpec will be
*"largely dominated by prompts and workflows, rather than a lot of coding of tools."*
**(3)** That is the same shape as APIAnyware's own ws5 LLM side-channel (ADR-0050):
the LLM proposes, git + a human review and accept, regeneration is idempotent.

## Decision

**AppSpec is an external, LLM-driven spec/test toolkit that APIAnyware *consumes*;
APIAnyware does not reinvent it. The app-specific data lives under `apps/macos/<app>/`;
the toolkit and its formats live in the AppSpec project and hold no app data.**

1. **Three-layer boundary.**
   - **TestAnyware** — the VM-automation *substrate* (VM lifecycle, VNC input,
     screen/OCR/vision, in-guest exec). Knows nothing about apps or specs.
   - **AppSpec** — the *common spec/test toolkit + formats*: the spec/scenario
     language, the harness / Driver / runner, the test-suite generators (reverse-gen
     and forward-gen), the TestAnyware SDK, config + self-tests. **Uses TestAnyware,
     is used by APIAnyware, holds no app-specific data.**
   - **APIAnyware** — owns the *app data*: `apps/macos/<app>/` holds each app's
     generated-and-annotated description/spec/PRD, its generated-and-validated test
     suites, and its contracts; `targets/<t>/app-implementations/<platform>/<app>/`
     holds the implementations under test.

2. **Consume / reference, do not reinvent** (REFACTOR §34). `apps/macos/<app>/` is
   authored against the AppSpec project's format(s) and run by its runner over
   TestAnyware. APIAnyware does not vendor, fork, or re-host the AppSpec toolkit.

3. **No grove-native `.apiw` AppSpec entity, schema, or validator.** This is a
   deliberate asymmetry from the grove's `.apiw`-everywhere convention (ADR-0046) and
   from the ws3/ws4/ws6 authored-entity template: the *concept* of an app
   specification is owned by an external project, so APIAnyware does not mint a
   competing machine entity for it. The ws7 brief's "author the AppSpec `.apiw` Schema
   + validator" line and the ws8 *AppSpec-schema* / ws9 *AppSpec-runner* seams that
   presumed it are withdrawn. Grove-domain *structural* facts an app still carries —
   its app-kind (ADR-0049 instance side), the pattern-kinds it exercises, the
   display-name the bundler reads — stay **prose** in the app's description until a
   real machine consumer needs them; only then is a thin machine manifest authored
   (lazy; constraint 4).

4. **The spec is generated, not hand-authored.** An app's spec/PRD is produced by
   **LLM reverse-generation from an existing implementation, human-validated**, and its
   test suites by **LLM forward-generation from the spec + guidelines + attack-vectors
   + patterns, human-validated** — git is the propose→review→accept boundary, exactly
   as ADR-0050 made it for annotations. Hand-authoring suites would be authoring the
   generator's output by hand.

5. **The AppSpec toolkit is developed in its own grove, at a pause point of this
   grove.** Building it (largely prompts + workflows) is not ws7's code to write;
   ws7 authors the toolkit's seed/PRD, initializes the AppSpec grove
   (`~/Development/AppSpec`) via the cross-grove `grove-meta` inbox, and marks a
   pause-point leaf where structural-refactoring hands off, the AppSpec grove runs,
   and this grove resumes for the parts that depend on it.

## Consequences

- **Domain + project boundary held:** app data lives in APIAnyware; the spec/test
  *tooling and formats* live in AppSpec; the VM substrate lives in TestAnyware. The
  surprising part — that the grove *declines* its own `.apiw`-everywhere convention
  for apps — is the reason this ADR exists.
- **ws7 shrinks and re-aims:** from "author N `.apiw` AppSpecs (+ schema + validator)"
  to "establish the consume/reference relationship + boundary + glossary, bootstrap
  reverse-gen, build the AppSpec grove, mark the pause point." Forward-gen suites +
  AppSpec-runner VM-verify are deferred behind the AppSpec grove.
- **ws8 / ws9 seams adjusted:** ws8 does **not** schema-validate `#lang app-spec` (the
  AppSpec project owns its reader/validation); the AppSpec *runner* is the AppSpec
  project's, not a ws9 build. ws9's testing architecture *references* AppSpec results
  (§33 layer 8) rather than building the runner.
- **The bundler is undisturbed:** the four bundlers keep reading each app's display
  name from the first H1 of its description (`apps/macos/<app>/docs/spec.md` today);
  any later rename is its own scoped change.
- **A cross-project interface to settle later (seed, not resolved here):** AppSpec's
  forward-gen inputs — *patterns / anti-patterns / attack-vectors / guidelines* —
  overlap APIAnyware's own first-class **semantic `pattern-kinds`** (ADR-0048) and
  platform truth (ADR-0049). Whether these are shared entities consumed across the
  boundary or a distinct app-behaviour/security axis is an open interface question
  seeded to the AppSpec grove.
- **Why this clears the ADR bar:** hard-to-reverse (a cross-project boundary, an
  on-disk data placement, the withdrawal of presumed ws7/ws8/ws9 scope), surprising
  (the grove declines its own authored-entity convention), and a real trade-off
  (reinvent a grove-native AppSpec for `.apiw` uniformity vs consume an established
  external project — the project chose consumption).

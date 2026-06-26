# app-model-k62

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

## Done when

The ws7 design is grilled to shared understanding; ADR(s) raised for the load-bearing
decisions (esp. the AppSpec entity shape + the spec/implementation-notes split); `CONTEXT.md`
carries the new app-model vocabulary; and the leaf is **decomposed** into the `app-model-k62`
node with an ordered first child, that first child executed this session.

## Decisions (running log)

Captured inline as each grilling question settles (driving.md running-log habit).

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

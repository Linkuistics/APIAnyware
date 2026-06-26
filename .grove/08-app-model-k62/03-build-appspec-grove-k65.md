# build-appspec-grove-k65

**Kind:** work

## Goal

Stand up the **AppSpec toolkit workstream** as its own grove in `~/Development/AppSpec`
(ADR-0052 step 5; node BRIEF D5/D2′): author the toolkit **seed/PRD** capturing the
three-capability vision — **reverse-gen** (existing app/impl → description/spec/PRD),
**forward-gen** (spec + guidelines + attack-vectors + patterns → suites that correlate
with the spec), **run** (replay suites against any impl in a live VM via TestAnyware) —
and deliver the cross-grove **seeds** APIAnyware owes it. AppSpec is *"largely prompts +
workflows, not coding of tools."*

## Context

- **AppSpec already exists and is already driven as a grove** (exploration finding in the
  node BRIEF; `~/Development/AppSpec/CONTEXT.md` says *"This repo is driven as a grove"*).
  So this leaf does **not** create a grove from nothing — **start by reconciling the
  existing AppSpec grove state** against the D2′ toolkit vision: what's already there
  (`#lang app-spec` DSL, harness/Driver/runner, `testanyware-sdk`, three-tier
  verification), what the toolkit vision adds (the reverse-/forward-gen generators as a
  first-class, prompts+workflows capability), and whether that's a new workstream in the
  *existing* grove or a re-seed of its direction. If real design questions surface,
  **`leaf-decompose` into a planning first-child** (grill the toolkit PRD) rather than
  absorbing.
- **Cross-grove mechanism:** seeds go to the AppSpec grove's **inbox** via
  `grove-llm inbox-add --to=AppSpec ...` on the shared `grove-meta` branch (drained at
  the start of an AppSpec session). This grove does **not** edit the AppSpec repo
  directly (the boundary ADR-0052 / node Q-boundary confirmed); it seeds.
- **The worked exemplar** `apps/macos/hello-window/docs/spec.md` (k64) + the
  **reverse-gen workflow** `apps/macos/docs/reverse-gen-workflow.md` are the **format
  input** to hand over — the AppSpec grove generalizes that bootstrap into the toolkit.

## Seeds to deliver (node BRIEF D5)

- The **reverse-gen / forward-gen** capability shapes (reverse-gen proven by k64; the
  workflow doc is the legible prompt/subagent template).
- The **spec / PRD format(s)** — what a "formal spec" should be (k64's spec is the first
  data point; the AppSpec grove firms the format; `apps/macos/` layout stays
  format-flexible until then).
- The **patterns / attack-vectors / guidelines interface** — AppSpec's forward-gen inputs
  overlap APIAnyware's own first-class `semantic/pattern-kinds` (ADR-0048) + platform
  truth (ADR-0049). ADR-0052 flags this as an **open interface question seeded, not
  resolved here**: shared entities across the boundary vs a distinct app-behaviour/
  security axis.

## Out of scope (externalize)

- **No building the toolkit itself** — that's the AppSpec grove's work (prompts +
  workflows), reached via the *pause point* (next child, k66).
- **No forward-gen suites / VM-verify / portfolio / layout-finalize** — post-pause,
  deferred children.
- **No edits inside the AppSpec repo** beyond what its own grove session does — seed via
  the inbox.

## Done when

The AppSpec toolkit workstream is **seeded and ready to run**: its toolkit seed/PRD is
authored (homed appropriately — likely in the AppSpec repo via its grove, or staged here
and delivered via the inbox), the three cross-grove seeds are delivered to the AppSpec
inbox, and the hand-off is legible enough that the **next child (pause point, k66)** can
run the AppSpec grove to completion and resume here. Commit names `build-appspec-grove-k65`.

## Notes

Reference: ADR-0052 (steps 5 + the open patterns/attack-vectors interface); node `BRIEF.md`
D2′/D5; `~/Development/AppSpec` (`CONTEXT.md` vocabulary + `README.md` + `docs/adr/` +
`docs/specs/2026-04-18-app-spec-design.md` + `docs/plans/2026-04-18-app-spec-v1.md` for
its current state); the k64 exemplar + reverse-gen workflow doc as format input. After
k65, the next child is the **pause point** (k66): hand off to / run the AppSpec grove,
resume after. Post-pause deferred children (forward-gen suites + VM-verify; `apps/macos/`
layout finalize; portfolio index + coverage tie-in) are added on k66's retirement.

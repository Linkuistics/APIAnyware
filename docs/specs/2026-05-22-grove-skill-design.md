# grove — A Skill for Hierarchical, Self-Extending Workstreams

`grove` is a Claude Code skill that drives a long, multi-session project as a
**git-tracked tree of task files** — one task per session, where planning tasks
grow the tree as understanding deepens, and completed branches are retired to an
archive. It is "Linear, but ordered and committed with the code," anchored on a
Domain-Driven Ubiquitous Language, and deliberately *not* a return to
Ravel-style machinery.

## Context

The project's pipeline work was historically driven by the **Ravel-Lite**
work→reflect→triage phase cycle, with per-workstream state under
`LLM_STATE/<name>/`. That machinery was fully retired on 2026-05-22 and
`LLM_STATE/` deleted; workstreams are now tracked by `docs/specs/*-design.md`
plus `docs/superpowers/plans/*`. The racket-oo completion design explicitly left
one decision open: *"choosing the replacement new-target methodology is a
separate decision."* **This spec is that decision.**

A monolithic implementation plan suits work whose shape is known upfront. It
does not suit a project that spans many sessions and many months, where some
steps are *themselves* design or planning steps whose output is *more steps*.
`grove` is the process for that kind of work: a task tree that is decomposed
dynamically, built up as it is walked, and executed one fresh session at a time.

## Goal

A skill that encapsulates a hierarchical, self-extending, git-tracked task-tree
workflow, such that:

- Each unit of work is a self-contained task file, executed in a fresh session.
- Planning tasks decompose work into subtrees on demand — the tree is grown
  lazily, never specified exhaustively upfront.
- A Domain-Driven **Ubiquitous Language** is maintained as a first-class,
  living asset, read at the start of every session.
- Human-facing **PRDs** are produced at agreement points and archived with
  project history.
- The mechanisms stay **open, understandable, and walk-away-able** — the
  explicit anti-goal is recreating the Ravel trap.

## Governing constraints — the spine

These seven rules are non-negotiable. Every later section is subordinate to
them. They exist because Ravel-Lite became brittle and constraining — a form of
lock-in — and `grove` must not repeat that.

1. **Artifacts, not state.** No `phase.md`, no session log, no status files.
   The tree's shape — what `ls` shows — is the *only* state. Git is the history.
2. **Read, don't run.** A session bootstraps by *reading markdown*. There is no
   `pre-work.sh`, no script that must succeed first.
3. **Suggested shape, not enforced schema.** Task files and briefs are freeform
   markdown. Templates are guides; nothing validates them; nothing breaks if one
   is "wrong."
4. **Lazy and optional.** Every artifact — brief, ADR, PRD, glossary entry — is
   created *only when it earns its place*, never *because a step demands it*.
5. **The skill guides, it does not gate.** `grove` never refuses to proceed. A
   task may be done by hand, reordered, or skipped; the skill describes a way of
   working, it does not enforce one.
6. **Walk-away-able.** Delete the `grove` skill — and every skill it depends on —
   and `groves/` is still a legible folder of notes; every durable output
   (glossary, ADRs, PRDs, specs, code) is standard, team-readable, tool-agnostic
   markdown.
7. **One page of rules.** If `grove`'s core loop does not fit on a page, it is
   too complex — cut until it does.

Note on constraint 6: it governs whether the *artifacts* survive the *skill's*
removal — and they do, unconditionally. It says nothing about whether `grove`
itself may depend on other skills. Ravel's fragility was *endogenous* — a state
machine that could corrupt its own state and block work. An ordinary dependency
on a maintained skill is *exogenous* and does not impede work. The two are not
the same kind of risk; constraint 6 does not forbid the dependency below.

## Relationship to `mattpocock/skills`

`grove` is built on Matt Pocock's skills ecosystem
(`github.com/mattpocock/skills`), which already proves out the grilling and
documentation half of this design.

**`grove` depends on `mattpocock/skills` (pinned).** It does not vendor copies.
Rationale:

- **Coexistence.** The people most likely to adopt `grove` already use Matt's
  skills. Vendored copies of his conventions would put two divergent definitions
  of the *same* `CONTEXT.md` in front of them. A dependency keeps one source of
  truth.
- **Improvements.** The repo is actively maintained; vendored copies rot because
  nobody re-syncs them.
- **Separation of concerns.** The grilling / glossary / ADR conventions are
  Matt's domain model of *how to do this work*. `grove` *composes* them; it does
  not *own* them. `grove` owns only the task-tree orchestration.
- **Simplicity (constraint 7).** A depending `grove` is *just the loop*. A
  vendoring `grove` carries ~3 extra pages it must keep coherent.

The one real residual risk — a long project's methodology shifting silently
underfoot — is handled by **pinning**: the exact `mattpocock/skills` commit is
recorded in an ADR (decision **D1** below). Improvements then arrive when the
pin is deliberately bumped, not silently. `grove` must also **fail loudly and
informatively** when the dependency is absent ("`grove` requires
`mattpocock/skills` — install it").

**Adopted from `mattpocock/skills`, by reference (never copied):**

| Convention | Source | Used by `grove` for |
|---|---|---|
| `CONTEXT.md` glossary + `CONTEXT-MAP.md` | `grill-with-docs/CONTEXT-FORMAT.md` | the Ubiquitous Language |
| ADRs in `docs/adr/` | `grill-with-docs/ADR-FORMAT.md` | atomic decisions |
| The grilling procedure | `grill-with-docs`, `grill-me` | planning-task interrogation |

**`grove` owns:** the hierarchical task tree, the `BRIEF.md` node briefing, the
pick→bootstrap→execute→decompose→retire loop, and the in-repo `docs/prd/`
convention (where `grove` diverges from Matt's `to-prd`, which posts to GitHub
issues).

## Artifact taxonomy

Five artifact types. Only one — the task tree — is `grove`-specific and
ephemeral. Everything else is a standard artifact that outlives the process;
that is the anti-lock-in guarantee.

| Artifact | Path | Role | Lifecycle |
|---|---|---|---|
| **Glossary** | `CONTEXT.md` (+ `CONTEXT-MAP.md`) | The Ubiquitous Language — domain vocabulary | Living — never retired |
| **ADRs** | `docs/adr/NNNN-*.md` | Atomic decisions; hard-to-reverse, surprising, real trade-off | Living — never retired |
| **PRDs** | `docs/prd/` | Incremental, human-facing, team-shareable agreement checkpoints | Living (archival) |
| **Design specs** | `docs/specs/*-design.md` | Workstream-level technical design (existing project convention) | Living |
| **Task tree** | `groves/<name>/` | The *process*: hierarchical, self-extending decomposition of work | Retired branch-by-branch to `done/` |

### The Ubiquitous Language

`CONTEXT.md` is the project glossary, in the sense Matt's `CONTEXT-FORMAT.md`
defines: opinionated, terse, one-or-two-sentence definitions, aliases-to-avoid,
**totally devoid of implementation details**. It is the user's
"`UbiquitousLanguage.md`" idea, under Matt's filename — adopting his name is
what makes `grill-with-docs` interoperate.

It exists because the acute failure mode of multi-session LLM work is
**terminology drift**: session 1 coins a term; session 7, with no memory of
session 1, reinvents it under a different name, or reuses the words with a
subtly shifted meaning. The glossary, read at the start of *every* session and
appended to *inline* whenever a term is resolved, is the forcing function
against that. It is load-bearing, not decorative.

### Bounded contexts vs. task-tree nodes — orthogonal

A DDD **bounded context** is a *domain* partition with its own ubiquitous
language. A **task-tree node** is a *process* partition — a group of work. They
are independent axes and must not be conflated:

- The **glossary** is organised by bounded context — one `CONTEXT.md`, or
  several linked by a root `CONTEXT-MAP.md`.
- The **task tree** is organised by decomposition of work — and a node like
  "build the emitter" is *not* a bounded context.

A task-tree node therefore does **not** carry a glossary. It carries a `BRIEF.md`
(below), which is process scaffolding — never a glossary, never a decision log.
This is the distinction that keeps `CONTEXT.md` a glossary "and nothing else."

## The task tree

A **grove** is one task tree, for one workstream, living at `groves/<name>/`.
A **node** is a directory; a **leaf** is a `.md` task file. Numeric prefixes in
tens (`010-`, `020-`, …) order siblings and leave gaps for insertion.

```
CONTEXT.md                          ← project glossary (repo root)
docs/adr/0001-*.md …                ← decisions
docs/prd/0001-*.md …                ← agreement checkpoints
docs/specs/*-design.md              ← workstream technical designs
groves/
  chez-functional/
    BRIEF.md                        ← root brief for this grove
    010-design/
      BRIEF.md                      ← brief for the design branch
      010-seed-glossary.md          ← leaf task
      020-write-design-spec.md      ← leaf task (planning)
    020-build-emitter/
      BRIEF.md
      010-ffi-type-mapper.md
      020-emit-class/               ← a leaf that a planning task decomposed
        BRIEF.md
        010-…md
    done/                           ← retired branches, structure preserved
```

### `BRIEF.md` — the node briefing

Every node carries a `BRIEF.md`. It is the piece `grove` genuinely adds, and it
is neither glossary nor decision log. It records, for its subtree:

- the subtree's goal and done-criteria rollup;
- the decomposition rationale and child ordering;
- **pointers** to the ADRs and glossary terms a session needs — so a session
  reads three ADRs, not fifty.

A `BRIEF.md` is written by the planning task that creates its node. Briefs
inherit root→leaf and are retired *with* their subtree (see Retire).

## The loop

This is `grove` itself, and it fits on a page.

**1 — Pick.** The next task is found by depth-first, prefix-order traversal from
the grove root, skipping `done/`: walk children in numeric order; descend into
directories; the first `.md` leaf reached is the next task.

**2 — Bootstrap.** To execute leaf `groves/W/010-a/020-b/030-task.md`, read, in
order: (a) the glossary — `CONTEXT.md`, or the relevant bounded context's
`CONTEXT.md` via `CONTEXT-MAP.md`; (b) the ADRs cited by the briefs; (c) the
`BRIEF.md` chain root→leaf — `groves/W/BRIEF.md`, then `010-a/BRIEF.md`, then
`010-a/020-b/BRIEF.md`; (d) the task file. That assembled context is the
session's entire mandate — nothing else is assumed.

**3 — Execute.** Do the task (see Task kinds). One task = one session.

**4 — Decompose or retire** as applicable (see Operations).

**5 — Commit.** One task = one focused commit (or a tight set); the message
references the task's path. A retire is part of the completing commit.

### Task kinds

- A **planning task** grills (invoking `grill-with-docs` / `grill-me`), refines
  understanding, updates the glossary *inline*, raises ADRs *sparingly* (Matt's
  three criteria), MAY produce a PRD when the increment is a genuine agreement
  point, and **grows the tree** — writes child `BRIEF.md`s and leaf tasks. Its
  deliverable is tree structure + context, not code.
- A **work task** produces code, docs, or tests. Its deliverable is the artifact
  plus its commit. It may still touch the glossary or raise an ADR if it coins a
  term or makes a recordable decision.

The two kinds share one mechanism — both are leaf `.md` files. A task file
states which kind it is so the session knows its mode.

### Operations

- **Decompose.** A planning task replaces an oversized leaf `NNN-x.md` with a
  node `NNN-x/` containing a `BRIEF.md` and ordered child tasks. Decomposition
  is **lazy** — only when a task is genuinely too big for one focused session.
  The tree is never pre-built deep; it grows just-in-time.
- **Retire.** When a node's last live leaf completes, the executing session
  (a) **promotes** anything still relevant from the node's `BRIEF.md` upward —
  to the parent brief, an ADR, or the glossary; then (b) `mv`s the node into
  `groves/<name>/done/`, preserving its relative path. Durable outcomes already
  live in specs / ADRs / PRDs / glossary / code; the retired branch is the
  process record — archived, not deleted (constraint: archive, never `rm`).

## PRDs

A **PRD** is the human-facing, team-shareable, archival face of a planning
increment. It is produced **lazily** — by a planning task, *when the increment
is a genuine agreement point*, never on a schedule. The flow at such a point is:

> grill → **PRD** (review & agree) → decompose into the task subtree → execute

PRDs live in `docs/prd/`, are committed, and are **never retired** — archived
with project history is their entire purpose. They are the discussion
checkpoints; the task tree is the execution of an agreed PRD. A small increment
may get only a PRD; a large technical workstream may also get a `docs/specs/`
design spec — create whichever earns its place (constraint 4).

`grove` diverges from Matt's `to-prd` here: `to-prd` posts a PRD as a GitHub
issue; `grove` writes it as an in-repo file so it versions with the code.

## The `grove` skill's own files

Following the `mattpocock/skills` layout (a `SKILL.md` plus focused reference
files):

```
grove/
  SKILL.md            ← the loop, the seven constraints, the dependency
  BRIEF-FORMAT.md     ← the BRIEF.md shape (a guide, not a schema)
  TASK-FORMAT.md      ← the task-file shape; the two task kinds
```

`SKILL.md` references Matt's `CONTEXT-FORMAT.md` and `ADR-FORMAT.md` rather than
restating them. The skill stays thin: it is the loop and its conventions, and
nothing more.

## Decisions

Decisions reached during this brainstorm. D1 meets Matt's three ADR criteria and
becomes **ADR-0001** once `docs/adr/` is established (an early task of building
`grove`).

- **D1 — `grove` depends on `mattpocock/skills`, pinned.** It does not vendor.
  Trade-off: a dependency vs. a self-contained skill. Chosen for coexistence,
  upstream improvements, separation of concerns, and a thinner skill; the
  residual "silent drift" risk is bounded by pinning the commit.
- **D2 — The glossary is `CONTEXT.md`** (Matt's convention), repo-root, with
  `CONTEXT-MAP.md` if multiple bounded contexts emerge. This *is* the project's
  Ubiquitous Language asset.
- **D3 — Task trees live in `groves/<name>/`;** nodes carry `BRIEF.md`; numeric
  prefixes in tens order siblings; completed branches retire to `done/`.
- **D4 — PRDs are in-repo** at `docs/prd/`, committed and never retired — a
  deliberate divergence from `to-prd`'s GitHub-issue output.
- **D5 — One task per session.** Predictability over throughput.
- **D6 — Bounded contexts (domain) and task-tree nodes (process) are
  orthogonal.** The glossary is per-bounded-context; `BRIEF.md` is per-node and
  is never a glossary.

## First customer: the `chez-functional` target

Building `grove` is done conventionally — this spec → an implementation plan →
execution. `grove`'s **first use** is the Chez Scheme target, which is genuinely
a many-session effort and the reason this process is needed (Part 2 of the
originating task). The Chez target is therefore delivered *through* `grove`,
as the grove `groves/chez-functional/`.

Its first planning task will (a) seed `CONTEXT.md` by harvesting the dense
latent vocabulary already in `knowledge/` — especially `knowledge/targets/
racket-oo.md` ("emitter", "enriched IR", "runtime-load harness", "delegate
factory", "synthetic pseudo-framework", "binding style", …) — and (b) expand the
Chez design seed below into `docs/specs/2026-05-22-chez-functional-design.md`.

**Chez design seed** — the technical thinking already established in this
brainstorm, preserved as input so it is not lost:

- **Paradigm: Functional** (per the README) → target slug `chez-functional`,
  emitter crate `emit-chez` (already a commented-in workspace member).
- **Implementation:** Chez Scheme 10.4.1 — installed via Homebrew as `chez` /
  `petite`, arm64-native, threaded, with a full FFI.
- **FFI:** Chez's native FFI — `load-shared-object`, `foreign-procedure`,
  `foreign-callable`, `ftype`. There is no `tell`-macro equivalent: every method
  call is a typed `foreign-procedure` over `objc_msgSend`. This collapses
  racket-oo's Tell-vs-TypedMsgSend dispatch duality to a single mechanism.
- **Module system:** R6RS `library` forms, one per generated class/protocol file.
- **Memory model:** wrap ObjC pointers in records; use a Chez **`guardian`** for
  release-on-finalization; **`lock-object`** every `foreign-callable` code object
  so the compacting GC cannot move a pointer handed to C.
- **Dispatch & naming:** receiver-first flat free functions; kebab-case
  identifiers; `make-<class>`, `<class>-<method>`, `<class>?` predicates, `!`
  setters — structurally like racket-oo's generated code.
- **Blocks / delegates / subclassing:** via libobjc plus an `APIAnywareChez`
  Swift dylib (a stub already exists at `swift/Sources/APIAnywareChez/`),
  mirroring racket-oo.
- **Error handling:** match racket-oo — emit `NSError**` methods normally with
  an enrichment comment; no automatic result-or-error wrapper.
- **Scope — Milestone 1 (confirmed with the user):** the first grove covers the
  `emit-chez` crate, the Chez runtime library, the `APIAnywareChez` dylib, CLI
  registration, snapshot + runtime-load harnesses, and non-GUI smoke tests — a
  working, test-verified target with **no sample apps**. Sample apps, bundling,
  and TestAnyware validation are a later grove.
- **Reuse:** the shared `emit` crate wholesale (`code_writer`, `naming`,
  `snapshot_testing`, `test_fixtures`, `binding_style`, …); a new
  `ChezFfiTypeMapper` implementing `FfiTypeMapper`; Chez emit modules mirroring
  the `emit-racket-oo` layout.

## Scope

**In scope (this spec):** the design of the `grove` skill.

**Out of scope:**

- *Building* `grove` — that is the next step, an implementation plan produced
  via `superpowers:writing-plans` and then executed.
- The `chez-functional` target's implementation — downstream, run through
  `grove` once it exists.
- Migrating the existing `racket-oo` workstream onto `grove` — `racket-oo` is
  already tracked by its own spec + plan; a retrofit is a separate, optional
  decision.

## Success criteria

`grove` is done when:

- `grove/SKILL.md` plus `BRIEF-FORMAT.md` and `TASK-FORMAT.md` exist, and the
  core loop fits on one page (constraint 7).
- All seven governing constraints are demonstrably met: no state files; no
  must-run scripts; freeform markdown; lazy artifacts; the skill guides without
  gating; the artifacts are walk-away-able.
- `grove` declares its pinned dependency on `mattpocock/skills` and fails
  loudly and informatively when it is absent.
- A dry run holds: a fresh `groves/<name>/` with a root `BRIEF.md` and one leaf
  task can be picked, bootstrapped, and executed *by reading alone*.
- Full validation follows from `grove`'s first real use — the `chez-functional`
  grove.

## Open questions

Deferred to the build or to the first grilling task; none blocks writing the
implementation plan:

- PRD identifier scheme — sequential `NNNN-` vs. dated. Decide when `docs/prd/`
  is first created.
- Whether APIAnyware-MacOS warrants multiple bounded contexts (Collection /
  Analysis / Generation are candidates) and therefore a `CONTEXT-MAP.md`, or a
  single root `CONTEXT.md`. Resolve in the glossary-seeding task.

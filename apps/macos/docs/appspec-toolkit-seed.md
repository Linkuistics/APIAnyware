# AppSpec toolkit — workstream seed / PRD

**Status:** seed (a propose→review→accept artifact, ADR-0050 philosophy). Authored by
the `structural-refactoring` grove, workstream 7, leaf `build-appspec-grove-k65`
(ADR-0052 step 5). **Not yet accepted into the AppSpec project** — the hand-off into
`~/Development/AppSpec` happens at this grove's **pause point** (leaf k66), where an
AppSpec grove session reviews this seed, homes the durable parts (likely
`~/Development/AppSpec/docs/prd/`), and runs the toolkit workstream.

This document is the **direction-setting seed** for standing up the **AppSpec toolkit
workstream** as its own grove. It exists because APIAnyware *consumes* AppSpec but must
not *build* it (ADR-0052 — the cross-project boundary): APIAnyware can only **seed** the
AppSpec grove with the vision, the reconciliation, and the cross-grove inputs it owes.

**Companion format-inputs (already committed in this repo, hand over alongside):**
- `apps/macos/docs/reverse-gen-workflow.md` — the bootstrap reverse-gen workflow (the
  legible prompt/subagent template the toolkit generalizes).
- `apps/macos/hello-window/docs/spec.md` — the first reverse-generated, human-validated
  spec (leaf `reverse-gen-exemplar-k64`); the **first data point** for "what a formal
  spec is."

---

## 1. Why this seed exists (the boundary)

ADR-0052 fixes a three-layer, three-repo boundary:

```
TestAnyware  →  AppSpec  →  APIAnyware
(VM substrate)  (spec/test   (app data:
                toolkit +     apps/macos/<app>/ +
                formats,      targets/<t>/app-
                no app data)  implementations/)
```

- **APIAnyware owns the app data**, not the toolkit. `apps/macos/<app>/` holds each
  app's generated-and-annotated description/spec/PRD + (eventually) its
  generated-and-validated suites + contracts; the implementations live under
  `targets/<t>/app-implementations/macos/<app>/`.
- **AppSpec owns the toolkit + the formats**, and *holds no app data*.
- This grove (`structural-refactoring`) **does not edit the AppSpec repo directly**
  (node `app-model-k62` Q-boundary). Its only lever on AppSpec is to **seed** — to hand
  this document and the cross-grove seeds (§5) to the AppSpec grove, which then does the
  building. Building the toolkit is *not ws7's code to write*; ws7 sets the direction and
  marks the pause point (ADR-0052 step 5).

So the deliverable here is **legibility, not implementation**: after this seed, an
AppSpec grove session should be able to `root-init` and run the toolkit workstream to
completion with no further input from APIAnyware beyond what is captured here and in the
companion format-inputs.

---

## 2. Reconcile: what the AppSpec project is *today* (the starting substrate)

The node brief mandates *starting by reconciling the existing AppSpec state* against the
toolkit vision. Findings from `~/Development/AppSpec` (commit on `main`, 2026-06-26):

**What already exists and works (v1 — the assets to build *on*, not replace):**

- **`#lang app-spec` scenario DSL** (ADR-0002) — a Racket dialect with domain verbs
  (`scenario`, `press`, `type`, `chord`, `expect-log`, `expect-ocr`, `expect-ax`,
  `expect-running-app`, `expect-file`, `wait-for-*`, `read-mru`, `kill-impl!`,
  `restart-impl!`, …). Scenarios are impl-agnostic programs.
- **`#lang app-spec/impl` config dialect** — a ~10-line per-impl module
  (`#:binary`/`#:config-env`/`#:log-env`/`#:bundle-id`/`#:launch-via`) that wires one
  implementation into the runner as a black box. This *is* the "run any impl" seam.
- **Harness / Driver / runner** (`runner/main.rkt`, `run.sh`; ADR-0003) — loads
  scenarios, installs a Driver, drives per-scenario setup/exec/teardown against a shared
  VM, captures artifacts on failure, prints pass/fail.
- **`testanyware-sdk`** — Racket wrappers over the `testanyware` CLI + agent HTTP
  (`exec`/`input`/`screenshot`/`ocr`/`ax-snapshot`/`macos-helpers`). The TestAnyware seam.
- **Three-tier verification strategy** (ADR-0004) — hermetic unit → null-impl
  meaningful-failure smoke → live-VM shakedown. The null-impl stub (`tests/impls/null.rkt`)
  proves a suite fails meaningfully when nothing is implemented.

**What the toolkit vision *adds* (the new, mostly prompts+workflows):**

- **reverse-gen** and **forward-gen** **generators** — today these do **not** exist in
  AppSpec. v1 scenarios were **hand-authored** for Modaliser. The toolkit makes the spec
  and the suites *LLM-generated, human-validated* (the D2′ pivot). The `run` capability
  is largely the existing runner/SDK/three-tier — reverse-/forward-gen are the net-new.

**What needs *cleanup* to honour ADR-0052 ("AppSpec holds no app data"):**

- AppSpec still carries **Modaliser-coupled app data**: `config/test-config.scm` is a
  Modaliser-specific config; `README.md` / `CONTEXT.md` / the v1 design+plan are written
  almost entirely around Modaliser. ADR-0052 says the toolkit holds *no app data* —
  per-app config/contracts/suites belong downstream in the consumer
  (`apps/macos/<app>/`). De-coupling Modaliser specifics out of the toolkit is part of
  the toolkit workstream (a seeded cleanup, **performed by the AppSpec grove**, not here).
- **Path drift** the refactor created (the toolkit's docs cite *pre-refactor* homes):
  - scenario suites: AppSpec docs say `APIAnyware-MacOS/knowledge/apps/<app>/scenarios/`
    → now **`APIAnyware/apps/macos/<app>/scenarios/`** (`co-locate-docs-k9` moved app
    prose; the refactor renames the repo `APIAnyware-MacOS` → `APIAnyware`).
  - per-impl `--impl` configs: AppSpec docs say
    `APIAnyware-MacOS/generation/targets/racket-oo/apps/<app>/` → now
    **`APIAnyware/targets/<t>/app-implementations/macos/<app>/`**.
  - `run.sh` defaults to `../APIAnyware-MacOS/knowledge/apps/modaliser/scenarios/` — a
    **dangling path** (that tree is untracked / does not exist on `main`).
  These repoints land *inside* the AppSpec repo and so are the AppSpec grove's to make;
  they are **seeded** here (§5), not done here.

**Grove state:** AppSpec's `CONTEXT.md` says *"this repo is driven as a grove,"* but on
`main` there is currently **no live `.grove/` tree and no `grove-meta` branch** — the v1
`finish-app-spec-v1` workstream appears finished and its `.grove/` deleted (grove finish
step 2). So the toolkit is a **new workstream that re-stands-up the AppSpec grove**, built
on the dormant-but-working v1 substrate above — *not* a continuation of a live tree, and
*not* a from-scratch rebuild.

**Net reconciliation:** the toolkit workstream is **additive (reverse-/forward-gen
generators) + cleanup (de-Modaliser the toolkit, repoint paths)** over a working v1
runner/DSL/SDK/three-tier substrate. The `run` capability already substantially exists;
the generators are the new prompts+workflows centre of gravity.

---

## 3. The toolkit vision (D2′ — the three capabilities)

AppSpec is a **human-in-the-loop, LLM-driven toolkit** with three capabilities, *"largely
dominated by prompts and workflows, rather than a lot of coding of tools"* — and it
**holds no app data**:

1. **reverse-gen** — point at an arbitrary app/implementation → LLM-generate
   **description / spec / PRD** docs detailed enough to *reliably replicate* the app in
   any language (human-annotated). The durable human-adjacent artifact is the **spec**,
   not a hand-written suite. *Proven now* by `reverse-gen-exemplar-k64` (the worked
   exemplar + the workflow doc are the format-inputs handed over).
2. **forward-gen** — spec + best-practice **guidelines** + **attack-vectors** +
   **patterns/anti-patterns** → **test suites that correlate with the spec**
   (human-validated). The spec's §10 *Behavioural exemplar* (enumeration of observable
   assertions mapped to runner verbs) is forward-gen's input. Hand-authoring suites would
   be authoring the generator's output by hand (avoid).
3. **run** — replay the suites against any implementation in a live macOS VM via
   TestAnyware. This is largely the **existing** runner / Driver / `testanyware-sdk` /
   three-tier verification — generalized off Modaliser to "any app + any impl."

**Governing philosophy (mirrors APIAnyware ws5, ADR-0050):** the LLM *proposes*, **git is
the propose→review→accept boundary**, a human *accepts by committing the diff*,
regeneration is idempotent. AppSpec is the same shape applied to app specs/suites — which
is exactly why APIAnyware can hand it this seed and trust the toolkit to be built the same
way it builds its own annotation side-channel.

**Deliberately deferred (no premature format lock-in):** AppSpec settles *what a "formal
spec" is* (the spec/PRD format). Until it does, APIAnyware's `apps/macos/<app>/` stays
**format-flexible** (prose `docs/spec.md`; bundlers read the display-name from its first
H1). The k64 exemplar is the **first data point**, not the final format.

---

## 4. Proposed AppSpec grove decomposition (direction for `root-init`)

A *suggested* skeleton-first shape for the AppSpec toolkit workstream — the AppSpec grove
grills and refines this; it is direction, not a frozen plan (grove constraint 4: lazy,
incremental). Skeleton-first = buildable/legible at every step.

1. **Reconcile + re-home (cleanup).** Drain this seed; reconcile the v1 substrate (§2);
   de-couple Modaliser app data out of the toolkit (ADR-0052 "no app data"); repoint the
   path drift (`APIAnyware-MacOS/knowledge/...` and `.../generation/targets/racket-oo/...`
   → the post-refactor homes); fix the dangling `run.sh` default. Update the toolkit's
   `README`/`CONTEXT`/design to the three-capability framing. Establishes the "toolkit
   holds no app data" invariant before any generator work.
2. **reverse-gen capability (prompts+workflows).** Generalize
   `apps/macos/docs/reverse-gen-workflow.md` into AppSpec's first-class reverse-gen
   capability — the prompt/subagent template, the projection-free + bundler-safe-first-H1
   rules, the two-part (spec + modeling-notes) return, the cross-source reconciliation
   discipline (impl source + platform app-kind + precursor prose). Validate against the
   k64 exemplar (must reproduce a spec of equal grade).
3. **spec / PRD format.** Settle *what a formal spec is* — firm the format the k64
   exemplar instances (structural-facts header, §-sections, the §10 behavioural exemplar
   as forward-gen input). Decide the spec↔PRD relationship and the on-disk shape
   `apps/macos/<app>/` should converge to. **This unblocks APIAnyware's `apps/macos/`
   layout-finalize** (a post-pause ws7 child).
4. **forward-gen capability (prompts+workflows).** The generator from spec + guidelines +
   attack-vectors + patterns → `#lang app-spec` suites. Requires the
   patterns/attack-vectors/guidelines interface (§5 seed 3) to be at least scoped.
5. **run generalization.** Generalize the runner/Driver/SDK/three-tier off Modaliser to
   "any app, any impl"; wire the post-refactor `--impl` config homes.
6. **Prove end-to-end on one app.** reverse-gen → (firmed) spec → forward-gen → run a
   live-VM suite for **hello-window** across the four impls (the smallest exemplar). This
   is the toolkit's own acceptance test and the template APIAnyware's post-pause children
   replicate per app.

(The AppSpec grove owns its real decomposition; this is the seed's recommended spine.)

---

## 5. Cross-grove seeds delivered (node BRIEF D5)

The three seeds APIAnyware owes the AppSpec grove. Each is *scoped here, resolved there.*

### Seed 1 — reverse-gen / forward-gen capability shapes

- **reverse-gen** is **proven now** (`reverse-gen-exemplar-k64`). The legible template is
  `apps/macos/docs/reverse-gen-workflow.md`: read all impls → subagent-generate
  (projection-free, bundler-safe first H1, structural-facts header, replication-grade
  coverage, §10 behavioural exemplar, provenance line, two-part return) → human-validate
  by reconciling every cross-impl disagreement and ungrounded claim against an
  authoritative anchor (platform app-kind > prose) → commit (the accept boundary).
- **forward-gen** is **not yet built**; its *input shape* is fixed: the spec's §10
  enumeration of observable assertions already mapped to AppSpec runner verbs
  (`expect-ocr`/`expect-ax`/`expect-running-app`/`expect-log`/`wait-for-*`/`expect-file`;
  inputs `press`/`type`/`chord`/`click-at`/`move-mouse`; state
  `read-mru`/`kill-impl!`/`restart-impl!`). The exemplar's §10 is a worked forward-gen
  input. Open: the guidelines/attack-vectors/patterns side (seed 3).
- **The economic constraint travels with the capability:** LLM-driven generation runs
  *inside Claude Code* (subagents), not via external paid APIs (APIAnyware's standing
  constraint; AppSpec inherits it as the toolkit is "largely prompts + workflows").

### Seed 2 — spec / PRD format(s)

- **First data point:** `apps/macos/hello-window/docs/spec.md` (k64). Its de-facto shape:
  a bundler-safe `# <Display Name>` H1, an italic provenance line, then numbered sections
  — **§1 Structural facts** (app-kind ref, display name, complexity, API frameworks,
  pattern-kinds exercised, native units), §2 purpose, §3 app-kind & lifecycle, §4 window,
  §5 controls, §6 menu, §7 API surface (a table of Objective-C selectors — platform truth,
  projection-free), §8 API-usage patterns, §9 observable outcomes & accessibility, **§10
  Behavioural exemplar** (the forward-gen input).
- **Format is APIAnyware-flexible until AppSpec firms it.** APIAnyware deliberately did
  **not** lock a rigid `apps/macos/<app>/` layout or mint a machine manifest (ADR-0052 D3:
  structural facts stay prose until a real machine consumer needs them). AppSpec decides
  what a "formal spec" is; APIAnyware's layout-finalize is a *post-pause* child gated on
  that decision.
- **Constraint that must survive any format change:** the **bundlers read the app
  display-name from the spec's first H1** (`bundler-reshape-k61`). Whatever AppSpec makes
  the canonical spec, that read (or its agreed replacement) must keep working — flagged so
  the AppSpec format decision doesn't silently break APIAnyware's four bundlers.
- **spec vs impl-notes split is already correct** (no re-split owed): `apps/macos/<app>/`
  holds the **target-independent** description + app-universal `learnings.md`; per-target
  realization notes already live at
  `targets/<t>/app-implementations/macos/<app>/learnings.md` (ws6). AppSpec format work
  need not re-partition these.

### Seed 3 — the patterns / attack-vectors / guidelines interface (open question — seeded, not resolved)

forward-gen's inputs — *patterns / anti-patterns / attack-vectors / best-practice
guidelines* — **overlap APIAnyware's own first-class entities**:

- **`semantic/pattern-kinds`** (ADR-0048) — authored API-usage pattern-kinds (roles +
  laws, framework- and target-independent). The k64 spec's §1 already names the
  pattern-kinds an app *exercises* (object-lifecycle, property-configuration,
  class-method-factory, value-type-geometry, option-set, view-composition, menu
  object-graph, run-loop entry).
- **`platforms/macos/app-kinds`** (ADR-0049) — platform process/run-loop/termination/
  activation truth (the authoritative anchor reverse-gen reconciles against).

**The open interface question (for the AppSpec grove to resolve):** are AppSpec's
forward-gen pattern/attack-vector inputs the **same entities consumed across the
boundary** (AppSpec reads APIAnyware's `semantic/pattern-kinds` + `app-kinds`), or a
**distinct app-behaviour/security axis** (AppSpec authors its own
attack-vector/guideline catalogue, with at most a *mapping* to APIAnyware's API-usage
pattern-kinds)?

- *Note the axis mismatch:* APIAnyware's pattern-kinds are **API-usage** patterns
  (how an app uses a framework's objects); AppSpec's forward-gen wants **behavioural +
  security** patterns (what to test, how an app can be misused/attacked). These may be
  genuinely orthogonal — sharing a *reference*, not an entity.
- **Recommendation (seed, not decision):** keep them **distinct** with an explicit
  mapping — AppSpec authors the attack-vector/guideline axis; where a behavioural test
  exercises an API-usage pattern-kind, AppSpec *references* APIAnyware's `pattern-kinds`
  by id rather than re-authoring it. This preserves each project's single source of truth
  and the ADR-0052 boundary. The AppSpec grove makes the call.

---

## 6. Hand-off mechanism + the `inbox-add` tooling gap (honesty note)

ADR-0052 step 5 and the node brief assumed seeds travel via
`grove-llm inbox-add --to=AppSpec` onto a shared `grove-meta` branch, drained at the
start of an AppSpec session. **That subcommand does not exist** in the installed
`grove-llm` (its verbs are `root-init`/`pick`/`brief-chain`/`resolve`/`leaf-*`/
`complete`), and **no `grove-meta` branch exists** in either repo. The inbox/seed/drain
mechanism is AppSpec-`CONTEXT.md` *vocabulary*, not backed by tooling; the core grove
skill has no inbox concept either.

**Resolution (chosen for legibility + the ADR-0052 boundary):** the seed is **homed
durably in this repo** (this file + the two companion format-inputs, committed on the
`structural-refactoring` branch → they reach `main` when the grove merges, surviving
`.grove/` deletion). The **actual delivery into the AppSpec grove is performed at the
pause point (leaf k66)**, when there is finally a grove to receive it: that session
`cd`s to `~/Development/AppSpec`, `grove-llm root-init`s the toolkit workstream, and seeds
its first planning leaf from **this document** (homing the durable parts into
`~/Development/AppSpec/docs/prd/`). This honours *"does not edit the AppSpec repo
directly"* (zero AppSpec edits now) and *"staged here and delivered via the inbox"* — the
delivery just happens at k66, the moment it is well-defined, rather than against a
non-existent branch and a dormant grove.

> **For the k66 (pause-point) session — the carrier checklist:**
> 1. Read this seed + `reverse-gen-workflow.md` + `hello-window/docs/spec.md`.
> 2. `cd ~/Development/AppSpec`; confirm no live `.grove/`; `grove-llm root-init appspec-toolkit`.
> 3. Seed the first planning leaf's brief from §3 (vision) + §4 (decomposition) + §5
>    (the three seeds); home this PRD's durable parts under
>    `~/Development/AppSpec/docs/prd/`.
> 4. Run the AppSpec grove (`grove do …`) to completion; then resume
>    `structural-refactoring` to retire k66 and grow the post-pause ws7 children.

---

## 7. What this seed does *not* decide (out of scope — externalized)

- **Building the toolkit** — the AppSpec grove's work (prompts + workflows).
- **forward-gen suites / VM-verify / the `apps/macos/` layout-finalize / portfolio +
  coverage tie-in** — post-pause ws7 children, deferred behind the AppSpec grove (added on
  k66's retirement).
- **Editing the AppSpec repo** — only the AppSpec grove (at k66+) does that; this grove
  seeds.
- **Resolving seed 3's interface question** — flagged for the AppSpec grove, not decided
  here.

## References

- **ADR-0052** — AppSpec as an external LLM-driven toolkit; the data boundary; no
  grove-native `.apiw` AppSpec entity.
- **ADR-0050** — the ws5 LLM side-channel (git as propose→review→accept) the toolkit
  mirrors. **ADR-0048** — semantic pattern-kinds (seed 3). **ADR-0049** — app-kinds (the
  reverse-gen authoritative anchor; seed 3).
- Node `app-model-k62` BRIEF (D1/D2/D2′/D3/D5; the exploration findings reconciling the
  external AppSpec project) + this grove's root brief *App model* decomposition #7.
- `CONTEXT.md` *App model / AppSpec* (the reconciled glossary — the three "AppSpec"
  meanings, App/impl/scenario/suite/contract, reverse-/forward-gen).
- `~/Development/AppSpec` — `README.md`, `CONTEXT.md`, `docs/adr/0001-0004`,
  `docs/specs/2026-04-18-app-spec-design.md`, `docs/plans/2026-04-18-app-spec-v1.md` (the
  v1 substrate reconciled in §2).

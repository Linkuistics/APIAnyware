# platform-model-k32

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

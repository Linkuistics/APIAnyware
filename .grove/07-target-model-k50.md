# target-model-k50

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

## Notes

- Reference: `REFACTOR.md` §20 (capability profiles), §7.7 (representability), §45 (success
  criteria — `targets/<t>/` material, native adapters as platform/target artifacts, homes for
  idiom catalogues / adapter specs / binding docs / conformance reports). `CONTEXT.md` for the
  hermetic per-target isolation + trampoline model the four live targets already embody.
- The four live targets each already ship VM-verified bindings (racket/chez/gerbil/sbcl); ws6
  **reshapes their homes + adds the authored target-model layer over them** — it does not re-port
  them. Per-target richness is affordable because the LLM makes it so
  ([[maximize_target_idiom_and_perf]]).

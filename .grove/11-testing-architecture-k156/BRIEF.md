# testing-architecture-k156 — brief

## Charter

**Workstream 9 — testing architecture** (root BRIEF decomposition #9): the **multi-layer test
model** (REFACTOR §33) + **TestAnyware / AppSpec integration** (§34). Grilling (2026-07-04) settled
the shape — see **Decisions D1–D5** below: ws9 is a **documented federation** of the test layers
that *already exist*, **not** new test machinery, homed in a new top-level **`testing/`** doc set
(the behaviour-axis twin of `schemas/`). Golden-neutral throughout (docs only).

This is the **last** workstream. After it retires: decomposition **#10 (ADR consolidation)**, then the
grove-finish cycle. Do **not** open #10 here (lazy materialization — grown after ws9 retires).

## Children

1. **`test-model-k157`** (flagship, live) — create the `testing/` home; author
   `testing/test-model.md` (the §33 twelve-layer federation map → existing homes + honest gaps +
   the §34 external-runner seam) + `testing/README.md`; raise **ADR-0053** (subject to the
   offer-sparingly re-check at authoring time). The `CONTEXT.md` "Test model (workstream 9)"
   glossary entry already landed in the k156 planning commit.
2. **`promote-testanyware-docs-k158`** (live) — promote + de-stale the parked
   `semantic/docs/testing/` docs into `testing/` (`general.md → testing/testanyware-workflow.md`;
   `strategies/modal-overlay-apps.md → testing/strategies/`); retire the old location; fix the five
   inbound references (`CONTEXT.md`, `TODO.md`, `README.md`,
   `targets/racket/app-implementations/macos/README.md`,
   `targets/_shared/docs/adding-a-language-target.md`).

## Context (pointers beyond the brief chain)

The root BRIEF is the charter; read its **Seams for the remaining workstreams** subsections — every
prior workstream (ws3–ws8) deferred a concrete slice to ws9. Synthesized, the standing ws9 seam is a
recurring **declare-now / execute-later** pattern where ws9 is the *execute-later* consumer:

- **ws9 owns the multi-layer test model (§33) + TestAnyware/AppSpec integration (§34).** It ties the
  layers into one coherent model; it does **not** re-build the pieces that already exist.
- **Prior workstreams declared, never executed.** ws4 authored + schema-validated the **platform-test
  declarations** (`platforms/macos/tests/api-semantics/<facet>.apiw` + `tests/app-kinds/<kind>.apiw`)
  but does **not** run them. ws3's **semantic model** informs the semantic-layer tests. The already-green
  regression substrate is the **emit goldens** (per-target) + the **per-crate `tests/*_registry.rs`**
  guards (validity) + ws8's `apianyware-validate` (validity, orthogonal to behavior).
- **The runner is external; execution hooks are ws6's.** The **AppSpec** project (`~/Development/AppSpec`)
  already drives `#lang app-spec` suites against a running binding **in a VM through TestAnyware**
  (built + run to completion during the ws7 k66 pause; 8 apps × 87 scenarios, each VM-verified ×4 —
  ADR-0052). **Per-target execution hooks are ws6's.** So ws9 **integrates/references** the runner, it
  does **not** build one (ws4/ws6/ws7 all state this). [[use_testanyware]] / [[vm_verify_every_app]].
- **Validity ≠ behavior.** ws8 (`apianyware-validate`) answers "is the artifact well-formed against its
  schema?"; ws9 answers "does the binding *behave*?". Orthogonal axes — a schema-valid artifact can still
  describe a broken binding. Keep the test model distinct from the validation model
  (`schemas/docs/validation-model.md`).

State to read before grilling: `REFACTOR.md` §33 (multi-layer test model), §34 (TestAnyware/AppSpec
integration), §45.13 (the "obvious home for … tests" criterion — is it already met structurally?), §47
end-state; the ws4 platform-test declaration crate `platforms/macos/tools/platform-tests/`; the ws7
app-model outcomes (external AppSpec, canonical per-app `scenarios/*.rkt` + `run-results.md`); the
`CONTEXT.md` "App model / AppSpec" + "Platform model" (D3 declare/execute seam) sections.

## Decisions (running log)

*(The four grilling-agenda questions — layer enumeration, machinery-vs-docs, the §34 seam, and the
home — were resolved into D1–D5 below. D1↔agenda-Q1/Q2, D2↔Q4, D3↔Q3, D4↔honest-coverage, D5↔shape.)*

**D1 — ws9 is a documented federation, not new test machinery.** (user, foundational, 2026-07-04)
Evidence: 9–10 of §33's 12 test layers already have real, verified homes (spec-validation →
ws8 `apianyware-validate`; extraction → goldens ×4 + `extract-{objc,swift}/tests`; annotation
→ ws5 `annotations {stale,audit}`; conformance → ws6 `apianyware-conformance`; sample-app →
external AppSpec `scenarios/*.rkt` VM-verified ×4; adapter-ABI → `adapters/*/tests/*.swift`;
packaging → `bundle-*/tests`). The runner is **external** (AppSpec, ADR-0052) and per-target
execution hooks are **ws6's**. So ws9 authors the **multi-layer test *model*** — a doc that maps
each §33 layer to its existing home, marks the honest gaps (perf §11, dedicated stress §12,
layer-6 api-semantics execution), homes the parked TestAnyware methodology doc, and names the
external AppSpec seam — and builds **no** runner and **no** crate. Mirrors ws7 (homed external
AppSpec) and ws8 (thin validation layer over existing schemas); **golden-neutral by
construction**. Rejected: a unified test-execution mechanism (net-new machinery contradicting
three standing seams — runner-external, hooks-are-ws6, declare-now/execute-later).

**D2 — Home: a new top-level `testing/` doc set.** (user, 2026-07-04)
The test model is cross-cutting (layers live in `platforms/`, `apps/`, `targets/`, `semantic/`,
`schemas/`) with no owning source-domain — exactly as validation was. So `testing/` becomes the
**behavior-axis twin of `schemas/`**: `schemas/docs/validation-model.md` answers "is it
well-formed?", `testing/test-model.md` answers "does it behave?". Doc-only (no `tools/`);
consistent with the repo's existing non-domain top-level dirs (`adr/`, `prd/`, `process/`,
`website/`); leaves the five source-material domains untouched; satisfies §45.13. Homes the
parked `semantic/docs/testing/{general.md,strategies/}` (which self-flag "expect this to move"
pending ws9). Rejected: schemas/docs adjacency (overloads the schema domain with behavioral
content); co-located + thin index (no clean home for the parked docs; weak §45.13).

**D3 — §34 seam: pure reference, no new APIAnyware-side test entity.** (recommendation, under D1)
The three-layer boundary is already settled (`CONTEXT.md` "App model / AppSpec" + ADR-0052):
**TestAnyware** (VM substrate) → **AppSpec** (toolkit + formats, external) → **APIAnyware**
(`apps/macos/` data). ws9 **describes** that seam in `test-model.md` and points at the external
runner; it adds **no** test manifest/index and **no** conformance tie-in (ws6
`apianyware-conformance` already derives per-app status; ws7 D3 re-confirmed no machine app
manifest). Reopen trigger: a machine consumer of a cross-layer test index materializes (none does).

**D4 — Layer-6 (api-semantics declarations) honestly marked declared-not-executed.**
(recommendation, honesty §43) The ws4 `tests/api-semantics/*.apiw` declarations state
per-`(receiver, selector)` source weirdness + expectations but are **not** systematically executed
by any layer. They are **honored-by-construction** (emit reads the same ownership/threading facts →
goldens encode correct annotation) and **incidentally exercised** by AppSpec VM-verify, but a
dedicated per-obligation runtime runner is **not built** (that is the "new machinery" D1 rejected).
`test-model.md` marks it a documented gap alongside perf (§11) and dedicated stress (§12) — no
coverage is claimed that doesn't exist. Reopen trigger = same as the deferred obligation-runner.

**D5 — Deliverables + two-child decomposition.** (planning)
The ws9 node produces: `testing/test-model.md` (the §33 federation map + honest gaps + §34 seam) +
`testing/README.md`; **ADR-0053** "multi-layer test model as a documented federation"
(current-state / in-place per D9 — a *new* decision, not a supersession chain: it records
federation-over-machinery + external-executor + top-level-home, the questions a future reader asks);
the `CONTEXT.md` "Test model (workstream 9)" glossary entry (added **this** session — terms settled);
and the promotion + de-staling of the parked TestAnyware docs. **Two children:**
`01-test-model` (flagship: home + model + README + ADR) and `02-promote-testanyware-docs`
(move + de-stale + retire old home + fix the 5 inbound refs: `CONTEXT.md`, `TODO.md`, `README.md`,
`targets/racket/app-implementations/macos/README.md`, `targets/_shared/docs/adding-a-language-target.md`).
The ADR is offered subject to child-1's offer-sparingly re-check. Golden-neutral throughout (docs only).

## Notes

- **Kin cadence:** ws2–ws8 each began as a root leaf whose planning session grilled then
  `leaf-decompose`d into a node. ws9 follows it. Golden-invariance has held across every workstream —
  ws9 is testing architecture, so it should stay golden-neutral (documenting/homing the test model, not
  moving emit output). If any decision would move goldens, flag it loudly.
- On decomposing, keep it **lazy** — grow the concrete child leaves the grilling actually justifies, not
  a speculative full set (runaway-tree anti-pattern; root BRIEF Decomposition note).

# The multi-layer test model is a documented federation, not a test-running machine

**Status:** accepted

**Raised by:** `structural-refactoring` grove, workstream 9 (testing architecture,
`test-model-k157`).

**Relates to:** ADR-0052 (AppSpec is the external LLM-driven spec/test toolkit APIAnyware
consumes — the layer-8/9 executor this decision references), ADR-0051 (capability profiles
and derived representability — per-target execution hooks are ws6's), ADR-0046 §5 / the
validation model (`schemas/`) — the *well-formedness* twin this test model is orthogonal to,
ADR-0050 (the ws5 side-channel philosophy the LLM edit-build-test loop reuses), ADR-0024/0045
(docs co-located / central ADRs). Records the shape of REFACTOR §33 (the twelve test layers)
and §34 (AppSpec / TestAnyware integration).

## Context

REFACTOR §33 opens "Testing must happen at multiple levels" and enumerates **twelve test
layers**, from spec validation through cross-target conformance to leak/lifetime/threading
stress; §34 says APIAnyware should *"consume or reference"* the external AppSpec and
TestAnyware projects. §45.13 requires "an obvious place for … tests." Read from those
sections alone — as the ws9 brief originally was — a workstream titled *testing architecture*
looks like it should build a **unified test-execution engine** that drives all twelve levels
from one place, plus a machine test-index tying the layers together, mirroring how ws2–ws6
each became an authored `.apiw` entity + schema + tool.

A reviewer will ask why ws9 builds neither. The grilling (2026-07-04) established the answer.
**Nine to ten of the twelve layers already have real, verified homes**, placed with the code
they test by the same co-location rule that governs docs (§10): spec-validity is ws8's
`apianyware-validate` (`schemas/`); extraction and binding-unit regression are the per-target
emit goldens + `extract-*/tests` (`targets/`, `platforms/`); annotation review is ws5's
`annotations {stale,audit}` (`platforms/`); conformance is ws6's `apianyware-conformance`
(`targets/`); adapter-ABI and packaging are the per-target `adapters/*/tests` and
`bundle-*/tests`; sample-app and GUI behaviour are the **external** AppSpec suites
(`apps/macos/<app>/scenarios/*.rkt`, VM-verified ×4). Three standing seams forbid a grove-side
runner: the sample-app / GUI **runner is external** (AppSpec owns it, ADR-0052), per-target
**execution hooks are ws6's** (ADR-0051), and every prior workstream **declared, never
executed** — the recurring *declare-now / execute-later* pattern, with the executor living
where the runtime is. A unified runner would duplicate the external one, fork three settled
boundaries, and re-implement homes that already pass.

This is the same shape as the two workstreams before it: ws7 *homed* the external AppSpec
toolkit rather than minting a grove-native app-spec entity (ADR-0052), and ws8 layered a
*thin validation driver* over schemas that already existed (ADR-0046 §5). The cross-cutting
test model has no owning source-domain — its layers live in all five domains — exactly as
validation did, which argues for a top-level home paralleling `schemas/`.

## Decision

**The multi-layer test model is a *documented federation* of the test layers that already
exist, homed in a new top-level `testing/` doc set. ws9 builds no test runner and no crate;
it maps each §33 layer to its home, marks the honest gaps, and names the external-runner
seam.**

1. **Federation over machinery.** `testing/test-model.md` maps each of the twelve §33 layers
   to the existing home that realises it (a crate, the emit goldens, an authored declaration,
   or an external suite). No grove-side test-execution engine, no unified "run the tests"
   command, no cross-layer machine test-index. Rejected: a unified test-execution mechanism —
   net-new machinery contradicting the runner-external / hooks-are-ws6 / declare-now-execute-later
   seams, and re-implementing homes that already pass.

2. **The executor is external; the model references it.** Layers 8–9 (AppSpec sample-app,
   GUI/accessibility) are driven by the external **AppSpec** project over **TestAnyware**
   (ADR-0052). `test-model.md` describes the TestAnyware → AppSpec → APIAnyware three-layer
   boundary and the §34 LLM edit-build-test-inspect-patch loop; it points at the external
   runner and adds **no** test manifest, cross-layer index, or conformance tie-in
   (`apianyware-conformance` already derives per-app status).

3. **Top-level `testing/` home — the behaviour-axis twin of `schemas/`.**
   `schemas/docs/validation-model.md` answers *"is the artifact well-formed?"*;
   `testing/test-model.md` answers *"does the binding behave?"*. Doc-only (no `tools/`),
   consistent with the repo's other non-domain top-level dirs (`adr/`, `prd/`, `process/`),
   leaving the five source-material domains untouched and satisfying §45.13. It also homes the
   TestAnyware GUI-testing methodology docs (promoted by `promote-testanyware-docs-k158`).
   Rejected: `schemas/docs` adjacency (overloads the schema
   domain with behavioural content); co-located + thin index (no clean home for the parked
   docs; weak §45.13).

4. **Honest gaps, stated as gaps.** Three layers are **not** systematically covered and the
   model says so (REFACTOR §43): **layer 6** (api-semantics execution) is *declared, not
   executed* — the ws4 `tests/api-semantics/*.apiw` declarations are schema-valid,
   honored-by-construction (emit reads the same facts → goldens), and incidentally exercised by
   AppSpec VM-verify, but no per-obligation runtime runner exists; **layer 11** (performance)
   and **layer 12** (leak/lifetime/threading stress) have no dedicated harness (stress is
   covered only indirectly via the adapter-ABI tests and VM runs). Each carries a stated reopen
   trigger; none claims coverage that does not exist.

## Consequences

- **Golden-neutral by construction.** ws9 writes only Markdown — no crate, no emitter, no
  schema, no goldens move. The invariant that held across ws2–ws8 holds through the last
  workstream.
- **The `testing/` domain is documentation, permanently.** It has no `tools/` and will grow no
  runner under this decision; a runner would be a *reopen* (see the layer-6 trigger), living
  where the runtime is (ws6 execution hooks / the external AppSpec project), not here.
- **Two orthogonal models, cross-linked.** `testing/` (behaviour) and `schemas/`
  (well-formedness) are distinct axes — a schema-valid artifact can still describe a broken
  binding. Layer 1 is the single touch-point (validation *seen as* a test layer). Conflating
  the two is the failure mode both model docs guard against.
- **Reopen triggers recorded.** A dedicated per-obligation api-semantics runner, a performance
  gate, a stress harness, or a machine cross-layer test-index — each is a new leaf if its need
  becomes real, not machinery built speculatively. This mirrors ws8's *derived reports stay
  on-demand* and D4's *deferred codec*.
- **Why this clears the ADR bar:** surprising (the workstream titled "testing architecture"
  ships documentation and *no* runner — a reader of §33/§34 expects a test-execution engine),
  a real trade-off (build a unified runner + machine test-index for one-command uniformity vs
  federate the homes that already exist and reference the external executor — the grove chose
  federation), and structurally committing (a new top-level domain and the withdrawal of the
  presumed ws9-builds-a-runner scope). Current-state, raised in place per the grove's ADR
  policy — not a supersession of any earlier ADR.

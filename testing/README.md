# testing/ — the multi-layer test model

The `testing/` domain holds the **behaviour axis** of the repository: the model of how the whole
system is tested (REFACTOR.md §33/§34). It is the twin of `schemas/` —
[`schemas/docs/validation-model.md`](../schemas/docs/validation-model.md) answers *"is the artifact
well-formed?"*, [`test-model.md`](test-model.md) answers *"does the binding behave?"*. This is the
"obvious home for … tests" the success criteria demand (§45.13).

**This directory is documentation only.** There is no `tools/` here and no test runner — testing is
a **federation** of twelve independently-homed layers (ADR-0053), not one machine. Each layer is
homed with the code it tests (spec-validity in `schemas/`, extraction goldens in `targets/`,
conformance in `targets/`, annotation review in `platforms/`, sample-app behaviour in the external
AppSpec suites); this domain names them, maps them, and marks the gaps. `testing/` is a non-domain
top-level doc home, consistent with the repo's `adr/`, `prd/`, `process/`, and `schemas/docs`.

## Layout

- **`test-model.md`** — **the multi-layer test model**: the twelve §33 layers mapped to their
  existing homes, the honest gaps (performance §11, leak/lifetime/threading stress §12, layer-6
  api-semantics execution), the §34 TestAnyware → AppSpec → APIAnyware seam + the LLM
  edit-build-test-inspect-patch loop, and why validity is not behaviour. Start here.
- **`testanyware-workflow.md`** — the **TestAnyware GUI-testing methodology**: the operational
  how-to for driving a GUI app in a live VM (the runbook behind test-model layers 8–9).
  *Promoted here from `semantic/docs/testing/` by `promote-testanyware-docs-k158`.*
- **`strategies/`** — per-scenario testing strategies (e.g. modal-overlay apps).
  *Promoted here by `promote-testanyware-docs-k158`.*

## The test model, in one line

**Testing is a federation of twelve independently-homed layers, not one runner.** Nine to ten
layers already have real, verified homes; layers 6/11/12 are documented gaps; the sample-app / GUI
runner is **external** (the AppSpec project, ADR-0052) and per-target execution hooks are ws6's. So
this domain builds **no runner and no crate** — it maps and names. Testing (behaviour) and
validation (well-formedness, `schemas/`) are orthogonal axes: a schema-valid artifact can still
describe a broken binding. Full model: [`test-model.md`](test-model.md).

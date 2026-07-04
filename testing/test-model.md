# The multi-layer test model

How the repository's testing is organised. Authored by **workstream 9**
(`testing-architecture-k156`, leaf `test-model-k157`); the decisions it records are the node
BRIEF running log **D1–D5** and **ADR-0053**.

The one-line version: **testing is a federation of twelve independently-homed layers, not one
runner.** This document maps each REFACTOR §33 layer to the home that already realises it, marks
the honest gaps, and names the external-runner seam. It builds nothing — no crate, no harness, no
goldens move.

This is the **behaviour axis** of the repository, the twin of `schemas/`:
[`schemas/docs/validation-model.md`](../schemas/docs/validation-model.md) answers *"is the
artifact well-formed?"*; this document answers *"does the binding behave?"*. The two are
orthogonal — see *Validity is not behaviour* below.

## A federation, not a machine

There is **no grove-side test runner and no `testing/` crate.** REFACTOR §33 opens "Testing must
happen at multiple levels," and a reader could expect a workstream titled *testing architecture* to
build a unified test-execution engine that drives all twelve levels. It deliberately does not
(**D1**), for one reason: **nine to ten of the twelve layers already have real, verified homes,**
scattered across the five source domains by design — spec-validity lives in `schemas/`, extraction
regression in the per-target emit goldens, annotation review in `platforms/`, conformance in
`targets/`, sample-app behaviour in the external AppSpec suites. Each layer is homed with the code
it tests, exactly as documentation is co-located with its subject (§10). A single command that
"ran the tests" would either re-implement those homes or become a thin dispatcher over
`cargo test` + `make` + an external VM runner — machinery that earns nothing the existing homes do
not already provide.

So the deliverable is the **model**, not a machine: this map, the honest gaps, and the seam to the
external executor. This mirrors the two workstreams before it — ws7 *homed* the external AppSpec
toolkit rather than reinventing an app-spec entity (ADR-0052), and ws8 layered a *thin validation
driver* over schemas that already existed (ADR-0046 §5). Federation-over-machinery keeps ws9
**golden-neutral by construction**: it writes only Markdown, so no emit output can move.

> **Why not a unified runner?** Three standing seams forbid it. The sample-app / GUI runner is
> **external** — the AppSpec project owns it (ADR-0052). Per-target **execution hooks are ws6's**
> (ADR-0051). And every prior workstream **declared, never executed** — ws4 authored the
> platform-test declarations but does not run them; the pattern throughout is *declare-now /
> execute-later*, with the executor living where the runtime is. A grove-side runner would
> duplicate the external one and fork three settled boundaries.

## The twelve layers and their homes

The spine of the model. Each §33 layer maps to an existing home (a crate, the goldens, a
declaration, or an external suite) or is an honest **gap**. State is reported as it actually stands
— `✅` covered, `✅ partial` covered for the shipped surface but not exhaustive, `✅ external` covered
by a sibling project, `⚠️`/`✗` a documented gap (see the next section).

| # | §33 layer | Home / substrate | State |
|---|-----------|------------------|-------|
| 1 | Spec validation | ws8 `apianyware-validate` (`schemas/tools/validate/`) + `make validate`; per-crate `tests/*_registry.rs` | ✅ |
| 2 | Extraction regression | per-target emit goldens (×4) + `platforms/macos/tools/extract-{objc,swift}/tests/` | ✅ |
| 3 | Annotation / LLM review | ws5 `apianyware-analyze annotations {stale,audit}` + `make lint-annotations` | ✅ |
| 4 | Adapter ABI | `targets/<t>/adapters/macos/tests/*Tests.swift` (per-concern trampoline ABI: throws-bridge, struct-marshal, class-lookup, GC-prevention, memory-management, string-conversion) | ✅ partial |
| 5 | Target binding unit | per-crate `cargo test` across every `tools/` crate + the emit goldens | ✅ |
| 6 | Semantic pattern | `semantic/tools/patterns` registry (`cargo test`) + ws4 `platforms/macos/tests/api-semantics/*.apiw` declarations | ⚠️ **declared, not executed** |
| 7 | Cross-target conformance | ws6 `apianyware-conformance` (`targets/_shared/tools/conformance-cli/`) + `target-model/tests/conformance_reports.rs` | ✅ |
| 8 | AppSpec sample-app | external **AppSpec** runner over `apps/macos/<app>/scenarios/*.rkt`, VM-verified ×4 (8 apps, 87 scenarios) | ✅ external |
| 9 | GUI / accessibility | external **AppSpec** / **TestAnyware** (OCR / vision / accessibility-tree assertions, in a live VM) | ✅ external |
| 10 | Packaging / signing / install | `targets/<t>/tools/bundle-*/tests/` (Info.plist, signing identity, bundle layout) + VM-verify launch | ✅ partial |
| 11 | Performance | — | ✗ **gap** |
| 12 | Leak / lifetime / threading stress | native binding + AppSpec VM-verify (indirect only) | ⚠️ **gap** |

Layers **1–7** and **10** are grove-side (Rust `cargo test`, the goldens, `make` gates, or the
authored declarations); layers **8–9** are the **external** AppSpec/TestAnyware suites the grove
*references* (see the seam below). The two regression substrates that catch the most are the
**per-target emit goldens** (layers 2 and 5 — any drift in extraction or emission moves a golden)
and the **`apianyware-conformance` derivation** (layer 7 — cross-target coverage computed on
demand). Neither is new to ws9; the model's job is to *name* them as the test layers they are.

## The honest gaps

Three layers are **not** systematically covered, and the model says so plainly rather than claiming
a coverage that does not exist (**D4**; REFACTOR §43, honesty). Naming a gap is itself the
deliverable — it tells a future session exactly what to build if the need becomes real, and states
the trigger.

- **Layer 6 — api-semantics execution (`⚠️ declared, not executed`).** ws4 authored the
  `platforms/macos/tests/api-semantics/<facet>.apiw` declarations — per `(receiver, selector)`, the
  §30 source-weirdness the pair exhibits and the expected annotation. They are **schema-valid** (ws8
  validates them) and **honored-by-construction** (emit reads the *same* ownership / threading /
  error facts, so a golden encodes the correct annotation and any regression moves it) and
  **incidentally exercised** by the AppSpec VM-verify. But no layer *systematically executes each
  declared obligation against a running binding* — a dedicated per-obligation runtime runner is the
  "new machinery" D1 declined. **Reopen trigger:** if per-obligation runtime assertions are ever
  wanted as a first-class gate, that runner is a new leaf (it is also ws6's execution-hook seam).
- **Layer 11 — performance (`✗ gap`).** No performance test exists. Emit throughput and binding
  call-overhead are unmeasured by any committed test. **Reopen trigger:** a performance regression
  is felt, or a perf budget becomes a release gate.
- **Layer 12 — leak / lifetime / threading stress (`⚠️ gap`).** Lifetime and main-thread-bounce
  correctness are covered **indirectly** — the native adapters' memory-management and GC-prevention
  ABI tests (layer 4) exercise the mechanisms, and the AppSpec VM runs surface gross leaks — but
  there is **no dedicated stress harness** (soak loops, allocation churn, concurrent-callback
  storms). **Reopen trigger:** a lifetime/threading defect escapes the indirect coverage, or a
  target's memory model needs a standing stress gate.

These are the same class of decision as ws8's *derived reports stay on-demand* and D4's
*native-serde codec deferred* — build the machinery when the need is **felt**, not speculatively.

## The §34 seam — TestAnyware → AppSpec → APIAnyware

Layers 8 and 9 are driven by an **external** executor, and the model describes that boundary rather
than reproducing it (**D3**). It is the same three-layer boundary already settled in `CONTEXT.md`
("App model / AppSpec") and **ADR-0052**:

- **TestAnyware** (`~/Development/TestAnyware`) — the VM-automation *substrate*: VM lifecycle, VNC
  input, screen capture / OCR / vision, in-guest exec. Knows nothing about apps or specs.
- **AppSpec** (`~/Development/AppSpec`, `Linkuistics/AppSpec`) — the external, LLM-driven
  *spec/test toolkit + formats*: the `#lang app-spec` scenario language, the harness / Driver /
  runner, the reverse- and forward-generators, the `testanyware-sdk`. **Uses TestAnyware, is used
  by APIAnyware, holds no app data.**
- **APIAnyware** (this repo) — owns the *app data*: `apps/macos/<app>/` holds each app's
  generated-and-validated `scenarios/*.rkt` + contracts; `targets/<t>/app-implementations/macos/<app>/`
  holds the implementations under test.

The grove **consumes / references** this stack; it does not vendor, fork, or re-host it, and it
mints **no** test manifest, cross-layer index, or conformance tie-in (ws6's `apianyware-conformance`
already derives per-app status; ws7's D3 re-confirmed no machine app manifest). **Reopen trigger:**
a machine consumer of a cross-layer test index materialises — none does today.

### The intended integration workflow (§34)

The end-to-end loop §34 describes is **LLM-driven**, and the whole architecture exists to make it
runnable: an LLM should be able to **read** a common app spec, **read** the target's binding docs +
idiom catalogue, **generate** a target-language implementation, **build** it, **run** the AppSpec /
TestAnyware suite in a live VM, **inspect** the failures, **patch** the implementation, and
**repeat**. The generated bindings (`targets/`), their docs and idiom catalogues (ws6), the common
app specs (`apps/macos/`, ws7), and the external runner (AppSpec) are precisely the inputs and
substrate that loop needs. *The tests validate the result, not the LLM's confidence* (§34) — a
scenario suite passing in a VM is the conformance evidence, not the model's assurance that it
should. The operational how-to for driving that VM loop is
[`testanyware-workflow.md`](testanyware-workflow.md) (the TestAnyware GUI-testing methodology); this
document is the *model*, not the runbook.

## Validity is not behaviour

The test model and the **validation model** are orthogonal axes, and conflating them is the acute
failure mode this document guards against. **Validation** (ws8,
[`schemas/docs/validation-model.md`](../schemas/docs/validation-model.md)) asks *"is the artifact
well-formed against its schema?"* — a static, structural check over the KDL. **Testing** (this
document) asks *"does the binding behave?"* — a dynamic, behavioural check over a running target.
A schema-valid artifact can still describe a broken binding; a passing scenario suite says nothing
about whether the underlying `.apiw` is well-formed. Layer 1 (spec validation) is the one place they
touch — it is literally the validation model *seen as a test layer* — and even there the question is
"did validation pass?", not "is the binding correct?". Keep the two models distinct: `schemas/` for
well-formedness, `testing/` for behaviour.

## Map: pointers

- [`README.md`](README.md) — the one-screen map of this `testing/` home.
- [`testanyware-workflow.md`](testanyware-workflow.md) — the TestAnyware GUI-testing methodology
  (the operational how-to behind layers 8–9; the *runbook* this model points at). *Landed by the
  sibling leaf `promote-testanyware-docs-k158`.*
- [`../schemas/docs/validation-model.md`](../schemas/docs/validation-model.md) — the twin
  well-formedness model.
- **ADR-0052** — AppSpec is the external LLM-driven spec/test toolkit APIAnyware consumes (the
  layer-8/9 executor).
- **ADR-0053** — this model: the multi-layer test model as a documented federation.
- **CONTEXT.md** "Test model (workstream 9)" — the glossary entry (test model · test layer).
- **REFACTOR.md** §33 (the twelve layers) · §34 (AppSpec / TestAnyware integration).

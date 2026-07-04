# testing-architecture-k156

**Kind:** planning

## Goal

Open **workstream 9 — testing architecture** (root BRIEF decomposition #9: the **multi-layer test
model** (REFACTOR §33) + **TestAnyware / AppSpec integration** (§34)). Grill the scope, sharpen
`CONTEXT.md`, and **grow the ws9 node** (via `leaf-decompose` when the shape is clear) with ordered
child leaves. The deliverable is *more tree*, not code — do only the first child this session if one
is obvious, else stop at the decomposition.

This is the **last** workstream. After it retires: decomposition **#10 (ADR consolidation)**, then the
grove-finish cycle. Do **not** open #10 here (lazy materialization — grown after ws9 retires).

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

## Grilling agenda (open questions — decide *with* the user, don't pre-answer)

1. **What are the layers of the multi-layer test model (§33)?** Enumerate them and map each to what
   already exists (goldens, registry guards, `apianyware-validate`, ws4 platform-test declarations,
   ws3 semantic tests, external AppSpec suites, VM-verify) vs. what is missing. Is the deliverable **one
   unified model** or a **documented federation** of the existing layers? WDYT.
2. **Does ws9 build machinery, or is it a documentation/architecture workstream?** Given the runner is
   external, execution hooks are ws6's, and declarations are ws4's — ws9 may turn out (like **ws7**) to
   be mostly *homing + tying together* existing pieces rather than authoring new entities/tools. Flag
   this as a live possibility early; let the grilling decide, don't presume either way.
3. **§34 integration surface.** AppSpec already runs suites in VMs. Does ws9 add anything APIAnyware-side
   — a test manifest/index, a conformance tie-in (ws6 `apianyware-conformance` already derives per-app
   status), a doc set — or purely reference the external runner? What is the *seam* between the APIAnyware
   repo and the external AppSpec project?
4. **Where does the test model live?** A `tests/` domain, a `testing/` doc set, co-located per subject?
   (§45.13 asks for an "obvious home … for tests" — is it met by the existing scattered homes, or does
   ws9 add a coherent one?)

## Notes

- **Kin cadence:** ws2–ws8 each began as a root leaf whose planning session grilled then
  `leaf-decompose`d into a node. ws9 follows it. Golden-invariance has held across every workstream —
  ws9 is testing architecture, so it should stay golden-neutral (documenting/homing the test model, not
  moving emit output). If any decision would move goldens, flag it loudly.
- On decomposing, keep it **lazy** — grow the concrete child leaves the grilling actually justifies, not
  a speculative full set (runaway-tree anti-pattern; root BRIEF Decomposition note).

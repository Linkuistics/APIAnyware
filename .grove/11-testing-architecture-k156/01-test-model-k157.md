# test-model-k157

**Kind:** work

## Goal

Author the **multi-layer test model** — ws9's flagship deliverable. Create the new top-level
**`testing/`** doc home and write `testing/test-model.md`: the **documented federation** that maps
REFACTOR §33's twelve test layers to the homes that already realise them, marks the honest gaps, and
names the external-runner seam. Add `testing/README.md` (a map). Raise **ADR-0053** recording the
architectural decision. **No runner, no crate, no goldens moved** — docs only (node BRIEF **D1**).

## Context

Read the node BRIEF **Decisions D1–D5** first — they are this leaf's mandate. The one-line version:
ws9 is a federation doc, not machinery; `testing/` is the behaviour-axis twin of `schemas/`
(`schemas/docs/validation-model.md` = "is it well-formed?", `testing/test-model.md` = "does it
behave?"). Model `test-model.md`'s prose density and structure on `schemas/docs/validation-model.md`
(the ws8 sibling — same author-a-model-doc job).

**The §33 layer → home map** (verified in the k156 grilling; the doc's spine):

| # | §33 layer | Home / substrate | State |
|---|-----------|------------------|-------|
| 1 | Spec validation | ws8 `apianyware-validate` + `make validate` | ✅ |
| 2 | Extraction regression | emit goldens (×4) + `platforms/macos/tools/extract-{objc,swift}/tests` | ✅ |
| 3 | Annotation/LLM review | ws5 `apianyware-analyze annotations {stale,audit}` + `make lint-annotations` | ✅ |
| 4 | Adapter ABI | `targets/<t>/adapters/macos/tests/*.swift` (TrampolineTests) | ✅ partial |
| 5 | Target binding unit | per-crate `cargo test` + emit goldens | ✅ |
| 6 | Semantic pattern | `semantic/tools/patterns` registry + ws4 `platforms/macos/tests/api-semantics/*.apiw` | ⚠️ **declared, not executed** (D4) |
| 7 | Cross-target conformance | ws6 `apianyware-conformance` + `target-model/tests/conformance_reports.rs` | ✅ |
| 8 | AppSpec sample-app | external AppSpec `apps/macos/<app>/scenarios/*.rkt`, VM-verified ×4 (87 scenarios) | ✅ external |
| 9 | GUI/accessibility | AppSpec / TestAnyware (external) | ✅ external |
| 10 | Packaging/signing/install | `targets/<t>/tools/bundle-*/tests` + VM-verify launch | ✅ partial |
| 11 | Performance | — | ✗ **gap** (D4) |
| 12 | Leak/lifetime/threading stress | native binding + VM-verify (indirect only) | ⚠️ **gap** (D4) |

- **§34 seam (D3):** describe the three-layer boundary (already in `CONTEXT.md` "App model /
  AppSpec" + ADR-0052): **TestAnyware** (VM substrate) → **AppSpec** (external toolkit + formats) →
  **APIAnyware** (`apps/macos/` data). Point at the external runner; add **no** manifest/index/tie-in.
  Include §34's LLM edit-build-test-inspect-patch loop as the intended integration workflow.
- **Honesty (D4, REFACTOR §43):** layers 6/11/12 are **documented gaps** — do not claim coverage
  that doesn't exist. Layer 6's api-semantics declarations are honored-by-construction (emit reads
  the same facts → goldens) + incidentally exercised (AppSpec VM-verify), but not systematically
  run; a per-obligation runner is deferred (reopen trigger stated).
- **Validity ≠ behaviour:** cross-link to `schemas/docs/validation-model.md`; state the orthogonality.
- **ADR-0053** (next free number, verified): current-state / in-place per the root BRIEF **ADR policy
  (D9)** — a *new* decision, **not** a supersession chain. Records: federation-over-machinery,
  external executor (cites ADR-0052), top-level `testing/` home. Re-run grilling.md's offer-sparingly
  three-part test at authoring time; if it fails, fold the rationale into `test-model.md` instead.
- The `CONTEXT.md` "Test model (workstream 9)" glossary entry **already landed** in the k156 commit —
  reference it, don't re-add it.
- Forward-reference `testing/testanyware-workflow.md` (populated by sibling
  `promote-testanyware-docs-k158`) as the TestAnyware GUI-testing methodology.

## Done when

- `testing/test-model.md` maps all twelve §33 layers to home-or-gap, describes the §34 seam +
  LLM loop, states validity≠behaviour, and marks layers 6/11/12 honestly.
- `testing/README.md` is a one-screen map of the `testing/` home.
- ADR-0053 exists (or its rationale is folded into `test-model.md` with a logged reason).
- `make validate` still green; **no golden changed** (`git status` on `targets/*/tools/*/tests/golden*`
  is clean). One focused commit naming `test-model-k157`.

## Notes

- Golden-neutral is a hard invariant (D1) — this leaf writes only Markdown. If any urge to touch a
  crate/emitter/schema arises, it is out of scope → externalize as a new leaf (`leaf-add`).
- Keep `test-model.md` a **model/map**, not a runbook — the operational TestAnyware how-to is
  `promote-testanyware-docs-k158`'s `testing/testanyware-workflow.md`, not this doc.

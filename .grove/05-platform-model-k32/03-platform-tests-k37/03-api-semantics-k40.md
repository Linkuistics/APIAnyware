# api-semantics-k40

**Kind:** work (platform-tests child 3 — the sibling api-semantics family; **may decompose** mechanism-first, see Notes)

## Goal

Realize the **api-semantics test-declaration family** (node-brief D5 child 3 / D6):
the four `platforms/macos/tests/api-semantics/{ownership,callbacks,threading,errors}.apiw`
files — projection-free, target-independent declarations of what a macOS API
*semantic facet* must hold — plus the **sibling** mechanism that contracts them: a
new `schemas/spec-format/api-semantics.kdl-schema` and a new `src/api_semantics/`
submodule in the existing `apianyware-platform-tests` crate, with a standing guard.
Unlike child 2 (pure content on a built mechanism), this child **builds the second
family's mechanism** *and* authors its content. Declarations are schema-validated
(goldens-green) but **NOT executed** (ws9 owns execution).

## Context (see `grove-llm brief-chain`; node BRIEF D6 + ADR-0046/0049)

- **Distinct entity, shared mechanism (D6, ADR-0049).** An api-semantics declaration
  is a **distinct entity** from an app-kind-tests declaration — an api-semantic
  expectation is an *API-facet property* (a receiver/selector's ownership, callback,
  threading, or error behaviour), not a process/bundle obligation. So it takes its
  **own** sibling KDL-Schema (`api-semantics.kdl-schema`, not a unified envelope) and
  its **own** submodule `src/api_semantics/` (model + `apiw` parser + schema validator
  + registry), added **additively** to the one `apianyware-platform-tests` crate — no
  crate-root collision (child 1 already structured `lib.rs` for submodules-per-family;
  the gui-app/app-kind family lives in `src/app_kind_tests/`). **Mirror child 1's
  template exactly:** authored `.apiw` family ⟶ KDL-Schema under `schemas/spec-format/`
  (register it in `schemas/spec-format/README.md`) ⟶ focused in-crate validator
  (`include_str!` the schema, delegate structure to
  `apianyware_spec_format::validate_against_schema`, add the semantic checks the
  generic schema can't state) ⟶ standing `tests/` guard that loads + validates every
  committed declaration.
- **Four files = the four convention facets.** The four declarations align with the
  four facet maps the `apianyware-conventions` datalog computes (the same four the
  `annotate` step consumes by `(receiver, selector)`):
  `ownership.apiw` ↔ ParamOwnership · `callbacks.apiw` ↔ BlockParamAnnotation ·
  `threading.apiw` · `errors.apiw`. Ground every declaration in **real
  Foundation/AppKit shapes** (concrete receiver/selector examples) — platform truth,
  not invented.
- **§30 source-weirdness vocabulary.** The declarations draw on the §30
  source-semantic difficulty vocab — `fork-unsafe`, `may-reenter`, `ownership-unknown`,
  `requires-message-pump`, `main-thread-only`, … (node-brief D4). Settle whether the
  schema carries this as a **controlled vocabulary** (cf. the app-kind process-model
  enums) — likely yes for the threading/ownership weirdness tags — vs. open prose for
  the expectation bodies. This is platform truth ws6 *consumes* to compute a
  representability status; it is **never itself a representability status** (that is
  ws6/§20, node-brief D4 — no `fully-`/`lossily-represented` here).
- **REFACTOR.md (source of truth):** **§30** (source-semantic difficulty vocab),
  **§13/§14** (platform semantic specs + directory structure), §29 (`.apiw`/triad
  mechanics ws2 settled, reused). ADR-0046 (`.apiw` overlays, declare-now /
  execute-later), ADR-0049 (distinct-entity-vs-shared-mechanism precedent).
- **ws8 seam (mirrors child 1 / ADR-0049):** author only the `.apiw` KDL-Schema + the
  focused in-crate validator; the machine-JSON schema + CI validation tooling stay
  ws8.
- **Placeholder NOT discharged here:** `platforms/macos/tests/README.md` is child 4's
  (it lands with the fixtures, once both families exist).

## Done when

- `tests/api-semantics/{ownership,callbacks,threading,errors}.apiw` authored,
  projection-free, target-independent, grounded in real Foundation/AppKit shapes,
  schema-validated.
- `schemas/spec-format/api-semantics.kdl-schema` authored + registered in the schema
  README; `src/api_semantics/` submodule (model + parser + validator + registry) added
  to `apianyware-platform-tests`; a standing guard loads + validates every committed
  api-semantics file.
- The §30 weirdness vocabulary is settled (controlled-vocab vs. open prose) and the
  schema reflects the decision.
- `cargo test -p apianyware-platform-tests`, clippy, fmt green; **declarations NOT
  executed** (ws9); no emit-golden movement.

## Notes (steers)

- **May decompose mechanism-first.** This child is meatier than child 2 (new schema +
  new submodule + 4 files + vocab). If the grammar/vocab design warrants it, decompose
  mechanism-first (like child 1): a first child standing up
  `api-semantics.kdl-schema` + the `src/api_semantics/` submodule + guard with **one
  exemplar facet** (e.g. `ownership.apiw`) end-to-end, then a content child for the
  other three facets. Otherwise do it in one session. Grove principle: the session
  decides.
- **Projection-free + target-independent + platform truth.** A declaration says what
  the *platform* semantic is (this selector returns an owned object; this block is
  called on the main thread; this method may re-enter), never how a target satisfies
  it (ws6) or how it is run (ws9). No target-specific expectations, no representability
  status.
- **Schema-validated, not executed.** Done-bar is "loads + validates + goldens green,"
  exactly like the app-kind family — no runner, no VM, no TestAnyware under
  `platforms/`.
- After this node retires, grow child 4 (**fixtures + README** — the raw
  `tests/fixtures/{pasteboard,spotlight,sample-documents,sample-images}/` inputs the
  obligations reference + discharge `tests/README.md`). After *it* retires, the
  retire-cascade asks before treating **workstream 4** done; then **ws5** (LLM analysis
  side-channel) grows next (root-brief decomposition).

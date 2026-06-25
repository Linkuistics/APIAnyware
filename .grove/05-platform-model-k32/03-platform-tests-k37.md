# platform-tests-k37

**Kind:** work (ws4 child 3 — likely decomposes; see Decomposition)

## Goal

Realize the **platform-semantic test declarations** (node-brief decision D3) — the
projection-free, target-independent *expectation declarations* of what macOS API
semantics and app-kind obligations must hold, plus the raw **fixtures** they read.
These are authored and **schema-validated (goldens-green) but NOT executed** in ws4;
execution is ws9. Discharge `platforms/macos/tests/README.md`. This is ws4's third
of four children (manifest ✓, app-kinds ✓, **platform-tests**, then platform-docs).

## Context (inherited — see `grove-llm brief-chain`; node BRIEF D3/D5 + ADR-0046 carry the seam)

- **The declare-now / execute-later seam (D3).** ws4 owns the *declaration* half —
  projection-free, target-independent expectation declarations as `.apiw`
  (ADR-0046; KDL overlays, machine files JSON) — and the raw fixtures. **ws9** owns
  the *execution* half: the multi-layer test model (§33), the runner, and
  TestAnyware/AppSpec integration (§34) that drives a declaration against a *running
  target binding* in a VM; **ws6** owns the per-target execution hooks. Same
  declare-now / execute-later shape as ws3→ws8. **Build nothing that executes** under
  `platforms/` — schema-validate and load, do not run.
- **Two declaration families + fixtures** (D3 / D5 child 3):
  - **`tests/api-semantics/{ownership,callbacks,threading,errors}.apiw`** — what a
    macOS API semantic *must hold*, target-independent. These align with the four
    **convention facets** the `apianyware-conventions` datalog computes
    (ParamOwnership · BlockParamAnnotation/callbacks · threading · error) and draw on
    the §30 **source-weirdness** vocabulary (`fork-unsafe`, `may-reenter`,
    `ownership-unknown`, `requires-message-pump`, `main-thread-only`, …) — platform
    truth ws6 *consumes*, never a representability status (that is ws6/§20, node-brief
    D4). Ground each in real Foundation/AppKit shapes.
  - **`tests/app-kinds/<kind>.apiw`** — the obligation **bodies** that resolve the
    `test-obligation` refs the seven authored kinds declare. The refs (already
    prose-specified in each kind's `docs/test-obligations.md` /
    `indexing-tests.md` — that prose is the written source for each `.apiw` body):

    | kind | obligation refs |
    |---|---|
    | `cli-tool` | `lifecycle` |
    | `gui-app` | `lifecycle`, `bundle-structure` |
    | `menu-bar-daemon` | `lifecycle`, `accessory-activation`, `status-item` |
    | `launch-agent` | `lifecycle`, `background-activation` |
    | `spotlight-importer` | `importer-bundle`, `indexing` |
    | `quicklook-extension` | `extension-bundle`, `preview` |
    | `finder-sync-extension` | `extension-bundle`, `sync-badging` |

  - **`tests/fixtures/{pasteboard,spotlight,sample-documents,sample-images}/`** — the
    raw inputs the obligations read (a pasteboard payload; a sample document the
    importer/preview index; sample images for quicklook). Keep **minimal +
    representative**, not a corpus.
- **Mirror the manifest/app-kinds mechanism exactly** (`platform-manifest-k33`,
  `app-kinds-k34`, both retired): an authored `.apiw` family is contracted by a
  **KDL-Schema** under `schemas/spec-format/` + validated by a **focused in-crate
  validator** (`include_str!` the schema, delegate to
  `apianyware_spec_format::validate_against_schema` for structure, add the semantic
  checks the generic schema can't state) + guarded by a **standing `tests/` guard**
  that loads + validates every committed declaration. Crate home: a new
  `platforms/macos/tools/<crate>` (crate-home convention, ADR-0043). Whether
  api-semantics and app-kind-obligation declarations share **one** test-declaration
  schema or take **two** sibling schemas is a design beat to settle while authoring.
- **ws8 seam (mirrors ws3 D7 / ADR-0049):** author only the `.apiw` KDL-Schema(s) +
  the focused in-crate validator; the machine-JSON schema + CI validation tooling
  stay ws8.
- **Placeholder to discharge:** `platforms/macos/tests/README.md` (ws4 marker).

## Done when (node done-bar — across children if decomposed)

- `tests/api-semantics/{ownership,callbacks,threading,errors}.apiw` authored,
  projection-free, schema-validated.
- `tests/app-kinds/<kind>.apiw` authored for all seven kinds — **every** declared
  `test-obligation` ref above resolved by a body.
- `tests/fixtures/{pasteboard,spotlight,sample-documents,sample-images}/` populated
  with minimal representative inputs.
- The test-declaration `.apiw` KDL-Schema(s) under `schemas/spec-format/` + a focused
  validator crate + a standing guard; everything loads + validates; tests green.
- `platforms/macos/tests/README.md` discharged (TODO removed; prose reflects the
  realized declarations + the declare-now/execute-later seam).
- `cargo check --workspace`, clippy, fmt green; **declarations are NOT executed**
  (ws9); no emit-golden movement.

## Decomposition (skeleton-first; children grow lazily)

This leaf is **likely a node** — a schema/validator mechanism plus two declaration
families plus fixtures is more than one focused session. If so, `leaf-decompose`
(first child only this session). A natural skeleton-first order, mirroring how
app-kinds went mechanism-first:

1. **mechanism** — the test-declaration `.apiw` KDL-Schema(s) + a focused validator
   crate + a standing guard, with **one exemplar declaration end-to-end** (a strong
   choice: `app-kinds/gui-app.apiw` resolving `lifecycle` + `bundle-structure`, the
   richest obligation pair). De-risks the grammar the rest follow.
2. **app-kind obligations** — the remaining six kinds' `tests/app-kinds/<kind>.apiw`.
3. **api-semantics** — the four `tests/api-semantics/*.apiw` + the §30 weirdness vocab.
4. **fixtures + README** — the raw fixtures and discharge `tests/README.md`.

(Exact child split is the picking session's call — keep it lazy; do only child 1.)

## Notes (steers)

- **Projection-free + target-independent.** A declaration says what the *platform*
  semantic/obligation is, never how any target satisfies it (that is ws6) and never
  how it is run (that is ws9). No target-specific expectations.
- **Schema-validated, not executed.** The done-bar is "loads + validates + goldens
  green," exactly like app-kinds — no runner, no VM, no TestAnyware under
  `platforms/`.
- After this node retires, grow child 4 (**platform-docs**, node-brief D5) — the last
  ws4 child. After *it* retires, the retire-cascade asks before treating **workstream
  4** done; then **ws5** (LLM analysis side-channel) grows next (root-brief
  decomposition).

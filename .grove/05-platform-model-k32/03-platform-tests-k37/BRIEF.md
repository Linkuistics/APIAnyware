# platform-tests-k37 — brief

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
  that loads + validates every committed declaration. Crate home: the new
  `platforms/macos/tools/platform-tests` crate (`apianyware-platform-tests`;
  crate-home convention, ADR-0043), hosting both families as submodules
  (`src/app_kind_tests/` now, `src/api_semantics/` in child 3).
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

Decomposed into a node (`leaf-decompose`, this session); children grow lazily as
earlier ones retire. Skeleton-first order, mirroring how app-kinds went
mechanism-first:

1. **test-mechanism-k38** *(child 1, this session)* — the app-kind-obligation
   `.apiw` KDL-Schema + the `apianyware-platform-tests` validator crate + a standing
   guard, with the exemplar `app-kinds/gui-app.apiw` resolving `lifecycle` +
   `bundle-structure` end-to-end. De-risks the grammar the rest follow.
2. **app-kind obligations** — the remaining six kinds' `tests/app-kinds/<kind>.apiw`
   (pure content + fixture-ref grammar already in the schema from child 1).
3. **api-semantics** — the four `tests/api-semantics/*.apiw` + the §30 weirdness
   vocab; adds the **sibling** `api-semantics.kdl-schema` + an `src/api_semantics/`
   submodule to the same crate.
4. **fixtures + README** — the raw fixtures and discharge `tests/README.md`.

## Decisions (running log)

### D6 — Two sibling test-declaration schemas, one crate

The two declaration families take **two sibling KDL-Schemas**
(`app-kind-tests.kdl-schema` now, `api-semantics.kdl-schema` in child 3), not one
unified envelope. They are *distinct entities sharing only the mechanism* — exactly
the ADR-0049 distinct-entity-vs-shared-mechanism precedent (app-kind ≠ pattern-kind):
an app-kind obligation body is process/bundle behaviour, an api-semantic expectation
is an API-facet property; their bodies have genuinely different shapes. **One crate**
(`apianyware-platform-tests`) hosts both as **submodules-per-family**
(`src/app_kind_tests/`, `src/api_semantics/`), so child 3 is purely additive (no
crate-root file collision) and the "platform test declaration" umbrella stays one
home. This *applies* ADR-0049 rather than making a new hard-to-reverse decision —
running-log + this brief suffice, no new ADR.

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

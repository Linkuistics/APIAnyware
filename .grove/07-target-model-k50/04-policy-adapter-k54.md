# policy-adapter-k54

**Kind:** work

## Goal

Author the **projection policy** (§23) + **adapter spec** (§24–26) layers of the target
model (ws6 child 4, D7) — the two remaining *authored* `.apiw` entities that describe each
target's per-platform projection *choices* and its *existing* native adapter library. Add
`policy/` and `adapter_spec/` submodules to the shared `target-model` crate (mirroring
`descriptor/` + `capability/` + `idioms/`), the two `kdl-schema` contracts + focused
validators, and the authored `targets/<t>/policies/<platform>/*.apiw` +
`targets/<t>/adapters/<platform>/spec.apiw` for each of the four live targets.
**Documentation-of-the-existing only** — describe the adapter code that already ships; do
**not** redesign the ABI or write adapter code.

## Context (see `grove-llm brief-chain` — esp. node BRIEF D1/D5/D6; CONTEXT "Projection policy" + "Adapter spec")

- **D1 (the entity split):**
  - **Projection policy** (`targets/<t>/policies/<platform>/*.apiw` — §23): the per-platform
    projection *choices* a target makes — e.g. `safe-adapter` vs `thin-direct` (§24's
    direct-call-vs-adapter spectrum). Projection-bearing → lives in `targets/`, never
    `platforms/`. Authored (a target-policy decision: the racket trampoline-elision posture,
    the sbcl direct-msgSend + sole-native-unit posture).
  - **Adapter spec** (`targets/<t>/adapters/<platform>/spec.apiw` — §24–26): the authored
    description of the *existing* native adapter library (`adapters/<platform>/sources/`,
    already built) — the §26 adapter **roles** required (`direct_forwarder`,
    `callback_adapter`, `thread_adapter`, …), the §26 runtime **services**
    (`object_registry` / `callback_registry` / `main_thread_dispatch` /
    `autorelease_pool_management` / …), and the §26 **direct-call policy**. The *spec* is
    ws6's authored layer; the adapter *code* was built by the target grove.
- **D5 (crate home):** extend the **same** `targets/_shared/tools/target-model` crate — add
  `policy/` + `adapter_spec/` submodules (parse + serde + focused validator + registry),
  mirroring `descriptor/` / `capability/` / `idioms/` (the three-layer structural→semantic→
  registry pattern, the `include_str!`'d schema, controlled-vocab-via-validator where a
  vocabulary is section-conditional). ws6 authors the `{policy,adapter-spec}.kdl-schema`
  + focused validators; **ws8** owns the machine JSON Schema. The per-target `.apiw` files are
  **data** under `targets/<t>/`.
- **D6 (boundaries):** the adapter *code* exists (built by the target groves) — author the
  *spec over it*, never the code; no §25 ABI redesign (the adapters ship a working ABI — the
  spec documents it). The bundler-reshape residuals are a *separate* ws6 item (child 7), not
  this leaf.
- **First action:** survey each target's existing `adapters/<platform>/sources/` (the native
  adapter library) + its `target.apiw` `adapter-strategy` / `projection-policy` facets
  (already authored by `target-descriptor-k51`) so the spec describes *what is actually
  there* — settle the `policies/<platform>/<file>.apiw` partition (one file per policy
  concern vs one `policies/<platform>/policy.apiw`) the way `idioms-k53` settled the
  catalogue partition.

## Done when

- `target-model` crate gains `policy/` + `adapter_spec/` (parse/serde/validator + registry)
  and re-exports.
- `schemas/spec-format/{policy,adapter-spec}.kdl-schema` authored (language-neutral
  contracts) + README registered.
- `targets/{racket,chez,gerbil,sbcl}/policies/macos/*.apiw` +
  `targets/<t>/adapters/macos/spec.apiw` authored, each parsing + validating green,
  grounded in each target's already-shipped adapter code + ADRs.
- Goldens unmoved (authored-layer only — no emit change); workspace + clippy + fmt green.

## Notes

- Authored-layer-only, like the prior three children — no generation/emit change, so
  golden-neutral by construction (these entities have no emit consumer yet; a future child
  or grove may add a projection-policy consumer, which would be golden-intentional).
- Per-target richness is affordable because the LLM makes it so ([[maximize_target_idiom_and_perf]]);
  each target authors its own policy + adapter spec grounded in its real native unit
  (racket trampoline-elision; chez foreign-thread activation; gerbil/sbcl main-thread bounce;
  sbcl sole-native-unit `libAPIAnywareSbcl`).
- Commit handle: `policy-adapter-k54`. Remaining ws6 children after this (grow lazily):
  5 conformance, 6 mapping+target docs, 7 bundler reshape + guide resync (D7).

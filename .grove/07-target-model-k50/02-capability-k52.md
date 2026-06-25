# capability-k52

**Kind:** work

## Goal

Author the **capability profile + representability** layer (ws6 child 2, D7) — the genuinely
novel model of ws6. Add a `capability/` submodule to the shared `target-model` crate, the shared
§20 capability vocabulary + the `weirdness → capability` map + the 7-rung representability ladder
+ the `derive` representability floor, the `capability.kdl-schema` contract + focused validator,
and an authored `capability.apiw` profile for each of the four live targets.

## Context (see `grove-llm brief-chain` — esp. node BRIEF running log, D1/D2/D5)

- **D2 (the model to build):**
  - **One 7-rung representability ladder** unifying §20 levels & §7.7 statuses:
    `exact-static` > `exact-runtime` > `idiomatic-conventional` > `lossy-but-documented` >
    `unsafe-only` > `not-representable` > `research`.
  - **Capability profile** `targets/<t>/capability.apiw` — authored, **platform-independent**:
    a map from a **§20 capability dimension** (a *shared controlled vocabulary* in the new
    `target-model::vocab` — `foreign-thread-callbacks`, `struct-by-value`, `deterministic-cleanup`,
    …) → a ladder rung. Two faces: per-API *semantic* capabilities (feed representability) and
    §36 *app-form* capabilities (`packaging`/`app-bundle`/`plugin`/`sandboxing`/
    `native-runtime-embedding` — feed per-app-kind feasibility, child 5's conformance, **not**
    per-API representability).
  - **Shared `weirdness → capability` map** (`target-model::vocab`, target-independent): which §20
    capability a given §30 source-weirdness demands (`may-reenter → foreign-thread-callbacks`).
  - **Representability is DERIVED** (uncommitted, `target-model::derive`):
    `status(api, target) = floor over { profile[needs(w)] : w ∈ platform.weirdness(api) }`;
    an API with **no** §30 weirdness tag defaults to `exact-static` (the trampoline-elision limit).
    The §30 weirdness comes from ws4's `platforms/macos/tests/api-semantics/<facet>.apiw`
    declarations (read, do not author — that is platform truth; ws6 consumes it).
- **D5 (crate home):** extend the **same** `targets/_shared/tools/target-model` crate — add the
  `capability/` submodule (parse + serde + focused validator), `vocab.rs` (capability dimensions +
  weirdness→capability map), and `derive.rs` (the floor). ws6 authors the `.apiw` KDL Schema +
  focused validator; **ws8** owns the machine JSON Schema for any derived report.
- **Conventions to mirror:** the `descriptor/` submodule shipped by `target-descriptor-k51` (the
  three-layer structural→semantic→registry pattern, the `include_str!`'d schema, the
  controlled-vocab-via-validator shape for the §30 weirdness — cf. `api_semantics::vocab` in
  `apianyware-platform-tests`, which keeps its own §30 token table). The ladder is a controlled
  enum (like `runtime-model`); the capability dimensions are a controlled vocab (like §30 weirdness).
- **The ADR (D7):** the capability/representability model is the genuinely novel model of ws6 —
  **raise the candidate ADR here** (parallel to ADR-0048/0049), citing the floor-derivation + the
  trampoline-elision default + the two-face profile.

## Done when

- `target-model` crate gains `capability/` (profile parse/serde/validator), `vocab.rs` (§20
  capability dimensions + `weirdness → capability` map), `derive.rs` (the representability floor +
  the 7-rung ladder), and re-exports.
- `schemas/spec-format/capability.kdl-schema` authored (language-neutral contract).
- `targets/{racket,chez,gerbil,sbcl}/capability.apiw` authored, each parsing + validating green,
  facet rungs grounded in CONTEXT (e.g. sbcl `foreign-thread-callbacks` is bounced-not-activated →
  a conventional/lossy rung vs chez's activation; racket main-thread-bounce; etc.).
- A derivation test: for a sample `(receiver, selector)` carrying a known §30 weirdness, the
  derived per-target status matches the floor; a no-weirdness API derives `exact-static`.
- The candidate ADR raised in `adr/` (central, ADR-0045 home).
- **Goldens unmoved** (representability is derived, emit untouched); workspace + clippy green.

## Notes

- Skeleton-first: the derivation is a library + tests; surfacing it via a CLI/report is later
  (child 5 conformance). Do not build the report generator here.
- Keep the capability profile **platform-independent** (it describes the implementation) — the
  per-platform binding happens in the derivation, reading platform §30 weirdness.
- Commit handle: `capability-k52`.

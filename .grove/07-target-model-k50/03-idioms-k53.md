# idioms-k53

**Kind:** work

## Goal

Author the **idiom catalogue + data-driven dispatch** layer (ws6 child 3, D7) — the §21
source-concept → target-construct mapping, authored as `.apiw` per target, plus the refactor
that **externalizes the existing `emit/pattern_dispatch` classifier onto it**. Add an `idioms/`
submodule to the shared `target-model` crate, the `idioms.kdl-schema` contract + focused
validator, an authored `targets/<t>/idioms/<category>.apiw` catalogue for each of the four live
targets, and the §21 idiom docs. **Golden-neutral** (D3): author the catalogue + data-drive the
seam; do **not** turn on generation this grove.

## Context (see `grove-llm brief-chain` — esp. node BRIEF running log, D3/D5; ws3 seam)

- **D3 (the work):**
  - **Author** `targets/<t>/idioms/<category>.apiw` — the §21 source-concept → target-construct
    mapping (`bracket → with-macro + unwind-protect`, `error-out → condition + multiple-values`, …)
    — plus the generated/maintained §21 idiom docs under `idioms/docs/`. §21 idiom categories:
    owned/borrowed/shared resource, explicit release, bracketed use, builder, typestate, nullable
    result, error side channel, exception-like failure, callback, escaping callback, subscription,
    delegate, async completion, thread affinity, main-thread requirement, buffer fill, two-call
    sizing, array/slice/view, string encoding, foreign struct, foreign enum/flags, global singleton,
    unsafe escape hatch. (Settle the `<category>.apiw` partition — one file per category like
    api-semantics' `<facet>.apiw`, or one catalogue file — first thing in the session.)
  - **Data-drive the seam:** refactor `classify_pattern` (today a hardcoded Rust `match` on kind
    name, scheme-flavoured names baked in) to **read the per-target catalogue**; the shared `emit`
    crate keeps the plumbing, the per-target `.apiw` supplies the construct + naming. **First action:
    grep for `classify_pattern` / `IdiomaticConstruct`** to confirm the D3 finding still holds —
    *zero callers, every emitter pattern-blind* (verified 2026-06-25) — so the refactor is provably
    golden-neutral. If a caller has appeared, re-scope before touching it.
  - **Defer *applying* projection** — wiring emitters to consume pattern-instances and emit
    `with-bracket`/`make-foo` wrappers **moves goldens in all four targets + needs per-target
    VM-verify**; that is a clearly-scoped, **golden-INTENTIONAL** follow-on (a late ws6 child or a
    future grove), **not** this leaf. Mirrors ws3–ws5's "author the carriage, defer the consumer"
    and capability-k52's "author the profile, defer turning on a representability report."
- **ws3 seam:** ws6 *consumes* the semantic pattern-kind model (the catalogue maps a pattern-**kind**
  to a target construct via the `emit/pattern_dispatch` seam); the semantic model is ws6's **input**,
  never the projection spec — projection lives in `targets/`, never `semantic/`.
- **D5 (crate home):** extend the **same** `targets/_shared/tools/target-model` crate — add the
  `idioms/` submodule (parse + serde + focused validator + registry), mirroring `descriptor/` +
  `capability/` (the three-layer structural→semantic→registry pattern, the `include_str!`'d schema,
  the controlled-vocab-via-validator shape — cf. `vocab::is_valid_dimension`). ws6 authors the
  `idioms.kdl-schema` + focused validator; **ws8** owns the machine JSON Schema. The per-target
  `.apiw` files are **data** under `targets/<t>/idioms/`.
- **Conventions to mirror:** the `capability/` submodule shipped by `capability-k52` (face/section
  bodies + a per-entry controlled-vocab token + a controlled-enum child; the §21 idiom *category* is
  a controlled vocab like the §20 capability dimensions; the target *construct* is the open authored
  token like an idiom's realization). The catalogue loader keys a per-target catalogue by category,
  the way `classify_pattern` will read it.

## Done when

- `target-model` crate gains `idioms/` (catalogue parse/serde/validator + registry) and re-exports.
- `schemas/spec-format/idioms.kdl-schema` authored (language-neutral contract) + README registered.
- `targets/{racket,chez,gerbil,sbcl}/idioms/<category>.apiw` authored, each parsing + validating
  green, constructs grounded in each target's already-shipped idiom (CONTEXT + the per-target ADRs).
- `classify_pattern` refactored to **consume the per-target catalogue** instead of the baked-in Rust
  `match` — **golden-neutral** (confirmed zero-callers / pattern-blind emitters; goldens unmoved).
- §21 idiom docs authored under `targets/<t>/idioms/docs/` (or the settled docs home).
- Goldens unmoved; workspace + clippy + fmt green.

## Notes

- Skeleton-first: author the catalogue + data-drive the classifier; do **not** wire emitters to
  emit idiom wrappers (golden-moving — deferred).
- Per-target richness is affordable because the LLM makes it so ([[maximize_target_idiom_and_perf]]);
  each target authors **its own** idioms (the maximize-idiom rule — not a target-neutral catalogue).
- Commit handle: `idioms-k53`.

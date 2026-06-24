# spec-format-k16

**Kind:** planning

## Goal

Open **workstream 2** of the `structural-refactoring` grove (root brief decomposition
item 2): design the **`.apiw` DSL + parser** and the **canonical / resolved YAML
interchange** that replaces today's **JSON enriched IR**. This is the spine the later
workstreams consume — semantic model (3), platform model (4), LLM side-channel (5),
target model (6) all read or write specs in this format — so its shape is grilled and
agreed before they build on it.

This is a **planning** leaf: open with a grilling session (one question at a time,
recommended answer each), update `CONTEXT.md` inline as the new vocabulary resolves,
raise ADRs sparingly, write a **PRD** at the genuine agreement point, then **decompose**
into child work leaves (the `.apiw` parser, the YAML schemas, the IR→YAML migration of
the live pipeline). Do **not** pre-spawn the whole subtree.

## Context (inherited — see `grove-llm brief-chain`)

The skeleton (`skeleton-k2`) is complete: five-domain tree, internal rename, docs
co-located, JSON-IR pipeline building + 71 test suites green. Content rewrites (this
workstream and 3–9) land **in place** in the new tree. Read before grilling:

- `REFACTOR.md` — esp. **§29 Specification format**, **§12 Semantic model**, **§27
  Complete API surface**, **§13 Source platform semantic specifications**, **§30 Source
  semantic weirdness to model**, **§7.1** (source semantics are projection-independent).
- `CONTEXT.md` — current architecture & glossary (complete-API binding model, the JSON
  enriched IR + goldens it replaces). New DSL/interchange terms get appended here inline.
- Root `BRIEF.md` — the nine-workstream decomposition + **Skeleton outcomes** (crate-home
  convention, deferred-content TODO index).

**Live constraints to grill against:**
- The current pipeline emits/consumes **JSON** at `analysis/ir/{collected,resolved,
  annotated,enriched}/` (gitignored, regenerable) via `semantic/tools/{datalog,resolve,
  enrich}` + `platforms/macos/tools/{extract-*,annotate}`. This workstream changes that
  interchange; sequence the cutover so the pipeline stays buildable (D4 spirit).
- The **IR relocation** `analysis/ir/` → `platforms/macos/api/` is **workstream 4**'s
  job (`platforms/macos/api/README.md` TODO) — decide how 2 and 4 interleave (does the
  format change land first at the old paths, or co-move?).
- Per-target emitters (`emit`, `emit-<t>`) read enriched IR today; the format change must
  keep them fed (goldens-as-truth testing, per the racket cleanup ADR-0010-era practice).

## Grilling seeds (shape, not a fixed agenda)

- **`.apiw` surface:** what does the DSL express (declarations, annotations, pattern-kinds,
  relationships, capability/representability)? Authored by hand, emitted by tools, or both?
  Syntax family (its own grammar vs a YAML/edn dialect)? Parser host crate + where it lives
  (`semantic/tools/`?).
- **Canonical vs resolved YAML:** what distinguishes the two stages; which today's
  collected/resolved/enriched checkpoints map onto; what becomes derivable vs authored.
- **Migration from JSON IR:** big-bang vs staged; converter direction; how goldens and the
  snapshot tests move; how `datalog`/`resolve`/`enrich` change.
- **Provenance / precedence / confidence:** carried in the format vs the side-channel (ws5)?
- **Schema home:** how this meets workstream 8 (`schemas/`) — is the YAML schema authored
  here or there?

## Done when

The spec-format / data-model design is grilled to shared understanding, captured in a PRD
(and ADRs where a decision is hard-to-reverse or a real trade-off), `CONTEXT.md` carries
the new vocabulary, and this leaf is **decomposed** into ordered child work leaves under a
`spec-format-k16/` node (or executed directly if the agreed scope fits one session).

## Notes

Workstream 2 is "done in place" — no new top-level structure; the `.apiw` files and YAML
schemas land in the homes the skeleton already created (`semantic/`, `platforms/macos/api/`,
`schemas/`), discharging their `TODO (workstream 2)` markers. Keep `cargo fmt --all` +
standalone `style:` commits in mind as code lands.

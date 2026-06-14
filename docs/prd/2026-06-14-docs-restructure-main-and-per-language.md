# PRD — Restructure docs into a main tier and per-language tier

**Date:** 2026-06-14
**Status:** Agreed (grilling complete; see `.grove/010-plan.md` running log)
**Grove:** `restructure-docs-to-main-and-per-language`

## Problem

Documentation is ~50/50 cross-cutting vs. target-specific (~5,000 lines, ~160
`.md` files), and the target-specific half is scattered across **six** trees:
`docs/adr/`, `docs/specs/`, `docs/research/`, `knowledge/targets/`,
`knowledge/matrix/`, and `generation/targets/<lang>/`. A contributor working on
one target gathers context from all six; a newcomer cannot tell shared docs from
target-specific ones because they are interleaved (e.g. racket-only ADR-0013
sits mid-sequence among foundational ADRs); and there is no template telling a
new-target author what to read vs. produce.

## Goals

1. **Per-target locality** — everything about one target in one place.
2. **Clean main/shared core** — cross-cutting docs form one unified, discoverable tier.
3. **New-target onboarding** — an obvious read-this (main) / produce-this (per-language template) split.
4. **Reduce duplication/drift** — eliminate cross-target repetition (e.g. "read racket.md for shared bits").
5. **Authoring process includes docs** — the new-target authoring instructions
   must make producing the per-language doc structure (the canonical
   `generation/targets/<lang>/docs/` template + per-app `learnings.md`) an
   explicit, sequenced part of adding a target — not an afterthought. A new
   target is not "done" until its docs exist in this structure.

## The two tiers

### Main tier — single `docs/` tree

```
docs/
  README.md          # main map / landing
  adr/               # central decision log, ALL targets (global numbering kept)
  pipeline/          # shared collect -> analyse -> generate docs
  specs/             # cross-cutting design specs
  research/          # cross-cutting research (currently empty; reserved)
  apps/              # language-agnostic app portfolio specs
  testing/           # TestAnyware methodology
  guides/            # adding-a-language-target, codesigning-identity
  prd/               # this PRD and future ones
```

`README.md` and `CONTEXT.md` stay at the repo root (CONTEXT.md is read by the
grove loop every session; README is the project entry point). `knowledge/` is
**dissolved**. `analysis/scripts/*.md` stay with their scripts (operational
prompt templates, not narrative docs). `docs/superpowers/` is tooling, untouched.

### Per-language tier — co-located in the target unit

```
generation/targets/<lang>/
  README.md               # target overview / index
  docs/
    reference.md          # deep target reference
    developer-guide.md    # user-facing app-writing guide (where present)
    design/               # per-target design specs
    research/             # per-target spikes
  apps/<app>/
    README.md
    learnings.md          # per-target-per-app realization notes
  test-results/<app>/report.md   # already co-located
```

**Exception:** ADRs do *not* co-locate. The decision log is a connected graph
crossing target boundaries (supersession 0020->0018, 0005->0004; gerbil ADRs
cite chez ADRs), so all of `docs/adr/0001..0023` stays central with global
numbering.

## Move-map

### Main consolidation (leaf 020)

| From | To |
|---|---|
| `knowledge/pipeline/{collection,analysis,type-mapping}.md` | `docs/pipeline/` |
| `analysis/docs/{annotation-workflow,api-pattern-catalog,enrich-rules,memory-architecture}.md` | `docs/pipeline/` |
| `generation/docs/emitter-contract.md` | `docs/pipeline/emitter-contract.md` |
| `knowledge/apps/**` | `docs/apps/**` |
| `knowledge/testanyware/**` | `docs/testing/**` |
| `docs/adding-a-language-target.md` | `docs/guides/adding-a-language-target.md` |
| `docs/codesigning-identity.md` | `docs/guides/codesigning-identity.md` |
| `knowledge/README.md` | folded into new `docs/README.md` (main map), then removed |
| `docs/adr/`, `docs/specs/` (cross-cutting), `docs/research/` (cross-cutting) | unchanged in place |

Cross-cutting specs that stay in `docs/specs/`:
`2026-03-26-macos-workspace-design`, `2026-04-16-sample-app-portfolio-design`,
`2026-05-20-core-pipeline-hardening-design`,
`2026-05-20-core-pipeline-hardening-item1-findings`,
`2026-05-20-core-pipeline-hardening-item3-gapb-findings`,
`2026-05-20-coretransferable-followup`, `2026-05-22-grove-skill-design`.

After 020, `knowledge/` no longer exists; `analysis/docs/` and `generation/docs/`
are empty (remove if so).

### Per-language co-location (leaf 030)

For each `<lang>` in {racket, chez, gerbil}:

| From | To |
|---|---|
| `knowledge/targets/<lang>.md` | `generation/targets/<lang>/docs/reference.md` |
| `knowledge/matrix/<app>/<lang>.md` | `generation/targets/<lang>/apps/<app>/learnings.md` |
| `docs/specs/<lang>-specific specs` | `generation/targets/<lang>/docs/design/` |
| `docs/research/<lang>-specific spikes` | `generation/targets/<lang>/docs/research/` |

Per-target spec assignments:
- **racket** — `2026-04-19-racket-oo-class-system-analysis`,
  `2026-05-22-racket-oo-completion-design`, `2026-05-31-racket-native-binding-design`.
- **chez** — `2026-05-27-chez-target-design`,
  `2026-05-29-chez-standalone-distribution-design`, `2026-06-02-chez-native-binding-design`.
- **gerbil** — `2026-06-03-gerbil-target-design`.

Per-target research assignments:
- **racket** — `2026-05-31-racket-9.2-ffi2-migration.md`, `2026-05-31-racket-ffi2-spike/`.
- **chez** — `2026-05-29-chez-standalone-spike.md`,
  `2026-05-29-chez-standalone-spike-evidence/`,
  `2026-05-29-chez-standalone-hello-window-vm-verify/`, `2026-06-02-chez-dispatch-spike/`.
- **gerbil** — `2026-06-03-gerbil-ffi-dispatch-spike/`, `2026-06-08-gerbil-threading-spike/`.

Judgment calls to resolve by reading the file (leaf 030):
- `docs/specs/2026-05-21-blockbridge-test-flake.md` — BlockBridge is racket's
  native trampoline; **likely racket**, confirm before moving (if genuinely
  cross-cutting, leave in `docs/specs/`).
- `knowledge/matrix/counter/racket.md` — the `counter` app is **retired** (not
  in the portfolio); no destination `apps/counter/` dir. Decide: drop, or keep
  as a historical note under racket. Surface to the user, do not silently delete.

### Cross-references, glossary, ADR (leaf 040)

- Update every internal markdown link broken by the moves.
- Update code/README pointers: root `README.md`, per-target `README.md`s,
  `CLAUDE.md`/memory pointers, the `knowledge/README.md` rules referenced elsewhere.
- `CONTEXT.md` glossary terms already added this session ("Main docs / main
  tier", "Per-language docs / co-located target docs"); verify against final layout.
- Write the **co-location ADR** (see below).

### New-target authoring process includes docs (leaf 050)

This is goal 5, called out by the user as a first-class deliverable, not a
link-fix. Rewrite `docs/guides/adding-a-language-target.md` so that **producing
the per-language documentation is a sequenced step of the authoring process**:

- Add an explicit "Document the target" stage that walks the author through
  creating each slot of the canonical layout: `docs/reference.md`,
  `docs/developer-guide.md`, `docs/design/` (design specs raised during the
  build), `docs/research/` (spikes), and per-app `apps/<app>/learnings.md`.
- State the read-vs-produce split up front: which **main** docs the author reads
  (pipeline, app portfolio specs, emitter-contract, ADRs 0010/0011, this PRD's
  structure) vs. which **per-language** docs they produce.
- Make "docs exist in the canonical structure" part of the target's definition
  of done. Cross-reference the co-location ADR.
- Consider a copyable skeleton (empty template tree or a checklist) so the
  author fills slots rather than inventing layout.

### Verification (leaf 060)

- Grep for dangling relative links and stale paths
  (`knowledge/`, `analysis/docs/`, `generation/docs/`) across all `.md`, plus
  source/README/CLAUDE references.
- Confirm no orphaned files; confirm `docs/README.md` map matches reality.
- Docs-only change — **no VM verification needed**.

## New ADR (written in leaf 040)

**"Per-language docs co-locate in the target unit; ADRs stay central."**
Qualifies as an ADR (hard to reverse — touches ~160 files and all cross-refs;
surprising without context — a reader wonders why docs are split this way; a real
trade-off — locality vs. central-history convention). Extends ADR-0011
(hermetic isolation) to documentation; records the ADR exception and its
rationale (connected cross-target decision graph).

## Done when

- `docs/` is the single main tier with the structure above; `knowledge/` is gone.
- Every target unit follows the canonical per-target doc layout for the docs it has.
- All ADRs remain central with unchanged numbering.
- No dangling links or stale paths anywhere (verified by grep in leaf 060).
- The co-location ADR is committed.
- `adding-a-language-target.md` makes producing the per-language doc structure
  an explicit, sequenced step of the authoring process, with a read-vs-produce
  split and docs as part of the target's definition of done (goal 5).

## Non-goals

- Rewriting doc *content* (this is a structural move; content edits only where a
  cross-reference or the onboarding-guide rewrite demands it).
- Touching `analysis/scripts/*.md`, `docs/superpowers/`, or any non-doc code.
- Renumbering or splitting ADRs.

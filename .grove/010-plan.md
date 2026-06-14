# 010-plan

**Kind:** planning

## Goal

Plan the restructuring of this repo's documentation into a clear **main**
(cross-cutting / shared) tier and a **per-language** (per-target) tier, then
grow the grove tree with the work leaves that execute it.

## Context

Today docs are ~50/50 cross-cutting vs target-specific (~5,000 lines, ~160
`.md`). Target-specific material is scattered across **six** locations:
`docs/adr/`, `docs/specs/`, `docs/research/`, `knowledge/targets/`,
`knowledge/matrix/`, and `generation/targets/<lang>/`. A `knowledge/` axis
system (`pipeline/targets/apps/matrix/testanyware`) already partially encodes
the split. ADRs are one global numbered sequence (0001–0023) mixing both kinds.

## Done when

- PRD written and agreed (`docs/prd/2026-06-14-docs-restructure-main-and-per-language.md`). ✓
- Glossary terms captured in `CONTEXT.md`. ✓
- Tree grown with work leaves 020–060. ✓ (this session)
- (Execution itself happens in the work leaves, not this planning leaf.)

## Decisions (running log)

### Q1 — Motivation (settled)

All four drivers are in scope (user selected all): **per-target locality**
(everything about one target in one place), **clean main/shared core**
(cross-cutting docs uncontaminated by target detail), **new-target onboarding**
(obvious what to read vs. produce when adding a target), and **reduce
duplication/drift** (eliminate "read racket.md for shared bits" cross-target
repetition). The restructure is therefore comprehensive, not a narrow move.

### Q2 — Home for the per-language tier (settled)

**Co-locate** per-language docs into the target's own on-disk unit,
`generation/targets/<lang>/`, alongside its runtime/apps/emitter output.
"Main" = the existing `docs/` + `knowledge/pipeline/` + root files, cleaned of
target-specific material. Rationale: `CONTEXT.md` already names
`generation/targets/<name>/` as *the on-disk unit*, and **ADR-0011** makes each
target hermetically isolated; a target's docs belong inside that isolated unit.
Rejected: a central `docs/targets/<lang>/` tree (re-centralizes what the
architecture deliberately separates). → **ADR candidate** (hard to reverse,
surprising without context, real trade-off vs. central-history convention).

### Q3 — ADRs (settled)

**All ADRs stay central** in root `docs/adr/` with their global 0001–0023
numbering intact. ADRs are the **one explicit exception** to Q2 co-location:
the decision history is a connected graph that crosses target boundaries
(supersession 0020→0018, 0005→0004; gerbil ADRs cite chez ADRs — later targets
learned from earlier ones), so splitting/renumbering would destroy the
project-wide chronological log and the supersession chains. Only guides, design
specs, research, and reference docs co-locate per-target (subject to Q4).
Rejected: per-target renumbered sequences, per-target global-number relocation,
central-index-with-co-located-bodies.

### Q4 — Per-target specs & research (settled)

**Co-locate** per-target design specs and spike/research docs into
`generation/targets/<lang>/docs/` (e.g. `design/`, `research/`). Cross-cutting
specs/research stay central in `docs/specs/` + `docs/research/`. Unlike ADRs,
specs/research don't form a connected supersession graph — they're per-target
design artifacts, so they follow the Q2 default. Accepted cost: a co-located
spec may cite a central ADR (e.g. chez design spec → ADRs 0005–0008).

**Emerging general rule:** *everything target-specific co-locates into
`generation/targets/<lang>/`, EXCEPT ADRs (which stay central in `docs/adr/`).*

### Q5 — knowledge/ axes (settled)

**Co-locate `targets` + `matrix`.** `knowledge/targets/<lang>.md` →
`generation/targets/<lang>/`; `knowledge/matrix/<app>/<lang>.md` →
`generation/targets/<lang>/apps/<app>/` (folds the "target" grid dimension into
the path, next to that target's app code). `knowledge/` keeps only the
cross-cutting axes — `pipeline/`, `apps/` (language-agnostic specs),
`testanyware/` — and its `README.md` is updated to drop the relocated axes.
Net: "main owns the language-agnostic app spec; each target owns its
realization notes," mirroring shared-IR / per-target-emitter separation.

### Q6 — Scope of main-tier work (settled; user overrode recommendation)

**Also consolidate main** — not extraction-only. Beyond pulling per-language
material out, actively reorganize the cross-cutting docs into a clearer single
shared structure. (LLM had recommended extraction-only for smaller blast
radius; user wants a genuinely unified main.) Shape of consolidated main → Q7.

### Q7 — Shape of consolidated main (settled)

**Single `docs/` tree.** Dissolve `knowledge/`; pull cross-cutting pipeline
docs out of `analysis/docs/` + `generation/docs/` into `docs/pipeline/`. Final
main tree:

```
docs/
  README.md          # main map/landing
  adr/               # central decision log (all targets)
  pipeline/          # collect->analyse->generate (shared)
    collection.md, analysis.md, type-mapping.md      (was knowledge/pipeline/)
    annotation-workflow.md, api-pattern-catalog.md,
    enrich-rules.md, memory-architecture.md          (was analysis/docs/)
    emitter-contract.md                              (was generation/docs/)
  specs/             # cross-cutting design specs
  research/          # cross-cutting research
  apps/              # language-agnostic app portfolio  (was knowledge/apps/)
  testing/           # TestAnyware methodology          (was knowledge/testanyware/)
  guides/            # adding-a-language-target, codesigning-identity
```

`README.md` + `CONTEXT.md` stay at repo root (CONTEXT.md is grove-load-bearing,
read every session; README is project entry). `analysis/scripts/*.md` stay with
their scripts (operational prompt templates, not narrative docs). Rationale for
centralizing phase docs while co-locating target docs: hermetic isolation
(ADR-0011) governs *targets*; pipeline *phases* are shared infrastructure
feeding all targets, so their docs are cross-cutting.

### Q8 — Canonical per-target doc layout (settled)

```
generation/targets/<lang>/
  README.md               # target overview / index
  docs/
    reference.md          # deep target ref      (was knowledge/targets/<lang>.md)
    developer-guide.md    # user-facing app-writing guide
    design/               # per-target design specs   (was docs/specs/<t>-*)
    research/             # per-target spikes          (was docs/research/<t>-*)
  apps/<app>/
    README.md
    learnings.md          # per-app notes  (was knowledge/matrix/<app>/<lang>.md)
  test-results/<app>/report.md   # already co-located
```

`docs/` subdir per target; `reference.md` stays a distinct doc (not folded into
README — racket's is ~150 lines). This is the template the new-target guide will
point at (onboarding goal). Not every slot is filled for every target today
(e.g. only racket has a developer-guide); empty slots are follow-ups, not
blockers.

### Q9 — Execution approach (settled)

**PRD + 4 work leaves.** Write a PRD (`docs/prd/`) capturing the two-tier
structure, a full move-map (every source → destination), and done-criteria.
Then grow leaves: **020** build consolidated main `docs/` tree (+ dissolve
`knowledge/`); **030** co-locate per-language docs for all three targets;
**040** global cross-reference + `CONTEXT.md` glossary + `CLAUDE.md`/memory
pointers + rewrite `adding-a-language-target.md` around the new template +
write the co-location ADR; **050** verification (grep dangling links/paths,
docs-only — no VM). All moves via `git mv` to preserve history.

### Q10 — User addition mid-session (incorporated)

User: "We also need to update the instructions for authoring a new target so
that the process includes this documentation, in this structure." → Promoted
from a sub-bullet of leaf 040 to **its own leaf (050)** and elevated to PRD
**goal 5**: the new-target authoring process must make producing the
per-language doc structure an explicit, sequenced step, with a read-vs-produce
split, and docs as part of the target's definition of done. Verification shifts
to leaf 060.

## Decomposition

Work leaves grown this session (siblings of 010 under root):

- **020-build-main-docs-tree** — consolidate main into single `docs/` tree; dissolve `knowledge/`.
- **030-colocate-per-language-docs** — move per-target reference/design/research/matrix into target units.
- **040-cross-refs-glossary-adr** — repair all references; verify glossary; write co-location ADR.
- **050-authoring-guide-includes-docs** — bake the doc structure into the new-target authoring process (goal 5).
- **060-verify-restructure** — grep dangling links/paths; confirm no orphans; docs-only (no VM).

See PRD for full move-map and rationale.

## Notes

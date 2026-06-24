# Per-language docs co-locate in the target unit; ADRs stay central

**Status:** accepted

Documentation splits into two tiers by the same axis that ADR-0011 uses for
code. **Main (cross-cutting) docs** — anything about the project as a whole or
the shared `collect → analyse → generate` pipeline — consolidate under a single
top-level `docs/` tree (`adr/ pipeline/ specs/ research/ apps/ testing/ guides/
prd/` + `docs/README.md` as the map). **Per-language (target-specific) docs**
co-locate inside the target's own on-disk unit `generation/targets/<lang>/`:
`docs/reference.md`, `docs/developer-guide.md`, `docs/design/`, `docs/research/`,
and per-app `apps/<app>/learnings.md` alongside the already-co-located
`test-results/<app>/report.md`. The former `knowledge/` tree is dissolved into
this split.

This extends **ADR-0011** (targets are hermetically isolated; only the API
analysis is shared) from code to documentation: a target's reference, design
spikes, and per-app realization notes are part of the target unit, not a shared
central pile that interleaves three targets' specifics. It carries ADR-0011's
locality posture into the docs a contributor reads while working on one target.

**The one exception is ADRs.** The decision log is a *connected graph that
crosses target boundaries* — supersession chains (0020→0018, 0005→0004) and
later targets citing earlier ones (gerbil ADRs cite chez ADRs) — so all of
`adr/0001..NNNN` stays central with unchanged global numbering. Co-locating
ADRs would sever those cross-target edges and force per-target renumbering.

## Considered options

- **Status quo: target docs scattered across six trees.** Target-specific
  material lived in `docs/adr/`, `docs/specs/`, `docs/research/`,
  `knowledge/targets/`, `knowledge/matrix/`, and `generation/targets/<lang>/`. A
  contributor on one target gathered context from all six; a newcomer could not
  tell shared docs from target-specific ones because they were interleaved
  (e.g. a racket-only ADR sitting mid-sequence among foundational ADRs); and
  there was no template separating what a new-target author *reads* from what
  they *produce*.
- **Central `docs/targets/<lang>/` tree.** Keep one top-level docs root, with a
  per-target subtree under it. Discoverable in one place, but it re-centralizes
  exactly what ADR-0011's isolation separates: the target unit on disk and the
  docs about it drift apart, and "everything about one target in one place" is
  lost the moment the docs live elsewhere.
- **Per-target ADR renumbering / co-located ADRs.** Move each target's ADRs into
  its unit and renumber locally. Rejected: it breaks the connected decision
  graph — supersession and cross-target citation edges become dangling or
  ambiguous — for no locality gain that the central log does not already give.
- **Co-locate per-language docs; keep ADRs central (chosen).** Everything about
  one target lives in its unit except the ADRs, whose value *is* their
  cross-target connectivity. Some discoverability cost for the central main tier
  is paid back by `docs/README.md` as the map and by the read-vs-produce split in
  the new-target authoring guide.

## Consequences

- **`knowledge/` is dissolved.** Its pipeline, app-portfolio, and TestAnyware
  docs fold into `docs/pipeline/`, `docs/apps/`, `docs/testing/`; its per-target
  `targets/<lang>.md` becomes `generation/targets/<lang>/docs/reference.md` and
  its `matrix/<app>/<lang>.md` becomes
  `generation/targets/<lang>/apps/<app>/learnings.md`.
- **Each target unit owns a canonical doc layout.** `docs/reference.md`,
  `docs/developer-guide.md` (where present), `docs/design/`, `docs/research/`,
  per-app `learnings.md`. A target is not "done" until its docs exist in this
  structure — the new-target authoring guide
  (`targets/_shared/docs/adding-a-language-target.md`) makes producing them an explicit,
  sequenced step with a read-the-main-tier / produce-the-per-language split.
- **ADRs remain central with global numbering** — the sole per-target-flavoured
  content kept central, justified by the cross-target decision graph.
- **Cross-references were repaired in bulk.** The move touched ~160 files; every
  live navigational pointer (READMEs, code comments, ADR back-references,
  per-target reference/guide cross-links) was repointed, while historical
  narrative inside dated design specs, research findings, test reports, and
  completed plans was deliberately left as a record of past state.
- **Duplication across similar targets is accepted by design**, as in ADR-0011 —
  e.g. each Scheme-family target repeats some setup in its own `reference.md`
  rather than sharing a central "read racket.md for the common bits" doc. The
  same ADR-0010 economics (LLM-assisted authoring) make per-target docs
  affordable.

See the PRD `prd/2026-06-14-docs-restructure-main-and-per-language.md` for
the full move-map, and `CONTEXT.md` ("Documentation structure": *Main docs /
main tier*, *Per-language docs / co-located target docs*) for the glossary
definitions.

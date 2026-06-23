# The central ADR log relocates from `docs/adr/` to a top-level `adr/`

**Status:** accepted

**Refines:** ADR-0024 (per-language docs co-locate; ADRs stay central).

The `structural-refactoring` grove dissolves the large top-level `docs/` tree:
`REFACTOR.md` §10 mandates *"there should be no large top-level `docs/` directory —
documentation must live beside the thing it documents."* ADRs are the one artifact
that resists co-location: ADR-0024 keeps the decision log **central** with global
numbering because it is a connected graph crossing every target (supersession
chains; later targets cite earlier ones). With `docs/` gone, the central log needs a
new home. We move it to a small, focused **top-level `adr/`**.

## Context

A co-located scheme (`semantic/docs/adr/`, `targets/<t>/docs/adr/`, …) was already
rejected by ADR-0024: per-target ADR renumbering breaks the cross-target decision
graph. So the only open question is *where the single central log lives* once the
top-level `docs/` tree is dissolved — not whether to decentralize it.

## Decision

1. **`docs/adr/` → `adr/`** at the repository root. A focused, single-purpose
   top-level directory holding only the global ADR log.
2. This does **not** violate REFACTOR §10. §10 forbids a *large top-level `docs/`*
   that re-centralizes substantive design documentation; ADRs are §10/ADR-0024's
   explicit carve-out (a cross-domain decision graph owned by no single domain), and
   `adr/` is small and single-purpose, not a `docs/` tree.
3. Global sequential numbering and the existing filenames are preserved; only the
   parent path changes. All `docs/adr/NNNN…` cross-references in code and docs are
   rewritten to `adr/NNNN…` as a one-time mechanical sweep (the skeleton's
   `co-locate-docs` work leaf).

## Considered options

- **`semantic/docs/adr/`** (rejected). REFACTOR §9 shows `semantic/docs/`, but ADRs
  are not semantic-domain-specific — e.g. ADR-0034 is SBCL-specific, ADR-0021 is
  Gerbil-specific. Burying a cross-cutting log inside one domain conflates "decisions"
  with that domain's "meaning vocabulary" and hides target-flavoured ADRs under
  `semantic/`.
- **Keep `docs/adr/`** (rejected). Lowest churn (no cross-ref rewrite), and a `docs/`
  holding *only* `adr/` is arguably within §10's spirit — but it leaves a top-level
  `docs/` directory standing, which §10 and success-criterion §45.7 read against, and
  invites later re-accretion of other docs into it.

## Consequences

- A future reader asking "why is there a top-level `adr/` when §10 bans a top-level
  `docs/`?" is answered here: ADRs are the deliberate central exception.
- `adr/` establishes the pattern for genuinely cross-cutting *record* artifacts that
  belong to no single domain; PRDs (today `docs/prd/`) follow the same logic toward a
  root `prd/`, decided in the `co-locate-docs` work leaf.
- One-time cost: ~45 `docs/adr/` cross-references rewritten. After that the path is
  stable.

See `REFACTOR.md` (§10, §11, §45.7), ADR-0024, `CONTEXT.md` ("Documentation
structure"), and the grove `structural-refactoring` skeleton node brief
(`skeleton-k2`).

# portfolio-coverage-tie-in-k85

**Kind:** work

## Goal

The last ws7 deliverable: the **portfolio index + conformance/coverage tie-in**.
Rewrite the `apps/macos/docs/` portfolio index over the finalized portfolio (per app:
its app-kind, the pattern-kinds it exercises, suite + run status) and tie app
coverage into the ws6 conformance machinery so per-target app status is *derivable*,
not hand-maintained (constraint 4).

## Context

- The ws6 seam: `targets/<t>/conformance/<platform>.apiw` (authored judgment) +
  `apianyware-conformance` (derived coverage) already reference app-implementations
  and binding tests; this leaf makes the **apps side** legible — the portfolio index
  points at the derived reports rather than duplicating them.
- The app↔app-kind binding + exercised pattern-kinds live in description prose
  (D3 — no machine manifest); revisit D3's "IF a real machine consumer materializes"
  test here: if the coverage tie-in *is* that consumer, a machine `app.apiw` manifest
  becomes its own follow-on leaf — decide, don't absorb.
- **Roster edges to settle:** `modaliser` (the AppSpec-v1 app; `knowledge/` is
  untracked/dangling — D1's relocation was overtaken by the D2 greenfield finding) —
  give it a place or record why not; `swift-native-method-probe` (impls exist under
  all four targets, no `apps/macos/` dir) — include or record why not.

## Done when

The portfolio index is current over all apps; coverage is derivable via the
conformance tooling; the roster edges are settled + recorded. This closes the node
k62 "Done when" — on this leaf's retirement the ws7 cascade fires (confirm with the
user before treating k62 as done). Commit names `portfolio-coverage-tie-in-k85`.

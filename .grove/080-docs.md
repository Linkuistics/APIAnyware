# 080-docs

**Kind:** work

## Goal

Complete the per-language documentation (guide Step 9, ADR-0024) — the target is
**not done until docs exist in the canonical structure**:
`generation/targets/sbcl/README.md`, `docs/reference.md` (FFI/`sb-alien`, the MOP
object model, dispatch, lifetime, callbacks/threading, distribution section),
`docs/developer-guide.md` *only if warranted*, `docs/design/` (all build-time
specs), `docs/research/` (the 020 survey if co-located), per-app `learnings.md` +
`test-results/<app>/report.md` (from 060). Confirm the **CL-family contract spec**
is in its decided (likely main-tier) location. Update the repo-root `README.md`
Current Status with the `sbcl` target. Confirm all target ADRs are in central
`docs/adr/`.

## Context

Most of these accrue during 030–070; this leaf fills remaining slots and confirms
the unit is self-describing. Model on `generation/targets/gerbil/` docs.

## Done when

- Every canonical doc slot filled; repo README updated; ADRs central.

## Notes

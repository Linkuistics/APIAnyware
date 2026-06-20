# 080-docs

**Kind:** work

## Goal

Complete the per-language documentation (guide Step 9, ADR-0024) — the target is
**not done until docs exist in the canonical structure**:
`generation/targets/sbcl/README.md`, `docs/reference.md` (FFI/`sb-alien`, the MOP
object model, dispatch, lifetime, callbacks/threading, distribution section),
`docs/developer-guide.md` *only if warranted*, `docs/design/` (the **SBCL target
design spec already lives there** — `2026-06-20-sbcl-target-design.md`; add any
build-time specs from 040–070), `docs/research/` (the 020 survey + the MOP/threading
spikes already co-located). per-app `learnings.md` + `test-results/<app>/report.md`
(from 060). The **CL-family contract spec** is confirmed **main-tier**
(`docs/specs/2026-06-20-cl-family-interface-contract.md`, ADR-0033/0024). Update the
repo-root `README.md` Current Status with the `sbcl` target. All target ADRs are
central in `docs/adr/` — **0033–0038** (family contract, object model, callbacks,
lifetime, conditions, trampoline) — confirm.

## Context

Most of these accrue during 030–070; this leaf fills remaining slots and confirms
the unit is self-describing. Model on `generation/targets/gerbil/` docs.

## Done when

- Every canonical doc slot filled; repo README updated; ADRs central.

## Notes

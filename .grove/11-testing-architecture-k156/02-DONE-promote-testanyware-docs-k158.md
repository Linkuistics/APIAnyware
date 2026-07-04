# promote-testanyware-docs-k158

**Kind:** work

## Goal

Promote the two **parked** testing docs from `semantic/docs/testing/` into the new top-level
`testing/` home (created by `test-model-k157`), **de-staling** them as they move, retire the old
location, and fix the five inbound references. Closes the `co-locate-docs-k9` (skeleton) parking
promise — `semantic/docs/testing/general.md` self-flags *"expect this to move [in ws9]."*

## Context

Two files move (both currently tracked under `semantic/docs/testing/`):

- `general.md` → **`testing/testanyware-workflow.md`** — the TestAnyware GUI-testing methodology.
  **De-stale on the way:** the memory [[reference_testanyware_cli]] records that the in-repo copy is
  stale — `testanyware` is now the **brew-installed** unified driver (`guivision`/`GUIVisionVMDriver`
  is retired/absorbed, per [[feedback_use_testanyware]]). Reconcile the doc to the current CLI:
  VM-provisioning + chunked upload + `open -n` launch. Strip the "Parked location" banner (it has
  arrived). Cross-link back to `testing/test-model.md` (layers 8/9 — the AppSpec/GUI executor).
- `strategies/modal-overlay-apps.md` → **`testing/strategies/modal-overlay-apps.md`** — a testing
  strategy; carry it across (skim for staleness, but it is strategy prose, likely fine).

**Retire the old home:** `git rm` the now-empty `semantic/docs/testing/` (both files + the dir).

**Fix the five inbound references** (found via `grep -rl 'semantic/docs/testing'`):
`CONTEXT.md`, `TODO.md`, `README.md`, `targets/racket/app-implementations/macos/README.md`,
`targets/_shared/docs/adding-a-language-target.md`. Repoint each at the new `testing/` path. Note
the `CONTEXT.md` hit is inside the ws9 "Test model" glossary entry (added in the k156 commit) — check
whether it already points at `testing/` or still needs updating.

**Do NOT** author the federation model here — that is `test-model-k157`. This leaf is a **move +
de-stale + reference-fix** only.

## Done when

- Both docs live under `testing/` (de-staled); `semantic/docs/testing/` no longer exists.
- All five inbound references resolve to the new paths (`grep -r 'semantic/docs/testing'` returns
  nothing outside `.grove/` history).
- `make validate` green; **no golden changed**. One focused commit naming `promote-testanyware-docs-k158`.

## Notes

- Golden-neutral (docs only). Use `git mv` so history follows the files.
- If `test-model-k157` has not yet created `testing/`, create the dir here — the two leaves are
  order-independent on the home dir (either may `mkdir testing/`).

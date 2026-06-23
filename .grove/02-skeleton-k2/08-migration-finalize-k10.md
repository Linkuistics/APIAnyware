# migration-finalize-k10

**Kind:** work

## Goal

Close out the skeleton: clean up emptied scaffolding, leave the migration breadcrumbs,
and prove the whole tree green.

- **Remove the emptied phase dirs** `collection/ analysis/ generation/` (now empty
  after k5/k6/k7/k8). Verify nothing stray remains (`git status`, `find`).
- **Author the post-merge migration note** — a root `MIGRATION.md` (or a README
  section) documenting the one remaining manual step: rename the physical directory
  `~/Development/APIAnyware-MacOS` → `~/Development/APIAnyware` *after* this grove
  merges to `main` and its worktree is removed (root brief Notes; cannot be done from
  inside the worktree). Note any tool/IDE/path config that references the old absolute
  path.
- **TODO sweep (§40.16):** confirm every deferred decision left a `TODO:` marker
  (annotation `.apiw` reshape→ws5, per-target `Package.swift`→ws6, testing docs→ws9,
  pattern-kinds/schemas content→ws2/3/8); collect them into a `TODO.md` index or verify
  the existing `TODO.md` lists them.
- **Final green sweep:** `cargo build && cargo test && cargo fmt --all`, the
  annotation-drift check, and each target's smoke — all green from the new tree.
- **Confirm §45 success criteria hold structurally** (1 rename, 2 platforms/macos,
  3 targets/<t>, 4 apps/<platform>, 5 app-implementations, 6 docs-local, 7 README-map,
  8–9 extensible, 10 projection-free-platforms [structurally; content is ws2/4],
  11 app-specs-target-independent [structurally], 12 adapters-as-artifacts, 13 obvious
  homes, 14 no-inference-needed).

## Context

See node brief — this is the node's last leaf; on its retirement the node `skeleton-k2`
is done and the next root workstream (item 2, spec-format/data-model) is grown. Promote
any still-live SC decisions to the root brief / ADRs / glossary at node retirement.

## Done when

Phase dirs gone; `MIGRATION.md` + TODO index present; full build+test+fmt+drift+smokes
green; §45 criteria confirmed; committed as `migration-finalize-k10`.

## Notes

This leaf does **not** merge the grove — that's the grove Finish cycle (proposed to the
user after all leaves retire). The physical `mv` is explicitly *not* done here (it's the
post-merge manual step). Keep `cargo fmt --all` + a `style:` commit habit in mind if
drift appears.

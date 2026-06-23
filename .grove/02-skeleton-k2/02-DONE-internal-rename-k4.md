# internal-rename-k4

**Kind:** work

## Goal

SC7: rename the project internally `APIAnyware-MacOS` → `APIAnyware` with **no path
changes** (an isolated, pure find-replace leaf). Surface:

- Cargo `[package] name`: `apianyware-macos-*` → `apianyware-*` (all ~20 crates).
- The 3 bin names: `apianyware-macos-{collect,analyze,generate}` →
  `apianyware-{collect,analyze,generate}`.
- Root `[workspace.dependencies]` keys + their `path` is **unchanged** (paths move in
  later leaves); only the dep *key names* rename.
- Rust `use apianyware_macos_*` underscore forms → `apianyware_*` (the lib names track
  the renamed package names).
- Literal `APIAnyware-MacOS` identity strings (~59) in README/docs/scripts/Makefile.

Do **not** rename: the per-target Swift module names `APIAnyware<T>` (target binding
modules, not the project name); bundle IDs `com.linkuistics.*` (unrelated). Do **not**
rename the physical dir — that is a post-merge manual step (k10 migration note).

## Context

See node brief (SC7) + the crate→domain map. Sized ~435 `apianyware-macos` + ~59
`APIAnyware-MacOS` occurrences (verified during planning). Pure mechanical sweep;
grep both hyphen (TOML/docs) and underscore (Rust) forms.

## Done when

No `apianyware-macos`/`apianyware_macos`/`APIAnyware-MacOS` occurrences remain (except
the still-named physical worktree path itself); `cargo build && cargo test &&
cargo fmt --all` green; committed as `internal-rename-k4`.

## Notes

Verify the 3 renamed binaries still invoke (`cargo run -p apianyware-collect -- --help`
etc.). `cargo fmt --all` per the global-fmt habit.

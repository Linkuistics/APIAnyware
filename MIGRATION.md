# MIGRATION — one remaining manual step after the structural refactor merges

The `structural-refactoring` grove renamed the project **internally** from
`APIAnyware-MacOS` to `APIAnyware` (Cargo package names `apianyware-macos-*` →
`apianyware-*`, the three binary names, Rust `use apianyware_macos_*` paths, and
literal `APIAnyware-MacOS` identity strings) and re-architected the tree into the
five domains (`semantic/`, `platforms/`, `apps/`, `targets/`, `schemas/`).

One step it **could not** perform remains: renaming the **physical directory on
disk**.

## Why it cannot be done by the grove

This grove runs in a git worktree that lives *inside* the directory being
renamed:

```
~/Development/APIAnyware-MacOS/.grove-worktrees/structural-refactoring   ← the grove's worktree
~/Development/APIAnyware-MacOS                                            ← the dir to rename
```

A process cannot rename the directory that contains its own working tree, and
the worktree is administratively linked to the main checkout by absolute path.
The rename must therefore happen **after** the grove merges to `main` and its
worktree is removed (both are done by the grove's Finish cycle), with no Claude
Code session holding the tree open.

## The step (run by hand, after merge + worktree removal)

```sh
# 1. Confirm the grove has merged and its worktree is gone:
git -C ~/Development/APIAnyware-MacOS worktree list      # no structural-refactoring entry
git -C ~/Development/APIAnyware-MacOS log --oneline -1   # the merge commit

# 2. Close every editor / shell / Claude Code session with a cwd inside the dir.

# 3. Rename:
mv ~/Development/APIAnyware-MacOS ~/Development/APIAnyware

# 4. Verify the repo still works from the new path:
cd ~/Development/APIAnyware && SDKROOT=macosx cargo build --workspace
```

Git itself needs nothing fixed: `.git` is internal to the directory, so the
remote, history, and refs all move with it. Only things that hold the **absolute
path** from *outside* the repo need attention (below).

## External references to the old path / name (host-side, not in this repo)

These live outside the git tree and will **not** follow the `mv` automatically:

- **Claude Code project state** — session transcripts and the persistent
  auto-memory are keyed on the absolute path under
  `~/.claude/projects/-Users-antony-Development-APIAnyware-MacOS/`. After the
  rename a fresh session in `~/Development/APIAnyware` opens a new, empty
  project dir (`…-Development-APIAnyware`). To carry history/memory forward,
  rename that host-side dir to match the new path, or copy `MEMORY.md` +
  `memory/` across. (Untracked host state — handle once, manually.)
- **Shell / tool config** — any alias, `cd` shortcut, `SDKROOT` wrapper, IDE
  "recent projects" entry, or scheduled task pointing at
  `~/Development/APIAnyware-MacOS`. No tracked IDE workspace files exist in this
  repo, so this is limited to your personal environment.

## Optional, separate: the GitHub repository name

`website/meta.yml` records `github_url:
https://github.com/Linkuistics/APIAnyware-MacOS`. Renaming the **GitHub repo**
(`APIAnyware-MacOS` → `APIAnyware`) is an independent decision from the local
directory `mv` — GitHub keeps the old URL as a redirect, so nothing breaks if it
is deferred. When/if the GitHub repo is renamed, update `website/meta.yml` and
the `origin` remote in the same pass. It is **not** changed now, because editing
the URL before the repo is actually renamed would make it wrong.

## What was intentionally *not* changed

Literal `APIAnyware-MacOS` strings remaining in the tree are **historical
records** — `REFACTOR.md` (which describes this very rename), dated design docs
and plans under `process/` and `*/docs/`, and captured spike-output `.txt`
files. Rewriting them would falsify the record; they stay as-is. Only live,
operational identity (package/binary names, import paths, build config) was
renamed.

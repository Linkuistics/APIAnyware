# grove — materialised version

A materialised copy of the `grove` skill: plain files committed in this repo.
This file records where the copy came from and how to refresh it.

| | |
|---|---|
| grove source | `Linkuistics/skills@9a35d52` |
| bundled conventions | `mattpocock/skills@b8be62ffacb0118fa3eaa29a0923c87c8c11985c` |
| materialised on | 2026-05-23 |
| materialised into | `.claude/skills/grove/` |

## Updating

From a `Linkuistics/skills` clone, checked out at the ref you want to pin:

```
scripts/materialise-grove.sh <path-to-this-repo> [<ref>]
```

Review the resulting diff and commit it. By discipline, record the bump in an
ADR (`docs/adr/`).

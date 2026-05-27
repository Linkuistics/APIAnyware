# Knowledge Base

This directory contains all project learnings organised by axis. It is the
single source of truth for discoveries made during implementation.

## Axes

| Axis         | Path              | What goes here                                          |
|--------------|-------------------|---------------------------------------------------------|
| Pipeline     | `pipeline/`       | Collection/analysis discoveries that affect all targets |
| TestAnyware  | `testanyware/`    | GUI testing strategies, reusable across apps/targets    |
| Apps         | `apps/{app}/`     | App specs, language-independent learnings, test strategies |
| Targets      | `targets/{target}.md` | Target-wide learnings (FFI patterns, runtime quirks) |
| Matrix       | `matrix/{app}/{target}.md` | Discoveries specific to one app in one target    |

## Rules

- **Never duplicate** — if a learning applies to a broader axis, put it there,
  not in a narrower file
- **Date entries** — prefix with `**YYYY-MM-DD:**` so staleness is visible
- **Promote eagerly** — if a matrix learning turns out to be target-universal,
  move it up
- **Priority codes** — use 🔴 (critical), 🟡 (useful), 🟢 (informational) on
  all entries

## Project workflow

APIAnyware-MacOS is a matrix project: N language *targets* × M sample *apps*.
A target is a language+paradigm combination (e.g. `racket`) with its own
emitter crate, runtime, generated output, and apps.

- **Adding a target** — see `docs/adding-a-language-target.md`.
- **Adding an app** — create `knowledge/apps/{name}/` (`spec.md`,
  `learnings.md`, `test-strategy.md`), add it to `knowledge/apps/_index.md`,
  and for each target create the app directory and a
  `knowledge/matrix/{app}/{target}.md` file.
- **Pipeline changes** — when app or generation work reveals a collection or
  analysis bug, fix it in the core pipeline, regenerate the affected targets,
  and capture the learning in `knowledge/pipeline/{area}.md`.

# Project Workflow

## Overview

APIAnyware-MacOS is a matrix project: N targets x M apps, generating idiomatic macOS
bindings for non-mainstream languages.

A **target** is a language+paradigm combination — a top-level directory with its own
emitter crate, runtime, apps, tests, and generated output. `racket-oo` and
`racket-functional` are independent targets, just like `racket-oo` and `haskell-monadic`.

Apps progress from simple (hello-window) to complex (menu-bar-tool), culminating in
Modaliser as the capstone proving a target's bindings are production-ready.

## Plans and Progress

- `LLM_STATE/overview.md` — at-a-glance status dashboard
- `docs/specs/2026-05-20-core-pipeline-hardening-design.md` and
  `docs/superpowers/plans/2026-05-20-core-pipeline-hardening.md` — the core
  pipeline (collection, analysis, generation)
- `LLM_STATE/targets/{target}/backlog.md` — per-target backlogs (still on the
  Ravel-Lite phase cycle)

Core pipeline and target plans are independent. If a target needs a pipeline
feature, file it against the core pipeline plan.

## The Knowledge System

Knowledge is captured along five axes:

| Axis | Path | What goes here |
|------|------|----------------|
| Pipeline | `knowledge/pipeline/` | Collection/analysis discoveries affecting all targets |
| TestAnyware | `knowledge/testanyware/` | GUI testing strategies, reusable across apps/targets |
| Apps | `knowledge/apps/{app}/` | App specs, language-independent learnings, test strategies |
| Targets | `knowledge/targets/{target}.md` | Target-wide learnings (FFI patterns, runtime quirks) |
| Matrix | `knowledge/matrix/{app}/{target}.md` | Discoveries specific to one app in one target |

See `knowledge/CLAUDE.md` for the full rules.

CLAUDE.md files in target and app directories route to the relevant knowledge files
automatically. This is the only mechanism that guarantees context loading.

## Adding To The Matrix

### Adding a new target
See `LLM_STATE/new-language-guide.md` for the 11-step checklist. Use
`LLM_STATE/targets/template.md` to create the target's plan.

### Adding a new app
1. Create `knowledge/apps/{name}/` with spec.md, learnings.md, test-strategy.md
2. Update `knowledge/apps/_index.md`
3. For each existing target: create app directory with CLAUDE.md, create matrix knowledge file

## App Bundling

Apps needing macOS TCC permissions (Accessibility, Camera, etc.) must be packaged as `.app`
bundles with per-app Swift stub launchers. Use `apianyware-macos-stub-launcher`
(`generation/crates/stub-launcher/`) — it generates a tiny Swift binary per app that
`execv`s into the language runtime, giving each app a unique CDHash for independent TCC
permission management. See CLAUDE.md's [App Bundling](#app-bundling) section for the API.

## GUI Testing With TestAnyware

Never run apps directly from the CLI. Use the TestAnyware VM workflow:
```bash
../TestAnyware/.build/release/testanyware vm start --share ./generation/targets/{target}:{target}
../TestAnyware/.build/release/testanyware exec "..."
../TestAnyware/.build/release/testanyware vm stop
```

See `knowledge/testanyware/general.md` for the full workflow.

When transferring files to the VM, use base64 encoding — VirtioFS can serve stale content.
Always `pkill -9 -f racket` (or equivalent) before relaunching apps.

## Pipeline Changes

When app/generation work reveals pipeline bugs:
1. Note the issue in the target plan (mark task blocked if necessary)
2. File a task against the core pipeline plan (`docs/superpowers/plans/`)
3. Fix in a core pipeline session
4. Re-generate affected targets
5. Capture the learning in `knowledge/pipeline/{area}.md`

## Coding Standards

See `README.md`'s Coding Conventions section.

Key points: TDD, descriptive names, small files, `thiserror`/`anyhow`, `tracing`,
bounded channels, no `unwrap`/`expect`, `cargo +nightly fmt`.

## App Progression

See `knowledge/apps/_index.md` for the full catalogue. Simple -> complex -> Modaliser capstone.
Each app exercises specific macOS/binding capabilities.

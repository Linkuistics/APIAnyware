# TestAnyware QA Workflow

LLM-driven GUI testing of generated sample apps using TestAnyware.

## Overview

TestAnyware is a screenshot-driven GUI testing tool for macOS VMs, designed for LLM automation. The workflow is:

1. Boot macOS VM with sample apps shared in
2. Build and launch the sample app
3. LLM agent uses TestAnyware's screenshot -> think -> act -> verify loop
4. Agent autonomously explores the app, comparing against the spec
5. Issues found -> fix bindings/runtime/app, re-test
6. Continue until app matches spec

This is LLM-driven autonomous QA, not scripted test automation.

## Prerequisites

- **TestAnyware dev build** from `../TestAnyware/`
  - Build: `cd ../TestAnyware && swift build`
  - Binary: `../TestAnyware/.build/debug/testanyware`
  - Can fix bugs in-place (see `../TestAnyware/docs/driver-project-setup.md`)
- **macOS VM** configured and accessible via TestAnyware
- **Generated bindings** in `generation/targets/{lang}/generated/`
- **Runtime library** in `generation/targets/{lang}/runtime/`
- **Sample app source** in `generation/targets/{lang}/apps/{style}/`

## Step-by-Step

### 1. Start the VM

```bash
../TestAnyware/.build/debug/testanyware vm start
```

This boots the macOS VM, starts the TestAnyware server, and opens the VNC viewer.

### 2. Share the app directory

The VM needs access to the sample app files. Share the language target directory:

```bash
../TestAnyware/.build/debug/testanyware vm start --share ./generation/targets/{lang}:apps
```

Inside the VM, the shared directory appears at a mount point accessible to the build system.

### 3. Build the sample app

Inside the VM (via TestAnyware commands), build the app:

- **Racket:** `racket generation/targets/racket/apps/oo/hello-window/main.rkt`
- **Haskell:** `cabal run hello-window` (from app directory)
- **Zig:** `zig build run` (from app directory)

Each language has its own build system. The app should be runnable from the command line.

### 4. Launch and test

The LLM agent drives the testing loop:

```
screenshot -> analyze -> act -> screenshot -> verify -> repeat
```

For each sample app:

1. **Launch the app** via TestAnyware
2. **Take initial screenshot** — verify window appears with correct title/layout
3. **Walk through validation steps** from `generation/apps/tests/{app}-test.md`
4. **For each step:**
   - Take screenshot
   - Analyze: does the current state match the expected behavior?
   - Act: click buttons, type text, interact with controls
   - Verify: take screenshot, confirm result matches expectation
5. **Report issues** — if behavior doesn't match spec, categorize as:
   - **Binding bug:** Generated code is wrong (fix emitter)
   - **Runtime bug:** Runtime library issue (fix runtime)
   - **App bug:** Sample app implementation issue (fix app code)
   - **TestAnyware bug:** Testing tool issue (fix in `../TestAnyware/`)
6. **Fix and re-test** — apply fix, rebuild, re-launch, continue from where the issue was

### 5. Document results

After testing each app, record:

- **Status:** Pass / Fail / Pass-with-fixes
- **Screenshots:** Key screenshots as evidence (stored in `generation/targets/{lang}/test-results/`)
- **Issues found:** What broke and how it was fixed
- **Binding/runtime changes:** Any fixes made during testing

## Test Artifact Conventions

```
generation/targets/{lang}/test-results/
  {style}/
    {app-name}/
      screenshot-001-launch.png
      screenshot-002-interaction.png
      ...
      report.md                   # Test results summary
```

### Report Format (`report.md`)

```markdown
# {App Name} — {Language} {Style} Test Report

**Date:** YYYY-MM-DD
**Status:** Pass | Fail | Pass-with-fixes

## Steps Completed
- [x] Step 1 description
- [x] Step 2 description
- [ ] Step 3 (failed — see Issues)

## Issues Found
### Issue 1: {title}
- **Category:** Binding bug | Runtime bug | App bug | TestAnyware bug
- **Description:** What went wrong
- **Fix:** What was changed
- **Screenshots:** screenshot-003.png (before), screenshot-004.png (after)

## Notes
Any additional observations...
```

## Fixing TestAnyware In-Place

If TestAnyware has a bug or missing feature during testing:

1. Read `../TestAnyware/CLAUDE.md` for architecture
2. Fix the issue in `../TestAnyware/` source
3. Rebuild: `cd ../TestAnyware && swift build`
4. Restart server: `../TestAnyware/.build/debug/testanyware vm stop && ../TestAnyware/.build/debug/testanyware vm start`
5. Continue testing

Keep fixes focused. Commit TestAnyware fixes separately from APIAnyware-MacOS changes.

## Testing Order

For each language, test apps in complexity order (1-7). Each app builds on patterns from simpler apps:

1. **Hello Window** — verifies basic binding infrastructure works
2. **Counter** — verifies target-action / callback mechanism
3. **UI Controls Gallery** — visual regression baseline for all controls
4. **File Lister** — verifies delegate protocols and collections
5. **Text Editor** — verifies complex patterns (blocks, error-out, notifications)
6. **Mini Browser** — verifies cross-framework (WebKit) integration
7. **Menu Bar Tool** — verifies non-standard app lifecycle (no window)

If Hello Window fails, do not proceed to Counter — fix the foundation first.

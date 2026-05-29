# 160-chez-bundle-version-coupling

**Kind:** work

## Goal
Decouple a chez `.app` bundle from the exact Chez Scheme version that
precompiled it — or make the mismatch fail loudly / recover — so a vanilla
TestAnyware-provisioned VM can launch the shipping bundle without a manual
chez swap.

## Context
Surfaced during `130-port-note-editor`'s VM-verify (see
`generation/targets/chez/test-results/note-editor/report.md`, Issue 1).

- The bundler precompiles `.sls` → `.so` with the **dev host's** Chez
  (10.4.1). Chez refuses to load a `.so` compiled by a different version.
- The golden image ships no Chez; `brew install chezscheme` now pours
  **10.3.0** (mini-browser's 2026-05-29 report got 10.4.1 from the same
  formula — the available bottle moved). So a freshly provisioned VM cannot
  launch the precompiled bundle: every `.so` is rejected.
- This run's workaround: copy the host's relocatable 10.4.1 Cellar (5.4 MB,
  system-dylib-only links) into the VM and repoint `/opt/homebrew/bin/chez`.
  Every future sample-app VM-verify (140 drawing-canvas next) hits the same
  wall and needs the same manual step.
- Bundler: `generation/crates/bundle-chez/src/{bundle.rs,precompile.rs}`.
  Launcher: the stub-launcher `execv`s `/opt/homebrew/bin/chez`. Runtime
  dylib resolver: `apianyware/runtime/ffi.sls`.

## Done when
- A chez bundle launches on a vanilla provisioned VM with no manual chez
  version swap. Acceptable shapes (decide during the task):
  1. **Pin the VM/golden image** to the bundler's Chez version (simplest;
     may belong in the TestAnyware golden-image scripts, not this repo).
  2. **Version-stamp + fall back:** bundler records the precompiling Chez
     version; the launcher (or `ffi.sls`) detects a mismatch and falls back
     to loading raw `.sls` (slow cold launch, but works) instead of crashing.
  3. **Ship `.sls` only** when targeting an unknown-version VM (a bundler
     flag), trading the ~75 s cold launch for version independence.
- The chosen shape is documented in `knowledge/targets/chez.md` (leaf 150)
  so later ports stop re-discovering it.

## Notes
- Not a binding or app bug — purely bundler/provisioning. Does not block the
  remaining sample-app ports (140) as long as the verifier applies the
  documented host-chez-copy workaround.
- Candidate overlaps with the 050 brief's existing follow-up note: "VM
  provisioning … brew install chezscheme once per VM clone … Candidate
  follow-up: pre-install in the golden image." This leaf extends that to
  the *version-match* requirement, which is the load-bearing part.

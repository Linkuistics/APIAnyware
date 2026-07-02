# sbcl-vendor-libzstd-k75

**Kind:** work

## Goal

Make the sbcl `.app` bundles fully self-contained by vendoring `libzstd.1.dylib` (the
SBCL core's zstd compression dependency) into the bundle. Finding carried back from the
hello-window Tier-2 live run (k73): the sbcl `hello-window` binary links
`/opt/homebrew/opt/zstd/lib/libzstd.1.dylib` by **absolute path**, absent in a vanilla
VM — the run had to stage the host dylib manually.

## Context

- The sbcl bundler (`targets/sbcl/tools/bundle-sbcl`) already vendors
  `libAPIAnywareSbcl.dylib`; extend the same mechanism to libzstd
  (`install_name_tool` repoint to `@executable_path`/`@rpath`).
- The pattern to mirror is gerbil's: it vendors `libssl.3`/`libcrypto.3` via
  `@executable_path` and is genuinely self-contained (k73). chez needs nothing.

## Done when

- The rebuilt sbcl hello-window `.app` has no absolute Homebrew link (`otool -L` clean)
  and launches in a vanilla VM with **no** staged libzstd.
- The hello-window AppSpec suite re-runs green against it (3/3) — the suite + run
  workflow already exist (`apps/macos/hello-window/scenarios/`, AppSpec
  `capabilities/run/workflow.md`). The VM re-run is the done-bar, not `otool` alone
  ([[vm_verify_every_app]]).
- `apps/macos/hello-window/docs/run-results.md`'s sbcl build finding updated.
- Commit names `sbcl-vendor-libzstd-k75`.

## Notes

Source finding: `.grove/08-app-model-k62/11-DONE-appspec-hello-window-live-run-k73.md`.
This is target-build work homed under ws7 because the need is AppSpec-run portability
(every remaining per-app live run benefits).

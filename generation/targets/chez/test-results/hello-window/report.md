# Hello Window — Chez Test Report

**Date:** 2026-05-28
**Status:** Pass-with-fixes

## Steps Completed
- [x] Launch app — window appears after ~75s first-launch compile of `apianyware/appkit.sls`
- [x] Window title "Hello from Chez"
- [x] Window 400×200 content (400×232 with title bar), roughly centred
- [x] "Hello, macOS!" label visible, centred, large (24pt system font)
- [x] Window close button present and clickable; closes the window
- [x] Cmd+Q quits the process cleanly (no stderr, exit 0)
- [x] No rendering artifacts; standard white system background
- [x] Idle RSS flat at ~1.22 GB over 16s — no unbounded growth (the 1.22 GB
      baseline is Chez's in-memory representation of the 70k-line
      `appkit.sls` library after on-demand compile)
- [~] Window close → app termination: window closes but chez stays alive,
      same as the racket port. Neither hello-window implements
      `applicationShouldTerminateAfterLastWindowClosed`. Parity with the
      bar; not a chez-only regression.

## Issues Found
### Issue 1: Bundled chez runtime cannot find `libAPIAnywareChez.dylib`
- **Category:** Runtime bug
- **Description:** `runtime/ffi.sls` resolved the dylib via two
  CWD-relative paths (`generation/targets/chez/lib/...` and
  `../lib/...`). The dev-host CLI smoke from leaf
  `030-port-hello-window-app` happened to work because CWD was the repo
  root and the first candidate matched. In a `.app` bundle launched via
  `open -n`, neither path resolves: chez aborts mid-compile with
  `Exception in apianyware-runtime-ffi: could not locate
  libAPIAnywareChez.dylib`. CLI smoke had a false-positive failure mode
  that only VM verification exposes — exactly the motivation for the
  per-app VM-verify policy ([[feedback-vm-verify-every-app]]).
- **Fix:** `resolve-dylib-path` now walks `(library-directories)` and
  probes `<libdir>/lib/libAPIAnywareChez.dylib`. Subsumes both layouts:
  unbundled (`--libdirs generation/targets/chez/` → repo dylib) and
  bundled (`--libdirs <Resources>/chez-app/` → bundled dylib). One
  mechanism for both call sites; no environment injection or stub
  changes needed. Removed the obsolete `default-dylib-candidates`.
- **Screenshots:** screenshot-001-launch.png, screenshot-002-window.png
  (post-fix); pre-fix the screen was the empty desktop.

## Notes
- Menu-bar app name reads as "chez" instead of "Hello Window" because the
  stub launcher `execv`s into `/opt/homebrew/bin/chez` and macOS reads
  the active process's name. The racket port has the identical
  behaviour (menu bar reads "racket"); not a chez-specific regression.
  If we want bundled-app menu-bar names someday, the fix is in the
  stub-launcher / runtime, not per-app.
- First-launch compile cost is ~75s on the dev host, similar in the
  VM. Chez does not cache `.so` files for `--script` invocations, so
  every cold launch pays this cost. Pre-compiling the bundled
  `.sls` files into `.so`s during bundling would eliminate it —
  candidate follow-up for the bundler.
- VM provisioning: the macOS golden image does not ship Chez Scheme,
  so the test run had to `brew install chezscheme` once before launching.
  A future improvement is to pre-install the runtime in the golden
  image, parallel to whatever provisioning the racket port relies on.

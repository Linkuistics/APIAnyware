# Hello Window — Chez Test Report

**Date:** 2026-05-28
**Status:** Pass-with-fixes

> **Superseded by the standalone re-verification (2026-05-30) below.** The body
> of this report describes the **retired source-exec bundle** (stub-launcher
> `execv` into a system Chez, precompiled `.so` tree). Under ADR-0009 chez apps
> now ship as a self-contained open-world standalone binary; the
> source-exec-era caveats below (menu-bar reads "chez", `brew install
> chezscheme` provisioning, ~75s first-launch compile, 102 MB `.so` bundle) are
> **obsolete** — see the dated section at the end for the production result.

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
- **Update 2026-05-28 (leaf `105-precompile-bundled-libraries`).**
  The bundler now pre-compiles every staged library `.sls` to a
  sibling `.so`. Re-running this app's import set against the
  precompiled bundle (`chez --libdirs … --script /tmp/imports-only`
  covering `(apianyware appkit)`, `(apianyware foundation)`, and the
  three runtime libs the entry uses) on the dev host:
  **~70s → ~1.85s** — a 38× speedup, well under the leaf's 5s
  bar. Bundle size grew from 38 MB to 102 MB to carry the 838 `.so`
  files. VM verification of the launched bundle (re-take
  screenshot-001-launch.png, confirm "feels instant") is a separate
  leaf — CLI re-verification covered only that imports load fast,
  not that the GUI still draws correctly.
- VM provisioning: the macOS golden image does not ship Chez Scheme,
  so the test run had to `brew install chezscheme` once before launching.
  A future improvement is to pre-install the runtime in the golden
  image, parallel to whatever provisioning the racket port relies on.

---

## Standalone re-verification (2026-05-30, leaf `060/050/010`)

**Status: PASS.** First app of the standalone-portfolio node — re-verifies
`hello-window` as a **production open-world standalone `.app`** (ADR-0009), the
regression anchor for the per-app portfolio.

**Build.** `cargo run --release --example bundle_app -p
apianyware-macos-bundle-chez -- hello-window`. Fresh build (prior `030`/spike
output removed first). Output: `Hello Window.app`, **4.5 MB** total (3.5 MB
`Contents/Resources/hello-window.boot` whole-program boot + 164 KB bundled
`libAPIAnywareChez.dylib`), bundle id `com.linkuistics.HelloWindow`, signed
`APIAnyware Local Signing`. `otool -L` on the `MacOS/hello-window` binary shows
**no Chez/Scheme/petite linkage** — only system frameworks + `libSystem`,
`libiconv`, `libncurses`, `libz`. The kernel is statically baked in.

**VM verify (no-Chez bar).** Golden `testanyware-golden-macos-tahoe`, arm64,
macOS 26.3. Confirmed the VM ships **no Chez** (`which chez scheme petite` →
empty, no `/opt/homebrew/Cellar/chezscheme`). Uploaded the 3.2 MB tarball
(md5-verified), unpacked, `xattr -dr com.apple.quarantine`, launched via `open
-n`. Results:
- [x] Window appears, titled **"Hello from Chez"**, 400×232, centred.
- [x] **"Hello, macOS!"** label renders centred, large system font — no artifacts
      (`screenshot-standalone-window.png`, `screenshot-standalone-desktop.png`).
- [x] Traffic-light controls correct (close/minimize active, zoom disabled for
      the fixed-size window).
- [x] Launch log is the clean single line `Hello Window opened. …` — **banner
      suppressed** (spike F6 `(suppress-greeting #t)` holds in the production boot).
- [x] No system Chez present, yet the app runs — self-containment proven
      end-to-end.

**Obsoleted source-exec caveats (now resolved by the standalone model):**
- **Menu bar now reads "Hello Window"**, not "chez" — no `execv` into a system
  chez, so macOS reads the real process name. The 2026-05-28 menu-bar gotcha is
  gone for standalone bundles.
- **No `brew install chezscheme` provisioning** — the no-Chez VM is the bar, met
  with zero provisioning.
- **No ~75s first-launch compile, no 102 MB `.so` bundle** — the whole-program
  compile is a one-time *build*-time cost (~160s); the shipped bundle is 4.5 MB
  with a ~0.29s cold launch (spike figures, ADR-0009).

No divergence from the spike build (same size, same `Resources/` boot+dylib
layout). No code changes were needed for hello-window.

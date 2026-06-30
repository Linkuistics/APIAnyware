# hello-window x gerbil

**2026-06-30 (AppSpec `gerbil-instrument-build-k31`):**
- 🟢 **Instrumented to the AppSpec logging contract + built to `HelloWindow-gerbil.app`.**
  `hello-window.ss` now writes the structured events.log the scenario runner tails
  (`[lifecycle] startup`, the bare `Hello Window opened.`, `[lifecycle] shutdown reason=…`
  via an `applicationWillTerminate:` `make-delegate`), honours `HELLO_WINDOW_TEST_CONFIG`
  gracefully, and keeps the stdout line. `build.sh` drives the full `bundle-gerbil` bundle
  (was a bare-exe build) and post-processes the per-impl id
  (`com.linkuistics.hello-window-gerbil`). Logging logic validated standalone with `gxi`;
  `codesign --verify --strict` + `otool -L` clean. Live GUI/terminate behaviour is
  VM-deferred to the AppSpec acceptance grove's live-run child.
- **No dylib needed.** The terminate delegate's IMP routes through the clang `native_block.c`
  companion, **not** the Swift-native trampoline dylib (`aw_gerbil_swift_*`, ADR-0029) —
  hello-window's closure pulls no trampolines, so the bundle is `libAPIAnywareGerbil`-free
  and travels alone (+ vendored openssl). No live-VM provisioning beyond the `.app`.
- **Cold build ~6 min** (shards 97s ∥ · facade 9s · closure 53s · `gxc -exe` link 194s) —
  the exe's `libgambit.a` static link now dominates. The old **~5h** figure below is
  **superseded by ADR-0023**, which sharded the monolithic `generics.ss` into small
  no-`-O` modules compiled in parallel (the `075-generics-compile-cost` follow-up landed).
- **Toolchain gap:** the gerbil bottle's Gambit config hardcodes `C_COMPILER="gcc-15"`; the
  host had since upgraded Homebrew `gcc` to 16, so `gambuild-C` failed with `gcc-15: command
  not found`. Restored with `brew install gcc@15` (bottled). Recurs for every gerbil build
  until the gerbil bottle is rebuilt — a gerbil-toolchain/environment concern.

**2026-06-08 (leaf `070/040`):**
- 🟢 **PASS** — first proof the whole gerbil pipeline produces a working macOS GUI app.
  Self-contained `.app` (73 MB, `gxc -exe` static Gambit runtime + vendored openssl@3,
  `otool -L` dylib-clean) launches + renders correctly in a **no-Gerbil VM** (no
  provisioning). Window "Hello from Gerbil", centred 24pt "Hello, macOS!" label,
  standard app menu reading "Hello Window" (About/Hide/Quit), Cmd+Q quits clean. See
  `generation/targets/gerbil/test-results/hello-window/report.md`.
- ⚠️ Build-time only: the **cold** build took ~5h, dominated by `gsc -target C` + `gcc
  -O1` on the monolithic full-framework `generics.ss` (60 MB `.scm` → 94 MB `.c`, 9.7 GB
  gcc RSS). Runtime is unaffected. **Superseded by ADR-0023** (sharded generics — see the
  2026-06-30 entry above; the cold build is now minutes).

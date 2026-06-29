# hello-window x chez

**2026-05-28:**
- 🟡 Window + centered label render correctly — validated in TestAnyware VM
  after runtime fix for bundled dylib lookup. See
  `targets/chez/bindings/macos/reports/hello-window/report.md`.

**2026-05-30 (standalone, leaf `060/050/010`):**
- 🟢 Re-verified as a **production open-world standalone `.app`** (ADR-0009,
  4.5 MB, kernel baked in). Launches + renders correctly in a **no-Chez VM**
  (no provisioning); menu bar now reads "Hello Window", banner suppressed. See
  the "Standalone re-verification" section of the report.

**2026-06-29 (AppSpec instrument + build, chez child `chez-instrument-build-k29`):**
- 🟢 Instrumented to the **Hello Window logging contract**
  (`apps/macos/hello-window/docs/logging-contract.md`): writes the events.log the
  runner tails — `[lifecycle] startup` before the run loop, the bare
  `Hello Window opened.`, and `[lifecycle] shutdown reason=menu` from an
  `applicationWillTerminate:` delegate (the osascript graceful-quit path the
  runner's `quit-impl!` / scenario `03` exercise). Logging is **inlined** (not a
  sibling `events.sls`): chez resolves imports by library-name→path against the
  whole-program tree, so a sibling lib would need an `apps/`-prefixed name; the
  inline defines use only `(chezscheme)` names. Added `(apianyware runtime
  dispatch)` to the imports for `make-delegate` (proven safe — note-editor uses
  the same curated set). The logging functions verified in isolation against the
  contract matchers.
- 🟢 **Built via `build.sh`** (new, reproducible recipe): regenerates the chez
  bindings + adapter dylib if absent, bundles via `apianyware-bundle-chez`
  (whole-program compile, ~2:42), then renames to `HelloWindow-chez.app` and sets
  `CFBundleIdentifier=com.linkuistics.hello-window-chez` (PlistBuddy + re-sign).
  `codesign --verify --strict` passes. The k27 chez descriptor needed **no
  change** (build meets its `#:bundle-id`/`#:binary`). File I/O uses
  `open-file-output-port` (not `open-output-file`, which rejects buffer-mode +
  transcoder args). The built `.app` is gitignored (reproduced by `build.sh`).

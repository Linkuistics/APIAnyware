# hello-window x racket

**2026-03-31:**
- 🟡 Window + centered label render correctly — validated in TestAnyware VM

**2026-06-02 (Racket 9.2 + ffi2, native dispatch):**
- 🟢 Re-verified after the ffi2 / generated-native-dispatch (ADR-0013) migration.
  Window "Hello from Racket" + centered "Hello, macOS!" label render correctly;
  correct menu-bar app name via `CFBundleName`. TestAnyware VM (macOS 26.3).

**2026-06-29 (AppSpec acceptance test — instrument + build, leaf k28):**
- 🟢 Instrumented to the logging contract (`apps/macos/hello-window/docs/logging-contract.md`):
  new `events.rkt` (a narrowed de-Modalisered emitter) + `hello-window.rkt` now writes
  `[lifecycle] startup`, the bare `Hello Window opened.`, and `[lifecycle] shutdown reason=…`
  to the events.log the runner tails. Shutdown is wired via an `applicationWillTerminate:`
  delegate (`reason=menu`) plus an `uncaught-exception-handler` (`signal`/`error`).
  `events.rkt` verified in isolation against the contract matchers; the full module
  `raco make`-compiles in the bundled layout (the split `../../{generated,runtime}` requires
  only resolve there or via the bundler's `SourceRoots::split`, not in-tree).
- 🟢 Built via `build.sh`: regenerates the shared racket binding if absent
  (`apianyware-generate --target racket` + `swift build` the adapter dylib), bundles with
  `apianyware-bundle-racket`, then renames to `HelloWindow-racket.app` and sets
  `CFBundleIdentifier=com.linkuistics.hello-window-racket` to match the k27 descriptor
  (`hello-window-impl.rkt` `#:bundle-id`/`#:binary`). The cargo bundler derives the id from
  the spec H1 (`com.linkuistics.HelloWindow`), with no per-impl-id flag — so the four impls
  would collide in one VM without this post-process. Live launch is the acceptance test's
  `04-live-run` (VM); not exercised here (host-side, no WindowServer).

**2026-07-02 (self-contained bundle, leaf k76):**
- 🟢 Rebuilt with the production bundler's **self-contained mode**
  (`bundle_app_self_contained`: staged colocated tree → `raco exe` → `raco distribute` →
  relocatable stub execv'ing `Resources/racket-dist/bin/hello-window`). AppSpec suite re-ran
  **3/3 in a vanilla VM with nothing staged** (no Racket install, no `ffi2-lib`, no
  first-launch compile — k74 had provisioned all three). 82 MB `.app`, 17 MB gzipped upload.
- The enabling runtime change: `swift-helpers.rkt` / `ffi2-dispatch.rkt` locate
  `libAPIAnywareRacket.dylib` via `define-runtime-path` now — `raco exe` records the
  reference and `raco distribute` carries + rewrites it (the old
  `variable-reference->resolved-module-path` lookup baked the build machine's absolute path
  into the embedded bytecode). `define-runtime-path`'s expression form needs
  `(require (for-syntax racket/base))` — it evaluates at the transformer phase too.
- `build.sh` gained the k75-style re-sign after the PlistBuddy id edit (codesign seals
  Info.plist) and a self-containment gate (`otool -L` must show no `/opt/homebrew`;
  the dist must carry `libAPIAnywareRacket.dylib`).

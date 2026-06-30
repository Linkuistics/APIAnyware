# appspec-hello-window-gerbil-build-k71

**Kind:** work (cross-grove **record** — app data authored *into* this repo by the AppSpec toolkit grove
per ADR-0013; recorded here, not driven as an APIAnyware session)

## What this records

The **AppSpec toolkit grove**'s `impl-conformance-k23` node **finishes** authoring hello-window's app data
**into this worktree** (ADR-0013; the data's home is APIAnyware). This leaf records the **gerbil** build
child `gerbil-instrument-build-k31` — the **last** of the four per-impl instrument+build children
(k28–k31), landing after the sbcl build record [[08-DONE-appspec-hello-window-sbcl-build-k70]]. With it,
**all four hello-window impls are conformant + built**; the AppSpec node's long pole is complete.

## Authored in this commit (gerbil: instrument + build)

- **`targets/gerbil/app-implementations/macos/hello-window/hello-window.ss`** (modified) — wires the
  logging contract **inline** (Gambit primitives only — `open-output-file` / `getenv` /
  `create-directory` / `force-output` — so it needs **no new import** on the bundle-gerbil closure path,
  which walks only `:gerbil-bindings/…` refs; the chez inline precedent, not the racket `events.rkt`
  split, which would have to sit under the bindings root to be on `GERBIL_LOADPATH`). Emits
  `[lifecycle] startup` before the run loop, the bare `Hello Window opened.` after key+front (kept the
  stdout `displayln` too), honours `HELLO_WINDOW_TEST_CONFIG` gracefully, and an
  `applicationWillTerminate:` delegate via `make-delegate` (pinned in `*delegate-roots*` for the process;
  AppKit holds it weakly) emitting `[lifecycle] shutdown reason=menu` on the osascript / Cmd-Q quit path.
  `symbol->string` on the lowercase reason symbol yields the contract's lowercase `reason` directly (no
  CL `*print-case*` downcasing dance like sbcl).
- **`build.sh`** (rewritten to the **bundle-gerbil** variant) — regenerates the gerbil bindings if absent
  (`apianyware-generate --target gerbil` — the sharded `generics/NNN.ss` + appkit/foundation modules,
  gitignored/absent in a clean checkout; the prior `build.sh` wrongly assumed them present and only linked
  a **bare exe**), drives the full bundle via `cargo run --example bundle_app -p apianyware-bundle-gerbil
  -- hello-window`, then post-processes the per-impl id: rename `Hello Window.app` →
  `HelloWindow-gerbil.app`, PlistBuddy set `CFBundleIdentifier=com.linkuistics.hello-window-gerbil`,
  re-sign (codesign seals Info.plist, so the post-mv edit invalidates the bundler's signature).
- **`README.md` / `learnings.md`** (modified) — dated build/conformance entry; the build now yields a
  `.app` (not a bare exe); corrected the stale "~5h cold build" claim (now ~6 min — ADR-0023 sharded
  generics); noted the `gcc-15` toolchain pin.

The built `.app` is a **gitignored** artifact (reproduced by `build.sh`), not committed — consistent with
the generated bindings + the openssl vendoring. The k67 gerbil descriptor needed **no change**: the build
meets its declared `#:bundle-id`/`#:binary` (`com.linkuistics.hello-window-gerbil` /
`/Applications/HelloWindow-gerbil.app`).

## Findings carried back (for child `04` live-run + future gerbil builds)

- **gerbil is in the chez camp, NOT the sbcl camp** — this **corrects** the AppSpec `impl-conformance-k23`
  node brief's prediction that k31 was "the same `build.sh`-hardcode pattern as sbcl (a one-line id
  change)". gerbil bundles via the **cargo** `bundle-gerbil` (the reusable driver that generalises the old
  per-app build.sh), and that bundler derives the id from the spec H1 with **no per-impl-id flag** — the
  same gap as racket k68 / chez k69. So build.sh post-processes (rename + PlistBuddy + **re-sign**),
  exactly like chez. sbcl k70 was the outlier: its build.sh writes Info.plist itself, so the id was a
  one-line heredoc with no re-sign. A native `--bundle-id` flag on the bundlers remains the proper
  long-term home — an APIAnyware **tooling** concern, not app data.
- **No dylib needed — gerbil hello-window travels alone (contrast sbcl).** The terminate delegate uses
  `make-delegate`, whose IMP path routes through the clang `native_block.c` companion (always compiled),
  **not** the Swift-native trampoline dylib (`aw_gerbil_swift_*`, ADR-0029). hello-window's closure pulls
  no trampolines, so `discover_swift_dylib` returns `None` and the bundle carries **no**
  `libAPIAnywareGerbil.dylib`. **Child `04` needs NO extra provisioning for gerbil** — the self-contained
  `gxc -exe` (+ the two openssl dylibs vendored *inside* `Contents/Frameworks/`) is the whole install.
  (Only **sbcl** needs `/tmp/libAPIAnywareSbcl.dylib`; racket/chez/gerbil carry their callbacks natively.)
- **The real toolchain gap was `gcc-15`, not gerbil.** gerbil-scheme 0.18.2 was already in the Cellar (just
  not brew-linked onto PATH — `bundle-gerbil` globs the Cellar, `discover_gerbil_bin_dir`, so that is a
  non-issue). But the bottle's Gambit config hardcodes `C_COMPILER="gcc-15"` (`gambuild-C`), and the host
  had upgraded Homebrew `gcc` to 16 (gcc-15 gone) → `gambuild-C: gcc-15: command not found`. Fixed with
  `brew install gcc@15` (bottled, fast). **This breaks every gerbil build until the gerbil bottle is
  rebuilt against the current gcc** — a gerbil-toolchain/environment concern worth a durable fix
  (pin gcc@15 as a gerbil build dep, or override gambit's C compiler).
- **The "~5h cold build" learning is stale.** ADR-0023 sharded the monolithic `generics.ss` into 28 small
  no-`-O` modules compiled **in parallel**; this build was ~6 min (shards 97s ∥ · facade 9s · closure 53s ·
  `gxc -exe` link 194s — the `libgambit.a` static link now dominates). Well within bundle-gerbil's
  `< 15 min` budget.

## Validation (host-side; live run is the AppSpec grove's child `04`)

- **Logging logic validated standalone with `gxi`** (no AppKit): the three exact lines + the runner's
  matchers (`#px"\[lifecycle\] startup"`, `#rx"Hello Window opened\."`, `reason=menu`), env-var path
  resolution (set / unset / empty→default), graceful absent-config read, and re-init truncation.
- **Full bundle built:** `HelloWindow-gerbil.app` (44 MB exe), `CFBundleIdentifier =
  com.linkuistics.hello-window-gerbil`, `CFBundleExecutable = hello-window`; `codesign --verify --strict`
  clean; `otool -L` Homebrew-clean (openssl `libssl.3`/`libcrypto.3` vendored + relocated to
  `@executable_path/../Frameworks/`). A clean exe link **is** the typecheck that the delegate + logging
  identifiers all resolved.
- **VM-deferred to `04`:** the delegate firing on a *real* terminate event + the run-loop event emission
  (needs a WindowServer); the four-impl live pass.

_Recorded as DONE on landing — a provenance record of completed cross-grove authoring, not pending
APIAnyware work; `appspec-grove-pause-k66` remains the live pick target. ADR-0013 / ADR-0052._

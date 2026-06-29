# appspec-hello-window-chez-build-k69

**Kind:** work (cross-grove **record** — app data authored *into* this repo by the AppSpec toolkit grove
per ADR-0013; recorded here, not driven as an APIAnyware session)

## What this records

The **AppSpec toolkit grove**'s `impl-conformance-k23` node continues authoring hello-window's app data
**into this worktree** (ADR-0013; the data's home is APIAnyware). This leaf records the **chez** build
child `chez-instrument-build-k29` — the second of the four per-impl instrument+build children
(k28–k31), landing after the racket build record [[06-DONE-appspec-hello-window-racket-build-k68]].

## Authored in this commit (chez: instrument + build)

- **`targets/chez/app-implementations/macos/hello-window/hello-window.sls`** (modified) — wires the
  logging contract, with the structured-event emitter **inlined** as top-level defines (not a sibling
  `events.sls`): chez resolves `(import …)` by library-name→path against the whole-program-compile tree
  (logical `apps/<script>/`), so a sibling library would need an `apps/`-prefixed name; the inline defines
  use only `(chezscheme)` names, so the standalone bundler resolves them with no new library on the path.
  Emits `[lifecycle] startup` (before the run loop), the bare `Hello Window opened.` (kept the stdout
  `display` too), and `[lifecycle] shutdown reason=menu` from an `applicationWillTerminate:` delegate;
  honours `HELLO_WINDOW_TEST_CONFIG` gracefully. Added `(apianyware runtime dispatch)` to the imports for
  `make-delegate`/`delegate-ptr` (proven collision-safe — note-editor imports the same curated set). The
  emitter verified in isolation against the contract matchers (`#px"\[lifecycle\] startup"`,
  `#rx"Hello Window opened\."`, `reason=menu`).
- **`targets/chez/app-implementations/macos/hello-window/build.sh`** (new) — reproducible build recipe
  (mirrors the racket/sbcl/gerbil `build.sh` convention): regenerates the chez bindings
  (`apianyware-generate --target chez`, which also emits the chez Swift-native trampolines) + the adapter
  dylib (`swift build`) if absent, bundles via `apianyware-bundle-chez` (whole-program compile, ~2:42),
  then renames to `HelloWindow-chez.app`, sets `CFBundleIdentifier=com.linkuistics.hello-window-chez`
  (PlistBuddy), and **re-signs** (the post-mv plist edit invalidates the bundler's seal —
  `codesign --verify --strict` passes after re-sign).
- `learnings.md` — dated build/conformance entry.

The built `.app` is a **gitignored** artifact (reproduced by `build.sh`), not committed — consistent with
the generated bindings + dylib. The k67 chez descriptor needed **no change**: the build meets its
declared `#:bundle-id`/`#:binary` (`com.linkuistics.hello-window-chez` / `/Applications/HelloWindow-chez.app`).

## Findings carried back (for the sibling build children)

- **Same per-impl bundle-id gap as racket (k68).** `apianyware-bundle-chez` derives the id from the spec
  H1 → `com.linkuistics.HelloWindow` for *every* impl, with **no `--bundle-id`/`--app-name` flag** — it
  would collide the four apps in one VM. chez works around it in `build.sh` (PlistBuddy + re-sign, the
  standalone bundle's strict signature forces the re-sign racket didn't need). A native flag on the
  bundlers remains the proper long-term home (an APIAnyware **tooling** concern, not app data).
- **sbcl/gerbil builds still not descriptor-conformant** (carried from k68): the sbcl/gerbil `build.sh`
  hardcode `com.linkuistics.hello-window` / `HelloWindow.app` (no `-<impl>`); the k30/k31 children must
  reconcile each impl's build to its `com.linkuistics.hello-window-<impl>` descriptor.
- **chez file I/O gotcha:** the structured log uses `open-file-output-port` (with `(file-options no-fail)`
  for truncate-or-create, `(buffer-mode line)`, a UTF-8 transcoder); `open-output-file` rejects those
  args. Noted for any sibling that touches chez file output.

_Recorded as DONE on landing — a provenance record of completed cross-grove authoring, not pending
APIAnyware work; `appspec-grove-pause-k66` remains the live pick target. ADR-0013 / ADR-0052._

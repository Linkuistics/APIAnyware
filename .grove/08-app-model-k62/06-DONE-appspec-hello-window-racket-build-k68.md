# appspec-hello-window-racket-build-k68

**Kind:** work (cross-grove **record** — app data authored *into* this repo by the AppSpec toolkit grove
per ADR-0013; recorded here, not driven as an APIAnyware session)

## What this records

The **AppSpec toolkit grove**'s `impl-conformance-k23` node continues authoring hello-window's app data
**into this worktree** (ADR-0013; the data's home is APIAnyware). This leaf records the **racket** build
child `racket-instrument-build-k28` — the first of the four per-impl instrument+build children
(k28–k31), landing after the contract+descriptors record [[05-DONE-appspec-hello-window-conformance-data-k67]].

## Authored in this commit (racket: instrument + build)

- **`targets/racket/app-implementations/macos/hello-window/events.rkt`** (new) — a narrowed,
  de-Modalisered structured-event emitter (3 events, single writer). Verified in isolation against the
  contract matchers (`#px"\[lifecycle\] startup"`, `#rx"Hello Window opened\."`,
  `reason ∈ {menu,signal,error}`); `Hello Window opened.` is a bare line.
- **`targets/racket/app-implementations/macos/hello-window/hello-window.rkt`** (modified) — wires the
  contract: `events-init!` + `[lifecycle] startup` before the run loop; the bare `Hello Window opened.`
  (kept the stdout `displayln` too); shutdown via an `applicationWillTerminate:` delegate (`reason=menu`)
  + an `uncaught-exception-handler` (`signal`/`error`); honours `HELLO_WINDOW_TEST_CONFIG` gracefully.
  `raco make`-compiles in the bundled layout.
- **`targets/racket/app-implementations/macos/hello-window/build.sh`** (new) — reproducible build recipe
  (mirrors the sbcl/gerbil `build.sh` convention, which racket lacked): regenerates the shared racket
  binding if absent (`apianyware-generate --target racket` + `swift build` the adapter dylib), bundles
  via `apianyware-bundle-racket`, then renames to `HelloWindow-racket.app` and sets
  `CFBundleIdentifier=com.linkuistics.hello-window-racket`.
- `learnings.md` — dated build/conformance entry.

The built `.app` is a **gitignored** artifact (reproduced by `build.sh`), not committed — consistent with
the generated bindings + dylib. The k67 racket descriptor needed **no change**: the build now meets its
declared `#:bundle-id`/`#:binary` (`com.linkuistics.hello-window-racket` / `/Applications/HelloWindow-racket.app`).

## Findings carried back (for APIAnyware + the sibling build children)

- **The cargo bundler has no per-impl bundle-id flag.** `apianyware-bundle-racket` derives the id from the
  spec H1 → `com.linkuistics.HelloWindow` for *every* impl, which would collide the four apps in one VM.
  racket works around it in `build.sh` (post-process the Info.plist). A native `--bundle-id`/`--app-name`
  flag on the bundler is the proper long-term home (an APIAnyware **tooling** concern, not app data).
- **sbcl/gerbil builds are not yet descriptor-conformant.** `targets/sbcl/.../build.sh` hardcodes
  `com.linkuistics.hello-window` (no `-sbcl`) and `HelloWindow.app`; the k27 descriptors expect
  `com.linkuistics.hello-window-<impl>` / `HelloWindow-<impl>.app`. The sbcl/gerbil build children
  (k30/k31) must reconcile each impl's build to its descriptor (chez/k29: check `bundle-chez`).

_Recorded as DONE on landing — a provenance record of completed cross-grove authoring, not pending
APIAnyware work; `appspec-grove-pause-k66` remains the live pick target. ADR-0013 / ADR-0052._

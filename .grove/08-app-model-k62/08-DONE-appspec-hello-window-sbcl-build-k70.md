# appspec-hello-window-sbcl-build-k70

**Kind:** work (cross-grove **record** — app data authored *into* this repo by the AppSpec toolkit grove
per ADR-0013; recorded here, not driven as an APIAnyware session)

## What this records

The **AppSpec toolkit grove**'s `impl-conformance-k23` node continues authoring hello-window's app data
**into this worktree** (ADR-0013; the data's home is APIAnyware). This leaf records the **sbcl** build
child `sbcl-instrument-build-k30` — the third of the four per-impl instrument+build children
(k28–k31), landing after the chez build record [[07-DONE-appspec-hello-window-chez-build-k69]].

## Authored in this commit (sbcl: instrument + build)

- **`targets/sbcl/app-implementations/macos/hello-window/events.lisp`** (new) — the structured event log
  **extracted** to a pure-CL package (`apianyware-sbcl-hello-window-events`, nickname `hw-events`), with
  no AppKit/Foundation/dylib dependency so it **unit-tests in isolation** (the racket `events.rkt`
  precedent, not the chez inline). Emits `[lifecycle] startup`, the bare `Hello Window opened.`, and
  `[lifecycle] shutdown reason=<r>`. `emit-shutdown` uses the `~(~a~)` directive to **downcase** the
  reason — CL's default `*print-case*` is `:upcase`, so a bare `~a` on `'menu` would emit `reason=MENU`,
  but the contract (and the racket/chez siblings) mandate lowercase `reason ∈ {menu, signal, error}`.
- **`targets/sbcl/app-implementations/macos/hello-window/hello-window.lisp`** (modified) — wires the
  contract: `events-init!`/`emit-startup` before the run loop, `emit-opened` after key+front (kept the
  stdout line too), honours `HELLO_WINDOW_TEST_CONFIG` gracefully, and an `applicationWillTerminate:`
  delegate (`define-objc-subclass hw-app-delegate (ns:ns-object)` + a `define-objc-method`, synthesized at
  **runtime** in `ensure-hw-delegate` so it survives the dump→revive — note-editor's
  `ensure-note-controller` pattern). The delegate emits `[lifecycle] shutdown reason=menu` on the
  osascript/Cmd-Q quit path.
- **`run.lisp` / `dump.lisp`** (modified) — load `libAPIAnywareSbcl` (`aw-load-native-dylib`) + `events.lisp`
  before the app; `dump.lisp` records the dylib path (`/tmp/libAPIAnywareSbcl.dylib`) for revive
  auto-reopen (ADR-0038 §5). No block-dispatcher init — the subclass dispatcher self-registers on the
  first `define-objc-method`.
- **`build.sh`** (rewritten to the **dylib variant**) — regenerates the sbcl bindings
  (`apianyware-generate --target sbcl`) + the adapter dylib (`swift build`) if absent (both
  gitignored/absent in a clean checkout — the prior `build.sh` wrongly assumed the bindings present),
  stages the dylib at `/tmp`, pre-flight → dump → vendors the dylib into `Contents/Frameworks` → revive
  smoke. Sets `CFBundleIdentifier=com.linkuistics.hello-window-sbcl` / `HelloWindow-sbcl.app` **directly in
  the Info.plist heredoc**.
- **`README.md` / `learnings.md`** (modified) — corrected the now-false "no dylib" / `HelloWindow.app`
  claims; dated build/conformance entry.

The built `.app` is a **gitignored** artifact (reproduced by `build.sh`), not committed — consistent with
the generated bindings + dylib. The k67 sbcl descriptor needed **no change**: the build meets its declared
`#:bundle-id`/`#:binary` (`com.linkuistics.hello-window-sbcl` / `/Applications/HelloWindow-sbcl.app`).

## Findings carried back (for the sibling build children)

- **The terminate delegate forces the dylib — sbcl hello-window is no longer dylib-free** (a divergence
  from the original "pure ObjC, travels alone" build). Any ObjC→Lisp callback on SBCL MUST route through
  `libAPIAnywareSbcl`'s subclass bounce shim (a `define-alien-callable` installed AS an IMP is the
  ADR-0035 crash); a delegate, not an exit hook, because `-[NSApplication terminate:]` ends in a C
  `exit()` that bypasses `sb-ext:*exit-hooks*`. Decided as **full parity** with racket/chez (human-chosen
  over the pure-ObjC, skip-the-shutdown-line alternative). **VM consequence:** the live-run child `04`
  must provision `/tmp/libAPIAnywareSbcl.dylib` for this impl (one dylib, like note-editor).
- **Per-impl bundle-id was cheap here, unlike the cargo bundlers.** hello-window's `build.sh` writes
  Info.plist itself, so the per-impl id is set directly — **no** PlistBuddy + re-sign dance (the racket
  k68 / chez k69 cargo bundlers derive the id from the spec H1 and seal the bundle signature, forcing the
  post-mv edit + re-sign). The native `--bundle-id` flag on the bundlers remains the proper long-term home
  (an APIAnyware **tooling** concern, not app data) — gerbil k31 (also a `build.sh` hardcode) is the last
  per-impl workaround.
- **Expected STYLE-WARNING** "Cannot find type for specializer `HW-APP-DELEGATE`": the
  `define-objc-method` `defmethod` compiles before the runtime `define-objc-subclass` defines the class
  (note-editor exhibits the same). Benign — the revive smoke proves the method installs + dispatches.

## Validation (host-side; live run is the AppSpec grove's child `04`)

- `events.lisp` isolation test — three lines + the runner's exact matchers
  (`#px"\[lifecycle\] startup"`, `#rx"Hello Window opened\."`, `reason=menu`) + env-var path resolution +
  re-init truncation.
- Construction pre-flight + **revive smoke** — subclass synthesis + dispatcher re-registration in the
  dumped image (dylib auto-reopened from `/tmp`); `### revived hello-window construction OK`.
- Host integration test — fires `ns:application-will-terminate_` directly; all three lines land in
  events.log.
- **VM-deferred to `04`:** the delegate firing on a *real* terminate event + the run-loop event emission
  (`:run t` needs a WindowServer).

_Recorded as DONE on landing — a provenance record of completed cross-grove authoring, not pending
APIAnyware work; `appspec-grove-pause-k66` remains the live pick target. ADR-0013 / ADR-0052._

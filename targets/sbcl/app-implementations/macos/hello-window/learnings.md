# hello-window — learnings (sbcl target, 060 ladder app 1/8)

The first real GUI app on the SBCL bindings. It stood up the shared app pipeline
(generate → load bindings → build UI → `save-lisp-and-die` → `.app` → VM-verify) the
ladder reuses, and — true to its forcing-function role — surfaced one contract gap (now
fixed) plus several findings for the control-heavy apps and 070-distribution.

## Contract gap fixed here: the `@"…"` NSString reader macro (§3.2)

An app written against the contract has **no portable way to make an `NSString`**: the
generated setters take an *object* (`ns:set-title_` calls `(aw-ptr value)`), never a Lisp
string, and `make-instance 'ns:ns-string` has no from-Lisp-string init. The contract
(§3.2) and the SBCL design spec both name the `@"…"` reader macro ("readers in runtime")
— but it was specified and never built. Implemented now in
`lib/runtime/reader-syntax.lisp`: `@"text"` reads as `(aw-wrap (aw-make-nsstring "text")
t)` — a lifetime-managed `ns:ns-string` instance. Installed **non-terminating** into the
global `*readtable*` at runtime load (so the app just writes `@"…"`; CCL installs `@`
globally too), safe because no generated/runtime/smoke `.lisp` file carries a token
beginning with `@`. All 7 runtime smokes stay green.

**`#/` (selector literal) is DEFERRED** — no app on the ladder needs it (the surface is
named per-selector generics, not raw `objc_msgSend`), and a robust reader (case- and
colon-preserving token scan) wants its own focused unit + tests. Recorded so §3.2 is not
silently treated as fully met.

## Findings for later apps

- **The init registry is keyed by EXACT class — inherited inits do not resolve via
  `make-instance` on a subclass.** `aw-apply-init` does `(gethash class
  *objc-init-registry*)` with no superclass walk, so `initWithFrame:` (registered on
  `NSView`/`NSControl`) is invisible to `make-instance 'ns:ns-text-field`. Worked around
  here by mirroring gerbil: bare `(make-instance 'ns:ns-text-field)` (alloc/init) +
  `ns:set-frame_`. This will bite **040-ui-controls-gallery** hard (many controls are
  constructed via inherited `initWithFrame:`). Candidate fix (a runtime change, its own
  leaf): have `aw-apply-init` walk the CLOS superclass chain for a registered init whose
  initargs match. Not a hello-window blocker, so left for the controls app to force.
- **By-value geometry flows cleanly through `make-instance`.** `aw-with-rect` binds a
  stack `with-alien (struct ns-rect)`; passing that var as a `make-instance` initarg →
  through the `&rest initargs` plist → into the ADR-0040 applier's `alien-funcall`
  `(struct ns-rect)` arg copies by value correctly, since the call is inside the
  `aw-with-rect` dynamic extent. First committed proof of the ADR-0040 typed-init path
  against real AppKit (010 proved it interactively only).
- **App package.** Source is in `apianyware-sbcl-impl` (giving bare `make-instance`,
  `aw-with-rect`, the menu helper). The *Cocoa* surface it names is the portable `ns:`
  contract, but the impl-package home and the geometry primitive (`aw-with-rect`, not a
  `ns:`-level form) are **not yet portable** — a contract-surface refinement (a portable
  app package + a `ns:` geometry constructor) for when a second CL-family member lands.

## Findings for 070-distribution (the dumped `.app` shape)

- **The dumped exe links Homebrew's `libzstd`** (`/opt/homebrew/opt/zstd/lib/
  libzstd.1.dylib`) — SBCL's runtime uses it for core compression, an absolute path a
  Homebrew-less target lacks. Verification provisioned that one dylib into the VM.
  `bundle-sbcl` must address it: vendor+relocate is **impossible post-dump** (next bullet),
  so the realistic options are dumping against an SBCL runtime built `--without-zstd` or a
  relocatable runtime, or a launcher that sets `DYLD_FALLBACK_LIBRARY_PATH` to a vendored
  copy.
- **Post-dump Mach-O surgery is off the table.** `install_name_tool` refuses the dumped
  exe ("the __LINKEDIT segment does not cover the end of the file") because
  `save-lisp-and-die` appends the Lisp core *after* `__LINKEDIT`. `codesign --force` also
  fails "strict validation" on that layout — but SBCL **already ad-hoc signs** the dumped
  exe (so it launches on arm64), and that signature must be left intact. So all path
  rewriting must be a runtime/`DYLD_*` concern or baked into the chosen SBCL runtime.
- **Pure-ObjC apps need no `libAPIAnywareSbcl` dylib.** hello-window dispatches ObjC
  directly via `objc_msgSend` (libobjc, always mapped); the dylib is only for the
  Swift-native residual (the 030-swift-native-probe app's job). Loading bindings with
  `:load-residual nil` keeps the artifact dependency-free of it.
- **The startup re-resolution pass works in a real dumped GUI image** (revive smoke +
  the live VM run): re-`dlopen` of Foundation/AppKit, `objc_msgSend` re-resolution, and
  FP-trap re-masking all happen via `*init-hooks*` before the toplevel. Load-bearing for
  070 and now demonstrated under AppKit, not just the smoke.

## 2026-06-30 (AppSpec instrument + build, sbcl child `sbcl-instrument-build-k30`)

Instrumented hello-window to the **Hello Window logging contract**
(`apps/macos/hello-window/docs/logging-contract.md`) and built it for the AppSpec acceptance
test (`acceptance-test-k21` / `impl-conformance-k23`). Full parity with the racket/chez
siblings — all three events emitted.

- 🟢 **Structured event log extracted to `events.lisp`** (pure CL, package
  `apianyware-sbcl-hello-window-events`, nickname `hw-events`) — no AppKit/Foundation/dylib
  dependency, so it **unit-tests in isolation** (`sbcl --script events.lisp` + assertions; the
  racket `events.rkt` precedent, not the chez inline). Emits `[lifecycle] startup` (before the
  run loop), the bare `Hello Window opened.`, and `[lifecycle] shutdown reason=<r>`. `run.lisp`
  /`dump.lisp` load it before `hello-window.lisp`.
- 🟢 **`~(~a~)` downcase gotcha (cross-impl correctness).** CL's default `*print-case*` is
  `:upcase`, so a bare `~a` on the symbol `'menu` emits `reason=MENU` — but the contract (and
  the racket/chez siblings, whose symbols print lowercase) mandate lowercase
  `reason ∈ {menu, signal, error}`. `emit-shutdown` uses `~(~a~)` to downcase. Caught by the
  isolation test before it reached the VM.
- 🟢 **The terminate delegate forces the dylib — this app is no longer dylib-free.** The
  `applicationWillTerminate:` callback (→ `reason=menu`, the osascript/Cmd-Q quit path
  `quit-impl!`/scenario `03` exercise) is an ObjC→Lisp callback, and on SBCL **every** such
  callback MUST route through `libAPIAnywareSbcl`'s subclass bounce shim — a
  `define-alien-callable` installed AS an IMP runs Lisp on a foreign thread (the ADR-0035
  crash; `subclass.lisp` is explicit). So hello-window now loads the dylib for the **subclass
  shim only** (no block factory, no trampoline residual), via `define-objc-subclass
  hw-app-delegate (ns:ns-object)` + a `define-objc-method` for the selector, synthesized at
  **runtime** in `ensure-hw-delegate` (a class synthesized during `save-lisp-and-die` does not
  survive into the revived image — note-editor's `ensure-note-controller` pattern). **This
  refines the 060 finding "Pure-ObjC apps need no `libAPIAnywareSbcl` dylib":** pure-ObjC
  *framework calls* need no residual, but any ObjC→Lisp *callback* (a delegate/target-action)
  pulls in the dylib regardless. Why a delegate and not an exit hook: `-[NSApplication
  terminate:]` ends in a C `exit()`, which bypasses `sb-ext:*exit-hooks*`.
- 🟡 **Expected STYLE-WARNING** "Cannot find type for specializer `HW-APP-DELEGATE`": the
  `define-objc-method` `defmethod` compiles before the runtime `define-objc-subclass` creates
  the class. Benign and identical to note-editor; the revive smoke proves the method installs +
  dispatches.
- 🟢 **Build converted to the dylib variant** (`build.sh`, was the pure-standalone build):
  **regenerates the sbcl bindings** (`apianyware-generate --target sbcl`, ~4s — the prior
  `build.sh` assumed them present, but they are gitignored/absent in a clean checkout; the
  racket/chez build children already regenerated theirs) + the adapter dylib (`swift build`) if
  absent, stages the dylib at `/tmp/libAPIAnywareSbcl.dylib` (recorded for revive auto-reopen,
  ADR-0038 §5), pre-flight → dump → vendor the dylib into `Contents/Frameworks` → revive smoke.
  **Per-impl bundle id set DIRECTLY in the Info.plist heredoc** (`com.linkuistics.hello-window-sbcl`
  / `HelloWindow-sbcl.app`) — hello-window's `build.sh` writes Info.plist itself, so it needs
  **none** of the post-mv PlistBuddy + re-sign dance the racket/chez **cargo** bundlers needed
  (those derive the id from the spec H1 and seal the bundle signature). The k27 sbcl descriptor
  needed **no change** (build meets its `#:bundle-id`/`#:binary`).
- 🟢 **Validated host-side** (instrument + build are host-side; the live run is sibling `04`):
  events.lisp isolation test (three lines + the runner's exact matchers + env-var path
  resolution + re-init truncation); construction pre-flight + **revive smoke** (subclass
  synthesis + dispatcher re-registration in the dumped image, dylib auto-reopened from `/tmp`);
  and a **host integration test** that fires `ns:application-will-terminate_` directly and
  confirms all three lines land in events.log. **VM-deferred to child `04`:** the delegate
  firing on a *real* terminate event and the run-loop event emission (`:run t` needs a
  WindowServer). The built `.app` is gitignored (reproduced by `build.sh`).
- 🟡 **VM provisioning change.** This impl no longer "travels alone": the VM must provide
  `/tmp/libAPIAnywareSbcl.dylib` (one dylib, like note-editor). The `04` live-run child uploads
  the vendored `Contents/Frameworks/libAPIAnywareSbcl.dylib` to that path.

**For the gerbil sibling (k31):** same per-impl bundle-id reconciliation (the gerbil `build.sh`
hardcodes `com.linkuistics.hello-window` / `HelloWindow.app`); gerbil also needs its toolchain
installed (`gerbil-scheme` not on host). A native `--bundle-id` flag on the cargo bundlers
remains the proper long-term home (an APIAnyware tooling concern, not app data).

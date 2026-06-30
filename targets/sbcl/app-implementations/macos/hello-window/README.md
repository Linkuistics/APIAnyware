# Hello Window (sbcl)

The simplest sample app (ladder 1/8): a 400×200 centred window titled "Hello from SBCL"
with a centred 24 pt "Hello, macOS!" label, a standard application menu, and a run loop.
The forcing function that stands up the SBCL app pipeline.

Written against the **CL-family interface contract** (ADR-0033 / the contract spec): it
names only the `ns:` Cocoa surface, `make-instance` (§3.3), the per-selector generics
(§3.2), and the `@"…"` NSString reader macro (§3.2). Every Cocoa call is pure ObjC (no
Swift-native trampoline residual, so `:load-residual nil`), but it is **not** dylib-free:
the AppSpec logging contract's `applicationWillTerminate:` delegate needs an ObjC→Lisp
callback, which on SBCL must route through `libAPIAnywareSbcl`'s subclass bounce shim — so
the harness loads the dylib for that one facility (like `note-editor`).

## Files

| File | Role |
|---|---|
| `hello-window.lisp` | the app — `hello-window-main` + the `applicationWillTerminate:` delegate; built from the `ns:` surface |
| `events.lisp` | structured event log (`hw-events`) the AppSpec runner tails; pure CL, isolation-testable |
| `run.lisp` | dev host runner; `AW_HELLO_SMOKE=1` = construction pre-flight (no run loop) |
| `dump.lisp` | `save-lisp-and-die :executable t` → standalone exe; `AW_HELLO_SMOKE` revive smoke |
| `build.sh` | full build: regen bindings + dylib → stage → pre-flight → dump → wrap in `HelloWindow-sbcl.app` |
| `learnings.md` | findings (the `@`-reader gap, exact-class init registry, AppSpec instrument, 070 dist notes) |

## Build

```sh
targets/sbcl/app-implementations/macos/hello-window/build.sh
# → targets/sbcl/app-implementations/macos/hello-window/build/HelloWindow-sbcl.app
```

The pipeline:

0. **prereqs** — regenerate the sbcl bindings (`apianyware-generate --target sbcl`) + the
   adapter dylib (`swift build` → `libAPIAnywareSbcl`) if absent, then stage the dylib at
   the fixed `/tmp/libAPIAnywareSbcl.dylib` the dumped image records for revive auto-reopen;
1. **host construction pre-flight** — load dylib + bindings (Foundation + AppKit,
   `:load-residual nil`) and build the whole UI + synthesize the terminate delegate
   *without* the run loop, so a marshalling/subclass break fails the build before the dump;
2. **dump** — `save-lisp-and-die :executable t` embeds the SBCL runtime + the binding
   library + the app into one executable (the dylib stays in `*shared-objects*`,
   auto-reopened from `/tmp` at revive — ADR-0038 §5). At revive, `sb-ext:*init-hooks*`
   runs the startup re-resolution pass (re-`dlopen`, re-resolve `objc_msgSend`, re-mask FP
   traps, re-register the subclass dispatcher) before the toplevel;
3. **wrap** — into `HelloWindow-sbcl.app` (Info.plist, `com.linkuistics.hello-window-sbcl`
   — the per-impl id so the four impls coexist in one acceptance-test VM) with the dylib
   vendored into `Contents/Frameworks`, so it launches with `open -n` in a WindowServer session.

The production packaging (the `bundle-sbcl` crate) is 070-distribution's job; this dev
`build.sh` is its precursor, as gerbil's app `build.sh` preceded `bundle-gerbil`.

## Dev run (interactive, needs a GUI session)

```sh
SDKROOT=macosx sbcl --script targets/sbcl/app-implementations/macos/hello-window/run.lisp
```

## Distribution note

The dumped exe links Homebrew's `libzstd` (SBCL core-compression dep) at an absolute
`/opt/homebrew/...` path; a target without Homebrew must provide that one dylib (post-dump
relocation is impossible — see `learnings.md`). Verified via TestAnyware: see
`../../test-results/hello-window/report.md`.

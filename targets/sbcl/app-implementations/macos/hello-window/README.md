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
| `build.sh` | full build: regen bindings + dylib → pre-flight → `bundle-sbcl` (dump + stub + vendor + sign) → per-impl id → revive smoke |
| `learnings.md` | findings (the `@`-reader gap, exact-class init registry, AppSpec instrument, 070 dist notes) |

## Build

```sh
targets/sbcl/app-implementations/macos/hello-window/build.sh
# → targets/sbcl/app-implementations/macos/hello-window/build/HelloWindow-sbcl.app
```

The pipeline:

0. **prereqs** — regenerate the sbcl bindings (`apianyware-generate --target sbcl`) + the
   adapter dylib (`swift build` → `libAPIAnywareSbcl`) if absent;
1. **host construction pre-flight** — load dylib + bindings (Foundation + AppKit,
   `:load-residual nil`) and build the whole UI + synthesize the terminate delegate
   *without* the run loop, so a marshalling/subclass break fails the build before the dump;
2. **bundle** — the production bundler (`cargo run --example bundle_app -p
   apianyware-bundle-sbcl`, ADR-0041): dumps the image to `Contents/Resources/`
   (`save-lisp-and-die :executable t` embeds the SBCL runtime + binding library + app; the
   dylib stays in `*shared-objects*`, recorded as `@executable_path/../Frameworks/…` via
   `AW_NATIVE_DYLIB_RECORD_AS` — ADR-0038 §5), compiles the Swift **stub** launcher
   (CFBundleExecutable — sets `DYLD_FALLBACK_LIBRARY_PATH=<bundle>/Contents/Frameworks`,
   `execv`s the image), vendors `libzstd.1.dylib` + `libAPIAnywareSbcl.dylib` into
   `Contents/Frameworks/`, and signs the bundle. At revive, `sb-ext:*init-hooks*` runs the
   startup re-resolution pass (re-`dlopen`, re-resolve `objc_msgSend`, re-mask FP traps,
   re-register the subclass dispatcher) before the toplevel;
3. **per-impl id** — rename to `HelloWindow-sbcl.app` + PlistBuddy the id to
   `com.linkuistics.hello-window-sbcl` (the four impls coexist in one acceptance-test VM)
   + re-sign, then a **revive smoke through the stub** proves the whole launch chain on
   the host.

## Dev run (interactive, needs a GUI session)

```sh
SDKROOT=macosx sbcl --script targets/sbcl/app-implementations/macos/hello-window/run.lisp
```

## Distribution note

The `.app` is **fully self-contained** (`sbcl-vendor-libzstd-k75`): the dumped image's
absolute Homebrew `libzstd` load command is uneditable post-dump, but the vendored copy in
`Contents/Frameworks/` resolves via the stub's `DYLD_FALLBACK_LIBRARY_PATH`, and
`libAPIAnywareSbcl` reopens exe-relative — a vanilla VM needs **nothing** staged. Verified
via TestAnyware against the AppSpec suite: see `apps/macos/hello-window/docs/run-results.md`.

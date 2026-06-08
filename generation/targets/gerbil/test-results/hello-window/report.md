# Hello Window — Gerbil Test Report

**Date:** 2026-06-08
**Status:** PASS — first proof the whole gerbil pipeline produces a working macOS GUI app.

This is the done-bar for grove node `070-bundle-gerbil-and-hello-window`: the
self-contained `.app` built by `bundle-gerbil` (leaf 070/030) **actually draws a
window** in a macOS VM with **no Gerbil installed** — CLI smoke does not satisfy this
([[feedback-vm-verify-every-app]]).

## Build

`cargo run --release --example bundle_app -p apianyware-macos-bundle-gerbil -- hello-window`
(`SDKROOT=$(xcrun --sdk macosx --show-sdk-path)` exported). Output:
`generation/targets/gerbil/apps/hello-window/build/Hello Window.app`, **73 MB**, bundle
id `com.linkuistics.HelloWindow`, CFBundleName "Hello Window", codesigned.

**`otool -L` on `Contents/MacOS/hello-window` is dylib-clean** — only system libs +
frameworks, no Homebrew/Gerbil/Gambit linkage:
- `/usr/lib/libobjc.A.dylib`, `/usr/lib/libSystem.B.dylib`, `/usr/lib/libz.1.dylib`,
  `/usr/lib/libsqlite3.dylib`
- `/System/Library/Frameworks/AppKit.framework`, `…/Foundation.framework`
- `@executable_path/../Frameworks/libssl.3.dylib`, `…/libcrypto.3.dylib` — the
  vendored + relocated openssl@3 (the one Homebrew dep `bundle-gerbil` stages, ADR-0009).

The Gerbil/Gambit runtime is **statically embedded** (`gxc -exe` links `libgambit.a`
by default — the 070/020 bottle-toolchain finding), so no `libgambit`/`libgerbil` dep
appears.

## VM verify (no-Gerbil bar)

Golden `testanyware-golden-macos-tahoe`, arm64, macOS 26 (1024×768). Confirmed the VM
ships **no Gerbil** (`which gxc gsc gerbil` → empty, no
`/opt/homebrew/Cellar/gerbil-scheme`). Uploaded the 13 MB tarball (md5-verified
`c894b78e…`), unpacked, `xattr -dr com.apple.quarantine`, launched via `open -n`.

Results:
- [x] Window appears, titled **"Hello from Gerbil"**, 400×200 content, centred.
- [x] **"Hello, macOS!"** label renders centred, large 24pt system font — no artifacts,
      standard white background (`screenshot-001-window.png`).
- [x] Traffic-light controls correct: close (red) + minimize (yellow) active, zoom
      (grey) disabled — correct for a `Titled|Closable|Miniaturizable` fixed-size window
      (no `Resizable` mask).
- [x] **Menu-bar app name reads "Hello Window"** (bold) — sourced from CFBundleName, not
      the exe name "hello-window". The bundle gives the menu its proper display name.
- [x] **Standard app menu works** (`screenshot-002-app-menu.png`): About Hello Window /
      Hide Hello Window ⌘H / Hide Others ⌥⌘H / Show All (greyed) / Quit Hello Window ⌘Q —
      the `runtime/cocoa` `install-standard-app-menu!` helper, app name substituted
      throughout.
- [x] **Cmd+Q quits cleanly** — process gone after the keystroke (`pgrep` empty).
- [x] No system Gerbil present, yet the app runs — self-containment proven end-to-end.

No code changes were needed for hello-window; the emitter + runtime + bundler produced a
correct GUI app on the first VM run.

## Issue found (build performance, not correctness): monolithic-generics cold-compile blowup

The **cold** build (no warm `gerbil-cache`) took **~5h 7min**, dominated by the
full-framework `generics.ss`:
- `gsc -target C` on the second generics compilation unit (`generics~1.scm`, **60 MB**)
  ran single-threaded ~2h44m, emitting a **94 MB** `generics~1.c`.
- `gcc-15 -O1` on that 94 MB single translation unit ran ~2h+ at **9.7 GB RSS** before
  producing the object — GCC's optimizers (register allocation, GCSE, scheduling) are
  superlinear in translation-unit size.

This **contradicts the 070 brief's "the bottle is fast" premise**, which was measured
against a *warm* cache; `build/` is gitignored, so every fresh checkout pays this cost.
At this duration the per-app VM-verify portfolio (node 090, six more apps) is impractical
without a fix. Captured as a follow-up planning leaf at the grove root
(`075-generics-compile-cost`): candidate directions are splitting `generics.ss` into many
small modules (bounded, parallelizable units), compiling generics at `-O0`/`-d` via
Gambit's per-module C-opt control, or committing/persisting a warm cache. This is a
build-time concern only — the shipped `.app` runs fine and launches instantly.

See [[feedback-use-testanyware]], [[reference-testanyware-cli]].

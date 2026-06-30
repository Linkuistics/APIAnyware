# Hello Window — gerbil sample app

Minimal macOS GUI: a 400×200 window with a centred 24pt "Hello, macOS!" label and
the standard application menu. The first gerbil sample app, and the vehicle for the
**first full-framework `gxc` compile** (leaf 070/020).

## What it exercises

- The generated AppKit/Foundation bindings (`:gerbil-bindings/appkit/nswindow`,
  `…/nsapplication`, `…/nstextfield`, `…/nscontrol`, `…/nsview`, `…/nsfont`,
  `…/enums`) — proc-core surface.
- The hand-written runtime: `runtime/objc` (`define-entry-point` / autorelease pool,
  `wrap`, `->ptr`, `string->nsstring`) and `runtime/cocoa` (geometry constructors +
  the standard app menu — the reusable app-support layer, mirroring chez's
  `runtime/cocoa.sls`).
- Geometry structs by value (`make-rect` → the window's content rect crosses into
  the binding's `(c-define-type CGRect (struct "CGRect"))` constructor).
- Inherited-method dispatch through the declaring superclass's proc core
  (`nscontrol-set-string-value!` etc. on an `NSTextField`) — the emitter emits only
  methods *declared* on a class.

## Build

```sh
./build.sh          # → build/HelloWindow-gerbil.app  (run from anywhere)
```

`build.sh` regenerates the gerbil bindings if absent (`apianyware-generate
--target gerbil`), drives the full `bundle-gerbil` bundle, and post-processes the
per-impl bundle id (`com.linkuistics.hello-window-gerbil` /
`HelloWindow-gerbil.app`) for the AppSpec acceptance test (four impls coexist in
one VM). Needs `gcc-15` on PATH — the gerbil bottle's Gambit config pins it
(`brew install gcc@15` if the host has moved to a newer gcc).

Then verify in a macOS VM (TestAnyware) — **never run a GUI app from the CLI**
(leaf 070/040).

### Toolchain & self-containment (the 070/020 finding)

Built with the **bottle** (Homebrew) gerbil — *not* a `--enable-shared=no` static
source toolchain. `gxc -exe` links `libgambit.a` by default, so the exe **embeds the
Gerbil/Gambit runtime**: `otool -L` shows only `/usr/lib/*`, the system frameworks,
and the Gerbil stdlib's **openssl@3** (the one dep `bundle-gerbil` vendors +
relocates, leaf 070/030). A trivial bottle exe runs under `env -i` (empty
environment, toolchain off PATH), confirming self-containment.

This **corrects FINDINGS §5** (it prescribed a static source toolchain but only
checked `otool -L` on that toolchain's exe, never the bottle's). The static source
toolchain is retired: its from-source non-single-host gsc is ~20× slower and
pathologically slow on the 13k-line `generics.ss` (>1h). See spec §7.

### Build model

`gxc -exe` does **not** recursively compile imports — they must be pre-compiled.
`build.sh` first compiles the app's binding-library closure (runtime + shared
`generics.ss` + each imported class module's parent chain) with `gxc -O` into a
persistent cache, then links the exe. This realises the spec §3 "compile the binding
library once, amortise across apps" model. The clang `-fblocks` `native_block.o`
companion joins the link line (runtime README "Building").

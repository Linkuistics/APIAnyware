# hello-window standalone — no-Chez VM verification (2026-05-29)

The done-bar evidence for grove node `060/030-standalone-build-pipeline`: the
**bundler-built** standalone `Hello Window.app` launches and draws its window on
a macOS VM with **no Chez Scheme installed**.

## What was verified

The `.app` built end-to-end through `bundle_app_standalone`
(`cargo run --example bundle_standalone -p apianyware-macos-bundle-chez -- hello-window`),
not the spike's hand-driven shell scripts.

- **No-Chez precondition** — clean `testanyware-golden-macos-tahoe` clone:
  `which chez scheme petite` empty, `/opt/homebrew/bin/chez` and
  `/opt/homebrew/Cellar/chezscheme` both absent. See `no-chez-vm-transcript.txt`.
- **Launches via `open -n`** — process `Contents/MacOS/hello-window` running;
  launch log shows only the app's own `"Hello Window opened…"` line, **no
  `Chez Scheme Version …` banner** (030 banner suppression, `suppress-greeting`).
- **Window draws correctly** — `hello-window-standalone-no-chez-vm.png`:
  centred "Hello, macOS!" label, title bar "Hello from Chez", and the menu-bar
  app name **"Hello Window"** sourced from `CFBundleName` (not "chez").
- **Self-contained linkage** — host-side `otool -L` on the stub shows only
  system libraries (Foundation, AppKit, libSystem, libiconv/ncurses/z); no Chez
  dylib. The full `scheme` boot (3.7 MB) is embedded in
  `Contents/Resources/hello-window.boot`; `libAPIAnywareChez.dylib` ships in
  `Contents/Resources/lib/`. `codesign --verify --strict` passes; signed under
  "APIAnyware Local Signing" with a unique CDHash.

## Visual parity

Pixel-identical to the spike's known-good open-world window
(`../2026-05-29-chez-standalone-spike-evidence/open-world-window.png`) — same
window geometry, title, and label. The sole difference is an improvement: the
production bundler uses the proper display name "Hello Window" where the spike's
hand-built bundle showed "Hello Window Open".

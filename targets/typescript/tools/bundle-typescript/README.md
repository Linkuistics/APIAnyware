# `bundle-typescript` — package a Node TypeScript sample app into a `.app`

Step 8 of `adding-a-language-target.md` for the `typescript` (Node) target. Realises
ADR-0060 — read it first; this crate does not re-derive the design, only the mechanics.

## Why this target's bundler looks different from the four Lisp ones

The four Lisp targets ship a **stub** (or, for chez/gerbil, a self-contained binary) that
either `execv`s or embeds a **byte-identical-across-apps** runtime. That model is
structurally wrong here: ADR-0056 established that the native side must own `main()` with
no ambient blocking JS→native call while pumping libuv, which forces a **per-app-compiled**
native launcher that embeds Node directly (the Electron shape) — there is no shared runtime
binary to `execv`, and no stub is needed since the per-app-baked launcher already gets a
unique CDHash for free.

## Division of labour

This crate does **not** compile the app's TypeScript or the native N-API addon — both are
prerequisites, built by the app's own `build.sh` and `bindings/node/native/build.sh`
respectively. `bundle_app` fails fast (`AppNotBuilt` / `AddonNotBuilt`) if either is missing.
What this crate adds on top:

1. **Compile the per-app native launcher** (`launcher.rs`) — a fresh ObjC++ source with this
   app's identity baked in, linked against the build-time host's `libnode`/`libuv` (the
   pinned-matched-pair headers/libs ADR-0060 §2 requires) plus the shared `pump.swift`/
   `pump_shim.cc` embedder core every sample app's dev launcher already proves.
2. **Lay out the bundle** (`standalone.rs`) — the launcher at `Contents/MacOS/<script>`, the
   app's already-`tsc`-compiled `build/js/` tree + `loader.mjs` + a generated
   `bootstrap.cjs` (Frameworks-relative addon `require()`, everything else copied verbatim)
   under `Contents/Resources/app/`, and the addon at
   `Contents/Frameworks/APIAnywareTypeScript.node`.
3. **Vendor + relocate** (`relocate.rs`) — walk the launcher's `otool -L`, vendor every
   Homebrew dylib transitively reachable from `libnode` into `Contents/Frameworks/`, and
   rewrite every load command to `@executable_path/../Frameworks/<name>` via
   `install_name_tool`. The native addon needs **no** relocation: its N-API symbols
   dlopen-resolve against whichever process loaded it, and its only other deps are system
   frameworks + OS-resident Swift dylibs (confirmed via `otool -L`).
4. **Codesign inside-out** — each vendored dylib/addon, then the whole bundle.

## A measured correction to ADR-0060 §2

ADR-0060 assumed a `--shared` `libnode` build statically links V8 + ICU, leaving "minimal
transitive vendoring". The Homebrew `node` formula available in this environment does
**not** do that — its `libnode` dynamically links ~20 further Homebrew dylibs (llhttp,
ada-url, simdjson, brotli, c-ares, openssl, icu4c, …). The vendor-and-relocate mechanism
(the gerbil/chez precedent) already generalizes to this — `relocate.rs` walks the closure
transitively rather than assuming a short, fixed list — so this is a premise correction, not
a design change.

## Build

```sh
cargo run --example bundle_app -p apianyware-bundle-typescript -- hello-window
# → targets/typescript/app-implementations/macos/hello-window/build/Hello Window.app
```

Prerequisites: `hello-window`'s own `build.sh` and
`targets/typescript/bindings/node/native/build.sh` must have already run.

## Test

```sh
cargo test -p apianyware-bundle-typescript                     # cheap checks
cargo test -p apianyware-bundle-typescript -- --ignored --nocapture  # full build + otool check
```

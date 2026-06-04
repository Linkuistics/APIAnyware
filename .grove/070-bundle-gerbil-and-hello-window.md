# 070-bundle-gerbil-and-hello-window

**Kind:** work

## Goal

Build the `bundle-gerbil` crate (self-contained `.app` per ADR-0009) and prove the
whole pipeline end-to-end with a **VM-verified hello-window** — the first sample
app, doubling as the bundler's verification vehicle.

## Context

Distribution recipe is CHARACTERIZED (FINDINGS §5, spec §7): `gxc -exe` against the
`--enable-shared=no` static toolchain (`~/.local/gerbil-0.18.2-static`) embeds the
runtime statically; `-static` (fully-static) is UNSUPPORTED on macOS; the only gap
is vendoring + relocating the Gerbil stdlib's **openssl@3** dylib dep into the
`.app` (`install_name_tool` / `@executable_path`), chez-style. Reference:
`generation/crates/bundle-chez/`. This leaf APPLIES the recipe — it no longer needs
to discover it.

## Done when

- `bundle-gerbil` builds a hello-window `.app`: `gxc -exe` (static toolchain) +
  openssl@3 dylib vendor/relocate; `otool -L` shows no Homebrew dylib deps remain.
- Bundle IDs use `com.linkuistics.*` (never `com.apianyware.*`).
- **hello-window VM-verified via TestAnyware** (never run GUI apps from the CLI —
  verify in a macOS VM; `testanyware` is brew-installed). Actually draws a window;
  CLI smoke does NOT satisfy the done-bar.

## Notes

⚠️ Runtime block-literal companion (from leaf 050/020): every app exe link line must
include `native_block.o` (clang-compiled from `lib/runtime/native_block.c` with
`-fblocks`) alongside `-lobjc` and the touched `-framework`s — the runtime's
`make-objc-block` / native-core references its `aw_make_block_*` symbols. See
`runtime/README.md` "Building" and the 060 build-config note.

⚠️ Two-toolchain perf caveat (spec §1, FINDINGS §3b): the static toolchain's `-O`
Scheme codegen ran ~10× slower than the bottle's. If hello-window feels sluggish,
that is the prelude-optimisation gap, not the binding — investigate whether the
static prelude can be rebuilt at the bottle's `-O` level (open item).

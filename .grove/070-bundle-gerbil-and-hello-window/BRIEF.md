# 070-bundle-gerbil-and-hello-window — brief

## Goal

Build the `bundle-gerbil` crate (self-contained `.app` per ADR-0009) and prove the
whole pipeline end-to-end with a **VM-verified hello-window** — the first sample
app, doubling as the bundler's verification vehicle.

## Decomposition (lazy, grown 2026-06-04)

What looked like one work leaf is a four-stage pipeline with hard sequential
dependencies and one explicitly-flagged unknown ("first full-framework gxc
compile"). Decomposed so each stage is a focused session, and so VM-verify is its
own leaf per the project rule (every sample-app port carries a dedicated
TestAnyware/VM-verify leaf; CLI smoke never satisfies the node's done-bar):

- **010** generate full gerbil bindings — regenerate the IR pipeline from scratch
  (collect → resolve → annotate[merge committed LLM] → enrich), run the first full
  gerbil emit, compile the hand-written runtime under the bottle toolchain. No app
  yet; the milestone is *files emitted + runtime compiles clean*.
- **020** hello-window app + **first full `gxc -exe` compile** (the discovery leaf)
  — write `apps/hello-window/hello-window.ss` (port the chez one), compile against
  the **static** distribution toolchain linking the emitted Foundation/AppKit
  modules + `native_block.o` + frameworks. Shakes out emitter C-correctness at
  scale. CLI smoke run only (no GUI from CLI).
- **030** `bundle-gerbil` crate — `.app` assembly (clone `bundle-chez` shape) +
  openssl@3 dylib vendor/relocate; `otool -L` shows no Homebrew dylib deps;
  `com.linkuistics.*` bundle id.
- **040** VM-verify hello-window via TestAnyware — the node's done-bar; window
  actually draws.

## Context

Distribution recipe (spec §7, **corrected at 070/020**): `gxc -exe` against the
**bottle** (Homebrew) toolchain already embeds the Gerbil/Gambit runtime statically
(links `libgambit.a` by default; `otool -L` shows no libgambit/libgerbil dep; a
trivial exe runs under `env -i`). The `--enable-shared=no` static source toolchain
that FINDINGS §5 prescribed is **NOT needed** — its gsc is ~20× slower and chokes on
`generics.ss` (>1h); the bottle wins on both speed and self-containment. The only
self-containment gap is vendoring + relocating the Gerbil stdlib's **openssl@3**
dylib dep into the `.app` (`install_name_tool` / `@executable_path`), chez-style.
Reference: `generation/crates/bundle-chez/`. This node APPLIES the recipe.

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

⚠️ Emitted modules use the DEFAULT compiler (from node 055, ADR-0021): the emitter
never `#include`s a framework umbrella header — it synthesizes the C declaration
(`extern`/prototype/inline-typedef) for each symbol its `constants.ss`/`functions.ss`/
geometry crossings name, ObjC pointer types spelled `void *`. **Consequence for the
build config this node bakes: generated `.ss` → C compiles use the DEFAULT compiler
(gcc-15) with NO special flags** — no `-cc clang`, no `-x objective-c`, no
SDKROOT-for-clang. The ONLY non-default compile in the whole build is the
`native_block.c` companion above. (Proven at 055/010: a real Foundation
`constants.ss` from the emitter compiled + ran under default gcc-15.)
`SDKROOT=$(xcrun --sdk macosx --show-sdk-path)` is still exported — gambit needs it
for the SDK framework paths — but it does not select a compiler.

⚠️ Toolchain (RESOLVED at 070/020): use the **bottle** for everything (dev AND
distribution). It produces self-contained exes (runtime embedded) AND its gsc is
the fast single-host build. The static source toolchain is retired/unused — its
slow gsc made the two-toolchain perf caveat (spec §3b) moot by being unusable for
real builds, and the bottle's `-O` codegen is the good one anyway.

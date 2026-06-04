# 055-compiler-resolution

**Kind:** planning

## Goal

Resolve — as an **ADR** — how the gerbil target compiles the **emitted**
`constants.ss` / `functions.ss` modules, whose `begin-ffi` blocks `#include` the
framework **umbrella headers** (`<Foundation/Foundation.h>`, `<AppKit/AppKit.h>`,
…) to declare the C symbols they call by name (design §4). Settle this **before**
the first emitted-framework build (060 CLI/build flags, 070 hello-window), so 060
can bake the right compiler invocation into the target's build config.

## Context — the finding (leaf 050/010)

The bottled gerbil's Gambit `gsc` invokes **gcc-15** (Homebrew GNU GCC) as its C
compiler by default, NOT Apple clang. Consequences proven at 050/010:

- gcc-15 compiles **C-safe** headers fine (`<objc/runtime.h>`, `<objc/message.h>`,
  `<CoreGraphics/CGGeometry.h>`) — so the 050 runtime data plane is gcc-15-clean,
  no `-x objective-c`.
- gcc-15 **cannot** parse the Foundation/AppKit **umbrella headers** — it dies on
  blocks (`^`), nullability (`nullable`), and lightweight generics
  (`NSArray<…>`). This blocks every emitted `constants.ss`/`functions.ss`.
- `gxc -gsc-option -cc clang` switches the compiler; standalone
  `clang -x objective-c -framework Foundation` compiles the umbrella cleanly.
  `SDKROOT=$(xcrun --sdk macosx --show-sdk-path)` is required (host default-SDK
  resolution is broken; cf. the project SDKROOT=macosx workaround).
- **OPEN:** under gambit's full flag soup, `-cc clang` changed the error to
  `cannot find protocol declaration for 'NSLinguisticTagScheme'` (lightweight
  generics not enabled) — one clang flag interaction still to bisect
  (`gxc -V` shows gambit's exact clang command; diff vs the working standalone one).

Full detail: the grove-inbox note `…-for-node-060-cli-build-flags-070-bu-…`
(drained next bootstrap) and `lib/runtime/README.md`. Leaf 050/020 (native bridges)
will independently exercise `-gsc-option -cc clang` + `-fblocks` for the runtime's
own ObjC block trampolines — that result is evidence for this decision (run 055
after 020 lands).

## Decision space (for the ADR)

- **(a) Mandate a clang-configured gerbil.** Drive the dev bottle via
  `-gsc-option -cc clang`; `./configure CC=clang` the `--enable-shared=no` static
  source build (§7 distribution) so the shipped toolchain compiles umbrella headers
  natively. Cost: every build invocation carries the `-cc clang` + SDKROOT
  contract; the lightweight-generics flag must be bisected and pinned.
- **(b) Avoid ObjC umbrella headers entirely.** Have `emit_functions` /
  `emit_constants` emit explicit C `extern` declarations for the symbols they
  reference (the emitter has the IR types) instead of `#include`-ing the umbrella.
  Keeps EVERY emitted module gcc-15-compatible, sidesteps the clang/SDK fight.
  Cost: emitter synthesizes decls; revisits design §4's umbrella-header decision.
- **(c) Hybrid** — C-safe modules on gcc-15, only the umbrella-needing ones on
  clang (per-module compiler selection in the 060 build config).

## Done when

- An **ADR** (`docs/adr/NNNN-gerbil-umbrella-header-compiler.md`) records the
  decision + rationale, and the lightweight-generics flag is either resolved
  (option a/c) or made moot (option b), with a verified compile of at least one
  emitted `constants.ss` **or** `functions.ss` (Foundation) as proof.
- The chosen compiler invocation is written into wherever 060 will read it (note
  it here / in the 060 brief), and `knowledge/targets/gerbil.md` (node 100) gets
  the toolchain entry.
- Design spec §4 is reconciled with the outcome (it currently asserts
  `-x objective-c` works for umbrella headers — true only with the clang fix).

## Notes

This is a genuine planning/decision leaf (ADR-worthy), but light on grilling — the
options are technical and mostly settled by experiment. Grill only if the
distribution-toolchain implications (option a's static-build reconfigure) need the
user's call. May fold into 060 if the answer is trivially (b).

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

### Also in scope — geometry struct headers (escalated from leaf 050/040)

The umbrella-header / gcc-15-vs-clang split is **not limited to**
`constants.ss`/`functions.ss`. Any emitted **class/function module** that takes
or returns an NS-prefixed or affine geometry struct by value (`NSRange`,
`NSEdgeInsets`, `NSDirectionalEdgeInsets`, `NSAffineTransformStruct`) emits a
`(c-declare "#include <Foundation/NSRange.h>")` (etc.) into its `begin-ffi`
block — and those Foundation/AppKit headers are **NOT C-safe** (`@class NSString`
in `NSObjCRuntime.h`), so they need the same `-x objective-c` / `-cc clang` path.
Verified at 050/040 by a standalone `cc` probe:

- **plain C (gcc-15 or clang)** — CoreGraphics geometry headers
  (`<CoreGraphics/CGGeometry.h>`, `<CoreGraphics/CGAffineTransform.h>`) compile
  clean; the Foundation/AppKit geometry headers do **not**.
- **`clang -x objective-c`** — all eight geometry struct tags compile
  (CGRect/CGPoint/CGSize/CGVector/CGAffineTransform + `_NSRange`/NSEdgeInsets/
  NSDirectionalEdgeInsets/NSAffineTransformStruct). The CG-only subset also
  round-trips through gsc end-to-end (leaf 050/040 `smoke-geometry.ss`, plain
  path).

So the per-module compiler selection (option **c**) must key on **geometry
tokens too**, not just umbrella `#include`s — a class module with an `NSRange`
arg is a clang-path module even though it includes no framework umbrella. The
emitter already centralises these headers in `geometry_decl` (`emit-gerbil/src/
ffi_type_mapping.rs`), so the build config can detect them from the emitted
`#include` set. One geometry-tag bug was found+fixed at 050/040
(`NSDirectionalEdgeInsets` lives in `<AppKit/NSCollectionViewCompositional
Layout.h>`, not `<Foundation/NSGeometry.h>`).

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

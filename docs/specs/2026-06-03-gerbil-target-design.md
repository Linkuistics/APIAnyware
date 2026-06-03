# Gerbil Scheme target — design spec

**Date:** 2026-06-03  **Grove:** add-gerbil-scheme-target (leaf 030)
**Status:** design agreed; build subtree decomposed from here.

Settles the design of the third language target, `gerbil`, armed with the 020
spike (`docs/research/2026-06-03-gerbil-ffi-dispatch-spike/FINDINGS.md`) and a
030 follow-up that resolved precompilation and the OO-veneer dispatch mechanism.
Written per `docs/adding-a-language-target.md` Step 1.

## 1. Identity & toolchain

- **Language / display name:** Gerbil Scheme.
- **Target id:** `gerbil` (CLI `--target gerbil`; on-disk `generation/targets/gerbil/`).
- **Implementation / pin:** Gerbil **v0.18.2** on the vendored Gambit **v4.9.7**
  (one pin since the v0.18 cycle — Gambit is a git submodule of Gerbil, not an
  external dep). A **compiled-FFI target** (Scheme → Gambit → C → native exe),
  like chez and unlike interpreted-FFI racket.
- **Two toolchains, different roles** (FINDINGS §0, §3b caveat):
  - **Bottled Cellar gerbil** (`/opt/homebrew/Cellar/gerbil-scheme/0.18.2`) —
    `--enable-shared` (dynamic). Its `-O` Scheme codegen is well-optimised; use
    for **development and performance measurement**. Needs the three Cellar-local
    `~~`-resolution symlinks (FINDINGS §0) and a `gsc`/ghostscript unlink dance.
  - **Static source build** (`~/.local/gerbil-0.18.2-static`, `--enable-shared=no`)
    — embeds the runtime statically; use for **distribution** (§7). ⚠️ its `-O`
    Scheme codegen ran ~10× slower than the bottle's on the same source (§3b
    caveat) — measure on the bottle, ship on the static build. Whether the static
    prelude can be rebuilt at the bottle's optimisation level is a build-phase
    open item.
  - ⚠️ Stale-`.o.lock` hazard: a killed `gxc` leaves a zero-byte
    `~/.gerbil/lib/static/<mod>.o.lock` that hangs the next build; clear
    `~/.gerbil/lib/static/<mod>*` before retrying (FINDINGS §0).

## 2. Idiom commitments (ADR-0005)

The emitter writes the source a Gerbil programmer would actually write:

- **`:std/foreign`** FFI: `begin-ffi` + `define-c-lambda` + `c-declare`, NOT raw
  Gambit `c-lambda`. One typed `define-c-lambda` per distinct method ABI signature
  (see §3) — the idiomatic, compiled equivalent of chez's per-signature
  `foreign-procedure`.
- **`define-c-lambda` bodies compile as Objective-C** (§4): the FFI/runtime unit
  is compiled `-x objective-c` so `@autoreleasepool`, blocks, and real ObjC types
  are available — needed for lifetime (§5) and bridges (§6) anyway.
- **`:std/generic`** generic functions for the opt-in OO veneer (§3, Q2), over a
  single `objc-obj` handle struct (`defstruct`). NO `defclass` graph mirroring the
  ObjC class hierarchy.
- **Multiple-value return** for fallible (`NSError**`) methods (§ error model),
  `(values result error)` — converges with chez ADR-0006.
- **Gambit `will`s** for finalization + entry-point `@autoreleasepool` (§5).
- **Module/package layout** per Gerbil convention: a binding **library** compiled
  once to `.ssi`+`.o1`; apps `(import :gerbil-bindings/<framework>/<class>)`.

## 3. Dispatch & native-binding model — Q1 settled (→ ADR-0017)

**Decision: converge with chez ADR-0015 — generated per-signature
`define-c-lambda` dispatch in the Gerbil binding library; the native (Objective-C)
core is reserved for what cannot be a thin call.** Diverges from the 020 spike's
fat-native headline.

Settled on BOTH axes (the task required recording both, where ADR-0015 recorded
only runtime):

- **Runtime axis (FINDINGS §2): a tie.** Inline-cast `objc_msgSend` (11.00 ns) ≈
  the same via a separate C shim (10.98 ns). For a compiled-FFI target both shapes
  are C in the binary, so routing through a native-lib entry is free at runtime —
  the *opposite* of ADR-0015's Chez result. Runtime therefore does **not** pick
  the model.
- **Compile-time axis (FINDINGS §6 + 030 precompilation finding): decides, and
  it does NOT force fat-native.** The spike measured per-method generated Gerbil
  at ~13 ms/method (`define-c-lambda`) vs ~5 ms (thin Scheme) and concluded
  "minimise generated Gerbil → go fat-native," but flagged precompilation as
  possibly reframing it. **030 confirmed the reframe** (a `gxc` of a module
  produces `.ssi`+`.o1`; an importing app reuses them — verified, the library
  `.o1` mtime is untouched across an app build). So the per-method compile cost is
  paid **once at binding-build time**, amortised across every app — a
  binding-regeneration-loop cost (~70 s vs ~27 s for a ~5k-method binding), not a
  per-app tax. The premise that drove fat-native (per-build penalty) is falsified;
  arm64 forces a per-signature typed crossing to exist *somewhere* regardless.
- **Net:** Gerbil keeps the cheap compiled crossing (generated `define-c-lambda`,
  most idiomatic, self-contained), exactly as chez did — and honours ADR-0010 by
  reserving the native core for blocks, delegates, dynamic classes, lifetime, and
  thread activation, the concerns that genuinely cannot be a thin call. ADR-0011
  licenses this divergence from racket's fat-dispatch (ADR-0013) and the
  divergence from the spike's own headline.

**Marshalling depth** (racket's spectrum, design spec §3 there) still applies
per-method: opaque pointers at depth 0; typed scalars/strings/structs at depth 1;
`NSError**` → `(values result error)` at depth 2 — but the marshalling lives in
idiomatic Gerbil/`define-c-lambda`, not a native entry, mirroring chez.

## 3a. Object model — Q2 settled (→ ADR-0018)

**Decision: an opt-in OO veneer of `:std/generic` generic functions over a single
procedural core, dispatching on one `objc-obj` handle struct (no class graph).**

- **Procedural core (the hot path, 16.3 ns, FINDINGS §3):** a single
  `(defstruct objc-obj (ptr))` handle + plain procedures keyed per class
  (namespaces of procedures, not a record hierarchy — mirrors the existing
  `objc-object` convention, CONTEXT.md). Hot loops call procs directly.
- **OO veneer (opt-in, 29.4 ns, FINDINGS §3b):** `:std/generic` generic functions
  (`(defmethod (length (o objc-obj)) ...)`, called `(length o)`). Measured ~31%
  cheaper than Gerbil's built-in `{}` method dispatch (42.8 ns) — it halves the
  veneer tax over the proc core — while keeping the single-handle-struct shape.
  A *pure* native-OO foundation would tax every call ~4×; OO is the **veneer, not
  the foundation**.

## 4. C-vs-ObjC FFI compilation

`gsc` compiles `define-c-lambda` bodies as C by default; framework umbrella
headers (`<Foundation/Foundation.h>`) are Objective-C and fail (FINDINGS §2). The
target compiles its FFI/runtime unit **as Objective-C** (`-x objective-c` via
`gsc`/`gxc` `-cc-options`), because `@autoreleasepool` (§5), blocks/delegates (§6),
and the ObjC native core (§6) need it anyway. C-safe headers (`<objc/runtime.h>`,
`<objc/message.h>`, `<CoreGraphics/CGGeometry.h>`) are used directly; real ObjC
types/selectors are available in the ObjC-compiled unit. `const`-qualified returns
cast via `___CAST`/`___return` to avoid `cast-qual` warnings (FINDINGS §1).

## 5. Lifetime model (→ ADR-0019)

**Decision: Gambit `will`s + entry-point `@autoreleasepool`** — the Gambit-idiomatic
analogue of chez ADR-0007 (which used a guardian, a primitive Gambit lacks).

- Each `objc-obj` wrapper registers a Gambit `(make-will testator action)` whose
  action sends ObjC `release` when the Scheme wrapper becomes collectable.
- The app `main`, every event handler, and every callback trampoline wrap their
  body in an `@autoreleasepool` (the **entry-point autoreleasepool** convention,
  CONTEXT.md, transferred from ADR-0007). Transient `+0` autoreleased objects
  drain at the pool boundary and never reach a will.
- Chez rejected per-instance finalizers (racket's model) for unpredictable
  release *order*; that objection is benign here — ObjC `release` ordering among
  independently-retained objects does not affect correctness, and the entry-point
  pool already handles the transient working-set concern that drove it.

## 6. Native core (Objective-C, compiled by gsc into the exe)

**Decision: the native core is Objective-C, emitted into the FFI unit's
`c-declare` / a companion `.m`, compiled by gsc and statically linked into the
exe — NOT a separate Swift dylib.** Keeps the static-exe fully self-contained (a
dylib would fight the distribution model §7, the way the stray openssl@3 dylib
already does); gsc *is* a C/ObjC compiler, so this is the idiomatic Gerbil path.
ADR-0011 licenses diverging from racket/chez's Swift-dylib shape; ADR-0010 is
honoured in spirit — a purpose-built native core, authored in the language gsc
speaks. Scope of the native core (the only things not expressible as a thin call):

- **Block bridging** — ObjC block trampolines invoking a registered Gerbil
  callback (racket ADR-0014 / chez ADR-0016 analogue, native side).
- **Delegate bridging** — a `DelegateBridge`-equivalent IMP dispatching ObjC
  protocol methods to Gerbil.
- **Dynamic classes** — runtime `objc_allocateClassPair` class synthesis.
- **Thread activation** — the foreign-OS-thread → Gerbil entry mechanism, **TBD
  by the threading spike** (§ threading).

## Error model

**`(values result error)`** for every method whose ObjC signature takes a trailing
`NSError**` out-param (`#f` on success, an `nserror` struct on failure); callers
use `let-values`. In-band, no raise — converges with chez **ADR-0006** (same
rationale: NSError is routine/recoverable, multiple-values is zero-alloc on the
success path and keeps the autoreleasepool boundary clean). No separate Gerbil ADR
— this decision *is* ADR-0006 applied to gerbil; recorded here.

## Threading — spike-gated

Gambit's default thread model is **green (user-level) threads**, the biggest
Chez→Gerbil divergence: chez ADR-0016's `__collect_safe`/`Sactivate_thread` made
foreign-OS-thread callbacks (GCD workers) safe via Chez's *native* threads. Whether
a foreign OS thread can safely enter Gambit Scheme, and the activation analogue
(`___EXT`? a Gambit-specific dance?), is **genuinely unknown and not covered by the
020 spike**. A dedicated build-subtree investigation leaf characterizes it BEFORE a
threading ADR is written. Early sample apps (hello-window, ui-controls) are
main-thread-only, so this does not block early build progress.

## 7. Distribution model (FINDINGS §5 — characterized)

**`gxc -exe` against the `--enable-shared=no` static toolchain + `.app`
dylib-relocation of the openssl@3 deps.** Realises ADR-0009 self-contained
distribution on macOS's terms:

- `gxc -exe` against the static toolchain embeds the Gerbil/Gambit runtime
  statically (`otool -L` shows no libgambit/libgerbil dep). Frameworks link via
  `-ld-options "-framework AppKit"`.
- **`-static` (fully-static) is unsupported on macOS** (`ld: crt0.o not found` —
  Apple does not allow statically linking libSystem). Do NOT pursue it.
- **Self-containment gap:** the Gerbil stdlib pulls **openssl@3**
  (libssl/libcrypto) via Homebrew paths. The `.app` bundler must **vendor + relocate**
  these dylibs (`install_name_tool` / `@executable_path`), the same dylib-staging
  chez's bundler does. System `/usr/lib/*` deps need nothing.
- **Bundler crate:** `bundle-gerbil`, paralleling `bundle-chez`.

## 8. On-disk layout (parallels chez)

```
generation/crates/emit-gerbil/        # emitter crate
generation/crates/bundle-gerbil/      # bundler crate
generation/targets/gerbil/
  runtime/        # Gerbil runtime modules (ffi, objc, types, cocoa, dispatch) +
                  # the ObjC native core (.m / c-declare) + tests
  apps/           # 7 sample apps (drawing-canvas, hello-window, mini-browser,
                  # note-editor, pdfkit-viewer, scenekit-viewer, ui-controls-gallery)
  lib/            # generated binding library (compiled once to .ssi+.o1)
knowledge/targets/gerbil.md           # target-wide learnings
```

## 9. ADRs raised from this spec

- **ADR-0017** — Gerbil dispatch & native-core model (Q1; §3, §6): generated
  `define-c-lambda` dispatch (converge chez 0015) + ObjC-in-gsc native core
  (diverge racket/chez Swift dylib); records both axes incl. precompilation.
- **ADR-0018** — Gerbil object model (Q2; §3a): opt-in `:std/generic` veneer over a
  procedural core, single handle struct.
- **ADR-0019** — Gerbil lifetime model (§5): Gambit wills + entry-point
  `@autoreleasepool`.
- Error model (§ error model) converges with **ADR-0006** — no new ADR.
- Threading ADR — **deferred** to the spike-gated build leaf.

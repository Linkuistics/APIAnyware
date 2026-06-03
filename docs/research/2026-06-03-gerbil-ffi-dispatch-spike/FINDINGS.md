# Gerbil FFI / dispatch characterization spike — FINDINGS

**Date:** 2026-06-03  **Grove:** add-gerbil-scheme-target, leaf 020
**Toolchain:** Gerbil v0.18.2 on Gambit v4.9.7 (Homebrew bottle)

Settles the forks 010-plan deferred: Q1 (dispatch model), Q2 (object model),
plus the user-raised compile-time DX axis, and de-risks distribution. Models
chez's `docs/research/2026-06-02-chez-dispatch-spike/`. Status legend: ✅ done /
⏳ pending / ⚠️ caveat.

## 0. Toolchain provisioning (✅ — important for knowledge/targets/gerbil.md)

`brew install gerbil-scheme` → **0.18.2** (bottled; vendors Gambit 4.9.7 since the
v0.18 cycle). Two real obstacles on this machine, both resolved without a source
build:

1. **`gsc` name collision with ghostscript.** Both formulae ship a `gsc`
   (gerbil's = the Gambit Scheme Compiler; ghostscript's = a ghostscript alias).
   Homebrew refuses to link gerbil while ghostscript owns the `gsc` symlink.
   Resolution: install gerbil **unlinked**, keep ghostscript linked, drive gerbil
   from its Cellar bin (`/opt/homebrew/Cellar/gerbil-scheme/0.18.2/bin`) on PATH.
   (Globally `brew link --overwrite gerbil-scheme` would also work but shadows
   ghostscript's `gsc` — deferred to a user decision; not needed.)

2. **Split Gambit prefix breaks `gsc`'s `~~` resolution when unlinked.** The
   bottle lays out the Gambit prefix at `…/0.18.2/{bin,include,lib}` but the
   versioned Gerbil libs at `…/0.18.2/v0.18.2/lib`. `gxc` invokes Gambit's `gsc`
   expecting it (and `gambuild-C`, `include/`) under `…/v0.18.2/…`, so it fails
   with `~~include`/`gambuild-C` "No such file or directory". Resolution — three
   Cellar-local symlinks (contained to the gerbil keg, reversible, touch nothing
   else):

   ```sh
   P=/opt/homebrew/Cellar/gerbil-scheme/0.18.2 ; V=$P/v0.18.2
   mkdir -p "$V/bin"
   for f in "$P"/bin/*; do ln -sf "../../bin/$(basename "$f")" "$V/bin/"; done
   ln -sfn ../include "$V/include"
   ```
   (`…/0.18.2/lib` is already just symlinks into `v0.18.2/lib`, so the lib side
   needs nothing.)

   **Build env that works:**
   ```sh
   export PATH="/opt/homebrew/Cellar/gerbil-scheme/0.18.2/bin:$PATH"
   unset GERBIL_HOME            # let gerbil self-locate to …/v0.18.2
   gxc -exe -o prog -ld-options "-framework Foundation" prog.ss
   ```

   ⚠️ **Stale lockfile hang:** a killed `gxc` leaves a zero-byte
   `~/.gerbil/lib/static/<mod>.o.lock`; the next `gxc` blocks on it forever (low
   CPU, growing elapsed). Clear `~/.gerbil/lib/static/<mod>*` before retrying.

   **Open for the distribution leaf:** the bottle is `--enable-shared` (dynamic),
   so spike item 5 (`-static`) likely needs a `--enable-shared=no` *source* build.
   The target's bundler wants static-exe regardless, so a source-built gerbil is
   probably the eventual toolchain. TBD in item 5.

## 1. FFI reachability (✅ PASS)

`docs/research/2026-06-03-gerbil-ffi-dispatch-spike/01-reachability.ss`. A
`begin-ffi` block with `c-declare`'d `<objc/runtime.h>`+`<objc/message.h>` and
`define-c-lambda`s for `objc_getClass`, `sel_registerName`, and two
signature-cast `objc_msgSend` wrappers round-trips a string through
`+[NSString stringWithUTF8String:]` → `-[NSString UTF8String]`:

```
round-trip: hello from gerbil via objc_msgSend
RESULT: PASS — :std/foreign reaches objc_msgSend and round-trips NSString
```

Notes for the emitter:
- `objc_msgSend` is untyped/variadic in the headers; each call shape needs an
  **inline C cast** to a concrete function-pointer signature inside the
  `define-c-lambda` body (`((id (*)(id, SEL, const char*))objc_msgSend)(…)`).
  This is the compiled-FFI equivalent of chez open-coding one typed
  `foreign-procedure` per signature (ADR-0015) — the cast is per-signature.
- `gxc -exe` requires the module to `(export main)`.
- ⚠️ Cast `const char*` returns through `___CAST(char*, …)` (or return as an
  opaque pointer + a separate copy step) to avoid the `-Wincompatible-pointer`
  /`cast-qual` warning seen here. Cosmetic now; clean it in the emitter.

## 2. Dispatch cost — runtime (✅ settles Q1 axis 1)

`02-dispatch-cost.ss`, `-O`, 30M calls each, monotonic-clock FFI timer,
`-[NSString length]` on a 19-char string:

| call shape | ns/call |
|---|---|
| `nop` — bare `define-c-lambda` crossing floor | **4.84** |
| `direct` — inline-cast `objc_msgSend` (chez ADR-0015 shape) | **11.00** |
| `shim` — same msgSend via a separate C function (the "extra hop") | **10.98** |

**Headline: `direct` and `shim` are a statistical dead heat (~0.02 ns apart).**
In a compiled-FFI target both shapes are C in the binary, so routing through a
native-lib-style C entry is *free* at runtime. This is the **opposite** of
ADR-0015's Chez result (there a shim was equal-or-slower, so Chez kept direct
dispatch alone at the floor). For Gerbil **runtime does not favour either dispatch
model** → the choice falls to the compile-time-DX axis (item 6). The bare crossing
is ~4.8 ns (≈44% of an 11 ns msgSend), so the FFI seam is not free but is cheap.

Caveat: the `shim` here is a `static` C fn in the same TU (inlinable). A real
`libAPIAnywareGerbil.dylib` entry is a cross-dylib call (~1–2 ns PLT indirection),
still negligible vs 11 ns. Conclusion holds.

**Emitter finding (⚠️ important):** `gsc` compiles `define-c-lambda` bodies as
**plain C**. C-safe headers only — `<objc/runtime.h>`, `<objc/message.h>`,
CoreGraphics (`CGRect`/`CGFloat` are C). Framework umbrella headers
(`<Foundation/Foundation.h>`, `<AppKit/AppKit.h>`) are Objective-C and fail to
compile ("stray '@'", "unknown type name 'class'"). The real target must either
spell ObjC types via plain-C equivalents (`NSUInteger`=`unsigned long`, etc.) or
make `gsc` compile the FFI unit as **Objective-C** (`-x objective-c`) — which it
will want anyway for `@autoreleasepool`/blocks (ADR-0007/0016). → a Q for 030.

## 3. OO-layering tax (✅ validates Q2 layering direction)

`03-oo-tax.ss`, `-O`, 30M calls, `-[NSString length]`:

| layer | ns/call | tax |
|---|---|---|
| raw-ffi (raw `id` pointer) | 10.95 | — (matches item 2) |
| `proc over struct` — procedural CORE (handle struct + plain proc) | 16.64 | +5.7 ns (unwrap + call) |
| `method {} dispatch` — OO VENEER (Gerbil generic method) | 43.80 | **+27.2 ns over core** |

Gerbil's `{method obj}` single-dispatch costs **~27 ns** (a method-table lookup),
~2.6× the procedural-core call; the OO veneer is ~4× the raw FFI call.

**Validates the Q2 layering design (user proposal):** the veneer's dynamic-dispatch
tax is real, so making OO **opt-in over a procedural core** is correct — hot loops
use the 16.6 ns proc layer, ergonomic sites pay 43.8 ns for `{length obj}`. A
*pure* native-OO foundation would tax every call ~4×, so OO must be the **veneer,
not the foundation**. Absolute 30 ns is negligible for event-driven UI code (no
30M-call loops), so the veneer is fine for ordinary app code; the tax only bites
in tight loops, where the layering lets the programmer drop down. For 030: explore
whether a cheaper veneer dispatch (`:std/generic`, or predicate-dispatch) beats
built-in `{}` if the tax ever matters.

### 3b. OO-veneer dispatch mechanism — `:std/generic` vs built-in `{}` (✅ — 030 follow-up, settles veneer dispatch)

`03b-generic-tax.ss`, **built with the bottled Cellar gerbil** (see ⚠️ toolchain
note below), `-O`, 30M calls, same `-[NSString length]` harness, veneer dispatches
on the RECEIVER only (`(length obj)`, selector baked in — the realistic veneer shape):

| layer | ns/call | tax over proc core |
|---|---|---|
| raw-ffi (ptr) | 10.9 | — |
| proc over struct (procedural core) | 16.3 | — |
| **`:std/generic` dispatch** | **29.4** | **+13.1 ns** |
| built-in `{}` dispatch | 42.8 | +26.5 ns |

**`:std/generic` is ~31% faster than built-in `{}` (29.4 vs 42.8 ns) — it HALVES the
veneer's opt-in tax over the procedural core.** Item 3's headline (built-in `{}` at
43.8 ns) measured only `{}`; this follow-up shows the cheaper mechanism. Structural
reason: `:std/generic` has arity-specialised dispatchers (`generic-dispatch1..4`,
`std/generic/dispatch.ss`) keyed on the type descriptor; built-in `{}` does a MOP
method-table lookup by type+name each call. Both dispatch on the single `objc-obj`
handle struct (no class graph). Correct `:std/generic` method form (NOT `{name type}`):
`(defmethod (generic-id (arg type)) body)`. **030 decision: the OO veneer uses
`:std/generic` generic functions over the single handle struct.**

⚠️ **Toolchain-perf caveat (important for `knowledge/targets/gerbil.md`):** the two
gerbil toolchains are NOT interchangeable for *performance* measurement. The same
source built with the `--enable-shared=no` **static toolchain**
(`~/.local/gerbil-0.18.2-static`) ran the Scheme paths ~10× slower (proc 16→83 ns,
`{}` 43→476 ns) than the **bottled Cellar** build, while the FFI path was unchanged —
i.e. the static prelude's `-O` Scheme codegen is far less optimised. **Measure on the
bottle; distribute on the static build** (§5). Whether the static prelude can be
rebuilt at the bottle's optimisation level is an open item for the build phase.

## 4. Struct-by-value returns (CGRect) (✅ PASS)

`04-struct-return.ss`. Both probes pass:
- **A** — construct a `CGRect` in C, return by value, read fields:
  `x=10 y=20 w=300 h=400` ✓ (Gambit struct-return ABI works).
- **B** — real `objc_msgSend` struct return: box an NSRect via
  `+[NSValue valueWithBytes:objCType:]`, read it back via `-[NSValue rectValue]`
  cast to return `CGRect` by value: `x=1 y=2 w=3 h=4` ✓ (arm64 x8 hidden-pointer
  struct-return ABI handled by the C cast).

Emitter notes: `(c-define-type CGRect (struct "CGRect"))`; struct args pass **by
value** (`___arg1.origin.x`, dot not arrow); `<CoreGraphics/CGGeometry.h>` is
C-safe (CGRect/CGFloat/CGRectMake). A returned struct comes back as a Gambit
foreign heap copy needing field accessors — so per the native-lib/marshalling-depth
model (ADR-0010/-0013), the real entry will more likely return the rect
*decomposed* into Scheme floats (multiple values / f64vector) rather than hand a
foreign CGRect to Scheme. Capability proven either way.

## 5. Static-exe + framework link (✅ characterized — macOS distribution recipe found)

The `--enable-shared=no` source toolchain finished
(`build-gerbil-static.sh` → `~/.local/gerbil-0.18.2-static`, ~80 min from-scratch
self-hosting build). Results:

**(a) Fully-static (`gxc -exe -static`) does NOT work on macOS.**
`ld: library 'crt0.o' not found` — Apple does not support statically linking
libSystem / fully-static executables. Gerbil's docs' "provided your system
supports it" caveat *excludes* macOS. Do not pursue `-static` for the target.

**(b) The correct macOS recipe: `gxc -exe` against the `--enable-shared=no`
toolchain.** Compiles, runs, FFI round-trips, and **embeds the Gerbil/Gambit
runtime statically** — `otool -L` shows NO libgambit/libgerbil dylib dependency.
Frameworks link normally (`-ld-options "-framework Foundation"` and
`"-framework AppKit"` both ✅; `NSApplication` resolves at runtime → AppKit PASS).

**(c) The self-containment gap the bundler must close.** `otool -L` of a plain
`gxc -exe` binary:
```
Foundation / AppKit (system frameworks)        ✓ always present
/usr/lib/libSystem.B.dylib, libz, libsqlite3,
  libobjc.A.dylib                              ✓ system (/usr/lib)
/opt/homebrew/opt/openssl@3/libssl.3,
  libcrypto.3                                  ⚠️ Homebrew — NOT on a clean target
```
The Gerbil stdlib pulls **openssl@3** (libssl/libcrypto) via Homebrew paths. For
ADR-0009 self-contained distribution the `.app` bundler must **vendor these
dylibs into the bundle and relocate their load paths** (`install_name_tool` /
`@executable_path`/`@rpath`) — the same dylib-staging chez's bundler does. System
`/usr/lib/*` deps need nothing.

**Net macOS distribution model for gerbil (for the bundler leaf):** NOT
fully-static; instead **`gxc -exe` (static runtime via `--enable-shared=no`) +
.app dylib-relocation of the openssl@3 deps**. This realises ADR-0009
("self-contained, no Gerbil install on target") on macOS's terms.

**Still for the build phase (genuinely needs it):** a VM-verified hello-window
(actually drawing) is a sample-app leaf per the app ladder + the VM-verify rule;
this spike proved the toolchain/link/runtime-embed, not pixels.
## 6. Compile-time DX vs generated-FFI volume (✅ settles Q1 axis 2 — user steer)

`06-compile-time.sh` (N typed `define-c-lambda` per method — the chez ADR-0015
emission shape) and `06b-scheme-only.sh` (N pure-Scheme thin wrappers over ONE
shared FFI entry — the fat-native-lib shape). `gxc -exe -O`, clean build each:

| N methods | 06 define-c-lambda (s) | 06b Scheme-only (s) |
|---|---|---|
| 10 | 3.24 | 3.29 |
| 100 | 3.88 | 3.52 |
| 250 | 5.11 | 3.98 |
| 500 | 7.83 | 5.11 |
| 1000 | **15.82** | **7.82** |

Marginal cost: **~13.3 ms/method** (define-c-lambda) vs **~4.8 ms/method**
(Scheme-only) over a ~3.2 s base. ~2.8× cheaper to keep the FFI in one shared
entry and emit thin Scheme — but **neither curve is flat**: Gerbil compiles *all*
emitted Scheme → Gambit → C → machine code, so per-method Gerbil of any kind
costs. Extrapolated: a realistic binding (~5k methods across Foundation+AppKit+…)
is ~70 s/clean-build as per-method define-c-lambda, ~27 s as thin Scheme — the
Chez compile-time PITA, confirmed and quantified.

**Conclusions for Q1 (combined with item 2):**
- Runtime is a dead heat (item 2) → runtime does NOT pick the dispatch model.
- Compile-time DECIDES, and it says: **minimise per-method generated Gerbil.**
  Push per-method dispatch into the precompiled native lib (racket ADR-0013
  direction), keeping the Gerbil surface as thin as possible. Gerbil legitimately
  **diverges from Chez** (ADR-0015 kept per-method emission because runtime
  favoured it and it never weighed compile time) — ADR-0011 licenses this.
- **The deeper lever — precompilation (for 030 to settle):** constant compile
  time needs the Gerbil surface to NOT grow with method count, which collides
  with idiom (named per-method `(length str)` bindings ARE per-method Gerbil).
  Likely resolution: Gerbil compiles binding **libraries to `.ssi`+`.o` once**;
  apps importing them don't recompile, so the binding's cost is paid at
  binding-build time, not per app build. MUST verify in 030 whether Chez's PITA
  was per-app recompilation — it reframes the whole trade-off.

## Synthesis for 030 (Q1 + Q2 settled; item 5 pending the static build)

**Q1 — dispatch / native-binding model: go FAT NATIVE (racket ADR-0013
direction), NOT chez direct-dispatch (ADR-0015). Gerbil diverges from Chez.**
- Runtime is a *tie*: direct inline-cast msgSend (11.00 ns) ≈ msgSend via a C shim
  (10.98 ns) — item 2. Routing through a native-lib entry costs ~nothing at
  runtime for a compiled-FFI target. So runtime does not pick the model (unlike
  ADR-0015, where it picked direct).
- Compile-time *decides* (item 6): per-method generated Gerbil costs ~13 ms/method
  (define-c-lambda) or ~5 ms/method (thin Scheme); a realistic binding is tens of
  seconds to ~70 s per clean build — the Chez PITA, quantified. Minimise per-method
  generated Gerbil → push dispatch + marshalling into the precompiled native lib.
- **Net:** Gerbil most fully realises ADR-0010 — fattest native (Swift) core,
  thinnest scripting seam — reached via the *compile-time* axis, not runtime.
  ADR-0011 licenses the divergence from Chez. **Write a Gerbil dispatch ADR that
  records BOTH axes** (where ADR-0015 recorded only runtime).
- **MUST resolve in 030 — precompilation:** does Gerbil's compile a binding
  *library* to `.ssi`+`.o` once (so app builds don't recompile it)? If yes, the
  per-method compile cost is paid at binding-build time, not per app, which
  changes how aggressively we must minimise generated surface. Verify whether
  Chez's PITA was per-app recompilation.

**Q2 — object model: LAYER an opt-in OO veneer over a procedural core (the user's
design). Validated.**
- Procedural core (handle struct + plain proc) = 16.6 ns; OO veneer (Gerbil
  `{method}` generic dispatch) = 43.8 ns — a real ~27 ns opt-in tax (item 3).
- So OO is the **veneer, not the foundation**: hot loops use the proc core,
  ergonomic sites use `{length obj}`. A pure native-OO foundation would tax every
  call ~4×. 030: pick the veneer's dispatch (built-in `{}` vs `:std/generic` vs
  predicate) and whether it mirrors the ObjC class graph or is generic functions
  over the single handle struct (spike leans the latter — no graph to maintain).

**Emitter findings to carry into the build:**
- `define-c-lambda` bodies compile as **C**: C-safe headers only, or make `gsc`
  compile the FFI unit as **Objective-C** (`-x objective-c`) — wanted anyway for
  `@autoreleasepool`/blocks (ADR-0007/0016 analogues). Decide in 030.
- Cast `const` returns via `___CAST` to avoid warnings (item 1).
- Struct-by-value works; `(c-define-type … (struct …))`, by-value args (item 4).
- Toolchain provisioning recipe + the stale-`.o.lock` hazard (§0).

**Distribution (item 5): ✅ characterized.** macOS recipe = `gxc -exe` against the
`--enable-shared=no` toolchain (`~/.local/gerbil-0.18.2-static`) — embeds the
Gerbil/Gambit runtime statically, links system frameworks; `-static`
(fully-static) is unsupported on macOS (no crt0.o). The only self-containment gap
is the Gerbil stdlib's **openssl@3** Homebrew dylib dep, which the `.app` bundler
must vendor + relocate (chez-style). 030's distribution leaf APPLIES this recipe
(+ VM-verified hello-window), it no longer needs to discover it. See §5.

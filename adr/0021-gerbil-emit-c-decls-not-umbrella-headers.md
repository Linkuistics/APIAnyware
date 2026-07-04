# Gerbil emitter synthesizes C declarations; it never `#include`s a framework umbrella header

The `gerbil` target's emitted data modules (`constants.ss`, `functions.ss`, and
any class module taking/returning a geometry struct by value) declare the C
symbols their `define-c-lambda` bodies name by **synthesizing the C declaration in
the emitter** — an `extern` for a global, a prototype for a function, an inline
plain-C typedef for a non-C-safe struct — and **never by `#include`-ing the
framework umbrella header** (`<Foundation/Foundation.h>`, `<AppKit/AppKit.h>`, …).
Every emitted module therefore compiles under the bottle's **default C compiler
(gcc-15)** with **no** `-cc clang`, **no** `-x objective-c`, **no** SDKROOT
contract, and **no** per-module compiler selection. This deviates from the earlier
design-spec §4 approach
(`targets/gerbil/docs/design/2026-06-03-gerbil-target-design.md`), which had the emitter `#include`
the umbrella and compile the FFI unit `-x objective-c` — that approach is not used.

## Context

`gsc` compiles `define-c-lambda` bodies as C. The bottled gerbil
(`gerbil-scheme 0.18.2`) is configured `CC=gcc-15` (its
`configure-command-string` shows `'CC=gcc-15'`). gcc-15 compiles the C-safe
headers the runtime data plane uses (`<objc/runtime.h>`, `<objc/message.h>`,
CoreGraphics geometry) but **cannot parse the Foundation/AppKit umbrella headers**
— it dies on `@class`, blocks (`^`), nullability (`nullable`), and lightweight
generics (`NSArray<…>`). Found at leaf 050/010; reconfirmed here:

```
NSObjCRuntime.h:617: error: stray '@' in program     # @class NSString, Protocol;
```

Since the class emitter dispatches dynamically (`objc_msgSend` on selector
strings) it needs no framework header. Only modules that name a C symbol *by name*
are affected: `constants.ss` (reads `extern` globals), `functions.ss` (calls free
C functions), and geometry-struct-by-value crossings (need the struct's C tag).
chez sidesteps declarations entirely — `foreign-entry` / `foreign-procedure`
resolve the symbol by string at link/load time (dlsym). Gambit cannot: it emits
real C that *names* the symbol, so the symbol must be **declared** in the
translation unit. That single requirement — a declaration — is the whole problem.

## Options considered

- **(a) Mandate a clang-configured gerbil.** Keep the umbrella `#include`s; ship a
  toolchain `./configure`d `CC=clang` (a §7 distribution change) so the compiler
  parses ObjC natively. Rejected: it is a distribution-toolchain change, and the
  dev/measure bottle (gcc-15) cannot be used as-is. A *runtime* `-cc clang`
  override on the gcc-configured bottle was tested and is **brittle** — it breaks
  gambit's gcc-tuned `-dynamic` loadable-link step with a spurious
  `Undefined symbols … "_main"` even for a trivial **C-safe** module, because the
  dynamic-link recipe is tuned for the configured compiler. `-cc clang` only works
  cleanly on a gambit actually *built* with clang.
- **(c) Hybrid per-module compiler selection.** C-safe modules on gcc-15, umbrella
  / NS-geometry modules on clang, routed by scanning the emitted `#include` set in
  the 060 build config. Rejected: inherits (a)'s `-dynamic` `_main` brittleness on
  the gcc-15 bottle, and adds two-toolchain build-config complexity.
- **(b) Synthesize C declarations — CHOSEN.** Emit the declaration the
  `define-c-lambda` needs, spelling ObjC pointer types as `void *`. Every emitted
  module stays plain-C / gcc-15-clean. The one translation unit gcc-15 genuinely
  cannot parse — the ObjC **block literals** in `native_block.c` — already lives in
  a separate clang `-fblocks` companion (runtime README); option (b) adds nothing
  to the clang surface. Cost: the emitter synthesizes decls (it has the IR types),
  and the C seam loses the umbrella's documentary ObjC types — but the Scheme side
  already owns all wrapping/typing, so the C seam is pure ABI, exactly as chez
  already operates.

The decisive evidence is that **chez resolves the identical constant/function
symbol set purely by name** — which proves every such symbol is a real linkable
extern (not an inline/macro), so a synthesized `extern` is always sufficient.

## Decision — the synthesized-declaration mechanism

**constants.ss** — replace the single umbrella `#include` with one `extern` per
non-CFSTR constant:

| flavour | declaration | crossing body |
|---|---|---|
| object (`NSString * const`, `id`) | `extern void * const NAME;` | `___return((void*)NAME);` |
| struct-addr global | `extern const char NAME;` | `___return((void*)&NAME);` |
| scalar `tok` | `extern <C(tok)> NAME;` | `___return(NAME);` |

(The struct-addr `const char` is a fiction: only `&NAME` is taken, and the linker
binds `NAME` to the real symbol's address. POINTER-token scalars use
`void * const` and cast in the body.)

**functions.ss** — replace the umbrella `#include` with a synthesized prototype
per function, keeping the short `"NAME"` body (Gambit generates the call):

```scheme
(c-declare "extern <C(ret)> NAME(<C(arg1)> …);")
(define-c-lambda NAME (<arg-tokens>) <ret-token> "NAME")
```

Emit `(c-declare "#include <stdbool.h>")` once if any slot is `bool`.

**token → C type `C(tok)`** (each verified to compile + run under gcc-15):

| token | C type | token | C type |
|---|---|---|---|
| `(pointer void)` | `void *` | `int32` | `int` |
| `char-string` | `const char *` | `unsigned-int32` | `unsigned int` |
| `void` | `void` | `int64` | `long long` |
| `bool` | `bool` (needs `<stdbool.h>`) | `unsigned-int64` | `unsigned long long` |
| `int8` | `signed char` | `float` | `float` |
| `unsigned-int8` | `unsigned char` | `double` | `double` |
| `int16` | `short` | geometry token | its struct tag |
| `unsigned-int16` | `unsigned short` | | |

**geometry** — the CoreGraphics geometry headers are C-safe (gcc-15-clean), so CG
tokens keep `#include <CoreGraphics/…>`. The four NS-prefixed structs have
non-C-safe headers, so the emitter emits an **inline plain-C tagged typedef**
instead (`CGFloat`→`double`, `NSUInteger`→`unsigned long`), preserving the
`(c-define-type Tok (struct "tag"))` crossing token. (Implemented in leaf
055/020.)

## Consequences

- The bottle's default compiler builds everything; 060/070 bake **no** special
  compiler flag for emitted modules. The only non-default compile remains the
  pre-existing `clang -fblocks` companion (`native_block.c`).
- The emitter gains a small token→C-type table and per-symbol decl synthesis;
  emit-gerbil unit tests that asserted `#include <umbrella>` are rewritten.
- The C seam types are ABI-only (`void *` for objects); type intent lives on the
  Scheme side, as in chez. Acceptable per ADR-0011 (per-target idiom).
- Geometry: one ABI risk — the inline NS-struct field layouts are hardcoded; they
  are cross-checked against the SDK headers and the 050/040 smoke-geometry build.

## Proof (this leaf, gcc-15, no clang / no `-x objective-c`)

Real Foundation symbols, synthesized `extern`s, default compiler:

```
NSCocoaErrorDomain non-null: #t = NSCocoaErrorDomain
NSURLFileScheme   non-null: #t = file
NSFoundationVersionNumber = 5026.5            # constants.ss shape
NSHomeDirectory = /Users/antony              # functions.ss shape (object return)
NSRange round-trip = {3, 7}                   # functions.ss NS-geometry by value
i64=42 u64=42 i32=42 dbl=3. flt=3. bool=#t i8=10 str=hello-from-c   # full token table
```

The same default gcc-15 invocation that fails on `#include <Foundation/Foundation.h>`
(`stray '@'`) compiles the synthesized-`extern` module cleanly and the program
reads the real symbol values. The `NSRange` line is the strongest geometry proof:
an `NSRange` left C as a by-value `struct _NSRange` **return** (`NSRangeFromString`)
and re-entered as a by-value **arg** (`NSStringFromRange`), spelled only by the
emitter's inline `struct _NSRange` — identical formatting out confirms the field
offsets are ABI-exact. Converted-emitter output is compile-verified for constants
at leaf 055/010 (`examples/dump_foundation_constants.rs`) and for functions +
geometry at 055/020 (`examples/dump_foundation_functions.rs`); the runtime
smoke-geometry suite additionally round-trips all four NS structs by value under
the default compiler.

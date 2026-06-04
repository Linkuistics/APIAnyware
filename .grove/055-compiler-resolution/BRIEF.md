# 055-compiler-resolution — brief

**Kind:** planning node (decomposed 2026-06-04)

## Goal

Resolve how the gerbil target compiles the **emitted** `constants.ss` /
`functions.ss` (and any geometry-struct-bearing class) modules — whose
`begin-ffi` blocks named framework C symbols by `#include`-ing the framework
**umbrella headers** (design §4), which the bottle's default **gcc-15 cannot
parse**. Settle this **before** the first emitted-framework build (060/070).

## Decision — RESOLVED 2026-06-04 → **option (b)** (grilled; user-confirmed)

**Synthesize C declarations in the emitter; never `#include` a framework umbrella
header.** Every emitted module then compiles under the bottle's **default
gcc-15** — no `-cc clang`, no `-x objective-c`, no SDKROOT contract, no
per-module compiler selection. The ADR is `docs/adr/0021-gerbil-emit-c-decls-not-umbrella-headers.md`.

Why (experiments at this leaf, see ADR):
- The bottle's gambit is configured `CC=gcc-15`. A runtime `-cc clang` override is
  **brittle** — it breaks gambit's gcc-tuned `-dynamic` loadable link (spurious
  `_main` undefined) even for a trivial C-safe module. Option (a) would need a
  `./configure CC=clang` rebuilt toolchain (a §7 distribution change).
- **chez resolves the identical constant/function symbol set purely by name**
  (`foreign-entry`/`foreign-procedure`, no headers) — proving every symbol is a
  real linkable extern. So synthesizing `extern` decls (ObjC pointer → `void *`)
  is sufficient. Gambit needs the symbol *declared* (it emits real C naming it),
  unlike chez's dlsym-by-string — that declaration is the only delta.
- **Proven** under gcc-15: real Foundation constants (`NSCocoaErrorDomain`,
  `NSURLFileScheme`, `NSFoundationVersionNumber`), real Foundation functions
  (`NSHomeDirectory` → `/Users/...`), and the full scalar/`bool`/`char-string`
  token vocabulary, all compiled + ran green. `bool` needs the C-safe
  `<stdbool.h>` (gcc-15-clean).

### The synthesized-declaration mechanism (for the implementing leaves)

- **constants.ss** — per symbol, replace the one umbrella `#include` with:
  - object (`NSString * const` / `id`): `(c-declare "extern void * const NAME;")`,
    body `___return((void*)NAME);`
  - struct-addr global: `(c-declare "extern const char NAME;")`, body
    `___return((void*)&NAME);` (only the address is used; the `char` type is a
    fiction the linker resolves to the real symbol).
  - scalar `tok`: `(c-declare "extern <C(tok)> NAME;")`, body `___return(NAME);`
    (POINTER token → `void * const`, body casts to `void*`).
- **functions.ss** — per function, replace the umbrella `#include` with a
  synthesized prototype `(c-declare "extern <C(ret)> NAME(<C(arg)>…);")`; keep the
  short `"NAME"` body (Gambit generates the call). Add `<stdbool.h>` once if any
  slot is `bool`.
- **token → C type `C(tok)`** (verified): `(pointer void)`→`void *`,
  `char-string`→`const char *`, `void`→`void`, `bool`→`bool`,
  `int8`→`signed char`, `unsigned-int8`→`unsigned char`, `int16`→`short`,
  `unsigned-int16`→`unsigned short`, `int32`→`int`, `unsigned-int32`→`unsigned int`,
  `int64`→`long long`, `unsigned-int64`→`unsigned long long`, `float`→`float`,
  `double`→`double`. Geometry tokens spell their struct tag (see geometry).
- **geometry** (the "also in scope" escalation): the **CoreGraphics** headers are
  C-safe (gcc-15-clean) — KEEP `#include <CoreGraphics/…>` for CG tokens. The four
  **NS-prefixed** geometry structs (`_NSRange`, `NSEdgeInsets`,
  `NSDirectionalEdgeInsets`, `NSAffineTransformStruct`) have non-C-safe headers, so
  emit an **inline plain-C tagged typedef** instead (`CGFloat`→`double`,
  `NSUInteger`→`unsigned long`), keeping the `(c-define-type Tok (struct "tag"))`.
  This is 020's verification job (exact field layouts; ABI-stable).

## Children

- **010** — ADR `0021` + convert the **constants** emitter to option (b) +
  prove against real emitter output compiled under gcc-15 + reconcile design §4 +
  update runtime README + 060-note. (this session)
- **020** — convert the **functions** emitter + **geometry** (CG headers kept;
  NS-geometry inline typedefs) to option (b), with the shared token→C-type helper,
  test rewrites, and a real `functions.ss` compile-verify. Runs before 060.

## Done when (node)

- ADR 0021 records the decision + rationale + the proven mechanism.
- The emitter emits **no** framework umbrella `#include` in any module; every
  emitted module compiles under the default gcc-15. (010 constants, 020
  functions+geometry.)
- 060 reads "default compiler, no special flags" (note in the 060 brief + README).
- Design spec §4 reconciled (it asserted `-x objective-c`/umbrella; now externs).
- `knowledge/targets/gerbil.md` (node 100) gets the toolchain entry.

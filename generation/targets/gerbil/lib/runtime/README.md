# Gerbil target runtime

The hand-written Gerbil runtime the generated bindings sit on. Part of the
`gerbil-bindings` package (`../gerbil.pkg`); generated framework modules land
beside this `runtime/` dir at `lib/<framework>/` and import it.

Built across node **050** (see `.grove/050-gerbil-runtime/`). This README is
seeded by leaf 010 (data plane) and expanded by leaf 040 (smoke-suite).

## Modules

| Module | Import path | Role |
|---|---|---|
| `ffi.ss`  | `:gerbil-bindings/runtime/ffi`  | C-safe libobjc seam: class/sel lookup, retain/release, autorelease pool, `string->nsstring`/`nsstring->string`, null + NSError-out-cell helpers. `:std/foreign` `define-c-lambda` crossings — **no separate dylib** (ADR-0017 §6). |
| `objc.ss` | `:gerbil-bindings/runtime/objc` | The module every generated binding imports. Owns the class-graph root `(defclass NSObject (ptr) …)`, the ObjC-name→constructor registry + class-aware `wrap`, `->ptr`, the lifetime `will` (ADR-0019), `with-autorelease-pool` / `define-entry-point`, the `nserror` record + `call-with-nserror-out` (ADR-0006). Re-exports `ffi.ss`. |

Leaves 020/030 add the ObjC native core (`make-objc-block`, `make-delegate`,
transparent subclass synthesis) — currently **stubs** in `objc.ss` that raise.

## Object model (ADR-0018/0020)

A returned `id` is `wrap`ped to its **exact bound Gerbil type**: `object_getClass`
→ the registry → the class's constructor, walking the ObjC superclass chain to the
nearest bound ancestor when the dynamic class is unbound (e.g. a string literal's
`__NSCFString` resolves to the bound `NSString`). A Gerbil class id (`NSString`) is
*syntax*, only valid in type positions; the registry stores the runtime descriptor
`NSString::t` + a positional constructor closure `(lambda (p) (make-NSString ptr: p))`.

## Lifetime (ADR-0019)

`wrap` registers a Gambit `will` that sends `objc_release` when the wrapper is
collected. Unlike chez's guardian (drained at every pool boundary), Gambit wills
**self-execute at GC** — `with-autorelease-pool` only manages the `+0` autorelease
pool, no finalization queue to poll. **Loops outside the run loop's entry-point
wrapping must `with-autorelease-pool` themselves** (the rule Cocoa imposes on ObjC
command-line tools).

## Building (the toolchain recipe — discovered at leaf 050/010)

Dev/measure on the **bottled** gerbil (`/opt/homebrew/Cellar/gerbil-scheme/0.18.2`);
its `gxc`/`gxi` are multicall symlinks in `bin/`, not on PATH. Needs the
FINDINGS-§0 symlink dance + `SDKROOT`.

```sh
export PATH="/opt/homebrew/Cellar/gerbil-scheme/0.18.2/bin:$PATH"
unset GERBIL_HOME
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
export GERBIL_LOADPATH="$PWD/generation/targets/gerbil/lib"   # package root

# 1. Compile the runtime modules to the static cache. -lobjc is REQUIRED here
#    (the module .o1 link resolves libobjc) AND produces the static .scm an
#    -exe link consumes.
gxc -O -ld-options "-lobjc" lib/runtime/ffi.ss lib/runtime/objc.ss

# 2. Build a program. Link -lobjc (runtime machinery) AND every framework whose
#    classes it touches (-framework Foundation gives NSString etc.; libobjc
#    alone gives objc_getClass but no classes → objc_getClass returns NULL).
gxc -exe -o prog -ld-options "-lobjc -framework Foundation" prog.ss
```

**Compiler note (load-bearing — see the 060/070 inbox note).** The bottle's gsc
uses **gcc-15** by default, which compiles the C-safe headers this runtime uses
(`<objc/runtime.h>`, `<objc/message.h>`) but CANNOT parse the Foundation/AppKit
umbrella headers the emitted `constants.ss`/`functions.ss` need. Those require
`gxc -gsc-option -cc clang` (+ an unresolved lightweight-generics flag). This
runtime is deliberately **C-safe / gcc-15-clean**; `-x objective-c` first becomes
mandatory at leaf 020 (`make-objc-block`, ObjC blocks).

Stale-lock hazard: a killed `gxc` leaves `~/.gerbil/lib/static/<mod>.o.lock`;
clear `~/.gerbil/lib/static/<mod>*` before retrying.

## Tests

`tests/run-smokes.sh` builds + runs the smoke programs. Leaf 010 ships
`smoke-data-plane.ss` (FFI round-trip, class-aware wrap, lifetime will,
`call-with-nserror-out` against a real failing Cocoa call) and
`smoke-dual-surface.ss` (proc core + `{}` MOP + `:std/generic`, all agreeing).
CLI smoke only — VM-verify of real apps is node 070/090.

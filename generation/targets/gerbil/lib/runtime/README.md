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
| `objc.ss` | `:gerbil-bindings/runtime/objc` | The module every generated binding imports. Owns the class-graph root `(defclass NSObject (ptr) …)`, the ObjC-name→constructor registry + class-aware `wrap`/`wrap-borrowed`, `->ptr`, the lifetime `will` (ADR-0019), `with-autorelease-pool` / `define-entry-point`, the `nserror` record + `call-with-nserror-out` (ADR-0006), and the two callback bridges `make-delegate` / `make-objc-block` (the token marshalling on top of `native-core`). Re-exports `ffi.ss`. |
| `native-core.ss` | `:gerbil-bindings/runtime/native-core` | The ObjC native core (ADR-0017 §6): the generic C trampolines (Gambit `c-define`, one per return shape) that let an ObjC IMP or block call BACK into a runtime-chosen Gerbil closure, the dispatch tables those consult, and the `objc_allocateClassPair`/`class_addMethod`/`objc_registerClassPair` plumbing (shared with leaf 030). C-safe (`<objc/runtime.h>`), gcc-15-clean. |
| `native_block.c` | — (linked `.o`) | The clang companion: the ObjC block literals (`^`) `make-objc-block` builds. The ONE thing gcc-15 cannot parse, so it is compiled separately by `clang -fblocks` and linked in. Self-contained (the dispatcher is passed in as an opaque fn-pointer), so it links on every link line. |

### Native callback bridges (leaf 050/020, ADR-0017 §6)

`make-delegate` and `make-objc-block` both sit on `native-core`: a generic C
trampoline re-enters Gerbil and looks up the registered closure (IMP closures
keyed by `(class-address . selector)`; block closures by an integer id). The
bridge layer in `objc.ss` owns the **token marshalling** — turning the emitter's
per-selector spec tokens into per-arg/per-return coercion.

- `(make-delegate specs)` — `specs` is a list of `(selector-string proc
  (param-token …) return-token)` 4-tuples (emit_protocol bakes them from the IR);
  synthesizes a fresh ObjC class, installs an IMP per selector dispatching into
  `proc`, returns a `+1`-retained instance. The caller must keep it reachable
  (`setDelegate:` does not retain — ADR-0019).
- `(make-objc-block proc (param-token …) return-token)` — wraps a Gerbil proc as
  an ObjC block; `#f` proc → the null block.

**Spec tokens** are the `GerbilFfiTypeMapper` vocabulary with ONE addition:
`object` marks a wrappable ObjC object, distinct from a raw `(pointer void)` (a
`BOOL*` out-param, a block, a `SEL`). The bridge `wrap`s an `object` but passes a
raw pointer straight through — `object_getClass` on a non-object pointer
crashes. Known gaps: the generic trampoline cannot deliver `float`/`double` (FP
registers) or by-value struct args (the bridge raises on those tokens); IMP arity
caps at 4 method args, blocks at 3. Main-thread model only (foreign-thread
activation is node 080).

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

# 1. Compile the clang companion (the ONE block-literal TU gcc-15 can't parse).
#    Self-contained, so it links onto every subsequent link line.
clang -fblocks -isysroot "$SDKROOT" -c lib/runtime/native_block.c -o native_block.o

# 2. Compile the runtime modules to the static cache. Order: objc.ss imports
#    native-core.ss imports ffi.ss. -lobjc is REQUIRED here AND the companion .o
#    (native-core's loadable object references its block-maker symbols).
gxc -O -ld-options "-lobjc native_block.o" \
    lib/runtime/ffi.ss lib/runtime/native-core.ss lib/runtime/objc.ss

# 3. Build a program. Link -lobjc + the companion .o + every framework whose
#    classes it touches (-framework Foundation gives NSString etc.; libobjc
#    alone gives objc_getClass but no classes → objc_getClass returns NULL).
gxc -exe -o prog -ld-options "-lobjc -framework Foundation native_block.o" prog.ss
```

**Compiler note (load-bearing — see the 060/070 inbox note).** The bottle's gsc
uses **gcc-15** by default, which compiles the C-safe headers this runtime uses
(`<objc/runtime.h>`, `<objc/message.h>`) but CANNOT parse the Foundation/AppKit
umbrella headers the emitted `constants.ss`/`functions.ss` need (resolved by
node 055). gcc-15 also cannot parse ObjC **block literals** (`^`); the native
core sidesteps both by staying C-safe and pushing the block literals into the
**clang-compiled companion** `native_block.c` (step 1). So `60`/`070`'s build
config must: compile `native_block.c` with `clang -fblocks` and add its `.o` to
every `-ld-options` link line (runtime modules + each app exe).

Stale-lock hazard: a killed `gxc` leaves `~/.gerbil/lib/static/<mod>.o.lock`;
clear `~/.gerbil/lib/static/<mod>*` before retrying.

## Tests

`tests/run-smokes.sh` builds + runs the smoke programs (it compiles the clang
companion and links it into every smoke). Leaf 010 ships `smoke-data-plane.ss`
(FFI round-trip, class-aware wrap, lifetime will, `call-with-nserror-out` against
a real failing Cocoa call) and `smoke-dual-surface.ss` (proc core + `{}` MOP +
`:std/generic`, all agreeing); leaf 020 adds `smoke-native-bridges.ss` (a
`make-delegate` instance receiving a real `-[NSTimer fire]` target/action, and a
`make-objc-block` invoked by `-[NSArray enumerateObjectsUsingBlock:]`, args
marshalled per token). CLI smoke only — VM-verify of real apps is node 070/090.

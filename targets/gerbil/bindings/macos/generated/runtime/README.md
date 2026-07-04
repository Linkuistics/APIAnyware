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
| `subclass.ss` | `:gerbil-bindings/runtime/subclass` | Transparent extensible subclassing (ADR-0020, leaf 050/030): the shadowing `defclass`/`defmethod`/`new` forms that synthesize a real ObjC subclass from an ObjC-backed superclass and route framework callbacks into Gerbil overrides. Imported ONLY by user app code that subclasses — NOT by generated bindings (which use the built-in `defclass`). Builds on `native-core`'s class-pair plumbing. |
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

### Transparent extensible subclassing (leaf 050/030, ADR-0020 — the centre)

*Deriving in Gerbil = deriving in ObjC.* `subclass.ss` re-exports `defclass` /
`defmethod` / `new` forms that **shadow** Gerbil's built-ins. A user app that wants
a custom view writes:

```scheme
(import :gerbil-bindings/appkit/nsview          ; the bound NSView
        :gerbil-bindings/runtime/subclass)      ; the shadowing forms

(defclass (CanvasView NSView) (strokes))        ; synthesizes a real ObjC subclass
(defmethod (CanvasView "drawRect:") (self)      ; installs an IMP → framework calls this
  (render (CanvasView-strokes self)))
(defmethod (CanvasView "isFlipped") (self) #t)

(def view (new CanvasView))                     ; alloc+init the synthesized class
```

How it works:

- **`defclass`** expands to the built-in `defclass` (so `CanvasView?`, the extra
  slots, the inherited `ptr` slot, and the keyword constructor all exist) PLUS a
  load-time `register-objc-subclass!` that — when the superclass is ObjC-backed —
  synthesizes and **registers** an `objc_allocateClassPair` subclass. The ObjC
  super name is `(symbol->string 'NSView)` (Gerbil class id == ObjC name). For a
  non-ObjC superclass it is a plain Gerbil class (clean fall-through; `new` errors,
  overrides are no-ops).
- **`defmethod (Class "objcSelector:")`** installs an IMP via the native core. The
  signature is **inferred from the ObjC superclass's `method_getTypeEncoding`** —
  the ABI-exact encoding is used verbatim for `class_addMethod`, and a parsed token
  list drives the trampoline's arg/return marshalling (objc.ss's shared vocabulary).
  Override formals are `(self . deliverable-args)`: struct/`float`/`double` args
  cannot ride the generic pointer-width trampoline, so they are omitted (e.g.
  `drawRect:`'s `CGRect` — the override is just `(self)`). Any other `defmethod`
  shape (`{sel Class}` built-in MOP) falls through to the built-in.
- **`new`** allocs+inits the synthesized class and records a back-reference
  ObjC-ptr → Gerbil-instance, so the override's `self` is the **typed** Gerbil
  instance (its slots, its methods), recovered when a framework callback fires.
- **`call-super` / `call-super-id`** give the common zero-arg `[super …]` chain.

**Registration ordering (the wrinkle ADR-0020 flagged):** the class pair is
synthesized+registered at `defclass`, and each separate top-level `defmethod`
override does a **post-registration `class_addMethod`** — legal on a registered
class (only `class_addIvar` is forbidden after registration, and we add no ivars:
the Gerbil instance holds the extra slots). The only constraint on user code: an
override `defmethod` must textually follow its `defclass`. This fits Gerbil's
separate-top-level-forms model with no deferred bookkeeping (racket's
`dynamic-class.rkt` batches add-then-register because its bridge is one call).

**Lifetime (main-thread, bounded-instance scope):** the back-reference table is
strong and the alloc `+1` is held implicitly, so a synthesized instance is
retained for the **process** — exactly racket's proven drawing-canvas model
(custom views/controllers are few and app-lifetime). A `dealloc`-driven reclaim is
the natural future refinement.

**Known gaps** (shared with the callback bridges): struct/`float`/`double` override
args are not delivered; struct/`float`/`double` override *returns* are unsupported
(raise at install). Argument-passing super-sends are deferred. Main-thread only
(foreign-thread activation is node 080).

## Object model (ADR-0020)

A returned `id` is `wrap`ped to its **exact bound Gerbil type**: `object_getClass`
→ the registry → the class's constructor, walking the ObjC superclass chain to the
nearest bound ancestor when the dynamic class is unbound (e.g. a string literal's
`__NSCFString` resolves to the bound `NSString`). A Gerbil class id (`NSString`) is
*syntax*, only valid in type positions; the registry stores the runtime descriptor
`NSString::t` + a positional constructor closure `(lambda (p) (make-NSString ptr: p))`.

## Dispatch surfaces & fast-path layering (ADR-0020)

Every bound instance method/property is offered through **two** call surfaces over
**one** proc core, so a caller picks idiom without paying twice:

```scheme
(nsstring-length s)   ; proc core      — the fast path, a plain define
{str-length s}        ; {} MOP surface — Gerbil's built-in object syntax
(str-length s)        ; :std/generic   — the generic-function surface
```

The three layers, fastest first:

1. **Proc core** — `(define (<class>-<sel> self …) (%msg-… (NSObject-ptr self) %sel-… …))`.
   A direct read of the receiver's `ptr` slot + the cached selector + the
   per-signature `%msg-…` FFI crossing. No dispatch. `(declare (inline))` lets the
   two surface forwarders inline straight onto it (**confirmed honoured by gsc** at
   leaf 050/040 — `smoke-dual-surface` compiles + runs green with the pragma; it does
   not fight the `begin-ffi`/`defclass` forms above it).
2. **`{}` MOP surface** — `(defmethod {<bare-sel> <Class>} (lambda (self …) (<class>-<sel> self …)))`,
   Gerbil's built-in method syntax, forwarding to the proc core.
3. **`:std/generic` surface** — `(g:defmethod (<bare-sel> (o <Class>) …) (<class>-<sel> o …))`,
   the generic-function surface, also forwarding to the proc core. `:std/generic` is
   imported **renamed** (`(rename-in :std/generic (defgeneric g:defgeneric) (defmethod
   g:defmethod))`) so its `defmethod` does not clash with the built-in `{}` `defmethod`;
   both surfaces share one identifier per selector.

Below the proc core sits the **raw `%msg-…`** per-signature crossing (emitted inline
per class module in the `begin-ffi` block, not runtime-owned) — the bare
`objc_msgSend` cast. Class methods + class properties stay **proc-only** (no instance
receiver to dispatch on). All three smokes' `smoke-dual-surface` asserts the three
forms agree over a real `-[NSString length]`.

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
# The gerbil-bindings package root after the §18 move (move-gerbil-material-k13):
cd targets/gerbil/bindings/macos/generated
export GERBIL_LOADPATH="$PWD"                                 # package root

# 1. Compile the clang companion (the ONE block-literal TU gcc-15 can't parse).
#    Self-contained, so it links onto every subsequent link line.
clang -fblocks -isysroot "$SDKROOT" -c runtime/native_block.c -o native_block.o

# 2. Compile the runtime modules to the static cache. Order: objc.ss imports
#    native-core.ss imports ffi.ss. -lobjc is REQUIRED here AND the companion .o
#    (native-core's loadable object references its block-maker symbols).
gxc -O -ld-options "-lobjc native_block.o" \
    runtime/ffi.ss runtime/native-core.ss runtime/objc.ss

# 3. Build a program. Link -lobjc + the companion .o + every framework whose
#    classes it touches (-framework Foundation gives NSString etc.; libobjc
#    alone gives objc_getClass but no classes → objc_getClass returns NULL).
gxc -exe -o prog -ld-options "-lobjc -framework Foundation native_block.o" prog.ss
```

**Compiler note (load-bearing — RESOLVED, ADR-0021).** The bottle's gsc uses
**gcc-15** by default, which compiles the C-safe headers this runtime uses
(`<objc/runtime.h>`, `<objc/message.h>`) but CANNOT parse the Foundation/AppKit
umbrella headers. **Node 055 resolved this: the emitter NEVER `#include`s an
umbrella header** — it synthesizes the C declaration (`extern`/prototype) for each
symbol its `constants.ss`/`functions.ss` crossings name, spelling ObjC pointer
types as `void *` (ADR-0021). So **every emitted module compiles under the default
gcc-15** — no `-cc clang`, no `-x objective-c`, no SDKROOT contract. gcc-15 also
cannot parse ObjC **block literals** (`^`); that ONE translation unit stays in the
**clang-compiled companion** `native_block.c` (step 1). So the ONLY non-default
compile in the whole build is that companion: `060`/`070`'s build config compiles
`native_block.c` with `clang -fblocks` and adds its `.o` to every `-ld-options`
link line (runtime modules + each app exe); everything else uses the default
compiler with no special flags.

Stale-lock hazard: a killed `gxc` leaves `~/.gerbil/lib/static/<mod>.o.lock`;
clear `~/.gerbil/lib/static/<mod>*` before retrying.

## Geometry structs by value (FINDINGS §4, ADR-0020)

Geometry types (`CGRect`/`NSRect`, `CGPoint`, `CGSize`, `CGVector`,
`CGAffineTransform`, `NSRange`, `NSEdgeInsets`, `NSDirectionalEdgeInsets`,
`NSAffineTransformStruct`) cross the FFI **by value**, not as pointers: the
emitter puts a `(c-define-type <Tok> (struct "<tag>"))` + a C-scope decl into each
class/function module's `begin-ffi` block
(`emit-gerbil/src/ffi_type_mapping.rs::geometry_decl` + `emit_geometry_decls`),
and the crossing's plain `objc_msgSend` cast returns the struct (arm64: ≤16 bytes
in registers, larger via the x8 hidden pointer — proven, FINDINGS §4). Every
token compiles under the **default gcc-15** (ADR-0021 — no `-x objective-c`):

- The **CoreGraphics** tokens' headers are **plain-C-safe** (gcc-15-clean), so the
  emitter `#include`s them (`GeometryCScope::Header`). They round-trip end-to-end
  through gsc — `tests/smoke-geometry.ss` (incl. a real `-[NSScreen frame]` struct
  return).
- The four **NS-prefixed / affine** tokens' headers are **not** C-safe (they pull
  in ObjC), so the emitter declares an **inline plain-C tagged struct** instead
  (`GeometryCScope::InlineStruct`; `CGFloat`→`double`, `NSUInteger`→`unsigned
  long`), keeping the `(c-define-type Tok (struct "tag"))` crossing. The SDK-exact
  field layouts (055/020) round-trip by value through the same default-compiler
  gsc path in `tests/smoke-geometry.ss`. `NSAffineTransformStruct`'s SDK typedef
  is anonymous-tagged, so the inline form gives it the real
  `NSAffineTransformStruct` tag the `c-define-type` names;
  `NSDirectionalEdgeInsets` lives in AppKit (compositional-layout), not
  Foundation/NSGeometry — the source of its inline field list.

## Tests

`tests/run-smokes.sh` builds + runs the smoke programs (it compiles the clang
companion and links it into every smoke). The suite, consolidated at leaf 050/040:

- `smoke-data-plane.ss` (leaf 010) — FFI round-trip, class-aware `wrap` into the
  exact bound type, the lifetime will surviving a GC sweep, and
  `call-with-nserror-out` `(values result error)` against a real failing Cocoa call.
- `smoke-dual-surface.ss` (leaf 010) — proc core + `{}` MOP + `:std/generic`, all
  three agreeing over a real `-[NSString length]` (also the `(declare (inline))`
  confirmation).
- `smoke-native-bridges.ss` (leaf 020) — a `make-delegate` instance receiving a real
  `-[NSTimer fire]` target/action, and a `make-objc-block` invoked by
  `-[NSArray enumerateObjectsUsingBlock:]`, args marshalled per FFI token.
- `smoke-subclass.ss` (leaf 030) — a synthesized `NSView` subclass whose
  `drawRect:`/`isFlipped` overrides receive ObjC-runtime dispatch with the correct
  typed `self`, installed in an `NSWindow`.
- `smoke-geometry.ss` (leaf 040) — by-value round-trip of the CoreGraphics geometry
  structs (incl. a real `-[NSScreen frame]` CGRect return), see above.
- `smoke-swift-trampoline.ss` (leaf 070, ADR-0029) — **the permanent Swift-native
  trampoline regression guard.** Resolves the §6a exemplars through
  `libAPIAnywareGerbil`'s `@_cdecl` entries via `define-c-lambda`:
  `CreateML.timestampSeed()` returns a time-derived `Int`, and reading
  `CreateML.MLCreateErrorDomain` exercises the **constant-trampoline round-trip at
  module init** (`= "com.apple.CreateML"`, Scheme-side coerced per ADR-0015). It has
  its **own** runner, `run-swift-trampoline-smoke.sh`, because it links the extra
  `-lAPIAnywareGerbil` line the pure-ObjC smokes do not; `run-smokes.sh` chains to it
  (skipping with a build instruction when the generated bindings / dylib are absent).
  This is the gerbil analog of racket's `RUNTIME_LOAD_TEST` / chez's smoke
  registration — the require-shape + constant round-trip are now a standing guard,
  not a one-time check.

CLI smoke only — VM-verify of real apps is node 070/030.

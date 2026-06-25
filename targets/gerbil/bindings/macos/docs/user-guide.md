# gerbil macOS binding — user guide (§22)

The entry point for **using** the generated gerbil binding for macOS. Gerbil ships no separate
developer guide, so this page is the primary walkthrough: what you are using, how to import it, the
three dispatch surfaces, how to subclass, how threading and errors behave, and how to ship a `.app`.
The deepest mechanism detail (the manifest object model, the dual-surface fast-path layering, the
lifetime will, the toolchain bottle) is in [`../../../docs/reference.md`](../../../docs/reference.md);
the target model behind it is mapped in [`../../../docs/overview.md`](../../../docs/overview.md).

## What you are using

A class-and-method binding over directly-dispatched ObjC, with a **real Gerbil class graph** behind
it. Unlike racket and chez — which expose flat free procedures over one opaque object — gerbil
reifies the ObjC hierarchy as Gerbil `defclass`es (`NSButton : NSControl : NSView : NSResponder :
NSObject`, ADR-0020), and offers **three dispatch surfaces** over each bound method (below). The
binding is **idiomatic Gerbil**: `defclass`, the `{}` MOP, `:std/generic`, `define-c-lambda`,
`unwind-protect`, and `(values …)` — never portable-R6RS or racket-shaped code.

## The binding layout (`bindings/macos/`)

Gerbil's layout is **racket-like, not chez-like**: there is a separate `generated/` directory (chez
interleaves emitted source into one `apianyware/` namespace tree; gerbil does not). The `generated/`
directory **is the `gerbil-bindings` package root** (`generated/gerbil.pkg` declares
`(package: gerbil-bindings)`), so an import `:gerbil-bindings/appkit/nswindow` resolves to
`generated/appkit/nswindow.ss`.

| dir | what it holds |
|---|---|
| `generated/` | the **`gerbil-bindings` package root** (`gerbil.pkg`) — the import namespace |
| `generated/runtime/` | the hand-written runtime modules (`ffi`, `objc`, `native-core`, `subclass`, `cocoa`, `native_block.c`, the Swift trampolines) — tracked |
| `generated/<framework>/<class>.ss` | emitted per-class binding source (gitignored — produced by `apianyware-generate`, absent in a clean checkout) |
| `generated/<framework>/enums.ss` | emitted per-framework enum / option-set constants |
| `reports/` | screenshots / VM-verify artifacts (one dir per sample app) |

## Importing bindings — the `:gerbil-bindings/…` model

You `import` module paths and point Gerbil's load path at the package root with `GERBIL_LOADPATH`.
The common case is the runtime plus the per-class modules and enum constants you touch
(from [`../../../app-implementations/macos/hello-window/`](../../../app-implementations/macos/hello-window/)):

```scheme
(import :gerbil-bindings/runtime/objc          ; the module every binding sits on
        :gerbil-bindings/runtime/cocoa         ; geometry ctors + standard app menu
        :gerbil-bindings/appkit/nsapplication
        :gerbil-bindings/appkit/nswindow
        :gerbil-bindings/appkit/nsview
        :gerbil-bindings/appkit/nscontrol
        :gerbil-bindings/appkit/nstextfield
        :gerbil-bindings/appkit/enums)         ; the PascalCase constants
```

Set the load path to the package root before building:

```
cd targets/gerbil/bindings/macos/generated
export GERBIL_LOADPATH="$PWD"      # the gerbil-bindings package root
```

Import the **declaring** class's module for inherited methods: an `NSTextField` label's
`set-frame!` lives in `nsview`, its `set-string-value!` in `nscontrol` (see *the three surfaces*
below). The build/toolchain env (the bottle PATH, `SDKROOT`, the clang companion) is in *Packaging*.

## Writing against the binding

A first program is a script that opens a window — the shape every sample app follows:

```scheme
(import :gerbil-bindings/runtime/objc
        :gerbil-bindings/runtime/cocoa
        :gerbil-bindings/appkit/nsapplication
        :gerbil-bindings/appkit/nswindow
        :gerbil-bindings/appkit/enums)
(export main)

(define-entry-point (main)
  (let (app (nsapplication-shared-application))
    (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
    (install-standard-app-menu! app "Hello Window")
    (let (window (make-nswindow-init-with-content-rect-style-mask-backing-defer
                   (make-rect 0. 0. 400. 200.)
                   (bitwise-ior NSWindowStyleMaskTitled NSWindowStyleMaskClosable)
                   NSBackingStoreBuffered #f))
      (nswindow-set-title! window (string->nsstring "Hello from Gerbil"))
      (nswindow-center! window)
      (nswindow-make-key-and-order-front window #f)
      (nsapplication-activate-ignoring-other-apps app #t)
      (nsapplication-run app))))
(main)
```

Note the naming, all from the emitter (full table in
[`platform-docs-mapping.md`](platform-docs-mapping.md)): class methods are class-scoped procedures
(`nsapplication-shared-application`); setters take `!`; a designated initializer is a
`make-<class>-<init-selector>` constructor; constants keep their PascalCase ObjC names; option sets
are `(bitwise-ior …)` of flag constants; geometry structs are `make-rect` / `make-point` (note —
**not** `make-nsrect`) with **`double` float literals** (`0.`); strings convert **explicitly** with
`string->nsstring` / `nsstring->string`.

## The three dispatch surfaces

Every bound **instance** method is callable three ways over **one proc core** (ADR-0020; the
authoritative detail + the benchmarks are in [`../../../docs/reference.md`](../../../docs/reference.md)
"Dispatch surfaces & fast-path layering"):

1. **Proc core** `(<class>-<selector> obj …)` — the **fast path** (a plain `define`, `(declare
   (inline))`), and the form every sample app uses (`(nswindow-set-title! window …)`).
2. **`{}` MOP surface** `{<selector> obj …}` — Gerbil's built-in object syntax, forwarding to the
   proc core.
3. **`:std/generic` surface** `(<selector> obj …)` — the generic-function surface, also forwarding
   to the proc core.

Generics are the natural *consumption* surface, OO the natural *extension* surface, and hot loops
drop to the proc core. **Class** methods + class properties stay **proc-only** (no instance receiver
to dispatch on).

## Subclassing — *deriving in Gerbil is deriving in ObjC*

To receive framework callbacks (a custom `NSView`'s `drawRect:`, a custom controller), import the
**shadowing** subclass forms and derive (ADR-0020):

```scheme
(import :gerbil-bindings/appkit/nsview
        :gerbil-bindings/runtime/subclass)      ; the shadowing defclass/defmethod/new

(defclass (CanvasView NSView) (strokes))        ; synthesizes a real ObjC subclass
(defmethod (CanvasView "drawRect:") (self)      ; installs an IMP → framework calls this
  (render (CanvasView-strokes self)))
(def view (new CanvasView))                     ; alloc+init the synthesized class
```

`defclass` synthesizes and registers an `objc_allocateClassPair` subclass; each `defmethod` installs
an IMP whose signature is inferred from the superclass's `method_getTypeEncoding`; `new` records the
ObjC-ptr → Gerbil-instance back-reference so the override's `self` is the **typed** Gerbil instance.
Two constraints: an override `defmethod` must textually follow its `defclass`, and
`struct`/`float`/`double` override args/returns cannot ride the generic trampoline (so `drawRect:`'s
`CGRect` is omitted — the override is just `(self)`). The generated bindings use the built-in
`defclass`; only app code that subclasses imports `runtime/subclass`.

## Threading — the main-thread *bounce*

Gerbil's behaviour is the **inverse of chez's**: foreign-thread callbacks and "main-thread-only"
calls **bounce** to the main thread (ADR-0022) — gerbil does **not** thread-activate the way chez
does. Main-thread dispatch is an exact mechanism (`dispatch_sync` value-returning / `dispatch_async`
void), and the `AsyncBridge` fires Swift-native completion callbacks on the main thread for you. The
binding's callback bridges (`make-delegate` / `make-objc-block`) are main-thread-model; see
[`../../../docs/ffi-model.md`](../../../docs/ffi-model.md) and reference.

## Errors

`NSError**` out-parameters surface as **multiple values** — `(let-values (((result err) …)) …)`
(ADR-0006) — via `call-with-nserror-out`; the wrapper hides the raw out-param pointer. Thrown
`NSException`s / Swift errors surface as **`:std/error` objects**, catchable with `try` /
`with-catch`. See [`platform-docs-mapping.md`](platform-docs-mapping.md) for the per-shape mapping.

## Packaging — the self-contained static executable

Gerbil ships as a **single self-contained static executable** (ADR-0021), *not* chez's open-world
dynamic bundle: `gxc -exe` links `libgambit.a`, so the runtime is *in* the binary — no separate
Gerbil/Gambit install on the target machine. That executable is wrapped into a `.app` (vendored libs
+ `install_name_tool` relocation) and **VM-verified** — all seven GUI sample apps. The build uses
the **BOTTLE toolchain** (ADR-0021) with sharded, parallel `generics.ss` compilation (ADR-0023, cold
build ~5 h → ~8.4 min). The bottle env:

```
export PATH="/opt/homebrew/Cellar/gerbil-scheme/0.18.2/bin:$PATH"
unset GERBIL_HOME
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
```

Two build-host gotchas worth knowing up front:

- The ADR-0021 toolchain **hardcodes gcc-15** for `gxc`; a host carrying only gcc-16 needs a
  `/tmp/aw-gcc15-shim` symlink, or `gxc` fails with `gcc-15: command not found`.
- The **one** translation unit gcc-15 cannot parse is the block-literal companion
  `runtime/native_block.c` — it is compiled by `clang -fblocks` and its `.o` linked onto every
  link line. Everything else compiles under the default gcc-15 (the emitter synthesizes C
  declarations rather than `#include`-ing umbrella headers — ADR-0021).

## Where to go next

- [`platform-docs-mapping.md`](platform-docs-mapping.md) — translate an Apple API-doc page into the
  gerbil names.
- [`api-coverage.md`](api-coverage.md) — what is and isn't covered, and how faithfully.
- [`unsafe-escape-hatches.md`](unsafe-escape-hatches.md) — reaching APIs the binding doesn't model.
- [`../../../docs/reference.md`](../../../docs/reference.md) — the deep target reference (object
  model, dual-surface dispatch, lifetime, toolchain, gotchas).

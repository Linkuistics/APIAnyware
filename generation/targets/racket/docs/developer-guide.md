# racket Developer Guide

A practical guide to writing Racket applications against the macOS
system APIs via the generated `racket` bindings. Start here if you
have never used the target; skim the table of contents if you are
returning for a specific topic.

- [What "OO" means (and does not mean) here](#what-oo-means-and-does-not-mean-here)
- [First program](#first-program)
- [Requiring generated bindings](#requiring-generated-bindings)
- [Calling instance and class methods](#calling-instance-and-class-methods)
- [Creating objects](#creating-objects)
- [Dynamic subclassing with `define-objc-subclass`](#dynamic-subclassing-with-define-objc-subclass)
- [Delegates and protocols](#delegates-and-protocols)
- [Completion blocks](#completion-blocks)
- [Notifications](#notifications)
- [Threading and callback safety](#threading-and-callback-safety)
- [Type coercion and the FFI boundary](#type-coercion-and-the-ffi-boundary)
- [Packaging sample apps](#packaging-sample-apps)
- [Testing apps in a VM](#testing-apps-in-a-vm)
- [AppKit widget quirks](#appkit-widget-quirks)
- [Further reading](#further-reading)


## What "OO" means (and does not mean) here

The target name `racket` is a labelling convention, not a technical
description of the emitted code. Generated bindings use
`#lang racket/base` and do **not** use Racket's class system
(`racket/class`, `class*`, `define/public`, `send`, `interface`, `mixin`).
Every class is emitted as a flat module of free functions named
`<class>-<method>` operating on an opaque `objc-object?` struct.

The difference from a hypothetical functional Racket target would be
conventional: racket emits `(nsview-set-frame! view frame)` — method
receiver is the first argument — whereas a functional target might emit
`(ns-view-set-frame! frame view)` or reorder by currying. Neither is
`racket/class`.

The one place the target does resemble traditional OO is **dynamic
subclassing** — defining a new ObjC subclass in Racket with method
overrides. That single use case is served by `define-objc-subclass`
(see [below](#dynamic-subclassing-with-define-objc-subclass)). Everything
else is flat message-passing over opaque handles.

If a familiar Racket idiom surprises you, the friction is almost always
**FFI-shaped**, not OO-shaped. This guide focuses on the FFI-shaped
parts.


## First program

A minimal window that runs until you quit:

```racket
#lang racket/base
(require "../../generated/appkit/nsapplication.rkt"
         "../../generated/appkit/nswindow.rkt"
         "../../runtime/type-mapping.rkt"
         "../../runtime/coerce.rkt"
         "../../runtime/app-menu.rkt")

;; NSWindowStyleMask bits are not yet extracted — define locally.
(define NSWindowStyleMaskTitled       1)
(define NSWindowStyleMaskClosable     2)
(define NSWindowStyleMaskResizable    8)
(define NSBackingStoreBuffered        2)

(define app (nsapplication-shared-application))
(nsapplication-set-activation-policy! app 0)  ; regular activation
(install-standard-app-menu! app "Hello")

(define win
  (make-nswindow-init-with-content-rect-style-mask-backing-defer
    (make-nsrect 0 0 480 320)
    (bitwise-ior NSWindowStyleMaskTitled
                 NSWindowStyleMaskClosable
                 NSWindowStyleMaskResizable)
    NSBackingStoreBuffered
    #f))
(nswindow-set-title! win "Hello")
(nswindow-make-key-and-order-front! win #f)
(nsapplication-run app)
```

Points worth calling out:

- `make-nswindow-init-with-content-rect-style-mask-backing-defer` is a
  generated constructor. The long name preserves the full ObjC selector.
- `make-nsrect` (lowercase) is a runtime convenience wrapping four
  scalars. The underlying `make-NSRect` (from `define-cstruct`) takes
  an NSPoint and an NSSize — use it when you already have those
  structs in hand.
- `install-standard-app-menu!` lives in the runtime, not the SDK. The
  full "Quit", "Hide", etc. menu has to be built manually — Cocoa does
  not install it automatically.
- The `apps/<name>/<name>.rkt` path is `../../runtime/` and
  `../../generated/` from the script. Apps carry these relative
  paths indefinitely — the emitter never touches them.


## Requiring generated bindings

Each framework is a per-class file under
`generated/<framework>/<class>.rkt`. Import the class files you
actually need:

```racket
(require "../../generated/appkit/nsbutton.rkt"
         "../../generated/appkit/nsstackview.rkt"
         "../../generated/foundation/nsstring.rkt")
```

For **functions** and **constants** at the framework level — the output
of `generated/<framework>/functions.rkt` and `constants.rkt` — prefer
`only-in` so the consumer declares exactly which names it uses. This
also prevents the file's private `racket/contract` re-exports from
leaking through into your module:

```racket
(require (only-in "../../generated/coregraphics/functions.rkt"
                  CGContextMoveToPoint
                  CGContextAddLineToPoint
                  CGContextStrokePath)
         (only-in "../../generated/corefoundation/functions.rkt"
                  CFRelease)
         (only-in "../../generated/corefoundation/constants.rkt"
                  kCFRunLoopCommonModes))
```

`only-in` is a visibility filter — it still fully expands the imported
module. If that module has a module-level error, even a narrow
`only-in` will fail. In that (rare) case, the escape hatch is to drop
to raw `tell` or `objc_msgSend` without touching the broken module.


## Calling instance and class methods

Generated names follow the ObjC selector with `:` replaced by `-` and
kebab-cased:

| ObjC                                 | Racket                            |
|--------------------------------------|-----------------------------------|
| `[view setFrame:r]`                  | `(nsview-set-frame! view r)`      |
| `[NSColor redColor]` (class method)  | `(nscolor-red-color)`             |
| `view.alphaValue = 0.5`              | `(nsview-set-alpha-value! view 0.5)` |
| `view.alphaValue`                    | `(nsview-alpha-value view)`       |

**Setters end in `!`.** Property getters and class methods do not.

**Class/instance disambiguation:** where a class and an instance share
a selector name (e.g. `NSEvent +modifierFlags` and `-modifierFlags`), the
class method gets a `-class` suffix: `nsevent-modifier-flags-class`
vs `nsevent-modifier-flags`.

**Contracts.** Every exported function is wrapped in
`provide/contract`. Self is contracted `objc-object?`; object parameters
accept `(or/c string? objc-object? #f)`; SEL parameters accept
`string?` (the wrapper calls `sel_registerName` internally). Raw
cpointers are **rejected** — see [Type coercion](#type-coercion-and-the-ffi-boundary).


## Creating objects

### Default constructor: `make-<class>`

For roughly 73% of all emitted classes, the emitter synthesizes a
default constructor:

```racket
(define (make-<class>)
  (wrap-objc-object (tell (tell <Class> alloc) init) #:retained #t))
```

Examples that have this: `make-nsalert`, `make-nscolorpanel`,
`make-nsstackview`, `make-nssavepanel`, `make-nsopenpanel`,
`make-nsfilemanager`. Call it with zero arguments.

This is suppressed for any class that has at least one explicit init
method — `NSWindow`, for instance, has only the long
`make-nswindow-init-with-content-rect-style-mask-backing-defer`
constructor, no bare `make-nswindow`. The synthesis trigger lives in
`has_explicit_constructor` in `emit_class.rs`.

### Explicit init methods

Use the generated init function directly:

```racket
(define win
  (make-nswindow-init-with-content-rect-style-mask-backing-defer
    (make-NSRect 0 0 480 320) style-mask NSBackingStoreBuffered #f))
```

### Escape hatch: `objc-interop.rkt`

For the small set of NSCoder-style flows that need explicit `alloc` →
custom init selector separation, `runtime/objc-interop.rkt` re-exports
the `ffi/unsafe/objc` surface (`tell`, `import-class`, `sel_registerName`,
etc.). Prefer the generated constructors when one exists; reach for
`objc-interop.rkt` only when you genuinely need manual selector plumbing.


## Dynamic subclassing with `define-objc-subclass`

When you need to override methods on an ObjC class — drawing into an
NSView, handling mouse events, responding to delegates you can't express
as handler callbacks — use `define-objc-subclass` from
`runtime/objc-subclass.rkt`:

```racket
(require "../../runtime/objc-subclass.rkt")

(define-objc-subclass DrawingCanvasView NSView
  [(drawRect:)
   (lambda (self rect)
     (define gc (nsgraphicscontext-current-context))
     (when gc
       (define ctx (nsgraphicscontext-cg-context gc))
       (render-strokes ctx strokes)))]
  [(mouseDown:)
   (lambda (self event)
     (define pt (event->view-point self event))
     (start-stroke! (NSPoint-x pt) (NSPoint-y pt))
     (nsview-set-needs-display! (borrow-objc-object self) #t))]
  ...)
```

What it does for you:

- **Type encoding inference.** The ObjC type-encoding string for each
  overridden method is pulled from the superclass's own method table
  via `(method-type-encoding (get-instance-method NSView sel))`.
  Hardcoded encoding strings drift silently if Apple changes the ABI;
  pulling from the live superclass method is always correct.
- **`(self SEL)` prefix.** Auto-inserted into the `_cprocedure`
  signature; your lambda receives just the real args.
- **IMP GC pinning.** Each method's `function-ptr` is bound at module
  level to prevent GC — a moved pointer would crash Cocoa at callback
  time.
- **Idempotent registration.** If the module is re-required, the
  existing registered class is returned.

For unsupported arg/return types (packed struct literals, unions, bit
fields), pass `#:arg-types` and `#:ret-type` explicitly. See
`generation/targets/racket/docs/design/2026-04-19-racket-oo-class-system-analysis.md` for the
design rationale.

Constructor synthesis (`make-<class>`) is deliberately absent from
`define-objc-subclass` — superclass init signatures vary per parent.
Call `(tell (tell DrawingCanvasView alloc) init-with-frame: frame)`
or the equivalent manual form.

### Raw API: `make-dynamic-subclass`

`runtime/dynamic-class.rkt` is the lower-level primitive. Use it only
if `define-objc-subclass` can't express what you need — its API is
`(allocate-subclass name super)`, `(add-method! cls sel imp enc)`,
`(register-subclass! cls)`.


## Delegates and protocols

Generated protocol files (`generated/<fw>/protocols/<proto>.rkt`)
export two bindings: `make-<proto>` (a delegate factory) and
`<proto>-selectors` (the selector list).

### Basic pattern

```racket
(require "../../generated/appkit/protocols/nstextfielddelegate.rkt"
         "../../runtime/delegate.rkt")

(define delegate
  (make-nstextfielddelegate
    "controlTextDidChange:"
    (lambda (notification)
      (displayln "text changed"))))
(nstextfield-set-delegate! field delegate)
```

Handler lambdas receive the real method args — **no `self` prefix**.
The protocol file's `make-<proto>` accepts pairs of selector strings
and Racket procedures (`#:rest (listof (or/c string? procedure?))`).

(This is different from `define-objc-subclass`, whose IMP lambdas
*do* receive `self` as the first arg. Delegates and dynamic
subclasses are two different mechanisms.)

### `#:param-types` and `#:return-types`

ObjC delegate trampolines pass **raw cpointers** for `id`-typed args.
If your handler then calls generated class wrappers — which require
`objc-object?` self — you'll hit a contract violation before you can
blink. The protocol emitter passes `#:param-types` on your behalf, so
NSNotification, NSTableColumn, etc. arrive already wrapped.

If you use `make-delegate` directly (not the per-protocol factory),
you need to pass this yourself:

```racket
(define handler
  (make-delegate
    #:return-types (hash "pageChanged:" 'void)
    #:param-types  (hash "pageChanged:" '(object))
    "pageChanged:"
    (lambda (notification) (refresh-ui!))))
```

Supported `#:param-types` arg-type symbols: `'object`, `'long`,
`'int`, `'bool`, `'pointer`. `'long` is the correct choice for any
NSInteger-returning or NSInteger-taking method on 64-bit Apple
platforms (clang encodes `long` as `q`).

`#:return-types` uses return-kind symbols — `'void`, `'bool`, `'id`,
`'int`, `'long`. Defaults are selector-name based: selectors starting
with `should`/`can`/`validate` return `bool`; those starting with
`willReturn`/`willUse` return `id`.

### The raw-cpointer wrap trap

Even with `#:param-types`, some delegate methods have args the protocol
file doesn't know about (e.g. user-info dictionary keys, ancillary
objects passed through `tell` from inside the handler). Whenever you
receive a raw cpointer and need to cross a class-wrapper boundary with
it, wrap with `(borrow-objc-object ptr)`:

```racket
(lambda (self notification)
  (define user-info (nsnotification-user-info notification))
  (define key (borrow-objc-object kPDFViewPageChangedNotification)))
```

`borrow-objc-object` constructs an `objc-object?` struct with no
retain/release — correct for transient callback args and for dylib-
lifetime constants.

### Delegate lifetime

**Keep the delegate in a module-level variable.** Cocoa holds delegates
and observers weakly — a `(define d (make-...))` inside a `let` lexical
scope goes out of scope, gets GC'd, and the delegate silently stops
firing. The same applies to `make-objc-block` and any `_cprocedure`.
Module-level is the reliable anchor.

### `make-delegate` vs `make-<proto>`

`make-delegate` in `runtime/delegate.rkt` returns a
`borrow-objc-object` — it satisfies `objc-object?` at class wrapper
boundaries (e.g. `nsbutton-set-target!`). Protocol factories layer on
top with the right `#:param-types` wired in.


## Completion blocks

For modal panels and async APIs that take a completion handler, use
`make-objc-block`:

```racket
(define completion
  (make-objc-block
    '(Int64 -> Void)
    (lambda (response)
      (cond
        [(= response 1) (save-to-url (nssavepanel-url panel))]
        [else (displayln "cancelled")]))))
(nssavepanel-begin-sheet-modal-for-window-completion-handler!
  panel window completion)
```

Known completion-block signatures in the sample apps:

| API                                                | Signature           |
|----------------------------------------------------|---------------------|
| `NSSavePanel/NSOpenPanel beginSheetModal...`       | `(Int64 -> Void)`   |

The `Int64` arg is `NSModalResponseOK` (1) or `NSModalResponseCancel`
(0). The pattern generalises to any `NSModalResponse` completion.

Block lifetime is managed automatically by `make-objc-block`, but the
value it returns must still be kept alive — assign it to a module-level
variable if the call is not synchronous.


## Notifications

NSNotificationCenter observers follow a three-part pattern:

```racket
;; 1. Wrap the notification-name constant — it is a raw _id-typed cpointer.
(define NAME (borrow-objc-object PDFViewPageChangedNotification))

;; 2. Build the observer (keep at module level).
(define observer
  (make-delegate
    #:return-types (hash "pageChanged:" 'void)
    #:param-types  (hash "pageChanged:" '(object))
    "pageChanged:"
    (lambda (notification) (refresh-page-label))))

;; 3. Register.
(define nc (nsnotificationcenter-default-center))
(nsnotificationcenter-add-observer-selector-name-object!
  nc observer "pageChanged:" NAME pdfview)
```

The three load-bearing details:

- **Constant wrapping.** Notification-name constants (e.g.
  `PDFViewPageChangedNotification`) are emitted as
  `(get-ffi-obj ... _id)` — a raw cpointer. The `name` contract
  requires `objc-object?` or `string?` or `#f`; raw cpointers are
  rejected. `borrow-objc-object` provides the wrap with no
  retain/release — the constant's lifetime is tied to the dylib.
- **`#:param-types`.** The notification arrives as `objc-object?`
  when the selector maps to `'(object)`.
- **Module-level observer.** Cocoa holds observers weakly.


## Threading and callback safety

This section is the most subtle part of the target. Read it once before
writing any non-trivial app.

### The premise: Cocoa blocks Racket's scheduler

When an app calls `(nsapplication-run app)`, the Cocoa run loop takes
over the place's main thread. **All Racket green-thread primitives
stop working.** `thread`, `sleep`, `sync`, `sync/timeout`, `thread-wait`,
`semaphore-wait` — all silently non-functional. The scheduler never
advances because no Racket code is running: Cocoa is.

This is not a bug in Racket; it's the natural consequence of cooperative
scheduling plus a non-returning C entry point. Every workaround in this
section is about living with it.

### `call-on-main-thread` and friends

`runtime/main-thread.rkt` exports three primitives, all built on Grand
Central Dispatch:

- `(on-main-thread?)` — returns `#t` if the caller is on the main OS
  thread.
- `(call-on-main-thread thunk)` — if already on the main thread,
  invokes synchronously; otherwise dispatches via `dispatch_async_f`.
- `(call-on-main-thread-after seconds thunk)` — dispatches after a
  delay via `dispatch_after_f`.

Use these instead of `thread` for deferred UI work or animation-ish
patterns:

```racket
(call-on-main-thread-after 0.5
  (lambda () (nsbutton-set-enabled! save-button #t)))
```

FFI details worth knowing:

- `_dispatch_main_q` is a global struct, not a pointer. Accessed via
  `dlsym` directly.
- The module-level `function-ptr` bindings in `main-thread.rkt`
  prevent GC of the C callback pointer.

### The SIGILL trap: `_cprocedure` from foreign threads

When a Racket `_cprocedure` callback is invoked from an **OS thread
not registered with the Racket VM** (e.g. a libdispatch worker queue,
a GCD background queue, a pthread spawned by a third-party dylib), the
Racket CS VM SIGILLs immediately — exit code 132.

**Safe:** callbacks installed on the main run loop
(`CFRunLoopGetMain`), CGEvent taps (which fire on the main OS thread),
anything visible to you under `nsapplication-run`.

**Not safe:** any API that routes its callback through a background
GCD queue, libdispatch worker, or detached pthread. The emitter flags
this at emission time: any function with a `FunctionPointer` or `Block`
parameter gets a 3-line `; WARNING:` comment before the `define`.
Read it.

### Why `#:async-apply` doesn't save you

`#:async-apply` on `_cprocedure` routes foreign-thread invocations to
the Racket scheduler's async-apply queue — which is drained on the
main Racket thread. Under `nsapplication-run`, the main Racket thread
is stuck inside Cocoa's run loop and never drains the queue. Result:
deadlock instead of SIGILL.

Either way, the only safe callbacks are those that fire on the main
thread. Before installing a callback on any GCD or libdispatch API,
verify — from the API's documentation — that it fires on the main
queue.

### Off-main-thread I/O: `dynamic-place`

`ffi/unsafe/os-thread` (`call-in-os-thread`) works for pure Racket
compute (fuzzy matching, serialization, file I/O) but **segfaults** on
anything that touches the scheduler's I/O event pump — `tcp-connect`,
`subprocess`, `system`, `net/url` (transitively). The rules are
subtle and the failure mode is hard violence.

For background I/O that needs the full scheduler, use `dynamic-place`.
Each place is a separate Racket VM on its own OS thread with its own
scheduler; `tcp-connect` and friends work correctly inside.

### The place-backed async facade pattern

The canonical pattern for doing network/subprocess/I/O work alongside
a Cocoa app:

```
main thread:  (nsapplication-run app)
              │
              ├── timer via call-on-main-thread-after polls the channel:
              │     (place-channel-try-get chan) or (sync/timeout 0 chan)
              │
              └── work place (separate VM):
                    reads commands from chan
                    performs I/O synchronously within the place
                    writes results to chan
```

Place-channel semantics:

- `place-channel-put` — fully buffered; the sender never blocks.
- `place-channel-get` — blocks. **Never call on the main thread under
  `nsapplication-run`** — it deadlocks identically to
  `#:async-apply`.
- `sync/timeout 0 chan` — non-blocking try-receive; safe to poll from
  a main-thread timer.

None of the current sample apps exercise this pattern; it's documented
here for when the need arises. Start with a `dispatch_async_f`-based
solution if the work can finish in a few milliseconds — escalate to a
place only when the blocking call is genuinely long-running.

### Tests that enter the Cocoa loop

Tests that call `nsapplication-run` need a structured exit or they hang
the test runner:

```racket
(define delegate
  (make-nsapplicationdelegate
    "applicationDidFinishLaunching:"
    (lambda (notification)
      ;; Safety net: fires even if assertions raise and get caught.
      (call-on-main-thread-after 5.0
        (lambda () (eprintf "safety net: timed out\n") (exit 1)))
      (with-handlers ([exn:fail? (lambda (e) (eprintf "FAIL: ~a\n" (exn-message e)))])
        (run-assertions!))
      ;; Normal-path exit.
      (call-on-main-thread-after 0.5 (lambda () (exit 0))))))
(nsapplication-set-delegate! app delegate)
(nsapplication-run app)
```

Outcomes:
- Assertions pass → `(exit 0)` → `[OK]`.
- Assertion raises (caught) → safety net fires at 5.0s → `(exit 1)`
  → `[FAIL]`.
- Genuine hang → outer `timeout -k 1 30` → `[TIMEOUT]`.

The safety-net timeout **must** be longer than the normal-path delay.


## Type coercion and the FFI boundary

Every generated function is wrapped in `provide/contract`. Three
contract families, all defined in `generation/crates/emit-racket`:

- **Primitives.** `real?`, `exact-integer?`, `boolean?`, etc.
  `_string` returns map to `(or/c string? #f)` (NULL becomes `#f`).
- **Object params** (`Id`, `Class`, `Instancetype`):
  `(or/c string? objc-object? #f)`. `cpointer?` is **excluded** — wrap
  raw pointers with `borrow-objc-object`.
- **Object returns.** For `TypeRefKind::Class { name }`, the contract
  is `(or/c <pred>? objc-nil?)` where `<pred>?` is a per-class
  predicate defined inline in each class file. `Id`/`Instancetype`
  returns stay `any/c`.

### `coerce-arg` — automatic param conversion

At the wrapper's body (not its contract), each object arg flows through
`coerce-arg` from `runtime/coerce.rkt`. It handles the set exactly
matched by the contract: `string? → NSString`, `objc-object? → _id`,
`cpointer? → _id`, `#f → nil`. This is why the contract does not have
to be more specific — `coerce-arg` closes the gap.

### `->string` — polymorphic NSString → string

`runtime/type-mapping.rkt` exports `->string`, which accepts
`objc-object`, raw `cpointer`, `string?`, or `#f`. Replaces the ad-hoc
`ns->str` helpers that earlier apps carried.

### NSColor colour-space gotcha

`nscolor-red-component`, `-green-component`, `-blue-component`,
`-alpha-component` **raise an NSException** on a color whose color
space is not RGB — pattern colors, named colors, greyscale colors all
fail. NSColorPanel's color is user-selectable, so it can be any of
these. Always convert first:

```racket
(define rgb
  (nscolor-color-using-color-space
    color
    (nscolorspace-device-rgb-color-space)))
(when rgb  ; can be #f if conversion fails
  (define r (nscolor-red-component rgb))
  (define g (nscolor-green-component rgb))
  (define b (nscolor-blue-component rgb)))
```

### Delegate IMPs and `coerce-arg` on receivers

Inside a dynamic-subclass IMP or a `make-delegate` handler, `self` is a
**raw cpointer**, not an `objc-object?` wrapper. Sending messages to it
via a generated class wrapper fails the self contract. Two options:

- Pass `#:param-types` with `'object` for the `self` position (only
  applicable to delegate args, not to the IMP self).
- Use `tell` directly, but wrap through `coerce-arg`:
  ```racket
  (tell #:type _NSPoint (coerce-arg event) locationInWindow)
  ```
  `coerce-arg` does the `(cast ... _pointer _id)` that raw `tell`
  requires, and accepts raw cpointers, `objc-object?`, `string?`, and
  `#f` alike.


## Packaging sample apps

### Why bundling

Two reasons a `racket script.rkt` invocation is not production-ready:

1. **Menu-bar app name.** Cocoa reads the bold app name from
   `CFBundleName` in `Info.plist`. Unbundled, a Racket app shows up as
   "racket". `NSProcessInfo setProcessName:` is filtered by modern
   macOS and does not help.
2. **Per-app TCC permissions.** Accessibility, Screen Recording,
   Camera, etc. are keyed on the binary's CDHash. Without a per-app
   stub binary, every Racket app shares one TCC entry for
   `/opt/homebrew/bin/racket`.

### Building a bundle

```sh
cargo run --example bundle_app -p apianyware-macos-bundle-racket -- hello-window
# → generation/targets/racket/apps/hello-window/build/Hello Window.app
```

What `bundle-racket` does:

- Walks the entry script's transitive `(require ...)` tree and copies
  only the reachable runtime modules and generated bindings into
  `Resources/racket-app/` preserving the source layout.
- Copies `lib/libAPIAnywareRacket.dylib` if present, and normalises its
  install_name to `@executable_path/../Resources/racket-app/lib/<name>`.
- Excludes `compiled/` subdirectories. Host-compiled `.zo` files bake
  in machine-specific path references and will fail with wrong-arity
  contract errors on any other machine.
- Signs the stub binary, copies resources, then re-signs the full
  bundle (two-stage signing — a single post-copy sign produces an
  inconsistent bundle that Gatekeeper rejects).

### Conventions

- **Bundle ID domain:** `com.linkuistics.*`, never `com.apianyware.*`.
  The kebab→Title conversion for the app name produces the bundle ID
  automatically: `hello-window` → `com.linkuistics.HelloWindow`.
- **Display name:** read from the `# <Display Name>` H1 of
  `docs/apps/<name>/spec.md` when present. The kebab→Title
  fallback mis-capitalises acronyms ("Ui Controls Gallery").
- **Info.plist overrides:** `AppSpec.info_plist_overrides` is a
  `HashMap<String, plist::Value>` for ad-hoc keys (e.g.
  `NSCameraUsageDescription`). Empty maps skip the plist round-trip
  entirely — `plist::to_file_xml` is not byte-identical to
  `PlistBuddy` output.
- **Stable signing identity:** `AppSpec.signing_identity: Option<String>`.
  `None` uses ad-hoc signing; `Some("...")` passes through to
  `codesign --sign`.

### Adding a new sample app

1. Create `apps/<name>/<name>.rkt` with an `(nsapplication-run app)`
   at the end.
2. Create `docs/apps/<name>/spec.md` with `# <Display Name>` as
   the first heading.
3. Append `<name>` to the `APPS` list in
   `generation/crates/emit-racket/tests/runtime_load_test.rs`.
4. If the app imports a framework not already in the hermetic test
   tree, append it to `REQUIRED_FRAMEWORKS` in the same file.

The bundling integration test auto-discovers apps via directory walk —
no edit needed there.


## Testing apps in a VM

Every sample app is validated end-to-end in a macOS VM via
`TestAnyware`. Never run GUI apps directly from the CLI — always
use the VM for visual verification.

```sh
TA={{DEV_ROOT}}/TestAnyware
TA_BIN=$TA/cli/.build/release/testanyware

# Boot a VM; vm-start.sh writes a per-VM spec file and prints the VM id
# on stdout. Run as a normal subprocess (no `source` needed).
ID=$($TA/provisioner/scripts/vm-start.sh --viewer)

# Ship a bundled .app.
APP="apps/hello-window/build/Hello Window.app"
tar -C "$(dirname "$APP")" -czf /tmp/app.tgz "$(basename "$APP")"
$TA_BIN upload --vm $ID /tmp/app.tgz /Users/admin/app.tgz
$TA_BIN exec --vm $ID "tar -xzf /Users/admin/app.tgz -C /Users/admin/ && open '/Users/admin/Hello Window.app'"

# Visual verification.
$TA_BIN agent snapshot --vm $ID --window "Hello Window"
$TA_BIN screenshot --vm $ID -o /tmp/s.png
$TA_BIN find-text --vm $ID "Hello Window"

# Always kill before relaunch.
$TA_BIN exec --vm $ID "pkill -9 -f racket"

# Teardown.
$TA/provisioner/scripts/vm-stop.sh $ID
```

### `--vm <id>` vs `--connect <spec>`

`vm-start.sh` writes a per-VM spec to
`$XDG_STATE_HOME/testanyware/vms/<id>.json` (default
`~/.local/state/testanyware/vms/<id>.json`). Prefer `--vm <id>` in every
command — no manual `/tmp/ta_connect.json` juggling. Resolution order
(highest priority first): `--connect`, `--vm`, explicit flags,
`TESTANYWARE_VM_ID`, `TESTANYWARE_VNC`/`_AGENT` env vars.

### VM workflow quirks worth knowing

**Never use SSH.** `testanyware exec` is reliable (the wedge was fixed
2026-04-17). `timedOut: true` is a deadline signal, not a failure —
poll for completion rather than retrying.

**VirtioFS serves stale files.** Use `upload` with base64 or tar, or
restart the VM. VirtioFS-shared directories will serve cached content
indefinitely.

**Menu drill-down needs VNC click, not `agent snapshot`.** Accessibility
only surfaces top-level menu bar items until the menu is opened. To
verify submenu contents, VNC-click the menu title, then `screenshot`
the region.

**`set-value` fails for NSStackView-hosted textfields.** The
accessibility set-value path can't reach textfields nested inside
NSStackView containers (symptom on Tahoe: `Multiple elements matched`,
or `No element found`). Use VNC keyboard input instead:

```sh
# Triple-click focuses AND selects. Single-click is unreliable.
$TA_BIN input click --vm $ID --count 3 <screen-x> <screen-y>
$TA_BIN input type --vm $ID "new value"
$TA_BIN input key --vm $ID return
```

**`--window` coord offset on Tahoe.** The `--window <name>` flag on
`input click` uses AX-reported window origin which includes drop-shadow
inset — VNC clicks land ~40 px low. Use screen-absolute coords derived
from a full-screen screenshot.

**Long-running installs need detach.** `brew install minimal-racket`
takes ~5 minutes on Tahoe. Without `nohup ... > /tmp/x.log 2>&1 &`,
the spawning shell ends with the HTTP call and the child is killed.
Poll via `until $TA_BIN exec --vm $ID "test -x /path/to/binary"; do sleep 15; done`.

**Orphan VMs lose their VNC password.** `tart run --vnc-experimental`
prints the password once to stdout; a VM started outside `vm-start.sh`
has no recoverable password. Recovery: `tart stop <id>` then restart
via `bash provisioner/scripts/vm-start.sh --id <id>`, which re-clones
from the golden image.


## AppKit widget quirks

Real-world details discovered while building the sample apps:

- **Radio button mutual exclusion.** NSButton radio buttons do not
  automatically deselect siblings. Implement a target-action delegate
  that iterates the group and clears the others.
- **NSStepper continuous mode.** `setContinuous: YES` is required to
  fire target-action on every tick; otherwise only mouse-up fires.
- **NSStepper inside NSView inside NSStackView.** May not receive
  clicks. Add the NSStepper directly as an arranged subview of the
  stack.
- **NSScrollView scroll direction.** `dy = +50` scrolls *toward the
  top* (Cocoa's unflipped origin is bottom-left). This is opposite to
  most mental models — explicit constants help readability.
- **Cell-based NSTableView row height.** The default 17pt row height
  looks off; use 20pt with `setEditable: NO` per column for a clean
  read-only list.
- **NSScrollView border.** Default bezel border looks wrong when
  flush to the window edge — use `setBorderType: NSNoBorder` (= 0).
- **Baseline alignment of NSButton and NSTextField.** Don't fiddle
  with y coordinates. Use `NSStackView` horizontal with
  `NSLayoutAttributeFirstBaseline` (= 12) alignment; Auto Layout
  pins the `firstBaselineAnchor`s together exactly.


## Further reading

- `generation/targets/racket/docs/reference.md` — concise target-specific learnings
  (internal notes, not a user guide).
- `generation/targets/racket/docs/design/2026-04-19-racket-oo-class-system-analysis.md` — full
  analysis of why the target does not use `racket/class`, and the
  design rationale for `define-objc-subclass`.
- `docs/specs/2026-04-16-sample-app-portfolio-design.md` — the app
  portfolio shape and what each app exercises.
- `docs/pipeline/memory-architecture.md` — the upstream ObjC ownership
  model that shapes the annotations the emitter consumes.
- Sample apps (`apps/<name>/<name>.rkt`) — the best working references
  for each pattern:
  - `hello-window` — minimal app structure.
  - `ui-controls-gallery` — most common AppKit widgets.
  - `drawing-canvas` — multi-method dynamic subclassing + CGContext.
  - `pdfkit-viewer` — PDFKit + NSNotificationCenter observer.
  - `scenekit-viewer` — SceneKit.
  - `mini-browser` — WKWebView + navigation delegate.
  - `note-editor` — NSSplitView, WKWebView `loadHTMLString`,
    NSSavePanel/NSOpenPanel, NSUndoManager.

# sbcl macOS binding — user guide (§22)

The entry point for **using** the generated sbcl binding for macOS. SBCL ships no separate developer
guide, so this page is the primary walkthrough: what you are using, how the bindings load, the
per-selector generic surface, `make-instance` with typed inits, how to subclass, how threading and
errors behave, and how to ship a `.app`. The deepest mechanism detail (the `objc-class` metaclass
model, the FP-trap masking, the finalize + release-queue lifetime, the dumped-image bundler) is in
[`../../../docs/reference.md`](../../../docs/reference.md); the target model behind it is mapped in
[`../../../docs/overview.md`](../../../docs/overview.md).

## What you are using

A class-and-method binding over directly-dispatched ObjC, projected into **idiomatic CLOS through the
metaobject protocol**. Unlike racket and chez — which expose flat free procedures over one opaque
object — and unlike gerbil's manifest `defclass` graph, sbcl backs every bound ObjC class with an
`objc-class` metaclass (a `standard-class` subclass), reifying the ObjC hierarchy as a real
metaclass-backed class graph (ADR-0034) with **per-selector generic-function dispatch** over it. The
binding is **idiomatic Common Lisp**: `make-instance`, `defgeneric`/`defmethod`, `handler-case`,
`unwind-protect`, `slot-value` — never Scheme-shaped or portable-only code. You write against a
portable **`ns:` contract surface** (ADR-0033), so the same source ports to a future CL-family member
(CCL, AllegroCL, LispWorks); the SBCL-specific helpers (`make-instance`, `aw-with-rect`, the `@"…"`
reader) live in the `apianyware-sbcl-impl` package.

## The binding layout (`bindings/macos/`)

| dir | what it holds |
|---|---|
| `runtime/` | the hand-written runtime modules (`packages`, `ffi`, `objc`, `subclass`, `lifetime`, `conditions`, `threading`, `startup`, `swift-trampoline`, `value-struct`, `reader-syntax`) — tracked; see its [`README.md`](../runtime/README.md) |
| `generated/<framework>/<class>.lisp` | emitted per-class CLOS binding source (gitignored — produced by `apianyware-generate --target sbcl`, **absent in a clean checkout**) |
| `generated/<framework>/{generics,enums,constants,functions,structs}.lisp` | emitted per-framework generics, enum/option-set constants, and the Swift-native residual (`constants`/`functions`/`structs` are residual-gated) |
| `reports/` | screenshots / VM-verify artifacts (one dir per sample app) |
| `docs/` | this §22 binding mapping doc set |

There is **no Scheme-style import model** here. SBCL loads source files in order into one package
(`apianyware-sbcl-impl`); bound Cocoa names stay `ns:`-qualified. The §18 *target* docs (overview,
language characteristics, FFI model, idiom map, representability) live one level up at
[`../../../docs/`](../../../docs/); the authored target-model `.apiw` entities are under
[`../../../`](../../../) (`target.apiw`, `capability.apiw`, `idioms/`, `policies/`, `adapters/`,
`conformance/`).

## Loading the binding — `aw-app-load-framework` + `:load-residual`

The dev load surface is the shared harness
[`../../../app-implementations/macos/_support/load-bindings.lisp`](../../../app-implementations/macos/_support/load-bindings.lisp),
which loads `runtime/load.lisp` then defines `aw-app-load-framework`. A per-app `run.lisp` loads the
harness, loads the frameworks it needs, loads the app, and runs it. The pure-ObjC case (from
[`../../../app-implementations/macos/hello-window/run.lisp`](../../../app-implementations/macos/hello-window/run.lisp)):

```lisp
(in-package #:cl-user)
(load (merge-pathnames "../_support/load-bindings.lisp" *app-dir*))
(in-package #:apianyware-sbcl-impl)

(aw-app-load-framework "Foundation" :load-residual nil)   ; pure ObjC — no Swift-native residual
(aw-app-load-framework "AppKit"     :load-residual nil)

(load (merge-pathnames "hello-window.lisp" cl-user::*app-dir*))
(hello-window-main :run t)
```

The `:load-residual` flag is the dylib seam:

- **`:load-residual nil`** — load the framework's classes + generics only; skip
  `constants.lisp`/`functions.lisp`/`structs.lisp` and the Swift-native `defmethod`s. An app that
  **needs neither** the Swift-native residual **nor** a custom subclass loads everything this way and
  needs **no** `libAPIAnywareSbcl` dylib at all (every pure-ObjC GUI app whose UI is built from
  framework classes — hello-window).
- **`:load-residual t`** — also load the residual constants/functions/structs. Needed when the app
  uses a framework string constant (`pdfkit-viewer` needs `PDFViewPageChangedNotification`) or a
  Swift-native API.

Note the dylib has a **second** trigger independent of the residual: an app with a **custom subclass
or delegate** loads `libAPIAnywareSbcl` for the `SubclassSynth` forwarding IMP + the foreign→main
bounce, even when every Cocoa call it makes is plain ObjC (`pdfkit-viewer`, `scenekit-viewer`). Then
`run.lisp` sets `*native-dylib-path*` and calls `(aw-load-native-dylib)` before loading frameworks.

(The dev harness uses plain `load`; the **production** path is an ASDF system dumped to a
`save-lisp-and-die` image — see *Packaging* below. The enriched IR is gitignored, so
`generate --target sbcl` cannot run against a real framework locally; the runtime smoke suite drives
hand-authored binding slices in the emitter's exact output shape.)

## Writing against the binding

A first program opens a window — the shape every sample app follows (from
[`../../../app-implementations/macos/hello-window/hello-window.lisp`](../../../app-implementations/macos/hello-window/hello-window.lisp)):

```lisp
(in-package #:apianyware-sbcl-impl)

(defun hello-window-main (&key (run t))
  (let ((app (ns:shared-application (find-class 'ns:ns-application))))
    (ns:set-activation-policy_ app ns:ns-application-activation-policy-regular)
    (install-app-menu app "Hello Window")
    (aw-with-rect (frame 0 0 400 200)
      (let ((window (make-instance 'ns:ns-window
                      :init-with-content-rect frame
                      :style-mask (logior ns:ns-window-style-mask-titled
                                          ns:ns-window-style-mask-closable)
                      :backing ns:ns-backing-store-buffered
                      :defer nil)))
        (ns:set-title_ window @"Hello from SBCL")
        (ns:center window)
        (ns:make-key-and-order-front_ window nil)
        (ns:activate-ignoring-other-apps_ app t)
        (when run (ns:run app))))))
```

Note the shapes, all from the emitter (full table in
[`platform-docs-mapping.md`](platform-docs-mapping.md)):

- **Class methods dispatch on the class metaobject** — `(ns:shared-application (find-class
  'ns:ns-application))` (an `(eql (find-class …))`-specialized generic), not a free procedure.
- **Instance methods are per-selector generics with the selector structure preserved** (ADR-0039):
  each `:` → `_`, each camelCase hump → `-`. So `-[NSWindow setTitle:]` is `ns:set-title_`,
  `-[NSView addSubview:]` is `ns:add-subview_`, `setObject:forKey:` is `ns:set-object_for-key_`. The
  trailing `_` per colon is the headline naming divergence — the **inverse** of the Schemes' kebab
  `nsfoo-set-title!` convention. The map is injective: a colon and a hump never merge, so distinct
  selectors never collide.
- **`make-instance` with typed init keywords** is the designated-initializer surface — an
  `NSWindow`'s `initWithContentRect:styleMask:backing:defer:` is `(make-instance 'ns:ns-window
  :init-with-content-rect r :style-mask … :backing … :defer …)`, the `NSRect` flowing by value
  through the ADR-0040 typed applier. A failable init yields `nil`, so `(when obj …)` is the whole
  guard. **The init registry is keyed by *exact class*** — an inherited *typed* init does not resolve
  via `make-instance` on a subclass (in practice this never bites: modern AppKit uses class
  convenience constructors or bare `make-instance` + setters).
- **Inherited methods resolve by CLOS structurally** — `setStringValue:` is emitted only on
  `ns:ns-control` yet dispatches onto an `NSTextField`/`NSSlider`/… instance for free. Grepping a
  subclass file for an inherited setter returns 0 — that is correct, not a gap.
- **NSStrings via the `@"…"` reader macro** — `@"text"` reads as a lifetime-managed `ns:ns-string`.
  It is the app-author's string primitive (setters take an *object*, not a Lisp string). Build a
  *dynamic* string with `(aw-wrap (aw-make-nsstring (format nil …)) t)`.
- **Geometry via `aw-with-rect`** — a stack-allocating `with-` macro (not a `make-rect`
  constructor); the rect lives for the dynamic extent and is copied by value into the call.
- **Constants** keep their lisp-cased `ns:` names (`ns:ns-window-style-mask-titled`); option sets are
  `(logior …)` of flag constants.

## Subclassing — *deriving in Lisp = deriving in ObjC*

To receive framework callbacks (a custom `NSView`'s `drawRect:`, a custom controller), synthesize a
real ObjC subclass (ADR-0034 §5):

```lisp
(define-objc-subclass canvas-view (ns:ns-view) (strokes))   ; a real objc_allocateClassPair subclass
(define-objc-method canvas-view "drawRect:" (self rect)     ; installs the forwarding IMP
  (render (slot-value self 'strokes)))
```

`define-objc-subclass` synthesizes and registers an `objc_allocateClassPair` subclass carrying app
state in CLOS `:initform` slots; each `define-objc-method` routes its selector through the **one**
reflective `NSInvocation`-forwarding IMP (`SubclassSynth`), which is ABI-correct for every selector
shape — so `drawRect:`'s `NSRect` **is** delivered (`(self rect)`, a divergence from gerbil, whose
generic trampoline drops the struct). Three rules: synthesize **inside a function** called from
`-main` (the ObjC class pair does not survive a dump — re-synthesis on revive is idempotent);
override the ObjC super with **`call-super`** (`objc_msgSendSuper`), *not* `call-next-method` (which
re-enters the forwarding IMP → infinite recursion); and prefer subclassing over a hand-rolled block.

## Threading — the main-thread *bounce*, plus real background compute

SBCL is genuinely multi-threaded, but a **foreign** OS thread (a GCD worker, a completion thread)
must **never** run Lisp — under GC it crashes deterministically (`GC-STOP-THE-WORLD` `ENOTSUP`,
spiked 5/5). So foreign-thread callbacks **bounce** to the main thread (ADR-0035): the native block
body / subclass `forwardInvocation:` hops to main via `dispatch_sync` before any Lisp runs. On the
main thread already (the AppKit-delegate common case) it calls straight in — zero hop.

SBCL's compensating richness over gerbil/racket: **native `sb-thread` workers do run real concurrent
Lisp safely**. Do pure-Lisp compute on them, then hand the result to the UI on main:

```lisp
(with-background-work (:name "reindex")
  (let ((result (expensive-pure-lisp-computation)))
    (aw-on-main (lambda () (update-some-view result)))))   ; UI-safe hand-off, blocks until done
```

Blocks are automatic: a method taking an ObjC block argument accepts a plain Lisp closure (the
emitted binding wraps it with `aw-block`); the closure receives the block's args at its natural arity.
The one caveat (shared with racket/gerbil): a **value-returning** callback whose result the main
thread is itself synchronously awaiting would deadlock (the bounce is `dispatch_sync`); void
completions are immune. See [`../../../docs/ffi-model.md`](../../../docs/ffi-model.md) and reference.

## Errors — signalled conditions

The CL-family idiom, **diverging from chez/gerbil's `(values result error)`**: a Cocoa error surfaces
as a **signalled `ns:objc-error` condition**, caught with `handler-case` (ADR-0037). Flat hierarchy:
root `ns:objc-error : cl:error`; `ns:cocoa-error` (the `NSError**` path, with
`domain`/`code`/`user-info`/`localized-description` readers); `ns:objc-exception` (the `NSException`
path). The signaller fires **only** when the primary return indicates failure (`nil`/`NO`) — Apple's
"check the return, not the error". Catch with:

```lisp
(handler-case (ns:contents-of-directory-at-path_error_ fm path)
  (ns:cocoa-error (e) (format t "~A (~A ~D)~%" (localized-description e) (domain e) (code e))))
```

## Packaging — the self-contained dumped image

An sbcl `.app` is a `save-lisp-and-die :executable t` image (the SBCL runtime + all bindings
embedded) behind a thin Swift **stub** that `execv`s it (ADR-0041) — **not** gerbil's static
executable nor chez's open-world dynamic bundle. The defining constraint: a dumped image **cannot be
`install_name_tool`'d or re-signed** (the Lisp core is appended after `__LINKEDIT`, and SBCL already
ad-hoc-signs it), so self-containment is closed **at runtime**:

```text
<App>.app/Contents/
  MacOS/<script>            ← thin Swift stub (sets DYLD_FALLBACK_LIBRARY_PATH, execv's the image)
  Resources/<script>        ← the save-lisp-and-die image (keeps its own ad-hoc sig)
  Frameworks/
    libzstd.1.dylib         ← vendored; resolved by leaf name via DYLD_FALLBACK (SBCL's compression dep)
    libAPIAnywareSbcl.dylib ← vendored (residual / subclass apps); reopened @executable_path/..
  Info.plist                ← CFBundleName = "<App>", com.linkuistics.* id
```

The **startup re-resolution pass** is what makes a dumped GUI image work: on revive it re-`dlopen`s
Foundation/AppKit, re-resolves `objc_msgSend` + every `Class`/`SEL` from baked strings, re-masks the
IEEE FP traps SBCL enables by default (AppKit produces NaN/∞ intermediates that would otherwise crash
*any* GUI app), and re-registers the block/forwarding dispatchers — all on `sb-ext:*init-hooks*`. All
seven GUI sample apps are **VM-verified** as standalone `.app`s in a no-SBCL VM via TestAnyware.
Toolchain: `brew install sbcl` (2.6.5 / arm64; no bottle gymnastics), and
`export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"` for the Swift dylib build.

## Where to go next

- [`platform-docs-mapping.md`](platform-docs-mapping.md) — translate an Apple API-doc page into the
  sbcl names.
- [`api-coverage.md`](api-coverage.md) — what is and isn't covered, and how faithfully.
- [`unsafe-escape-hatches.md`](unsafe-escape-hatches.md) — reaching APIs the binding doesn't model.
- [`../../../docs/reference.md`](../../../docs/reference.md) — the deep target reference (metaclass
  model, dispatch, lifetime, conditions, FP-trap masking, bundler, gotchas).

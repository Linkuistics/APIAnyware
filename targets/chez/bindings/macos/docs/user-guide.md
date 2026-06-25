# chez macOS binding — user guide (§22)

The entry point for **using** the generated chez binding for macOS. Chez ships no separate
developer guide, so this page is the primary walkthrough: what you are using, how to require it,
how threading and errors behave, and how to ship a `.app`. The deepest mechanism detail (the
five-cluster runtime, the lifetime model, dispatch internals) is in
[`../../../docs/reference.md`](../../../docs/reference.md); the target model behind it is mapped in
[`../../../docs/overview.md`](../../../docs/overview.md).

## What you are using

A class-and-method binding over directly-dispatched ObjC. Every class is a flat set of free
procedures named `<class>-<method>` operating on an opaque `objc-object` — **not** a Scheme record
hierarchy mirroring the ObjC class graph. The binding is **maximally idiomatic Chez** (ADR-0005):
inside it you get `(library …)` forms, `foreign-procedure`, `define-ftype`, `define-record-type`,
guardians, and `let-values` — never portable-R6RS or racket-shaped code. If a familiar idiom
surprises you, the friction is almost always FFI-shaped, not OO-shaped.

## The binding layout (`bindings/macos/`)

Chez's layout is **unlike racket's**: there is no separate `generated/` directory. The emitter
writes each framework's libraries **interleaved with the hand-written runtime under one
`apianyware/` namespace tree**, because Chez maps a library *name* `(apianyware fw cls)` to the
on-disk *path* `<libdir>/apianyware/fw/cls.sls`.

| dir | what it holds |
|---|---|
| `apianyware/` | the Chez **package root** — the `(apianyware …)` library namespace tree (this *is* the emitted-package-root) |
| `apianyware/runtime/` | the hand-written runtime modules (`ffi`, `objc`, `dispatch`, `types`, `cocoa`, the Swift trampolines) — tracked |
| `apianyware/<framework>/` | emitted per-framework `.sls` binding source (gitignored — produced by `apianyware-generate`, absent in a clean checkout) |
| `lib/` | the built `libAPIAnywareChez.dylib` (symlink into the chez adapter package's `.build`) |
| `reports/` | screenshots / VM-verify artifacts |

See [`../README.md`](../README.md) for the directory contract and *why* chez is shaped this way.

## Requiring bindings — the `(apianyware …)` model

You `import` library names, and you point Chez's library search at the binding root with
`--libdirs`. The framework-level library re-exports its per-class libraries, so the common case is
a single framework import:

```scheme
(import (chezscheme)
        (apianyware appkit)            ; re-exports every emitted AppKit class
        (apianyware foundation)
        (apianyware runtime cocoa)     ; the runtime helpers you call directly
        (apianyware runtime objc)
        (apianyware runtime types))
```

Run a script unbundled by passing the binding root as the lib search path:

```
chez --libdirs targets/chez/bindings/macos \
     --script targets/chez/app-implementations/macos/hello-window/hello-window.sls
```

`--libdirs <root>` is **`bindings/macos/` itself**: Chez resolves `(apianyware fw cls)` to
`<root>/apianyware/fw/cls.sls`, and `runtime/ffi.sls` probes `<root>/lib/libAPIAnywareChez.dylib`
for the mandatory adapter dylib (ADR-0005). A bundled `.app` passes its own `--libdirs` pointing at
the in-bundle copy (see *Packaging* below).

## Writing against the binding

A first program is a script that opens a window — the shape every sample app follows
([`../../../app-implementations/macos/hello-window/`](../../../app-implementations/macos/hello-window/)):

```scheme
(define-entry-point (main)
  (let ([app (nsapplication-shared-application)])
    (nsapplication-set-activation-policy! app NSApplicationActivationPolicyRegular)
    (let ([window (make-nswindow-init-with-content-rect-style-mask-backing-defer
                    (make-nsrect 0 0 400 200)
                    (bitwise-ior NSWindowStyleMaskTitled NSWindowStyleMaskClosable)
                    NSBackingStoreBuffered #f)])
      (nswindow-set-title! window "Hello from Chez")
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
are `(bitwise-ior …)` of flag constants; geometry structs are `make-nsrect` and friends. The
receiver is always the **first** argument — a labelling choice, not an object system.

## Threading — *activation*, not a bounce

Chez's distinguishing behaviour: foreign-thread callbacks **activate** the calling thread
(`Sactivate_thread`, ADR-0016) and run your Scheme handler **on that thread** — chez does not bounce
foreign-thread callbacks to the main thread the way racket/gerbil/sbcl do. The one place chez *does*
hop to the main thread is **AppKit UI mutation**, and the `AsyncBridge` fires completion callbacks
on the main thread for you. Practical rule: a *blocking outbound* call you make from a callback must
itself be `__collect_safe`, or you can stall the collector behind it (see
[`../../../docs/ffi-model.md`](../../../docs/ffi-model.md) and reference §2–§3).

## Errors

`NSError**` out-parameters surface as **multiple values** — `(let-values ([(result err) …]) …)`
(ADR-0006) — and thrown `NSException`s / Swift errors surface as **R6RS conditions**, catchable with
`guard`. The result wrapper hides the raw out-param pointer; see
[`platform-docs-mapping.md`](platform-docs-mapping.md) for the per-shape mapping.

## Packaging — the open-world self-contained `.app`

Chez ships as an **open-world self-contained `.app`** (ADR-0009): boot files + the chez runtime are
bundled, so the app runs on a clean machine with no Chez install. The build pays a **one-time
whole-program compile** (~160 s) but the shipped bundle **launches in ~0.29 s** — a build-time cost,
not a runtime one. All seven GUI sample apps are VM-verified; bundle one with
`cargo run --example bundle_app -p apianyware-bundle-chez -- <app>`.

## Where to go next

- [`platform-docs-mapping.md`](platform-docs-mapping.md) — translate an Apple API-doc page into the
  chez names.
- [`api-coverage.md`](api-coverage.md) — what is and isn't covered, and how faithfully.
- [`unsafe-escape-hatches.md`](unsafe-escape-hatches.md) — reaching APIs the binding doesn't model.
- [`../../../docs/reference.md`](../../../docs/reference.md) — the deep target reference (runtime,
  lifetime, dispatch, gotchas).

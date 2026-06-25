# gerbil macOS binding — platform-docs mapping (§22)

How to read an Apple macOS API-doc page (or header) and find the corresponding gerbil binding. This
is the translation table between *what Apple calls it* and *what the gerbil binding calls it*. The
naming rules are the emitter's; the canonical detail is
[`../../../docs/reference.md`](../../../docs/reference.md).

## Names

| Apple / ObjC | gerbil binding |
|---|---|
| class `NSButton` | a real `defclass` `NSButton` on the manifest graph, in per-class module `:gerbil-bindings/appkit/nsbutton` |
| instance method `-setTitle:` on `NSFoo` | proc-core `nsfoo-set-title!`, receiver as the **first** argument — plus the `{set-title! obj …}` MOP and `(set-title! obj …)` generic surfaces over it |
| class method `+sharedApplication` | a class-scoped, **proc-only** procedure `nsapplication-shared-application` (class methods have no instance receiver to dispatch on) |
| designated initializer `-initWithContentRect:styleMask:backing:defer:` | constructor `make-nswindow-init-with-content-rect-style-mask-backing-defer` |
| property `title` | accessor `nsfoo-title` / setter `nsfoo-set-title!` |
| selector keyword parts `setObject:forKey:` | kebab-cased and joined: `nsfoo-set-object-for-key!` |
| enum / `NS_OPTIONS` constant `NSWindowStyleMaskTitled` | a constant of the **same PascalCase name** in `:gerbil-bindings/<framework>/enums`; option-sets via `(bitwise-ior …)` of flag constants |
| C struct `NSRect`/`NSPoint` | crosses **by value**; constructors `make-rect` / `make-point` (in `runtime/cocoa`), `double` field values (`(make-rect 0. 0. 400. 200.)`) |
| framework function `CGContextStrokePath` | a procedure in the framework's `functions` module under `:gerbil-bindings/coregraphics/…` |
| constant `kCFRunLoopCommonModes` | a constant in the framework's `constants` module under `:gerbil-bindings/corefoundation/…` |

An inherited method lives in the proc core of its **declaring** class: `-[NSView setFrame:]` called
on an `NSTextField` is `nsview-set-frame!`, `-[NSControl setStringValue:]` is
`nscontrol-set-string-value!`. The class graph makes this exact — `wrap` resolves a returned `id` to
its **exact bound type** (`object_getClass` → registry, walking to the nearest bound ancestor).

## Behaviours

How recurring macOS API *shapes* surface in gerbil — the authoritative source-concept → construct
map is [`../../../idioms/docs/idiom-map.md`](../../../idioms/docs/idiom-map.md) over
[`../../../idioms/catalogue.apiw`](../../../idioms/catalogue.apiw). The high-frequency cases:

| Apple doc shape | gerbil idiom |
|---|---|
| `NSError **` out-parameter | surfaces as **multiple values** `(values result err)` (ADR-0006) via `call-with-nserror-out`; the wrapper hides the out-param (catalogue `error-out`) |
| can throw an `NSException` / Swift error | raised as a **`:std/error` object**, catchable with `try` / `with-catch` |
| returns `nil` on failure | surfaces as `#f`; test with `cond` / pattern match (catalogue `nullable-result`) |
| delegate protocol | a real ObjC subclass via **transparent subclassing** (`runtime/subclass`) — *or* an ad-hoc `make-delegate` from per-selector handler procs; the one genuine OO mechanism (ADR-0020) |
| completion block | a Gerbil procedure bridged as an ObjC block via `make-objc-block`; for a Swift-native `async`, delivered on the main thread by `AsyncBridge` |
| KVO / notification observer | a `with-NAME` bracket registers and unregisters in its `unwind-protect` (catalogue `scoped-observer`) |
| "main thread only" | gerbil **bounces** to the main thread (ADR-0022) — it does **not** thread-activate the way chez does |
| `NSString` / `NSArray` argument or return | exact conversion, but **invoked explicitly**: `string->nsstring` / `nsstring->string`, array ↔ list/vector |
| C struct by value (`NSRect`, …) | open-coded by `define-c-lambda` at compile time through Gambit (arm64 register / x8 ABI) |

## Object model and subclassing

- Gerbil is the **one** target with a manifest `defclass` class graph mirroring the ObjC hierarchy
  (ADR-0020), so a wrapped object is a typed Gerbil instance of its exact bound class, and inherited
  methods dispatch through the declaring superclass's proc core — not a flat
  free-procedures-over-one-object convention.
- A **delegate protocol** is most idiomatically realized by **transparent subclassing**: a real ObjC
  subclass whose IMPs dispatch into your Gerbil `defmethod` overrides (`runtime/subclass`; the
  override's `self` is the typed Gerbil instance). For lightweight cases, `make-delegate` builds a
  fresh ObjC class from a list of `(selector proc param-tokens return-token)` specs. Both sit on the
  gsc-compiled native core, **not** the trampoline-only dylib (ADR-0022/0029); see
  [`../../../docs/ffi-model.md`](../../../docs/ffi-model.md).

## See also

- [`../../../docs/reference.md`](../../../docs/reference.md) — emission, type-coercion rules, the
  dual-surface dispatch, and the runtime in full.
- [`api-coverage.md`](api-coverage.md) — whether a given API is covered at all.

# chez macOS binding — platform-docs mapping (§22)

How to read an Apple macOS API-doc page (or header) and find the corresponding chez binding. This
is the translation table between *what Apple calls it* and *what the chez binding calls it*. The
naming rules are the emitter's; the canonical detail is
[`../../../docs/reference.md`](../../../docs/reference.md).

## Names

| Apple / ObjC | chez binding |
|---|---|
| class `NSButton` | per-class library `(apianyware appkit nsbutton)` — or just `(apianyware appkit)`, which re-exports it |
| instance method `-setTitle:` on `NSFoo` | procedure `nsfoo-set-title!`, receiver as the **first** argument |
| class method `+sharedApplication` | a class-scoped procedure `nsapplication-shared-application` (class/instance selectors disambiguated by the emitter) |
| designated initializer `-initWithContentRect:styleMask:backing:defer:` | constructor `make-nswindow-init-with-content-rect-style-mask-backing-defer` |
| property `title` | accessor `nsfoo-title` / setter `nsfoo-set-title!` |
| selector keyword parts `setObject:forKey:` | kebab-cased and joined: `nsfoo-set-object-for-key!` |
| enum / `NS_OPTIONS` constant `NSWindowStyleMaskTitled` | a constant of the **same PascalCase name**; option-sets via `(bitwise-ior …)` of flag constants |
| C struct `NSRect`/`NSPoint` | `define-ftype` types; constructors `make-nsrect` / `make-nspoint`, fields via accessors |
| framework function `CGContextStrokePath` | a procedure in the framework library `(apianyware coregraphics)` |
| constant `kCFRunLoopCommonModes` | a constant in the framework library `(apianyware corefoundation)` |

The receiver-first convention (`(nswindow-set-title! window "…")`) is a labelling choice, not a
Scheme object system — there is one opaque `objc-object` behind every wrapped `id`.

## Behaviours

How recurring macOS API *shapes* surface in chez — the authoritative source-concept → construct map
is [`../../../idioms/docs/idiom-map.md`](../../../idioms/docs/idiom-map.md) over
[`../../../idioms/catalogue.apiw`](../../../idioms/catalogue.apiw). The high-frequency cases:

| Apple doc shape | chez idiom |
|---|---|
| `NSError **` out-parameter | surfaces as **multiple values** `(values result err)` (ADR-0006); the wrapper hides the out-param (catalogue `error-out`) |
| can throw an `NSException` / Swift error | raised as an **R6RS condition**, catchable with `guard` |
| returns `nil` on failure | surfaces as `#f`; test with `cond` / pattern match (catalogue `nullable-result`) |
| delegate protocol | a dynamic ObjC subclass built by `DelegateBridge`; supply per-selector handler procedures |
| completion block | a Scheme procedure bridged as an ObjC block via `BlockBridge`; result delivered on the main thread by `AsyncBridge` |
| KVO / notification observer | a `with-NAME` bracket registers and unregisters in its `dynamic-wind` after-thunk (catalogue `scoped-observer`) |
| "main thread only" | chez hops to the main thread for **UI mutation**; other foreign-thread callbacks **activate** the calling thread (ADR-0016) rather than bounce |
| `NSString` / `NSArray` argument or return | exact conversion at the boundary (string ↔ UTF-8, array ↔ list/vector) |
| C struct by value (`NSRect`, …) | open-coded by `foreign-procedure` at compile time via `define-ftype` |

## Protocols and subclassing

- A **delegate protocol** is realized by `DelegateBridge` — a dynamically-built ObjC class whose
  IMPs dispatch to your Scheme handler procedures (the one genuine OO mechanism), not a Scheme
  interface. The Scheme handlers are GC-rooted via `lock-object` for the delegate's lifetime.
- **Struct-by-value, callbacks, and the dispatch substrate** all sit over one `foreign-callable`
  layer in `runtime/dispatch.sls`; see [`../../../docs/ffi-model.md`](../../../docs/ffi-model.md)
  and reference §3.

## See also

- [`../../../docs/reference.md`](../../../docs/reference.md) — emission, type-coercion rules, and
  the runtime in full.
- [`api-coverage.md`](api-coverage.md) — whether a given API is covered at all.

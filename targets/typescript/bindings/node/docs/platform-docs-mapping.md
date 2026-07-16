# typescript (Node) macOS binding — platform-docs mapping (§22)

How to read an Apple macOS API-doc page (or header) and find the corresponding TypeScript binding.
This is the translation table between *what Apple calls it* and *what the typescript binding calls
it*. The naming rules are the emitter's (`naming.rs`, `class_surface.rs`, ADR-0055/0039); the
canonical detail is [`../../../docs/reference.md`](../../../docs/reference.md).

## Names

| Apple / ObjC | typescript binding |
|---|---|
| class `NSButton` | a real ES6 class `NSButton extends NSControl`, emitted `generated/appkit/nsbutton.ts` (+ co-generated `.d.ts`) |
| instance method `-setTitle:` on `NSFoo` | instance method `setTitle_(title: NSString): void` — receiver is `this`, not a leading argument |
| class method `+buttonWithTitle:…` | a `static` method on the same class |
| designated initializer `-initWithContentRect:styleMask:backing:defer:` | instance method `initWithContentRect_styleMask_backing_defer_(…): this`, called on the result of the shared `__alloc(Cls)` primitive — never a bare `new` |
| property `title` | getter `title(): NSString \| null` / setter `setTitle_(t: NSString): void` — plain methods, not TS `get`/`set` accessors |
| selector keyword parts `setObject:forKey:` | structure-preserving, each `:` → `_`: `setObject_forKey_(object, key)` |
| a selector with no keyword parts, `cancel` vs. `cancel:` | `cancel()` vs. `cancel_()` — the trailing `_` per colon is what keeps the two from colliding (the map is injective) |
| enum / `NS_OPTIONS` | a real TS `enum`; option-sets combine with `\|` |
| C struct `NSRect`/`NSPoint`/`NSRange` | a plain nested by-value object (`{ origin: {x,y}, size: {width,height} }` for `CGRect`) — no handle, no disposal, `import type` from `@apianyware/runtime` |
| framework function `CGContextStrokePath` | a plain exported function in the framework's `functions.ts`, called positionally |
| constant `kCFRunLoopCommonModes` | an exported `const` in the framework's `constants.ts`, built once at module load (a CFSTR literal for an `NSString` constant, a `dlsym`+wrap for a pointer-valued global, a scalar/enum read otherwise) |
| Swift-native free function (`s:` USR, no C symbol) | a plain exported function in `functions.ts`, dispatched through a by-name call-by-symbol entry rather than the direct-C table (indistinguishable at the call site) |

An inherited method resolves by ordinary JS prototype-chain inheritance — `-[NSControl
setStringValue:]` called on an `NSTextField` instance is just `field.setStringValue_(…)`, declared
once on `NSControl` and inherited like any TS method.

## Behaviours

How recurring macOS API *shapes* surface in TypeScript — there is no authored
`idioms/catalogue.apiw` for this target yet (see [`../../../docs/idiom-map.md`](../../../docs/idiom-map.md)),
so this table is the closest analogue to the four Lisp targets' catalogue-backed idiom-map page. The
high-frequency cases:

| Apple doc shape | typescript idiom |
|---|---|
| `NSError **` out-parameter | a type-visible `Result<T>` (`{ok:true, value}` / `{ok:false, error}`); `unwrap(r)` escalates to a thrown `NSErrorError` |
| can throw an `NSException` | caught natively, re-thrown as `NSExceptionError extends ObjCError extends Error` — catchable with `try`/`catch` |
| Swift `throws` | routes through the same `Result<T>` channel as `NSError**` (both are Cocoa's "routine" failure class) |
| returns `nil` on failure | surfaces as `null`; `if (!x) …` is the whole guard |
| delegate protocol | a plain JS object literal implementing the generated `interface`, passed straight to the setter — no subclass, no manual keep-alive |
| dynamic subclass override (`drawRect:`, a custom controller) | a real `class Foo extends NSView { … }`; call the ObjC super with `this.$super.method_(…)`, never bare `super.` |
| completion block | mechanism exists (`__makeEscapingBlock`/`__withNoescapeBlock`, ADR-0059 §2) but the emitted **call-site** surface is currently a narrow two-selector carve-out — see [`api-coverage.md`](api-coverage.md) |
| KVO / notification observer | no generated convenience yet; register/unregister against the plain `NSNotificationCenter` API like any other ObjC call |
| "main thread only" / called on a background thread | **bounces to thread 0** automatically before your JS runs — you do not hop yourself |
| `NSString` argument or return | exact conversion at the boundary; there is no built-in JS-string convenience — build one with `__cfstr`+`__wrapOwned`, read one back through the target string's own accessor methods |
| by-value geometry struct (`CGRect`, `CGPoint`, …) | the closed nine-member POD family, nested plain objects mirroring the C struct fields exactly |

## Protocols and subclassing

- A **protocol** generates a real TS `interface` (`@optional` members are `?`) — not a delegate
  factory function. Pass a plain object literal implementing it directly to the setter; the runtime
  synthesizes the forwarding ObjC class and its keep-alive association on first use.
- **Subclassing** an ObjC class uses `class Foo extends Bar` plus `__allocSubclass`/`__bindSubclass`
  in the constructor (the one genuine OO mechanism every target eventually needs — see the user
  guide and [`../../../docs/reference.md`](../../../docs/reference.md) §6).

## See also

- [`../../../docs/reference.md`](../../../docs/reference.md) §2–§8 — emission, dispatch, memory,
  error, and callback mechanics in full.
- [`api-coverage.md`](api-coverage.md) — whether a given API is covered at all.
- [`user-guide.md`](user-guide.md) — the walkthrough these rules are drawn from.

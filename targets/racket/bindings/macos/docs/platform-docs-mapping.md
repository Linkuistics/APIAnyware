# racket macOS binding — platform-docs mapping (§22)

How to read an Apple macOS API-doc page (or header) and find the corresponding racket binding.
This is the translation table between *what Apple calls it* and *what the racket binding calls it*.
The naming rules are the emitter's; the canonical detail is [`../../../docs/reference.md`](../../../docs/reference.md)
§1–§4.

## Names

| Apple / ObjC | racket binding |
|---|---|
| class `NSButton` | per-class module `generated/appkit/nsbutton.rkt` (lowercased) |
| instance method `-setTitle:` on `NSFoo` | procedure `nsfoo-set-title`, receiver as the **first** argument |
| class method `+buttonWithTitle:…` | a class-scoped procedure on the same module (class/instance selectors disambiguated by the emitter) |
| property `title` | accessor `nsfoo-title` / setter `nsfoo-set-title!` |
| selector keyword parts `setObject:forKey:` | kebab-cased and joined: `nsfoo-set-object-for-key` |
| `init(string:)` (Swift-style selector containing `(`) | filtered — construct via the ObjC `alloc/init` path, not a generated `init(...)` procedure |
| enum / `NS_OPTIONS` | Racket symbols / fixnums; option-sets via `bitwise-ior` of flag constants |
| C struct `NSRect`/`NSPoint` | `define-cstruct` types; fields as Racket struct accessors |
| framework function `CGContextStrokePath` | `generated/coregraphics/functions.rkt` (require via `only-in`) |
| constant `kCFRunLoopCommonModes` | `generated/<framework>/constants.rkt` |

The receiver-first convention (`(nsview-set-frame! view frame)`) is a labelling choice, not
`racket/class` — see the developer guide's *What "OO" means*.

## Behaviours

How recurring macOS API *shapes* surface in racket — the authoritative source-concept → construct
map is [`../../../idioms/docs/idiom-map.md`](../../../idioms/docs/idiom-map.md) over
[`../../../idioms/catalogue.apiw`](../../../idioms/catalogue.apiw). The high-frequency cases:

| Apple doc shape | racket idiom |
|---|---|
| `NSError **` out-parameter | captured and re-raised as `exn:fail:objc`; the result wrapper hides the out-param (catalogue `error-side-channel`) |
| can throw an `NSException` | caught at the trampoline, raised as `exn:fail` (catchable with `with-handlers`) |
| returns `nil` on failure | surfaces as `#f`; `cond`/pattern-match (catalogue `nullable-result`) |
| delegate protocol | a Racket object exposed as ObjC IMPs via a synthesized delegate subclass (`make-<proto>`) |
| completion block | a Racket procedure bridged as an ObjC block; result delivered on the bounced main thread |
| KVO / notification observer | a `with-NAME` macro registers and unregisters in its `dynamic-wind` after-thunk |
| "main thread only" / called on a background thread | **bounces to the main thread** through the trampoline (ADR-0014) |
| `NSString` / `NSArray` argument or return | exact conversion at the boundary (string ↔ UTF-8, array ↔ list/vector) |

## Protocols and subclassing

- A **protocol** generates `make-<proto>` (a delegate factory) + `<proto>-selectors` — not a
  Racket interface. Supply alternating selector-string / procedure handler pairs.
- **Subclassing** an ObjC class from racket uses `define-objc-subclass` (the one genuine OO
  mechanism, `runtime/dynamic-class.rkt`). See the developer guide and reference §7.3.

## See also

- [`../../../docs/reference.md`](../../../docs/reference.md) §2–§4 — emission, contracts,
  type-coercion rules in full.
- [`api-coverage.md`](api-coverage.md) — whether a given API is covered at all.

# sbcl macOS binding — platform-docs mapping (§22)

How to read an Apple macOS API-doc page (or header) and find the corresponding sbcl binding. This is
the translation table between *what Apple calls it* and *what the sbcl binding calls it*. The naming
rules are the emitter's (ADR-0039); the canonical detail is
[`../../../docs/reference.md`](../../../docs/reference.md).

## Names — selector-structure-preserving (the inverse of the Schemes' kebab `!`)

The headline divergence from racket/chez/gerbil: a selector maps to **one generic symbol that
preserves selector structure** — each `:` → `_`, each camelCase hump → `-` — in the `ns:` package.
So `cancel` → `ns:cancel` but `cancel:` → `ns:cancel_`; `objectAtIndex:` → `ns:object-at-index_`;
`setObject:forKey:` → `ns:set-object_for-key_`. The map is **injective** (colon and hump never
merge), so distinct selectors never collide and need no rename table. This is the **inverse** of the
Schemes' `nsfoo-set-title!` kebab convention.

| Apple / ObjC | sbcl binding |
|---|---|
| class `NSButton` | a metaclass-backed CLOS class `ns:ns-button` on the `objc-class` graph, emitted in `generated/appkit/nsbutton.lisp` |
| instance method `-setTitle:` on `NSFoo` | per-selector generic `ns:set-title_`, receiver as the **first** argument (`(ns:set-title_ obj …)`) — one `defgeneric` + one `defmethod` per (class × selector), specialized on the receiver |
| class method `+sharedApplication` | a generic specialized on the **class metaobject**: `(ns:shared-application (find-class 'ns:ns-application))` — class methods dispatch on the class, not a free procedure |
| designated initializer `-initWithContentRect:styleMask:backing:defer:` | `(make-instance 'ns:ns-window :init-with-content-rect r :style-mask … :backing … :defer …)` — typed init keywords, marshalled by the ADR-0040 applier |
| property `title` | accessor `ns:title` / setter `ns:set-title_` |
| selector keyword parts `setObject:forKey:` | structure-preserved: `ns:set-object_for-key_` (one `_` and one argument per colon) |
| enum / `NS_OPTIONS` constant `NSWindowStyleMaskTitled` | a constant `ns:ns-window-style-mask-titled` in the framework's `enums.lisp`; option-sets via `(logior …)` of flag constants |
| C struct `NSRect`/`NSPoint` | crosses **by value** as a `(sb-alien:struct …)`; stack-allocated with `aw-with-rect` (not a constructor), `double` field values; returns are directly slot-readable (`(sb-alien:slot r 'x)`) |
| framework function `CGContextStrokePath` | a procedure in the framework's `functions.lisp` (residual-gated) |
| constant `kCFRunLoopCommonModes` / `PDFViewPageChangedNotification` | a `defparameter` in the framework's `constants.lisp` (residual-gated; re-resolved at startup in a dumped image) |
| NSString literal | the `@"…"` reader macro → a lifetime-managed `ns:ns-string` |

An inherited method dispatches by **plain CLOS inheritance** — `-[NSControl setStringValue:]` called
on an `NSTextField` is `(ns:set-string-value_ field …)`, resolved structurally onto the subclass
instance with no per-target idiom (a divergence from chez/gerbil, which route via the *declaring*
class's proc). `aw-wrap` resolves a returned `id` to its **exact bound type** through the MOP class
registry.

## Behaviours

How recurring macOS API *shapes* surface in sbcl — the authoritative source-concept → construct map
is [`../../../idioms/docs/idiom-map.md`](../../../idioms/docs/idiom-map.md) over
[`../../../idioms/catalogue.apiw`](../../../idioms/catalogue.apiw). The high-frequency cases:

| Apple doc shape | sbcl idiom |
|---|---|
| `NSError **` out-parameter | surfaces as a **signalled `ns:cocoa-error` condition** (ADR-0037), caught with `handler-case` — **not** chez/gerbil's `(values result err)`; signalled only when the primary return is `nil`/`NO` |
| can throw an `NSException` / Swift error | a signalled **`ns:objc-exception`** / `ns:cocoa-error` condition (the `ThrowsBridge` shares one `signal-cocoa-error`) |
| returns `nil` on failure | surfaces as `nil`; `(when obj …)` is the whole guard (a failable `make-instance` returns `nil` too) |
| delegate protocol | a real ObjC subclass via `define-objc-subclass` + `define-objc-method` (`SubclassSynth`); the override's `self` is the typed CLOS instance — the one genuine OO mechanism (ADR-0034 §5) |
| completion block | a Lisp closure auto-wrapped with `aw-block`; for a Swift-native `async`, delivered **on the main thread** by `AsyncBridge` |
| KVO / notification observer | a synthesized controller registers/unregisters; its strong `*subclass-instances*` rooting pins it for the process (catalogue `scoped-observer`) |
| "main thread only" | sbcl **bounces** to the main thread (ADR-0035) — it does **not** thread-activate the way chez does |
| `NSString` / `NSArray` argument or return | exact conversion, invoked explicitly: `@"…"` / `nsstring->string`, array ↔ CL sequence |
| C struct by value (`NSRect`, …) | open-coded by `sb-alien` at compile time; arm64 HFA returns slot-readable directly, projected to the CLOS value-struct surface (ADR-0042) |

## Object model and subclassing

- SBCL projects the ObjC class system into CLOS **through the metaobject protocol** (ADR-0034) — an
  `objc-class` metaclass backs every bound class, ObjC ivars are foreign slots via
  `slot-value-using-class`, and a wrapped object is a typed CLOS instance of its exact bound class.
  This goes **further** than gerbil's manifest `defclass` graph and rejects racket/chez's flat
  free-procedures-over-one-object shape. Inherited methods dispatch by plain CLOS inheritance.
- A **delegate protocol** is realized by **subclassing**: `define-objc-subclass` synthesizes a real
  ObjC subclass whose selectors route through the **one** reflective `NSInvocation`-forwarding IMP
  (`SubclassSynth`), bouncing foreign→main before your `define-objc-method` handler runs. Override
  the ObjC super with `call-super` (not `call-next-method`). This sits in `libAPIAnywareSbcl`, the
  sole native unit (ADR-0038); see [`../../../docs/ffi-model.md`](../../../docs/ffi-model.md).

## See also

- [`../../../docs/reference.md`](../../../docs/reference.md) — emission, the MOP dispatch model, the
  type-coercion rules, and the runtime in full.
- [`api-coverage.md`](api-coverage.md) — whether a given API is covered at all.

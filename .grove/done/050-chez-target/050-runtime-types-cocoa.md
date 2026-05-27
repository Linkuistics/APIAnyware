# 050-runtime-types-cocoa

**Kind:** work

## Goal
Fill `runtime/types.sls` and `runtime/cocoa.sls` — the cluster of helpers
that turn FFI primitives into application-level conveniences.

- `types.sls`: NSString/NSArray/NSDictionary marshallers
  (`string->nsstring`, `nsstring->string`, `->string`, `list->nsarray`,
  `nsarray->list`, `hash->nsdictionary`, `nsdictionary->hash`), the
  geometry ftypes (`NSPoint`, `NSSize`, `NSRect`, `NSRange`,
  `NSEdgeInsets`, `NSDirectionalEdgeInsets`, `NSAffineTransformStruct`,
  `CGAffineTransform`, `CGVector`) and their `make-*` constructors, the
  CoreFoundation bridging helpers from `cf-bridge.rkt`, the
  `coerce.rkt` predicate set.
- `cocoa.sls`: `install-standard-app-menu!`, main-thread dispatch helpers
  (`dispatch-on-main-thread`), the suite of `*-helpers.rkt` analogs that
  sample apps reach for (nsview-helpers, nsevent-helpers,
  cgevent-helpers, ax-helpers, spi-helpers), and the `objc-subclass.rkt`
  conveniences if they survive (re-check; some of objc-subclass may
  collapse into `dispatch.sls`'s dynamic-class API).

## Context
- All of `generation/targets/racket/runtime/*.rkt` files this cluster
  absorbs — for semantics and for matching the existing sample-app call
  sites that the chez ports will mirror in 100–140.
- Design spec §2 — the cluster boundaries are deliberate; if the size
  of `cocoa.sls` becomes unwieldy during this leaf, split it (`cocoa.sls`
  + `cocoa-helpers.sls`) and note the rationale.

## Done when
- `(import (apianyware runtime types))` and `(import (apianyware runtime cocoa))`
  load cleanly.
- A round-trip demo `(let ([s (string->nsstring "hi")]) (nsstring->string s))`
  works.
- Geometry struct round-trip via `define-ftype` works
  (`(make-nsrect 0 0 100 100)` → `NSRect-origin` accessor returns the
  right NSPoint).
- A demo `install-standard-app-menu!` call against a stub NSApplication
  installs a menu without crashing.

## Notes
- ftype-pointer vs define-ftype: Chez 10's `define-ftype` defines a type;
  `make-ftype-pointer` allocates an instance. The geometry types are
  value-by-copy at the C ABI, not pointers — `(values nsrect)` returns
  may need `make-ftype-pointer` followed by a copy-into-result step.
  Confirm during the leaf.

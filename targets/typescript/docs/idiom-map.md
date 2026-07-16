# typescript (Node) — idiom map (§18)

> **There is no authored `idioms/catalogue.apiw` for this target** (unlike racket/chez/
> gerbil/sbcl — see `overview.md`'s facet table: the `apianyware-target-model` §21 idiom
> catalogue has not been extended to `typescript`). This page points at where the
> equivalent source-concept → TypeScript-construct decisions actually live, rather than a
> second copy of a catalogue that does not exist.

## Where the idiom decisions live

- **The object model + selector/name mapping** — **ADR-0055** is this target's idiom
  catalogue in substance: real ES6 classes mirroring the ObjC graph, the injective
  `:`→`_` selector-to-method-name map (ADR-0039 ported), protocols → `interface`, the
  POD-object/Swift-value-handle split for by-value types, TS `enum`s for `NS_ENUM`/
  `NS_OPTIONS`, `T | null` from nullability annotations.
- **Error-side-channel and nullable-result idioms** — **ADR-0058**: `NSError**` →
  `Result<T>`, `NSException` → thrown `NSExceptionError`, `nil`/`NO` failure returns keyed
  through the same `Result` channel as a Swift `throws`.
- **Callback/delegate/block idioms** — **ADR-0059**: a delegate protocol → a plain object
  literal implementing the matching `interface`; a completion block → a JS closure passed
  positionally; a dynamic subclass override → a real `class ... extends`.
- **The Apple-doc-shape → TypeScript-idiom translation table** (the racket
  `platform-docs-mapping.md` "Behaviours" section's analogue) is
  [`../bindings/node/docs/platform-docs-mapping.md`](../bindings/node/docs/platform-docs-mapping.md).

## The shared cross-target catalogue model

For the §21 category vocabulary and the `emit/pattern_dispatch` seam every target's idiom
mapping answers to (whether or not it has an authored `catalogue.apiw`), see the shared
[idiom-catalogue doc](../../_shared/docs/idiom-catalogue.md).

## A future retrofit

Should `typescript` ever join the `apianyware-target-model` §21 authoring layer (the way
the four Lisp targets have), the catalogue would live at `targets/typescript/idioms/` and
this page would become a thin pointer to `idioms/docs/idiom-map.md`, matching the other
four targets exactly. That retrofit is `structural-refactoring` grove scope, not this
grove's — not undertaken here.

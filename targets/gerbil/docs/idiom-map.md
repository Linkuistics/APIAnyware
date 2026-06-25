# gerbil — idiom map (§18)

> **The authoritative §21 idiom map lives at
> [`../idioms/docs/idiom-map.md`](../idioms/docs/idiom-map.md).**

This page is a pointer, not a second copy. The gerbil idiom map — the source-concept → Gerbil
construct mapping across all 25 §21 categories, plus the `pattern_dispatch` emit projections — is
the maintained render at [`../idioms/docs/idiom-map.md`](../idioms/docs/idiom-map.md), over the
authored catalogue [`../idioms/catalogue.apiw`](../idioms/catalogue.apiw).

The **gerbil flavour** in brief (the full table is in that render): owned resources are `defclass`
instances on the manifest object graph (ADR-0020) released by a will at GC; brackets expand to
`dynamic-wind` / `unwind-protect` via `defrules`; ObjC errors/exceptions surface as `(values result
error)` / `:std/error` objects (`try` / `with-catch`); delegates use transparent subclassing
(ADR-0020); and foreign-thread / main-thread-only calls **bounce** to the main thread (ADR-0022) —
the inverse of chez's thread activation.

For the catalogue **model** (the two axes — §21 category vs ws3 pattern-kind — and the
`emit/pattern_dispatch` seam shared across targets), see the shared
[idiom-catalogue doc](../../_shared/docs/idiom-catalogue.md).

The map is co-located under [`../idioms/`](../idioms/) — beside its authored subject — rather than
duplicated here; this `docs/idiom-map.md` exists only so a reader scanning the §18 target docs
finds the trail.

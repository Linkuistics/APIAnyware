# sbcl — idiom map (§18)

> **The authoritative §21 idiom map lives at
> [`../idioms/docs/idiom-map.md`](../idioms/docs/idiom-map.md).**

This page is a pointer, not a second copy. The sbcl idiom map — the source-concept → CLOS construct
mapping across all 25 §21 categories, plus the `pattern_dispatch` emit projections — is the
maintained render at [`../idioms/docs/idiom-map.md`](../idioms/docs/idiom-map.md), over the authored
catalogue [`../idioms/catalogue.apiw`](../idioms/catalogue.apiw).

The **sbcl flavour** in brief (the full table is in that render): owned resources are CLOS objects on
the `objc-class` metaclass graph (ADR-0034) finalized via `sb-ext:finalize` + a main-thread
release-queue drain (ADR-0036); brackets expand to `unwind-protect`; ObjC errors/exceptions surface
as the **`ns:objc-error` condition hierarchy** caught with `handler-case` (ADR-0037 — the CL-family
idiom, diverging from chez/gerbil's `(values result error)`); delegates use **subclass-IMP
synthesis** in `libAPIAnywareSbcl` (ADR-0038); struct-by-value is the CLOS **value-struct** surface
(ADR-0042); and foreign-thread / main-thread-only calls **bounce** to the main thread (ADR-0035).

For the catalogue **model** (the two axes — §21 category vs ws3 pattern-kind — and the
`emit/pattern_dispatch` seam shared across targets), see the shared
[idiom-catalogue doc](../../_shared/docs/idiom-catalogue.md).

The map is co-located under [`../idioms/`](../idioms/) — beside its authored subject — rather than
duplicated here; this `docs/idiom-map.md` exists only so a reader scanning the §18 target docs finds
the trail.

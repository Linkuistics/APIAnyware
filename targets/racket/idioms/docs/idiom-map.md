# racket — §21 idiom map

The authoritative §21 source-concept → target-construct mapping for the Racket CS binding
is [`../catalogue.apiw`](../catalogue.apiw) (25 categories). This page is the maintained
human rendering; for the catalogue model + the `pattern_dispatch` seam see the shared
[idiom-catalogue doc](../../../_shared/docs/idiom-catalogue.md).

**Racket flavour.** Owned resources are opaque structs released by a *will-executor* at GC;
brackets expand to `dynamic-wind`; ObjC errors/exceptions surface as `exn:fail`
(`with-handlers`); foreign-thread and main-thread-only calls **bounce** to the main thread
through the trampoline (ADR-0014); struct-by-value maps to `define-cstruct`.

## Emit dispatch projections

The catalogue's `projects` entries are the data the shared `emit/pattern_dispatch`
classifier reads. The eight emit-relevant ws3 pattern-kinds:

| §21 category | pattern-kind | `emit` construct | generated name |
|---|---|---|---|
| `bracketed-use` | `bracket` | `scoped-resource` | `with-bracket` |
| `bracketed-use` | `paired-state` | `scoped-guard` | `with-paired-state` |
| `builder` | `builder` | `builder-dsl` | `builder` |
| `builder` | `factory-cluster` | `smart-constructor` | `make-factory-cluster` |
| `subscription` | `observer` | `scoped-observer` | `with-observer` |
| `subscription` | `subscription` | `scoped-observer` | `with-subscription` |
| `array-slice-view` | `enumeration` | `iteration-adapter` | `enumeration-sequence` |
| `error-side-channel` | `error-out` | `result-wrapper` | `error-out` |

The other 17 §21 categories are documentation-only (no emit projection). Kinds no idiom
projects (structural relationships, class-level `delegate` / `target-action`) pass through.
The generated names are notional pending the deferred *apply-projection* follow-on
(generation is golden-neutral today — `classify_pattern` has zero callers).

# gerbil — §21 idiom map

The authoritative §21 source-concept → target-construct mapping for the Gerbil Scheme
binding is [`../catalogue.apiw`](../catalogue.apiw) (25 categories). This page is the
maintained human rendering; for the catalogue model + the `pattern_dispatch` seam see the
shared [idiom-catalogue doc](../../../_shared/docs/idiom-catalogue.md).

**Gerbil flavour.** Owned resources are `defclass` instances on the manifest object graph
(ADR-0020) released by a finalizer at GC; brackets expand to `dynamic-wind`/`unwind-protect`
via `defrules`; ObjC errors/exceptions surface as `:std/error` objects (`try`/`with-catch`);
delegates use transparent subclassing (ADR-0020); foreign-thread and main-thread-only calls
**bounce** to the main thread (ADR-0022).

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

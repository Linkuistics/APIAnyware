# Gerbil object model: opt-in `:std/generic` veneer over a procedural core

**Status:** superseded by ADR-0020

> Superseded 2026-06-03 while building leaf 040/020. The single-`objc-obj`
> handle makes receiver-only generic dispatch **vacuous** (one type ⇒ nothing to
> dispatch on), collapsing gerbil into "chez with different syntax", and a
> wrapper-only model cannot **extend** the frameworks (subclass + override). See
> ADR-0020 (manifest class hierarchy · dual dispatch surface · transparent
> subclassing) and FINDINGS §7. The dispatch-cost measurements below remain valid
> and still inform the fast-path layering.

The `gerbil` target exposes its bindings as a **procedural core** — a single
`(defstruct objc-obj (ptr))` handle plus plain procedures keyed per class — with
an **opt-in OO veneer of `:std/generic` generic functions** layered over it. The
veneer dispatches on the one `objc-obj` handle struct; it does **not** mirror the
ObjC class graph with a `defclass`/`defmethod` hierarchy. Settles Q2 (the object
model fork 010-plan deferred to the 020 spike).

## Context — measured

`docs/research/2026-06-03-gerbil-ffi-dispatch-spike/FINDINGS.md` §3 and §3b,
`-[NSString length]`, 30M calls, bottled-gerbil `-O`:

| layer | ns/call | tax over proc core |
|---|---|---|
| raw FFI (raw `id` ptr) | 10.9 | — |
| **procedural core** (handle struct + plain proc) | **16.3** | — |
| **`:std/generic` veneer** | **29.4** | **+13.1 ns** |
| built-in `{}` veneer | 42.8 | +26.5 ns |

A *pure* native-OO foundation taxes every call ~4× the raw FFI; so OO must be the
**veneer, not the foundation**. Between veneer mechanisms, `:std/generic` is ~31%
cheaper than Gerbil's built-in `{}` (it has arity-specialised dispatchers
`generic-dispatch1..4` keyed on the type descriptor; `{}` does a MOP method-table
lookup by type+name each call), halving the opt-in tax over the proc core.

## Decision

- **Procedural core is the hot path:** plain procedures over a single `objc-obj`
  handle struct (namespaces of procedures keyed per class — the existing
  `objc-object` convention, CONTEXT.md, not a record hierarchy). Tight loops call
  procs directly at 16.3 ns.
- **OO veneer is opt-in `:std/generic`:** `(defgeneric length)` /
  `(defmethod (length (o objc-obj)) ...)`, called `(length o)`. Ergonomic sites
  pay 29.4 ns; the `:std/generic` form supports next-method/multimethods.
- **Single handle struct, no class graph:** all wrapped objects are `objc-obj`;
  the ObjC class hierarchy is not reified as Gerbil types. ObjC selector dispatch
  is already dynamic in the libobjc runtime, so a Scheme class graph would buy
  nothing and cost per-framework type-graph maintenance.

## Consequences

- **Every emitted class file is procedure namespaces + opt-in generic methods**,
  not a `defclass` tree. Hard to reverse: the shape is baked into all generated
  bindings and sample apps.
- **`:std/generic` is a binding dependency** (compiled into the binding library).
  Cheap and stdlib; acceptable.
- **The veneer's per-call tax is negligible for event-driven UI code** (no 30M-call
  loops); the layering lets a programmer drop to the proc core where it bites. The
  built-in `{}` mechanism is rejected purely on the measured cost; this divergence
  from a "use the built-in object system" default is the record's point.
- Knowledge: `knowledge/targets/gerbil.md` documents both layers and when to drop
  down.

# 020-emit-class — brief

## Object-model pivot (re-grilled in-session, 2026-06-03 — ADR-0020)

The original decomposition (010-dispatch-proc-core + 020-veneer-and-errors) was
built on ADR-0018's **single `objc-obj` handle + opt-in `:std/generic` veneer**.
Building leaf 020 surfaced that this is **vacuous**: with every wrapped object the
same `objc-obj` type, receiver-only generic dispatch has nothing to dispatch on,
and a wrapper-only model can never **extend** the frameworks (subclass + override
a method the run loop invokes). That collapses gerbil into "chez with different
syntax" and defeats the three-Scheme paradigm experiment.

Re-grilled with the user → **ADR-0020** (supersedes ADR-0018), spike-validated by
`07-dual-surface.ss` (FINDINGS §7). New object model:

1. **Manifest the full ObjC class graph** as a `defclass` hierarchy (full ancestor
   chain, incl. unbound intermediates — matches Apple docs; `NSObject` = runtime
   root; each class defined once in its owning framework's module).
2. **Both dispatch surfaces over it**, sharing identifiers: built-in `{sel obj}`
   MOP *and* `:std/generic` `(sel obj)`, both forwarding to an inlinable
   per-class **proc core** that bottoms out in leaf-010's `%msg-…` crossings.
3. **Transparent extensible subclassing:** `(defclass (MyView NSView) …)` +
   overrides synthesizes a real ObjC subclass (runtime, node 050). The emitter
   side here just emits each `defclass` with its ObjC class name + parent so the
   runtime synthesis bridge + wrap registry have what they need.
4. **Error model** `(values result error)` unchanged (ADR-0006), layered on the
   procs (so both surfaces inherit it).

**What survives from 010 (done):** the per-signature `%msg-…` `define-c-lambda`
crossings, selector caches, signature dedup, `begin-ffi`/geometry decls,
`method_filter`, the class-plan/dedup machinery. **What 010 built that gets
rewritten:** the single-`objc-obj` proc/constructor/property *surface* over the
opaque handle — re-targeted onto the typed `defclass` graph.

## New decomposition (live leaves)

- **030-manifest-class-graph** — emit the `defclass` hierarchy: build the type
  graph from bound classes ∪ their full ancestor chains; emit each class once in
  its owning framework module (`(defclass (<Class> <Super>) …)`, root carries the
  `ptr` slot); bare nodes for unbound intermediates; cross-framework parent ⇒
  import; the class-name↔Gerbil-type **registry** the wrap boundary uses; each
  class carries its ObjC name (registry + runtime subclassing). The structural
  foundation the surfaces hang on.
- **040-consumption-surfaces** — over the graph: the inlinable **proc core**
  (one impl per method) + **both** surfaces (`{sel self}` built-in and
  `(sel (o <Class>))` `:std/generic`, shared identifiers, the `g:defmethod`
  rename), constructors (return typed instances), properties (getter/setter on
  both surfaces). Export + facade wiring.
- **050-error-model** — `(values result error)` for trailing-`NSError**` methods:
  `method_filter` change + the in-Gerbil out-param crossing + the `nserror`
  runtime contract (inbox-noted to node 050). Carries the detailed contract
  worked out in the retired `020-veneer-and-errors` leaf.

## Goal (node)

`emit_class.rs` emits one Gerbil `.ss` module per ObjC class: the class's slice of
the manifest `defclass` graph, the proc core + dual consumption surfaces over it,
constructors, properties, and `(values result error)` for fallible methods —
wired into `emit_framework`. The node Done-when is the union of the three live
leaves' Done-whens.

## Context

Design spec §3/§3a/§4; **ADR-0020** (object model — primary), ADR-0017 (dispatch +
native core), ADR-0019 (lifetime), ADR-0006 (errors). FINDINGS §7 (dual-surface
spike). Reference: `emit-chez/src/emit_class.rs` (class-plan/dedup machinery is
target-neutral) and racket's `dynamic-class.rkt` / `define-objc-subclass` (the
subclassing prior art the runtime mirrors). Foundation from leaf 010.

## Notes

Each leaf wires its output into `emit_framework` so the crate compiles + tests
green at every commit. Names the runtime (node 050) owns — `defclass` root +
`ptr` accessor, `wrap` (now class-aware), the class registry, `nserror`, the
synthesis bridge — are settled there; where a leaf needs an unsettled name, pick
the obvious one, emit against it, and **inbox-add to 050**.

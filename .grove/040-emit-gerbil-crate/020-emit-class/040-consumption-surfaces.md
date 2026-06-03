# 040-consumption-surfaces

**Kind:** work

## Goal

Over the manifest `defclass` graph (030), emit the **proc core + both consumption
surfaces + constructors + properties** — the methods a binding user *calls*
(ADR-0020). Builds on leaf 010's `%msg-…` crossings, re-targeted onto typed
receivers.

## Done when

- **Inlinable proc core:** one class-prefixed proc per supported method
  (`nsstring-length`), the single implementation, declared **inlinable** so the
  surface forwarders compile away and hot call sites approach the raw crossing.
  Receiver is the typed `defclass` instance (`(<root>-ptr self)` for the pointer).
  Object returns wrapped through the registry-aware `wrap` (030); `id` args
  coerced via the runtime's `->ptr` (an instance → its `ptr`, `#f` → null).
- **Surface 1 — built-in MOP:** `(defmethod {<sel> self} …)` over the class type,
  forwarding to the proc; called `{<sel> obj}`. Inherits down the graph.
- **Surface 2 — `:std/generic`:** `(defmethod (<sel> (o <Class>)) …)` forwarding
  to the proc; called `(<sel> obj)`. Uses the `(rename-in :std/generic
  (defgeneric g:defgeneric) (defmethod g:defmethod))` import to avoid the built-in
  `defmethod` clash (spike `03b`). **Same identifier** as surface 1 — spike
  `07-dual-surface.ss` proved no collision.
- **Constructors:** explicit `initX:` → `make-<class>-…` returning a **typed
  instance**; synthesize a default `make-<class>` (alloc+init) when no explicit
  initializer. Honour `returns_retained` / init-family ownership.
- **Properties:** getter + `…-set-x!` setter on **both** surfaces; skip
  unsupported struct-valued properties (`method_filter`).
- **Naming/dedup:** the generic name scheme is the **bare kebab selector** (the
  manifest hierarchy makes it sound — methods specialize on the real class type,
  not one shared handle, so distinct classes' same-named selectors are distinct
  methods on distinct types). Reuse 010's `collect_exports` /
  `dedupe_across_categories`; export the proc names + the surface generics.
- Wired into `emit_framework` + facade; crate compiles; tests cover: a method
  emits proc + `{}` + generic over the right class type; inheritance dispatches to
  an ancestor's method; a struct-returning method; an object return wrapped to the
  exact type; default + explicit constructor returning typed instances; a property
  getter/setter on both surfaces.

## Context

ADR-0020 (dual surface + proc fast path), FINDINGS §3/§3b (dispatch costs), §7
(dual-surface). Foundation: 010 (`%msg-…`, selector caches, signature naming),
030 (the `defclass` graph + registry). Inbox-note node 050 for the typed-`wrap`,
`->ptr`, and any generic-machinery names.

## Notes

Decide whether to emit both surfaces for *every* method (simplest, DRY via the
proc) or gate the built-in `{}` surface behind a flag (it's the slower one). Lean
"both always" unless emission volume bites — the proc is the shared body so the
marginal cost is two thin forwarders. The safe-vs-unsafe accessor perf lever
(FINDINGS Fork 3) lands here or in the runtime — default safe + inlinable.

# Gerbil object model: manifest ObjC class hierarchy, dual dispatch surface, transparent extensible subclassing

The `gerbil` target reifies the **full ObjC class graph as a Gerbil `defclass`
hierarchy** and exposes **both** of Gerbil's dispatch surfaces over it — the
built-in `{sel obj}` MOP *and* `:std/generic` `(sel obj)` generic functions —
both forwarding to an inlinable per-class **proc core** that bottoms out in the
per-signature `define-c-lambda` `%msg-…` crossings (ADR-0017). Crucially, user
**subclassing is transparent and first-class**: deriving `(defclass (MyView
NSView) …)` with override methods synthesizes a *real* ObjC subclass at runtime
(`objc_allocateClassPair` + IMP trampolines + `objc_registerClassPair`), so the
macOS frameworks dispatch their callbacks into the user's Gerbil methods.
*Deriving in Gerbil = deriving in ObjC.*

## Why a manifest hierarchy, not a single-handle veneer

The obvious cheaper alternative — a *single* `(defstruct objc-obj (ptr))` handle
with an opt-in `:std/generic` veneer and **no class graph** — is rejected for two
reasons that make the manifest hierarchy load-bearing:

1. **Receiver-only generic dispatch over one type is vacuous.** With every
   wrapped object the same `objc-obj` type, `(length o)` can only ever resolve to
   one method body regardless of what `o` is — the "veneer" cannot dispatch.
   Strip it and what remains (proc namespaces over an opaque handle) is *chez
   with different syntax*, defeating the reason gerbil exists as a third Scheme:
   to explore the OO/generic paradigm against the macOS APIs (racket = dynamic
   `tell`; chez = procedural; gerbil = OO/generics).
2. **A wrapper-only hierarchy cannot extend the frameworks.** It lets you *call*
   framework methods but never *override* them — a Gerbil subtype is invisible to
   AppKit, so the run loop never invokes your method. The value of native OO in
   Cocoa **is** extension (custom `NSView`/`drawRect:`, controllers), which
   requires synthesizing a real ObjC class. A manifest hierarchy is therefore
   *required* for either dispatch surface to be meaningful, and extension is
   central, not out-of-scope.

The dispatch-cost measurements behind the fast-path layering (proc core 16.3 ns,
`:std/generic` veneer 29.4 ns, built-in `{}` 42.8 ns) live in
`targets/gerbil/docs/research/2026-06-03-gerbil-ffi-dispatch-spike/FINDINGS.md`;
the inlinable proc core remains the fast path both surfaces forward to.

## Decision

- **Manifest hierarchy (full chain).** Reify the *complete* ObjC ancestor chain
  as `defclass`es — `NSButton : NSControl : NSView : NSResponder : NSObject` —
  including intermediate classes we bind no methods of (bare `defclass` nodes
  carrying only the inheritance link). Matching Apple's documented graph is a
  *user-facing* requirement: omitting intermediates would diverge from every
  Apple/third-party doc for a shortcut benefiting only our emitter. Each class is
  defined **once**, by its owning framework's module; `NSObject` is the single
  runtime-owned root (holding the `ptr` slot + the ADR-0019 lifetime will).
  Cross-framework ancestry becomes a cross-module import.
- **Two consumption surfaces, shared identifiers.** Emit both `(defmethod {length
  self} …)` (built-in MOP) and `(defmethod (length (o NSString)) …)`
  (`:std/generic`) over the same graph; spike `07-dual-surface.ss` proved the
  *same identifier* serves both with distinct bodies and no collision (`{}`
  dispatches by method-table symbol; the generic is a top-level binding).
- **Inlinable proc-core substrate.** One class-prefixed proc per method
  (`nsstring-length`) is the single implementation both surfaces forward to —
  DRY, and the designated fast path (declared inlinable so forwarding compiles
  away). Advanced code can drop to the proc, or to the raw `%msg-…` crossing.
- **Transparent extensible subclassing.** The binding library re-exports
  `defclass`/`defmethod` forms that **shadow** Gerbil's built-ins: when the
  superclass is an ObjC-backed bound class they synthesize the real ObjC subclass
  and install IMP trampolines routing framework selectors into the user's Gerbil
  override methods (on either surface); for ordinary classes they fall through to
  the built-ins. The emitter emits the metadata IMP-signature inference needs
  (superclass ObjC type encodings); the runtime owns the libobjc synthesis bridge
  (the gerbil analogue of racket's `dynamic-class.rkt` / `define-objc-subclass`,
  proven in the drawing-canvas app). OO is the natural **extension** surface;
  generics the natural **consumption** surface — the asymmetry is a deliberate
  experimental result.
- **Wrap boundary.** A returned `id` is wrapped as its exact Gerbil type via
  `object_getClass` → a class-name↔type registry; the full chain means an exact
  bound type is usually present, with a fallback walking the ObjC superclass
  chain to the nearest bound ancestor.

## Consequences

- **Dynamic-class synthesis + IMP trampolines move from a deferred §6 native-core
  item (ADR-0017) to the *center* of the object model** — it is what the model is
  *for*. 050 (runtime) must carry the libobjc synthesis bridge as core; 040
  (emitter) must emit a *subclassable* `defclass` graph + class registry + type
  encodings.
- **Cost moves to the wrap boundary:** every object-returning crossing pays an
  `object_getClass` + registry lookup. Accepted — the gerbil target maximises
  native idiom (and the proc/raw-crossing fast paths remain for hot loops).
- **Shadowing core forms (`defclass`/`defmethod`) is surprising** and must
  fall through cleanly for non-ObjC classes; the `class_addMethod`-after-
  `objc_registerClassPair` ordering (racket registers all methods before
  finalizing; separate top-level `defmethod`s may force lazy or post-registration
  method-add) is a runtime wrinkle 050 must settle.
- **Hard to reverse:** the hierarchy + dual surface + subclassing shape is baked
  into every generated binding and every sample app. `targets/gerbil/docs/reference.md`
  documents both surfaces, the fast-path layering, and the transparent-subclass
  idiom.
- The FFI crossings + selector caches are the proc core's; the object *surface*
  over them is the manifest `defclass` graph, not a single `objc-obj` handle.

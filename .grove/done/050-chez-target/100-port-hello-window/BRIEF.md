# 100-port-hello-window — brief

## Goal
Get the chez `hello-window` sample app to the same bar as racket's:
compiles, bundles into a runnable `.app`, draws its window with the
centred label, accepts the close button, exits cleanly, and passes
TestAnyware in the VM. End-to-end pipeline validation for the chez
target's first app.

## Why decomposed
The original `100-port-hello-window.md` (now this node's
`030-port-hello-window-app.md`) treated this as a single work leaf.
First-cut investigation surfaced two distinct, independently-shippable
concerns that don't compress into one focused commit:

1. **Emitter gap — struct-by-value params/returns.** The hello-window
   app needs `make-nswindow-init-with-content-rect-style-mask-backing-defer`
   and `make-nstextfield-init-with-frame`, which take `NSRect` by value.
   The emit-chez method filter was deferring all struct-by-value as a
   scaffold-era simplification (comment in `method_filter.rs` cited "the
   080 follow-up", which retired without addressing it). The runtime
   already defines the geometry ftypes and the mapper already produces
   `(& NSRect)`, so the gap is purely the filter. Leaf `010` lifts it
   for known-geometry aliases (NSPoint/NSSize/NSRect/NSRange/
   NSEdgeInsets and their CG twins) and regenerates the chez tree.
2. **Library-loading design gap.** Chez's default library-name
   resolution maps `(apianyware runtime objc)` to
   `<root>/apianyware/runtime/objc.sls`, but the chez source tree
   layout (and the bundle layout in design spec §8) places these at
   `<root>/runtime/objc.sls` and `<root>/generated/<fw>/<cls>.sls`.
   Neither unbundled `chez --script` nor the bundled
   `Resources/chez-app/` layout will resolve the imports as-is. The
   design spec is silent on how loading reconciles. Leaf `020` is a
   planning task that grills the options (rearrange source tree to
   `apianyware/{runtime,<fw>}/...`, install a custom
   `library-search-handler` in a bootstrap, symlink farm at bundle
   time, etc.) and records the decision as an ADR if it qualifies.

Leaf `030` is then the actual port + TestAnyware validation, taking
both prior decisions as inputs.

## Done when
- All three child leaves retire.
- The bar from the original task is met: chez `hello-window` builds,
  bundles, launches, draws the window with the centred label, accepts
  the close button, exits cleanly. Activity Monitor shows no
  unbounded memory growth.
- TestAnyware run is green for chez `hello-window` (same bar as
  racket's).

## Decomposition
- `010-emit-struct-by-value-params.md` — work. Extend emit-chez method
  filter to support known-geometry struct-by-value; regenerate.
- `020-chez-library-loading.md` — planning. Settle how the chez target
  resolves `(apianyware ...)` imports unbundled and bundled. May
  produce an ADR. May land code/source-tree changes itself or seed a
  further work leaf — that's the planner's call.
- `030-port-hello-window-app.md` — work. Write the app, bundle it.
  Two emit-chez bugs surfaced and were fixed-at-source during this
  leaf (framework facade location, framework dylib loading at class
  instantiation); regenerated at scale.
- `040-testanyware-verify.md` — work. VM verification via TestAnyware
  is its own leaf per the project-wide policy
  [[feedback-vm-verify-every-app]]. The 030 leaf can demonstrate the
  app reaches `[NSApp run]`; only this leaf can demonstrate the window
  draws correctly.

## Pointers
- Parent: `.grove/050-chez-target/BRIEF.md` (10 inherited decisions).
- Design spec: `docs/specs/2026-05-27-chez-target-design.md` (§3 emitted
  class form, §7 feature ladder, §8 bundle layout).
- Runtime: `generation/targets/chez/apianyware/runtime/types.sls` already exports
  `make-nsrect` / `make-nspoint` / etc. as ftype-pointers; no runtime
  work needed for the struct-by-value leaf.
- Reference: `generation/targets/racket/apps/hello-window/hello-window.rkt`
  for layout symmetry (window 400×200, label "Hello, macOS!", system
  font 24pt, title "Hello from {Language}" per
  `knowledge/apps/hello-window/spec.md`).

## Notes
- The 010 leaf widens method-filter for the **geometry** aliases only.
  Arbitrary structs stay blocked (no ftype defined for them in the
  runtime). Block-typed params remain blocked too — those belong to
  the 130 leaf.
- The 020 planning leaf is the gating decision; expect that it may
  itself decompose if the chosen approach is non-trivial.

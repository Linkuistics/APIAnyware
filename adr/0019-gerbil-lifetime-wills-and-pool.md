# Gerbil `objc-obj` lifetime = Gambit wills + entry-point autoreleasepool

Each wrapped ObjC `id` becomes an `objc-obj` whose Scheme wrapper registers a
**Gambit `will`** (`make-will testator action`) that sends ObjC `release` when the
wrapper becomes collectable. The app `main` and every ObjC-side entry point
(delegate methods, callback trampolines, event handlers) **wrap their body in an
`@autoreleasepool`**. This is the Gambit-idiomatic analogue of chez **ADR-0007**
(which used a Chez guardian — a primitive Gambit does not provide).

Two mechanisms intentionally combined, exactly as ADR-0007:

- **Wills** own *retained* objects whose lifetime is bounded by the Scheme
  wrapper's reachability — the will's action converts a Gambit GC event into an
  ObjC `release`.
- **The entry-point `@autoreleasepool`** owns *autoreleased* (`+0`) transients;
  they drain at the pool boundary and never reach a will, which is what `+0` calls
  for.

## Considered options

- **Wills + entry-point pool (chosen).** Wills are *the* idiomatic Gambit
  finalization mechanism (ADR-0005 idiom posture); the entry-point pool handles
  the `+0` working-set concern.
- **A will-fed drain queue emulating chez's guardian.** Rejected: reproduces a
  batched-drain primitive Gambit lacks, for release-*timing* control the use case
  does not need.
- **Chez's objection to per-instance finalizers** (unpredictable GC-ordered
  release, which drove ADR-0007 to a guardian) **is benign here:** ObjC `release`
  ordering among independently-retained objects does not affect correctness, and
  the entry-point pool already covers the transient working-set inflation that was
  the real concern. So the racket-style finalizer objection that mattered for chez
  does not apply to the gerbil will model.

## Consequences

- The gerbil `runtime/objc` cluster owns will registration at `wrap` (the class-
  aware wrap boundary — the emitter's actual spelling, not chez's `wrap-objc-obj`) and
  the `with-autorelease-pool` entry-point macro. Load-bearing: bugs surface as
  use-after-free or unbounded Activity-Monitor growth (same failure signature as
  the chez guardian).
- **Hard to reverse:** every entry point in every sample app, every delegate
  method, and every callback trampoline inherits the pool-wrap from the runtime
  macros. Sample-app authors writing loops *outside* the run-loop's entry-point
  wrapping must wrap them in `with-autorelease-pool` themselves (the same rule
  Cocoa imposes on ObjC command-line tools) — documented in
  `targets/gerbil/docs/reference.md`.
- **Threading interaction is deferred:** whether wills/pools fire correctly on
  foreign OS threads entering Gambit depends on Gambit's green-thread model and is
  resolved by the spike-gated threading leaf (cf. chez ADR-0016's per-thread pool
  + guardian-mutex interaction). This ADR covers the single-threaded / main-thread
  model; the threading leaf extends it.

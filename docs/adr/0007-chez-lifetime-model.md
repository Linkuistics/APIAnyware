# Chez `objc-object` lifetime = guardian + entry-point autoreleasepool

Each wrapped ObjC `id` becomes an `objc-object` record registered with a
**Chez guardian** at creation time. The application's main loop and every
ObjC-side entry point (delegate methods, `foreign-callable` callbacks,
event handlers, app `main`) **wrap their body in an `@autoreleasepool`**.
A guardian-drain pass after each pool pop sends `release` to any
`objc-object` whose Scheme wrapper has been collected since the previous
drain.

Two mechanisms intentionally combined:

- **The guardian** owns *retained* objects whose lifetime is bounded by
  the Scheme wrapper's reachability. The drain pass converts Scheme GC
  events into ObjC `release` calls.
- **The outer `@autoreleasepool`** owns *autoreleased* objects — transient
  objects ObjC returns at `+0` ownership. They drain at the pool boundary
  without ever reaching the guardian, which is what `+0` calls for.

## Considered options

- **Guardian only.** Rejected: autoreleased return values would still be
  retained by `wrap-objc-object` (to balance the +0 → +1 conversion),
  inflating the guardian's working set across every method call. The
  pool boundary lets us skip the retain for genuinely-short-lived
  objects.
- **Per-instance finalizers (the racket model).** Rejected for chez:
  Chez doesn't provide per-object finalizers directly — guardians are
  the idiomatic mechanism — and the racket finalizer model produces
  unpredictable release order under GC pressure. Guardians put release
  ordering under Scheme's explicit control (drain timing).
- **Autoreleasepool only, no guardian.** Rejected: leaks every object
  whose ownership outlives an entry point's autoreleasepool scope
  (windows, models, anything reachable beyond a single event tick). A
  GUI app's working set has many such objects.

## Consequences

- The `runtime/objc` cluster owns one `objc-guardian` parameter and a
  `(drain-objc-guardian)` procedure called at every pool-pop. This
  is the load-bearing piece of the chez runtime; bugs here surface as
  use-after-free or as Activity Monitor showing unbounded growth.
- Sample-app authors who write loops outside the run-loop's
  entry-point wrapping (e.g. an offline data-prep script) must wrap their
  loop in `(with-autorelease-pool ...)` themselves, otherwise transient
  autoreleased objects accumulate until the process exits. This is the
  same rule Cocoa imposes on Objective-C command-line tools and is
  called out in `knowledge/targets/chez.md`.
- Hard to reverse: every entry point in every sample app, every
  delegate method, and every block callback inherits the pool-wrap
  convention from the runtime macros. Changing the model later
  requires editing every emitted protocol method's trampoline and every
  app's `main`.
- The combination is **surprising**: a reader who knows guardians might
  wonder why autoreleasepools are in the mix at all, and vice-versa.
  This ADR is the answer.

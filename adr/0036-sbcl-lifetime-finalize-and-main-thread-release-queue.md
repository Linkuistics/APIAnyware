# SBCL `ns:ns-object` lifetime = `sb-ext:finalize` + main-thread release queue + entry-point pool

Decides the **sbcl** target's lifetime model for wrapped ObjC `id`s. The SBCL realization of the
two-mechanism model established by chez **ADR-0007** (guardian + entry-point pool)
and gerbil **ADR-0019** (Gambit will + entry-point pool), with one SBCL-specific
twist neither precedent faced: **finalizers run off the main thread.**

## The twist — verified first-hand

SBCL's idiomatic finalizer, `sb-ext:finalize`, runs its callbacks on a **dedicated
`"finalizer"` thread** (confirmed on SBCL 2.6.5: a finalizer observed
`(thread-name *current-thread*) => "finalizer"`, not `"main thread"`). So a
finalizer-driven ObjC `release` fires **off-main**. An off-main *final* `release`
that triggers `dealloc` of an **AppKit object** (NSWindow, NSView, …) is undefined
behaviour — and all 7 sample apps are GUI apps. This is a **UI-affinity** problem,
**not** a GC-safety one: the finalizer thread is SBCL-native and therefore
suspendable for stop-the-world GC (contrast ADR-0035, where *foreign* threads are
the hazard). Neither precedent hit this — chez's guardian is already drained on
main, and gerbil's wills fire on the single-VM main thread.

## Decision

The runtime-owned root `ns:ns-object` carries the foreign `ptr`. Two mechanisms,
intentionally combined (the chez/gerbil shape):

- **Retained objects** (lifetime bounded by the Lisp wrapper's reachability):
  **`sb-ext:finalize`** is the death trigger. It is chosen as the idiomatic SBCL
  finalizer *and* because, like chez's guardian, GC hands it **exactly the dead
  objects** — it is O(dead), not O(live). The finalizer closure captures **only the
  raw `id`** (a SAP/integer copy), never the wrapper — or the wrapper would never
  become collectable. The finalizer does **not** call `release` directly; it
  **enqueues** the raw `id` onto a release queue. A **main-thread drain** sends
  `release` to every queued `id`, so each `release`/`dealloc` happens UI-safely on
  the main thread. The drain runs at the **entry-point autoreleasepool boundary**
  (every main-thread entry: run-loop event handlers, callbacks bounced to main per
  ADR-0035, app `main`), exactly as chez drains its guardian at every pool pop.

- **Autoreleased (+0) transients** (objects ObjC returns at +0 ownership): the
  **entry-point `@autoreleasepool`** owns them; they drain at the pool boundary
  without ever reaching a finalizer, which is what +0 calls for. The pool boundary
  **doubles as the release-queue drain point** above.

## Considered options

- **`sb-ext:finalize` + main-thread release queue (chosen).** Idiomatic finalizer,
  O(dead) like chez's guardian, and UI-safe via the main-thread drain.
- **Weak-pointer registry + main-thread scavenger.** Rejected: stays fully on-main
  (no finalizer thread) and is the exact chez-guardian shape, but a registry scan is
  **O(live) per drain** — it loses the O(dead) efficiency that makes chez's guardian
  (and `sb-ext:finalize`) cheap. SBCL's GC already computes "which objects died";
  re-deriving it by scanning live weak pointers is wasteful at GUI-app scale.
- **Direct `release` from the finalizer thread.** Rejected: simplest, and ObjC
  retain/release is atomic-thread-safe, but an off-main final `dealloc` of an AppKit
  object is UB. Unsafe for the GUI sample apps.

## Consequences

- The sbcl runtime `objc` cluster owns the wrap-boundary `sb-ext:finalize`
  registration, the release queue, and the `with-autorelease-pool` entry-point
  macro that drains it. Load-bearing: bugs surface as use-after-free or unbounded
  Activity-Monitor growth (same failure signature as the chez guardian / gerbil
  will). Implemented in the runtime.
- **The entry-point-pool convention generalizes to the CL family — as a user
  obligation, not shared code.** Per ADR-0033 C1 (observable behaviour normative,
  mechanism private), the *obligation* (sample-app authors wrapping non-runloop
  loops in `with-autorelease-pool` themselves, the same rule Cocoa imposes on ObjC
  command-line tools) is family-level observable behaviour; the *mechanism*
  (`sb-ext:finalize` + queue) stays SBCL-private. The glossary's
  *Entry-point autoreleasepool* term is widened accordingly from chez-specific to a
  family convention with per-impl realization.
- **No per-thread pool/guardian-mutex dance** (contrast chez ADR-0016): because
  ADR-0035 bounces all foreign callbacks to main, Lisp only ever runs on main or on
  SBCL-native `sb-thread`s; the release queue is drained on main. The finalizer
  thread only *enqueues* (a cheap, lock-guarded push), never releases — so the
  cross-thread surface is one small queue, not a concurrent guardian.
- **Hard to reverse:** every entry point in every sample app and every wrapped
  object inherits the pool-wrap + finalize convention from the runtime macros.
- Target-local under **ADR-0011**. Verified premise: the finalizer-thread fact
  (this ADR's "twist"); full mechanism verified by a background-release smoke test.

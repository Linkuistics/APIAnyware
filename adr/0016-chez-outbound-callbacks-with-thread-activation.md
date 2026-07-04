# Chez callbacks are outbound, with `Sactivate_thread` for background threads

Extends **ADR-0007** (chez lifetime model) and mirrors racket's **ADR-0014**
(outbound callbacks over native trampolines), with a chez-specific divergence the
spike (`targets/chez/docs/research/2026-06-02-chez-dispatch-spike/`, `FINDINGS.md` §C) made
concrete. **Decision:** keep the callback path *outbound* — `foreign-procedure`
out; `foreign-callable` trampolines for callback creation registered behind the
native Swift bridges (`DelegateBridge`/`BlockBridge`) with GC pinning; **reject**
the inbound direction (Swift linking Chez's C-embedding API to drive Scheme
directly — larger surface, same foreign-thread problem one level down, no evidence
needed). The divergence from racket: a Chez `foreign-callable` entered from any
Scheme-unregistered OS thread **crashes hard** (confirmed on a raw pthread *and* a
real `dispatch_async` GCD worker), but because the Homebrew Chez is a **threaded**
build, wrapping the callback body in `Sactivate_thread()`/`Sdeactivate_thread()`
makes a foreign thread safe to enter Scheme (both survive when activated) — a fix
racket's ffi2 callbacks do not have. The native trampolines and `dispatch.sls`
`foreign-callable` wrappers therefore **`Sactivate_thread`-wrap their entry into
Scheme**, so background callbacks (NSURLSession completions, `dispatch_async`
compute) are safe *without* a main-thread bounce.

## Consequences

- **The main-thread bounce (`cocoa.sls` `dispatch_async_f`) becomes a *UI*
  requirement, not a Chez-safety requirement** — UI mutation must be on the main
  thread (AppKit), but non-UI background callbacks may run on their worker thread
  once activated. This is richer than racket's bounce-always model.
- **`Sactivate_thread` bookkeeping is load-bearing** — its `int` disposition
  distinguishes reactivation from a genuinely new thread context; new contexts may
  need `Sdestroy_thread` (not just `Sdeactivate_thread`) to avoid leaking thread
  contexts across many short-lived worker callbacks. Bugs here surface as leaks or
  use-after-free, like the ADR-0007 guardian.
- **Per-thread autoreleasepool vs process-wide guardian:** an activated background
  callback must push its own `@autoreleasepool` (per ADR-0007's entry-point
  convention) and must not assume the main thread's guardian-drain timing. The
  trampoline wrapper owns this.
- **Latent-crash fix, not a speedup.** The current runtime bounces everything to
  main, which works for today's UI sample apps; this ADR fixes the latent crash
  for the first sample app that takes a genuinely background callback.

## Implementation

The activation is **not** hand-written `Sactivate_thread`/`Sdestroy_thread`
bookkeeping in the native trampolines. Chez Scheme's `foreign-callable`
`__collect_safe` convention (since 9.5.1; we run 10.4.1) does exactly the
required dance in the callable's generated **C prologue** — which runs *before*
any Scheme heap access, the precise point the crash occurred: it activates the
caller on entry, reverts on exit, and **`Sdestroy_thread`s a thread context it
had to create from scratch** (so transient GCD workers don't leak contexts)
while merely reverting for already-registered threads (the main thread after
`main`, Scheme `fork-thread`s). This resolves the "`int` disposition bookkeeping"
open item *for free* — Chez owns it.

- **One point covers all three bridges.** Block invokes and dynamic-class IMPs
  *are* the `foreign-callable` entry pointer; the delegate Swift trampoline
  *calls* it. All three are built by `dispatch.sls`'s single `build-callable`, so
  marking that one form `__collect_safe` makes every callback path thread-safe —
  **no Swift edits were needed**, contrary to the design spec's expectation that
  the native trampolines would gain activation code.
- **The outbound dual — blocking foreign calls must also be `__collect_safe`.**
  GC in threaded Chez is stop-the-world: it can't run until every *active* Scheme
  thread parks at a safe point. A *blocking* outbound call on a Scheme thread
  (`dispatch_semaphore_wait`, `dispatch_sync`, a synchronous `pthread_join`, a
  blocking network wait) keeps that thread active but stuck in C, never reaching
  a safe point. If a freshly-activated background callback then allocates and
  triggers GC, the collector waits on the blocked thread **forever** — deadlock.
  The fix is `__collect_safe` on the blocking *`foreign-procedure`* too: it
  *deactivates* the caller for the call's duration so GC proceeds without it.
  Inbound callables activate; outbound blocking procedures deactivate. Sample
  apps that pair a synchronous wait with background callbacks must observe this.
- **Guardian thread-safety (the ADR-0007 interaction).** With background
  callbacks real, the process-wide `objc-guardian` is now registered-to
  (`wrap-objc-object`) and polled (`drain-objc-guardian`) from worker threads
  concurrently with the main thread. Register and poll are destructive operations
  on the *same* guardian object, which threaded Chez does not guarantee
  thread-safe. `objc.sls` serialises both with a dedicated mutex (the collector's
  own ready-queue updates are already safe by stop-the-world). The per-thread
  `@autoreleasepool` requirement is satisfied automatically: `__collect_safe`
  activates before the callable body, so the existing `with-autorelease-pool`
  push/pop in `%callable-invoke` runs on the worker thread.
- **Verified** by `tests/smoke-dispatch.sls` test 4: a block submitted to the
  GCD global queue via `dispatch_async` (a genuine worker thread), doing real
  Scheme heap work, asserting it ran *off* the main thread with the correct
  result, looped 500× to surface any crash, leak, or guardian race.

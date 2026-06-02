# Chez callbacks are outbound, with `Sactivate_thread` for background threads

**Status:** accepted

Extends **ADR-0007** (chez lifetime model) and mirrors racket's **ADR-0014**
(outbound callbacks over native trampolines), with a chez-specific divergence the
spike (`docs/research/2026-06-02-chez-dispatch-spike/`, `FINDINGS.md` §C) made
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

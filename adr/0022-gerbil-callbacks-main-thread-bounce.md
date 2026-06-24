# Gerbil background callbacks bounce to the main thread (no thread activation)

**Status:** accepted

Extends **ADR-0019** (gerbil lifetime: wills + entry-point pool, which deferred
threading) and mirrors racket **ADR-0014** (foreign-thread callbacks bounced to a
Scheme-safe thread), **diverging from chez ADR-0016** (which could activate
foreign threads). **Decision:** a foreign OS thread must **never** re-enter Gerbil
Scheme directly. The native-core callback trampolines (delegate IMPs, block
invokes, transparent-subclass IMPs) **bounce to the main thread** — which owns the
single Gambit VM and runs the AppKit run loop — before re-entering Scheme. There
is **no `Sactivate_thread` analogue** to adopt; the chez activation path is
structurally unavailable on this toolchain.

## Context — the spike settled it

`targets/gerbil/docs/research/2026-06-08-gerbil-threading-spike/FINDINGS.md` (the 080 spike,
spike-gated by 030 decision D4) characterized the biggest chez→gerbil divergence:

- The Homebrew bottle's Gambit (v4.9.7, the toolchain the grove standardized on,
  070 build note) is **single-VM / single-threaded-VMs / green-thread**,
  `___MAX_PROCESSORS 1`. The processor state is a **process-global**
  (`&___GSTATE->vmstate0…pstate[0]`), **not** thread-local — every OS thread
  shares one heap and one allocation pointer.
- **Serialized** foreign entry (worker runs while main is blocked) survives — a
  *false positive*; only one thread touches the VM at a time.
- **Concurrent** foreign entry (worker allocates while the main thread also
  allocates) **crashed 30/30 runs** — SIGSEGV / Gambit heap overflow.
- Because the pstate is global, foreign entry never hits chez's "missing
  per-thread context" crash — so **there is no per-thread context to activate**.
  `Sactivate_thread` has no analogue here.

## Considered options

- **Main-thread bounce (chosen).** Marshal background callbacks to the main thread
  before any Scheme runs. Safe, idiomatic for the green-thread bottle, no
  toolchain change. Coincides with AppKit's own "UI on the main thread" rule, so
  for UI callbacks the bounce is required anyway.
- **Thread activation (chez ADR-0016).** Structurally impossible: single-threaded
  VMs has one global processor owned by no thread; nothing to register.
- **Rebuild Gambit SMP (`--enable-multiple-threaded-vms`).** Rejected: abandons
  the bottle toolchain, large scope, still needs explicit per-thread processor
  attach, and adds GC-coordination cost.
- **Post to a Gambit green thread (mailbox).** Functionally another bounce with
  more Scheme-side machinery and the same main-thread-owns-VM invariant; the
  dispatch-to-main bounce is simpler.

## Decision

The bounce lives in the **clang-compiled native companion**, not the gcc-15
`c-define` bodies (it needs `[NSThread isMainThread]` + `dispatch_*` to the main
queue, which gcc-15 cannot compile — the same split that put block literals in
`native_block.c`, ADR-0021). The `c-define`d dispatchers (`aw_imp_*`, `aw_blk_*`)
become the **inner**, main-thread-only entry; a clang **outer** trampoline checks
the thread and, when off-main, hops to the main queue before calling inward. The
outer trampolines are what `class_addMethod` installs and what the block makers
invoke.

- **Value-returning** IMPs/blocks (`id`/`bool`/`long`) bounce with
  `dispatch_sync(dispatch_get_main_queue(), …)`: the framework needs the result
  and the args must outlive the hop.
- **Void-returning** completions may bounce with `dispatch_async` (fire-and-
  forget), which also avoids the `dispatch_sync`-while-main-blocked deadlock.
- **On the main thread already** (the run-loop common case), the outer trampoline
  calls inward with no hop — zero overhead for today's UI callbacks.

## Consequences

- **The native core is deepened, not replaced.** The 050 trampolines were a
  main-thread *placeholder* (direct re-entry, safe only because the run loop calls
  on main); this ADR makes off-main entry safe by construction. Implemented in
  leaf 080/020.
- **Lifetime/pool (ADR-0019) needs no per-thread machinery.** Since Scheme is only
  ever entered on the main thread, wills fire and the entry-point
  `@autoreleasepool` pushes on the main thread as today — *no* per-thread pool or
  guardian-mutex dance (contrast chez ADR-0016, which made concurrent Scheme
  safe and so had to). The bounce *removes* the hazard rather than tolerating it.
- **Run-loop dependency.** The bounce drains only when the main thread services
  the main queue — true under `[NSApp run]`. Documented in
  `targets/gerbil/docs/reference.md`; sample-app authors doing long main-thread work
  must let the run loop turn.
- **Deadlock caveat.** A `dispatch_sync`-bouncing (value-returning) callback whose
  result the main thread is synchronously blocked waiting for would deadlock — the
  same caveat racket's bounce carries. Void completions (async) are immune.
- **Verified** by a background-callback smoke test (leaf 080/030, cf. chez
  `smoke-dispatch.sls` test 4): a `dispatch_async` worker driving a real Gerbil
  callback under a live run loop, looped to surface any crash or corruption.
- Target-local under **ADR-0011**. Evidence: the 080 spike FINDINGS.

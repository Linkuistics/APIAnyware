# Gerbil foreign-thread → Gambit entry spike — FINDINGS

**Date:** 2026-06-08 · **Leaf:** add-gerbil-scheme-target 080 · **Gambit:** v4.9.7
(Gerbil v0.18.2, Homebrew bottle `gerbil-scheme/0.18.2`) · arm64 macOS.

Characterizes the biggest chez→gerbil threading divergence the 020 spike did not
cover: can an OS thread that Gambit did not create (a `dispatch_async` GCD worker,
an `NSURLSession` completion thread) safely enter Gerbil Scheme through the
native-core callback trampolines? Parallels the chez dispatch spike
(`docs/research/2026-06-02-chez-dispatch-spike/`, §C) which found chez's *threaded*
build survives via `Sactivate_thread`.

## TL;DR

The bottle's Gambit is a **single-VM, single-threaded-VMs, green-thread** build
(`___MAX_PROCESSORS 1`). The processor state is a **process-global**, not
thread-local, so all OS threads share one heap and one allocation pointer.
Consequence:

- **Serialized** foreign entry (worker runs while the main thread is blocked)
  **survives** — a false positive: only one thread touches the VM at a time.
- **Concurrent** foreign entry (worker allocates while the main thread also
  allocates) **crashes 100% of the time** — SIGSEGV / Gambit heap overflow.
- **There is no `Sactivate_thread` analogue.** Chez registers a *per-thread*
  Scheme context; single-threaded-VMs Gambit has no per-thread context to
  register. The chez activation model (ADR-0016) is structurally unavailable.

**Decision: a racket-style main-thread bounce (ADR-0014), recorded in ADR-0022.**
Background callbacks must marshal to the main thread — which owns the single VM
and runs the AppKit run loop — before re-entering Scheme.

## Evidence A — the build is green-thread, pstate is global

`/opt/homebrew/Cellar/gerbil-scheme/0.18.2/include/gambit.h` (the header every
`gxc`/`gsc` consumer compiles against, so authoritative for this toolchain — an
ABI mismatch with `libgambit.a` would not link):

- `___SINGLE_VM` defaulted (no `___MULTIPLE_VMS`), `___SINGLE_THREADED_VMS`
  defaulted (no `___MULTIPLE_THREADED_VMS`) ⇒ `___MAX_PROCESSORS 1`.
- Under `___SINGLE_THREADED_VMS` the pstate accessor is **direct global access**,
  not TLS:

  ```c
  /* Use direct access to the only pstate */
  #define ___GET_REAL_PSTATE() (&___GSTATE->vmstate0.aligned_pstate[0].pstate)
  ```

  (Contrast the multi-VM branch, which reads `___tls_ptr` / `___get_tls_ptr()`.)

So a foreign thread entering a `c-define`d trampoline does **not** dereference a
missing per-thread pstate (the chez crash mode) — it grabs the *one* global
pstate and proceeds, racing whoever else holds it.

## Evidence B — the probe (`probe.m` + `callback.ss`, one stage/process)

`bash build-and-run.sh 30` → `probe-results.txt`. A `c-define`d callback does
real Scheme heap work (allocates pairs, forcing pstate access + GC).

| Stage | Thread | Main thread meanwhile | Result |
|---|---|---|---|
| `direct` | main (re-entrant Scheme→C→Scheme) | n/a | **survives** (exit 0) |
| `pthread` | fresh pthread | **blocked** in `pthread_join` | **survives** (exit 0) |
| `gcd` | GCD global queue worker | **blocked** in `dispatch_semaphore_wait` | **survives** (exit 0) |
| `concurrent` | GCD worker (~2M pairs) | **also allocating** (~20M pairs), not blocked | **30/30 CRASH** |

Concurrent crash signatures: mostly `SIGSEGV` (rc 139), several Gambit
`*** FATAL ERROR -- Heap overflow` (rc 70), occasional `SIGABRT` (rc 138) — all
consistent with two threads mutating one bump-allocator / GC moving objects out
from under the other.

The serialized survivals are the trap: a sample app that happens to await its
background work would pass casual testing, then corrupt the moment a callback
truly overlaps the main run loop.

## Why not the other options

- **Activation (chez ADR-0016):** impossible without a per-thread processor.
  `___SINGLE_THREADED_VMS` has exactly one, owned by no thread in particular.
- **Rebuild Gambit SMP (`--enable-multiple-threaded-vms`):** abandons the
  Homebrew bottle toolchain the whole grove standardized on (070 build note,
  spec §7), is large scope, and SMP Gambit *still* requires explicit per-thread
  processor attach + carries its own GC-coordination cost. Rejected.
- **Gambit thread-system post (mailbox to a green thread):** functionally another
  bounce, with more Scheme-side machinery and the same "main thread owns the VM"
  invariant. The dispatch-to-main bounce is simpler and coincides with AppKit's
  own "UI on the main thread" rule. Rejected in favour of the dispatch bounce.

## Implementation consequences (for ADR-0022 + leaves 080/020, 080/030)

- The bounce **must live in the clang companion**, not the gcc-15 `c-define`
  bodies: it needs `[NSThread isMainThread]` + `dispatch_*` to the main queue,
  which gcc-15 cannot compile (same reason `native_block.c` is split out,
  ADR-0021). The `c-define`d dispatchers become the *inner* (main-thread-only)
  entry; a clang outer trampoline does the bounce and calls inward.
- **Sync vs async:** a value-returning IMP/block must `dispatch_sync` to main
  (the framework needs the result, and the args must outlive the hop); a
  void-returning completion may `dispatch_async` (fire-and-forget), which also
  sidesteps the `dispatch_sync`-while-main-thread-blocked deadlock.
- **Run-loop dependency:** the bounce only drains when the main thread services
  the main queue — true under `[NSApp run]`; the smoke test (CLI) must spin a
  run loop / `dispatch_main` to exercise a real background callback.
- **Lifetime/pool (ADR-0019) interaction is resolved by the bounce:** since
  Scheme is only ever entered on the main thread, wills fire and the entry-point
  `@autoreleasepool` pushes on the main thread as today — no per-thread pool /
  guardian-mutex dance like chez ADR-0016 needed. The bounce *removes* the
  threading hazard rather than making concurrent Scheme safe.

## Artifacts

`probe.m`, `callback.ss`, `build-and-run.sh`, `probe-results.txt`,
`probe-results-v1.txt` (serialized-only first run). Throwaway; kept as evidence.

# SBCL foreign-thread callback spike — first-hand de-risking for ADR-0035

A design-phase spike that settles **D2 — the threading/callbacks model** for the
`sbcl` target, run against **SBCL 2.6.5 (arm64, macOS)**. The grove leaf
`030-design/030-lifetime-threading-conditions` mandated settling this first-hand:
the prior-art survey (`docs/research/cl-cocoa-bridges-across-the-family.md` §D)
left D2 **un-de-risked** (its gap 4), and the two in-repo precedents *diverge* —
chez **activates** foreign threads (ADR-0016) while gerbil **bounces** them to
main (ADR-0022) — so which one SBCL fits is an empirical question, not an
inheritable one. The user chose "spike now, then decide" over picking on first
principles, matching how both prior compiled-FFI targets settled their threading.

The question chez/gerbil each spiked: **can a foreign (non-SBCL-created) OS thread
— a GCD worker firing an `NSURLSession`/`dispatch_async` completion — safely run
Lisp under GC pressure?** SBCL is a genuinely multi-threaded runtime (`sb-thread`,
real preemptive OS threads), so unlike gerbil's single global-VM Gambit the
chez-style activation model is *structurally available* — the runtime attaches
foreign threads for `define-alien-callable` callbacks. The spike asks whether that
attachment is actually GC-safe.

Run: `./run.sh` (compiles `spike.c` → `/tmp/libspike.dylib`, then runs each test in
a fresh SBCL process so a crash in one does not mask the others). Nothing here is
part of the build; it is reproducible evidence for the ADR.

## The harness

A `define-alien-callable` (`aw-spike-cb`) that **conses on every invocation** (a
fresh 64-element list, summed) so each foreign entry does real Lisp heap work and
can trigger GC. `spike.c` exposes `aw_spike_run(cb, outer, inner)`, which fires
`outer` concurrent blocks on the **global concurrent GCD queue** — genuine foreign
OS worker threads SBCL never created — each calling `cb` `inner` times. The
identical heap work (`do-cons-work`) is reused across all three variants so only
*who runs it* differs. This is the shape of chez's `smoke-dispatch.sls` test 4 and
the gerbil threading spike.

## What the spike proves

| Test | Who runs the consing load | Result |
|---|---|---|
| `native-concurrent` (**control**) | 8 **SBCL-native** `sb-thread`s + a background conser, identical load | **SURVIVED** (exit 0) — proves the *load* is fine; real concurrent Lisp + GC is safe on SBCL-owned threads |
| `foreign-serial` | **1** GCD worker at a time, no competing native conser | **SURVIVED** (exit 0) — a lone foreign thread that triggers GC can suspend the *SBCL-native* threads it needs to; nothing forces a foreign↔foreign suspend |
| `foreign-concurrent` | **8 concurrent GCD workers** + a background conser | **CRASHED 5/5** — fatal error inside `SB-KERNEL::GC-STOP-THE-WORLD` |

The crash is deterministic (5/5 runs) and always the identical signature:

```
fatal error encountered in SBCL pid … pthread 0x16f127000:
cannot suspend thread 0x16f053000: 45, Operation not supported
   0: SB-KERNEL::GC-STOP-THE-WORLD
   1: (FLET "WITHOUT-GCING-BODY-" :IN SB-KERNEL::SUB-GC)
   …
```

(errno 45 = `ENOTSUP`.)

## What it means

The three-variant design isolates the cause precisely:

- **Not the load.** `native-concurrent` runs the *same* (heavier) heap work on 8
  SBCL-created threads and survives. Concurrent Lisp + stop-the-world GC is fine
  when every thread is SBCL-owned.
- **Not foreign entry per se.** `foreign-serial` — a single GCD worker entering
  Lisp and triggering GC — survives, because the only threads GC must suspend are
  SBCL-native (main, finalizer), which suspend fine.
- **It is concurrent foreign threads needing stop-the-world coordination.** When
  one GCD worker triggers GC and must suspend *another* GCD worker, the suspend
  fails with `ENOTSUP`. SBCL's macOS thread-suspension path works only for threads
  it created; a foreign thread it merely *attached* for a callback is not
  suspendable for GC.

This is the **opposite failure from gerbil's** and arrives at the same place.
Gerbil crashed at *entry* — its single global-VM Gambit had no per-thread context
at all (`___MAX_PROCESSORS 1`). SBCL crashes *later and subtler*: it does attach
the foreign thread and run Lisp on it, and a *lone* foreign thread is even fine —
the failure only surfaces inside `GC-STOP-THE-WORLD` when the collector must
suspend a *second* concurrent foreign thread. Both roads forbid the same thing:
**Lisp must never run on a foreign thread** (beyond the accidental lone-worker case
that happens to survive).

## Decision settled (→ ADR-0035)

**Adopt the gerbil/racket bounce-always model**, reached for an SBCL-specific
reason (GC cannot stop-the-world concurrent foreign threads), not by inheritance:

- A foreign OS thread must **never** run Lisp directly. The native-core callback
  trampolines (delegate IMPs, block invokes, transparent-subclass IMPs) **bounce
  to the main thread** — an SBCL-native, always-suspendable thread that also runs
  the AppKit run loop — before re-entering Lisp. The chez `Sactivate_thread`
  activation path is **rejected** (this spike is the evidence it is unsafe here).
- **Richer than gerbil in one respect:** SBCL-native `sb-thread` workers *do* run
  real concurrent Lisp safely (the `native-concurrent` control). So sample-app
  background compute belongs on `sb-thread`, **not** on a captured foreign thread;
  the bounce rule scopes to *foreign* (framework/GCD) entry only, not to all
  concurrency.
- The bounce lives in the Swift native core (`libAPIAnywareSbcl`): `dispatch_sync`
  to the main queue for value-returning IMPs/blocks (the framework needs the
  result), `dispatch_async` for void completions (fire-and-forget, deadlock-immune);
  on the main thread already, call inward with no hop. This is gerbil ADR-0022's
  exact split, which Swift expresses directly.

# SBCL background callbacks bounce to the main thread (foreign-thread Lisp entry is GC-unsafe)

Decides the **sbcl** target's threading/callback model (grove leaf
`030-design/030-lifetime-threading-conditions`, D2). Mirrors gerbil **ADR-0022**
and racket **ADR-0014** (foreign-thread callbacks bounced to a runtime-safe
thread), and **rejects** the chez **ADR-0016** activation model — but, unlike
gerbil, the rejection is reached **empirically**, not structurally. **Decision:** a
foreign OS thread (a GCD worker / framework completion thread SBCL never created)
must **never** run Lisp directly. The native-core callback trampolines (delegate
IMPs, block invokes, transparent-subclass IMPs) **bounce to the main thread** —
which is SBCL-native, suspendable for GC, and runs the AppKit run loop — before
re-entering Lisp.

## Context — the spike settled it

SBCL is a genuinely multi-threaded runtime (`sb-thread`, real preemptive OS
threads), so unlike gerbil's single global-VM Gambit the chez activation model was
**structurally available**: the runtime attaches a foreign thread for a
`define-alien-callable` callback. The question was whether that attachment is
**GC-safe**. The prior-art survey left it un-evidenced (§D, gap 4); the user chose
"spike now, then decide". The spike
(`targets/sbcl/docs/research/2026-06-20-sbcl-threading-spike/`,
SBCL 2.6.5 / arm64) fired a consing `define-alien-callable` from genuine GCD
worker threads under GC pressure, against an SBCL-native control:

| Test | Who runs the consing load | Result |
|---|---|---|
| `native-concurrent` (control) | 8 **SBCL-native** `sb-thread`s + bg conser | **SURVIVED** |
| `foreign-serial` | **1** GCD worker at a time | **SURVIVED** |
| `foreign-concurrent` | **8 concurrent GCD workers** + bg conser | **CRASHED 5/5** |

The crash is deterministic and always identical: a fatal error inside
`SB-KERNEL::GC-STOP-THE-WORLD` — `cannot suspend thread 0x…: 45, Operation not
supported` (`ENOTSUP`). The three-variant design isolates the cause: not the load
(the native control runs the same work and survives), not foreign entry per se (a
lone foreign worker survives), but **concurrent foreign threads needing
stop-the-world coordination** — when one GCD worker triggers GC and must suspend
*another* GCD worker, SBCL's macOS thread-suspension fails, because it works only
for threads SBCL created, not for a thread it merely attached for a callback.

This is the **opposite failure from gerbil's** (which crashed at *entry*, having
`___MAX_PROCESSORS 1` and no per-thread context at all) and arrives at the same
prohibition: **Lisp must never run on a foreign thread.**

## Considered options

- **Main-thread bounce (chosen).** Marshal background callbacks to the main thread
  — an SBCL-native, always-suspendable thread that owns the AppKit run loop —
  before any Lisp runs. Safe by the spike, and coincides with AppKit's own "UI on
  the main thread" rule so UI callbacks need the bounce anyway. The bounce lives in
  the Swift native core (`libAPIAnywareSbcl`): `dispatch_sync` to the main queue for
  value-returning IMPs/blocks (the framework needs the result; args must outlive the
  hop), `dispatch_async` for void completions (fire-and-forget, deadlock-immune);
  on the main thread already, call inward with no hop — zero overhead for today's UI
  callbacks. This is gerbil ADR-0022's exact split, which Swift expresses directly.
- **Chez `Sactivate_thread` activation (ADR-0016).** Rejected — **the spike is the
  evidence it is unsafe here.** SBCL attaches the foreign thread but cannot
  stop-the-world-suspend it for GC on arm64 macOS; concurrent foreign callbacks
  crash 5/5. The chez result does not transfer: Chez's threaded build registers the
  foreign thread fully (GC-suspendable); SBCL's attachment does not extend to GC
  suspension on this platform.
- **Rebuild SBCL with a different GC/threading config.** Rejected: abandons the
  stock Homebrew SBCL toolchain for a speculative, unverified gain, large scope.
- **Post to an `sb-thread` mailbox.** Functionally another bounce with more
  Lisp-side machinery and the same main-thread-owns-the-run-loop invariant; the
  dispatch-to-main bounce is simpler.

## Consequences

- **Richer than gerbil in one respect.** SBCL-**native** `sb-thread` workers *do*
  run real concurrent Lisp safely (the `native-concurrent` control). So sample-app
  background compute belongs on `sb-thread`, **not** on a captured foreign thread;
  the bounce rule scopes to *foreign* (framework/GCD) entry only, not to all
  concurrency. Documented in `targets/sbcl/docs/reference.md`.
- **The native core is deepened, not replaced.** Early runtime trampolines may
  re-enter Lisp directly (safe only because the run loop calls on main); this ADR
  makes off-main entry safe by construction. Implemented in build leaf `050`.
- **Lifetime interaction (ADR-0036).** SBCL's `sb-ext:finalize` runs on a dedicated
  finalizer thread, so a finalizer-driven `release` fires off-main. That is a
  *UI-affinity* concern, **not** the GC-safety concern of this ADR — the finalizer
  thread is SBCL-native, hence suspendable. ADR-0036 routes the `release` to main
  via a queue drained at the entry-point pool boundary.
- **Deadlock caveat.** A `dispatch_sync`-bouncing (value-returning) callback whose
  result the main thread is synchronously blocked waiting for would deadlock — the
  same caveat racket/gerbil carry. Void completions (async) are immune.
- **Run-loop dependency.** The bounce drains only when the main thread services the
  main queue — true under `[NSApp run]`. Sample-app authors doing long main-thread
  work must let the run loop turn.
- Target-local under **ADR-0011**. Evidence: the 2026-06-20 threading spike.

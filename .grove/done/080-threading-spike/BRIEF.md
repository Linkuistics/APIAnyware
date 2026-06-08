# 080-threading-spike — brief

## Goal

Characterize Gambit's foreign-OS-thread → Gerbil entry story (the biggest
chez→gerbil divergence), settle the threading model, record it in an ADR, then
deepen the 050 native-core callbacks beyond the main-thread placeholder and
verify with a background-callback smoke test.

## Settled (this planning session, 2026-06-08)

**Spike ran and decided.** Evidence:
`docs/research/2026-06-08-gerbil-threading-spike/FINDINGS.md`.

- Bottle Gambit (v4.9.7) is **single-VM / single-threaded-VMs / green-thread**;
  the pstate is a **process-global**, shared by all OS threads.
- Serialized foreign entry survives (false positive); **concurrent entry crashed
  30/30** (SIGSEGV / heap overflow). **No `Sactivate_thread` analogue exists.**
- **Decision (ADR-0022): main-thread bounce**, racket-ADR-0014-style — diverges
  from chez activation (ADR-0016), which is structurally unavailable here.

## Remaining work (leaves)

- **010** native-core bounce: clang outer trampolines wrap the gcc `c-define`
  inner dispatchers; off-main IMP/block entry hops to the main queue
  (`dispatch_sync` for value returns, `dispatch_async` for void) before any
  Scheme runs. Implements ADR-0022.
- **020** background-callback smoke test: a real `dispatch_async` worker driving a
  Gerbil callback under a live run loop, looped to surface crash/corruption
  (cf. chez `smoke-dispatch.sls` test 4).

## Notes

Placed before 090 sample-apps because mini-browser (WebKit) / pdfkit / scenekit
may take background callbacks. Knowledge note (run-loop dependency + deadlock
caveat) lands in 110 / `knowledge/targets/gerbil.md`.

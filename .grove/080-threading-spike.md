# 080-threading-spike

**Kind:** planning

## Goal

Characterize Gambit's foreign-OS-thread → Gerbil entry story (the biggest
Chez→Gerbil divergence, NOT covered by the 020 spike), settle the threading model,
write a Gerbil threading ADR, then deepen the 050 native-core callbacks beyond the
main-thread placeholder.

## Context

Spike-gated by 030 (design decision D4). Background: chez ADR-0016 made
foreign-thread callbacks (GCD workers) safe via Chez's *native* threads
(`__collect_safe` / `Sactivate_thread`). **Gambit's default thread model is green
(user-level) threads**, so whether an OS thread (e.g. a `dispatch_async` worker)
can safely enter Gambit Scheme — and the activation analogue (`___EXT`? a
Gambit-specific dance? a forced main-thread bounce?) — is genuinely unknown.
ADR-0019 covers the single-threaded model and explicitly defers this.

## Done when

- A spike characterizes: does a GCD worker calling a Gerbil callback work, crash,
  or need activation? What is the Gambit analogue of `Sactivate_thread`? Does
  Gerbil run a multithreaded Gambit VM (SMP) or strictly green threads? Evidence
  in `docs/research/<date>-gerbil-threading-spike/`.
- Threading model decided (main-thread-bounce like racket ADR-0014, or
  activation-based like chez ADR-0016, or a Gambit-specific mechanism).
- Threading ADR raised (parallels ADR-0016) recording the measured model.
- 050's native-core callbacks deepened accordingly (block/delegate/dynamic-class
  IMPs made thread-safe per the decided model); lifetime/pool interaction on
  worker threads (ADR-0019) resolved.
- Verified by a smoke test exercising a genuine background callback (cf. chez
  `smoke-dispatch.sls` test 4).

## Notes

Placed before the 090 sample-apps node because mini-browser (WebKit) /
pdfkit / scenekit may take background callbacks. If an earlier app needs it,
`grove-llm leaf-insert` ahead. Planning leaf: may grow its own build leaves.

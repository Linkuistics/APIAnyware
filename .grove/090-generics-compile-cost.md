# 090-generics-compile-cost

**Kind:** planning

## Goal

Decide how to make the gerbil **cold** build tractable. Today a fresh build of a single
sample app takes **~5h**, dominated by the monolithic full-framework `generics.ss`. This
blocks the per-app VM-verify portfolio (node 100-sample-apps): six more apps, each a cold
build, is impractical at 5h/app. Grill the options, pick a direction, raise an ADR, and
grow work leaves.

## Context — the blowup (measured at leaf 070/040, 2026-06-08)

The emitter folds every `:std/generic` dispatch into one module, `generics.ss`. On a cold
build (`build/` is gitignored, so no warm `gerbil-cache` survives a checkout — every fresh
session is cold) the pipeline on that one module was:

- `gsc -target C` on the 2nd compilation unit (`generics~1.scm`, **60 MB**): ~2h44m
  single-threaded → emits a **94 MB** `generics~1.c`.
- `gcc-15 -O1` on that 94 MB single translation unit: ~2h+ at **9.7 GB RSS** (32 GB host,
  swap nearly exhausted) before the object appeared.

Root cause is architectural, not transient: a monolithic generics module is one giant C
translation unit, and GCC's optimizers (register allocation, GCSE, instruction
scheduling) are **superlinear in unit size** — both time and memory blow up. The 070
brief's "the bottle gsc is the fast single-host build" was true *for a warm cache* but
never measured a cold full-framework generics compile.

The shipped `.app` is unaffected — it runs fine and launches instantly. This is purely a
**build-time** cost.

## Candidate directions (to grill — not yet decided)

1. **Split `generics.ss` into many small modules** — bounded, parallelizable translation
   units; sidesteps GCC's superlinear-per-unit cost and enables `gxc`/make parallelism.
   Likely the real fix; touches the emitter (emit-gerbil) generics-module strategy.
2. **Compile generics at `-O0`/`-d` (Gambit per-module C-opt control)** — generics is
   mostly dispatch glue; full `-O1` optimization may buy little. Cheapest to try; may be a
   large win alone or a stopgap before (1).
3. **Persist/commit a warm `gerbil-cache`** — amortize the cost once. Fights the gitignore
   and bloats the repo (94 MB C, 30 MB+ objects); least attractive, but worth weighing.
4. Combinations (e.g. split + `-O0`).

## Done when (planning)

- Direction chosen (likely 2 as a quick win, then 1 as the durable fix), recorded in an
  ADR if it changes the emitter's generics strategy or the build config.
- Work leaves grown for the chosen direction.
- A target cold-build budget agreed (e.g. "< N min/app cold") so node 100 is viable.

## Notes

Sequenced **before** 100-sample-apps deliberately: the portfolio is the thing this
unblocks. 080-threading-spike is independent and may run in either order. First action of
the work that follows: re-measure a cold build after the chosen change against the
hello-window app (the cheapest end-to-end probe). See
`generation/targets/gerbil/test-results/hello-window/report.md` for the baseline numbers.

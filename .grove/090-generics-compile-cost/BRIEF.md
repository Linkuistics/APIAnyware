# 090-generics-compile-cost — brief

## Goal

Make the gerbil **cold** build tractable so the per-app VM-verify portfolio
(node `100-sample-apps`, six more apps × a cold build) is viable. Today a fresh
build of one sample app takes **~5h**, dominated by the monolithic
full-framework `generics.ss`.

**Decision (ADR-0023):** compile `generics.ss` **without optimization** — it is
a pure-declaration module (`(g:defgeneric …)` only; methods + dispatch live
elsewhere), so `-O` costs hours and buys no runtime speed. Probe this cheapest
remedy first and re-measure; escalate to splitting only if it misses budget.

**Budget (done-bar): `< 15 min/app` cold.**

## Diagnosis (measured at leaf 070/040, 2026-06-08)

`lib/generics.ss` is 415 KB of source but **6,496 `(g:defgeneric …)` forms**
(AppKit + Foundation only). The `:std/generic` macro expands each heavily → one
**60 MB** Gambit `.scm` / **94 MB** `.c` translation unit. Both compile stages
are superlinear in unit size and both are driven by `gxc -O`:

- `gsc -target C` on `generics~1.scm`: ~2h44m single-threaded.
- `gcc -O1` on the 94 MB `.c`: ~2h+ at 9.7 GB RSS (swap thrashing).

Every class module imports `generics.ss`, so even hello-window (≈7 classes)
drags the full monolith in. The shipped `.app` is unaffected — build-time only.

Build driver: `generation/crates/bundle-gerbil/src/compile.rs` (single
`gxc -O` over the whole topological closure from `deps.rs`). Emitter:
`generation/crates/emit-gerbil/src/emit_generics.rs`. Baseline numbers:
`generation/targets/gerbil/test-results/hello-window/report.md`.

## Chosen direction & sequencing

1. **Probe (leaf 010):** compile `generics.ss` on its own un-`-O` `gxc` pass in
   `compile.rs`; re-measure a cold hello-window build.
2. **Decide from data:** under 15 min → ship, record outcome in ADR-0023,
   node done. Still over → grow a follow-up leaf:
   - **split** `generics.ss` into N bounded modules (`emit_generics.rs`) if
     generics is still the bottleneck, and/or
   - **residual** leaf (parallelize class-module compiles / the link) if
     generics is now cheap but the non-generics tail keeps it over budget (the
     original ~23 min residual was measured under swap thrash — re-measure
     isolates it).

Lazy decomposition (grove): only leaf 010 is grown now; the escalation leaves
are commissioned by 010 *if* its measurement demands them.

## Done when

- Cold build of hello-window measured `< 15 min/app` (or escalation leaves grown
  and that work completed to reach it).
- ADR-0023 amended with the measured outcome.
- `100-sample-apps` is unblocked.

## Notes

Sequenced before `100-sample-apps` deliberately — the portfolio is what this
unblocks. `080-threading-spike` was independent (now retired). First action of
leaf 010: re-measure against hello-window (the cheapest end-to-end probe).

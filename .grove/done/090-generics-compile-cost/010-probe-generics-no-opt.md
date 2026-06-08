# 010-probe-generics-no-opt

**Kind:** work

## Goal

Compile the shared `generics.ss` declaration module **without optimization**
(ADR-0023), then re-measure a cold hello-window build against the
`< 15 min/app` budget. This is the cheapest remedy for the ~5h cold build;
the measurement decides whether it suffices or splitting must follow.

## What to change

`generation/crates/bundle-gerbil/src/compile.rs`, step 2 ("`gxc -O` the
closure"). Today one `gxc -O` compiles the whole topological closure, which
includes `generics.ss`. Split it:

1. If `generics.ss` is in the closure, compile it **first, on its own `gxc`
   pass without `-O`** (default/debug codegen — Gambit skips the global flow
   analysis and gcc skips `-O1`, killing both superlinear stages for a module
   that has nothing to optimize).
2. Compile the **rest** of the closure with `-O` as today, in topological
   order (generics already cached, so importers resolve its `.ssi`).
3. Leave step 3 (`gxc -exe -O`) unchanged — it links the warmed cache and must
   not recompile generics.

Nail the exact non-`-O` invocation empirically (plain `gxc <file>` vs. an
explicit opt-off flag); verify the produced `.o1`/`.ssi` links cleanly with the
`-O` modules (Gerbil mixed-opt linking is sound — the `.ssi` interface is
opt-independent). Keep the clang companion (step 1) and ld-options untouched.

If a per-module Gambit declaration in the emitted `generics.ss` is cleaner than
a separate build-driver pass, that is an acceptable alternative — but the
build-driver pass keeps the emitter (`emit_generics.rs`) unchanged and is
preferred unless it proves awkward.

## Done when

- `compile.rs` compiles `generics.ss` without `-O`; existing bundle-gerbil unit
  tests still pass (`cargo test -p apianyware-macos-bundle-gerbil`).
- **Cold** hello-window build re-measured (wipe `build/` and the `GERBIL_PATH`
  cache first — `build/` is gitignored so a fresh checkout is already cold; use
  the **BOTTLE** toolchain, `SDKROOT` exported, per the 070 findings and
  `[[reference-testanyware-cli]]` is *not* needed here — this is a host build,
  not a VM step). Record wall-clock total and the generics-stage time.
- Result triaged against the `< 15 min/app` budget:
  - **Under budget** → update `test-results/hello-window/report.md` and amend
    `docs/adr/0023-*.md` with the measured outcome ("accepted, confirmed");
    node `090` is done.
  - **Over budget** → record the new breakdown, then **grow the escalation
    leaf(s)** under this node (`grove-llm leaf-add … --node 090-generics-compile-cost`):
    `split` generics into N modules (`emit_generics.rs`) if generics is still
    the bottleneck; a `residual` leaf if generics is now cheap but the
    non-generics tail (class modules + link) keeps it over budget. Re-measuring
    isolates which — the original ~23 min residual was contaminated by generics'
    gcc thrashing swap.

## Notes

- The shipped `.app` must remain byte-for-byte equivalent in behaviour — this is
  a build-time-only change; a quick CLI smoke (window draws) is enough here, the
  full VM-verify bar belongs to the sample-app leaves.
- Re-VM-verification of hello-window is **not** required for this node — 070
  already PASSED it; this leaf only changes build wall-clock.
- Watch peak RSS during the re-measure — confirming the 9.7 GB / swap-thrash
  spike is gone is itself evidence the fix landed.

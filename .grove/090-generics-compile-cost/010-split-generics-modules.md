# 010-split-generics-modules

**Kind:** work

## Goal

Split the monolithic `generics.ss` into many small, bounded modules so each is a
small `gsc -target C` unit — sidestepping the size-superlinearity that makes one
giant unit pathological (retired leaf `done/090.../010-probe-generics-no-opt`:
`gsc` on a 37.8 MB unit ran >67 min *even without `-O`*; a 16.9 MB unit was
borderline). Compile the shards **without `-O`** (ADR-0023, already in
`compile.rs`) and **in parallel**. Land a cold hello-window build under the
**`< 15 min/app`** budget — and, for the first time, measure the true
non-generics residual.

## Background (why this is the durable fix)

`gsc` itself (Scheme→C, not just `gcc -O1`) is superlinear in module size. The
`:std/generic` macro expands each `(g:defgeneric …)` to ~8 KB of Scheme; 6,496
selectors (AppKit+Foundation) → ~54 MB expanded, which Gambit auto-splits into
units big enough to choke `gsc`. Bounded source modules give bounded units +
parallel `gsc` invocations. See `docs/adr/0023-*.md` (measured outcome section).

## Design

### Emitter — `generation/crates/emit-gerbil/src/emit_generics.rs`

- Shard the sorted global selector set into chunks of **K** selectors
  (`K` a tunable const; start ~256 → ~26 shards; see budget note). Each chunk
  becomes a shard module under `lib/generics/NNN.ss` that imports `:std/generic`
  (renamed) and `(g:defgeneric …)`+exports only its slice.
- Emit a **facade** `lib/generics.ss` that imports every shard and re-exports
  them (`(export (import: :gerbil-bindings/generics/000) …)`), so the import
  path class modules already use — `:gerbil-bindings/generics` — is unchanged
  (`GENERICS_MODULE_IMPORT`/`GENERIC_IMPORT` in `emit_class.rs` stay as-is).
- **Invariant preserved (ADR-0020):** each selector is declared in exactly one
  shard → one generic per selector, re-exported once via the facade → no facade
  clash, all classes extend the same generic. The existing test
  `shared_selector_declared_once_across_unrelated_classes` must still pass
  (now: declared once *across all shards*); add a test that a selector lands in
  exactly one shard and the facade re-exports every shard.
- Shards have **no cross-shard deps** (each imports only `:std/generic`) — that
  is what makes them embarrassingly parallel; only the facade depends on them.

### Build driver — `generation/crates/bundle-gerbil/src/compile.rs`

- The current partition keys on the single `generics.ss`. Generalise it: a
  "generics module" is `generics.ss` **or** any module under `generics/`. All go
  in the no-`-O` pass; everything else stays `-O`.
- **Parallelise the no-`-O` shard compile**: spawn concurrent `gxc` invocations
  (one per shard, or batched) up to a worker cap — shards are independent.
  Compile the facade **after** all shards (it imports them). `gxc` has no
  built-in `-j`; parallelism comes from concurrent processes. Keep `deps.rs`'s
  topological order for the `-O` pass.
- Update/extend `deps.rs` if needed so the facade's shard imports resolve into
  the closure (the `(import …)` walk should already pick them up — verify).

### Regenerate

After the emitter change, **regenerate** the gerbil lib so `lib/generics*`
reflects the split ([[regenerate-pipeline-aggressively]]) — don't hand-edit
`lib/generics.ss`. Confirm class modules still import `:gerbil-bindings/generics`
and compile.

## Done when

- Emitter shards generics + emits the re-export facade; emit-gerbil tests pass
  (incl. the unification + one-shard-per-selector tests). `compile.rs` compiles
  all generics modules no-`-O` and in parallel; bundle-gerbil tests pass.
- gerbil lib regenerated; `lib/generics.ss` is the facade, `lib/generics/NNN.ss`
  the shards.
- **Cold** hello-window build (wipe `build/`, BOTTLE 0.18.2, `SDKROOT` set)
  re-measured: record total wall-clock, generics-stage time, per-shard `gsc`
  time, peak RSS, and — finally — the **non-generics residual**.
- Triage vs `< 15 min`:
  - **Under budget** → tune `K` if needed, update `test-results/hello-window/`
    with the new build time, amend ADR-0023 "confirmed", node `090` done.
  - **Generics fine but residual over** → grow a `residual` leaf (parallelize
    class-module compiles / the `-exe` link). The residual was never isolated
    before (every prior build died in generics).
  - **Shards still too slow** → lower `K` and re-measure (the size threshold is
    empirical; `gsc` may be worse than O(n²)).
- A quick CLI/headless smoke that the app still launches (full VM-verify is
  070's bar / the sample-app leaves, not this build-perf leaf).

## Notes

- Budget math: if `gsc` is ~O(n²), 37.8 MB→67 min implies ~3 MB/shard for ~30 s
  each → ~18 shards (~9 min sequential, ~1–2 min parallel). Start `K`≈256 and
  measure *one* shard's `gsc` time before committing to N; adjust so each shard
  is well under ~1 min.
- The shipped `.app` behaviour is unchanged — build-time only.
- Keep the no-`-O` decision (ADR-0023): small **and** unoptimized is the intended
  end state for these declaration modules.

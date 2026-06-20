# 060-orchestration-goldens

**Kind:** work

## Goal

Wire the construct emitters into a complete `emit_framework` and lock behaviour
with goldens — the integration + done-bar leaf:

- **`emit_framework.rs`** — the full orchestrator (peer
  `emit-gerbil/emit_framework.rs` ~776): per-framework drive class_graph →
  emit_class/generics → protocols → enums/constants/functions → trampoline
  collection; the **facade / per-framework `main` re-export** (`SubModule`
  collection + collision-rename, the chez/gerbil on-disk symmetry); the on-disk
  layout under `generated_subdir`. Fill in the `EmitResult` counts.
- **Cross-framework registry pre-pass (the generate.rs swap)** — `SbclEmitter`
  must carry the `ClassRegistry` (cross-framework parents) **and** the
  `ProtocolRegistry` (conformance closures cross frameworks) — both already built
  in 040/020 + 040/030 but **not yet threaded**: 040/030 deliberately left the
  swap to this leaf because the scaffold `emit_framework` had nothing to consume
  it (see that leaf's done-record). Add `SbclEmitter::with_registries(ClassRegistry,
  ProtocolRegistry)` (gerbil's empty-in-`new` + populated-swap pattern) and the
  `info.id == "sbcl"` branch in `cli/src/generate.rs` that builds both via
  `from_framework_refs(&ordered_frameworks)` and swaps the configured emitter in
  (mirror the gerbil branch; sbcl needs **no** `write_global_generics_module` — it
  has no sharded generics). `emit_framework` then: (a) flattens via
  `render_class_dispatch_with`/`emit_class_dispatch` (registry-aware), (b) emits
  the **global** `defgeneric` block once from `collect_generics(&frameworks,
  &protocols)`, and (c) per protocol with `emit_protocol::has_surface`, emits
  `render_protocol(proto, fw, &global_generic_names)` (dedup against that global
  set). Wire `cli/src/registry.rs`'s comment to mention the protocol registry too.
- **Goldens** — `tests/golden/` (a synthetic `testkit` framework: classes,
  protocols, enums, constants, functions, a subclass) + `tests/golden-foundation/`
  (real Foundation subset: nsstring/nsarray/nsurl/nsdata/nserror + enums/
  constants/functions), mirroring the gerbil golden fixtures. Snapshot tests
  (`emit::snapshot_testing`) + a runtime-shape / load-smoke test where feasible.
- **End-to-end §6d verification** — a test that runs the full pipeline over the
  real IR and asserts the residual = **51 fn + 7 const + 576 init + 554 method**
  (the node's hard done-bar; complements 050's unit assertion).

## Context

Node BRIEF "Done when". SBCL design spec §5 (build pipeline + artifact map) + §6
(contract conformance table — the goldens should demonstrate §3.1–§3.8). Reference:
`emit-gerbil/src/emit_framework.rs`, `emit-gerbil/tests/{snapshot_test.rs,
runtime_load_test.rs}`, and the golden trees `tests/golden/` + `tests/golden-
foundation/`. The shared `emit::snapshot_testing` + `emit::test_fixtures`.

## Done when

- `cargo test -p apianyware-macos-emit-sbcl` green (snapshot + integration).
- `--target sbcl` emits a complete, contract-conforming framework tree end-to-end.
- §6d invariant asserted end-to-end over the real IR.
- Node done-bar met → 040-build-emitter node retires.

## Notes

- This leaf closes the node. On completion, walk the parent chain: 040 node retires
  (promote any durable convention to the SBCL design spec / CONTEXT.md), then pick
  moves to 050-build-runtime-native-core.

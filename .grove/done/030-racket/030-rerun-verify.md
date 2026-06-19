# 030-rerun-verify

**Kind:** work

## Goal

Close the racket method slice the way the parent grove closed §6b: a **full cold
pipeline rerun** from the real SDK, residual-count reproduction, no ObjC
regression, and a **VM-verify** of the Swift-native-method path in a bundled app.
Blocks on `010-build` (the mechanism must compile + smoke in-process first).

## Context

Read first: node `BRIEF.md`, `010-build`'s landed ADR + spec sections, and
`docs/specs/2026-06-15-racket-trampoline.md` §6b (the free-function racket close
this mirrors), §6a (the known-good exemplars), and the `swift-native-probe` app
(`apps/swift-native-probe/`, spec `docs/apps/swift-native-probe/`).

Discipline references: `feedback-regenerate-pipeline-aggressively` (regenerate,
don't trust stale checkpoints), `feedback-vm-verify-every-app` (VM-verify is the
done-bar, CLI smoke never satisfies it), `reference-testanyware-cli` +
`feedback-use-testanyware` (VM verification harness). `SDKROOT=macosx` workaround
applies to collect/analyze.

## Done when

- **Cold full rerun, clean:** `SDKROOT=macosx collect` (284 frameworks, 0 errors)
  → `analyze` (0 verification failures; LLM annotations replayed) → `generate
  --target racket` → `swift build`. The method-residual classification (trampoline
  count + per-blocker deferred counts) **reproduces exactly** from the cold collect
  — proving the counts are a deterministic function of the SDK, not stale local IR.
- **No ObjC regression:** `cargo test --workspace` green; the `RUNTIME_LOAD_TEST`
  harness extended to carry the method-trampoline require-shape + a receiver-method
  round-trip as a permanent regression guard (the §6b registration pattern).
- **VM-verified (project done-bar):** the `swift-native-probe` app extended (or a
  sibling) shows the §6a method exemplars live — the headline async method and the
  pop-B init→receiver→method (+mutating) path — through `libAPIAnywareRacket`'s
  `@_cdecl` trampolines. Visually confirmed in the TestAnyware macOS VM (golden
  `macos-tahoe`); screenshot committed under `generation/targets/racket/
  test-results/`.
- The design spec's §6b-analog (a method-slice close section) is written, and the
  spec/ADR note that chez (040) and gerbil (050) inherit these known-good method
  exemplars.

## Landed (2026-06-19) — scope narrowed, Swift-residual + VM-verify split to `040`

This leaf landed the **racket-side method-trampoline emission** + the cold
`collect`→`analyze`→`generate` rerun. Generate+load revealed the racket emission was
substantially unfinished (not just the carried require-gap); all of it is now fixed and
the **whole residual loads cleanly** (119 class files + 510 value-struct files):

- **Cold rerun green:** `collect` 284/0, `analyze` 0 verification failures, `generate
  --target racket` ok. **Method residual reproduced:** 51 fn + 7 const (unchanged from
  §6b) + **593 init + 588 method** trampolines; deferred `1 deferred_async_scalar_return
  / 68 deferred_closure_param / 3169 deferred_nonbridged_struct_param / 12
  deferred_nullable_scalar_return / 1106 deferred_static_method / 106
  deferred_unnameable_param / 34 unbindable_generic_free_function / 5567
  unbindable_generic_method`.
- **Racket emitter fixes** (`naming.rs`, `trampoline.rs`, `emit_class.rs`,
  `emit_framework.rs`): Swift method/init naming from selector base+labels (wildcard `_`
  → `argN`); require-wiring of `swift-trampoline.rkt`/`async-bridge.rkt`; the **`aw->`
  arrow alias** (ffi/unsafe's `->` under a name `_fun` still matches, surviving the
  native header's `(except-in ffi/unsafe ->)`); `render_racket_init` (init producers
  had **no** racket binding); **value-struct files** (`generate_struct_file`,
  `owner_is_class=false` — pop-B had no file at all); ObjC-vs-Swift name-collision
  exclusion. `cargo test --workspace` green (incl. new unit tests; sole failure is the
  pre-existing gerbil `computes_hello_window_closure` env-skip — gerbil's generated tree
  isn't present in a fresh worktree, unrelated to racket).

**Deferred to `040-swift-residual-verify`** (user-chosen 2026-06-19): the full
117-framework residual **`swift build`** (955 errors — never compiled before, only
Foundation typechecked; bump deployment target + defer-with-count), the
`RUNTIME_LOAD_TEST` harness extension, CLI smoke, **VM-verify** of both exemplars, and
the spec §6b-analog close.

## Notes

This leaf's done-bar is the node's §6b done-bar. Per
`feedback-vm-verify-every-app`, the CLI smoke does not satisfy it — a real bundled
app verified in the VM does. Retiring this leaf empties the `030-racket` node.

**Carried from `020-async-method` (require-wiring gap, full-pipeline territory).**
`emit_class.rs` emits Swift-native method bindings against `_aw-lib` /
`aw-call/error` (sync) and `aw-async-call` (async) but adds **no
`(require …/swift-trampoline.rkt)` nor `…/async-bridge.rkt`** — the providing
modules. This is a pre-existing 010 gap (its in-process smoke binds raw, so it
never loaded a generated class file); 020 inherits it for async. Wire it here when
the cold rerun generates + loads real framework files (the `RUNTIME_LOAD_TEST`
"require-shape" guard above): a class file needs `swift-trampoline.rkt` iff it emits
any trampolined instance method, and `async-bridge.rkt` iff any is `async`
(`MethodTrampoline::is_async`). **Also resolve the native-branch interaction:** the
`needs_native` (ffi2) header does `(except-in ffi/unsafe ->)`, but the async/sync
method ffi arrows use `(_fun … -> …)` — a class that both routes natively *and* has
Swift-native methods has no `->` in scope. Both surface together only at generate +
load, which is this leaf.

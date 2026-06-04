# 010-generate-gerbil-bindings

**Kind:** work

## Goal

Produce the **first full-framework gerbil emit**: regenerate the IR pipeline from
scratch, run the gerbil emitter over every framework, and confirm the hand-written
runtime still compiles under the bottle toolchain. No sample app yet — the
milestone is *bindings emitted + runtime compiles clean*, so 020 can import them.

## Context

The resolved/enriched IR is gitignored (reproducible) and absent locally; only the
152 committed `analysis/ir/llm-annotations/*.llm.json` survive. So the whole
pipeline must run before any gerbil binding exists. This is also the first time the
gerbil emitter runs over real Foundation/AppKit at scale — emitter-output bugs that
only show up across thousands of real symbols surface here, decoupled from
app/bundler work.

Steps:

1. **Regenerate IR** (memory: `SDKROOT=macosx` workaround for collect/extract):
   - `collection/ir/collected/` is empty → run collection first
     (`cargo run -p apianyware-macos-collect …`; ~2 min; gated on SDK headers).
   - `cargo run -p apianyware-macos-analyze -- all` (resolve → annotate[merges the
     committed LLM annotations when `--llm-dir` omitted] → enrich) →
     `analysis/ir/enriched/`.
2. **Emit gerbil**: `cargo run -p <cli> -- generate --target gerbil` → writes
   `generation/targets/gerbil/lib/<framework>/*.ss` + `lib/generics.ss`
   (the CLI pre-pass builds the cross-framework ClassRegistry + shared generics, see
   `cli/src/generate.rs`). Spot-check NSString / NSWindow / NSView modules look sane.
3. **Compile the runtime** under the **bottle** toolchain per `runtime/README.md`
   "Building" (symlink dance + `SDKROOT`): `clang -fblocks native_block.c`, then
   `gxc -O ffi.ss native-core.ss objc.ss` (+ `subclass.ss`). Runtime smokes still
   green (`runtime/tests/run-smokes.sh`).

## Done when

- `analysis/ir/enriched/` populated (Foundation + AppKit + deps present).
- `generation/targets/gerbil/lib/foundation/` and `lib/appkit/` emitted; `generics.ss` present.
- Runtime modules compile clean under the bottle toolchain; runtime smoke suite passes.
- Any emitter-output bug found at scale is fixed in `emit-gerbil` (or captured as a
  follow-up leaf if out of scope for hello-window).

## Notes

⚠️ Bottle toolchain for dev/measure; static toolchain is for distribution (020/030).
⚠️ Stale-`.o.lock` hazard: clear `~/.gerbil/lib/static/<mod>*` after a killed gxc.

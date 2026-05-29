# 030-standalone-build-pipeline — brief

## Goal
Productionise the spike's hand-driven scripts into `bundle-chez`: a new
`standalone.rs` module that builds a self-contained open-world `.app` for a chez
sample app. End state: a `hello-window` `.app` built **entirely through the Rust
bundler** (not shell scripts) that **launches and draws its window with no
system Chez** in a VM.

## Why this is a node (decomposed 2026-05-29)
The original `030` leaf folded four genuinely distinct concerns, and the crux
operation — `compile-whole-program` over the real AppKit closure — costs
**~160 s / ~1.6 GB RSS per iteration** (spike F7). Four concerns × dozens of
3-minute compile-debug cycles is not one focused session. The leaf brief
licensed this split ("May decompose into a node if the Rust orchestration +
wrapper-gen + prelude prove too big"). The four concerns become four leaves,
each with an isolated compile-debug loop and its own focused commit.

The split is **make-it-work-then-make-it-general**: `010` ports the
spike-proven mechanics (hand-coded wrapper for hello-window, spike's `chdir`
host) to get a green standalone via Rust fast; `020` generalises the wrapper to
any app; `030` swaps `chdir` for the cleaner prelude; `040` is the no-Chez VM
proof (the node's done-bar).

## Context
- Authoritative recipe + every gotcha: the spike report
  `docs/research/2026-05-29-chez-standalone-spike.md` (build pipeline §, findings
  F2–F9) and the design spec `docs/specs/2026-05-29-chez-standalone-distribution-design.md`
  (§2 pipeline, §3 wrapper, §4 prelude, §5 layout, §6 crate shape).
- Spike repro sources are committed under
  `docs/research/2026-05-29-chez-standalone-spike-evidence/` (`embed_main.c`,
  `hw-entry.ss`, `build_whole.sh`, `link_standalone.sh`, `assemble_app.sh`) —
  port these into the bundler, don't reinvent.
- `bundle-chez` today (`bundle.rs`, `deps.rs`, `launch.rs`, `precompile.rs`,
  `spec.rs`): the deps walker is reused; the wrapper generator builds on it.
- **Single mode** (D6 / ADR-0009): build open-world only. No build-mode enum.
- Idiom posture: [[feedback-chez-target-idiomatic-not-portable]].

## Children
- **`010-pipeline-skeleton-handwrapper.md`** (work) — port the spike pipeline
  into `standalone.rs`: a new `bundle_app_standalone` that runs
  whole-program compile → `make-boot-file` (full scheme boot) → `cc`-link
  `embed_main`+`libkernel.a` (+`liblz4.a`/`libz.a`; **not** `main.o`, F9) →
  assemble `.app` (Resources layout, F4) → codesign (F5). Uses a **hand-coded**
  hello-window wrapper (the spike's 4-`except` set, F2) and the spike's
  `chdir`-host (`embed_main.c`) to get a green standalone fast. `hello-window`
  builds + `codesign --verify --strict` passes, locally. Source-exec untouched.
- **`020-wrapper-generator.md`** (work) — replace the hand-coded `except` set
  with the automatic collision probe (chez `environment-symbols` script + Rust)
  that rewrites any app's `--script` entry into a strict top-level program
  (`(except <facade> …)` + `(scheme-start …)`). Generalises beyond hello-window.
- **`030-dylib-prelude-and-banner.md`** (work) — replace `embed_main.c`'s
  `chdir` with the spec §4 prelude object that sets `(library-directories)` from
  an exe-relative `../Resources` path (F3); banner suppression via
  `(suppress-greeting #t)` (F6).
- **`040-vm-verify-hello-window.md`** (work) — the node's done-bar: VM-verify the
  standalone `hello-window` draws its window in a **no-Chez** VM
  ([[feedback-use-testanyware]], [[reference-testanyware-cli]]).

## Done when (node)
- `standalone.rs` runs the spec §2 pipeline end-to-end from Rust; kernel-artifact
  paths discovered from the host Chez install (build-time dependency, documented
  for the `060` toolchain-docs leaf).
- The top-level-program wrapper is **generated** (F2/§3): collision set computed
  from the app's import closure; framework facades yield to `runtime/objc` +
  `(chezscheme)`; app authors keep `--script`-style entries.
- Dylib-search **prelude** (F3/§4): exe-relative `../Resources`, no `chdir`, no
  `--libdirs` stub. Banner suppressed (F6).
- Layout + signing (F4/F5/§5): boot + `lib/libAPIAnywareChez.dylib` under
  `Contents/Resources/`; `codesign --verify --strict` passes; unique CDHash per
  app under `APIAnyware Local Signing`.
- `hello-window` built via the bundler launches and draws its window in a no-Chez
  VM. (Full portfolio VM-verify is `050`.)
- Source-exec path **left working** alongside the new path — its deletion is
  node `040` (never without a green path).

## Notes
- Keep racket untouched — the stub-launcher is shared crate surface.
- Regenerate/rebuild aggressively after pipeline changes
  ([[feedback-regenerate-pipeline-aggressively]]).

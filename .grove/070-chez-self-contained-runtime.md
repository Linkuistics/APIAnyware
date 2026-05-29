# 070-chez-self-contained-runtime

**Kind:** planning

## Goal
Make a chez `.app` self-contained — it must launch on a machine with **no
Chez Scheme installed**, with no `brew install chezscheme` provisioning step.
Today the stub-launcher `execv`s the *system* `/opt/homebrew/bin/chez`
(`bundle.rs` `DEFAULT_CHEZ_PATH`), so the bundle hard-depends on a host Chez.

Two directions, **native compilation preferred** (the user's steer — "unless
we can do a native compilation"; Chez ships the machinery for it):

1. **Native standalone executable (preferred).** Chez has first-class support:
   `compile-whole-program` folds the app + all `(apianyware …)` libraries into a
   single optimised object/boot, `make-boot-file` builds a custom boot, and the
   kernel ships as linkable artifacts (`libkernel.a`, `main.o`, `scheme.h` —
   confirmed present under
   `/opt/homebrew/Cellar/chezscheme/10.4.1/lib/csv10.4.1/tarm64osx/`). Linking
   these yields a real native binary that embeds the kernel + boot, needs no
   installed Chez, and (bonus) the executable *is* the app — killing the
   menu-bar-reads-"chez" gotcha and obsoleting leaf-160's version fallback for
   standalone bundles.
2. **Bundle the runtime tree (fallback).** Ship `scheme`/`petite` + boot files
   inside the `.app` and have the stub `execv` the bundled binary instead of the
   system one. Heavier, simpler, no linking — the safety net if the standalone
   path is blocked.

This is a planning leaf: the approach has real unknowns that must be grilled and
spiked before committing to work leaves.

## Context
- **Current bundling:** `generation/crates/bundle-chez/` stages `.sls` (+ leaf-160
  `launch.ss`), precompiles to `.so`, copies `libAPIAnywareChez.dylib`, and the
  Swift stub execs the system chez `--libdirs … --script …/launch.ss`. See
  `knowledge/targets/chez.md` §6–7 and the design spec
  `docs/specs/2026-05-27-chez-target-design.md`.
- **Native-path machinery is present** (verified 2026-05-29 on Chez 10.4.1):
  `compile-program`, `compile-whole-program`, `compile-whole-library`,
  `make-boot-file`, `generate-wpo-files` all bound; kernel artifacts in the
  Cellar as above. Authoritative recipe: Chez Scheme User's Guide §2.8 / "Using
  Chez Scheme" (`cisco.github.io/ChezScheme/csug10.0/use.html`) and the
  `main.c`/kernel entry-points section (§4.9).
- 🔴 **Load-bearing constraint — the dispatch substrate needs the compiler at
  runtime.** `runtime/dispatch.sls` builds `foreign-callable` forms with
  `quasiquote` and **`eval`s them in `(interaction-environment)`** (chez.md 🔴
  2026-05-27) — that is how blocks, delegates, and dynamic subclasses get
  arbitrary runtime signatures. A `petite`-only boot has **no compiler**, so
  `eval` of those forms fails. The standalone **must embed the full `scheme`
  boot** (`make-boot-file … "scheme" "petite" …`), or the dispatch substrate
  must be reworked to avoid runtime `eval` (e.g. a fixed table of pre-compiled
  `foreign-callable` trampoline variants — note the trampolines are already a
  small enumerated set: `void`/`bool`/`id`/`int`/`long`, per
  `return-type->cstring`). Resolve this **first** — it gates the whole approach.
- **FFI must survive whole-program optimisation.** The target leans on
  `foreign-procedure`, `foreign-callable`, `load-shared-object`,
  `lock-object`, ftypes, guardians. Spike that a `compile-whole-program` build
  still loads `libAPIAnywareChez.dylib` + `libobjc.dylib` at runtime and that
  `foreign-callable`/`lock-object` behave under the embedded kernel.
- **TCC / codesigning.** The unique-CDHash-per-app rationale (stub-launcher) must
  carry over: a native standalone binary is signed directly (good — it already
  has a unique CDHash), but confirm the `com.linkuistics.*` bundle-id +
  persistent local-signing-identity story (`bundle.rs`
  `LOCAL_SIGNING_IDENTITY`) still grants TCC.
- **Relation to existing crates.** Decide whether this lives in `bundle-chez`
  (a new "standalone" mode alongside the current stub-exec mode) or a sibling.
  The stub-launcher is shared with racket — keep racket's path untouched.

## Done when (planning leaf)
- A short spike proves (or refutes) the preferred native path end-to-end for at
  least `hello-window`: `compile-whole-program` → `make-boot-file` (full scheme
  boot) → link `main.o`+`libkernel.a` → a standalone arm64 binary that opens the
  window **with no system Chez on PATH** and with the FFI/dispatch substrate
  working (a delegate or block callback fires — exercises the `eval` path).
- The dispatch-substrate-needs-compiler question (above) is answered: either
  "embed full scheme boot, size cost X" or "rework dispatch to drop runtime
  `eval`" — captured as an ADR if it forces a runtime change.
- A design spec section (or new spec) records the chosen approach, the bundle
  layout, the build-pipeline changes (where `compile-whole-program`/link runs —
  in `bundle-chez`?), bundle-size + cold-launch numbers vs today, and whether
  leaf-160's `launch.ss` fallback is retired for standalone bundles.
- Work leaves are grown for the implementation (and a VM-verify leaf per
  [[feedback-use-testanyware]] — the real test is "launch on a vanilla VM with
  Chez **uninstalled**", a stronger bar than leaf 160's).
- If the native path is refuted, the fallback (bundle the runtime tree) is
  specced instead, with its size/launch trade-offs documented.

## Notes
- This may obsolete several deferred follow-ups at once: leaf-160 version
  coupling (no system chez → no version mismatch), the menu-bar-name gotcha
  (chez.md 🟢 2026-05-26), and the golden-image Chez pre-install note (050
  brief) — all evaporate for a standalone binary. Note that in the spec.
- **Ordering:** appended after `060-rewrite-adding-language-target.md`. If the
  distribution model should land *before* the adding-a-language-target doc is
  finalised (the doc's bundler section would otherwise describe the soon-stale
  stub-exec-system-chez model), reorder via `grove-llm leaf-insert` — flagged
  for the operator, not assumed.
- Regenerate/rebuild aggressively after pipeline changes
  ([[feedback-regenerate-pipeline-aggressively]]); idiom posture still applies
  ([[feedback-chez-target-idiomatic-not-portable]]).

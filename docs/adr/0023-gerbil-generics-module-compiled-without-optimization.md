# Gerbil: compile the shared `generics.ss` module without optimization

**Status:** accepted, but **necessary-not-sufficient** — the cold-build
re-measure (grove leaf `090/010`, below) proved no-`-O` alone misses the budget;
the durable fix is **no-`-O` + splitting `generics.ss`** (grove leaf `090/020`).
This change is kept because it composes with and is required by the split.

## Context

The gerbil dual-surface object model (ADR-0020) gives every class a
`:std/generic` consumption surface. To keep a selector shared by unrelated
classes a *single* generic (not N colliding per-module generics that clash at
the framework facade), the emitter declares every distinct instance-surface
selector **once** in a shared package-root module, `generics.ss` — one
`(g:defgeneric <sel>)` per selector (`emit_generics.rs`).

For just AppKit + Foundation that is **6,496 declarations** in a 415 KB source
file. The `:std/generic` macro expands each `defgeneric` heavily, so the one
module becomes a 60 MB Gambit `.scm` / 94 MB `.c` translation unit. A **cold**
build (`build/` is gitignored; every fresh checkout is cold) measured **~5h**
for a single sample app, dominated by this one module: `gsc -target C` ran
~2h44m single-threaded and `gcc -O1` ran ~2h+ at 9.7 GB RSS. Both compile
stages are **superlinear in module/translation-unit size**, and `gxc -O` drives
both. At that cost the per-app VM-verify portfolio (six more apps) is
impractical (grove node `100-sample-apps`).

Because `generics.ss` is imported by *every* class module, even a tiny app like
hello-window (≈7 classes) drags the full monolith into its compile closure.

## Decision

Compile `generics.ss` **without optimization** — a separate, un-`-O` `gxc` pass,
ordered before the optimized closure pass that compiles the rest. The module is
**pure declarations**: `(g:defgeneric …)` creates empty generic objects; the
actual methods (`g:defmethod`) live in class modules and the hot dispatch
machinery lives in the `:std/generic` stdlib (both still compiled `-O`). There
is therefore **nothing in this module worth optimizing** — `-O` buys it no
runtime speed while costing hours of build time. Mixed-optimization linking is
sound in Gerbil (the `.ssi` interface is opt-independent; the exe links the
cached `.o1`).

This is a deliberate, scoped exception to ADR-0021 ("every emitted module
compiles under default flags"): ADR-0021 is about *which C compiler / no special
gcc flags*; this is about the *optimization level passed to `gxc`* for one
generated module whose content is optimization-inert.

## Considered alternatives

- **Split `generics.ss` into N bounded modules** (parallelizable, sidesteps
  per-unit superlinearity). The durable fix if no-`-O` alone misses the
  `< 15 min/app cold` budget; deferred as the escalation rather than done up
  front (grove probe-first, lazy decomposition).
- **Persist/commit a warm `gerbil-cache`.** Rejected: fights the `build/`
  gitignore and bloats the repo (94 MB C + objects) to paper over an
  architectural cost.
- **Closure-scoped / per-framework generics.** Architecturally right for
  scaling to the full-macOS binding set, but does not shrink today's
  2-framework cost (an app pulls both frameworks regardless). Out of scope here.

## Measured outcome (grove leaf 090/010, 2026-06-08)

Implemented the no-`-O` generics pass in `compile.rs` and re-measured a cold
hello-window build (`build/` wiped, BOTTLE 0.18.2, `SDKROOT` exported). Findings:

- **No-`-O` helped but did not solve it.** Gambit's expansion of `generics.ss`
  shrank (`generics~1.scm` 60 MB → 37.8 MB) and peak RSS fell 9.7 GB → ~4.8 GB
  (the swap thrash is gone). But `gsc -target C` on the 37.8 MB unit ran **>67
  min and had still not finished** (build killed at 73 min, never reaching gcc).
- **`gsc` itself is superlinear in module size, independent of `-O`.** The
  Scheme→C stage — not just `gcc -O1` — chokes on one giant macro-expanded unit.
  Removing `-O` attacks the *optimizer*; it cannot fix the raw *size*.
- **It's a size threshold.** Gambit auto-split the module into `generics~0`
  (16.9 MB, compiled fine) + `generics~1` (37.8 MB, pathological). Bounded units
  are the fix.

**Conclusion:** keep no-`-O` (strict improvement, composes with the split) and
**split `generics.ss` into many small modules** (leaf `090/020`) — bounded,
parallelizable `gsc` invocations. Compiling each small shard *also* without
`-O` is the intended end state (small + unoptimized = fast). The true
non-generics residual is still unmeasured (the build never got past generics);
leaf `090/020` is the first chance to measure it against the `< 15 min` budget.

## Consequences

- Cold-build budget: **`< 15 min/app`**, the done-bar for node `100-sample-apps`.
- The shipped `.app` is **unaffected** — this is purely a build-time change; the
  binary runs and launches identically.
- A residual cost (~23 min in the original measurement) for the non-generics
  modules + link was measured while generics' gcc was thrashing swap, so it may
  be inflated; the re-measure isolates it. If the residual alone exceeds budget,
  it becomes its own follow-up (parallelizing class-module compiles / the link),
  independent of the generics fix.

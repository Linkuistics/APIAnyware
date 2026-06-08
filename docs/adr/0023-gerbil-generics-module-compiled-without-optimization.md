# Gerbil: compile the shared `generics.ss` module without optimization

**Status:** accepted (probe-gated — the durable remedy is confirmed by the
cold-build re-measure in grove leaf `090-generics-compile-cost/010`; if it
misses the budget, splitting `generics.ss` follows and this ADR is amended).

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

## Consequences

- Cold-build budget: **`< 15 min/app`**, the done-bar for node `100-sample-apps`.
- The shipped `.app` is **unaffected** — this is purely a build-time change; the
  binary runs and launches identically.
- A residual cost (~23 min in the original measurement) for the non-generics
  modules + link was measured while generics' gcc was thrashing swap, so it may
  be inflated; the re-measure isolates it. If the residual alone exceeds budget,
  it becomes its own follow-up (parallelizing class-module compiles / the link),
  independent of the generics fix.

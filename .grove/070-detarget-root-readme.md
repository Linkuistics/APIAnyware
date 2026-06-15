# 070-detarget-root-readme

**Kind:** work

## Goal

The root `README.md` is the **main (cross-cutting) tier** entry point, but several
sections carry purely **racket-specific** content that violates the
main/per-language split (ADR-0024). Trim those to cross-cutting essentials and
point at the canonical per-target / testing docs, which already cover the detail.
Surfaced at grove-finish: a structural (tier-placement) gap leaf 060's link grep
could not catch.

## Context

Discovered when proposing Finish. The racket detail in the README is **duplicated**
— it already lives in the right co-located docs, so this is a *trim-and-point*, not
a content move:

- racket bundling deep-dive → `generation/targets/racket/docs/reference.md` §9 and
  `generation/targets/racket/docs/developer-guide.md` already cover bundle-racket,
  the require-walker, stub-launcher, and the bundle tree.
- TestAnyware VM recipe → `docs/testing/general.md` is the canonical QA workflow.
- emitter internals → racket `reference.md` §2 covers DispatchStrategy / coerce-arg.

## Done when

Root `README.md` reads as cross-cutting, with racket detail replaced by pointers:

- **`#### Per-language convention: apianyware-macos-bundle-racket`** (the detailed
  require-walker / `bundle_app` / bundle-tree block) trimmed to a short
  cross-cutting note on the per-target bundler pattern + pointer to racket's
  reference.md §9 / developer-guide. The language-agnostic `stub-launcher`
  description stays (it is cross-cutting).
- **`### Key Patterns`** racket-emitter internals (`DispatchStrategy in emit-racket`,
  `coerce-arg in Racket runtime`, racket golden paths) removed or generalized; keep
  only cross-cutting emitter-framework patterns (`effective_methods()`,
  `build_snapshot_test_framework()`).
- **`### GUI Testing with TestAnyware`** reduced to the cross-cutting principle
  (VM-verify every app, never run GUI from CLI, the two channels) + pointer to
  `docs/testing/general.md`; the racket-flavored recipe (minimal-racket,
  bundle-racket, pkill racket) dropped or made target-neutral.
- **Crate Map** de-staled: Generation lists all three emitters (or generalizes);
  the Swift-dylibs note drops the dissolved `APIAnywareCommon` framing (ADR-0011)
  and stops implying racket is the only bridge.
- No new dangling links; cross-cutting pointers resolve; `cargo check` still green
  if any code-adjacent doc paths change (none expected).

## Non-goals

- Rewriting racket's per-target docs (they already cover the detail).
- Touching `docs/superpowers/` (off-limits) or non-doc code.

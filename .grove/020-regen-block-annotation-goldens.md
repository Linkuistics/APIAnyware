# 020-regen-block-annotation-goldens

**Kind:** work

## Goal
Green the two failing snapshot tests by regenerating their stale goldens to
match the current emitter's block-param annotation output. This is issue #1 —
the urgent regression deferred from `add-chez-target`. Single concern: emitter
*output* drift, nothing else.

## Context
- Failing tests: `snapshot_racket_foundation_subset`,
  `snapshot_racket_appkit_subset` in
  `generation/crates/emit-racket/tests/snapshot_test.rs`.
- The drift was introduced by commit `c6e8b95` (the `add-chez-target/040`
  racket-oo→racket rename leaf); goldens were never regenerated. The emitter
  output is correct; the goldens are stale.
- Expected diff (~15 lines across 6 class files): block params now annotated
  `async-copied (runtime-managed)` (was `stored (retained across calls)`), and
  a dropped `;; Threading: this class has main-thread-only methods.` comment
  line. Affected goldens: `golden-appkit/{nsapplication,nscolor,nsimage}.rkt`
  and `golden-foundation/{nserror,nsfilemanager,nstimer}.rkt`.
- The snapshot tests re-emit from committed enriched IR and never shell out to
  xcrun, so this regen will NOT touch enum SDK paths (those change only in 040).

## Done when
- Ran `SDKROOT=macosx UPDATE_GOLDEN=1 cargo test -p apianyware-macos-emit-racket
  --test snapshot_test`.
- Reviewed the golden diff and **confirmed it is limited to** the block-param
  annotation wording + the dropped threading comment described above — no other
  files changed, no enum-path changes. If anything else drifted, STOP and
  investigate before committing (do not blanket-accept).
- `SDKROOT=macosx cargo test -p apianyware-macos-emit-racket --test
  snapshot_test` is green.
- One focused commit containing only the regenerated golden files.

## Notes
- Must run under `SDKROOT=macosx` (this host's xcrun is broken — see
  `project_sdkroot_workaround`).

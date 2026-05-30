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

## Resolution (corrected) — no golden regen; goldens are already correct
The plan's premise was wrong twice over and the urgent regression does not
exist. Evidence-based finding:

1. **The enriched IR is gitignored, not committed** (`.gitignore` excludes
   `analysis/ir/enriched/`; Foundation 16 MB, AppKit 90 MB; present only in the
   main checkout). In a clean worktree it is absent, so
   `load_enriched_framework` returns `None` and the Foundation/AppKit snapshot
   tests **silently skip and report `ok`** — they test nothing. (My first commit
   `c2c4745` concluded "no regen needed" from these skipped tests: right
   conclusion, wrong reasoning.)
2. With the main-repo IR (21 May) copied in, the two tests **fail** — but
   `UPDATE_GOLDEN` would *strip* annotations, not fix drift: it removes
   protocol-level `— block param N: async-copied (runtime-managed)` (×6) and
   `weak reference` (×2) notes the committed goldens already carry.
3. Root cause: the 21-May IR's enrichment is **under-enriched** vs the IR that
   produced the goldens — `weak_param_methods`, `protocol_async_block_methods`,
   `protocol_stored_block_methods`, `protocol_weak_param_methods` are all
   **null**. The goldens were generated from a later analysis pipeline that
   computes those fields. So the goldens are the *richest, most correct*
   artifact; the "failure" is a stale local IR lagging the goldens, the reverse
   of the plan's "stale goldens lagging the emitter."

**Action: none on the goldens.** Per the grove's goldens-as-truth decision
(2026-05-30), the committed block-annotation goldens are kept as-is. The
block-annotation drift the plan predicted (stored→async, dropped threading
comment) does not occur — it was misattributed to commit `c6e8b95`, which was a
pure directory rename. Issue #1 requires no code or golden change.

# 040-migrate-ir-regen-normalized-goldens

**Kind:** work

## Goal
Land the normalized, environment-independent unnamed-enum paths in the committed
artifacts: migrate the committed Foundation/AppKit enriched IR (unnamed-enum
names only) to match the 030 transform, then regenerate the snapshot goldens so
`enums.rkt` reflects the relative paths. Issue #2, data half. Write the ADR that
records the decision.

## Context
- Depends on 030 (the canonical transform). The migration applies the **same**
  prefix-strip to the committed IR rather than re-running the full pipeline —
  deliberately, to avoid importing MacOSX-SDK-version drift (new/changed enums)
  that a host regen under a newer SDK would bring (grilling Q2; see
  `010-plan.md` decision log and `feedback_regenerate_pipeline_aggressively`).
- Target files: `analysis/ir/enriched/Foundation.json`,
  `analysis/ir/enriched/AppKit.json`. Only the `name` of unnamed enums changes:
  `"enum (unnamed at /Applications/.../MacOSX.sdk/System/Library/.../Foo.h:L:C)"`
  → `"enum (unnamed at System/Library/.../Foo.h:L:C)"`. Everything else stays
  byte-identical.
- Migration should be a deterministic rewrite (a tiny script, or reuse the 030
  helper) — not hand-editing. Verify with `git diff --stat` that ONLY
  unnamed-enum name lines changed in the two JSONs (Foundation has 16 such
  names; AppKit similar).
- After migrating IR, regen goldens:
  `SDKROOT=macosx UPDATE_GOLDEN=1 cargo test -p apianyware-macos-emit-racket
  --test snapshot_test`. Only `golden-foundation/enums.rkt` and
  `golden-appkit/enums.rkt` should change (absolute → relative enum paths).

## Done when
- Committed Foundation/AppKit enriched IR have SDK-relative unnamed-enum names;
  `git diff` confirms no other IR fields changed.
- `golden-{foundation,appkit}/enums.rkt` regenerated; diff limited to the
  enum-path relativization.
- `SDKROOT=macosx cargo test -p apianyware-macos-emit-racket --test
  snapshot_test` green.
- ADR written under `docs/adr/` (next free number; last seen was 0012):
  "Unnamed-enum source locations are SDK-relative, normalized at collection
  time" — rationale includes why the committed IR was hand-migrated rather than
  full-pipeline-regenerated (scope-limit the diff; avoid SDK-version drift on a
  host with broken xcrun). Cross-reference from the brief's ADR-candidate note.
- One focused commit: migrated IR + regenerated enum goldens + the ADR.

## Notes
- Must run under `SDKROOT=macosx`.
- If the migration script is throwaway, do not leave it committed; if it is
  reusable, place it where pipeline tooling lives and say so in the commit.

## Resolution (reframed under goldens-as-truth)
The leaf assumed a *committed* enriched IR to migrate; there is none — the IR
(`analysis/ir/enriched/*.json`, 16/90 MB) is gitignored. The committed artifact
that carries the absolute SDK path is the **goldens**
(`golden-{foundation,appkit}/enums.rkt`, 16 + 28 unnamed-enum lines; no other
golden file contains an absolute path). So the data migration target is the
goldens, not the IR.

What was done:
- Verified the absolute prefix appears in the local IR **only** within
  unnamed-enum names (16 + 28 = 44, zero elsewhere) — blast radius is exactly
  those names, matching 030's premise.
- Emitter-authoritative regen: applied 030's prefix-strip to the local IR's enum
  names, ran `UPDATE_GOLDEN`, kept only the two `enums.rkt` changes, and reverted
  the 3 unrelated files that `UPDATE_GOLDEN` would have *regressed* (the local IR
  is under-enriched — see 020 — so a blanket regen strips correct block/weak
  annotations). Net committed diff: 44 lines, absolute → `System/Library/...`,
  nothing else.
- Round-trip confirms 030 ⇄ 040 consistency: `enums.rkt` is no longer in the
  snapshot DIFFERS set, so a future fresh-IR regen reproduces it exactly.
- ADR `docs/adr/0010-unnamed-enum-sdk-relative-paths.md` records the decision and
  why the IR was *not* hand-migrated/full-regenerated.
- No migration script left behind (a one-shot string-replace on a gitignored,
  now-removed local IR copy).

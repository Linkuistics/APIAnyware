# 010-plan

**Kind:** planning

## Goal
Plan the racket-emitter-cleanup grove: turn the deferred inbox observation
(racket golden-test drift + SDK-path brittleness) into a scoped tree of work
leaves. Deliverable: the root `BRIEF.md` and ordered work leaves 020/030/040.

## Context
- Seed: inbox observation drained at bootstrap and triaged **incorporated** —
  it defined the whole scope (deferred from `add-chez-target`, 2026-05-30).
- Memory: `project_racket_golden_drift_deferred` (origin of this grove).

## Done when
- Root brief written; work leaves created and fleshed out; decision log below
  complete; planning leaf retired. (Done — see decisions.)

## Decisions (running log)

### Pre-grilling exploration — findings that reshaped the plan
- `emit_enums.rs` is a dumb printer (`;; {en.name}` then `(define …)`). For
  *unnamed* enums, libclang's `entity.get_name()` returns the entire
  `enum (unnamed at <abs-path>:line:col)` string, so the SDK path is baked into
  the **enriched IR JSON upstream**, not computed in the emitter.
- The committed `analysis/ir/enriched/Foundation.json` already holds the
  **generic** `MacOSX.sdk` (no versioned `MacOSX26.5.sdk`), and the snapshot
  tests re-emit from that committed JSON — they never shell out to xcrun.
  ⇒ `UPDATE_GOLDEN` regen is **safe**; it changes only block-param annotation
  lines. The "regen bakes in the host's versioned SDK path" risk belongs to the
  *full collect→analyse pipeline*, not the snapshot regen. The original deferral
  note conflated the two.
- The unnamed-enum name is the **only** IR field carrying an absolute SDK path
  (verified across enriched JSON). Blast radius of normalization is tiny.
- Fix location settled by evidence: `extract_enum()` in
  `collection/crates/extract-objc/src/extract_declarations.rs` (~L716), reusing
  the `strip_prefix(sdk_path)` pattern from `extract_provenance()` (~L1041);
  `sdk_path` is already in scope there.
- Target form settled by evidence: match `SourceProvenance.header` exactly —
  `System/Library/Frameworks/.../Foo.h` (committed IR confirms this is the
  existing relative form), giving
  `enum (unnamed at System/Library/Frameworks/.../Foo.h:line:col)`.

### Q1 — Grove scope → **Medium: tests + SDK normalization**
Green the failing snapshot tests AND implement SDK-path normalization upstream,
so a future full pipeline regen is reproducible across machines. (Not narrow
green-only; not a broad open-ended emitter cleanup.)

### Q2 — How the normalization reaches committed IR/goldens → **Code fix + targeted IR migration**
Land the `extract_enum` fix (+ unit test), then deterministically rewrite ONLY
the unnamed-enum name strings in the committed Foundation/AppKit enriched IR
(provably isolated field, pure prefix-strip), then `UPDATE_GOLDEN`. Chosen over
a full collect→analyse pipeline regen because that would import unrelated
MacOSX26.5 SDK-version drift (new/changed enums, decls) far beyond this grove's
scope, on a host with broken xcrun. Conscious, documented scope-down of
`feedback_regenerate_pipeline_aggressively` — justified because the migrated
field is deterministic and provably isolated; everything else in the IR stays
byte-identical. → ADR-worthy (see below).

### Q3 — Normalized path form → settled by exploration, not asked
Reuse `extract_provenance`'s `strip_prefix(sdk_path)` verbatim for consistency
with `SourceProvenance.header`. No user input needed.

### Q4 — Decomposition / commit granularity → **3 leaves, split issue #1 / #2**
- `020` issue #1 (urgent): regen block-annotation goldens → greens the 2 tests,
  isolated/bisectable single-concern commit. No deps.
- `030` issue #2 logic: `extract_enum` normalization + unit test.
- `040` issue #2 data: targeted IR migration + golden regen + ADR. Depends on
  030. Issue #2 thus contiguous (030+040); urgent fix (020) lands first.

### ADR candidate (to write in 040)
"Unnamed-enum source locations are SDK-relative, normalized at collection time;
committed IR hand-migrated rather than full-pipeline-regenerated." Meets all
three ADR criteria: hard to reverse (re-running the pipeline would re-introduce
absolute paths if the fix regressed; the invariant must be documented),
surprising without context (a reader will ask why these names are relativized
and why the IR was hand-migrated), and a real trade-off (targeted migration vs.
aggressive full regen). Next free number ≈ 0013.

### Glossary
No new ubiquitous-language terms resolved — the work is implementation detail,
which `CONTEXT.md` deliberately excludes. No glossary edit made.

## Notes
All racket-emitter tests must run under `SDKROOT=macosx` on this host
(`project_sdkroot_workaround`).

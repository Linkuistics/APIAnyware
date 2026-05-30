# racket-emitter-cleanup — brief

## Goal
Resolve the two entangled racket-emitter issues deferred from the
`add-chez-target` grove: (1) the two failing snapshot tests
(`snapshot_racket_foundation_subset`, `snapshot_racket_appkit_subset`) whose
goldens are stale after the emitter's block-param annotation change, and
(2) the SDK-path brittleness whereby unnamed-enum names carry an absolute,
host-specific SDK path. Land an environment-independent normalization so a
future full-pipeline regen is reproducible across machines.

## Done when
- `SDKROOT=macosx cargo test -p apianyware-macos-emit-racket --test snapshot_test`
  is green.
- Unnamed-enum names in the committed Foundation/AppKit enriched IR and in the
  snapshot goldens use an SDK-relative path
  (`enum (unnamed at System/Library/Frameworks/.../Foo.h:line:col)`),
  consistent with `SourceProvenance.header`.
- The collection extractor (`extract_enum`) normalizes unnamed-enum names at
  source, with a unit test covering the transform, so future regens stay clean.

## Decomposition
Scope is **medium**: green the tests AND implement SDK-path normalization
upstream (grilling Q1). Three work leaves:
- `020` — issue #1: regen the block-annotation goldens; greens the two failing
  tests in a single-concern commit (the urgent regression). No dependencies.
- `030` — issue #2 logic: normalize unnamed-enum SDK paths in `extract_enum`
  (collection phase) + unit test. Establishes the canonical, tested transform.
- `040` — issue #2 data: targeted migration of the committed Foundation/AppKit
  enriched IR (unnamed-enum names only) + golden regen, so the normalized,
  env-independent path lands in committed artifacts. Depends on 030's transform.

## Pointers
- Glossary terms in play: **Target**, **`objc-object`** (see `CONTEXT.md`) — no
  new terms resolved by this grove (the work is implementation detail, not
  ubiquitous language).
- Key code (collection): `collection/crates/extract-objc/src/extract_declarations.rs`
  — `extract_enum()` (~L716, where clang's `entity.get_name()` yields the
  unnamed-enum string) and `extract_provenance()` (~L1041, the existing
  `strip_prefix(sdk_path)` relativization to reuse).
- Key code (emitter): `generation/crates/emit-racket/src/emit_enums.rs` (dumb
  printer: `;; {en.name}`), `tests/snapshot_test.rs`, and the golden dirs
  `tests/golden-foundation/`, `tests/golden-appkit/`.
- Committed enriched IR: `analysis/ir/enriched/{Foundation,AppKit}.json`.
- ADR candidate (write during 040): "unnamed-enum source locations are
  SDK-relative, normalized at collection time; committed IR hand-migrated rather
  than full-pipeline-regenerated to avoid importing SDK-version drift." Meets all
  three ADR criteria — see `010-plan.md` decision log.
- Project memory: `project_racket_golden_drift_deferred` (origin),
  `project_sdkroot_workaround` (why `SDKROOT=macosx` is required on this host),
  `feedback_regenerate_pipeline_aggressively` (the principle the 040 migration
  consciously scopes-down — rationale in the decision log).

## Notes
- Environment: this host's `xcrun` default-SDK resolution is broken; run all
  racket-emitter tests under `SDKROOT=macosx`. A planned OS reinstall may clear
  it.
- Key finding from planning: the snapshot tests re-emit from the *committed*
  enriched IR JSON (they never shell out to xcrun), and that committed IR already
  holds the generic `MacOSX.sdk`. So `UPDATE_GOLDEN` regen is **safe** — the
  SDK-version brittleness belongs to the *full collect→analyse pipeline*, not the
  snapshot regen. The original deferral note conflated the two.
- Absolute SDK paths appear in **exactly one** IR field — unnamed-enum names —
  and nowhere else (verified). The normalization blast radius is tiny.

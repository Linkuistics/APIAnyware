# Unnamed-enum source locations are SDK-relative, normalized at collection time

libclang reports the "name" of an anonymous enum as a synthetic string of the
shape `enum (unnamed at <abs-path>:<line>:<col>)`, where `<abs-path>` is the
host-specific absolute path to the SDK header
(`/Applications/Xcode.app/.../MacOSX.sdk/System/Library/.../Foo.h`). This is the
**only** IR field that carries an absolute SDK path — every other source
location (`SourceProvenance.header`) is already relativized. Left unnormalized,
the absolute path bakes a machine- and Xcode-version-specific string into the
generated bindings, so the same headers produce different output on different
machines.

**Decision:** relativize the unnamed-enum name **at collection time**, in
`extract_enum` (`collection/crates/extract-objc/src/extract_declarations.rs`),
reusing the same `strip_prefix(sdk_path).unwrap_or(path)` relativization as
`extract_provenance`. The embedded path becomes SDK-relative
(`System/Library/.../Foo.h`), matching `SourceProvenance.header`, so all freshly
collected IR is environment-independent. Named enums and any path not under the
SDK root pass through unchanged.

The committed snapshot goldens (`generation/crates/emit-racket/tests/golden-{foundation,appkit}/enums.rkt`)
were normalized **in place** to the same relative form — a deterministic
prefix-strip of the 16 + 28 unnamed-enum comment lines, touching nothing else,
verified emitter-consistent by a round-trip (strip the local IR's enum names,
let the emitter regenerate, confirm `enums.rkt` comes out byte-identical to the
committed normalization).

## Considered options

- **Full `collect → analyse` pipeline regen on the host.** Rejected. It would
  import unrelated MacOSX-SDK-version drift (new/changed enums and decls) far
  beyond this change's scope, on a host whose `xcrun` default-SDK resolution is
  broken. Worse, the enriched IR is **gitignored**, so a regen would not land in
  any committed artifact, and the locally available IR is *under-enriched*
  (its enrichment lacks `weak_param_methods` / `protocol_*_block_methods`), so a
  blanket `UPDATE_GOLDEN` would **strip** correct block/weak annotations from
  unrelated goldens rather than only relativizing enum paths.

- **Hand-migrate the committed enriched IR** (the original plan). Moot. The
  enriched IR (`analysis/ir/enriched/*.json`, Foundation 16 MB / AppKit 90 MB) is
  **gitignored, not committed** — there is no committed IR in git to migrate. The
  committed artifact that actually carries the absolute path is the snapshot
  goldens, so the in-place golden normalization *is* the data migration.

- **Normalize at collection + in-place golden edit (chosen).** Fix the source so
  future IR is relative; surgically relativize the only committed files that hold
  the absolute path; prove the two agree by round-trip. Smallest, deterministic,
  byte-isolated diff; closes the env-independence loop without importing SDK
  drift.

## Consequences

- All freshly collected IR has SDK-relative unnamed-enum names; a future
  fresh-IR `UPDATE_GOLDEN` reproduces exactly the committed `enums.rkt`.
- The transform assumes POSIX header paths contain no `:` (so the two rightmost
  colons delimit line/column); documented at the `relativize_unnamed_name`
  helper. A path with an embedded `:` would fall through unchanged via the
  `strip_prefix` fallback rather than corrupt.
- The racket snapshot tests remain **non-hermetic**: because the enriched IR is
  gitignored, `load_enriched_framework` returns `None` in a clean worktree and
  the Foundation/AppKit cases skip-as-pass. Making those tests hermetic (a
  pinned IR fixture) is a separate, deferred concern — see the grove's
  goldens-as-truth decision (2026-05-30).

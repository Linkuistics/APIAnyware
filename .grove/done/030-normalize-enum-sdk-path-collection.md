# 030-normalize-enum-sdk-path-collection

**Kind:** work

## Goal
Normalize the absolute SDK path that libclang bakes into unnamed-enum names, at
its source in the collection phase, so future regens produce environment-
independent IR. Establishes the canonical, unit-tested transform that leaf 040
then applies to the committed IR. Issue #2, logic half.

## Context
- The string `enum (unnamed at /Applications/Xcode.app/.../MacOSX.sdk/System/
  Library/Frameworks/.../Foo.h:line:col)` is returned **verbatim by libclang**
  via `entity.get_name()` in `extract_enum()` at
  `collection/crates/extract-objc/src/extract_declarations.rs` (~L716–778, name
  set ~L717). It is not constructed in Rust.
- Reuse the existing relativization already in the same file:
  `extract_provenance()` (~L1041–1067) does
  `path.strip_prefix(sdk_path).unwrap_or(&path)`. `sdk_path` is already passed
  into `extract_enum()` (call chain: `extractor.rs` →
  `extract_from_translation_unit` → EnumDecl branch → `extract_enum(entity,
  sdk_path)`).
- Target form (must match `SourceProvenance.header` exactly, verified in
  committed IR): strip through the SDK root so the path becomes
  `System/Library/Frameworks/Foundation.framework/Headers/FoundationErrors.h`,
  yielding the name
  `enum (unnamed at System/Library/Frameworks/Foundation.framework/Headers/FoundationErrors.h:11:1)`.
- Only unnamed-enum names carry an absolute path; no other IR field does
  (verified). So the transform need only fire when the name matches the
  `... (unnamed at <path>:line:col)` shape.

## Done when
- `extract_enum` normalizes the unnamed-enum name: detect the
  `(unnamed at <path>...)` shape, `strip_prefix(sdk_path)` the path portion,
  reconstruct the name (preserve the `:line:col)` suffix). Named enums are
  untouched. Path that does not start with `sdk_path` falls through unchanged
  (same `unwrap_or` fallback as `extract_provenance`).
- A unit test covers: (a) an unnamed enum with a path under `sdk_path` →
  relativized; (b) a named enum → unchanged; (c) a path not under `sdk_path` →
  unchanged. Test lives with the extractor crate.
- `cargo test -p apianyware-macos-extract-objc` (or the crate's actual package
  name) is green.
- One focused commit: the `extract_enum` change + its unit test. No IR or golden
  files touched here (that is 040).

## Notes
- Prefer a small private helper (e.g. `relativize_unnamed_name(name,
  sdk_path)`) so the unit test targets it directly without needing a live clang
  translation unit.
- Confirm the crate's exact Cargo package name before running the test.

//! The macOS **platform manifest** (`structural-refactoring` grove, workstream 4).
//!
//! `platforms/macos/platform.apiw` is the authored, **policy-only** description of
//! the macOS source platform — its SDK name, its source-availability floor, and
//! the framework roster as an include/ignore *policy*. It is projection-free
//! platform truth (REFACTOR §13/§14; node-brief decision D1): it states what the
//! platform *is*, never how any target expresses it. The resolved framework roster
//! and the cross-family dependency graph are *derived* from the SDK scan + the
//! `api/<F>/` triad and are never committed (constraint 4).
//!
//! This crate is the manifest's reader + a focused validator — the lightest home
//! that keeps the authored file green, and the seam workstream 6 reads the floor
//! from. The concerns, one per module:
//!
//! - [`manifest`] — the typed model ([`PlatformManifest`], [`FrameworkPolicy`], …)
//!   + the `.apiw` (KDL 2.0) parser + the parse-time semantic checks
//!   (`ignore` / `subframework-allow` uniqueness; the two sets are disjoint).
//! - [`schema`] — **structural** validation against the language-neutral
//!   `platform.kdl-schema`, reusing `apianyware-spec-format`'s generic KDL-Schema
//!   engine (ADR-0046 §3).
//!
//! The path-aware [`load`] adds one further check the parse-time layer cannot: the
//! platform name matches its containing directory (`platforms/<name>/`), which
//! `platform.kdl-schema` requires the conforming loader to enforce.

pub mod error;
pub mod manifest;
pub mod schema;

pub use error::{PlatformManifestError, Result};
pub use manifest::{
    parse_manifest, DiscoverSource, FrameworkPolicy, IgnoredFramework, PlatformManifest,
};
pub use schema::validate_platform_manifest;

use std::path::Path;

/// Load a platform manifest from a `.apiw` string: structural schema validation
/// first, then parse into the typed model (which runs the semantic checks).
///
/// `source_name` labels diagnostics (typically the file name).
pub fn load_str(source_name: &str, text: &str) -> Result<PlatformManifest> {
    validate_platform_manifest(source_name, text)?;
    parse_manifest(source_name, text)
}

/// Load a platform manifest from a file path. Convenience over [`load_str`], plus
/// the directory-name check `platform.kdl-schema` requires: the platform name must
/// match the containing directory (`platforms/<name>/`).
pub fn load(path: &Path) -> Result<PlatformManifest> {
    let text = std::fs::read_to_string(path).map_err(|source| PlatformManifestError::Io {
        path: path.display().to_string(),
        source,
    })?;
    let source_name = path
        .file_name()
        .and_then(|n| n.to_str())
        .unwrap_or("platform.apiw");
    let manifest = load_str(source_name, &text)?;
    check_dir_name(&manifest, path)?;
    Ok(manifest)
}

/// Enforce that the manifest's platform name matches its containing directory.
///
/// Pure (no IO) so it is unit-testable with synthetic paths. A path with no usable
/// parent directory name (e.g. a bare `platform.apiw`) skips the check rather than
/// inventing a failure — the directory invariant only applies when there is a
/// directory to compare.
fn check_dir_name(manifest: &PlatformManifest, path: &Path) -> Result<()> {
    let dir = path
        .parent()
        .and_then(|p| p.file_name())
        .and_then(|n| n.to_str());
    match dir {
        Some(dir) if dir != manifest.name => Err(PlatformManifestError::NameMismatch {
            name: manifest.name.clone(),
            dir: dir.to_string(),
        }),
        _ => Ok(()),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::manifest::{FrameworkPolicy, PlatformManifest};

    fn manifest(name: &str) -> PlatformManifest {
        PlatformManifest {
            name: name.to_string(),
            doc: None,
            sdk: "macosx".to_string(),
            deployment_target: "14.0".to_string(),
            frameworks: FrameworkPolicy {
                discover: vec![],
                subframework_allow: vec![],
                ignore: vec![],
            },
        }
    }

    #[test]
    fn dir_name_matches() {
        let m = manifest("macos");
        assert!(check_dir_name(&m, Path::new("platforms/macos/platform.apiw")).is_ok());
    }

    #[test]
    fn dir_name_mismatch_is_rejected() {
        let m = manifest("linux");
        let err = check_dir_name(&m, Path::new("platforms/macos/platform.apiw"))
            .expect_err("name/dir mismatch rejected");
        assert!(matches!(err, PlatformManifestError::NameMismatch { .. }));
    }

    #[test]
    fn bare_filename_skips_the_dir_check() {
        let m = manifest("macos");
        assert!(check_dir_name(&m, Path::new("platform.apiw")).is_ok());
    }
}

//! The capability **registry**: load `targets/<id>/capability.apiw` into an
//! addressable set of typed [`CapabilityProfile`]s.
//!
//! The registry is the in-memory face of the authored capability profiles. The
//! representability derivation ([`crate::derive`]) keys a profile to its target; the
//! child-5 conformance machinery reads the app-form face per target. Loading is the
//! full three-layer check: structural ([`crate::capability::schema`]) → parse +
//! semantic ([`crate::capability::apiw`]) → the registry-level check that each
//! profile's `capability "<id>"` matches its **containing directory** (the target's
//! stable identity, the same id its sibling `target.apiw` carries).

use std::collections::BTreeMap;
use std::path::Path;

use crate::capability::model::CapabilityProfile;
use crate::capability::{apiw, schema};
use crate::error::{Result, TargetModelError};

/// The fixed file name every capability profile carries (identity is the parent
/// directory, not this stem).
const CAPABILITY_FILE: &str = "capability.apiw";

/// An addressable set of authored capability profiles, keyed by target id.
#[derive(Debug, Clone, Default)]
pub struct CapabilityRegistry {
    profiles: BTreeMap<String, CapabilityProfile>,
}

impl CapabilityRegistry {
    /// Load and fully validate one `<id>/capability.apiw` file into a
    /// [`CapabilityProfile`], asserting its `capability "<id>"` matches its containing
    /// directory.
    pub fn load_file(path: &Path) -> Result<CapabilityProfile> {
        // Label diagnostics with `<dir>/capability.apiw` so a tree of identically named
        // files stays distinguishable.
        let source_name = display_name(path);
        let text = std::fs::read_to_string(path).map_err(|source| TargetModelError::Io {
            path: path.display().to_string(),
            source,
        })?;

        // Layer 1: structural (KDL Schema). Layer 2: parse + semantic.
        schema::validate_capability(&source_name, &text)?;
        let profile = apiw::parse_capability(&source_name, &text)?;

        // Layer 3: the profile's authored id is its containing directory (stable
        // identity). `path` is `.../targets/<id>/capability.apiw`.
        if let Some(dir) = path
            .parent()
            .and_then(Path::file_name)
            .and_then(|n| n.to_str())
        {
            if dir != profile.id {
                return Err(TargetModelError::IdMismatch {
                    entity: "capability",
                    name: profile.id.clone(),
                    dir: dir.to_string(),
                });
            }
        }
        Ok(profile)
    }

    /// Load every `<id>/capability.apiw` under `dir` (the `targets/` root) into a
    /// registry. Each immediate subdirectory containing a `capability.apiw` is one
    /// target; subdirectories are visited in sorted order. Subdirectories without a
    /// `capability.apiw` (the shared `_shared/` substrate, a target still being homed)
    /// are skipped. A duplicate id is an error.
    pub fn load_dir(dir: &Path) -> Result<Self> {
        let mut subdirs: Vec<_> = std::fs::read_dir(dir)
            .map_err(|source| TargetModelError::Io {
                path: dir.display().to_string(),
                source,
            })?
            .filter_map(|e| e.ok().map(|e| e.path()))
            .filter(|p| p.is_dir() && p.join(CAPABILITY_FILE).is_file())
            .collect();
        subdirs.sort();

        let mut profiles = BTreeMap::new();
        for subdir in subdirs {
            let profile = Self::load_file(&subdir.join(CAPABILITY_FILE))?;
            if let Some(prev) = profiles.insert(profile.id.clone(), profile) {
                return Err(TargetModelError::Io {
                    path: subdir.display().to_string(),
                    source: std::io::Error::new(
                        std::io::ErrorKind::InvalidData,
                        format!("duplicate capability profile id `{}`", prev.id),
                    ),
                });
            }
        }
        Ok(Self { profiles })
    }

    /// The profile for this target id, if present.
    pub fn get(&self, id: &str) -> Option<&CapabilityProfile> {
        self.profiles.get(id)
    }

    /// Every profile, in id order.
    pub fn profiles(&self) -> impl Iterator<Item = &CapabilityProfile> {
        self.profiles.values()
    }

    /// How many profiles are loaded.
    pub fn len(&self) -> usize {
        self.profiles.len()
    }

    /// Whether the registry is empty.
    pub fn is_empty(&self) -> bool {
        self.profiles.is_empty()
    }
}

/// A `<dir>/capability.apiw` diagnostic label for a profile file path.
fn display_name(path: &Path) -> String {
    let file = path
        .file_name()
        .and_then(|n| n.to_str())
        .unwrap_or(CAPABILITY_FILE);
    match path
        .parent()
        .and_then(Path::file_name)
        .and_then(|n| n.to_str())
    {
        Some(dir) => format!("{dir}/{file}"),
        None => file.to_string(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn load_file_rejects_id_directory_mismatch() {
        // A temp `wrongdir/capability.apiw` whose authored id is `sbcl` — the registry
        // identity check must reject it.
        let dir = std::env::temp_dir().join("apianyware-target-model-test-capability-mismatch");
        let target_dir = dir.join("wrongdir");
        std::fs::create_dir_all(&target_dir).expect("scratch dir");
        let file = target_dir.join("capability.apiw");
        std::fs::write(
            &file,
            r#"
            capability "sbcl" {
                semantic { dimension "ownership" { rung "idiomatic-conventional" } }
                app-form { dimension "packaging" { rung "exact-runtime" } }
            }
            "#,
        )
        .expect("write fixture");

        let err = CapabilityRegistry::load_file(&file).expect_err("id/dir mismatch rejected");
        assert!(matches!(err, TargetModelError::IdMismatch { .. }));

        let _ = std::fs::remove_dir_all(&dir);
    }
}

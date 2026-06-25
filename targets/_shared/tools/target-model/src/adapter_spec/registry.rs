//! The adapter-spec **registry**: load `targets/<id>/adapters/<platform>/spec.apiw` into an
//! addressable set of typed [`AdapterSpec`]s.
//!
//! Loading is the full three-layer check: structural ([`crate::adapter_spec::schema`]) →
//! parse + semantic ([`crate::adapter_spec::apiw`]) → the registry-level checks that the
//! spec's `adapter-spec "<id>"` matches its **target directory** and its `platform` matches
//! the **platform directory**.
//!
//! Identity nests two levels deep, exactly like the sibling `policy` registry: a spec lives
//! at `<id>/adapters/<platform>/spec.apiw`, so the target id is the file's
//! **great-grandparent** and the platform is its **parent** (`<platform>`). The spec sits
//! beside the `sources/` it describes.
//!
//! `macos` is the sole platform today (the second platform is added lazily, per the
//! node-brief D4 discipline), so [`load_dir`](AdapterSpecRegistry::load_dir) loads the fixed
//! `adapters/macos/spec.apiw` stem and keys by target id;
//! [`load_file`](AdapterSpecRegistry::load_file) is path-driven and already general.

use std::collections::BTreeMap;
use std::path::Path;

use crate::adapter_spec::model::AdapterSpec;
use crate::adapter_spec::{apiw, schema};
use crate::error::{Result, TargetModelError};

/// The fixed relative path the macOS adapter spec carries under its target directory.
const ADAPTER_REL: &str = "adapters/macos/spec.apiw";

/// An addressable set of authored adapter specs, keyed by target id.
#[derive(Debug, Clone, Default)]
pub struct AdapterSpecRegistry {
    specs: BTreeMap<String, AdapterSpec>,
}

impl AdapterSpecRegistry {
    /// Load and fully validate one `<id>/adapters/<platform>/spec.apiw` file into an
    /// [`AdapterSpec`], asserting its `adapter-spec "<id>"` matches its target directory (the
    /// great-grandparent) and its `platform` matches the platform directory (the parent).
    pub fn load_file(path: &Path) -> Result<AdapterSpec> {
        let source_name = display_name(path);
        let text = std::fs::read_to_string(path).map_err(|source| TargetModelError::Io {
            path: path.display().to_string(),
            source,
        })?;

        // Layer 1: structural (KDL Schema). Layer 2: parse + semantic.
        schema::validate_adapter_spec(&source_name, &text)?;
        let spec = apiw::parse_adapter_spec(&source_name, &text)?;

        // Layer 3: id = the target directory (great-grandparent); platform = the parent dir.
        if let Some(dir) = target_dir_name(path) {
            if dir != spec.id {
                return Err(TargetModelError::IdMismatch {
                    entity: "adapter-spec",
                    name: spec.id.clone(),
                    dir: dir.to_string(),
                });
            }
        }
        if let Some(platform_dir) = platform_dir_name(path) {
            if platform_dir != spec.platform {
                return Err(TargetModelError::IdMismatch {
                    entity: "adapter-spec platform",
                    name: spec.platform.clone(),
                    dir: platform_dir.to_string(),
                });
            }
        }
        Ok(spec)
    }

    /// Load every `<id>/adapters/macos/spec.apiw` under `dir` (the `targets/` root) into a
    /// registry. Each immediate subdirectory containing the spec is one target;
    /// subdirectories without one (the shared `_shared/` substrate, a target still being
    /// homed) are skipped. A duplicate id is an error.
    pub fn load_dir(dir: &Path) -> Result<Self> {
        let mut subdirs: Vec<_> = std::fs::read_dir(dir)
            .map_err(|source| TargetModelError::Io {
                path: dir.display().to_string(),
                source,
            })?
            .filter_map(|e| e.ok().map(|e| e.path()))
            .filter(|p| p.is_dir() && p.join(ADAPTER_REL).is_file())
            .collect();
        subdirs.sort();

        let mut specs = BTreeMap::new();
        for subdir in subdirs {
            let spec = Self::load_file(&subdir.join(ADAPTER_REL))?;
            if let Some(prev) = specs.insert(spec.id.clone(), spec) {
                return Err(TargetModelError::Io {
                    path: subdir.display().to_string(),
                    source: std::io::Error::new(
                        std::io::ErrorKind::InvalidData,
                        format!("duplicate adapter spec id `{}`", prev.id),
                    ),
                });
            }
        }
        Ok(Self { specs })
    }

    /// The spec for this target id, if present.
    pub fn get(&self, id: &str) -> Option<&AdapterSpec> {
        self.specs.get(id)
    }

    /// Every spec, in id order.
    pub fn specs(&self) -> impl Iterator<Item = &AdapterSpec> {
        self.specs.values()
    }

    /// How many specs are loaded.
    pub fn len(&self) -> usize {
        self.specs.len()
    }

    /// Whether the registry is empty.
    pub fn is_empty(&self) -> bool {
        self.specs.is_empty()
    }
}

/// The target directory name for a `<id>/adapters/<platform>/spec.apiw` path — the
/// great-grandparent of the file.
fn target_dir_name(path: &Path) -> Option<&str> {
    path.parent()
        .and_then(Path::parent)
        .and_then(Path::parent)
        .and_then(Path::file_name)
        .and_then(|n| n.to_str())
}

/// The platform directory name for the path — the immediate parent (`<platform>`).
fn platform_dir_name(path: &Path) -> Option<&str> {
    path.parent()
        .and_then(Path::file_name)
        .and_then(|n| n.to_str())
}

/// An `<id>/adapters/<platform>/spec.apiw` diagnostic label for a spec file path.
fn display_name(path: &Path) -> String {
    match (target_dir_name(path), platform_dir_name(path)) {
        (Some(dir), Some(platform)) => format!("{dir}/adapters/{platform}/spec.apiw"),
        _ => "adapters/spec.apiw".to_string(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn load_file_rejects_id_directory_mismatch() {
        let dir = std::env::temp_dir().join("apianyware-target-model-test-adapter-mismatch");
        let spec_dir = dir.join("wrongdir").join("adapters").join("macos");
        std::fs::create_dir_all(&spec_dir).expect("scratch dir");
        let file = spec_dir.join("spec.apiw");
        std::fs::write(
            &file,
            r#"
            adapter-spec "racket" {
                platform "macos"
                output { library "APIAnywareRacket"; kind "dynamic-library" }
            }
            "#,
        )
        .expect("write fixture");

        let err = AdapterSpecRegistry::load_file(&file).expect_err("id/dir mismatch rejected");
        assert!(matches!(err, TargetModelError::IdMismatch { .. }));

        let _ = std::fs::remove_dir_all(&dir);
    }
}

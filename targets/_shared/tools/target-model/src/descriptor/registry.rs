//! The target **registry**: load `targets/<id>/target.apiw` into an addressable set
//! of typed [`TargetDescriptor`]s.
//!
//! The registry is the in-memory face of the authored target descriptors. Later ws6
//! children + consumers read it: the capability/representability derivation keys a
//! profile to its target; the conformance report names its target; a future support
//! matrix enumerates targets. Loading is the full three-layer check: structural
//! ([`crate::descriptor::schema`]) → parse + semantic ([`crate::descriptor::apiw`]) → the
//! registry-level check that each descriptor's `target "<id>"` matches its
//! **containing directory** (the target's stable identity).

use std::collections::BTreeMap;
use std::path::Path;

use crate::descriptor::model::TargetDescriptor;
use crate::descriptor::{apiw, schema};
use crate::error::{Result, TargetModelError};

/// The fixed file name every target descriptor carries (identity is the parent
/// directory, not this stem).
const TARGET_FILE: &str = "target.apiw";

/// An addressable set of authored target descriptors, keyed by id.
#[derive(Debug, Clone, Default)]
pub struct TargetRegistry {
    targets: BTreeMap<String, TargetDescriptor>,
}

impl TargetRegistry {
    /// Load and fully validate one `<id>/target.apiw` file into a
    /// [`TargetDescriptor`], asserting its `target "<id>"` matches its containing
    /// directory.
    pub fn load_file(path: &Path) -> Result<TargetDescriptor> {
        // Label diagnostics with `<dir>/target.apiw` so a tree of identically named
        // files stays distinguishable.
        let source_name = display_name(path);
        let text = std::fs::read_to_string(path).map_err(|source| TargetModelError::Io {
            path: path.display().to_string(),
            source,
        })?;

        // Layer 1: structural (KDL Schema). Layer 2: parse + semantic.
        schema::validate_target(&source_name, &text)?;
        let descriptor = apiw::parse_target(&source_name, &text)?;

        // Layer 3: the descriptor's authored id is its containing directory (stable
        // identity). `path` is `.../targets/<id>/target.apiw`, so the parent
        // directory's file name is `<id>`.
        if let Some(dir) = path
            .parent()
            .and_then(Path::file_name)
            .and_then(|n| n.to_str())
        {
            if dir != descriptor.id {
                return Err(TargetModelError::IdMismatch {
                    entity: "target",
                    name: descriptor.id.clone(),
                    dir: dir.to_string(),
                });
            }
        }
        Ok(descriptor)
    }

    /// Load every `<id>/target.apiw` under `dir` (the `targets/` root) into a
    /// registry. Each immediate subdirectory containing a `target.apiw` is one
    /// target; subdirectories are visited in sorted order. Subdirectories without a
    /// `target.apiw` (the shared `_shared/` substrate, a target still being homed)
    /// are skipped. A duplicate id is an error.
    pub fn load_dir(dir: &Path) -> Result<Self> {
        let mut subdirs: Vec<_> = std::fs::read_dir(dir)
            .map_err(|source| TargetModelError::Io {
                path: dir.display().to_string(),
                source,
            })?
            .filter_map(|e| e.ok().map(|e| e.path()))
            .filter(|p| p.is_dir() && p.join(TARGET_FILE).is_file())
            .collect();
        subdirs.sort();

        let mut targets = BTreeMap::new();
        for subdir in subdirs {
            let descriptor = Self::load_file(&subdir.join(TARGET_FILE))?;
            if let Some(prev) = targets.insert(descriptor.id.clone(), descriptor) {
                return Err(TargetModelError::Io {
                    path: subdir.display().to_string(),
                    source: std::io::Error::new(
                        std::io::ErrorKind::InvalidData,
                        format!("duplicate target id `{}`", prev.id),
                    ),
                });
            }
        }
        Ok(Self { targets })
    }

    /// The target with this id, if present.
    pub fn get(&self, id: &str) -> Option<&TargetDescriptor> {
        self.targets.get(id)
    }

    /// Every target, in id order.
    pub fn targets(&self) -> impl Iterator<Item = &TargetDescriptor> {
        self.targets.values()
    }

    /// How many targets are loaded.
    pub fn len(&self) -> usize {
        self.targets.len()
    }

    /// Whether the registry is empty.
    pub fn is_empty(&self) -> bool {
        self.targets.is_empty()
    }
}

/// A `<dir>/target.apiw` diagnostic label for a descriptor file path.
fn display_name(path: &Path) -> String {
    let file = path
        .file_name()
        .and_then(|n| n.to_str())
        .unwrap_or(TARGET_FILE);
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
        // A temp `wrongdir/target.apiw` whose authored id is `sbcl` — the registry
        // identity check must reject it. Use the crate's own target dir for a real
        // path-aware load against a mismatch fixture written to a scratch dir.
        let dir = std::env::temp_dir().join("apianyware-target-model-test-mismatch");
        let target_dir = dir.join("wrongdir");
        std::fs::create_dir_all(&target_dir).expect("scratch dir");
        let file = target_dir.join("target.apiw");
        std::fs::write(
            &file,
            r#"
            target "sbcl" {
                family "common-lisp"
                implementation "sbcl"
                ffi-backend "sb-alien"
                runtime-model "compiled-ffi"
                projection-policy "thin-direct"
                adapter-strategy "sole-native-unit"
            }
            "#,
        )
        .expect("write fixture");

        let err = TargetRegistry::load_file(&file).expect_err("id/dir mismatch rejected");
        assert!(matches!(err, TargetModelError::IdMismatch { .. }));

        let _ = std::fs::remove_dir_all(&dir);
    }
}

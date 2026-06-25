//! The projection-policy **registry**: load `targets/<id>/policies/<platform>/projection.apiw`
//! into an addressable set of typed [`ProjectionPolicy`]s.
//!
//! Loading is the full three-layer check: structural ([`crate::policy::schema`]) → parse +
//! semantic ([`crate::policy::apiw`]) → the registry-level checks that the policy's
//! `projection-policy "<id>"` matches its **target directory** and its `platform` matches
//! the **platform directory**.
//!
//! Identity nests one level deeper than the sibling `idioms` registry: a policy lives at
//! `<id>/policies/<platform>/projection.apiw`, so the target id is the file's
//! **great-grandparent** and the platform is its **parent** (`<platform>`). Both are checked
//! against the authored values.
//!
//! `macos` is the sole platform today (the second platform is added lazily, per the
//! node-brief D4 discipline), so [`load_dir`](ProjectionPolicyRegistry::load_dir) loads the
//! fixed `policies/macos/projection.apiw` stem and keys by target id;
//! [`load_file`](ProjectionPolicyRegistry::load_file) is path-driven and already general (a
//! future platform just calls it with that path).

use std::collections::BTreeMap;
use std::path::Path;

use crate::error::{Result, TargetModelError};
use crate::policy::model::ProjectionPolicy;
use crate::policy::{apiw, schema};

/// The fixed relative path the macOS projection policy carries under its target directory.
const POLICY_REL: &str = "policies/macos/projection.apiw";

/// An addressable set of authored projection policies, keyed by target id.
#[derive(Debug, Clone, Default)]
pub struct ProjectionPolicyRegistry {
    policies: BTreeMap<String, ProjectionPolicy>,
}

impl ProjectionPolicyRegistry {
    /// Load and fully validate one `<id>/policies/<platform>/projection.apiw` file into a
    /// [`ProjectionPolicy`], asserting its `projection-policy "<id>"` matches its target
    /// directory (the great-grandparent) and its `platform` matches the platform directory
    /// (the parent).
    pub fn load_file(path: &Path) -> Result<ProjectionPolicy> {
        let source_name = display_name(path);
        let text = std::fs::read_to_string(path).map_err(|source| TargetModelError::Io {
            path: path.display().to_string(),
            source,
        })?;

        // Layer 1: structural (KDL Schema). Layer 2: parse + semantic.
        schema::validate_policy(&source_name, &text)?;
        let policy = apiw::parse_policy(&source_name, &text)?;

        // Layer 3: id = the target directory (great-grandparent); platform = the parent dir.
        if let Some(dir) = target_dir_name(path) {
            if dir != policy.id {
                return Err(TargetModelError::IdMismatch {
                    entity: "projection-policy",
                    name: policy.id.clone(),
                    dir: dir.to_string(),
                });
            }
        }
        if let Some(platform_dir) = platform_dir_name(path) {
            if platform_dir != policy.platform {
                return Err(TargetModelError::IdMismatch {
                    entity: "projection-policy platform",
                    name: policy.platform.clone(),
                    dir: platform_dir.to_string(),
                });
            }
        }
        Ok(policy)
    }

    /// Load every `<id>/policies/macos/projection.apiw` under `dir` (the `targets/` root)
    /// into a registry. Each immediate subdirectory containing the policy is one target;
    /// subdirectories without one (the shared `_shared/` substrate, a target still being
    /// homed) are skipped. A duplicate id is an error.
    pub fn load_dir(dir: &Path) -> Result<Self> {
        let mut subdirs: Vec<_> = std::fs::read_dir(dir)
            .map_err(|source| TargetModelError::Io {
                path: dir.display().to_string(),
                source,
            })?
            .filter_map(|e| e.ok().map(|e| e.path()))
            .filter(|p| p.is_dir() && p.join(POLICY_REL).is_file())
            .collect();
        subdirs.sort();

        let mut policies = BTreeMap::new();
        for subdir in subdirs {
            let policy = Self::load_file(&subdir.join(POLICY_REL))?;
            if let Some(prev) = policies.insert(policy.id.clone(), policy) {
                return Err(TargetModelError::Io {
                    path: subdir.display().to_string(),
                    source: std::io::Error::new(
                        std::io::ErrorKind::InvalidData,
                        format!("duplicate projection policy id `{}`", prev.id),
                    ),
                });
            }
        }
        Ok(Self { policies })
    }

    /// The policy for this target id, if present.
    pub fn get(&self, id: &str) -> Option<&ProjectionPolicy> {
        self.policies.get(id)
    }

    /// Every policy, in id order.
    pub fn policies(&self) -> impl Iterator<Item = &ProjectionPolicy> {
        self.policies.values()
    }

    /// How many policies are loaded.
    pub fn len(&self) -> usize {
        self.policies.len()
    }

    /// Whether the registry is empty.
    pub fn is_empty(&self) -> bool {
        self.policies.is_empty()
    }
}

/// The target directory name for a `<id>/policies/<platform>/projection.apiw` path — the
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

/// An `<id>/policies/<platform>/projection.apiw` diagnostic label for a policy file path.
fn display_name(path: &Path) -> String {
    match (target_dir_name(path), platform_dir_name(path)) {
        (Some(dir), Some(platform)) => format!("{dir}/policies/{platform}/projection.apiw"),
        _ => "policies/projection.apiw".to_string(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn load_file_rejects_id_directory_mismatch() {
        let dir = std::env::temp_dir().join("apianyware-target-model-test-policy-mismatch");
        let policy_dir = dir.join("wrongdir").join("policies").join("macos");
        std::fs::create_dir_all(&policy_dir).expect("scratch dir");
        let file = policy_dir.join("projection.apiw");
        std::fs::write(
            &file,
            r#"
            projection-policy "racket" {
                platform "macos"
                choice "directly-reachable-objc" { spectrum "direct-call" }
            }
            "#,
        )
        .expect("write fixture");

        let err = ProjectionPolicyRegistry::load_file(&file).expect_err("id/dir mismatch rejected");
        assert!(matches!(err, TargetModelError::IdMismatch { .. }));

        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn load_file_rejects_platform_directory_mismatch() {
        let dir = std::env::temp_dir().join("apianyware-target-model-test-policy-platform");
        // The target dir matches (`racket`) but the platform dir (`linux`) ≠ authored `macos`.
        let policy_dir = dir.join("racket").join("policies").join("linux");
        std::fs::create_dir_all(&policy_dir).expect("scratch dir");
        let file = policy_dir.join("projection.apiw");
        std::fs::write(
            &file,
            r#"
            projection-policy "racket" {
                platform "macos"
                choice "directly-reachable-objc" { spectrum "direct-call" }
            }
            "#,
        )
        .expect("write fixture");

        let err =
            ProjectionPolicyRegistry::load_file(&file).expect_err("platform/dir mismatch rejected");
        assert!(matches!(err, TargetModelError::IdMismatch { .. }));

        let _ = std::fs::remove_dir_all(&dir);
    }
}

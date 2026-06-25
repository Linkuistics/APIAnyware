//! The conformance-report **registry**: load `targets/<id>/conformance/<platform>.apiw` into
//! an addressable set of typed [`ConformanceReport`]s.
//!
//! Loading is the full three-layer check: structural ([`crate::conformance::schema`]), then
//! parse + semantic ([`crate::conformance::apiw`]), then the registry-level checks that the
//! report's `conformance "<id>"` matches its **target directory** and its `platform` matches
//! the file **stem**.
//!
//! Identity has a shape unique among the target-model entities (node-brief D1): the **platform
//! is in the filename** (`conformance/macos.apiw`), not a platform directory as for
//! policy/adapter. So the target id is the file's **grandparent** (mirroring the `idioms`
//! registry, whose catalogue also sits one level deep) and the platform is the file **stem**
//! (mirroring the platform-tests `api-semantics` registry, whose facet identity is its stem).
//! Both are checked against the authored values.
//!
//! `macos` is the sole platform today (the second platform is added lazily, per the node-brief
//! D4 discipline), so [`load_dir`](ConformanceRegistry::load_dir) loads the fixed
//! `conformance/macos.apiw` stem and keys by target id;
//! [`load_file`](ConformanceRegistry::load_file) is path-driven and already general (a future
//! platform just calls it with that path).

use std::collections::BTreeMap;
use std::path::Path;

use crate::conformance::model::ConformanceReport;
use crate::conformance::{apiw, schema};
use crate::error::{Result, TargetModelError};

/// The fixed relative path the macOS conformance report carries under its target directory.
const REPORT_REL: &str = "conformance/macos.apiw";

/// An addressable set of authored conformance reports, keyed by target id.
#[derive(Debug, Clone, Default)]
pub struct ConformanceRegistry {
    reports: BTreeMap<String, ConformanceReport>,
}

impl ConformanceRegistry {
    /// Load and fully validate one `<id>/conformance/<platform>.apiw` file into a
    /// [`ConformanceReport`], asserting its `conformance "<id>"` matches its target directory
    /// (the grandparent) and its `platform` matches the file stem.
    pub fn load_file(path: &Path) -> Result<ConformanceReport> {
        let source_name = display_name(path);
        let text = std::fs::read_to_string(path).map_err(|source| TargetModelError::Io {
            path: path.display().to_string(),
            source,
        })?;

        // Layer 1: structural (KDL Schema). Layer 2: parse + semantic.
        schema::validate_conformance(&source_name, &text)?;
        let report = apiw::parse_conformance(&source_name, &text)?;

        // Layer 3: id = the target directory (grandparent); platform = the file stem.
        if let Some(dir) = target_dir_name(path) {
            if dir != report.id {
                return Err(TargetModelError::IdMismatch {
                    entity: "conformance",
                    name: report.id.clone(),
                    dir: dir.to_string(),
                });
            }
        }
        if let Some(stem) = path.file_stem().and_then(|s| s.to_str()) {
            if stem != report.platform {
                return Err(TargetModelError::IdMismatch {
                    entity: "conformance platform",
                    name: report.platform.clone(),
                    dir: stem.to_string(),
                });
            }
        }
        Ok(report)
    }

    /// Load every `<id>/conformance/macos.apiw` under `dir` (the `targets/` root) into a
    /// registry. Each immediate subdirectory containing the report is one target;
    /// subdirectories without one (the shared `_shared/` substrate, a target still being
    /// homed) are skipped. A duplicate id is an error.
    pub fn load_dir(dir: &Path) -> Result<Self> {
        let mut subdirs: Vec<_> = std::fs::read_dir(dir)
            .map_err(|source| TargetModelError::Io {
                path: dir.display().to_string(),
                source,
            })?
            .filter_map(|e| e.ok().map(|e| e.path()))
            .filter(|p| p.is_dir() && p.join(REPORT_REL).is_file())
            .collect();
        subdirs.sort();

        let mut reports = BTreeMap::new();
        for subdir in subdirs {
            let report = Self::load_file(&subdir.join(REPORT_REL))?;
            if let Some(prev) = reports.insert(report.id.clone(), report) {
                return Err(TargetModelError::Io {
                    path: subdir.display().to_string(),
                    source: std::io::Error::new(
                        std::io::ErrorKind::InvalidData,
                        format!("duplicate conformance report id `{}`", prev.id),
                    ),
                });
            }
        }
        Ok(Self { reports })
    }

    /// The report for this target id, if present.
    pub fn get(&self, id: &str) -> Option<&ConformanceReport> {
        self.reports.get(id)
    }

    /// Every report, in id order.
    pub fn reports(&self) -> impl Iterator<Item = &ConformanceReport> {
        self.reports.values()
    }

    /// How many reports are loaded.
    pub fn len(&self) -> usize {
        self.reports.len()
    }

    /// Whether the registry is empty.
    pub fn is_empty(&self) -> bool {
        self.reports.is_empty()
    }
}

/// The target directory name for a `<id>/conformance/<platform>.apiw` path — the grandparent
/// of the file.
fn target_dir_name(path: &Path) -> Option<&str> {
    path.parent()
        .and_then(Path::parent)
        .and_then(Path::file_name)
        .and_then(|n| n.to_str())
}

/// An `<id>/conformance/<platform>.apiw` diagnostic label for a report file path.
fn display_name(path: &Path) -> String {
    let platform = path
        .file_name()
        .and_then(|n| n.to_str())
        .unwrap_or("macos.apiw");
    match target_dir_name(path) {
        Some(dir) => format!("{dir}/conformance/{platform}"),
        None => format!("conformance/{platform}"),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn load_file_rejects_id_directory_mismatch() {
        let dir = std::env::temp_dir().join("apianyware-target-model-test-conformance-mismatch");
        let report_dir = dir.join("wrongdir").join("conformance");
        std::fs::create_dir_all(&report_dir).expect("scratch dir");
        let file = report_dir.join("macos.apiw");
        std::fs::write(
            &file,
            r#"
            conformance "racket" {
                platform "macos"
                app-support "gui-app" { status "pass" }
            }
            "#,
        )
        .expect("write fixture");

        let err = ConformanceRegistry::load_file(&file).expect_err("id/dir mismatch rejected");
        assert!(matches!(err, TargetModelError::IdMismatch { .. }));

        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn load_file_rejects_platform_stem_mismatch() {
        let dir = std::env::temp_dir().join("apianyware-target-model-test-conformance-platform");
        // The target dir matches (`racket`) but the file stem (`linux`) ≠ authored `macos`.
        let report_dir = dir.join("racket").join("conformance");
        std::fs::create_dir_all(&report_dir).expect("scratch dir");
        let file = report_dir.join("linux.apiw");
        std::fs::write(
            &file,
            r#"
            conformance "racket" {
                platform "macos"
                app-support "gui-app" { status "pass" }
            }
            "#,
        )
        .expect("write fixture");

        let err =
            ConformanceRegistry::load_file(&file).expect_err("platform/stem mismatch rejected");
        assert!(matches!(err, TargetModelError::IdMismatch { .. }));

        let _ = std::fs::remove_dir_all(&dir);
    }
}

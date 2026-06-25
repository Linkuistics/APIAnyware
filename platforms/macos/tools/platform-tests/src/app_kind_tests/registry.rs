//! The app-kind test-obligation **registry**: load
//! `platforms/macos/tests/app-kinds/<kind>.apiw` into an addressable set of typed
//! [`AppKindTests`].
//!
//! The registry is the in-memory face of the authored obligation bodies. Workstream
//! 9 consumes it: each [`crate::Expectation`] is executed against a running target
//! binding. Loading is the full three-layer check: structural
//! ([`super::schema`]) → parse + semantic ([`super::apiw`]) → the registry-level
//! check that each file's `app-kind-tests "<name>"` matches its **file stem** (the
//! kind's stable identity — these are flat files, one per kind, so identity comes
//! from the stem, not a parent directory).
//!
//! The remaining cross-entity invariant — the obligations a `<kind>.apiw` declares
//! exactly resolve the `test-obligation` refs in `app-kinds/<kind>/kind.apiw` — needs
//! the *app-kind* registry too, so it lives in the standing `tests/` guard rather
//! than here (this crate does not depend on `apianyware-app-kinds` outside tests).

use std::collections::BTreeMap;
use std::path::Path;

use crate::error::{PlatformTestError, Result};

use super::apiw;
use super::model::AppKindTests;
use super::schema;

/// The extension every app-kind test-obligation file carries.
const APIW_EXT: &str = "apiw";

/// An addressable set of authored app-kind test obligations, keyed by kind name.
#[derive(Debug, Clone, Default)]
pub struct AppKindTestsRegistry {
    by_kind: BTreeMap<String, AppKindTests>,
}

impl AppKindTestsRegistry {
    /// Load and fully validate one `<kind>.apiw` file into an [`AppKindTests`],
    /// asserting its `app-kind-tests "<name>"` matches its file stem.
    pub fn load_file(path: &Path) -> Result<AppKindTests> {
        let source_name = path
            .file_name()
            .and_then(|n| n.to_str())
            .unwrap_or("<kind>.apiw")
            .to_string();
        let text = std::fs::read_to_string(path).map_err(|source| PlatformTestError::Io {
            path: path.display().to_string(),
            source,
        })?;

        // Layer 1: structural (KDL Schema). Layer 2: parse + semantic.
        schema::validate_app_kind_tests(&source_name, &text)?;
        let tests = apiw::parse_app_kind_tests(&source_name, &text)?;

        // Layer 3: the declaration's authored name is its file stem (stable
        // identity). `path` is `.../tests/app-kinds/<name>.apiw`.
        if let Some(stem) = path.file_stem().and_then(|s| s.to_str()) {
            if stem != tests.kind {
                return Err(PlatformTestError::NameMismatch {
                    name: tests.kind.clone(),
                    stem: stem.to_string(),
                });
            }
        }
        Ok(tests)
    }

    /// Load every `<kind>.apiw` under `dir` (`platforms/macos/tests/app-kinds/`) into
    /// a registry. Each `*.apiw` file is one kind's obligations; files are visited in
    /// sorted order. Non-`.apiw` files (a `README.md`) are skipped. A duplicate kind
    /// name is an error.
    pub fn load_dir(dir: &Path) -> Result<Self> {
        let mut files: Vec<_> = std::fs::read_dir(dir)
            .map_err(|source| PlatformTestError::Io {
                path: dir.display().to_string(),
                source,
            })?
            .filter_map(|e| e.ok().map(|e| e.path()))
            .filter(|p| p.is_file() && p.extension().and_then(|x| x.to_str()) == Some(APIW_EXT))
            .collect();
        files.sort();

        let mut by_kind = BTreeMap::new();
        for file in files {
            let tests = Self::load_file(&file)?;
            if let Some(prev) = by_kind.insert(tests.kind.clone(), tests) {
                return Err(PlatformTestError::Io {
                    path: file.display().to_string(),
                    source: std::io::Error::new(
                        std::io::ErrorKind::InvalidData,
                        format!("duplicate app-kind-tests name `{}`", prev.kind),
                    ),
                });
            }
        }
        Ok(Self { by_kind })
    }

    /// The obligations for this kind, if present.
    pub fn get(&self, kind: &str) -> Option<&AppKindTests> {
        self.by_kind.get(kind)
    }

    /// Every kind's obligations, in name order.
    pub fn all(&self) -> impl Iterator<Item = &AppKindTests> {
        self.by_kind.values()
    }

    /// How many kinds' obligations are loaded.
    pub fn len(&self) -> usize {
        self.by_kind.len()
    }

    /// Whether the registry is empty.
    pub fn is_empty(&self) -> bool {
        self.by_kind.is_empty()
    }
}

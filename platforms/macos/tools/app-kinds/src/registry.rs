//! The app-kind **registry**: load `platforms/macos/app-kinds/<kind>/kind.apiw`
//! into an addressable set of typed [`AppKind`]s.
//!
//! The registry is the in-memory face of the authored app-kind vocabulary. Later
//! workstreams consume it: ws6 target emitters project a kind to a target's bundle
//! shape; ws7 app-specs *name* a kind; ws9 reads its test obligations. Loading is
//! the full three-layer check: structural ([`crate::schema`]) → parse + semantic
//! ([`crate::apiw`]) → the registry-level check that each kind's `app-kind "<name>"`
//! matches its **containing directory** (the kind's stable identity — every file is
//! named `kind.apiw`, so identity comes from the directory, not the file stem).

use std::collections::BTreeMap;
use std::path::Path;

use crate::error::{AppKindError, Result};
use crate::kind::AppKind;
use crate::{apiw, schema};

/// The fixed file name every app-kind definition carries (identity is the parent
/// directory, not this stem).
const KIND_FILE: &str = "kind.apiw";

/// An addressable set of authored app-kinds, keyed by name.
#[derive(Debug, Clone, Default)]
pub struct AppKindRegistry {
    kinds: BTreeMap<String, AppKind>,
}

impl AppKindRegistry {
    /// Load and fully validate one `<kind>/kind.apiw` file into an [`AppKind`],
    /// asserting its `app-kind "<name>"` matches its containing directory.
    pub fn load_file(path: &Path) -> Result<AppKind> {
        // Label diagnostics with `<dir>/kind.apiw` so a registry of identically
        // named files stays distinguishable.
        let source_name = display_name(path);
        let text = std::fs::read_to_string(path).map_err(|source| AppKindError::Io {
            path: path.display().to_string(),
            source,
        })?;

        // Layer 1: structural (KDL Schema). Layer 2: parse + semantic.
        schema::validate_app_kind(&source_name, &text)?;
        let kind = apiw::parse_kind(&source_name, &text)?;

        // Layer 3: the kind's authored name is its containing directory (stable
        // identity). `path` is `.../app-kinds/<name>/kind.apiw`, so the parent
        // directory's file name is `<name>`.
        if let Some(dir) = path
            .parent()
            .and_then(Path::file_name)
            .and_then(|n| n.to_str())
        {
            if dir != kind.name {
                return Err(AppKindError::NameMismatch {
                    name: kind.name.clone(),
                    dir: dir.to_string(),
                });
            }
        }
        Ok(kind)
    }

    /// Load every `<kind>/kind.apiw` under `dir` (`platforms/macos/app-kinds/`)
    /// into a registry. Each immediate subdirectory containing a `kind.apiw` is one
    /// kind; subdirectories are visited in sorted order. Files that are not a
    /// kind directory (the `README.md`, a kind's `docs/` subtree) are skipped. A
    /// duplicate kind name is an error.
    pub fn load_dir(dir: &Path) -> Result<Self> {
        let mut subdirs: Vec<_> = std::fs::read_dir(dir)
            .map_err(|source| AppKindError::Io {
                path: dir.display().to_string(),
                source,
            })?
            .filter_map(|e| e.ok().map(|e| e.path()))
            .filter(|p| p.is_dir() && p.join(KIND_FILE).is_file())
            .collect();
        subdirs.sort();

        let mut kinds = BTreeMap::new();
        for subdir in subdirs {
            let kind = Self::load_file(&subdir.join(KIND_FILE))?;
            if let Some(prev) = kinds.insert(kind.name.clone(), kind) {
                return Err(AppKindError::Io {
                    path: subdir.display().to_string(),
                    source: std::io::Error::new(
                        std::io::ErrorKind::InvalidData,
                        format!("duplicate app-kind name `{}`", prev.name),
                    ),
                });
            }
        }
        Ok(Self { kinds })
    }

    /// The kind with this name, if present.
    pub fn get(&self, name: &str) -> Option<&AppKind> {
        self.kinds.get(name)
    }

    /// Every kind, in name order.
    pub fn kinds(&self) -> impl Iterator<Item = &AppKind> {
        self.kinds.values()
    }

    /// How many kinds are loaded.
    pub fn len(&self) -> usize {
        self.kinds.len()
    }

    /// Whether the registry is empty.
    pub fn is_empty(&self) -> bool {
        self.kinds.is_empty()
    }
}

/// A `<dir>/kind.apiw` diagnostic label for a kind file path.
fn display_name(path: &Path) -> String {
    let file = path
        .file_name()
        .and_then(|n| n.to_str())
        .unwrap_or(KIND_FILE);
    match path
        .parent()
        .and_then(Path::file_name)
        .and_then(|n| n.to_str())
    {
        Some(dir) => format!("{dir}/{file}"),
        None => file.to_string(),
    }
}

//! The pattern-kind **registry**: load `semantic/pattern-kinds/*.apiw` into an
//! addressable set of typed [`PatternKind`]s.
//!
//! The registry is the in-memory face of the authored kind vocabulary. Later
//! workstream-3 children resolve instance `kind="<name>"` references against it;
//! ws6 emitters project the kinds it holds. Loading is the full three-layer
//! check: structural ([`crate::schema`]) → parse + semantic ([`crate::apiw`]) →
//! the registry-level check that each file's stem matches its `pattern-kind`
//! name (the kind's stable authored identity — ADR-0048).

use std::collections::BTreeMap;
use std::path::Path;

use crate::error::{PatternError, Result};
use crate::kind::PatternKind;
use crate::{apiw, schema};

/// An addressable set of authored pattern-kinds, keyed by name.
#[derive(Debug, Clone, Default)]
pub struct PatternKindRegistry {
    kinds: BTreeMap<String, PatternKind>,
}

impl PatternKindRegistry {
    /// Load and fully validate one `<name>.apiw` file into a [`PatternKind`],
    /// asserting its `pattern-kind "<name>"` matches the file stem.
    pub fn load_file(path: &Path) -> Result<PatternKind> {
        let source_name = path
            .file_name()
            .map(|n| n.to_string_lossy().into_owned())
            .unwrap_or_else(|| path.display().to_string());
        let text = std::fs::read_to_string(path).map_err(|source| PatternError::Io {
            path: path.display().to_string(),
            source,
        })?;

        // Layer 1: structural (KDL Schema). Layer 2: parse + semantic.
        schema::validate_pattern_kind(&source_name, &text)?;
        let kind = apiw::parse_kind(&source_name, &text)?;

        // Layer 3: the kind's authored name is its file stem (stable identity).
        if let Some(stem) = path.file_stem().map(|s| s.to_string_lossy()) {
            if stem != kind.name {
                return Err(PatternError::Io {
                    path: path.display().to_string(),
                    source: std::io::Error::new(
                        std::io::ErrorKind::InvalidData,
                        format!(
                            "pattern-kind name `{}` does not match file stem `{stem}`",
                            kind.name
                        ),
                    ),
                });
            }
        }
        Ok(kind)
    }

    /// Load every `*.apiw` file in `dir` into a registry. Files are loaded in
    /// sorted order; a duplicate kind name across two files is an error.
    pub fn load_dir(dir: &Path) -> Result<Self> {
        let mut entries: Vec<_> = std::fs::read_dir(dir)
            .map_err(|source| PatternError::Io {
                path: dir.display().to_string(),
                source,
            })?
            .filter_map(|e| e.ok().map(|e| e.path()))
            .filter(|p| p.extension().is_some_and(|x| x == "apiw"))
            .collect();
        entries.sort();

        let mut kinds = BTreeMap::new();
        for path in entries {
            let kind = Self::load_file(&path)?;
            if let Some(prev) = kinds.insert(kind.name.clone(), kind) {
                return Err(PatternError::Io {
                    path: path.display().to_string(),
                    source: std::io::Error::new(
                        std::io::ErrorKind::InvalidData,
                        format!("duplicate pattern-kind name `{}`", prev.name),
                    ),
                });
            }
        }
        Ok(Self { kinds })
    }

    /// The kind with this name, if present.
    pub fn get(&self, name: &str) -> Option<&PatternKind> {
        self.kinds.get(name)
    }

    /// Every kind, in name order.
    pub fn kinds(&self) -> impl Iterator<Item = &PatternKind> {
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

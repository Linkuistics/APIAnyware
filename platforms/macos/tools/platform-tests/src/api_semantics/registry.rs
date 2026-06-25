//! The api-semantics **registry**: load `platforms/macos/tests/api-semantics/<facet>.apiw`
//! into an addressable set of typed [`ApiSemantics`].
//!
//! The registry is the in-memory face of the authored api-semantic declarations.
//! Workstream 6 consumes the §30 `weirdness` tags (to compute a representability
//! status); workstream 9 executes each [`crate::Expectation`] against a running target
//! binding. Loading is the full three-layer check: structural ([`super::schema`]) →
//! parse + semantic ([`super::apiw`]) → the registry-level check that each file's
//! `api-semantics "<facet>"` matches its **file stem** (the facet's identity — these
//! are flat files, one per facet, so identity comes from the stem, not a parent
//! directory).
//!
//! Unlike the sibling app-kind-tests family, an api-semantics file has **no
//! cross-entity ref** to resolve (its facets are self-contained), so the registry is
//! the last validation layer; the standing guard only asserts the four expected facets
//! are present and well-formed.

use std::collections::BTreeMap;
use std::path::Path;

use crate::error::{PlatformTestError, Result};

use super::apiw;
use super::model::{ApiSemantics, Facet};
use super::schema;

/// The extension every api-semantics file carries.
const APIW_EXT: &str = "apiw";

/// An addressable set of authored api-semantic declarations, keyed by facet.
#[derive(Debug, Clone, Default)]
pub struct ApiSemanticsRegistry {
    by_facet: BTreeMap<Facet, ApiSemantics>,
}

impl ApiSemanticsRegistry {
    /// Load and fully validate one `<facet>.apiw` file into an [`ApiSemantics`],
    /// asserting its `api-semantics "<facet>"` matches its file stem.
    pub fn load_file(path: &Path) -> Result<ApiSemantics> {
        let source_name = path
            .file_name()
            .and_then(|n| n.to_str())
            .unwrap_or("<facet>.apiw")
            .to_string();
        let text = std::fs::read_to_string(path).map_err(|source| PlatformTestError::Io {
            path: path.display().to_string(),
            source,
        })?;

        // Layer 1: structural (KDL Schema). Layer 2: parse + semantic.
        schema::validate_api_semantics(&source_name, &text)?;
        let semantics = apiw::parse_api_semantics(&source_name, &text)?;

        // Layer 3: the declaration's facet is its file stem (stable identity).
        // `path` is `.../tests/api-semantics/<facet>.apiw`.
        if let Some(stem) = path.file_stem().and_then(|s| s.to_str()) {
            if stem != semantics.facet.as_str() {
                return Err(PlatformTestError::NameMismatch {
                    name: semantics.facet.as_str().to_string(),
                    stem: stem.to_string(),
                });
            }
        }
        Ok(semantics)
    }

    /// Load every `<facet>.apiw` under `dir` (`platforms/macos/tests/api-semantics/`)
    /// into a registry. Each `*.apiw` file is one facet; files are visited in sorted
    /// order. Non-`.apiw` files (a `README.md`) are skipped. A duplicate facet is an
    /// error.
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

        let mut by_facet = BTreeMap::new();
        for file in files {
            let semantics = Self::load_file(&file)?;
            if let Some(prev) = by_facet.insert(semantics.facet, semantics) {
                return Err(PlatformTestError::Io {
                    path: file.display().to_string(),
                    source: std::io::Error::new(
                        std::io::ErrorKind::InvalidData,
                        format!("duplicate api-semantics facet `{}`", prev.facet.as_str()),
                    ),
                });
            }
        }
        Ok(Self { by_facet })
    }

    /// The declarations for this facet, if present.
    pub fn get(&self, facet: Facet) -> Option<&ApiSemantics> {
        self.by_facet.get(&facet)
    }

    /// Every facet's declarations, in facet order.
    pub fn all(&self) -> impl Iterator<Item = &ApiSemantics> {
        self.by_facet.values()
    }

    /// How many facets' declarations are loaded.
    pub fn len(&self) -> usize {
        self.by_facet.len()
    }

    /// Whether the registry is empty.
    pub fn is_empty(&self) -> bool {
        self.by_facet.is_empty()
    }
}

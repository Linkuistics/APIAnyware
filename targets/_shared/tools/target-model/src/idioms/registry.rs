//! The idiom-catalogue **registry**: load `targets/<id>/idioms/catalogue.apiw` into an
//! addressable set of typed [`IdiomCatalogue`]s.
//!
//! The registry is the in-memory face of the authored idiom catalogues. The `emit` crate's
//! `classify_pattern` keys a catalogue to its target, then indexes its projections by
//! pattern-kind. Loading is the full three-layer check: structural
//! ([`crate::idioms::schema`]) → parse + semantic ([`crate::idioms::apiw`]) → the
//! registry-level check that each catalogue's `idiom-catalogue "<id>"` matches its **target
//! directory**.
//!
//! Identity differs from the sibling `descriptor` / `capability` registries in one way: a
//! catalogue lives one level deeper (`<id>/idioms/catalogue.apiw`, not `<id>/<entity>.apiw`)
//! because the §21 docs home (`<id>/idioms/docs/`) forces `idioms/` to be a directory. So
//! the identity check compares the authored id to the **grandparent** of the file (the
//! target directory), not its immediate parent (`idioms/`).

use std::collections::BTreeMap;
use std::path::Path;

use crate::error::{Result, TargetModelError};
use crate::idioms::model::IdiomCatalogue;
use crate::idioms::{apiw, schema};

/// The fixed relative path every idiom catalogue carries under its target directory
/// (identity is the target directory, not this stem).
const CATALOGUE_REL: &str = "idioms/catalogue.apiw";

/// An addressable set of authored idiom catalogues, keyed by target id.
#[derive(Debug, Clone, Default)]
pub struct IdiomCatalogueRegistry {
    catalogues: BTreeMap<String, IdiomCatalogue>,
}

impl IdiomCatalogueRegistry {
    /// Load and fully validate one `<id>/idioms/catalogue.apiw` file into an
    /// [`IdiomCatalogue`], asserting its `idiom-catalogue "<id>"` matches its target
    /// directory (the grandparent of the file).
    pub fn load_file(path: &Path) -> Result<IdiomCatalogue> {
        // Label diagnostics with `<id>/idioms/catalogue.apiw` so a tree of identically
        // named files stays distinguishable.
        let source_name = display_name(path);
        let text = std::fs::read_to_string(path).map_err(|source| TargetModelError::Io {
            path: path.display().to_string(),
            source,
        })?;

        // Layer 1: structural (KDL Schema). Layer 2: parse + semantic.
        schema::validate_idioms(&source_name, &text)?;
        let catalogue = apiw::parse_idioms(&source_name, &text)?;

        // Layer 3: the catalogue's authored id is its TARGET directory (stable identity).
        // `path` is `.../targets/<id>/idioms/catalogue.apiw`, so the target dir is the
        // file's grandparent.
        if let Some(dir) = target_dir_name(path) {
            if dir != catalogue.id {
                return Err(TargetModelError::IdMismatch {
                    entity: "idiom-catalogue",
                    name: catalogue.id.clone(),
                    dir: dir.to_string(),
                });
            }
        }
        Ok(catalogue)
    }

    /// Load every `<id>/idioms/catalogue.apiw` under `dir` (the `targets/` root) into a
    /// registry. Each immediate subdirectory containing `idioms/catalogue.apiw` is one
    /// target; subdirectories are visited in sorted order. Subdirectories without one (the
    /// shared `_shared/` substrate, a target still being homed) are skipped. A duplicate id
    /// is an error.
    pub fn load_dir(dir: &Path) -> Result<Self> {
        let mut subdirs: Vec<_> = std::fs::read_dir(dir)
            .map_err(|source| TargetModelError::Io {
                path: dir.display().to_string(),
                source,
            })?
            .filter_map(|e| e.ok().map(|e| e.path()))
            .filter(|p| p.is_dir() && p.join(CATALOGUE_REL).is_file())
            .collect();
        subdirs.sort();

        let mut catalogues = BTreeMap::new();
        for subdir in subdirs {
            let catalogue = Self::load_file(&subdir.join(CATALOGUE_REL))?;
            if let Some(prev) = catalogues.insert(catalogue.id.clone(), catalogue) {
                return Err(TargetModelError::Io {
                    path: subdir.display().to_string(),
                    source: std::io::Error::new(
                        std::io::ErrorKind::InvalidData,
                        format!("duplicate idiom catalogue id `{}`", prev.id),
                    ),
                });
            }
        }
        Ok(Self { catalogues })
    }

    /// The catalogue for this target id, if present.
    pub fn get(&self, id: &str) -> Option<&IdiomCatalogue> {
        self.catalogues.get(id)
    }

    /// Every catalogue, in id order.
    pub fn catalogues(&self) -> impl Iterator<Item = &IdiomCatalogue> {
        self.catalogues.values()
    }

    /// How many catalogues are loaded.
    pub fn len(&self) -> usize {
        self.catalogues.len()
    }

    /// Whether the registry is empty.
    pub fn is_empty(&self) -> bool {
        self.catalogues.is_empty()
    }
}

/// The target directory name for a `<id>/idioms/catalogue.apiw` path — the grandparent of
/// the file.
fn target_dir_name(path: &Path) -> Option<&str> {
    path.parent()
        .and_then(Path::parent)
        .and_then(Path::file_name)
        .and_then(|n| n.to_str())
}

/// An `<id>/idioms/catalogue.apiw` diagnostic label for a catalogue file path.
fn display_name(path: &Path) -> String {
    match target_dir_name(path) {
        Some(dir) => format!("{dir}/{CATALOGUE_REL}"),
        None => CATALOGUE_REL.to_string(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn load_file_rejects_id_directory_mismatch() {
        // A temp `wrongdir/idioms/catalogue.apiw` whose authored id is `sbcl` — the
        // registry identity check (against the grandparent) must reject it.
        let dir = std::env::temp_dir().join("apianyware-target-model-test-idioms-mismatch");
        let idioms_dir = dir.join("wrongdir").join("idioms");
        std::fs::create_dir_all(&idioms_dir).expect("scratch dir");
        let file = idioms_dir.join("catalogue.apiw");
        std::fs::write(
            &file,
            r#"
            idiom-catalogue "sbcl" {
                idiom "bracketed-use" { construct "with-macro" }
            }
            "#,
        )
        .expect("write fixture");

        let err = IdiomCatalogueRegistry::load_file(&file).expect_err("id/dir mismatch rejected");
        assert!(matches!(err, TargetModelError::IdMismatch { .. }));

        let _ = std::fs::remove_dir_all(&dir);
    }
}

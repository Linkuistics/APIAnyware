//! Framework JSON checkpoint loading utilities.
//!
//! Reads `{Framework}.json` checkpoint files from a directory and
//! deserializes them into [`Framework`] values.

use std::path::{Path, PathBuf};

use anyhow::{Context, Result};
use apianyware_types::Framework;

/// Discover all `*.json` framework files in a directory, sorted by name.
///
/// Only matches files named `{Name}.json` (no dots in the stem), so
/// ancillary files like `Foundation.patterns.json` are excluded.
pub fn discover_framework_files(directory: &Path) -> Result<Vec<PathBuf>> {
    let mut files: Vec<PathBuf> = std::fs::read_dir(directory)
        .with_context(|| format!("failed to read directory: {}", directory.display()))?
        .filter_map(|entry| {
            let entry = entry.ok()?;
            let path = entry.path();
            if path.extension().is_some_and(|ext| ext == "json") {
                // Skip files with dots in the stem (e.g., "Foundation.patterns.json")
                let stem = path.file_stem()?.to_str()?;
                if !stem.contains('.') {
                    return Some(path);
                }
            }
            None
        })
        .collect();
    files.sort();
    Ok(files)
}

/// Load a single framework from a JSON checkpoint file.
pub fn load_framework_from_file(path: &Path) -> Result<Framework> {
    let json = std::fs::read_to_string(path)
        .with_context(|| format!("failed to read: {}", path.display()))?;
    let framework: Framework = serde_json::from_str(&json)
        .with_context(|| format!("failed to parse: {}", path.display()))?;
    Ok(framework)
}

/// Load all framework JSON files from a directory.
///
/// Returns frameworks sorted by file name. If `only` is provided,
/// only frameworks whose names match the list are loaded.
pub fn load_all_frameworks(directory: &Path, only: Option<&[String]>) -> Result<Vec<Framework>> {
    let files = discover_framework_files(directory)?;
    let mut frameworks = Vec::new();

    for file in &files {
        let framework = load_framework_from_file(file)?;

        if let Some(filter) = only {
            if !filter.iter().any(|name| name == &framework.name) {
                continue;
            }
        }

        tracing::info!(
            framework = %framework.name,
            classes = framework.classes.len(),
            protocols = framework.protocols.len(),
            "loaded framework"
        );
        frameworks.push(framework);
    }

    Ok(frameworks)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;

    fn collected_ir_directory() -> PathBuf {
        PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("..")
            .join("..")
            .join("..")
            .join("collection")
            .join("ir")
            .join("collected")
    }

    #[test]
    fn discover_collected_framework_files() {
        let dir = collected_ir_directory();
        if !dir.exists() {
            eprintln!("skipping: no collected IR at {}", dir.display());
            return;
        }
        let files = discover_framework_files(&dir).unwrap();
        assert!(!files.is_empty(), "should find at least one JSON file");
        for file in &files {
            assert_eq!(file.extension().unwrap(), "json");
        }
    }

    #[test]
    fn load_foundation_from_collected() {
        let dir = collected_ir_directory();
        let path = dir.join("Foundation.json");
        if !path.exists() {
            eprintln!("skipping: no Foundation.json at {}", path.display());
            return;
        }
        let fw = load_framework_from_file(&path).unwrap();
        assert_eq!(fw.name, "Foundation");
        assert!(!fw.classes.is_empty());
        assert!(!fw.protocols.is_empty());
    }

    #[test]
    fn load_all_with_filter() {
        let dir = collected_ir_directory();
        if !dir.exists() {
            eprintln!("skipping: no collected IR at {}", dir.display());
            return;
        }
        let only = vec!["Foundation".to_string()];
        let frameworks = load_all_frameworks(&dir, Some(&only)).unwrap();
        assert_eq!(frameworks.len(), 1);
        assert_eq!(frameworks[0].name, "Foundation");
    }
}

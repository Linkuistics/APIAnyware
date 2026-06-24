//! Read canonical sample-app metadata from `apps/macos/<script>/docs/spec.md`.
//!
//! Identical to bundle-racket's spec reader — the spec.md file is
//! target-agnostic, so the chez bundler reuses the same convention:
//! first markdown H1 is the human-readable display name.

use std::fs;
use std::path::Path;

/// Read the first markdown H1 (`# Title`) from `spec_md_path` and return
/// it as the display name. Returns `None` if the file is missing,
/// unreadable, or has no leading H1.
pub fn read_display_name_from_spec(spec_md_path: &Path) -> Option<String> {
    let content = fs::read_to_string(spec_md_path).ok()?;
    for line in content.lines() {
        let trimmed = line.trim_start();
        if let Some(rest) = trimmed.strip_prefix("# ") {
            let title = rest.trim().to_string();
            if !title.is_empty() {
                return Some(title);
            }
        }
        if !trimmed.is_empty() {
            return None;
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    fn write(dir: &Path, name: &str, content: &str) -> std::path::PathBuf {
        let p = dir.join(name);
        fs::write(&p, content).unwrap();
        p
    }

    #[test]
    fn extracts_first_h1_as_display_name() {
        let dir = TempDir::new().unwrap();
        let p = write(
            dir.path(),
            "spec.md",
            "# UI Controls Gallery\n\n**Complexity:** 3/7\n",
        );
        assert_eq!(
            read_display_name_from_spec(&p),
            Some("UI Controls Gallery".to_string())
        );
    }

    #[test]
    fn returns_none_when_file_missing() {
        let dir = TempDir::new().unwrap();
        assert_eq!(
            read_display_name_from_spec(&dir.path().join("nope.md")),
            None
        );
    }

    #[test]
    fn returns_none_when_no_h1() {
        let dir = TempDir::new().unwrap();
        let p = write(dir.path(), "spec.md", "**Complexity:** 1/7\n");
        assert_eq!(read_display_name_from_spec(&p), None);
    }

    #[test]
    fn does_not_pick_up_buried_h1() {
        let dir = TempDir::new().unwrap();
        let p = write(
            dir.path(),
            "spec.md",
            "Some intro paragraph.\n\n# Not the app name\n",
        );
        assert_eq!(read_display_name_from_spec(&p), None);
    }
}

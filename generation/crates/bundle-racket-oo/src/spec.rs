//! Read canonical sample-app metadata from `knowledge/apps/<script>/spec.md`.
//!
//! Each sample app has a spec file whose first markdown H1 is the
//! human-readable display name — `# UI Controls Gallery` for the
//! `ui-controls-gallery` script, `# Hello Window` for `hello-window`,
//! and so on. Bundlers should prefer this over kebab→title conversion
//! of the script name, because it preserves multi-letter acronyms
//! (`UI`) and editorial casing the conversion can't recover.

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
        // Skip empty/whitespace lines before the first H1; bail on any
        // other content so we don't pick up an H1 buried lower in the
        // doc by accident.
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
        let missing = dir.path().join("nope.md");
        assert_eq!(read_display_name_from_spec(&missing), None);
    }

    #[test]
    fn returns_none_when_no_h1() {
        let dir = TempDir::new().unwrap();
        let p = write(dir.path(), "spec.md", "**Complexity:** 1/7\n");
        assert_eq!(read_display_name_from_spec(&p), None);
    }

    #[test]
    fn skips_leading_blank_lines() {
        let dir = TempDir::new().unwrap();
        let p = write(dir.path(), "spec.md", "\n\n# Modaliser\n");
        assert_eq!(read_display_name_from_spec(&p), Some("Modaliser".to_string()));
    }

    #[test]
    fn does_not_pick_up_buried_h1() {
        // Don't accidentally promote a section header to the app name.
        let dir = TempDir::new().unwrap();
        let p = write(
            dir.path(),
            "spec.md",
            "Some intro paragraph.\n\n# Not the app name\n",
        );
        assert_eq!(read_display_name_from_spec(&p), None);
    }

    #[test]
    fn trims_whitespace_around_h1_text() {
        let dir = TempDir::new().unwrap();
        let p = write(dir.path(), "spec.md", "#   Hello Window   \n");
        assert_eq!(
            read_display_name_from_spec(&p),
            Some("Hello Window".to_string())
        );
    }
}

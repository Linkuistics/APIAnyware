//! Golden-file snapshot testing harness for emitter regression tests.
//!
//! Provides utilities to compare generated emitter output against checked-in
//! golden reference files. When the `UPDATE_GOLDEN` environment variable is set
//! to `"1"`, golden files are updated instead of compared.
//!
//! # Usage
//!
//! ```no_run
//! use apianyware_emit::snapshot_testing::GoldenTest;
//! # use std::path::Path;
//!
//! let golden_test = GoldenTest::new(Path::new("tests/golden"), "racket");
//! golden_test.assert_matches(Path::new("/tmp/generated")).unwrap();
//! ```

use std::collections::BTreeSet;
use std::fmt::Write as FmtWrite;
use std::path::{Path, PathBuf};
use std::{env, fs, io};

/// Golden-file test runner.
///
/// Compares a directory of generated files against a directory of golden
/// (reference) files. Reports missing, extra, and changed files.
pub struct GoldenTest {
    /// Root directory containing golden files (e.g., `tests/golden/`).
    golden_dir: PathBuf,
    /// Target identifier (e.g., `"racket"`).
    target: String,
}

impl GoldenTest {
    /// Create a new golden test runner.
    ///
    /// Golden files are expected directly under `golden_dir`.
    pub fn new(golden_dir: &Path, target: &str) -> Self {
        Self {
            golden_dir: golden_dir.to_path_buf(),
            target: target.to_string(),
        }
    }

    /// Compare generated output against golden files.
    ///
    /// If `UPDATE_GOLDEN=1` is set, updates golden files from generated output
    /// instead of comparing. Otherwise, asserts that the generated output
    /// matches the golden files exactly.
    ///
    /// Returns `Ok(())` if files match (or were updated), `Err` with a
    /// descriptive diff report if they differ.
    pub fn assert_matches(&self, generated_dir: &Path) -> Result<(), GoldenMismatch> {
        if env::var("UPDATE_GOLDEN").as_deref() == Ok("1") {
            update_golden_directory(generated_dir, &self.golden_dir)?;
            eprintln!(
                "Updated golden files for {} at {}",
                self.target,
                self.golden_dir.display()
            );
            return Ok(());
        }

        compare_directories(generated_dir, &self.golden_dir, &self.target)
    }

    /// Compare a subset of generated output against golden files.
    ///
    /// Like `assert_matches`, but only checks files that exist in the golden
    /// directory — extra files in the generated output are ignored. Useful for
    /// curated golden sets of large frameworks (e.g., 20 representative files
    /// from Foundation rather than all 300+).
    ///
    /// If `UPDATE_GOLDEN=1` is set, copies only the specified files from the
    /// generated output into the golden directory.
    pub fn assert_subset_matches(
        &self,
        generated_dir: &Path,
        golden_file_list: &[&str],
    ) -> Result<(), GoldenMismatch> {
        if env::var("UPDATE_GOLDEN").as_deref() == Ok("1") {
            update_golden_subset(generated_dir, &self.golden_dir, golden_file_list)?;
            eprintln!(
                "Updated {} golden subset files for {} at {}",
                golden_file_list.len(),
                self.target,
                self.golden_dir.display()
            );
            return Ok(());
        }

        compare_subset(
            generated_dir,
            &self.golden_dir,
            golden_file_list,
            &self.target,
        )
    }
}

/// Error type for golden file mismatches.
#[derive(Debug)]
pub enum GoldenMismatch {
    /// Files don't match — contains a human-readable diff report.
    Diff(String),
    /// IO error during comparison or update.
    Io(io::Error),
}

impl std::fmt::Display for GoldenMismatch {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Diff(report) => write!(f, "{report}"),
            Self::Io(err) => write!(f, "IO error: {err}"),
        }
    }
}

impl std::error::Error for GoldenMismatch {}

impl From<io::Error> for GoldenMismatch {
    fn from(err: io::Error) -> Self {
        Self::Io(err)
    }
}

/// Collect all file paths relative to `base_dir`, sorted lexicographically.
fn collect_relative_paths(base_dir: &Path) -> io::Result<BTreeSet<PathBuf>> {
    let mut paths = BTreeSet::new();
    if !base_dir.exists() {
        return Ok(paths);
    }
    collect_recursive(base_dir, base_dir, &mut paths)?;
    Ok(paths)
}

fn collect_recursive(base: &Path, current: &Path, paths: &mut BTreeSet<PathBuf>) -> io::Result<()> {
    for entry in fs::read_dir(current)? {
        let entry = entry?;
        let path = entry.path();
        if path.is_dir() {
            collect_recursive(base, &path, paths)?;
        } else {
            let relative = path
                .strip_prefix(base)
                .expect("path must be under base directory");
            paths.insert(relative.to_path_buf());
        }
    }
    Ok(())
}

/// Compare two directory trees and produce a diff report.
fn compare_directories(
    generated_dir: &Path,
    golden_dir: &Path,
    target: &str,
) -> Result<(), GoldenMismatch> {
    let generated_files = collect_relative_paths(generated_dir)?;
    let golden_files = collect_relative_paths(golden_dir)?;

    let mut report = String::new();
    let mut has_diff = false;

    // Files in golden but not in generated (missing)
    for path in golden_files.difference(&generated_files) {
        has_diff = true;
        writeln!(
            report,
            "MISSING (in golden, not generated): {}",
            path.display()
        )
        .unwrap();
    }

    // Files in generated but not in golden (extra)
    for path in generated_files.difference(&golden_files) {
        has_diff = true;
        writeln!(
            report,
            "EXTRA (generated, not in golden): {}",
            path.display()
        )
        .unwrap();
    }

    // Files in both — compare content
    for path in generated_files.intersection(&golden_files) {
        let generated_content = fs::read_to_string(generated_dir.join(path))?;
        let golden_content = fs::read_to_string(golden_dir.join(path))?;

        if generated_content != golden_content {
            has_diff = true;
            writeln!(report, "\nDIFFERS: {}", path.display()).unwrap();
            append_unified_diff(
                &report_buffer(&golden_content),
                &report_buffer(&generated_content),
                path,
                &mut report,
            );
        }
    }

    if has_diff {
        let header = format!(
            "Golden file mismatch for {target}.\n\
             Golden dir: {}\n\
             Generated dir: {}\n\
             Run with UPDATE_GOLDEN=1 to accept the new output.\n\n",
            golden_dir.display(),
            generated_dir.display(),
        );
        Err(GoldenMismatch::Diff(header + &report))
    } else {
        Ok(())
    }
}

/// Produce a simple unified-style diff between two strings.
fn append_unified_diff(golden: &str, generated: &str, path: &Path, out: &mut String) {
    let golden_lines: Vec<&str> = golden.lines().collect();
    let generated_lines: Vec<&str> = generated.lines().collect();

    writeln!(out, "--- golden/{}", path.display()).unwrap();
    writeln!(out, "+++ generated/{}", path.display()).unwrap();

    // Simple line-by-line diff (not a true LCS diff, but clear enough for test output)
    let max_lines = golden_lines.len().max(generated_lines.len());
    let context = 3;
    let mut in_hunk = false;
    let mut hunk_start = 0;

    for i in 0..max_lines {
        let g = golden_lines.get(i).copied();
        let n = generated_lines.get(i).copied();

        if g != n {
            if !in_hunk {
                hunk_start = i.saturating_sub(context);
                writeln!(out, "@@ line {} @@", hunk_start + 1).unwrap();
                // Print context before
                for j in hunk_start..i {
                    if let Some(line) = golden_lines.get(j) {
                        writeln!(out, " {line}").unwrap();
                    }
                }
                in_hunk = true;
            }
            if let Some(line) = g {
                writeln!(out, "-{line}").unwrap();
            }
            if let Some(line) = n {
                writeln!(out, "+{line}").unwrap();
            }
        } else if in_hunk {
            // Print trailing context
            if let Some(line) = g {
                writeln!(out, " {line}").unwrap();
            }
            if i >= hunk_start + context * 2 {
                in_hunk = false;
            }
        }
    }
}

/// Ensure trailing newline for clean diff output.
fn report_buffer(content: &str) -> String {
    if content.ends_with('\n') {
        content.to_string()
    } else {
        format!("{content}\n")
    }
}

/// Copy generated files into the golden directory (replacing it entirely).
fn update_golden_directory(generated_dir: &Path, golden_dir: &Path) -> io::Result<()> {
    // Remove old golden dir if it exists
    if golden_dir.exists() {
        fs::remove_dir_all(golden_dir)?;
    }
    copy_dir_recursive(generated_dir, golden_dir)
}

/// Recursively copy a directory tree.
fn copy_dir_recursive(src: &Path, dst: &Path) -> io::Result<()> {
    fs::create_dir_all(dst)?;
    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let src_path = entry.path();
        let dst_path = dst.join(entry.file_name());
        if src_path.is_dir() {
            copy_dir_recursive(&src_path, &dst_path)?;
        } else {
            fs::copy(&src_path, &dst_path)?;
        }
    }
    Ok(())
}

/// Compare only the specified files between generated and golden directories.
fn compare_subset(
    generated_dir: &Path,
    golden_dir: &Path,
    file_list: &[&str],
    target: &str,
) -> Result<(), GoldenMismatch> {
    let mut report = String::new();
    let mut has_diff = false;

    for rel_path_str in file_list {
        let rel_path = Path::new(rel_path_str);
        let golden_file = golden_dir.join(rel_path);
        let generated_file = generated_dir.join(rel_path);

        if !golden_file.exists() {
            has_diff = true;
            writeln!(
                report,
                "MISSING GOLDEN: {} (run with UPDATE_GOLDEN=1)",
                rel_path_str
            )
            .unwrap();
            continue;
        }

        if !generated_file.exists() {
            has_diff = true;
            writeln!(report, "NOT GENERATED: {}", rel_path_str).unwrap();
            continue;
        }

        let golden_content = fs::read_to_string(&golden_file)?;
        let generated_content = fs::read_to_string(&generated_file)?;

        if generated_content != golden_content {
            has_diff = true;
            writeln!(report, "\nDIFFERS: {}", rel_path_str).unwrap();
            append_unified_diff(
                &report_buffer(&golden_content),
                &report_buffer(&generated_content),
                rel_path,
                &mut report,
            );
        }
    }

    if has_diff {
        let header = format!(
            "Golden subset mismatch for {target}.\n\
             Golden dir: {}\n\
             Generated dir: {}\n\
             Checked {} files.\n\
             Run with UPDATE_GOLDEN=1 to accept the new output.\n\n",
            golden_dir.display(),
            generated_dir.display(),
            file_list.len(),
        );
        Err(GoldenMismatch::Diff(header + &report))
    } else {
        Ok(())
    }
}

/// Copy only specified files from generated output into the golden directory.
fn update_golden_subset(
    generated_dir: &Path,
    golden_dir: &Path,
    file_list: &[&str],
) -> io::Result<()> {
    for rel_path_str in file_list {
        let rel_path = Path::new(rel_path_str);
        let src = generated_dir.join(rel_path);
        let dst = golden_dir.join(rel_path);

        if src.exists() {
            if let Some(parent) = dst.parent() {
                fs::create_dir_all(parent)?;
            }
            fs::copy(&src, &dst)?;
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_collect_relative_paths_empty() {
        let dir = tempfile::tempdir().unwrap();
        let paths = collect_relative_paths(dir.path()).unwrap();
        assert!(paths.is_empty());
    }

    #[test]
    fn test_collect_relative_paths_with_files() {
        let dir = tempfile::tempdir().unwrap();
        fs::write(dir.path().join("a.rkt"), "content-a").unwrap();
        fs::create_dir(dir.path().join("sub")).unwrap();
        fs::write(dir.path().join("sub/b.rkt"), "content-b").unwrap();

        let paths = collect_relative_paths(dir.path()).unwrap();
        let names: Vec<String> = paths.iter().map(|p| p.display().to_string()).collect();
        assert_eq!(names, vec!["a.rkt", "sub/b.rkt"]);
    }

    #[test]
    fn test_collect_relative_paths_nonexistent_dir() {
        let paths = collect_relative_paths(Path::new("/nonexistent/dir")).unwrap();
        assert!(paths.is_empty());
    }

    #[test]
    fn test_compare_matching_directories() {
        let gen_dir = tempfile::tempdir().unwrap();
        let golden_dir = tempfile::tempdir().unwrap();

        fs::write(gen_dir.path().join("file.rkt"), "(define x 1)\n").unwrap();
        fs::write(golden_dir.path().join("file.rkt"), "(define x 1)\n").unwrap();

        let result = compare_directories(gen_dir.path(), golden_dir.path(), "racket");
        assert!(result.is_ok());
    }

    #[test]
    fn test_compare_detects_missing_file() {
        let gen_dir = tempfile::tempdir().unwrap();
        let golden_dir = tempfile::tempdir().unwrap();

        fs::write(golden_dir.path().join("expected.rkt"), "content").unwrap();

        let result = compare_directories(gen_dir.path(), golden_dir.path(), "racket");
        match result {
            Err(GoldenMismatch::Diff(report)) => {
                assert!(report.contains("MISSING"));
                assert!(report.contains("expected.rkt"));
            }
            other => panic!("Expected Diff, got: {other:?}"),
        }
    }

    #[test]
    fn test_compare_detects_extra_file() {
        let gen_dir = tempfile::tempdir().unwrap();
        let golden_dir = tempfile::tempdir().unwrap();

        fs::write(gen_dir.path().join("extra.rkt"), "content").unwrap();

        let result = compare_directories(gen_dir.path(), golden_dir.path(), "racket");
        match result {
            Err(GoldenMismatch::Diff(report)) => {
                assert!(report.contains("EXTRA"));
                assert!(report.contains("extra.rkt"));
            }
            other => panic!("Expected Diff, got: {other:?}"),
        }
    }

    #[test]
    fn test_compare_detects_content_difference() {
        let gen_dir = tempfile::tempdir().unwrap();
        let golden_dir = tempfile::tempdir().unwrap();

        fs::write(gen_dir.path().join("file.rkt"), "(define x 2)\n").unwrap();
        fs::write(golden_dir.path().join("file.rkt"), "(define x 1)\n").unwrap();

        let result = compare_directories(gen_dir.path(), golden_dir.path(), "racket");
        match result {
            Err(GoldenMismatch::Diff(report)) => {
                assert!(report.contains("DIFFERS"));
                assert!(report.contains("file.rkt"));
                assert!(report.contains("-(define x 1)"));
                assert!(report.contains("+(define x 2)"));
            }
            other => panic!("Expected Diff, got: {other:?}"),
        }
    }

    #[test]
    fn test_compare_with_subdirectories() {
        let gen_dir = tempfile::tempdir().unwrap();
        let golden_dir = tempfile::tempdir().unwrap();

        fs::create_dir(gen_dir.path().join("protocols")).unwrap();
        fs::create_dir(golden_dir.path().join("protocols")).unwrap();

        fs::write(gen_dir.path().join("main.rkt"), "main").unwrap();
        fs::write(golden_dir.path().join("main.rkt"), "main").unwrap();
        fs::write(gen_dir.path().join("protocols/nscopying.rkt"), "proto").unwrap();
        fs::write(golden_dir.path().join("protocols/nscopying.rkt"), "proto").unwrap();

        let result = compare_directories(gen_dir.path(), golden_dir.path(), "racket");
        assert!(result.is_ok());
    }

    #[test]
    fn test_update_golden_directory() {
        let gen_dir = tempfile::tempdir().unwrap();
        let golden_dir = tempfile::tempdir().unwrap();

        fs::write(gen_dir.path().join("new.rkt"), "new content").unwrap();
        fs::create_dir(gen_dir.path().join("sub")).unwrap();
        fs::write(gen_dir.path().join("sub/nested.rkt"), "nested").unwrap();

        // Pre-populate golden with different content
        fs::write(golden_dir.path().join("old.rkt"), "old content").unwrap();

        let golden_target = golden_dir.path().join("target");
        update_golden_directory(gen_dir.path(), &golden_target).unwrap();

        // Should have new files, not old
        assert!(golden_target.join("new.rkt").exists());
        assert!(golden_target.join("sub/nested.rkt").exists());
        assert_eq!(
            fs::read_to_string(golden_target.join("new.rkt")).unwrap(),
            "new content"
        );
        assert_eq!(
            fs::read_to_string(golden_target.join("sub/nested.rkt")).unwrap(),
            "nested"
        );
    }

    #[test]
    #[allow(unsafe_code)]
    fn test_golden_test_update_mode() {
        let gen_dir = tempfile::tempdir().unwrap();
        let golden_root = tempfile::tempdir().unwrap();

        fs::write(gen_dir.path().join("file.rkt"), "content").unwrap();

        // Temporarily set UPDATE_GOLDEN
        // SAFETY: test runs single-threaded; no other thread reads this env var concurrently.
        unsafe { env::set_var("UPDATE_GOLDEN", "1") };
        let test = GoldenTest::new(golden_root.path(), "racket");
        let result = test.assert_matches(gen_dir.path());
        // SAFETY: same as above.
        unsafe { env::remove_var("UPDATE_GOLDEN") };

        assert!(result.is_ok());
        assert!(golden_root.path().join("file.rkt").exists());
    }
}

//! Vendor the non-system dylibs an sbcl `.app` needs into
//! `Contents/Frameworks/` (ADR-0041).
//!
//! Two categories, both resolved **without** editing the dumped image (post-dump
//! `install_name_tool` is impossible — the Lisp core sits past `__LINKEDIT`):
//!
//! 1. **Homebrew load commands** (`libzstd`, SBCL's core compression) — a *hard*
//!    `LC_LOAD_DYLIB` with an absolute `/opt/homebrew/...` path. Vendored by leaf
//!    name; the stub's `DYLD_FALLBACK_LIBRARY_PATH` makes dyld resolve it by leaf
//!    name when the absolute path is absent on a clean target.
//! 2. **The residual dylib** (`libAPIAnywareSbcl`, residual apps only) — `dlopen`ed,
//!    not a load command. The dump already recorded its `@executable_path/..`
//!    namestring (ADR-0041); we just vendor the file there.
//!
//! Each vendored dylib is re-signed with the bundle's identity so the whole-bundle
//! seal is consistent. The dumped image is **never** touched or re-signed.

use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process::Command;

use apianyware_stub_launcher::codesign_path;

use crate::spec::BundleError;

/// The Homebrew prefix vendored Homebrew dependencies live under.
const HOMEBREW_PREFIX: &str = "/opt/homebrew/";

/// Parse `otool -L` output into the dependency load-command paths under the
/// Homebrew prefix. The unindented first line (the binary's own path) is skipped;
/// dependency lines are whitespace-indented `<path> (compatibility version …)`.
pub fn homebrew_deps_of(otool_output: &str) -> Vec<String> {
    otool_output
        .lines()
        .filter(|line| line.starts_with([' ', '\t']))
        .filter_map(|line| {
            let trimmed = line.trim();
            let path = trimmed.split(" (").next().unwrap_or(trimmed);
            path.starts_with(HOMEBREW_PREFIX).then(|| path.to_string())
        })
        .collect()
}

/// Vendor every Homebrew dylib the dumped `image` links (by leaf name) plus the
/// residual `swift_dylib` (when the app loads it) into `frameworks_dir`,
/// re-signing each. Returns the vendored paths (for logging).
pub fn vendor_dylibs(
    image: &Path,
    frameworks_dir: &Path,
    swift_dylib: Option<&Path>,
    identity: &str,
) -> Result<Vec<PathBuf>, BundleError> {
    fs::create_dir_all(frameworks_dir)?;
    let mut vendored = Vec::new();

    // 1. Homebrew load commands of the image (libzstd). Keyed by leaf name —
    //    DYLD_FALLBACK_LIBRARY_PATH resolves by leaf name, and that is also the
    //    vendoring identity (two deps with the same basename collapse to one file).
    for dep in homebrew_deps_of(&otool_l(image)?) {
        let src = PathBuf::from(&dep);
        let base = match src.file_name() {
            Some(n) => n.to_os_string(),
            None => continue,
        };
        let dst = frameworks_dir.join(&base);
        if dst.exists() {
            continue;
        }
        if !src.exists() {
            return Err(BundleError::DylibSourceMissing(src));
        }
        copy_writable(&src, &dst)?;
        codesign_path(&dst, identity)?;
        vendored.push(dst);
    }

    // 2. The residual dylib (dlopen'd; namestring already relocated at dump).
    if let Some(src) = swift_dylib {
        if !src.exists() {
            return Err(BundleError::DylibSourceMissing(src.to_path_buf()));
        }
        let base = src.file_name().expect("dylib basename");
        let dst = frameworks_dir.join(base);
        copy_writable(src, &dst)?;
        codesign_path(&dst, identity)?;
        vendored.push(dst);
    }

    Ok(vendored)
}

/// Copy `src` to `dst` and make it writable+signable (Homebrew dylibs ship 0444).
fn copy_writable(src: &Path, dst: &Path) -> Result<(), BundleError> {
    fs::copy(src, dst)?;
    let mut perms = fs::metadata(dst)?.permissions();
    perms.set_mode(0o644);
    fs::set_permissions(dst, perms)?;
    Ok(())
}

/// `otool -L <path>`.
pub fn otool_l(path: &Path) -> Result<String, BundleError> {
    let out = Command::new("otool")
        .arg("-L")
        .arg(path)
        .output()
        .map_err(|source| BundleError::ToolNotAvailable {
            tool: "otool",
            source,
        })?;
    if !out.status.success() {
        return Err(BundleError::OtoolFailed {
            path: path.to_path_buf(),
            stderr: String::from_utf8_lossy(&out.stderr).into_owned(),
        });
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Real `otool -L` of a dumped sbcl image (060): only libSystem + the
    /// Homebrew libzstd SBCL links for core compression.
    const IMAGE_OTOOL: &str = "\
build/HelloWindow.app/Contents/Resources/hello-window:
\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1356.0.0)
\t/opt/homebrew/opt/zstd/lib/libzstd.1.dylib (compatibility version 1.0.0, current version 1.5.7)
";

    #[test]
    fn homebrew_deps_extracts_only_libzstd() {
        assert_eq!(
            homebrew_deps_of(IMAGE_OTOOL),
            vec!["/opt/homebrew/opt/zstd/lib/libzstd.1.dylib"]
        );
    }

    #[test]
    fn homebrew_deps_skips_header_and_system() {
        // The unindented header line is the image's own path; libSystem is system.
        assert!(homebrew_deps_of("x:\n\t/usr/lib/libSystem.B.dylib (v)\n").is_empty());
    }
}

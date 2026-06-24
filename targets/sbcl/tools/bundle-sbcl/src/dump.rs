//! Drive `sbcl` to dump a self-contained image for a sample app.
//!
//! The productized counterpart to each app's dev `build.sh` + `dump.lisp`. The
//! bundler **reuses the app's own `dump.lisp`** unchanged — it already declares
//! the app's framework set, `:load-residual` flags, and `save-lisp-and-die`
//! `:toplevel` (the run loop). We only redirect its output path and, for a
//! residual app, relocate the recorded dylib namestring (ADR-0041):
//!
//! ```text
//! [SDKROOT=…] [AW_NATIVE_DYLIB_RECORD_AS=@executable_path/../Frameworks/libAPIAnywareSbcl.dylib]
//!   sbcl --non-interactive --disable-debugger --load <app>/dump.lisp -- <image-out> [<dylib-build-path>]
//! ```
//!
//! `dump.lisp` reads arg 1 as the output image path and (residual apps) arg 2 as
//! the dylib to load. The runtime's `aw-load-native-dylib` loads from that real
//! build path (so every `aw_sbcl_*` symbol resolves at dump time) and, seeing the
//! `AW_NATIVE_DYLIB_RECORD_AS` env, records the `@executable_path/..` namestring
//! the revived image re-opens by — no post-dump Mach-O surgery.

use std::path::{Path, PathBuf};
use std::process::Command;

use crate::spec::BundleError;

/// The Swift-native dylib basename (ADR-0038 — the sbcl target's sole native unit).
pub const SWIFT_DYLIB_NAME: &str = "libAPIAnywareSbcl.dylib";

/// The env var the runtime's `aw-load-native-dylib` honours to record an
/// `@executable_path`-relative namestring for the dumped image (ADR-0041).
pub const RECORD_AS_ENV: &str = "AW_NATIVE_DYLIB_RECORD_AS";

/// The `@executable_path`-relative namestring the revived image re-opens the
/// vendored `libAPIAnywareSbcl` by. `@executable_path` is the dumped *image*
/// (which the stub `execv`s) under `Contents/Resources/`, so `../Frameworks`
/// resolves to `Contents/Frameworks/`.
pub const DYLIB_RECORD_AS: &str = "@executable_path/../Frameworks/libAPIAnywareSbcl.dylib";

/// Does the app's `dump.lisp` load `libAPIAnywareSbcl`? A static check of the
/// driver source: an app that calls `aw-load-native-dylib` needs the dylib
/// `dlopen`ed (Swift-native residual, or the block/subclass bounce shim) and so
/// gets the dylib vendored + the namestring relocation. A pure-ObjC app
/// (hello-window) never calls it — `otool -L` then shows only system libs +
/// libzstd.
pub fn driver_needs_dylib(driver: &Path) -> bool {
    std::fs::read_to_string(driver)
        .map(|s| s.contains("(aw-load-native-dylib"))
        .unwrap_or(false)
}

/// Locate the built `libAPIAnywareSbcl.dylib`, building it with `swift build`
/// when absent. Mirrors the dev `build.sh` step 0. Arch-agnostic: scans every
/// `targets/sbcl/adapters/macos/.build/<triple>/{release,debug}/` for the
/// artifact (the §18 per-target adapter package; `move-sbcl-material-k14` split
/// it out of the shared `swift/.build` umbrella).
pub fn ensure_swift_dylib(workspace_root: &Path) -> Result<PathBuf, BundleError> {
    if let Some(found) = discover_swift_dylib(workspace_root) {
        return Ok(found);
    }
    // Not built yet — drive `swift build --product APIAnywareSbcl` in the adapter.
    let swift_dir = adapter_package_dir(workspace_root);
    let out = Command::new("swift")
        .args(["build", "--product", "APIAnywareSbcl"])
        .current_dir(&swift_dir)
        .output()
        .map_err(|source| BundleError::SwiftBuildNotAvailable { source })?;
    if !out.status.success() {
        return Err(BundleError::SwiftDylibBuildFailed {
            dylib: swift_dir
                .join(".build/<triple>/debug")
                .join(SWIFT_DYLIB_NAME),
            stderr: String::from_utf8_lossy(&out.stderr).into_owned(),
        });
    }
    discover_swift_dylib(workspace_root).ok_or_else(|| BundleError::SwiftDylibBuildFailed {
        dylib: swift_dir.join(".build"),
        stderr: "swift build reported success but the dylib was not found".into(),
    })
}

/// The §18 per-target Swift adapter package directory
/// (`targets/sbcl/adapters/macos/`) under `workspace_root` — where
/// `swift build --product APIAnywareSbcl` writes `.build/` since
/// `move-sbcl-material-k14`.
fn adapter_package_dir(workspace_root: &Path) -> PathBuf {
    workspace_root
        .join("targets")
        .join("sbcl")
        .join("adapters")
        .join("macos")
}

/// Scan `targets/sbcl/adapters/macos/.build/<triple>/{release,debug}/libAPIAnywareSbcl.dylib`.
pub fn discover_swift_dylib(workspace_root: &Path) -> Option<PathBuf> {
    let build_root = adapter_package_dir(workspace_root).join(".build");
    let mut triple_dirs: Vec<PathBuf> = Vec::new();
    if let Ok(entries) = std::fs::read_dir(&build_root) {
        for e in entries.flatten() {
            let p = e.path();
            if p.is_dir() {
                let name = p.file_name().and_then(|n| n.to_str()).unwrap_or("");
                if name != "release" && name != "debug" && name != "checkouts" {
                    triple_dirs.push(p);
                }
            }
        }
    }
    triple_dirs.sort();
    for triple in &triple_dirs {
        for profile in ["release", "debug"] {
            let candidate = triple.join(profile).join(SWIFT_DYLIB_NAME);
            if candidate.is_file() {
                return Some(candidate);
            }
        }
    }
    None
}

/// Run the app's `dump.lisp` to write a `save-lisp-and-die :executable t` image
/// at `image_out`. When `dylib` is `Some`, it is passed as arg 2 and the
/// namestring-relocation env is set so the dumped image re-opens the vendored
/// copy exe-relative.
pub fn dump_image(
    driver: &Path,
    image_out: &Path,
    dylib: Option<&Path>,
    sdkroot: &str,
) -> Result<(), BundleError> {
    if !driver.exists() {
        return Err(BundleError::DumpDriverMissing {
            driver: driver.to_path_buf(),
        });
    }
    if let Some(parent) = image_out.parent() {
        std::fs::create_dir_all(parent)?;
    }

    let mut cmd = Command::new("sbcl");
    cmd.args(["--non-interactive", "--disable-debugger", "--load"])
        .arg(driver)
        .arg("--")
        .arg(image_out)
        .env("SDKROOT", sdkroot);
    if let Some(dylib) = dylib {
        cmd.arg(dylib);
        cmd.env(RECORD_AS_ENV, DYLIB_RECORD_AS);
    }

    let out = cmd.output().map_err(|e| {
        if e.kind() == std::io::ErrorKind::NotFound {
            BundleError::SbclNotFound
        } else {
            BundleError::ToolNotAvailable {
                tool: "sbcl",
                source: e,
            }
        }
    })?;
    if !out.status.success() {
        return Err(BundleError::DumpFailed {
            script: driver.display().to_string(),
            stderr: format!(
                "{}\n{}",
                String::from_utf8_lossy(&out.stdout),
                String::from_utf8_lossy(&out.stderr)
            ),
        });
    }
    if !image_out.exists() {
        return Err(BundleError::DumpProducedNoImage(image_out.to_path_buf()));
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    #[test]
    fn driver_needs_dylib_true_for_residual_driver() {
        let dir = TempDir::new().unwrap();
        let d = dir.path().join("dump.lisp");
        std::fs::write(&d, "(setf *native-dylib-path* x)\n(aw-load-native-dylib)\n").unwrap();
        assert!(driver_needs_dylib(&d));
    }

    #[test]
    fn driver_needs_dylib_false_for_pure_objc_driver() {
        let dir = TempDir::new().unwrap();
        let d = dir.path().join("dump.lisp");
        std::fs::write(
            &d,
            "(aw-app-load-framework \"AppKit\" :load-residual nil)\n",
        )
        .unwrap();
        assert!(!driver_needs_dylib(&d));
    }

    #[test]
    fn record_as_targets_the_frameworks_dir() {
        // The stub execs the image under Contents/Resources/, so @executable_path
        // resolves ../Frameworks to Contents/Frameworks — where the dylib is vendored.
        assert_eq!(
            DYLIB_RECORD_AS,
            "@executable_path/../Frameworks/libAPIAnywareSbcl.dylib"
        );
    }
}

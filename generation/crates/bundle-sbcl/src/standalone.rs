//! Assemble a self-contained sbcl `.app`: dump the image, lay out the bundle,
//! build the stub, vendor the dylibs, and sign (ADR-0041).
//!
//! ```text
//! <App>.app/
//!   Contents/
//!     MacOS/<script>           <- the Swift stub (CFBundleExecutable): sets
//!                                 DYLD_FALLBACK_LIBRARY_PATH, execv's the image
//!     Resources/<script>       <- the save-lisp-and-die :executable t image
//!                                 (embeds the SBCL runtime; keeps its own ad-hoc sig)
//!     Frameworks/
//!       libzstd.1.dylib        <- vendored; found by leaf name via DYLD_FALLBACK
//!       libAPIAnywareSbcl.dylib<- vendored (residual apps); reopened via @executable_path
//!     Info.plist               <- CFBundleName from spec H1, com.linkuistics.* id
//! ```

use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process::Command;

use apianyware_macos_stub_launcher::codesign_path;
use plist::Value as PlistValue;

use crate::dump::{driver_needs_dylib, dump_image, ensure_swift_dylib};
use crate::spec::{AppSpec, BundleError};
use crate::stub::build_stub;
use crate::vendor::vendor_dylibs;

/// The bundle subdirectory (under `Contents/`) vendored dylibs are copied into.
pub const FRAMEWORKS_SUBDIR: &str = "Frameworks";

/// Build a self-contained `.app` for the sbcl sample app at
/// `source_root/apps/<script_name>/dump.lisp` into `output_dir/<App Name>.app`,
/// using `workspace_root` to locate the Swift-native dylib. Returns the bundle
/// path.
///
/// The produced `.app` has **no Homebrew or SBCL dependency** on the target: the
/// SBCL runtime is embedded by `save-lisp-and-die`, libzstd is vendored +
/// resolved via the stub's `DYLD_FALLBACK_LIBRARY_PATH`, and `libAPIAnywareSbcl`
/// (residual apps) is vendored + reopened exe-relative. The Swift runtime is
/// OS-resident.
pub fn bundle_app(
    spec: &AppSpec,
    source_root: &Path,
    output_dir: &Path,
    workspace_root: &Path,
) -> Result<PathBuf, BundleError> {
    let abs_root = fs::canonicalize(source_root)
        .map_err(|e| BundleError::ResolveSourceRoot(source_root.to_path_buf(), e))?;
    let driver = abs_root
        .join("apps")
        .join(&spec.script_name)
        .join("dump.lisp");
    if !driver.exists() {
        return Err(BundleError::DumpDriverMissing { driver });
    }

    // Residual apps (Swift-native trampolines, or block/subclass bounce shim)
    // load libAPIAnywareSbcl; pure-ObjC apps (hello-window) do not.
    let needs_dylib = driver_needs_dylib(&driver);
    let swift_dylib = if needs_dylib {
        Some(ensure_swift_dylib(workspace_root)?)
    } else {
        None
    };
    if let Some(ref d) = swift_dylib {
        tracing::info!(dylib = %d.display(), "app loads libAPIAnywareSbcl (ADR-0038)");
    }

    // Lay out the bundle.
    let app_path = output_dir.join(format!("{}.app", spec.app_name));
    if app_path.exists() {
        fs::remove_dir_all(&app_path)?;
    }
    let contents = app_path.join("Contents");
    let macos = contents.join("MacOS");
    let resources = contents.join("Resources");
    let frameworks = contents.join(FRAMEWORKS_SUBDIR);
    fs::create_dir_all(&macos)?;
    fs::create_dir_all(&resources)?;
    fs::create_dir_all(&frameworks)?;

    // 1. Dump the image straight into Contents/Resources/<script>. dump.lisp
    //    declares the app's frameworks + run-loop toplevel; we only redirect the
    //    output and (residual apps) relocate the dylib namestring (ADR-0041).
    let image = resources.join(&spec.script_name);
    let sdkroot = macosx_sdk_path()?;
    dump_image(&driver, &image, swift_dylib.as_deref(), &sdkroot)?;
    make_executable(&image)?;

    // 2. The Swift stub becomes CFBundleExecutable.
    let stub = macos.join(&spec.script_name);
    build_stub(&spec.app_name, &spec.script_name, &stub)?;

    // 3. Vendor libzstd (+ the residual dylib) into Frameworks, each re-signed.
    let identity = spec.signing_identity.as_deref().unwrap_or("-");
    let vendored = vendor_dylibs(&image, &frameworks, swift_dylib.as_deref(), identity)?;

    // 4. Info.plist.
    write_info_plist(&contents.join("Info.plist"), spec)?;

    // 5. Sign the whole bundle last — signs the stub (main exe) and seals the
    //    Resources image + Frameworks dylibs by hash. The dumped image keeps its
    //    own save-lisp-and-die ad-hoc signature (never re-signed).
    codesign_path(&app_path, identity)?;

    tracing::info!(
        app = %spec.app_name,
        path = %app_path.display(),
        residual = needs_dylib,
        vendored = vendored.len(),
        "bundled standalone sbcl app"
    );
    Ok(app_path)
}

/// `xcrun --sdk macosx --show-sdk-path`, or `$SDKROOT` when already set.
fn macosx_sdk_path() -> Result<String, BundleError> {
    if let Ok(s) = std::env::var("SDKROOT") {
        if !s.is_empty() {
            return Ok(s);
        }
    }
    let out = Command::new("xcrun")
        .args(["--sdk", "macosx", "--show-sdk-path"])
        .output()
        .map_err(|source| BundleError::ToolNotAvailable {
            tool: "xcrun",
            source,
        })?;
    Ok(String::from_utf8_lossy(&out.stdout).trim().to_string())
}

fn make_executable(path: &Path) -> Result<(), BundleError> {
    let mut perms = fs::metadata(path)?.permissions();
    perms.set_mode(0o755);
    fs::set_permissions(path, perms)?;
    Ok(())
}

/// Write the bundle's `Info.plist`. `CFBundleExecutable` names the Swift stub
/// (the dumped image is a resource the stub execs, not the bundle executable).
fn write_info_plist(path: &Path, spec: &AppSpec) -> Result<(), BundleError> {
    let mut dict = plist::Dictionary::new();
    let mut set = |k: &str, v: &str| {
        dict.insert(k.to_string(), PlistValue::String(v.to_string()));
    };
    set("CFBundleName", &spec.app_name);
    set("CFBundleDisplayName", &spec.app_name);
    set("CFBundleIdentifier", &spec.bundle_id);
    set("CFBundleExecutable", &spec.script_name);
    set("CFBundlePackageType", "APPL");
    set("CFBundleVersion", "1.0");
    set("CFBundleShortVersionString", "1.0");
    set("NSPrincipalClass", "NSApplication");
    set("LSMinimumSystemVersion", "13.0");
    dict.insert(
        "NSHighResolutionCapable".to_string(),
        PlistValue::Boolean(true),
    );
    for (k, v) in &spec.info_plist_overrides {
        dict.insert(k.clone(), v.clone());
    }
    plist::to_file_xml(path, &PlistValue::Dictionary(dict))?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    #[test]
    fn info_plist_executable_is_the_stub_script_name() {
        let dir = TempDir::new().unwrap();
        let spec = AppSpec::from_script_name("hello-window");
        let path = dir.path().join("Info.plist");
        write_info_plist(&path, &spec).unwrap();

        let value = PlistValue::from_file(&path).unwrap();
        let d = value.as_dictionary().unwrap();
        assert_eq!(
            d.get("CFBundleName").unwrap().as_string(),
            Some("Hello Window")
        );
        assert_eq!(
            d.get("CFBundleExecutable").unwrap().as_string(),
            Some("hello-window")
        );
        assert_eq!(
            d.get("CFBundleIdentifier").unwrap().as_string(),
            Some("com.linkuistics.HelloWindow")
        );
        assert_eq!(
            d.get("NSPrincipalClass").unwrap().as_string(),
            Some("NSApplication")
        );
    }

    #[test]
    fn rejects_missing_driver() {
        let temp = TempDir::new().unwrap();
        fs::create_dir_all(temp.path().join("apps")).unwrap();
        let spec = AppSpec::from_script_name("definitely-not-an-app");
        let out = TempDir::new().unwrap();
        let err = bundle_app(&spec, temp.path(), out.path(), temp.path()).unwrap_err();
        assert!(
            matches!(err, BundleError::DumpDriverMissing { .. }),
            "expected DumpDriverMissing, got {err:?}"
        );
    }
}

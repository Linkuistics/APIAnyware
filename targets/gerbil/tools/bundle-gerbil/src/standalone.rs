//! Assemble a self-contained gerbil `.app`: compile the app exe, lay out the
//! bundle, vendor + relocate the Homebrew dylibs, and sign.
//!
//! The `gxc -exe` binary *is* the bundle executable (no Swift stub, like
//! chez) and already embeds the Gerbil/Gambit runtime, so assembly is just:
//! the binary at `Contents/MacOS/<script>`, an `Info.plist`, and the
//! relocated openssl dylibs under `Contents/Frameworks/` (ADR-0009; spec §7).

use std::fs;
use std::path::{Path, PathBuf};

use apianyware_stub_launcher::codesign_path;
use plist::Value as PlistValue;

use crate::bundle::{AppSpec, BundleError};
use crate::compile::{compile_app, discover_swift_dylib};
use crate::deps::collect_closure;
use crate::relocate::{relocate_homebrew_deps, relocate_swift_dylib, FRAMEWORKS_SUBDIR};

/// Build a self-contained `.app` for the gerbil sample app at
/// `source_root/apps/<script_name>/<script_name>.ss` into
/// `output_dir/<App Name>.app`. Returns the path to the new bundle.
///
/// The produced `.app` has **no Homebrew dylib dependency**: the
/// Gerbil/Gambit runtime is statically embedded by `gxc -exe`, and the
/// openssl@3 dylibs are vendored under `Contents/Frameworks/` and relocated
/// to `@executable_path`. The bottle gerbil toolchain is a **build-time**
/// dependency only.
pub fn bundle_app(
    spec: &AppSpec,
    source_root: &Path,
    output_dir: &Path,
) -> Result<PathBuf, BundleError> {
    let abs_root = fs::canonicalize(source_root)
        .map_err(|e| BundleError::ResolveSourceRoot(source_root.to_path_buf(), e))?;
    let lib_root = abs_root.join("lib");
    let entry = abs_root
        .join("apps")
        .join(&spec.script_name)
        .join(format!("{}.ss", spec.script_name));
    if !entry.exists() {
        return Err(BundleError::EntryMissing { entry });
    }

    // 1. Walk the binding-library compile closure (deps-first).
    let closure = collect_closure(&entry, &lib_root)?;

    // Locate the Swift-native trampoline dylib (ADR-0029). After the §18 move
    // (`move-gerbil-material-k13`) the bundler's source root is `targets/gerbil/`,
    // so the repo root is two levels above it; [`discover_swift_dylib`] then
    // descends to the per-target adapter package's `.build`. `None` when no
    // `swift build` artifact exists (an app with no Swift-native residual still
    // bundles; one that references the trampolines fails loudly at the gxc link).
    // TODO(w6, root brief item 6): the bundler still assumes apps/ + lib/ are
    // direct children of source_root (stitched via the test's gerbil_root()
    // fixture); teaching it the apps-root / bindings-root split natively will
    // settle this walk-up depth for good.
    let workspace_root = abs_root
        .ancestors()
        .nth(2)
        .map(Path::to_path_buf)
        .unwrap_or_else(|| abs_root.clone());
    let swift_dylib = discover_swift_dylib(&workspace_root);
    if let Some(ref d) = swift_dylib {
        tracing::info!(dylib = %d.display(), "linking Swift-native trampoline dylib (ADR-0029)");
    }

    // 2. Compile: clang companion + gxc -O closure into a persistent cache +
    //    gxc -exe -O link. Intermediates live in a scratch dir; the
    //    GERBIL_PATH cache persists under output_dir/ (gitignored) so it
    //    warms across rebuilds.
    let scratch = tempfile::tempdir()?;
    let cache_dir = output_dir.join("gerbil-cache");
    let exe = compile_app(
        &entry,
        &lib_root,
        &closure,
        scratch.path(),
        &cache_dir,
        swift_dylib.as_deref(),
    )?;

    // 3. Assemble the .app.
    fs::create_dir_all(output_dir)?;
    let app_path = output_dir.join(format!("{}.app", spec.app_name));
    if app_path.exists() {
        fs::remove_dir_all(&app_path)?;
    }
    let contents = app_path.join("Contents");
    let macos = contents.join("MacOS");
    let frameworks = contents.join(FRAMEWORKS_SUBDIR);
    fs::create_dir_all(&macos)?;
    fs::create_dir_all(&frameworks)?;

    let bundle_exe = macos.join(&spec.script_name);
    fs::copy(&exe, &bundle_exe)?;
    write_info_plist(&contents.join("Info.plist"), spec)?;

    // 4. Vendor + relocate the Homebrew dylibs (openssl@3). Signs each
    //    vendored dylib after rewriting its load commands.
    let identity = spec.signing_identity.as_deref().unwrap_or("-");
    let vendored = relocate_homebrew_deps(&bundle_exe, &frameworks, identity)?;

    // 4b. Vendor + relocate the Swift-native trampoline dylib (ADR-0029 §3) —
    //     the one *linked* (not dlopen'd) dylib. A no-op for an app whose exe
    //     records no `@rpath/libAPIAnywareGerbil.dylib` load command (no
    //     Swift-native residual), so it is safe to call unconditionally; when the
    //     dylib was not even built, `swift_dylib` is `None` and we skip entirely.
    let swift_vendored = match swift_dylib.as_deref() {
        Some(src) => relocate_swift_dylib(&bundle_exe, src, &frameworks, identity)?,
        None => None,
    };

    // 5. Sign the whole bundle last — covers the exe (whose load commands
    //    were rewritten) and Resources, with a stable CDHash.
    codesign_path(&app_path, identity)?;

    tracing::info!(
        app = %spec.app_name,
        path = %app_path.display(),
        closure = closure.len(),
        vendored = vendored.len(),
        swift_dylib = swift_vendored.is_some(),
        "bundled standalone gerbil app"
    );
    Ok(app_path)
}

/// Write the bundle's `Info.plist`. The native binary *is* the executable
/// (no Swift stub), so `CFBundleExecutable` names the `gxc -exe` output.
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
    set("LSMinimumSystemVersion", "13.0");
    dict.insert(
        "NSHighResolutionCapable".to_string(),
        PlistValue::Boolean(true),
    );
    // Caller overrides win.
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
    fn info_plist_has_expected_keys() {
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
            d.get("CFBundleIdentifier").unwrap().as_string(),
            Some("com.linkuistics.HelloWindow")
        );
        assert_eq!(
            d.get("CFBundleExecutable").unwrap().as_string(),
            Some("hello-window")
        );
        assert_eq!(
            d.get("CFBundlePackageType").unwrap().as_string(),
            Some("APPL")
        );
    }

    #[test]
    fn rejects_missing_app() {
        let temp = TempDir::new().unwrap();
        // A source root with a lib/ dir but no apps/<script>/<script>.ss.
        fs::create_dir_all(temp.path().join("lib")).unwrap();
        let spec = AppSpec::from_script_name("definitely-not-an-app");
        let out = TempDir::new().unwrap();
        let err = bundle_app(&spec, temp.path(), out.path()).unwrap_err();
        assert!(
            matches!(err, BundleError::EntryMissing { .. }),
            "expected EntryMissing, got {err:?}"
        );
    }
}

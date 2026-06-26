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

/// Build a self-contained `.app` for the gerbil sample app from the §18 domain
/// tree into `output_dir/<App Name>.app`. Returns the path to the new bundle.
///
/// The entry is `apps_root/<script_name>/<script_name>.ss`; the
/// `gerbil-bindings` package root (the closure's `runtime/` + emitted `<fw>/`
/// modules) is `bindings_root/generated`. Unlike racket/chez the gerbil bundle
/// never colocates a source tree — `collect_closure` already takes the entry
/// and the lib root separately, and the compiled closure goes into a
/// `GERBIL_PATH` cache under `output_dir`, so the split needs no virtual root.
///
/// The produced `.app` has **no Homebrew dylib dependency**: the
/// Gerbil/Gambit runtime is statically embedded by `gxc -exe`, and the
/// openssl@3 dylibs are vendored under `Contents/Frameworks/` and relocated
/// to `@executable_path`. The bottle gerbil toolchain is a **build-time**
/// dependency only.
pub fn bundle_app(
    spec: &AppSpec,
    apps_root: &Path,
    bindings_root: &Path,
    output_dir: &Path,
) -> Result<PathBuf, BundleError> {
    let apps_root = fs::canonicalize(apps_root)
        .map_err(|e| BundleError::ResolveSourceRoot(apps_root.to_path_buf(), e))?;
    let bindings_root = fs::canonicalize(bindings_root)
        .map_err(|e| BundleError::ResolveSourceRoot(bindings_root.to_path_buf(), e))?;
    let lib_root = bindings_root.join("generated");
    let entry = apps_root
        .join(&spec.script_name)
        .join(format!("{}.ss", spec.script_name));
    if !entry.exists() {
        return Err(BundleError::EntryMissing { entry });
    }

    // 1. Walk the binding-library compile closure (deps-first).
    let closure = collect_closure(&entry, &lib_root)?;

    // Locate the Swift-native trampoline dylib (ADR-0029). [`discover_swift_dylib`]
    // descends to the per-target adapter package's `.build` from the repo root,
    // which is the parent of the `targets/` ancestor of the bindings root. `None`
    // when no `swift build` artifact exists (an app with no Swift-native residual
    // still bundles; one that references the trampolines fails loudly at the gxc
    // link).
    let workspace_root = workspace_root_above_targets(&bindings_root);
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

/// The repo root above a `targets/<t>/…` path: the parent of the nearest
/// `targets` ancestor. Robust to how deep the bindings root sits (it is
/// `targets/gerbil/bindings/macos`), unlike a fixed `ancestors().nth(N)`.
/// Falls back to the input if no `targets` ancestor is found.
fn workspace_root_above_targets(under_targets: &Path) -> PathBuf {
    let mut p = under_targets;
    while let Some(parent) = p.parent() {
        if p.file_name().is_some_and(|n| n == "targets") {
            return parent.to_path_buf();
        }
        p = parent;
    }
    under_targets.to_path_buf()
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
        // An apps root with no <script>/<script>.ss, and a bindings root whose
        // generated/ package is empty — bundling fails at the entry precheck.
        let apps_root = temp.path().join("app-implementations");
        let bindings_root = temp.path().join("bindings");
        fs::create_dir_all(&apps_root).unwrap();
        fs::create_dir_all(bindings_root.join("generated")).unwrap();
        let spec = AppSpec::from_script_name("definitely-not-an-app");
        let out = TempDir::new().unwrap();
        let err = bundle_app(&spec, &apps_root, &bindings_root, out.path()).unwrap_err();
        assert!(
            matches!(err, BundleError::EntryMissing { .. }),
            "expected EntryMissing, got {err:?}"
        );
    }
}

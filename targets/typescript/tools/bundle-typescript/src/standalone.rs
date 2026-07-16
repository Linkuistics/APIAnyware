//! Assemble a self-contained Node TypeScript `.app`: compile the per-app
//! native launcher, lay out the JS tree + native addon, vendor + relocate the
//! Homebrew dylib closure, and sign inside-out (ADR-0060).
//!
//! Unlike the four Lisp targets' bundlers, this one does **not** compile the
//! app's TypeScript or the native addon itself — both are already-built
//! prerequisites checked up front (the app's own `build.sh`, and
//! `bindings/node/native/build.sh`; Step 8's own job is packaging + the native
//! launcher + relocation, not re-deriving Steps 2–4's build). See the leaf's
//! own "Context" section for the exact division of labour.

use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};

use apianyware_stub_launcher::codesign_path;
use plist::Value as PlistValue;

use crate::bundle::{AppSpec, BundleError};
use crate::launcher::{compile_launcher, discover_node_toolchain};
use crate::relocate::vendor_and_relocate_homebrew_deps;

/// The native addon's build product name (`bindings/node/native/build.sh`) —
/// kept verbatim (not renamed to a `lib*.dylib` form) so it is still a valid
/// `require()`-loadable native module: Node's module loader dispatches on the
/// `.node` extension specifically (`Module._extensions['.node']` →
/// `process.dlopen`), unlike an ordinary linked dylib found via `otool -L`.
const NATIVE_ADDON_NAME: &str = "APIAnywareTypeScript.node";

/// Build a self-contained `.app` for the Node TypeScript sample app at
/// `app_dir` into `output_dir/<App Name>.app`. Returns the path to the new
/// bundle.
///
/// `app_dir` is `targets/typescript/app-implementations/macos/<script_name>`
/// (must already carry a `build.sh`-produced `build/js/` tree and its own
/// `loader.mjs`); `native_dir` is `targets/typescript/bindings/node/native`
/// (must already carry a `build.sh`-produced `build/APIAnywareTypeScript.node`).
pub fn bundle_app(
    spec: &AppSpec,
    app_dir: &Path,
    native_dir: &Path,
    output_dir: &Path,
) -> Result<PathBuf, BundleError> {
    let app_js = app_dir
        .join("build/js/app-implementations/macos")
        .join(&spec.script_name)
        .join("app.js");
    if !app_js.exists() {
        return Err(BundleError::AppNotBuilt { app_js, script: spec.script_name.clone() });
    }
    let addon = native_dir.join("build").join(NATIVE_ADDON_NAME);
    if !addon.exists() {
        return Err(BundleError::AddonNotBuilt { addon });
    }
    let loader = app_dir.join("loader.mjs");
    if !loader.exists() {
        return Err(BundleError::LoaderMissing(loader));
    }

    // 1. Compile the per-app native launcher (build-time libnode/libuv from
    //    this host's node — the pinned matched pair ADR-0060 §2 requires).
    let toolchain = discover_node_toolchain()?;
    let scratch = tempfile::tempdir()?;
    let exe_scratch = scratch.path().join(&spec.script_name);
    compile_launcher(spec, native_dir, &toolchain, scratch.path(), &exe_scratch)?;

    // 2. Lay out the bundle skeleton.
    fs::create_dir_all(output_dir)?;
    let app_path = output_dir.join(format!("{}.app", spec.app_name));
    if app_path.exists() {
        fs::remove_dir_all(&app_path)?;
    }
    let contents = app_path.join("Contents");
    let macos = contents.join("MacOS");
    let frameworks = contents.join("Frameworks");
    let resources_app = contents.join("Resources").join("app");
    fs::create_dir_all(&macos)?;
    fs::create_dir_all(&frameworks)?;
    fs::create_dir_all(&resources_app)?;

    let bundle_exe = macos.join(&spec.script_name);
    fs::copy(&exe_scratch, &bundle_exe)?;
    let mut perms = fs::metadata(&bundle_exe)?.permissions();
    perms.set_mode(0o755);
    fs::set_permissions(&bundle_exe, perms)?;

    // 3. JS ships as a loose tree, no bundler (ADR-0060 §4): copy the app's
    //    already-compiled build/js/ output + loader.mjs verbatim (both resolve
    //    paths relative to their own directory, so they need no rewriting),
    //    and generate a bootstrap.cjs that requires the addon from its
    //    Frameworks/ home instead of the dev tree's bindings/node/native/build/.
    copy_dir_recursive(&app_dir.join("build/js"), &resources_app.join("build/js"))?;
    fs::copy(&loader, resources_app.join("loader.mjs"))?;
    fs::write(resources_app.join("bootstrap.cjs"), generate_bootstrap_cjs(&spec.script_name))?;

    // 4. Vendor + relocate libnode's Homebrew closure onto the launcher.
    let identity = spec.signing_identity.as_deref().unwrap_or("-");
    let vendored = vendor_and_relocate_homebrew_deps(&bundle_exe, &frameworks, identity)?;

    // 5. The native addon's N-API symbols resolve at dlopen against whatever
    //    process loaded it (`-undefined dynamic_lookup`) and its only other
    //    deps are system frameworks + OS-resident Swift dylibs (confirmed via
    //    otool -L, no Homebrew reference at all) — vendor as a plain copy, no
    //    relocation needed.
    let bundled_addon = frameworks.join(NATIVE_ADDON_NAME);
    fs::copy(&addon, &bundled_addon)?;
    codesign_path(&bundled_addon, identity)?;

    write_info_plist(&contents.join("Info.plist"), spec)?;

    // 6. Sign the whole bundle last — covers the exe (whose load commands
    //    were rewritten in step 4) and Resources, with a stable CDHash.
    codesign_path(&app_path, identity)?;

    tracing::info!(
        app = %spec.app_name,
        path = %app_path.display(),
        vendored = vendored.len(),
        "bundled Node TypeScript app"
    );
    Ok(app_path)
}

/// Generate the shipped `bootstrap.cjs` for `script_name`: identical
/// three-step shape to every sample app's own hand-authored `bootstrap.cjs`
/// (register the loader, install the native dispatch backend, THEN import the
/// app) — only the addon's require() path differs (`../../Frameworks/` rather
/// than the dev tree's `../../../bindings/node/native/build/`).
fn generate_bootstrap_cjs(script_name: &str) -> String {
    BOOTSTRAP_TEMPLATE.replace("__SCRIPT_NAME__", script_name).replace("__ADDON_NAME__", NATIVE_ADDON_NAME)
}

const BOOTSTRAP_TEMPLATE: &str = r#"// Generated by apianyware-bundle-typescript (ADR-0060) — do not hand-edit; see standalone.rs.
'use strict';

const { register } = require('node:module');
const path = require('node:path');
const { pathToFileURL } = require('node:url');

const HERE = __dirname;

register(pathToFileURL(path.join(HERE, 'loader.mjs')).href);

(async () => {
  const addonPath = path.join(HERE, '..', '..', 'Frameworks', '__ADDON_NAME__');
  const runtime = await import(
    pathToFileURL(path.join(HERE, 'build', 'js', 'bindings', 'node', 'runtime', 'src', 'index.js')).href,
  );
  const addon = require(addonPath);
  runtime.__installDispatch(addon);

  await import(
    pathToFileURL(
      path.join(HERE, 'build', 'js', 'app-implementations', 'macos', '__SCRIPT_NAME__', 'app.js'),
    ).href,
  );
})().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
"#;

/// Write the bundle's `Info.plist`. The native launcher *is* the executable
/// (no Swift stub), so `CFBundleExecutable` names it.
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
    // ADR-0060 §2: the Swift runtime stays OS-resident (macOS >= 12).
    set("LSMinimumSystemVersion", "12.0");
    dict.insert("NSHighResolutionCapable".to_string(), PlistValue::Boolean(true));
    // Caller overrides win.
    for (k, v) in &spec.info_plist_overrides {
        dict.insert(k.clone(), v.clone());
    }
    plist::to_file_xml(path, &PlistValue::Dictionary(dict))?;
    Ok(())
}

/// Recursively copy `src` into `dst`, creating directories as needed.
fn copy_dir_recursive(src: &Path, dst: &Path) -> std::io::Result<()> {
    fs::create_dir_all(dst)?;
    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let from = entry.path();
        let to = dst.join(entry.file_name());
        if entry.file_type()?.is_dir() {
            copy_dir_recursive(&from, &to)?;
        } else {
            fs::copy(&from, &to)?;
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn info_plist_has_expected_keys() {
        let dir = tempfile::TempDir::new().unwrap();
        let spec = AppSpec::from_script_name("hello-window");
        let path = dir.path().join("Info.plist");
        write_info_plist(&path, &spec).unwrap();

        let value = PlistValue::from_file(&path).unwrap();
        let d = value.as_dictionary().unwrap();
        assert_eq!(d.get("CFBundleName").unwrap().as_string(), Some("Hello Window"));
        assert_eq!(d.get("CFBundleIdentifier").unwrap().as_string(), Some("com.linkuistics.HelloWindow"));
        assert_eq!(d.get("CFBundleExecutable").unwrap().as_string(), Some("hello-window"));
        assert_eq!(d.get("CFBundlePackageType").unwrap().as_string(), Some("APPL"));
    }

    #[test]
    fn bootstrap_cjs_points_at_frameworks_addon_and_this_apps_entry() {
        let src = generate_bootstrap_cjs("hello-window");
        assert!(src.contains("path.join(HERE, '..', '..', 'Frameworks', 'APIAnywareTypeScript.node')"));
        assert!(src.contains(
            "path.join(HERE, 'build', 'js', 'app-implementations', 'macos', 'hello-window', 'app.js')"
        ));
        assert!(src.contains("register(pathToFileURL(path.join(HERE, 'loader.mjs')).href);"));
    }

    #[test]
    fn copy_dir_recursive_mirrors_nested_tree() {
        let dir = tempfile::TempDir::new().unwrap();
        let src = dir.path().join("src");
        let dst = dir.path().join("dst");
        fs::create_dir_all(src.join("a/b")).unwrap();
        fs::write(src.join("top.js"), "top").unwrap();
        fs::write(src.join("a/b/leaf.js"), "leaf").unwrap();

        copy_dir_recursive(&src, &dst).unwrap();

        assert_eq!(fs::read_to_string(dst.join("top.js")).unwrap(), "top");
        assert_eq!(fs::read_to_string(dst.join("a/b/leaf.js")).unwrap(), "leaf");
    }

    #[test]
    fn rejects_unbuilt_app() {
        let dir = tempfile::TempDir::new().unwrap();
        let app_dir = dir.path().join("app-implementations/macos/hello-window");
        let native_dir = dir.path().join("bindings/node/native");
        fs::create_dir_all(&app_dir).unwrap();
        let spec = AppSpec::from_script_name("hello-window");
        let out = tempfile::TempDir::new().unwrap();
        let err = bundle_app(&spec, &app_dir, &native_dir, out.path()).unwrap_err();
        assert!(matches!(err, BundleError::AppNotBuilt { .. }), "expected AppNotBuilt, got {err:?}");
    }
}

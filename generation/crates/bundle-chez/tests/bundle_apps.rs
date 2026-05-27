//! Integration tests: bundle real or minimal chez projects and verify
//! the resulting `.app` is structurally complete.
//!
//! Skipped if `swiftc` or `chez` isn't available (stub-launcher needs
//! swiftc; the deps walker needs chez). Also skipped if the chez target
//! source tree isn't present — keeps the workspace test run clean on
//! stripped checkouts.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use apianyware_macos_bundle_chez::{
    bundle_app, bundle_app_with_entry, read_display_name_from_spec, AppSpec, BundleError,
};

fn workspace_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .ancestors()
        .nth(3)
        .expect("workspace root above bundle-chez crate")
        .to_path_buf()
}

fn chez_root() -> PathBuf {
    workspace_root().join("generation").join("targets").join("chez")
}

fn knowledge_apps_dir() -> PathBuf {
    workspace_root().join("knowledge").join("apps")
}

fn swiftc_available() -> bool {
    Command::new("swiftc")
        .arg("--version")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

fn chez_available() -> bool {
    Command::new("chez")
        .arg("--version")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

fn chez_runtime_present() -> bool {
    chez_root()
        .join("apianyware")
        .join("runtime")
        .join("ffi.sls")
        .is_file()
}

fn chez_dylib_present() -> bool {
    chez_root().join("lib").join("libAPIAnywareChez.dylib").exists()
}

fn discover_app_scripts() -> Vec<String> {
    let apps = chez_root().join("apps");
    let mut scripts: Vec<String> = Vec::new();
    let Ok(entries) = fs::read_dir(&apps) else {
        return scripts;
    };
    for e in entries.flatten() {
        if !e.file_type().map(|t| t.is_dir()).unwrap_or(false) {
            continue;
        }
        let name = e.file_name().to_string_lossy().into_owned();
        if e.path().join(format!("{name}.sls")).is_file() {
            scripts.push(name);
        }
    }
    scripts.sort();
    scripts
}

/// Build a minimal chez project tree that symlinks the real chez target
/// into `bindings/` and `lib/`, plus a root-level `main.sls` entry
/// importing one known framework class. Same pattern as bundle-racket's
/// `minimal_project`. Returns the entry path and a default AppSpec.
fn minimal_project(project_root: &Path, display: &str, entry_import: &str) -> (PathBuf, AppSpec) {
    // bindings/ stands in for the real chez source tree — runtime,
    // generated/, etc all reachable from here.
    std::os::unix::fs::symlink(chez_root(), project_root.join("bindings"))
        .expect("symlink bindings/ into chez root");
    // lib/ needs to exist and contain libAPIAnywareChez.dylib — the
    // bundle's mandatory-dylib precheck looks here.
    std::os::unix::fs::symlink(chez_root().join("lib"), project_root.join("lib"))
        .expect("symlink lib/ into chez root lib/");

    fs::write(
        project_root.join("main.sls"),
        format!("(import {entry_import})\n(display 'ok)\n"),
    )
    .expect("write main.sls");

    let mut spec = AppSpec::from_script_name("main");
    spec.app_name = display.to_string();
    spec.bundle_id = format!("com.linkuistics.{}", display.replace(' ', ""));
    (project_root.join("main.sls"), spec)
}

#[test]
fn bundles_minimal_chez_project_into_app_directory() {
    if !swiftc_available() || !chez_available() {
        eprintln!("SKIPPED: swiftc or chez not available");
        return;
    }
    if !chez_runtime_present() || !chez_dylib_present() {
        eprintln!("SKIPPED: chez runtime tree or dylib not present");
        return;
    }

    let project = tempfile::tempdir().expect("project tempdir");
    let (entry, spec) = minimal_project(
        project.path(),
        "Minimal Chez",
        "(bindings/apianyware runtime objc)",
    );
    // Use logical import path that the registry recognises — main.sls
    // is a script, so import works the same as in a library body.
    fs::write(
        &entry,
        "(import (apianyware runtime objc))\n(display 'ok)\n",
    )
    .unwrap();

    let out = tempfile::tempdir().expect("out tempdir");
    let app_path =
        bundle_app_with_entry(&spec, &entry, project.path(), out.path()).expect("bundle");

    // Bundle skeleton from stub-launcher
    assert!(app_path.ends_with("Minimal Chez.app"), "{app_path:?}");
    let contents = app_path.join("Contents");
    assert!(contents.join("Info.plist").is_file());
    assert!(contents.join("MacOS").join("Minimal Chez").is_file());

    // Resource layout — entry at top of chez-app/ (root-level main).
    let chez_app = contents.join("Resources").join("chez-app");
    assert!(
        chez_app.join("main.sls").is_file(),
        "entry not at chez-app/main.sls"
    );

    // Bindings landed at the logical in-tree location as real copies,
    // not as a symlink to the chez source tree.
    let bindings = chez_app.join("bindings");
    assert!(
        !bindings.is_symlink(),
        "bindings/ must be a real directory, not a symlink — bundle is not distributable otherwise"
    );
    let runtime_objc = bindings
        .join("apianyware")
        .join("runtime")
        .join("objc.sls");
    assert!(
        runtime_objc.is_file() && !runtime_objc.is_symlink(),
        "bindings/apianyware/runtime/objc.sls must be a regular file"
    );

    // ffi.sls is a transitive dep of objc.sls — should also have been
    // pulled in by the registry walk.
    assert!(
        bindings
            .join("apianyware")
            .join("runtime")
            .join("ffi.sls")
            .is_file(),
        "transitive dep apianyware/runtime/ffi.sls missing — registry walk did not follow imports"
    );

    // Mandatory dylib landed in the bundle.
    assert!(
        chez_app.join("lib").join("libAPIAnywareChez.dylib").exists(),
        "libAPIAnywareChez.dylib missing — mandatory-dylib invariant broken"
    );

    // Info.plist carries the derived bundle metadata.
    let plist = std::fs::read_to_string(contents.join("Info.plist")).unwrap();
    assert!(plist.contains("<string>Minimal Chez</string>"));
    assert!(plist.contains("<string>com.linkuistics.MinimalChez</string>"));
}

#[test]
fn rejects_missing_dylib() {
    if !chez_available() {
        eprintln!("SKIPPED: chez not available");
        return;
    }
    let project = tempfile::tempdir().expect("project tempdir");
    // No lib/ — just an entry. Bundle must fail with DylibMissing.
    fs::write(project.path().join("main.sls"), "(import (chezscheme))\n").unwrap();

    let spec = AppSpec::from_script_name("main");
    let out = tempfile::tempdir().expect("out tempdir");
    let err = bundle_app_with_entry(&spec, &project.path().join("main.sls"), project.path(), out.path())
        .unwrap_err();
    match err {
        BundleError::DylibMissing { .. } => {}
        other => panic!("expected DylibMissing, got {other:?}"),
    }
    // No partial bundle left behind (precheck runs before output is touched).
    assert!(
        fs::read_dir(out.path()).unwrap().next().is_none(),
        "output dir should be empty when bundle fails at precheck"
    );
}

#[test]
fn rejects_missing_app() {
    if !swiftc_available() || !chez_available() {
        eprintln!("SKIPPED: swiftc or chez not available");
        return;
    }
    if !chez_runtime_present() || !chez_dylib_present() {
        eprintln!("SKIPPED: chez runtime tree or dylib not present");
        return;
    }
    let temp = tempfile::tempdir().expect("tempdir");
    let spec = AppSpec::from_script_name("definitely-not-an-app");
    let err = bundle_app(&spec, &chez_root(), temp.path()).unwrap_err();
    assert!(
        matches!(err, BundleError::EntryMissing { .. }),
        "expected EntryMissing, got {err:?}"
    );
}

/// Bundles every sample app under `apps/`. Today the chez tree has no
/// apps (they land in grove leaves 100+); this test discovers zero and
/// skips harmlessly. Once apps appear, coverage lights up automatically
/// without test edits.
#[test]
fn bundles_every_sample_app() {
    if !swiftc_available() || !chez_available() {
        eprintln!("SKIPPED: swiftc or chez not available");
        return;
    }
    if !chez_dylib_present() {
        eprintln!("SKIPPED: chez dylib not present");
        return;
    }
    let scripts = discover_app_scripts();
    if scripts.is_empty() {
        eprintln!("SKIPPED: no chez sample apps yet (expected before grove leaves 100+)");
        return;
    }

    for script in &scripts {
        let temp = tempfile::tempdir().expect("tempdir");

        let mut spec = AppSpec::from_script_name(script);
        let spec_md = knowledge_apps_dir().join(script).join("spec.md");
        if let Some(display) = read_display_name_from_spec(&spec_md) {
            spec.bundle_id = format!("com.linkuistics.{}", display.replace(' ', ""));
            spec.app_name = display;
        }

        let app_path = bundle_app(&spec, &chez_root(), temp.path())
            .unwrap_or_else(|e| panic!("bundle {script}: {e}"));

        let contents = app_path.join("Contents");
        let plist = fs::read_to_string(contents.join("Info.plist"))
            .unwrap_or_else(|e| panic!("read Info.plist for {script}: {e}"));
        assert!(
            plist.contains(&format!("<string>{}</string>", spec.app_name)),
            "{script}: CFBundleName missing from Info.plist"
        );

        let chez_app = contents.join("Resources").join("chez-app");
        let entry = chez_app
            .join("apps")
            .join(script)
            .join(format!("{script}.sls"));
        assert!(entry.is_file(), "{script}: entry script missing");
        assert!(
            chez_app.join("lib").join("libAPIAnywareChez.dylib").exists(),
            "{script}: mandatory dylib missing"
        );
    }
}

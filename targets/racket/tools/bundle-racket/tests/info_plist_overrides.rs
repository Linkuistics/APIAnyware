//! Integration tests for the Info.plist customization API.
//!
//! Apps that need Accessibility, Screen Recording, or other macOS
//! entitlements must declare them via Info.plist keys the base template
//! does not provide (`LSUIElement`, `NSAccessibilityUsageDescription`,
//! `NSScreenCaptureUsageDescription`, etc.). Callers supply these through
//! `AppSpec::info_plist_overrides` and the bundler merges them into the
//! generated plist.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use apianyware_bundle_racket::{bundle_app_with_entry, AppSpec};
use plist::Value;

fn workspace_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .ancestors()
        .nth(4)
        .expect("workspace root above bundle-racket crate")
        .to_path_buf()
}

fn bindings_root() -> PathBuf {
    workspace_root()
        .join("targets")
        .join("racket")
        .join("bindings")
        .join("macos")
}

fn swiftc_available() -> bool {
    Command::new("swiftc")
        .arg("--version")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

fn racket_source_present() -> bool {
    bindings_root()
        .join("runtime")
        .join("objc-base.rkt")
        .is_file()
}

/// Build a minimal project tree with a root-level `main.rkt` that pulls
/// in one runtime file via a symlinked `bindings/` directory — the
/// smallest tree that exercises the full bundle pipeline without
/// depending on the sample-app layout. Returns the entry path and a
/// default `AppSpec` keyed to the given display name.
fn minimal_project(project_root: &Path, display: &str) -> (PathBuf, AppSpec) {
    std::os::unix::fs::symlink(bindings_root(), project_root.join("bindings"))
        .expect("symlink bindings/ into racket root");
    fs::write(
        project_root.join("main.rkt"),
        "#lang racket/base\n(require \"bindings/runtime/objc-base.rkt\")\n",
    )
    .expect("write main.rkt");

    let mut spec = AppSpec::from_script_name("main");
    spec.app_name = display.to_string();
    spec.bundle_id = format!("com.linkuistics.{}", display.replace(' ', ""));
    (project_root.join("main.rkt"), spec)
}

fn parse_bundle_plist(app_path: &Path) -> plist::Dictionary {
    let plist_path = app_path.join("Contents").join("Info.plist");
    let value: Value = plist::from_file(&plist_path).expect("parse Info.plist");
    value
        .into_dictionary()
        .expect("Info.plist top level must be a dictionary")
}

#[test]
fn default_app_spec_has_empty_info_plist_overrides() {
    let spec = AppSpec::from_script_name("modaliser");
    assert!(
        spec.info_plist_overrides.is_empty(),
        "fresh AppSpec must have no overrides"
    );
}

/// Callers add an entitlement key the base template does not emit. The
/// key must land in the bundle's Info.plist with the supplied value.
#[test]
fn info_plist_override_injects_new_key() {
    if !swiftc_available() {
        eprintln!("SKIPPED: swiftc not available");
        return;
    }
    if !racket_source_present() {
        eprintln!("SKIPPED: racket source not present");
        return;
    }

    let project = tempfile::tempdir().expect("project tempdir");
    let (entry, mut spec) = minimal_project(project.path(), "LSUIElement Test");
    spec.info_plist_overrides
        .insert("LSUIElement".to_string(), Value::Boolean(true));

    let out = tempfile::tempdir().expect("out tempdir");
    let app_path =
        bundle_app_with_entry(&spec, &entry, project.path(), out.path()).expect("bundle");

    let dict = parse_bundle_plist(&app_path);
    assert_eq!(
        dict.get("LSUIElement").and_then(Value::as_boolean),
        Some(true),
        "LSUIElement key not injected into Info.plist"
    );
    // Base template keys must still be present alongside overrides.
    assert_eq!(
        dict.get("CFBundleName").and_then(Value::as_string),
        Some("LSUIElement Test"),
        "base template CFBundleName lost during merge"
    );
    assert_eq!(
        dict.get("CFBundleIdentifier").and_then(Value::as_string),
        Some("com.linkuistics.LSUIElementTest")
    );
}

/// Overrides win over base-template keys of the same name. This gives
/// callers a single well-defined precedence rule: whatever they put in
/// `info_plist_overrides` is what ends up in the plist.
#[test]
fn info_plist_override_replaces_base_template_key() {
    if !swiftc_available() {
        eprintln!("SKIPPED: swiftc not available");
        return;
    }
    if !racket_source_present() {
        eprintln!("SKIPPED: racket source not present");
        return;
    }

    let project = tempfile::tempdir().expect("project tempdir");
    let (entry, mut spec) = minimal_project(project.path(), "Version Override");
    spec.info_plist_overrides
        .insert("CFBundleVersion".to_string(), Value::String("2.5".into()));
    spec.info_plist_overrides.insert(
        "LSMinimumSystemVersion".to_string(),
        Value::String("15.0".into()),
    );

    let out = tempfile::tempdir().expect("out tempdir");
    let app_path =
        bundle_app_with_entry(&spec, &entry, project.path(), out.path()).expect("bundle");

    let dict = parse_bundle_plist(&app_path);
    assert_eq!(
        dict.get("CFBundleVersion").and_then(Value::as_string),
        Some("2.5"),
        "override did not replace the base template CFBundleVersion"
    );
    assert_eq!(
        dict.get("LSMinimumSystemVersion")
            .and_then(Value::as_string),
        Some("15.0"),
    );
}

/// An app needing accessibility permissions needs three plist keys. All
/// should land in the bundle plist together.
#[test]
fn info_plist_accepts_multiple_override_keys() {
    if !swiftc_available() {
        eprintln!("SKIPPED: swiftc not available");
        return;
    }
    if !racket_source_present() {
        eprintln!("SKIPPED: racket source not present");
        return;
    }

    let project = tempfile::tempdir().expect("project tempdir");
    let (entry, mut spec) = minimal_project(project.path(), "Accessibility Bundle");
    spec.info_plist_overrides
        .insert("LSUIElement".to_string(), Value::Boolean(true));
    spec.info_plist_overrides.insert(
        "NSAccessibilityUsageDescription".to_string(),
        Value::String("This app needs accessibility access.".into()),
    );
    spec.info_plist_overrides.insert(
        "NSScreenCaptureUsageDescription".to_string(),
        Value::String("This app records the screen.".into()),
    );

    let out = tempfile::tempdir().expect("out tempdir");
    let app_path =
        bundle_app_with_entry(&spec, &entry, project.path(), out.path()).expect("bundle");

    let dict = parse_bundle_plist(&app_path);
    assert_eq!(
        dict.get("LSUIElement").and_then(Value::as_boolean),
        Some(true)
    );
    assert_eq!(
        dict.get("NSAccessibilityUsageDescription")
            .and_then(Value::as_string),
        Some("This app needs accessibility access.")
    );
    assert_eq!(
        dict.get("NSScreenCaptureUsageDescription")
            .and_then(Value::as_string),
        Some("This app records the screen.")
    );
}

/// When no overrides are supplied, the plist is byte-identical to the
/// stub-launcher base template — the merge step must be a no-op for the
/// common case.
#[test]
fn info_plist_empty_overrides_preserves_base_template() {
    if !swiftc_available() {
        eprintln!("SKIPPED: swiftc not available");
        return;
    }
    if !racket_source_present() {
        eprintln!("SKIPPED: racket source not present");
        return;
    }

    let project = tempfile::tempdir().expect("project tempdir");
    let (entry, spec) = minimal_project(project.path(), "No Overrides");
    assert!(spec.info_plist_overrides.is_empty());

    let out = tempfile::tempdir().expect("out tempdir");
    let app_path =
        bundle_app_with_entry(&spec, &entry, project.path(), out.path()).expect("bundle");

    let plist_text =
        fs::read_to_string(app_path.join("Contents").join("Info.plist")).expect("read Info.plist");
    // Byte-level check: the base template is a human-readable XML doc
    // with a DOCTYPE line; the plist crate's writer would strip or
    // reformat it. If overrides are empty, we must not touch the file.
    assert!(
        plist_text.contains("<!DOCTYPE plist PUBLIC"),
        "empty-overrides path must not re-serialize the base template"
    );
}

/// Overrides support non-string values too — arrays and nested dicts
/// are standard plist shapes (e.g. `CFBundleURLTypes`).
#[test]
fn info_plist_override_accepts_array_and_dict_values() {
    if !swiftc_available() {
        eprintln!("SKIPPED: swiftc not available");
        return;
    }
    if !racket_source_present() {
        eprintln!("SKIPPED: racket source not present");
        return;
    }

    let project = tempfile::tempdir().expect("project tempdir");
    let (entry, mut spec) = minimal_project(project.path(), "URL Types");

    let mut url_type = plist::Dictionary::new();
    url_type.insert(
        "CFBundleURLName".to_string(),
        Value::String("com.linkuistics.urltype".into()),
    );
    url_type.insert(
        "CFBundleURLSchemes".to_string(),
        Value::Array(vec![Value::String("myapp".into())]),
    );
    spec.info_plist_overrides.insert(
        "CFBundleURLTypes".to_string(),
        Value::Array(vec![Value::Dictionary(url_type)]),
    );

    let out = tempfile::tempdir().expect("out tempdir");
    let app_path =
        bundle_app_with_entry(&spec, &entry, project.path(), out.path()).expect("bundle");

    let dict = parse_bundle_plist(&app_path);
    let url_types = dict
        .get("CFBundleURLTypes")
        .and_then(Value::as_array)
        .expect("CFBundleURLTypes missing");
    assert_eq!(url_types.len(), 1);
    let first = url_types[0]
        .as_dictionary()
        .expect("URL type entry is dict");
    assert_eq!(
        first.get("CFBundleURLName").and_then(Value::as_string),
        Some("com.linkuistics.urltype")
    );
    let schemes = first
        .get("CFBundleURLSchemes")
        .and_then(Value::as_array)
        .expect("schemes array");
    assert_eq!(schemes.len(), 1);
    assert_eq!(schemes[0].as_string(), Some("myapp"));
}

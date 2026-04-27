//! Integration test: `AppSpec::signing_identity` reaches `codesign`.
//!
//! The identity is threaded through to stub-launcher's `StubConfig` and
//! also used to re-sign the fully populated bundle at the end of
//! `bundle_app_with_entry`, so that the signature covers Resources/ and
//! any bundled dylib in addition to the stub binary.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use apianyware_macos_bundle_racket_oo::{bundle_app_with_entry, AppSpec};

fn workspace_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .ancestors()
        .nth(3)
        .expect("workspace root above bundle-racket-oo crate")
        .to_path_buf()
}

fn racket_oo_root() -> PathBuf {
    workspace_root()
        .join("generation")
        .join("targets")
        .join("racket-oo")
}

fn swiftc_available() -> bool {
    Command::new("swiftc")
        .arg("--version")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

fn codesign_available() -> bool {
    Command::new("codesign")
        .arg("-h")
        .output()
        .map(|o| o.status.code().is_some())
        .unwrap_or(false)
}

fn racket_oo_source_present() -> bool {
    racket_oo_root()
        .join("runtime")
        .join("objc-base.rkt")
        .is_file()
}

fn minimal_project(project_root: &Path, display: &str) -> (PathBuf, AppSpec) {
    std::os::unix::fs::symlink(racket_oo_root(), project_root.join("bindings"))
        .expect("symlink bindings/");
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

#[test]
fn default_app_spec_has_no_signing_identity() {
    let spec = AppSpec::from_script_name("modaliser");
    assert!(spec.signing_identity.is_none());
}

#[test]
fn signing_identity_propagates_to_bundle_codesign() {
    if !swiftc_available() || !codesign_available() {
        eprintln!("SKIPPED: swiftc or codesign unavailable");
        return;
    }
    if !racket_oo_source_present() {
        eprintln!("SKIPPED: racket-oo source not present");
        return;
    }

    let project = tempfile::tempdir().expect("project tempdir");
    let (entry, mut spec) = minimal_project(project.path(), "Signed Bundle");
    spec.signing_identity = Some("-".to_string());

    let out = tempfile::tempdir().expect("out tempdir");
    let app_path =
        bundle_app_with_entry(&spec, &entry, project.path(), out.path()).expect("bundle");

    // `codesign --verify` checks the bundle signature is internally
    // consistent (binary + Resources). A bundle where the binary was
    // signed but Resources were added afterwards would fail this
    // check — so passing it proves the final re-sign actually ran.
    let verify = Command::new("codesign")
        .arg("--verify")
        .arg("--verbose=2")
        .arg(&app_path)
        .output()
        .expect("run codesign --verify");

    assert!(
        verify.status.success(),
        "bundle signature must verify after signing_identity is set; stderr:\n{}",
        String::from_utf8_lossy(&verify.stderr)
    );
}

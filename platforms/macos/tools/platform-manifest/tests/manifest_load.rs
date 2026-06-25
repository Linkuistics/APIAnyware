//! The committed `platforms/macos/platform.apiw` loads, validates, and carries the
//! expected policy (the `platform-manifest-k33` done-bar).
//!
//! This is the standing guard that the authored manifest conforms to
//! `platform.kdl-schema` AND passes the semantic checks, and that its `ignore`
//! policy stays in lockstep with the extractor's `IGNORED_FRAMEWORKS` const — the
//! manifest-vs-extractor anti-drift gate. If the manifest drifts or the extractor
//! ignore-list changes without the manifest following, this test catches it.

use std::collections::BTreeSet;
use std::path::PathBuf;

use apianyware_platform_manifest::{DiscoverSource, PlatformManifest};

/// The committed manifest path, resolved from this crate's manifest dir
/// (`platforms/macos/tools/platform-manifest/`) up to `platforms/macos/`.
fn manifest_path() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../platform.apiw")
        .canonicalize()
        .expect("platforms/macos/platform.apiw resolves")
}

fn load() -> PlatformManifest {
    apianyware_platform_manifest::load(&manifest_path()).expect("platform.apiw loads + validates")
}

#[test]
fn committed_manifest_loads_and_carries_expected_policy() {
    let m = load();
    assert_eq!(m.name, "macos", "manifest names the macos platform");
    assert_eq!(m.sdk, "macosx", "SDK name is the xcrun `macosx` SDK");
    assert_eq!(
        m.deployment_target, "14.0",
        "source-availability floor matches the digester target (macos14.0)"
    );
    assert!(
        m.frameworks
            .discover
            .contains(&DiscoverSource::SdkUmbrellaHeaders),
        "discovery scans SDK umbrella-header frameworks"
    );
    assert!(
        m.frameworks
            .discover
            .contains(&DiscoverSource::SyntheticFrameworks),
        "discovery includes the synthetic-framework overlay"
    );
    assert!(
        m.frameworks
            .subframework_allow
            .iter()
            .any(|s| s == "ApplicationServices"),
        "the ApplicationServices subframework allowance is carried"
    );
    assert!(
        m.frameworks
            .ignore
            .iter()
            .all(|ig| !ig.reason.trim().is_empty()),
        "every ignore carries a non-empty reason (no silent caps)"
    );
}

#[test]
fn ignore_policy_matches_the_extractor_ignored_frameworks() {
    let m = load();
    let manifest_ignored: BTreeSet<&str> = m
        .frameworks
        .ignore
        .iter()
        .map(|ig| ig.name.as_str())
        .collect();
    let extractor_ignored: BTreeSet<&str> = apianyware_extract_objc::sdk::IGNORED_FRAMEWORKS
        .iter()
        .copied()
        .collect();
    assert_eq!(
        manifest_ignored, extractor_ignored,
        "platform.apiw `ignore` policy must equal extract-objc's IGNORED_FRAMEWORKS \
         (manifest-vs-extractor anti-drift): update both together"
    );
}

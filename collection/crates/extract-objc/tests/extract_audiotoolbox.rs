//! Integration test: extract AudioToolbox framework and lock in real-SDK
//! filter canaries.
//!
//! AudioToolbox is a C-heavy framework whose declaration shapes sit outside
//! the Foundation/AppKit comfort zone of most of the other extraction tests.
//! Every extraction-filter leak landed in this project so far was first
//! surfaced by a runtime `get-ffi-obj` / `dlsym` failure in a downstream
//! language target rather than by `cargo test`. This test closes part of
//! that meta-gap by asserting specific named symbols against real SDK
//! extraction:
//!
//! - **Negative canary** — `kAudioServicesDetailIntendedSpatialExperience`
//!   is declared in `AudioServices.h` as
//!   `extern const CFStringRef … API_AVAILABLE(visionos(26.0))
//!   API_UNAVAILABLE(ios, watchos, tvos, macos)`. It has `Linkage::External`
//!   and an ordinary USR, so neither the linkage filter nor a USR-prefix
//!   filter can catch it — only `is_unavailable_on_macos` fires. This is
//!   the canonical canary documented in the
//!   `extract-objc filters: platform unavailability` memory entry; locking
//!   it in against real-SDK extraction complements the synthetic-header
//!   coverage in `filter_platform_unavailable.rs`.
//! - **Positive control** — `AudioServicesPlaySystemSound` is declared with
//!   `API_AVAILABLE(macos(10.5), …)`. If AudioToolbox discovery or
//!   extraction itself is broken, this assertion fails loudly instead of
//!   letting the negative canary silently pass for the wrong reason.

use std::sync::LazyLock;

use apianyware_extract_objc::{create_index, extract_framework, init_clang, sdk};

/// Shared extracted AudioToolbox framework (expensive to compute, shared
/// across tests).
static AUDIO_TOOLBOX: LazyLock<apianyware_types::ir::Framework> = LazyLock::new(|| {
    let sdk = sdk::discover_sdk().expect("should discover macOS SDK");
    let frameworks = sdk::discover_frameworks(&sdk.path).expect("should discover frameworks");
    let audio_toolbox = frameworks
        .iter()
        .find(|f| f.name == "AudioToolbox")
        .expect("AudioToolbox not found");

    let clang = init_clang().expect("should initialize clang");
    let index = create_index(&clang);
    extract_framework(&index, audio_toolbox, &sdk).expect("should extract AudioToolbox")
});

fn audio_toolbox() -> &'static apianyware_types::ir::Framework {
    &AUDIO_TOOLBOX
}

#[test]
fn audio_toolbox_keeps_macos_available_function() {
    // Positive control: a symbol that must survive extraction. If this
    // assertion fails, discovery or extraction itself is broken and the
    // filter assertion below would be meaningless.
    let fw = audio_toolbox();
    assert!(
        fw.functions
            .iter()
            .any(|f| f.name == "AudioServicesPlaySystemSound"),
        "AudioServicesPlaySystemSound (API_AVAILABLE macos 10.5) should survive extraction"
    );
}

#[test]
fn audio_toolbox_filters_visionos_only_spatial_experience_constant() {
    // Canonical availability-filter canary. The declaration is
    // `API_UNAVAILABLE(ios, watchos, tvos, macos)` — the macos entry is
    // the load-bearing one. Locking this in against real-SDK extraction
    // catches regressions in `is_unavailable_on_macos` that synthetic
    // fixtures alone cannot: the synthetic test verifies the predicate,
    // this test verifies it fires on the real declaration libclang emits.
    let fw = audio_toolbox();
    let leaked: Vec<&str> = fw
        .constants
        .iter()
        .map(|c| c.name.as_str())
        .filter(|name| *name == "kAudioServicesDetailIntendedSpatialExperience")
        .collect();
    assert!(
        leaked.is_empty(),
        "API_UNAVAILABLE(macos) constant should be filtered, but found: {leaked:?}"
    );
}

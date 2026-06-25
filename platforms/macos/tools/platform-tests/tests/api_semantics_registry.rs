//! The authored `platforms/macos/tests/api-semantics/<facet>.apiw` registry loads,
//! validates, and covers exactly the four convention facets.
//!
//! This is the standing guard that every authored api-semantics file conforms to
//! `api-semantics.kdl-schema`, passes the semantic checks (facet-conditional §30
//! `weirdness` vocabulary, `(receiver, selector)` uniqueness, `expect`-id uniqueness,
//! facet = file stem), and that the four facets — ownership, callbacks, threading,
//! errors — are all present and non-empty. Unlike the sibling app-kind-tests guard,
//! an api-semantics file is self-contained (no cross-entity ref to resolve), so there
//! is no cross-registry check here.

use std::collections::BTreeSet;
use std::path::PathBuf;

use apianyware_platform_tests::{ApiSemanticsRegistry, Facet};

/// The authored api-semantics directory, relative to this crate's manifest
/// (`platforms/macos/tools/platform-tests/` up to `platforms/macos/tests/api-semantics/`).
fn api_semantics_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../tests/api-semantics")
        .canonicalize()
        .expect("platforms/macos/tests/api-semantics/ resolves")
}

fn registry() -> ApiSemanticsRegistry {
    ApiSemanticsRegistry::load_dir(&api_semantics_dir())
        .expect("every authored api-semantics file loads, validates, and passes semantic checks")
}

/// All four convention facets are authored and load.
#[test]
fn all_four_facets_present() {
    let reg = registry();
    assert_eq!(
        reg.len(),
        4,
        "exactly the four convention facets are authored"
    );

    let facets: BTreeSet<&str> = reg.all().map(|s| s.facet.as_str()).collect();
    assert_eq!(
        facets,
        BTreeSet::from(["ownership", "callbacks", "threading", "errors"]),
    );

    for facet in [
        Facet::Ownership,
        Facet::Callbacks,
        Facet::Threading,
        Facet::Errors,
    ] {
        assert!(
            reg.get(facet).is_some(),
            "facet `{}` is authored",
            facet.as_str()
        );
    }
}

/// Every loaded facet declares at least one API shape, every shape carries at least
/// one §30 weirdness tag and at least one expectation, and `(receiver, selector)`
/// shapes are unique within a file (load_dir would have errored otherwise — this
/// re-asserts the invariant shape across all committed files).
#[test]
fn every_declaration_is_well_formed() {
    let reg = registry();
    for semantics in reg.all() {
        assert!(
            !semantics.apis.is_empty(),
            "facet `{}` declares at least one API shape",
            semantics.facet.as_str()
        );

        let mut shapes = BTreeSet::new();
        for api in &semantics.apis {
            assert!(
                !api.weirdness.is_empty(),
                "shape `{} {}` (facet `{}`) carries at least one §30 weirdness tag",
                api.receiver,
                api.selector,
                semantics.facet.as_str()
            );
            assert!(
                !api.expectations.is_empty(),
                "shape `{} {}` (facet `{}`) carries at least one expectation",
                api.receiver,
                api.selector,
                semantics.facet.as_str()
            );
            assert!(
                shapes.insert((api.receiver.as_str(), api.selector.as_str())),
                "shape `{} {}` is unique within facet `{}`",
                api.receiver,
                api.selector,
                semantics.facet.as_str()
            );
        }
    }
}

/// A spot-check on the ownership facet: the autoreleased class-factory case is
/// authored with its canonical §30 tag — pinning that declarations are grounded in
/// real Foundation shapes, not placeholders.
#[test]
fn ownership_autoreleased_factory_is_grounded() {
    let reg = registry();
    let ownership = reg.get(Facet::Ownership).expect("ownership facet present");

    let factory = ownership
        .apis
        .iter()
        .find(|a| a.receiver == "NSString" && a.selector == "stringWithString:")
        .expect("the NSString stringWithString: class-factory shape is declared");
    assert!(
        factory.weirdness.iter().any(|w| w == "autoreleased"),
        "the class factory is tagged `autoreleased` (a +0 result the caller does not own)"
    );
}

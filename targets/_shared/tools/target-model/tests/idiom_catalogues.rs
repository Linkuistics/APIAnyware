//! The authored `targets/<id>/idioms/catalogue.apiw` catalogues load, validate, and drive
//! the data-driven `emit/pattern_dispatch` seam (the idioms-k53 done-bar).
//!
//! This is the standing guard that every authored idiom catalogue conforms to
//! `idioms.kdl-schema` AND passes the focused semantic checks (§21 category vocabulary,
//! category uniqueness, per-catalogue pattern-kind uniqueness, id = the target directory).
//! It also pins the **dispatch index** the `emit` crate's `classify_pattern` consumes: the
//! eight ws3 pattern-kinds the four scheme-family targets project, each to its expected
//! `EmitConstruct` + generated identifier, and the pass-through case (a kind no idiom
//! projects).

use std::path::PathBuf;

use apianyware_target_model::vocab::IDIOM_CATEGORIES;
use apianyware_target_model::{EmitConstruct, IdiomCatalogueRegistry};

/// The `targets/` root, relative to this crate's manifest
/// (`targets/_shared/tools/target-model/` up to `targets/`).
fn targets_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../..")
        .canonicalize()
        .expect("targets/ resolves")
}

fn registry() -> IdiomCatalogueRegistry {
    IdiomCatalogueRegistry::load_dir(&targets_dir())
        .expect("every authored idiom catalogue loads, validates, and passes semantic checks")
}

const TARGETS: [&str; 4] = ["racket", "chez", "gerbil", "sbcl"];

/// All four live targets are authored and load — and the registry holds *exactly* those
/// four (no extras, no gaps; `_shared/` carries no `idioms/catalogue.apiw` and is skipped).
#[test]
fn all_four_catalogues_present() {
    let reg = registry();
    for id in TARGETS {
        assert!(
            reg.get(id).is_some(),
            "missing authored idiom catalogue `{id}`"
        );
    }
    assert_eq!(
        reg.len(),
        TARGETS.len(),
        "registry has exactly the four live targets (no extras, no gaps; _shared skipped)"
    );
}

/// Every authored catalogue covers all 25 §21 idiom categories — so the catalogue is a
/// complete answer to "when the platform docs say X, how does that appear?" for each
/// target. Guards catalogue completeness as the standing invariant (the capability-profile
/// `every_profile_rates_the_full_vocabulary` analogue).
#[test]
fn every_catalogue_covers_the_full_section_21_vocabulary() {
    let reg = registry();
    for id in TARGETS {
        let c = reg.get(id).unwrap();
        for category in IDIOM_CATEGORIES {
            assert!(
                c.idiom(category).is_some(),
                "{id} catalogue is missing §21 category `{category}`"
            );
        }
    }
}

/// The dispatch index `classify_pattern` reads: the eight ws3 pattern-kinds the four
/// scheme-family targets project, each to its expected `EmitConstruct` + generated
/// identifier (uniform across the family — they share the with-macro / make-* convention;
/// the model permits a future non-Lisp target to author its own).
#[test]
fn the_emit_dispatch_index_is_authored_for_every_target() {
    use EmitConstruct::*;
    let expected: [(&str, EmitConstruct, &str); 8] = [
        ("bracket", ScopedResource, "with-bracket"),
        ("paired-state", ScopedGuard, "with-paired-state"),
        ("builder", BuilderDsl, "builder"),
        ("factory-cluster", SmartConstructor, "make-factory-cluster"),
        ("observer", ScopedObserver, "with-observer"),
        ("subscription", ScopedObserver, "with-subscription"),
        ("enumeration", IterationAdapter, "enumeration-sequence"),
        ("error-out", ResultWrapper, "error-out"),
    ];
    let reg = registry();
    for id in TARGETS {
        let c = reg.get(id).unwrap();
        for (kind, emit, name) in expected {
            let p = c
                .projection_for(kind)
                .unwrap_or_else(|| panic!("{id} catalogue does not project `{kind}`"));
            assert_eq!(
                p.emit, emit,
                "{id}: `{kind}` projects the wrong emit construct"
            );
            assert_eq!(p.name, name, "{id}: `{kind}` projects the wrong name");
        }
        // Exactly those eight kinds are projected (no extras) — keeps the dispatch index in
        // lockstep with the emit crate's classify_pattern coverage.
        assert_eq!(
            c.projections().count(),
            expected.len(),
            "{id} catalogue projects exactly the eight emit-relevant kinds"
        );
    }
}

/// A kind no idiom projects (a structural relationship, or a class-level idiom emitted as
/// part of class generation) resolves to no projection — the `classify_pattern`
/// pass-through case.
#[test]
fn unprojected_kinds_pass_through() {
    let reg = registry();
    for id in TARGETS {
        let c = reg.get(id).unwrap();
        for kind in ["delegate", "target-action", "parent-child", "typestate"] {
            assert!(
                c.projection_for(kind).is_none(),
                "{id}: `{kind}` should have no emit projection (pass-through)"
            );
        }
    }
}

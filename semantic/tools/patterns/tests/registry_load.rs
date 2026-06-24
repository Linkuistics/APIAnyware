//! The authored `semantic/pattern-kinds/*.apiw` registry loads, validates, and
//! has the expected role/law shapes (the `pattern-kind-registry-k28` done-bar).
//!
//! This is the standing guard that every authored kind conforms to
//! `pattern-kinds.kdl-schema` AND passes the semantic checks (token∈category,
//! ordering-edge role resolution, role-name uniqueness, name=file-stem). If a new
//! kind is added or an existing one drifts, this test exercises it end-to-end.

use std::path::PathBuf;

use apianyware_patterns::{Cardinality, LawCategory, PatternKindRegistry, RoleBinds};

/// The authored kind directory, relative to this crate's manifest.
fn pattern_kinds_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../pattern-kinds")
        .canonicalize()
        .expect("semantic/pattern-kinds/ resolves")
}

fn registry() -> PatternKindRegistry {
    PatternKindRegistry::load_dir(&pattern_kinds_dir())
        .expect("every authored pattern-kind loads, validates, and passes semantic checks")
}

/// Every §31/§32 kind named in the brief is authored and loads.
#[test]
fn all_brief_kinds_present() {
    let reg = registry();
    let expected = [
        // behavioral (§32 + legacy PatternStereotype)
        "bracket",
        "builder",
        "observer",
        "delegate",
        "factory-cluster",
        "paired-state",
        "target-action",
        "enumeration",
        "error-out",
        "subscription",
        "two-call-sizing",
        "buffer-fill",
        "typestate",
        // structural (§31)
        "parent-child",
        "callback-destroy-notifier",
        "collection-element-ownership",
    ];
    for name in expected {
        assert!(reg.get(name).is_some(), "missing authored kind `{name}`");
    }
    assert_eq!(
        reg.len(),
        expected.len(),
        "registry has exactly the brief's kinds (no extras, no gaps)"
    );
}

/// Every loaded kind has at least one role and every law token is in-vocabulary
/// (load_dir would have errored otherwise — this re-asserts the invariant shape).
#[test]
fn every_kind_is_well_formed() {
    let reg = registry();
    for kind in reg.kinds() {
        assert!(
            !kind.roles.is_empty(),
            "kind `{}` declares at least one role",
            kind.name
        );
        // The loader already enforced token∈category; assert the categories used
        // are the §30 set (a smoke that the enum decoded, not a string).
        for law in &kind.laws {
            assert!(
                matches!(
                    law.category,
                    LawCategory::Ownership
                        | LawCategory::Lifetime
                        | LawCategory::Threading
                        | LawCategory::Error
                        | LawCategory::Callback
                        | LawCategory::Buffer
                        | LawCategory::Relationship
                ),
                "kind `{}` has a recognized law category",
                kind.name
            );
            assert!(
                !law.tokens.is_empty(),
                "kind `{}` law has at least one token",
                kind.name
            );
        }
    }
}

/// `bracket` is the canonical behavioral kind: operation roles, an ordering
/// graph, and the bracket-totality error law.
#[test]
fn bracket_shape() {
    let reg = registry();
    let bracket = reg.get("bracket").expect("bracket present");
    assert!(bracket.is_behavioral());
    assert_eq!(bracket.role("acquire").unwrap().binds, RoleBinds::Operation);
    assert_eq!(
        bracket.role("operation").unwrap().cardinality,
        Cardinality::Many
    );
    let ordering = bracket.ordering.as_ref().expect("bracket has ordering");
    assert!(ordering
        .before
        .iter()
        .any(|e| e.earlier == "acquire" && e.later == "operation"));
    assert!(bracket.laws.iter().any(|l| l.category == LawCategory::Error
        && l.tokens
            .iter()
            .any(|t| t == "cleanup-required-after-partial-failure")));
}

/// `parent-child` is the canonical structural relationship: type-only roles, no
/// ordering, relationship laws (the degenerate pattern-kind — D4).
#[test]
fn parent_child_is_degenerate_relationship() {
    let reg = registry();
    let pc = reg.get("parent-child").expect("parent-child present");
    assert!(
        !pc.is_behavioral(),
        "a relationship has no operation roles / ordering"
    );
    assert!(pc.ordering.is_none());
    assert!(pc.roles.iter().all(|r| r.binds == RoleBinds::Type));
    assert_eq!(pc.laws[0].category, LawCategory::Relationship);
}

/// `callback-destroy-notifier` is the DP2 case: all roles bind to PARAMETERS of
/// one operation (a single-operation-scoped relationship).
#[test]
fn callback_destroy_notifier_is_parameter_scoped() {
    let reg = registry();
    let cdn = reg
        .get("callback-destroy-notifier")
        .expect("callback-destroy-notifier present");
    assert!(
        cdn.roles.iter().all(|r| r.binds == RoleBinds::Parameter),
        "all roles bind to parameters of one operation (DP2)"
    );
}

/// `subscription` realizes D5 composition: its `destroy` role binds to another
/// pattern-instance.
#[test]
fn subscription_composes_via_pattern_ref() {
    let reg = registry();
    let sub = reg.get("subscription").expect("subscription present");
    assert_eq!(sub.role("destroy").unwrap().binds, RoleBinds::Pattern);
}

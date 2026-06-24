//! End-to-end detection against the **real** authored kind registry
//! (`semantic/pattern-kinds/`).
//!
//! This is the contract check between the readback's role bindings and the
//! authored kinds: a misnamed role, a wrong `binds`, or a cardinality violation
//! makes `validate_instance` reject the instance and the producer drops it — so
//! "the expected instance is present and valid" proves the readback speaks the
//! kinds' vocabulary exactly. The datalog detection *logic* is unit-tested in
//! `program.rs`; this exercises the assembly + validation path on a synthetic
//! framework shaped like the real corpus's idioms.

use std::path::PathBuf;

use apianyware_pattern_detection::detect_pattern_instances;
use apianyware_patterns::PatternKindRegistry;
use apianyware_types::ir::Framework;
use apianyware_types::pattern_instance::{InstanceSource, PatternInstance};

/// Load the authored `semantic/pattern-kinds/` registry (the real kinds).
fn registry() -> PatternKindRegistry {
    let dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../../../semantic/pattern-kinds")
        .canonicalize()
        .expect("semantic/pattern-kinds/ resolves");
    PatternKindRegistry::load_dir(&dir).expect("authored kinds load")
}

/// A synthetic framework exercising all five convention detectors, plus a class
/// cluster with no public factory class methods (which must be dropped).
fn fixture() -> Framework {
    let m = |selector: &str, class_method: bool| {
        serde_json::json!({
            "selector": selector,
            "class_method": class_method,
            "return_type": {"kind": "primitive", "name": "void"},
        })
    };
    serde_json::from_value(serde_json::json!({
        "name": "TestKit",
        "classes": [
            // factory-cluster: NSArray (factory class methods) + NSMutableArray.
            { "name": "NSArray", "methods": [ m("array", true), m("arrayWithObject:", true) ] },
            { "name": "NSMutableArray", "methods": [ m("addObject:", false) ] },
            // factory-cluster with NO public factory class methods → dropped.
            { "name": "NSThing", "methods": [ m("describe", false) ] },
            { "name": "NSMutableThing", "methods": [] },
            // observer: add + remove on one class.
            { "name": "NSNotificationCenter", "methods": [
                m("addObserver:selector:name:object:", false),
                m("removeObserver:", false),
            ] },
            // paired-state: lock / unlock.
            { "name": "NSLock", "methods": [ m("lock", false), m("unlock", false) ] },
            // delegate: setDelegate: + NSCacheDelegate protocol.
            { "name": "NSCache", "methods": [ m("setDelegate:", false) ] },
            // bracket: resource access pair.
            { "name": "NSBundleResourceRequest", "methods": [
                m("beginAccessingResourcesWithCompletionHandler:", false),
                m("endAccessingResources", false),
            ] },
        ],
        "protocols": [
            { "name": "NSCacheDelegate", "optional_methods": [ m("cache:willEvictObject:", false) ] },
        ],
    }))
    .expect("fixture framework deserializes")
}

/// Find the single instance of `kind`, asserting exactly one exists.
fn only<'a>(instances: &'a [PatternInstance], kind: &str) -> &'a PatternInstance {
    let matches: Vec<&PatternInstance> = instances.iter().filter(|i| i.kind == kind).collect();
    assert_eq!(
        matches.len(),
        1,
        "expected exactly one `{kind}` instance, got {}",
        matches.len()
    );
    matches[0]
}

#[test]
fn detects_all_five_kinds_and_every_instance_validates() {
    let registry = registry();
    let instances = detect_pattern_instances(&fixture(), &registry);

    // Every produced instance is well-formed against the authored registry and
    // carries the convention provenance stamp + the single-framework home.
    for inst in &instances {
        assert_eq!(
            registry.validate_instance(inst),
            Ok(()),
            "produced instance {} of kind `{}` must validate",
            inst.id,
            inst.kind
        );
        assert_eq!(inst.source, InstanceSource::Convention);
        assert_eq!(inst.home, "TestKit");
        let provenance = inst.provenance.as_deref().unwrap_or_default();
        assert!(
            provenance.starts_with("convention:"),
            "provenance `{provenance}` must be a convention:<rule> stamp"
        );
        // The DP4 id is a pure function of (kind, roles).
        assert_eq!(
            inst.id,
            PatternInstance::compute_id(&inst.kind, &inst.roles)
        );
    }

    // All five kinds present.
    for kind in [
        "factory-cluster",
        "observer",
        "paired-state",
        "delegate",
        "bracket",
    ] {
        only(&instances, kind);
    }
}

#[test]
fn factory_cluster_binds_abstract_concrete_and_factory_roles() {
    let registry = registry();
    let instances = detect_pattern_instances(&fixture(), &registry);
    let cluster = only(&instances, "factory-cluster");

    // The abstract (immutable) type, the concrete (mutable) type, and ≥1 factory.
    assert_eq!(
        cluster.roles["abstract-type"].len(),
        1,
        "one abstract-type role binding"
    );
    assert_eq!(
        cluster.roles["concrete-type"].len(),
        1,
        "one concrete-type role binding"
    );
    assert_eq!(
        cluster.roles["factory"].len(),
        2,
        "both NSArray factory class methods are bound"
    );
    assert_eq!(
        cluster.provenance.as_deref(),
        Some("convention:factory-cluster")
    );
}

#[test]
fn cluster_without_factory_methods_is_dropped() {
    let registry = registry();
    let instances = detect_pattern_instances(&fixture(), &registry);

    // NSThing/NSMutableThing form a name pair, but NSThing exposes no public
    // factory class methods, so the cardinality-`+` `factory` role is unfillable
    // and the instance must not survive validation — exactly one cluster (NSArray).
    let clusters: Vec<&PatternInstance> = instances
        .iter()
        .filter(|i| i.kind == "factory-cluster")
        .collect();
    assert_eq!(clusters.len(), 1, "only the NSArray cluster is well-formed");
    assert_eq!(clusters[0].roles["abstract-type"].len(), 1);
}

#[test]
fn observer_binds_subject_register_unregister() {
    let registry = registry();
    let instances = detect_pattern_instances(&fixture(), &registry);
    let observer = only(&instances, "observer");

    assert!(observer.roles.contains_key("subject"));
    assert_eq!(observer.roles["register"].len(), 1);
    assert_eq!(observer.roles["unregister"].len(), 1);
    // The callback role is structurally unidentifiable at the convention tier.
    assert!(!observer.roles.contains_key("callback"));
}

#[test]
fn delegate_binds_protocol_and_callbacks() {
    let registry = registry();
    let instances = detect_pattern_instances(&fixture(), &registry);
    let delegate = only(&instances, "delegate");

    assert_eq!(delegate.roles["delegator"].len(), 1);
    assert_eq!(delegate.roles["protocol"].len(), 1);
    assert_eq!(delegate.roles["set-delegate"].len(), 1);
    assert_eq!(
        delegate.roles["callback"].len(),
        1,
        "the protocol's one optional method is the callback"
    );
}

#[test]
fn detection_is_deterministic() {
    let registry = registry();
    let a = detect_pattern_instances(&fixture(), &registry);
    let b = detect_pattern_instances(&fixture(), &registry);
    let ids = |v: &[PatternInstance]| v.iter().map(|i| i.id.clone()).collect::<Vec<_>>();
    assert_eq!(ids(&a), ids(&b), "instance ids are stable across runs");
}

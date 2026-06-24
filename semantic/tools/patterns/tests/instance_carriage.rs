//! The end-to-end **instance carriage** (ADR-0048, workstream-3 child 2 done-bar):
//! hand-authored pattern-instances ride a `Framework` through the `resolved.json`
//! JSON shape and validate against the authored kind registry, and the DP3 home
//! rule resolves a cross-framework instance deterministically.
//!
//! This is the carriage seam a real producer (the convention/llm/manual tiers,
//! later children) will write into; here fixture instances stand in for it.

use std::collections::BTreeMap;
use std::path::PathBuf;

use apianyware_patterns::PatternKindRegistry;
use apianyware_types::pattern_instance::{InstanceSource, Participant, PatternInstance};
use apianyware_types::Framework;

fn registry() -> PatternKindRegistry {
    let dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../pattern-kinds")
        .canonicalize()
        .expect("semantic/pattern-kinds/ resolves");
    PatternKindRegistry::load_dir(&dir).expect("authored kinds load")
}

fn roles(pairs: &[(&str, Vec<Participant>)]) -> BTreeMap<String, Vec<Participant>> {
    pairs
        .iter()
        .map(|(n, ps)| (n.to_string(), ps.clone()))
        .collect()
}

fn op(framework: &str, class: &str, selector: &str) -> Participant {
    Participant::Operation {
        framework: Some(framework.to_string()),
        class: Some(class.to_string()),
        selector: selector.to_string(),
    }
}

fn ty(framework: &str, name: &str) -> Participant {
    Participant::Type {
        framework: Some(framework.to_string()),
        name: name.to_string(),
    }
}

#[test]
fn instances_ride_a_framework_through_resolved_json_and_validate() {
    let reg = registry();

    // A convention-tier `bracket` (CGPath construction) and an llm-tier
    // cross-framework `parent-child` (an AppKit view parenting a CoreAudio type).
    let bracket_roles = roles(&[
        (
            "acquire",
            vec![op("CoreGraphics", "CGPath", "CGPathCreateMutable")],
        ),
        (
            "release",
            vec![op("CoreGraphics", "CGPath", "CGPathRelease")],
        ),
    ]);
    let bracket = PatternInstance {
        id: PatternInstance::compute_id("bracket", &bracket_roles),
        kind: "bracket".to_string(),
        home: reg
            .instance_home(&PatternInstance {
                id: String::new(),
                kind: "bracket".to_string(),
                home: String::new(),
                roles: bracket_roles.clone(),
                source: InstanceSource::Convention,
                confidence: None,
                provenance: None,
            })
            .expect("bracket homes to its single framework"),
        roles: bracket_roles,
        source: InstanceSource::Convention,
        confidence: None,
        provenance: Some("convention:create_release_pair".to_string()),
    };

    let pc_roles = roles(&[
        ("parent", vec![ty("AppKit", "NSView")]),
        ("child", vec![ty("CoreAudio", "AUNode")]),
    ]);
    let parent_child = PatternInstance {
        id: PatternInstance::compute_id("parent-child", &pc_roles),
        kind: "parent-child".to_string(),
        home: reg
            .instance_home(&PatternInstance {
                id: String::new(),
                kind: "parent-child".to_string(),
                home: String::new(),
                roles: pc_roles.clone(),
                source: InstanceSource::Llm,
                confidence: None,
                provenance: None,
            })
            .expect("parent-child homes to its primary role's framework"),
        roles: pc_roles,
        source: InstanceSource::Llm,
        confidence: Some(apianyware_types::annotation::Confidence::Medium),
        provenance: Some("AppKit view-hierarchy programming guide".to_string()),
    };

    // DP3: the cross-framework instance homes to the primary role (`parent`).
    assert_eq!(bracket.home, "CoreGraphics");
    assert_eq!(parent_child.home, "AppKit");

    // Carry the instances on a Framework and round-trip the resolved.json shape.
    let fw_json = serde_json::json!({
        "name": "CoreGraphics",
        "checkpoint": "resolved",
        "patterns": [
            serde_json::to_value(&bracket).unwrap(),
            serde_json::to_value(&parent_child).unwrap(),
        ],
    });
    let fw: Framework = serde_json::from_value(fw_json).expect("Framework carries patterns");
    assert_eq!(fw.patterns.len(), 2, "both instances survive the carriage");

    // Every carried instance validates against the authored registry.
    for instance in &fw.patterns {
        reg.validate_instance(instance)
            .unwrap_or_else(|e| panic!("instance {} should validate: {e}", instance.id));
    }

    // DP4: ids are content-derived and survive the round-trip unchanged.
    assert_eq!(
        fw.patterns[0].id,
        PatternInstance::compute_id(&fw.patterns[0].kind, &fw.patterns[0].roles),
        "id is reproducible from the carried (kind, roles)"
    );
}

#[test]
fn an_empty_framework_carries_no_patterns() {
    // The real corpus today: no producer runs, so `patterns` is absent/empty and
    // the field is skipped from resolved.json (serde skip_serializing_if).
    let fw: Framework = serde_json::from_value(serde_json::json!({"name": "Foundation"}))
        .expect("framework without patterns deserializes");
    assert!(fw.patterns.is_empty());
    let json = serde_json::to_string(&fw).unwrap();
    assert!(
        !json.contains("\"patterns\""),
        "an empty patterns list is omitted from resolved.json"
    );
}

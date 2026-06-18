//! Heuristic detection of multi-method API patterns.
//!
//! Scans a framework's classes, methods, and protocols for well-known Cocoa
//! idioms: observer pairs, paired state, factory clusters, error-out patterns,
//! delegate protocols, and resource lifecycles. These heuristics catch patterns
//! that can be recognized from naming conventions and type signatures alone.
//! More subtle patterns (builder sequences, transaction brackets) require LLM
//! analysis of Apple programming guides.

use apianyware_macos_types::annotation::{
    AnnotationSource, ApiPattern, PatternConstraint, PatternStereotype,
};
use apianyware_macos_types::ir::Framework;

/// Detect all heuristically-recognizable patterns in a framework.
pub fn detect_patterns(framework: &Framework) -> Vec<ApiPattern> {
    let mut patterns = Vec::new();

    patterns.extend(detect_factory_clusters(framework));
    patterns.extend(detect_observer_pairs(framework));
    patterns.extend(detect_paired_state(framework));
    patterns.extend(detect_delegate_protocols(framework));
    patterns.extend(detect_resource_lifecycles(framework));

    patterns
}

/// Detect mutable/immutable class pairs (factory cluster pattern).
fn detect_factory_clusters(framework: &Framework) -> Vec<ApiPattern> {
    let mut patterns = Vec::new();
    let class_names: Vec<&str> = framework.classes.iter().map(|c| c.name.as_str()).collect();

    for class in &framework.classes {
        if !class.name.starts_with("NSMutable") {
            continue;
        }

        let immutable_name = class.name.replacen("NSMutable", "NS", 1);
        if !class_names.contains(&immutable_name.as_str()) {
            continue;
        }

        // Find factory class methods on the immutable class
        let immutable_class = framework
            .classes
            .iter()
            .find(|c| c.name == immutable_name)
            .unwrap();
        let factory_methods: Vec<serde_json::Value> = immutable_class
            .methods
            .iter()
            .filter(|m| m.class_method && !m.init_method)
            .map(|m| {
                serde_json::json!({
                    "class": immutable_name,
                    "selector": m.selector,
                })
            })
            .collect();

        patterns.push(ApiPattern {
            stereotype: PatternStereotype::FactoryCluster,
            name: format!("{immutable_name} class cluster"),
            participants: serde_json::json!({
                "abstract_class": immutable_name,
                "mutable_variant": class.name,
                "factory_methods": factory_methods,
            }),
            constraints: vec![
                PatternConstraint {
                    kind: "immutability".to_string(),
                    description: format!(
                        "{immutable_name} instances are immutable; use {} for mutation",
                        class.name
                    ),
                },
                PatternConstraint {
                    kind: "copying".to_string(),
                    description: format!(
                        "copy returns self (already immutable); mutableCopy returns {}",
                        class.name
                    ),
                },
            ],
            source: AnnotationSource::Heuristic,
            doc_ref: None,
        });
    }

    patterns
}

/// Detect addObserver/removeObserver method pairs.
fn detect_observer_pairs(framework: &Framework) -> Vec<ApiPattern> {
    let mut patterns = Vec::new();

    for class in &framework.classes {
        let all_selectors = collect_all_selectors(class);

        let add_observers: Vec<&str> = all_selectors
            .iter()
            .filter(|s| s.starts_with("addObserver"))
            .copied()
            .collect();
        let remove_observers: Vec<&str> = all_selectors
            .iter()
            .filter(|s| s.starts_with("removeObserver"))
            .copied()
            .collect();

        if add_observers.is_empty() || remove_observers.is_empty() {
            continue;
        }

        let register: Vec<serde_json::Value> = add_observers
            .iter()
            .map(|s| {
                serde_json::json!({
                    "class": class.name,
                    "selector": s,
                })
            })
            .collect();
        let unregister: Vec<serde_json::Value> = remove_observers
            .iter()
            .map(|s| {
                serde_json::json!({
                    "class": class.name,
                    "selector": s,
                })
            })
            .collect();

        patterns.push(ApiPattern {
            stereotype: PatternStereotype::ObserverPair,
            name: format!("{} observer registration", class.name),
            participants: serde_json::json!({
                "register": register,
                "unregister": unregister,
            }),
            constraints: vec![
                PatternConstraint {
                    kind: "ordering".to_string(),
                    description:
                        "register before unregister; unregister before observer deallocation"
                            .to_string(),
                },
                PatternConstraint {
                    kind: "ownership".to_string(),
                    description: "observer is not retained by the observed object".to_string(),
                },
            ],
            source: AnnotationSource::Heuristic,
            doc_ref: None,
        });
    }

    patterns
}

/// Detect complementary verb pairs (lock/unlock, begin/end, etc.).
fn detect_paired_state(framework: &Framework) -> Vec<ApiPattern> {
    let mut patterns = Vec::new();

    let verb_pairs: &[(&str, &str, &str)] = &[
        ("lock", "unlock", "critical section"),
        ("beginEditing", "endEditing", "editing session"),
        ("beginUndoGrouping", "endUndoGrouping", "undo grouping"),
    ];

    for class in &framework.classes {
        let all_selectors = collect_all_selectors(class);

        for &(enable_sel, disable_sel, desc) in verb_pairs {
            if all_selectors.contains(&enable_sel) && all_selectors.contains(&disable_sel) {
                patterns.push(ApiPattern {
                    stereotype: PatternStereotype::PairedState,
                    name: format!("{} {desc}", class.name),
                    participants: serde_json::json!({
                        "enable": {"class": class.name, "selector": enable_sel},
                        "disable": {"class": class.name, "selector": disable_sel},
                    }),
                    constraints: vec![
                        PatternConstraint {
                            kind: "ordering".to_string(),
                            description: format!(
                                "every {enable_sel} must have matching {disable_sel}"
                            ),
                        },
                        PatternConstraint {
                            kind: "error_handling".to_string(),
                            description: format!(
                                "{disable_sel} must be called even on error (bracket semantics)"
                            ),
                        },
                    ],
                    source: AnnotationSource::Heuristic,
                    doc_ref: None,
                });
            }
        }

        // Generic begin*/end* pair detection
        let begin_selectors: Vec<&str> = all_selectors
            .iter()
            .filter(|s| s.starts_with("begin") && !verb_pairs.iter().any(|(v, _, _)| *v == **s))
            .copied()
            .collect();

        for begin_sel in &begin_selectors {
            let end_candidate = begin_sel.replacen("begin", "end", 1);
            if all_selectors.contains(&end_candidate.as_str()) {
                patterns.push(ApiPattern {
                    stereotype: PatternStereotype::PairedState,
                    name: format!("{} {}", class.name, begin_sel),
                    participants: serde_json::json!({
                        "enable": {"class": class.name, "selector": begin_sel},
                        "disable": {"class": class.name, "selector": end_candidate},
                    }),
                    constraints: vec![PatternConstraint {
                        kind: "ordering".to_string(),
                        description: format!(
                            "every {begin_sel} must have matching {end_candidate}"
                        ),
                    }],
                    source: AnnotationSource::Heuristic,
                    doc_ref: None,
                });
            }
        }
    }

    patterns
}

/// Detect delegate protocols by matching setDelegate: methods with *Delegate protocols.
fn detect_delegate_protocols(framework: &Framework) -> Vec<ApiPattern> {
    let mut patterns = Vec::new();
    let protocol_names: Vec<&str> = framework
        .protocols
        .iter()
        .map(|p| p.name.as_str())
        .collect();

    for class in &framework.classes {
        let all_selectors = collect_all_selectors(class);

        if !all_selectors.contains(&"setDelegate:") {
            continue;
        }

        // Look for a matching *Delegate protocol
        let delegate_protocol_candidates = [
            format!("{}Delegate", class.name),
            format!("{}Delegating", class.name),
        ];

        for candidate in &delegate_protocol_candidates {
            if protocol_names.contains(&candidate.as_str()) {
                let protocol = framework
                    .protocols
                    .iter()
                    .find(|p| p.name == *candidate)
                    .unwrap();

                let callbacks: Vec<serde_json::Value> = protocol
                    .required_methods
                    .iter()
                    .chain(protocol.optional_methods.iter())
                    .map(|m| {
                        serde_json::json!({
                            "protocol": candidate,
                            "selector": m.selector,
                        })
                    })
                    .collect();

                patterns.push(ApiPattern {
                    stereotype: PatternStereotype::DelegateProtocol,
                    name: format!("{} delegate", class.name),
                    participants: serde_json::json!({
                        "setter": {"class": class.name, "selector": "setDelegate:"},
                        "protocol": candidate,
                        "callbacks": callbacks,
                    }),
                    constraints: vec![PatternConstraint {
                        kind: "ownership".to_string(),
                        description: "delegate is weak (not retained)".to_string(),
                    }],
                    source: AnnotationSource::Heuristic,
                    doc_ref: None,
                });
                break;
            }
        }
    }

    patterns
}

/// Detect resource lifecycle patterns from create/release function pairs.
fn detect_resource_lifecycles(framework: &Framework) -> Vec<ApiPattern> {
    let mut patterns = Vec::new();

    // Look for class-level begin*/end* pairs that are more lifecycle than state
    // (beginEditing/endEditing already caught by paired_state, but
    //  beginAccessingResources/endAccessingResources is a lifecycle)
    for class in &framework.classes {
        let all_selectors = collect_all_selectors(class);

        // Resource access patterns
        let access_pairs: &[(&str, &str, &str)] = &[(
            "beginAccessingResourcesWithCompletionHandler:",
            "endAccessingResources",
            "on-demand resource access",
        )];

        for &(open_sel, close_sel, desc) in access_pairs {
            if all_selectors.contains(&open_sel) && all_selectors.contains(&close_sel) {
                patterns.push(ApiPattern {
                    stereotype: PatternStereotype::ResourceLifecycle,
                    name: format!("{} {desc}", class.name),
                    participants: serde_json::json!({
                        "open": {"class": class.name, "selector": open_sel},
                        "close": {"class": class.name, "selector": close_sel},
                    }),
                    constraints: vec![
                        PatternConstraint {
                            kind: "ordering".to_string(),
                            description: format!("{open_sel} must complete before using resources; {close_sel} when done"),
                        },
                    ],
                    source: AnnotationSource::Heuristic,
                    doc_ref: None,
                });
            }
        }
    }

    patterns
}

/// Collect all selector strings from a class (direct methods + category methods).
fn collect_all_selectors(class: &apianyware_macos_types::ir::Class) -> Vec<&str> {
    let mut selectors: Vec<&str> = class.methods.iter().map(|m| m.selector.as_str()).collect();
    for cg in &class.category_methods {
        for m in &cg.methods {
            selectors.push(m.selector.as_str());
        }
    }
    selectors
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::{Class, Protocol};

    fn empty_framework() -> Framework {
        Framework {
            format_version: "1.0".to_string(),
            checkpoint: "resolved".to_string(),
            name: "TestKit".to_string(),
            sdk_version: None,
            collected_at: None,
            depends_on: vec![],
            skipped_symbols: vec![],
            classes: vec![],
            protocols: vec![],
            enums: vec![],
            structs: vec![],
            functions: vec![],
            constants: vec![],
            class_annotations: vec![],
            api_patterns: vec![],
            enrichment: None,
            verification: None,
        }
    }

    fn make_method(selector: &str, class_method: bool) -> apianyware_macos_types::ir::Method {
        apianyware_macos_types::ir::Method {
            selector: selector.to_string(),
            class_method,
            init_method: false,
            params: vec![],
            return_type: apianyware_macos_types::type_ref::TypeRef::void(),
            deprecated: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
            category: None,
            overrides: None,
            returns_retained: None,
            satisfies_protocol: None,
            objc_exposed: true,
            swift_fn: None,
        }
    }

    #[test]
    fn detect_mutable_immutable_factory_cluster() {
        let mut fw = empty_framework();
        fw.classes.push(Class {
            name: "NSArray".to_string(),
            superclass: "NSObject".to_string(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                make_method("array", true),
                make_method("arrayWithObject:", true),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
        });
        fw.classes.push(Class {
            name: "NSMutableArray".to_string(),
            superclass: "NSArray".to_string(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_method("addObject:", false)],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
        });

        let patterns = detect_factory_clusters(&fw);
        assert_eq!(patterns.len(), 1);
        assert_eq!(patterns[0].stereotype, PatternStereotype::FactoryCluster);
        assert_eq!(patterns[0].name, "NSArray class cluster");
    }

    #[test]
    fn detect_notification_center_observer_pair() {
        let mut fw = empty_framework();
        fw.classes.push(Class {
            name: "NSNotificationCenter".to_string(),
            superclass: "NSObject".to_string(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                make_method("addObserver:selector:name:object:", false),
                make_method("removeObserver:", false),
                make_method("removeObserver:name:object:", false),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
        });

        let patterns = detect_observer_pairs(&fw);
        assert_eq!(patterns.len(), 1);
        assert_eq!(patterns[0].stereotype, PatternStereotype::ObserverPair);
        assert!(patterns[0].name.contains("NSNotificationCenter"));
    }

    #[test]
    fn detect_lock_unlock_paired_state() {
        let mut fw = empty_framework();
        fw.classes.push(Class {
            name: "NSLock".to_string(),
            superclass: "NSObject".to_string(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                make_method("lock", false),
                make_method("unlock", false),
                make_method("tryLock", false),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
        });

        let patterns = detect_paired_state(&fw);
        assert_eq!(patterns.len(), 1);
        assert_eq!(patterns[0].stereotype, PatternStereotype::PairedState);
        assert!(patterns[0].name.contains("critical section"));
    }

    #[test]
    fn detect_begin_end_paired_state() {
        let mut fw = empty_framework();
        fw.classes.push(Class {
            name: "NSUndoManager".to_string(),
            superclass: "NSObject".to_string(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                make_method("beginUndoGrouping", false),
                make_method("endUndoGrouping", false),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
        });

        let patterns = detect_paired_state(&fw);
        assert_eq!(patterns.len(), 1);
        assert!(patterns[0].name.contains("NSUndoManager"));
    }

    #[test]
    fn detect_delegate_with_protocol() {
        let mut fw = empty_framework();
        fw.classes.push(Class {
            name: "NSCache".to_string(),
            superclass: "NSObject".to_string(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                make_method("setDelegate:", false),
                make_method("delegate", false),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
        });
        fw.protocols.push(Protocol {
            name: "NSCacheDelegate".to_string(),
            inherits: vec![],
            required_methods: vec![],
            optional_methods: vec![make_method("cache:willEvictObject:", false)],
            properties: vec![],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
        });

        let patterns = detect_delegate_protocols(&fw);
        assert_eq!(patterns.len(), 1);
        assert_eq!(patterns[0].stereotype, PatternStereotype::DelegateProtocol);
        assert!(patterns[0].name.contains("NSCache delegate"));
    }

    #[test]
    fn no_delegate_without_protocol() {
        let mut fw = empty_framework();
        fw.classes.push(Class {
            name: "NSFoo".to_string(),
            superclass: "NSObject".to_string(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_method("setDelegate:", false)],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
        });
        // No NSFooDelegate protocol

        let patterns = detect_delegate_protocols(&fw);
        assert!(patterns.is_empty());
    }

    #[test]
    fn detect_all_patterns_on_foundation() {
        // Integration test: load real Foundation and detect patterns
        let resolved_path = std::path::Path::new("../../analysis/ir/resolved/Foundation.json");
        if !resolved_path.exists() {
            // Skip if resolved IR not available (CI)
            return;
        }

        let content = std::fs::read_to_string(resolved_path).unwrap();
        let fw: Framework = serde_json::from_str(&content).unwrap();
        let patterns = detect_patterns(&fw);

        // Should find multiple pattern types
        let factory_count = patterns
            .iter()
            .filter(|p| p.stereotype == PatternStereotype::FactoryCluster)
            .count();
        let observer_count = patterns
            .iter()
            .filter(|p| p.stereotype == PatternStereotype::ObserverPair)
            .count();
        let paired_count = patterns
            .iter()
            .filter(|p| p.stereotype == PatternStereotype::PairedState)
            .count();
        let delegate_count = patterns
            .iter()
            .filter(|p| p.stereotype == PatternStereotype::DelegateProtocol)
            .count();

        assert!(
            factory_count >= 5,
            "expected at least 5 factory clusters, got {factory_count}"
        );
        assert!(
            observer_count >= 2,
            "expected at least 2 observer pairs, got {observer_count}"
        );
        assert!(
            paired_count >= 1,
            "expected at least 1 paired state, got {paired_count}"
        );
        assert!(
            delegate_count >= 3,
            "expected at least 3 delegate protocols, got {delegate_count}"
        );

        // Log summary for debugging
        eprintln!("Foundation patterns detected:");
        eprintln!("  Factory clusters: {factory_count}");
        eprintln!("  Observer pairs: {observer_count}");
        eprintln!("  Paired state: {paired_count}");
        eprintln!("  Delegate protocols: {delegate_count}");
        eprintln!("  Total: {}", patterns.len());
    }
}

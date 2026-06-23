//! Build and write resolved Framework checkpoints.
//!
//! Maps Datalog resolution results back into the Framework IR struct,
//! populating `ancestors`, `all_methods`, `all_properties`, and per-method
//! `returns_retained` and `satisfies_protocol` fields.

use std::collections::{HashMap, HashSet};
use std::path::Path;

use anyhow::{Context, Result};
use apianyware_types::ir::{Framework, Method, Property};

use crate::program::ResolutionProgram;

/// Write a resolved framework checkpoint to `{output_dir}/{framework.name}.json`.
pub fn write_resolved_checkpoint(framework: &Framework, output_dir: &Path) -> Result<()> {
    let path = output_dir.join(format!("{}.json", framework.name));
    let json = serde_json::to_string_pretty(framework)
        .with_context(|| format!("failed to serialize {}", framework.name))?;
    std::fs::write(&path, json).with_context(|| format!("failed to write {}", path.display()))?;
    tracing::info!(framework = %framework.name, path = %path.display(), "wrote resolved checkpoint");
    Ok(())
}

/// Build a resolved framework from collected IR + Datalog results.
///
/// `all_frameworks` provides the full set of loaded frameworks so that
/// cross-framework inherited methods/properties can be looked up with full
/// metadata (params, return types, etc.) instead of falling back to minimal
/// stubs.
///
/// Clones the collected framework and populates resolved-phase fields:
/// - `checkpoint` → `"resolved"`
/// - `Class::ancestors` — transitive ancestor list
/// - `Class::all_methods` — inheritance-flattened methods with `origin`, `returns_retained`, `satisfies_protocol`
/// - `Class::all_properties` — inheritance-flattened properties with `origin`
pub fn build_resolved_framework(
    collected: &Framework,
    prog: &ResolutionProgram,
    all_frameworks: &[Framework],
) -> Framework {
    // Index methods and properties across ALL frameworks for cross-framework lookup
    let method_index = build_method_index(all_frameworks);
    let property_index = build_property_index(all_frameworks);
    let protocol_method_index = build_protocol_method_index(all_frameworks);

    // Index returns_retained results: (class, selector, is_class_method)
    let retained_set: HashSet<(&str, &str, bool)> = prog
        .returns_retained_method
        .iter()
        .map(|(c, s, is_cm)| (c.as_str(), s.as_str(), *is_cm))
        .collect();

    // Index satisfies_protocol: (class, selector, is_class_method) → protocol_name
    let mut protocol_satisfaction: HashMap<(&str, &str, bool), &str> = HashMap::new();
    for (class, sel, is_cm, proto) in &prog.satisfies_protocol_method {
        protocol_satisfaction
            .entry((class.as_str(), sel.as_str(), *is_cm))
            .or_insert(proto.as_str());
    }

    let mut resolved = collected.clone();
    resolved.checkpoint = "resolved".to_string();

    for class in &mut resolved.classes {
        // Populate ancestors
        class.ancestors = prog
            .ancestor
            .iter()
            .filter(|(child, _)| child == &class.name)
            .map(|(_, anc)| anc.clone())
            .collect();
        // Sort ancestors for deterministic output (root first)
        class.ancestors.sort();

        // Populate all_methods from effective_method results
        class.all_methods = build_effective_methods_for_class(
            &class.name,
            prog,
            &method_index,
            &protocol_method_index,
            &retained_set,
            &protocol_satisfaction,
        );

        // Populate all_properties from effective_property results
        class.all_properties =
            build_effective_properties_for_class(&class.name, prog, &property_index);
    }

    resolved
}

/// Method lookup key: (class_name, selector, is_class_method)
type MethodKey<'a> = (&'a str, &'a str, bool);

/// Build an index from (class, selector, is_class_method) → Method
/// across all classes in all loaded frameworks, so cross-framework inherited
/// methods retain full metadata (params, return type, etc.).
fn build_method_index<'a>(all_frameworks: &'a [Framework]) -> HashMap<MethodKey<'a>, &'a Method> {
    let mut index = HashMap::new();
    for framework in all_frameworks {
        for class in &framework.classes {
            for method in &class.methods {
                index.insert(
                    (
                        class.name.as_str(),
                        method.selector.as_str(),
                        method.class_method,
                    ),
                    method,
                );
            }
        }
    }
    index
}

/// Protocol-method lookup key: (protocol_name, selector, is_class_method)
type ProtocolMethodKey<'a> = (&'a str, &'a str, bool);

/// Build an index from (protocol, selector, is_class_method) → Method
/// across all protocols in all loaded frameworks, covering both
/// `required_methods` and `optional_methods`. Used to resolve full metadata
/// when a class's effective_method has a protocol name as its origin.
fn build_protocol_method_index<'a>(
    all_frameworks: &'a [Framework],
) -> HashMap<ProtocolMethodKey<'a>, &'a Method> {
    let mut index = HashMap::new();
    for framework in all_frameworks {
        for proto in &framework.protocols {
            for method in proto
                .required_methods
                .iter()
                .chain(proto.optional_methods.iter())
            {
                index.insert(
                    (
                        proto.name.as_str(),
                        method.selector.as_str(),
                        method.class_method,
                    ),
                    method,
                );
            }
        }
    }
    index
}

/// Property lookup key: (class_name, property_name)
type PropertyKey<'a> = (&'a str, &'a str);

/// Build an index from (class, property_name) → Property
/// across all classes in all loaded frameworks, so cross-framework inherited
/// properties retain full metadata (type, readonly, etc.).
fn build_property_index<'a>(
    all_frameworks: &'a [Framework],
) -> HashMap<PropertyKey<'a>, &'a Property> {
    let mut index = HashMap::new();
    for framework in all_frameworks {
        for class in &framework.classes {
            for prop in &class.properties {
                index.insert((class.name.as_str(), prop.name.as_str()), prop);
            }
        }
    }
    index
}

/// Build the `all_methods` list for a class from effective_method Datalog results.
fn build_effective_methods_for_class(
    class_name: &str,
    prog: &ResolutionProgram,
    method_index: &HashMap<MethodKey<'_>, &Method>,
    protocol_method_index: &HashMap<ProtocolMethodKey<'_>, &Method>,
    retained_set: &HashSet<(&str, &str, bool)>,
    protocol_satisfaction: &HashMap<(&str, &str, bool), &str>,
) -> Vec<Method> {
    let mut methods: Vec<Method> = prog
        .effective_method
        .iter()
        .filter(|(class, _, _, _, _, _, _)| class == class_name)
        .map(|(class, sel, is_cm, is_init, is_dep, is_var, origin)| {
            // Try to find the original method declaration for full metadata.
            // Origin is either a class name (direct/inherited method) or a
            // protocol name (protocol-inherited method) — try both indexes.
            let key = (origin.as_str(), sel.as_str(), *is_cm);
            let resolved_method = method_index
                .get(&key)
                .or_else(|| protocol_method_index.get(&key));

            if let Some(original) = resolved_method {
                let mut method = (*original).clone();
                // Set resolved-phase fields
                if origin != class {
                    method.origin = Some(origin.clone());
                }
                method.returns_retained =
                    Some(retained_set.contains(&(class.as_str(), sel.as_str(), *is_cm)));
                if let Some(proto) =
                    protocol_satisfaction.get(&(class.as_str(), sel.as_str(), *is_cm))
                {
                    method.satisfies_protocol = Some(proto.to_string());
                }
                method
            } else {
                // Method from another framework (cross-framework inheritance) —
                // create a minimal Method from the Datalog tuple
                let mut method = Method {
                    selector: sel.clone(),
                    class_method: *is_cm,
                    init_method: *is_init,
                    params: Vec::new(),
                    return_type: apianyware_types::TypeRef::void(),
                    deprecated: *is_dep,
                    variadic: *is_var,
                    source: None,
                    provenance: None,
                    doc_refs: None,
                    origin: Some(origin.clone()),
                    category: None,
                    overrides: None,
                    returns_retained: Some(retained_set.contains(&(
                        class.as_str(),
                        sel.as_str(),
                        *is_cm,
                    ))),
                    satisfies_protocol: None,
                    // Minimal cross-framework inherited method: no source decl
                    // in our index. Default to the ObjC-exposed limit (ADR-0026)
                    // — the in-index branch above clones and preserves the fact.
                    objc_exposed: true,
                    // No source decl ⇒ no Swift-native call metadata; the
                    // in-index branch clones and preserves the real value.
                    swift_fn: None,
                };
                if let Some(proto) =
                    protocol_satisfaction.get(&(class.as_str(), sel.as_str(), *is_cm))
                {
                    method.satisfies_protocol = Some(proto.to_string());
                }
                method
            }
        })
        .collect();

    // Sort for deterministic output
    methods.sort_by(|a, b| {
        a.selector
            .cmp(&b.selector)
            .then(a.class_method.cmp(&b.class_method))
    });

    methods
}

/// Build the `all_properties` list for a class from effective_property Datalog results.
fn build_effective_properties_for_class(
    class_name: &str,
    prog: &ResolutionProgram,
    property_index: &HashMap<PropertyKey<'_>, &Property>,
) -> Vec<Property> {
    let mut properties: Vec<Property> = prog
        .effective_property
        .iter()
        .filter(|(class, _, _, _, _, _)| class == class_name)
        .map(|(class, name, ro, cp, dep, origin)| {
            let key = (origin.as_str(), name.as_str());
            if let Some(original) = property_index.get(&key) {
                let mut prop = (*original).clone();
                if origin != class {
                    prop.origin = Some(origin.clone());
                }
                prop
            } else {
                // Property from another framework
                Property {
                    name: name.clone(),
                    property_type: apianyware_types::TypeRef::void(),
                    readonly: *ro,
                    class_property: *cp,
                    is_copy: false,
                    deprecated: *dep,
                    source: None,
                    provenance: None,
                    doc_refs: None,
                    origin: Some(origin.clone()),
                    objc_exposed: true,
                }
            }
        })
        .collect();

    properties.sort_by(|a, b| a.name.cmp(&b.name));
    properties
}

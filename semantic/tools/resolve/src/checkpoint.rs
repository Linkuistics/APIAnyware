//! Build and write `linked` Framework checkpoints.
//!
//! Maps Datalog resolution results back into the Framework IR struct,
//! populating `ancestors`, `all_methods`, `all_properties`, and per-method
//! `returns_retained` and `satisfies_protocol` fields. This is pass 1 — the
//! `linked` stage (ADR-0046 rename; formerly the on-disk `resolved` checkpoint,
//! whose name collided with the final `resolved.kdl`). It runs in-process; the
//! disk writer below remains available for ad-hoc dumps.

use std::collections::{HashMap, HashSet};
use std::path::Path;

use anyhow::{Context, Result};
use apianyware_types::ir::{Framework, Method, Property};

use crate::program::ResolutionProgram;

/// Write a `linked` framework checkpoint to `{output_dir}/{framework.name}.json`.
pub fn write_linked_checkpoint(framework: &Framework, output_dir: &Path) -> Result<()> {
    let path = output_dir.join(format!("{}.json", framework.name));
    let json = serde_json::to_string_pretty(framework)
        .with_context(|| format!("failed to serialize {}", framework.name))?;
    std::fs::write(&path, json).with_context(|| format!("failed to write {}", path.display()))?;
    tracing::info!(framework = %framework.name, path = %path.display(), "wrote linked checkpoint");
    Ok(())
}

/// Build a `linked` framework from extracted IR + Datalog results.
///
/// `all_frameworks` provides the full set of loaded frameworks so that
/// cross-framework inherited methods/properties can be looked up with full
/// metadata (params, return types, etc.) instead of falling back to minimal
/// stubs.
///
/// Clones the extracted framework and populates linked-phase fields:
/// - `checkpoint` → `"linked"`
/// - `Class::ancestors` — transitive ancestor list
/// - `Class::all_methods` — inheritance-flattened methods with `origin`, `returns_retained`, `satisfies_protocol`
/// - `Class::all_properties` — inheritance-flattened properties with `origin`
pub fn build_linked_framework(
    extracted: &Framework,
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

    let mut linked = extracted.clone();
    linked.checkpoint = "linked".to_string();

    for class in &mut linked.classes {
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

    linked
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
                // Set resolved-phase fields. `origin` is a **plain name string** shared by two
                // namespaces (a class or a protocol) — comparing it against `class` by string
                // equality alone is the same lossy-map-as-key species ADR-0055 §4c already named
                // for the render layer (`protocol-class-name-collapse-k90`), reaching the IR here:
                // a class whose own declaration is genuinely empty but which conforms to a
                // same-named protocol (`NSTextAttachmentCell : NSCell <NSTextAttachmentCell>`, 5
                // corpus occurrences) gets an `effective_method` row whose `origin` STRING equals
                // `class` even though the row came from the *protocol's* propagation rule, not the
                // class's own `method_decl` — `typecheck-gate-post-k86-residuals-k110`. The
                // disambiguator already exists: `method_index` is keyed on the same
                // `(class, selector, is_class_method)` triple `method_decl` populates, so a row is a
                // genuine own declaration iff *that* exact key (class, not origin) is present there
                // — not iff the name strings happen to match.
                let is_own_declaration =
                    method_index.contains_key(&(class.as_str(), sel.as_str(), *is_cm));
                if !is_own_declaration {
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

    // Sort for deterministic output. `origin` breaks ties on content (not
    // Datalog derivation order) so the dedup below is independent of ascent's
    // internal relation iteration order, which shifts with unrelated fact
    // volume (e.g. how many other frameworks share the run) — see
    // `has_nondeprecated_protocol_method` in program.rs for the common case
    // (a deprecated vs. non-deprecated protocol declaring the same selector),
    // already resolved before this point.
    methods.sort_by(|a, b| {
        a.selector
            .cmp(&b.selector)
            .then(a.class_method.cmp(&b.class_method))
            .then(a.origin.cmp(&b.origin))
    });

    // Residual same-selector collision: two conformed protocols of matching
    // deprecation status both declare it (the Datalog precedence above only
    // orders deprecated vs. non-deprecated), and — unlike `NSSecureCoding`/
    // `NSCoding` — carry no `protocol_inherits` edge between them either (the
    // real-corpus shape: `NSAccessibility`, a wide informal protocol declaring
    // `accessibilityValue` as a bare `id`, alongside an unrelated specific sibling
    // like `NSAccessibilityProgressIndicator` narrowing it to `NSNumber` —
    // `typecheck-gate-post-k86-residuals-k110`, ADR-0055 §4b). When exactly one
    // side declares a bare, unqualified `id` return and the other does not, the
    // non-bare declaration is strictly more informative — an untyped `id` return
    // is never a *better* fact than a typed one, only a less specific one — so it
    // wins regardless of alphabetical origin. Otherwise (including when BOTH or
    // NEITHER declare a bare `id`) fall back to the deterministic
    // alphabetically-first origin — and count what was dropped rather than losing
    // it silently (k57 discipline).
    let mut deduped: Vec<Method> = Vec::with_capacity(methods.len());
    let mut collisions = 0usize;
    for method in methods {
        let collides = deduped.last().is_some_and(|kept: &Method| {
            kept.selector == method.selector && kept.class_method == method.class_method
        });
        if !collides {
            deduped.push(method);
            continue;
        }
        collisions += 1;
        let kept = deduped.last_mut().expect("just checked collides");
        if is_bare_id_return(&kept.return_type) && !is_bare_id_return(&method.return_type) {
            *kept = method;
        }
    }
    if collisions > 0 {
        tracing::warn!(
            class = class_name,
            collisions,
            "resolved residual same-selector effective_method collisions (matching deprecation status, distinct protocol origins) — preferred a typed return over a bare `id` where exactly one side had one, else kept the alphabetically-first origin"
        );
    }

    deduped
}

/// A bare, unqualified `id` return (`TypeRefKind::Id` with no protocol qualifiers) — the least
/// specific object return a method can declare. The only signal [`build_effective_methods_for_class`]'s
/// residual-collision dedup uses to prefer one same-deprecation-status protocol declaration over
/// another with no `inherits` relation between them: a concrete class or a protocol-qualified `id`
/// is strictly more informative than the untyped case, in every target this IR feeds (ADR-0011) —
/// not a TypeScript-specific judgment, even though TypeScript's static types are what first made
/// the ambiguity observable (`corpus-typecheck-gate-k75`).
fn is_bare_id_return(t: &apianyware_types::TypeRef) -> bool {
    matches!(
        &t.kind,
        apianyware_types::TypeRefKind::Id { protocols } if protocols.is_empty()
    )
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
                    ownership: None,
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

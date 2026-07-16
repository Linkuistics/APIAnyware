//! Load a linked IR [`Framework`] into the convention program's base facts.
//!
//! Pushes one `param` tuple per method parameter, over the **same method set**
//! the annotate step classifies (so the rule output is comparable to the legacy
//! `heuristics.rs` output method-for-method): a class's inheritance-flattened
//! `all_methods` (falling back to direct `methods` when unresolved — both already
//! carry its category methods, extraction merges them in,
//! `text-undo-surface-gap-k121`), and every protocol's required + optional
//! methods. For each
//! method it also pushes a `param_count` tuple (the block-invocation
//! last-parameter rule and the error-pattern trailing-out-param rule need the
//! arity) and, for each `Pointer`-typed parameter, a `pointer_param` tuple (the
//! error-pattern facet's `NSError**` test needs the last param's pointer-ness).
//!
//! Additionally pushes one `property` tuple per **instance** property each
//! receiver declares **directly** — classes use `properties` (not
//! `all_properties`), exactly as `heuristics::annotate_method_heuristic` passes
//! `&class.properties`, so the copy-block-property-setter join sees the same
//! property set the legacy `.any(...)` did. Class properties are filtered out
//! at load (the legacy rule requires `!p.class_property`).
//!
//! For the **threading** facet it pushes one `receiver_method` tuple per method
//! (tagged `is_class`, so the class-only `@MainActor` signal cannot leak to a
//! same-named protocol's methods) and one `swift_attribute` tuple per attribute
//! on each **class** (protocols carry none — the IR records no Swift attributes
//! on protocols, mirroring the legacy `&[]` slice).

use apianyware_types::ir::{Framework, Method, Property};
use apianyware_types::type_ref::TypeRefKind;

use crate::program::ConventionProgram;

/// Populate the convention program's base relations from one framework. May be
/// called repeatedly (e.g. Foundation + AppKit) before `run()`.
pub fn load_framework_facts(prog: &mut ConventionProgram, framework: &Framework) {
    for class in &framework.classes {
        // Inheritance-flattened methods when resolve has run; direct methods
        // otherwise. Mirrors `annotate::annotate_framework`'s selection.
        let methods = if class.all_methods.is_empty() {
            &class.methods
        } else {
            &class.all_methods
        };
        for method in methods {
            load_method_params(prog, &class.name, method);
            // Threading is method-level (not per-param) and must enumerate
            // zero-param methods too — hence a tuple per method, tagged as a
            // class receiver (`is_class = true`).
            prog.receiver_method
                .push((class.name.clone(), method.selector.clone(), true));
        }
        // Direct (not flattened) properties: the legacy block-setter check
        // consults `class.properties`, even for inherited methods.
        load_receiver_properties(prog, &class.name, &class.properties);
        // Class-level Swift attributes feed the `@MainActor` threading signal —
        // classes only (protocols carry none in the IR).
        for attr in &class.swift_attributes {
            prog.swift_attribute
                .push((class.name.clone(), attr.clone()));
        }
    }

    for protocol in &framework.protocols {
        for method in protocol
            .required_methods
            .iter()
            .chain(&protocol.optional_methods)
        {
            load_method_params(prog, &protocol.name, method);
            // Protocol methods: `is_class = false`, so the class-only
            // `@MainActor` signal cannot stamp them (mirrors the legacy `&[]`
            // swift-attributes passed for protocols).
            prog.receiver_method
                .push((protocol.name.clone(), method.selector.clone(), false));
        }
        load_receiver_properties(prog, &protocol.name, &protocol.properties);
    }
}

/// Push one `param` fact per parameter of `method` (plus one `param_count`
/// fact), keyed by `receiver` (class or protocol name) and selector.
fn load_method_params(prog: &mut ConventionProgram, receiver: &str, method: &Method) {
    for (index, param) in method.params.iter().enumerate() {
        let is_block = matches!(param.param_type.kind, TypeRefKind::Block { .. });
        prog.param.push((
            receiver.to_string(),
            method.selector.clone(),
            index as u32,
            param.name.clone(),
            is_block,
        ));
        // Pointer-ness carriage for the error-pattern facet (the `param`
        // relation records name but not type kind). Pushed for every pointer
        // param; the error rule restricts to the last one via `param_count`.
        if matches!(param.param_type.kind, TypeRefKind::Pointer) {
            prog.pointer_param
                .push((receiver.to_string(), method.selector.clone(), index as u32));
        }
    }
    prog.param_count.push((
        receiver.to_string(),
        method.selector.clone(),
        method.params.len() as u32,
    ));
}

/// Push one `property` fact per **instance** property in `properties`, keyed by
/// `receiver`. Class properties are skipped (the copy-block-property-setter rule
/// requires `!p.class_property`).
///
/// Carries the **declared** ownership qualifier verbatim (`None` when the header
/// states none), plus the two type bits the rules gate on: `is_object` (the
/// declared type is an object pointer) and `is_block` (it is an ObjC block).
/// `is_object` is what stops a scalar `@property (assign) BOOL` from stamping its
/// setter's argument with an ownership it cannot have.
fn load_receiver_properties(prog: &mut ConventionProgram, receiver: &str, properties: &[Property]) {
    for property in properties {
        if property.class_property {
            continue;
        }
        let kind = &property.property_type.kind;
        let is_object = matches!(
            kind,
            TypeRefKind::Class { .. } | TypeRefKind::Id { .. } | TypeRefKind::Instancetype
        );
        let is_block = matches!(kind, TypeRefKind::Block { .. });
        prog.property.push((
            receiver.to_string(),
            property.name.clone(),
            property.ownership,
            is_object,
            is_block,
        ));
    }
}

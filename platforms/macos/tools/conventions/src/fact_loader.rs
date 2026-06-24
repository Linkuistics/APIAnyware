//! Load a linked IR [`Framework`] into the convention program's base facts.
//!
//! Pushes one `param` tuple per method parameter, over the **same method set**
//! the annotate step classifies (so the rule output is comparable to the legacy
//! `heuristics.rs` output method-for-method): a class's inheritance-flattened
//! `all_methods` (falling back to direct `methods` when unresolved) plus its
//! category methods, and every protocol's required + optional methods. For each
//! method it also pushes a `param_count` tuple (the block-invocation
//! last-parameter rule needs the arity).
//!
//! Additionally pushes one `property` tuple per **instance** property each
//! receiver declares **directly** — classes use `properties` (not
//! `all_properties`), exactly as `heuristics::annotate_method_heuristic` passes
//! `&class.properties`, so the copy-block-property-setter join sees the same
//! property set the legacy `.any(...)` did. Class properties are filtered out
//! at load (the legacy rule requires `!p.class_property`).

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
        }
        for group in &class.category_methods {
            for method in &group.methods {
                load_method_params(prog, &class.name, method);
            }
        }
        // Direct (not flattened) properties: the legacy block-setter check
        // consults `class.properties`, even for inherited methods.
        load_receiver_properties(prog, &class.name, &class.properties);
    }

    for protocol in &framework.protocols {
        for method in protocol
            .required_methods
            .iter()
            .chain(&protocol.optional_methods)
        {
            load_method_params(prog, &protocol.name, method);
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
    }
    prog.param_count.push((
        receiver.to_string(),
        method.selector.clone(),
        method.params.len() as u32,
    ));
}

/// Push one `property` fact per **instance** property in `properties`, keyed by
/// `receiver`. Class properties are skipped (the copy-block-property-setter rule
/// requires `!p.class_property`); `is_block` records whether the declared type
/// is an ObjC block.
fn load_receiver_properties(prog: &mut ConventionProgram, receiver: &str, properties: &[Property]) {
    for property in properties {
        if property.class_property {
            continue;
        }
        let is_block = matches!(property.property_type.kind, TypeRefKind::Block { .. });
        prog.property.push((
            receiver.to_string(),
            property.name.clone(),
            property.is_copy,
            is_block,
        ));
    }
}

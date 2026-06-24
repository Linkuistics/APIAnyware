//! Load a linked IR [`Framework`] into the convention program's base facts.
//!
//! Pushes one `param` tuple per method parameter, over the **same method set**
//! the annotate step classifies (so the rule output is comparable to the legacy
//! `heuristics.rs` output method-for-method): a class's inheritance-flattened
//! `all_methods` (falling back to direct `methods` when unresolved) plus its
//! category methods, and every protocol's required + optional methods.

use apianyware_types::ir::{Framework, Method};
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
    }

    for protocol in &framework.protocols {
        for method in protocol
            .required_methods
            .iter()
            .chain(&protocol.optional_methods)
        {
            load_method_params(prog, &protocol.name, method);
        }
    }
}

/// Push one `param` fact per parameter of `method`, keyed by `receiver`
/// (class or protocol name) and selector.
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
}

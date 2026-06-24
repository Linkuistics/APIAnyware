//! Load a linked IR [`Framework`] into the pattern program's base facts.
//!
//! Pushes the fact set the five convention detectors need, over the **same**
//! class/selector material the retired `annotate/pattern_detection.rs` scanned:
//!
//! - `class(name)` — every class (the cluster pairing + delegate existence test).
//! - `class_selector(class, selector)` — a class's **direct** `methods` plus its
//!   `category_methods` (the legacy `collect_all_selectors` set; *not* the
//!   inheritance-flattened `all_methods`, which the structural detectors never
//!   used — a pattern is detected on the class that *declares* the selectors).
//! - `class_factory_op(class, selector)` — the class's direct **class methods**
//!   that are not initializers (`class_method && !init_method`), the factory
//!   operations; loaded only from direct `methods`, matching the legacy factory
//!   scan of the immutable class's own `methods`.
//! - `protocol(name)` + `protocol_selector(protocol, selector)` — every protocol
//!   and its required + optional methods (the delegate callbacks).

use apianyware_types::ir::Framework;

use crate::program::PatternProgram;

/// Populate the pattern program's base relations from one framework.
pub fn load_framework_facts(prog: &mut PatternProgram, framework: &Framework) {
    for class in &framework.classes {
        prog.class.push((class.name.clone(),));

        // Direct methods: every selector feeds `class_selector`; non-init class
        // methods additionally feed `class_factory_op`.
        for method in &class.methods {
            prog.class_selector
                .push((class.name.clone(), method.selector.clone()));
            if method.class_method && !method.init_method {
                prog.class_factory_op
                    .push((class.name.clone(), method.selector.clone()));
            }
        }
        // Category methods feed `class_selector` only (the legacy
        // `collect_all_selectors` included them; the factory scan did not).
        for group in &class.category_methods {
            for method in &group.methods {
                prog.class_selector
                    .push((class.name.clone(), method.selector.clone()));
            }
        }
    }

    for protocol in &framework.protocols {
        prog.protocol.push((protocol.name.clone(),));
        for method in protocol
            .required_methods
            .iter()
            .chain(&protocol.optional_methods)
        {
            prog.protocol_selector
                .push((protocol.name.clone(), method.selector.clone()));
        }
    }
}

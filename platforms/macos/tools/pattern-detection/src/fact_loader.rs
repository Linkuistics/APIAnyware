//! Load a linked IR [`Framework`] into the pattern program's base facts.
//!
//! Pushes the fact set the five convention detectors need, over the **same**
//! class/selector material the retired `annotate/pattern_detection.rs` scanned:
//!
//! - `class(name)` — every class (the cluster pairing + delegate existence test).
//! - `class_selector(class, selector)` — a class's **direct** `methods`, which
//!   already carries its category methods (extraction merges `category_methods`
//!   into `methods`, `text-undo-surface-gap-k121`) — the legacy `collect_all_selectors`
//!   set; *not* the inheritance-flattened `all_methods`, which the structural
//!   detectors never used — a pattern is detected on the class that *declares*
//!   the selectors.
//! - `class_factory_op(class, selector)` — the class's direct **class methods**
//!   that are not initializers (`class_method && !init_method`) **and not a
//!   category method** (`method.category.is_none()`) — matching the legacy factory
//!   scan, which only ever looked at the primary `@interface`'s methods.
//! - `protocol(name)` + `protocol_selector(protocol, selector)` — every protocol
//!   and its required + optional methods (the delegate callbacks).

use apianyware_types::ir::Framework;

use crate::program::PatternProgram;

/// Populate the pattern program's base relations from one framework.
pub fn load_framework_facts(prog: &mut PatternProgram, framework: &Framework) {
    for class in &framework.classes {
        prog.class.push((class.name.clone(),));

        // Direct methods (own + merged category, `text-undo-surface-gap-k121`):
        // every selector feeds `class_selector`; non-init, non-category class
        // methods additionally feed `class_factory_op`.
        for method in &class.methods {
            prog.class_selector
                .push((class.name.clone(), method.selector.clone()));
            if method.class_method && !method.init_method && method.category.is_none() {
                prog.class_factory_op
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

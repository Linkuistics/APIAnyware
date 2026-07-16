//! Ascent Datalog program for resolution pass (pass 1).
//!
//! Defines base relations (loaded from collected IR) and derived relations
//! computed by fixed-point iteration:
//! - `ancestor` — transitive inheritance
//! - `effective_method` — flattened methods with override detection
//! - `effective_property` — flattened properties with override detection
//! - `returns_retained_method` — Cocoa ownership family detection
//! - `satisfies_protocol_method` — protocol conformance matching

// The `ascent!` macro expands rule bodies into code that clones Copy-typed
// relation fields and produces `()` tail expressions. Clippy cannot see past
// macro boundaries, so these lints fire on generated code we don't own.
#![allow(clippy::clone_on_copy, clippy::unused_unit)]

use ascent::ascent;

use apianyware_datalog::ownership::is_returns_retained;

ascent! {
    pub struct ResolutionProgram;

    // === Base facts (loaded from IR) ===

    relation class_decl(String, String, String);
    relation inherits_from(String, String);
    relation conforms_to(String, String);
    relation method_decl(String, String, bool, bool, bool, bool);
    relation property_decl(String, String, bool, bool, bool);
    relation protocol_decl(String,);
    relation protocol_inherits(String, String);
    // (protocol, selector, is_required, is_class_method, is_init, is_deprecated, is_variadic)
    relation protocol_method(String, String, bool, bool, bool, bool, bool);
    relation protocol_property(String, String, bool);
    relation enum_decl(String,);
    relation enum_value_decl(String, String, i64);
    relation struct_decl(String,);
    relation struct_field_decl(String, String, u32);
    relation function_decl(String,);
    relation constant_decl(String,);

    // === Derived: transitive ancestry ===

    relation ancestor(String, String);

    // Direct parent becomes ancestor
    ancestor(class.clone(), parent.clone()) <--
        inherits_from(class, parent);
    // Transitive: if class inherits from parent, and parent has ancestor,
    // then class has that ancestor
    ancestor(class.clone(), anc.clone()) <--
        inherits_from(class, parent),
        ancestor(parent, anc);

    // === Derived: effective methods (inheritance flattened) ===

    relation effective_method(String, String, bool, bool, bool, bool, String);

    // Own methods: origin is the declaring class
    effective_method(
        class.clone(), sel.clone(), *is_cm, *is_init, *is_dep, *is_var, class.clone()
    ) <--
        method_decl(class, sel, is_cm, is_init, is_dep, is_var);

    // Inherited methods: propagate from parent if not overridden in child.
    // Uses (class, selector, is_class_method) as the override key — instance and
    // class methods are in separate ObjC namespaces.
    effective_method(
        class.clone(), sel.clone(), *is_cm, *is_init, *is_dep, *is_var, origin.clone()
    ) <--
        inherits_from(class, parent),
        effective_method(parent, sel, is_cm, is_init, is_dep, is_var, origin),
        !method_decl(class, sel, is_cm, _, _, _);

    // === Derived: effective properties (inheritance flattened) ===

    relation effective_property(String, String, bool, bool, bool, String);

    // Own properties
    effective_property(
        class.clone(), name.clone(), *ro, *cp, *dep, class.clone()
    ) <--
        property_decl(class, name, ro, cp, dep);

    // Inherited properties
    effective_property(
        class.clone(), name.clone(), *ro, *cp, *dep, origin.clone()
    ) <--
        inherits_from(class, parent),
        effective_property(parent, name, ro, cp, dep, origin),
        !property_decl(class, name, _, _, _);

    // === Derived: returns retained (ownership detection) ===

    relation returns_retained_method(String, String, bool);

    returns_retained_method(class.clone(), sel.clone(), *is_cm) <--
        effective_method(class, sel, is_cm, _is_init, _is_dep, _is_var, _origin),
        if is_returns_retained(sel, *is_cm);

    // === Derived: protocol conformance ===

    relation satisfies_protocol_method(String, String, bool, String);

    satisfies_protocol_method(class.clone(), sel.clone(), *is_cm, proto.clone()) <--
        effective_method(class, sel, is_cm, _is_init, _is_dep, _is_var, _origin),
        conforms_to(class, proto),
        protocol_method(proto, sel, _is_req, is_cm, _is_init2, _is_dep2, _is_var2);

    // === Derived: transitive protocol conformance ===
    //
    // A class conforms to a protocol either directly (via `conforms_to`) or
    // transitively, when it conforms to a protocol that inherits from another.
    // Used by the protocol-method propagation rule below.

    relation transitively_conforms_to(String, String);

    transitively_conforms_to(class.clone(), proto.clone()) <--
        conforms_to(class, proto);
    transitively_conforms_to(class.clone(), parent_proto.clone()) <--
        transitively_conforms_to(class, child_proto),
        protocol_inherits(child_proto, parent_proto);

    // === Derived: protocol-method propagation into effective_method ===
    //
    // Methods declared on a protocol the class transitively conforms to are
    // available on instances of the class — unless the class declares its own
    // method with the same selector and class/instance kind. The "origin" of
    // the effective_method is set to the protocol name so the checkpoint
    // builder can look up the original protocol method declaration for full
    // metadata (parameters, return type).
    //
    // A class can transitively conform to two protocols that both declare the
    // same selector (e.g. NSTextView satisfies both the modern
    // `NSTextInputClient` and the legacy `NSTextInput`, which both declare
    // `characterIndexForPoint:`) — the ObjC runtime has exactly one method
    // implementation for a given (class, selector), so this must resolve to
    // one `effective_method` row, not two. `has_nondeprecated_protocol_method`
    // lets a non-deprecated declaration always win over a deprecated one from a
    // different protocol; two same-selector declarations of matching
    // deprecation status are a residual, corpus-measured deferral (checkpoint.rs).
    relation has_nondeprecated_protocol_method(String, String, bool);

    has_nondeprecated_protocol_method(class.clone(), sel.clone(), *is_cm) <--
        transitively_conforms_to(class, proto),
        protocol_method(proto, sel, _is_req, is_cm, _is_init, is_dep, _is_var),
        if !*is_dep;

    effective_method(
        class.clone(), sel.clone(), *is_cm, *is_init, *is_dep, *is_var, proto.clone()
    ) <--
        transitively_conforms_to(class, proto),
        protocol_method(proto, sel, _is_req, is_cm, is_init, is_dep, is_var),
        !method_decl(class, sel, is_cm, _, _, _),
        if !*is_dep;

    // A deprecated protocol declaration only wins when no conformed protocol
    // offers a non-deprecated alternative for the same selector.
    effective_method(
        class.clone(), sel.clone(), *is_cm, *is_init, *is_dep, *is_var, proto.clone()
    ) <--
        transitively_conforms_to(class, proto),
        protocol_method(proto, sel, _is_req, is_cm, is_init, is_dep, is_var),
        !method_decl(class, sel, is_cm, _, _, _),
        if *is_dep,
        !has_nondeprecated_protocol_method(class, sel, is_cm);
}

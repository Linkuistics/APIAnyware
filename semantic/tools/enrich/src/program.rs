//! Ascent Datalog program for enrichment pass (pass 2).
//!
//! Defines base relations loaded from annotated IR (type-level facts +
//! annotation facts) and derived relations that emitters consume:
//!
//! **Annotation-derived relations:**
//! - `sync_block_method` — synchronous block parameter (caller frees)
//! - `async_block_method` — async-copied block parameter (runtime-managed)
//! - `stored_block_method` — stored block parameter (called multiple times)
//! - `delegate_protocol` — protocol suitable for typed delegate builder
//! - `convenience_error_method` — method with NSError** out-param
//! - `collection_iterable` — class with indexed access + count
//! - `main_thread_class` — class with main-thread-only methods
//!
//! **Verification rules:**
//! - `violation_unclassified_block` — block param without sync/async/stored classification
//! - `violation_flag_mismatch` — returns_retained flag disagrees with ownership family

// The `ascent!` macro expands rule bodies into code that clones Copy-typed
// relation fields, produces `()` tail expressions, and stamps explicit
// lifetimes on index iterators. Clippy cannot see past macro boundaries, so
// these lints fire on generated code we don't own.
#![allow(clippy::clone_on_copy, clippy::unused_unit, clippy::needless_lifetimes)]

use ascent::ascent;

use apianyware_datalog::ownership::is_returns_retained;

ascent! {
    pub struct EnrichmentProgram;

    // =======================================================================
    // Base facts (loaded from annotated IR — type-level)
    // =======================================================================

    /// class_decl(class_name, superclass, framework)
    relation class_decl(String, String, String);

    /// inherits_from(child_class, parent_class)
    relation inherits_from(String, String);

    /// conforms_to(class_name, protocol_name)
    relation conforms_to(String, String);

    /// method_decl(class_name, selector, is_class_method, is_init)
    relation method_decl(String, String, bool, bool);

    /// property_decl(class_name, prop_name, is_readonly, is_class_property)
    relation property_decl(String, String, bool, bool);

    /// protocol_decl(protocol_name)
    relation protocol_decl(String,);

    /// protocol_method(protocol_name, selector, is_required, is_class_method)
    relation protocol_method(String, String, bool, bool);

    /// has_block_param(class_name, selector, param_index) — method has a block-typed parameter
    relation has_block_param(String, String, u32);

    /// method_returns_object(class_name, selector, is_class_method) — method returns an ObjC object
    relation method_returns_object(String, String, bool);

    /// returns_retained_from_resolve(class_name, selector, is_class_method) — from resolve step
    relation returns_retained_from_resolve(String, String, bool);

    /// resolve_processed_method(class, selector, is_class_method) — method has explicit returns_retained
    relation resolve_processed_method(String, String, bool);

    // =======================================================================
    // Base facts (loaded from annotations)
    // =======================================================================

    /// block_is_synchronous(class, selector, param_index)
    relation block_is_synchronous(String, String, u32);

    /// block_is_async_copied(class, selector, param_index)
    relation block_is_async_copied(String, String, u32);

    /// block_is_stored(class, selector, param_index)
    relation block_is_stored(String, String, u32);

    /// main_thread_only(class, selector) — method must be called on main thread
    relation main_thread_only(String, String);

    /// method_has_error_outparam(class, selector) — method has NSError** out-param
    relation method_has_error_outparam(String, String);

    /// weak_param(class, selector, param_index) — parameter is weak reference
    relation weak_param(String, String, u32);

    // =======================================================================
    // Derived: enrichment relations
    // =======================================================================

    // --- Block method classification (lift annotations) ---

    relation sync_block_method(String, String, u32);
    sync_block_method(class.clone(), sel.clone(), *idx) <--
        block_is_synchronous(class, sel, idx);

    relation async_block_method(String, String, u32);
    async_block_method(class.clone(), sel.clone(), *idx) <--
        block_is_async_copied(class, sel, idx);

    relation stored_block_method(String, String, u32);
    stored_block_method(class.clone(), sel.clone(), *idx) <--
        block_is_stored(class, sel, idx);

    // --- Convenience error methods ---

    relation convenience_error_method(String, String);
    convenience_error_method(class.clone(), sel.clone()) <--
        method_has_error_outparam(class, sel);

    // --- Main thread class: if any method on a class is main-thread-only ---

    relation main_thread_class(String);
    main_thread_class(class.clone()) <--
        main_thread_only(class, _sel);

    // --- Collection iterable: class has objectAtIndex: + count property ---

    relation has_indexed_access(String);
    has_indexed_access(class.clone()) <--
        method_decl(class, sel, is_cm, _is_init),
        if !*is_cm && sel == "objectAtIndex:";

    relation has_count_property(String);
    has_count_property(class.clone()) <--
        property_decl(class, name, _ro, _cp),
        if name == "count";

    relation collection_iterable(String);
    // Class with objectAtIndex: + count
    collection_iterable(class.clone()) <--
        has_indexed_access(class),
        has_count_property(class);
    // Class conforming to NSFastEnumeration
    collection_iterable(class.clone()) <--
        conforms_to(class, proto),
        if proto == "NSFastEnumeration";

    // --- Delegate protocol: protocol that has a class with setDelegate: + matching protocol ---

    relation has_set_delegate(String, String);
    has_set_delegate(class.clone(), proto.clone()) <--
        method_decl(class, sel, is_cm, _is_init),
        if !*is_cm && sel == "setDelegate:",
        conforms_to(class, proto),
        if proto.ends_with("Delegate");

    relation delegate_protocol(String);
    delegate_protocol(proto.clone()) <--
        has_set_delegate(_class, proto);
    // Also: protocols ending in DataSource with a setDataSource: method
    delegate_protocol(proto.clone()) <--
        method_decl(class, sel, is_cm, _is_init),
        if !*is_cm && sel == "setDataSource:",
        conforms_to(class, proto),
        if proto.ends_with("DataSource");

    // =======================================================================
    // Verification rules
    // =======================================================================

    // --- Every block param should have a classification ---

    relation block_classified(String, String, u32);
    block_classified(class.clone(), sel.clone(), *idx) <--
        block_is_synchronous(class, sel, idx);
    block_classified(class.clone(), sel.clone(), *idx) <--
        block_is_async_copied(class, sel, idx);
    block_classified(class.clone(), sel.clone(), *idx) <--
        block_is_stored(class, sel, idx);

    relation violation_unclassified_block(String, String, u32);
    violation_unclassified_block(class.clone(), sel.clone(), *idx) <--
        has_block_param(class, sel, idx),
        !block_classified(class, sel, idx);

    // --- Returns-retained flag mismatch ---
    // If resolve step says returns_retained but naming convention disagrees,
    // or vice versa. This catches annotation/resolve inconsistencies.

    relation returns_retained_by_naming(String, String, bool);
    returns_retained_by_naming(class.clone(), sel.clone(), *is_cm) <--
        method_decl(class, sel, is_cm, _is_init),
        if is_returns_retained(sel, *is_cm);

    relation violation_flag_mismatch(String, String);
    // Resolve says retained but naming says no
    violation_flag_mismatch(class.clone(), sel.clone()) <--
        returns_retained_from_resolve(class, sel, is_cm),
        !returns_retained_by_naming(class, sel, is_cm);
    // Naming says retained but resolve explicitly says not retained
    // (only for methods that resolve actually processed — a category method
    // is included here too, since extraction merges it into `class.methods`
    // and resolve now computes a real retained-fact for it,
    // `text-undo-surface-gap-k121`; this guard still excludes any method
    // resolve genuinely never derived a fact for)
    violation_flag_mismatch(class.clone(), sel.clone()) <--
        returns_retained_by_naming(class, sel, is_cm),
        resolve_processed_method(class, sel, is_cm),
        !returns_retained_from_resolve(class, sel, is_cm);
}

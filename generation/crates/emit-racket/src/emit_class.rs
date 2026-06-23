//! Racket class file code generation.
//!
//! Produces a single `.rkt` file for an ObjC class, including:
//! - Module header (requires, framework loading)
//! - Shared typed objc_msgSend bindings
//! - Constructor wrappers (init methods)
//! - Property accessors (getters + setters)
//! - Method wrappers (instance + class methods)

use std::collections::HashSet;

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::ffi_type_mapping::{FfiTypeMapper, RacketFfiTypeMapper};
use apianyware_macos_emit::naming::{camel_to_kebab, class_name_to_lowercase};
use apianyware_macos_emit::write_line;
use apianyware_macos_types::enrichment::EnrichmentData;
use apianyware_macos_types::ir::{Class, Method, Param, Property, Struct};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

use crate::emit_functions::map_contract;
use crate::enrichment_comments::EnrichmentNotes;
use crate::method_filter::{
    all_params_are_object_type, is_supported_method, returns_object_type, returns_void,
};
use crate::naming::{
    make_class_method_name, make_class_property_getter_name, make_class_property_setter_name,
    make_constructor_name, make_method_name, make_property_getter_name, make_property_setter_name,
    make_swift_init_name, make_swift_method_name, make_unique_constructor_name,
};
use crate::native_dispatch::{
    class_error_selectors, collect_class_native_sigs, is_error_out_routable,
    native_dispatch_binding, native_dispatch_error_binding, GeoStruct, NativeSig,
};
use crate::shared_signatures::{
    block_ffi_types, class_has_blocks, class_has_struct_types, collect_class_fallback_signatures,
    SignatureMap,
};
use crate::trampoline::{classify_method, introduced_macos, MethodDisposition, AW_ARROW_REQUIRE};

/// The rendered receiver-handle trampoline bindings (ADR-0030) for one type's
/// declared Swift-native methods/inits (`objc_exposed == false`), plus the require
/// flags they imply. Computed once so the header can declare the right requires and
/// `provide` can list the exact binding names.
struct SwiftNativeBindings {
    /// One per emitted binding: (`provide` name, rendered `(define …)`, is-async).
    entries: Vec<SwiftNativeBinding>,
}

struct SwiftNativeBinding {
    name: String,
    define: String,
    is_async: bool,
}

impl SwiftNativeBindings {
    fn names(&self) -> impl Iterator<Item = &String> {
        self.entries.iter().map(|e| &e.name)
    }
    fn has(&self, name: &str) -> bool {
        self.entries.iter().any(|e| e.name == name)
    }
    fn is_empty(&self) -> bool {
        self.entries.is_empty()
    }
    /// Any trampoline present ⇒ the file requires `swift-trampoline.rkt` (`_aw-lib`,
    /// `aw-call/error`, `aw-string-*`) and the `aw->` arrow alias.
    fn needs_trampoline(&self) -> bool {
        !self.entries.is_empty()
    }
    /// Any `async` method present ⇒ also requires `async-bridge.rkt` (`aw-async-call`).
    fn needs_async_bridge(&self) -> bool {
        self.entries.iter().any(|e| e.is_async)
    }
    /// Drop bindings whose Racket name collides with an already-bound ObjC name
    /// (the ObjC binding wins — e.g. ObjC `objectForKey:` and Swift `object(forKey:)`
    /// both kebab to `…-object-for-key`). The ObjC path usually provides equivalent
    /// behaviour; the dropped Swift duplicate is a generation detail (the Swift-side
    /// trampoline residual is unchanged).
    fn exclude(&mut self, objc_names: &HashSet<String>) {
        self.entries.retain(|e| !objc_names.contains(&e.name));
    }
}

/// Lambda formal names for a Swift-native method/init: the argument labels, kebabed.
/// A wildcard label (`_`, e.g. `contains(_:)`) becomes a positional `argN` so two
/// wildcard params don't collide as duplicate `lambda` formals.
fn swift_param_names(params: &[Param]) -> Vec<String> {
    params
        .iter()
        .enumerate()
        .map(|(i, p)| {
            if p.name == "_" {
                format!("arg{i}")
            } else {
                camel_to_kebab(&p.name)
            }
        })
        .collect()
}

/// Collect + render the receiver-handle trampoline bindings for a type's declared
/// Swift-native methods/inits (D4 routing). `owner_is_class` picks the reference
/// (`Unmanaged`) vs value (`AwValueBox`) receiver path; it MUST match the global
/// trampoline pass (`collect_trampolines`, which walks `Framework.classes`/`structs`
/// *declared* methods) so every emitted binding references an entry the `@_cdecl`
/// pass actually produces. Overloads that collapse to the same Racket name (distinct
/// content-addressed entries, same base+labels) keep the first — surfaced honestly
/// as a generation detail, the trampoline residual counts are unaffected (Swift side).
fn collect_swift_native_bindings(
    owner: &str,
    framework: &str,
    methods: &[Method],
    owner_is_class: bool,
    value_structs: &HashSet<&str>,
    owner_introduced: Option<&str>,
) -> SwiftNativeBindings {
    let mut entries: Vec<SwiftNativeBinding> = Vec::new();
    let mut seen = HashSet::new();
    for m in methods {
        if m.swift_fn.is_none() {
            continue; // ObjC method — binds via msgSend, no trampoline
        }
        match classify_method(
            framework,
            owner,
            owner_is_class,
            m,
            methods,
            value_structs,
            owner_introduced,
        ) {
            MethodDisposition::Method(t) => {
                let mutating =
                    m.swift_fn.as_ref().and_then(|i| i.self_kind.as_deref()) == Some("Mutating");
                let name = make_swift_method_name(owner, &m.selector, mutating);
                if !seen.insert(name.clone()) {
                    continue;
                }
                let param_names = swift_param_names(&m.params);
                entries.push(SwiftNativeBinding {
                    define: t.render_racket_method(&name, &param_names),
                    is_async: t.is_async(),
                    name,
                });
            }
            MethodDisposition::Init(t) => {
                let name = make_swift_init_name(owner, &m.selector);
                if !seen.insert(name.clone()) {
                    continue;
                }
                let param_names = swift_param_names(&m.params);
                entries.push(SwiftNativeBinding {
                    define: t.render_racket_init(&name, &param_names),
                    is_async: false,
                    name,
                });
            }
            MethodDisposition::Deferred(_) => {} // counted by the global trampoline pass
        }
    }
    SwiftNativeBindings { entries }
}

/// Generate a Racket binding file for a Swift-native **value struct** (population B,
/// D1/D3) — the receiver is a value handle (`AwValueBox`, `owner_is_class = false`),
/// init producers vend the handle, `mutating` methods write back. Returns `None`
/// when the struct has no bindable trampoline (a plain C struct, or every method
/// deferred) so no empty file is written. Unlike a class file there is no ObjC
/// substrate: just `ffi/unsafe` (for `_fun`/`get-ffi-obj`), the trampoline runtime,
/// the `aw->` arrow alias, and `coerce.rkt` (the receiver handle passes through
/// `coerce-arg`).
pub fn generate_struct_file(
    st: &Struct,
    framework: &str,
    value_structs: &HashSet<&str>,
) -> Option<String> {
    let bindings = collect_swift_native_bindings(
        &st.name,
        framework,
        &st.methods,
        false,
        value_structs,
        introduced_macos(&st.provenance).as_deref(),
    );
    if bindings.is_empty() {
        return None;
    }
    let mut w = CodeWriter::new();
    w.line("#lang racket/base");
    write_line!(
        w,
        ";; Generated binding for {} ({}) — Swift-native value struct (ADR-0030)",
        st.name,
        framework
    );
    w.line(";; Do not edit — regenerate from enriched IR");
    w.blank_line();
    // `ffi/unsafe` for `_fun`/`get-ffi-obj`/`_pointer`/scalar ctypes; the trampoline
    // runtime for `_aw-lib`/`aw-call/error`/`aw-string-*`; the `aw->` alias for the
    // `_fun` arrow; `coerce.rkt` for `coerce-arg` (the value handle passes through).
    w.line("(require ffi/unsafe");
    w.raw(&format!("         {AW_ARROW_REQUIRE}\n"));
    w.raw("         \"../../runtime/swift-trampoline.rkt\"\n");
    w.raw("         \"../../runtime/coerce.rkt\"");
    if bindings.needs_async_bridge() {
        w.raw("\n         \"../../runtime/async-bridge.rkt\"");
    }
    w.raw_line(")");
    w.blank_line();
    w.line("(provide");
    for name in bindings.names() {
        write_line!(w, "  {}", name);
    }
    w.line("  )");
    w.blank_line();
    w.line(";; --- Swift-native value-struct methods (receiver-handle trampolines) ---");
    for entry in &bindings.entries {
        w.line(&entry.define);
    }
    Some(w.finish())
}

/// Emit the Swift-native trampoline section (methods + init producers) into a class
/// or struct file, after the ObjC bindings. Idempotent on an empty set.
fn emit_swift_native_section(w: &mut CodeWriter, bindings: &SwiftNativeBindings) {
    if bindings.is_empty() {
        return;
    }
    w.blank_line();
    w.line(";; --- Swift-native methods (receiver-handle trampolines, ADR-0030) ---");
    for entry in &bindings.entries {
        w.line(&entry.define);
    }
}

/// Generate a complete Racket class binding file. Convenience wrapper used by tests
/// and any caller without the framework's value-struct set — equivalent to having
/// no in-framework Swift value structs (a value-struct **param** on a Swift-native
/// method then defers rather than binding, which only affects the method-frontier
/// routing, not the ObjC paths).
pub fn generate_class_file(
    cls: &Class,
    framework: &str,
    enrichment: Option<&EnrichmentData>,
) -> String {
    generate_class_file_with_structs(cls, framework, enrichment, &HashSet::new())
}

/// Generate a complete Racket class binding file, given the owning framework's
/// value-struct name set (`trampoline::value_struct_names(&fw.structs)`). The set is
/// the soundness gate for unboxing a value-struct **parameter** on a Swift-native
/// method (D2/§5c), threaded so the `emit_class` routing classifies methods
/// identically to the global trampoline pass (content-addressed entry agreement).
pub fn generate_class_file_with_structs(
    cls: &Class,
    framework: &str,
    enrichment: Option<&EnrichmentData>,
    value_structs: &HashSet<&str>,
) -> String {
    let mapper = RacketFfiTypeMapper;
    let mut w = CodeWriter::new();
    let notes = EnrichmentNotes::for_class(enrichment, &cls.name);

    let methods = effective_methods(cls);
    let mut properties = effective_properties(cls);

    // Build a set of class method names so we can suppress instance properties
    // that collide. Example: +[NSMenuItem separatorItem] (class factory returning
    // NSMenuItem*) shares the Racket name "nsmenuitem-separator-item" with the
    // instance property "separatorItem" (bool getter). The class method wins
    // because the property's boolean check is already available via isSeparatorItem.
    let class_method_names: std::collections::HashSet<String> = methods
        .iter()
        .filter(|m| m.class_method && !m.init_method)
        .map(|m| make_method_name(&cls.name, &m.selector))
        .collect();

    // Remove instance properties whose getter name collides with a class method
    properties.retain(|p| {
        if p.class_property {
            return true;
        }
        let getter = make_property_getter_name(&cls.name, &p.name);
        !class_method_names.contains(&getter)
    });

    // Build property name sets partitioned by class vs instance level.
    // Class methods only collide with class property names, and instance
    // methods only collide with instance property names. This prevents
    // e.g. +[NSMenuItem separatorItem] (class factory) from being suppressed
    // by the instance property "separatorItem" (boolean getter).
    let prop_names = build_property_name_sets(cls, &properties);

    // Separate method categories. Swift-native methods/inits (`objc_exposed ==
    // false`) are excluded from every ObjC list — they are emitted and `provide`d
    // exclusively by the receiver-handle trampoline section (else the same name is
    // both contracted here and provided there, a duplicate-provide error).
    let init_methods: Vec<&Method> = methods
        .iter()
        .filter(|m| m.init_method && m.objc_exposed)
        .copied()
        .collect();
    let class_methods: Vec<&Method> = methods
        .iter()
        .filter(|m| {
            m.objc_exposed
                && m.class_method
                && !m.init_method
                && !method_collides_with_property(&cls.name, m, &prop_names.class_property_names)
        })
        .copied()
        .collect();
    let instance_methods: Vec<&Method> = methods
        .iter()
        .filter(|m| {
            m.objc_exposed
                && !m.class_method
                && !m.init_method
                && !method_collides_with_property(&cls.name, m, &prop_names.instance_property_names)
        })
        .copied()
        .collect();

    let needs_blocks = class_has_blocks(cls);
    let needs_structs = class_has_struct_types(cls, &mapper);

    // Generated typed native dispatch (ADR-0013): the routable signatures move to
    // thin ffi2 bindings into the native dispatch table; only the non-routable
    // (struct / C-string) remainder keeps a `get-ffi-obj` `_msg-N` fallback. A
    // file routes natively iff it has at least one routable signature; such files
    // switch to the ffi2 header and emit their fallbacks as `_cprocedure` (since
    // the ffi2 header shadows `ffi/unsafe`'s `->`).
    // NSError out-param selectors for this class (leaf 050/040): the analysis
    // stage's `convenience_error_methods`, keyed by (class, selector). Methods in
    // this set route their trailing `NSError **` through the native `…_e` entry
    // and return `(values result error)` instead of threading a caller-allocated
    // cell through interpreted Racket.
    let error_selectors = class_error_selectors(enrichment, &cls.name);
    let native_sigs = collect_class_native_sigs(cls, &mapper, &error_selectors);
    let needs_native = !native_sigs.is_empty();
    let sig_map = collect_class_fallback_signatures(cls, &mapper);

    // Swift-native methods/inits (`objc_exposed == false`) route to receiver-handle
    // trampolines (ADR-0030), not the broken `objc_msgSend` path (charter #4). Walk
    // the class's *declared* methods (owner_is_class = true), matching the global
    // `@_cdecl` pass, so every binding references an entry that exists. Computed up
    // front: the header requires `swift-trampoline.rkt`/`async-bridge.rkt` and the
    // `aw->` arrow alias iff this type emits any trampoline, and `provide` lists the
    // exact binding names.
    let mut swift_native = collect_swift_native_bindings(
        &cls.name,
        framework,
        &cls.methods,
        true,
        value_structs,
        None, // `Class` carries no provenance; class-owned method gates suffice (spec §8.8)
    );

    // Names that must be disambiguated from a same-named instance binding.
    // Example: NSEvent has both @property(class) modifierFlags and
    // @property(readonly) modifierFlags; without disambiguation they emit
    // two `(define)` forms sharing the identifier `nsevent-modifier-flags`,
    // triggering "module: identifier already defined" at load time. The
    // class variant gets a `-class` suffix. Same collision can occur for
    // +selector vs -selector methods.
    let instance_method_names: std::collections::HashSet<String> = instance_methods
        .iter()
        .filter(|m| is_supported_method(m))
        .map(|m| make_method_name(&cls.name, &m.selector))
        .collect();
    let instance_property_names_only: std::collections::HashSet<String> = properties
        .iter()
        .filter(|p| !p.class_property)
        .map(|p| make_property_getter_name(&cls.name, &p.name))
        .collect();
    let instance_bindings: std::collections::HashSet<String> = instance_method_names
        .iter()
        .chain(instance_property_names_only.iter())
        .cloned()
        .collect();
    let class_method_disambig: std::collections::HashSet<String> = class_methods
        .iter()
        .filter(|m| is_supported_method(m))
        .filter(|m| instance_bindings.contains(&make_method_name(&cls.name, &m.selector)))
        .map(|m| m.selector.clone())
        .collect();
    let class_property_disambig: std::collections::HashSet<String> = properties
        .iter()
        .filter(|p| p.class_property)
        .filter(|p| instance_bindings.contains(&make_property_getter_name(&cls.name, &p.name)))
        .map(|p| p.name.clone())
        .collect();

    // A Swift-native `init` producer binds `(make-<class>)`; when present it owns
    // that name, so neither the synthesized default constructor nor its contract
    // export may also claim it.
    let swift_default_ctor = swift_native.has(&make_constructor_name(&cls.name));

    // Build export contracts
    let exports = build_export_contracts(
        cls,
        &properties,
        &init_methods,
        &instance_methods,
        &class_methods,
        &class_method_disambig,
        &class_property_disambig,
        &error_selectors,
        swift_default_ctor,
    );

    // Drop any Swift-native binding whose name collides with an ObjC export (the ObjC
    // binding wins; e.g. ObjC `objectForKey:` vs Swift `object(forKey:)`).
    let objc_names: HashSet<String> = exports.iter().map(|e| e.name.clone()).collect();
    swift_native.exclude(&objc_names);

    // Collect class names for predicates (must be defined before
    // provide/contract references them). Includes the class's own name so
    // the class-specific receiver predicate is always in scope.
    let predicate_class_names = collect_predicate_class_names(
        &cls.name,
        &properties,
        &init_methods,
        &instance_methods,
        &class_methods,
    );

    // Header
    emit_header(
        &mut w,
        &cls.name,
        framework,
        needs_blocks,
        needs_structs,
        needs_native,
        swift_native.needs_trampoline(),
        swift_native.needs_async_bridge(),
    );

    // Threading note: surface main-thread affinity from enrichment data.
    if notes.is_main_thread() {
        w.line(";; Threading: this class has main-thread-only methods.");
    }

    // Class-specific predicates (must precede provide/contract)
    emit_class_predicates(&mut w, &predicate_class_names);

    // Provide with contracts
    emit_provide(&mut w, &cls.name, &exports);

    // Swift-native trampoline bindings are `provide`d plainly (their returns are raw
    // opaque handles / scalars, not contract-carrying values).
    if !swift_native.is_empty() {
        w.line("(provide");
        for name in swift_native.names() {
            write_line!(w, "  {}", name);
        }
        w.line("  )");
        w.blank_line();
    }

    // Class reference
    w.line(";; --- Class reference ---");
    write_line!(w, "(import-class {})", cls.name);

    // Shared msgSend bindings: native dispatch entries (routable) + the
    // `_msg-N` get-ffi-obj fallbacks (non-routable struct/string shapes).
    emit_shared_msg_bindings(&mut w, &native_sigs, &sig_map, needs_native);

    // Constructors. Suppress the synthesized `(make-<class>)` default when a
    // Swift-native `init` producer already binds that name (else the two `(define
    // (make-<class>) …)` forms collide at load).
    let needs_default_constructor = !has_explicit_constructor(&init_methods) && !swift_default_ctor;
    if !init_methods.is_empty() || needs_default_constructor {
        w.line(";; --- Constructors ---");
        for m in &init_methods {
            emit_constructor(
                &mut w,
                &cls.name,
                m,
                &notes,
                &sig_map,
                &mapper,
                needs_native,
            );
        }
        if needs_default_constructor {
            emit_default_constructor(&mut w, &cls.name);
        }
        w.blank_line();
    }

    // Properties
    if !properties.is_empty() {
        w.line(";; --- Properties ---");
        for p in &properties {
            let disambig = p.class_property && class_property_disambig.contains(&p.name);
            emit_property(
                &mut w,
                &cls.name,
                p,
                disambig,
                &sig_map,
                &mapper,
                needs_native,
            );
        }
        w.blank_line();
    }

    // Instance methods
    if !instance_methods.is_empty() {
        w.line(";; --- Instance methods ---");
        for m in &instance_methods {
            emit_method(
                &mut w,
                &cls.name,
                m,
                false,
                false,
                &notes,
                &sig_map,
                &mapper,
                needs_native,
                &error_selectors,
                framework,
                &cls.methods,
                value_structs,
            );
        }
    }

    // Class methods
    if !class_methods.is_empty() {
        w.blank_line();
        w.line(";; --- Class methods ---");
        for m in &class_methods {
            let disambig = class_method_disambig.contains(&m.selector);
            emit_method(
                &mut w,
                &cls.name,
                m,
                true,
                disambig,
                &notes,
                &sig_map,
                &mapper,
                needs_native,
                &error_selectors,
                framework,
                &cls.methods,
                value_structs,
            );
        }
    }

    // Swift-native methods + init producers (receiver-handle trampolines, ADR-0030).
    emit_swift_native_section(&mut w, &swift_native);

    w.finish()
}

/// Determine if a method returns a retained (+1) object per Cocoa naming conventions.
fn method_returns_retained(method: &Method) -> bool {
    // Use the IR's computed value if available (from resolve step)
    if let Some(retained) = method.returns_retained {
        return retained;
    }
    // Fall back to naming convention heuristic
    let sel = &method.selector;
    let is_cm = method.class_method;

    if !is_cm && is_family_match(sel, "init") {
        return true;
    }
    if is_cm && is_family_match(sel, "new") {
        return true;
    }
    is_family_match(sel, "copy") || is_family_match(sel, "mutableCopy")
}

/// Check if a selector belongs to a method family.
fn is_family_match(selector: &str, family: &str) -> bool {
    if selector == family {
        return true;
    }
    if selector.len() > family.len() && selector.starts_with(family) {
        let next = selector.as_bytes()[family.len()];
        return next.is_ascii_uppercase() || next == b':' || next == b'(';
    }
    false
}

fn effective_methods(cls: &Class) -> Vec<&Method> {
    let methods: Vec<&Method> = if cls.all_methods.is_empty() {
        cls.methods.iter().collect()
    } else {
        cls.all_methods.iter().collect()
    };
    // Deduplicate by selector — category merging or inheritance flattening
    // can produce duplicate entries for the same selector
    let mut seen = std::collections::HashSet::new();
    methods
        .into_iter()
        .filter(|m| seen.insert(m.selector.clone()))
        .collect()
}

fn effective_properties(cls: &Class) -> Vec<&Property> {
    let properties: Vec<&Property> = if cls.all_properties.is_empty() {
        cls.properties.iter().collect()
    } else {
        cls.all_properties.iter().collect()
    };
    // Deduplicate by generated Racket getter name — ObjC and Swift extractors
    // can produce the same property with different casing (e.g. "CGDirectDisplayID"
    // vs "cgDirectDisplayID"), which both map to the same Racket identifier.
    let mut seen = std::collections::HashSet::new();
    properties
        .into_iter()
        .filter(|p| seen.insert(make_property_getter_name(&cls.name, &p.name)))
        .collect()
}

/// Property name sets partitioned by class vs instance level.
struct PropertyNameSets {
    class_property_names: std::collections::HashSet<String>,
    instance_property_names: std::collections::HashSet<String>,
}

fn build_property_name_sets(cls: &Class, properties: &[&Property]) -> PropertyNameSets {
    let mut class_names = std::collections::HashSet::new();
    let mut instance_names = std::collections::HashSet::new();
    for p in properties {
        let target = if p.class_property {
            &mut class_names
        } else {
            &mut instance_names
        };
        target.insert(make_property_getter_name(&cls.name, &p.name));
        if !p.readonly {
            target.insert(make_property_setter_name(&cls.name, &p.name));
        }
    }
    PropertyNameSets {
        class_property_names: class_names,
        instance_property_names: instance_names,
    }
}

fn method_collides_with_property(
    class_name: &str,
    method: &Method,
    property_names: &std::collections::HashSet<String>,
) -> bool {
    let fn_name = make_method_name(class_name, &method.selector);
    property_names.contains(&fn_name)
}

// --- Contracts ---

// The receiver (`self`) contract for instance-method wrappers, instance
// property getters, and instance property setters is the class-specific
// predicate produced by `make_class_predicate_name` (e.g. `tkbutton?` for
// class `TKButton`). Using the class-specific predicate instead of the
// generic `objc-object?` catches "you passed the wrong object class" at
// the contract boundary, giving precise blame attribution. The predicate
// is always defined before the `provide/contract` block because
// `collect_predicate_class_names` unconditionally inserts the class's own
// name into the set fed to `emit_class_predicates` (which is emitted
// before `emit_provide`). Every generated file has `objc-instance-of?` in
// scope via `objc-base.rkt` (re-exported by `coerce.rkt`).

/// Map a TypeRef to a contract for class wrapper parameter position.
///
/// Unlike `map_contract` (for C FFI boundaries), this accounts for
/// `coerce-arg` flexibility (accepts strings, objc-objects, pointers)
/// and block wrapping (accepts Racket procedures).
///
/// Object-shaped params (`Class`/`Id`/`Instancetype`) emit a union that
/// exactly mirrors `coerce-arg`'s accepted set in `runtime/coerce.rkt`:
/// `string?`, `objc-object?`, `cpointer?`, plus `#f` when the IR marks
/// the param nullable. The tight union replaces the old `any/c` so
/// numbers, symbols, and lists are rejected at the wrapper boundary
/// with caller blame instead of surfacing as a deeper `coerce-arg`
/// error.
fn map_param_contract(type_ref: &TypeRef) -> String {
    match &type_ref.kind {
        // Object params always accept #f (nil) — ObjC nil messaging is a
        // no-op, and many APIs accept nil even without explicit _Nullable.
        // coerce-arg passes #f through as the nil pointer.
        TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => {
            "(or/c string? objc-object? #f)".to_string()
        }
        // Block params receive Racket procedures (or #f for nil)
        TypeRefKind::Block { .. } => "(or/c procedure? #f)".to_string(),
        // Selector params accept strings — wrapper calls sel_registerName internally
        TypeRefKind::Selector => "string?".to_string(),
        // Everything else delegates to the standard contract mapper
        _ => map_contract(type_ref, false),
    }
}

/// Map a TypeRef to a contract for class wrapper return position.
///
/// `TypeRefKind::Class { name }` emits a class-specific predicate (e.g. `nsview?`)
/// that checks `isKindOfClass:` at runtime. Object returns are permitted to be
/// nil by default: many Cocoa properties (PDFView.document, NSTableView.dataSource,
/// NSWindow.firstResponder, …) legitimately return nil until the object is
/// configured, so the contract is `(or/c <class-pred>? objc-nil?)` unless the
/// IR explicitly marks the return as `_Nonnull`.
fn map_return_contract(type_ref: &TypeRef) -> String {
    match &type_ref.kind {
        TypeRefKind::Class { name, .. } => {
            let pred = format!("{}?", class_name_to_lowercase(name));
            format!("(or/c {pred} objc-nil?)")
        }
        TypeRefKind::Id | TypeRefKind::Instancetype => "any/c".to_string(),
        _ => map_contract(type_ref, true),
    }
}

/// Make the predicate name for a class: "NSView" → "nsview?".
fn make_class_predicate_name(class_name: &str) -> String {
    format!("{}?", class_name_to_lowercase(class_name))
}

/// The contract for the **error** component of an NSError out-param wrapper's
/// `(values result error)` result: a wrapped `NSError` object, or `#f` when the
/// method reported no error. `objc-object?` is in scope via `objc-base.rkt`
/// (re-exported by `coerce.rkt`).
const ERROR_VALUE_CONTRACT: &str = "(or/c objc-object? #f)";

/// Whether `method`'s trailing `NSError **` routes through the native error-out
/// entry (leaf 050/040), so the wrapper drops it from its arity and returns
/// `(values result error)`. Mirrors [`is_error_out_routable`] over the method's
/// mapped param/return spellings.
fn method_routes_error_out(
    method: &Method,
    mapper: &dyn FfiTypeMapper,
    error_selectors: &std::collections::HashSet<String>,
) -> bool {
    let param_types: Vec<String> = method
        .params
        .iter()
        .map(|p| mapper.map_type(&p.param_type, false))
        .collect();
    let ret = mapper.map_type(&method.return_type, true);
    is_error_out_routable(&param_types, &ret, &method.selector, error_selectors)
}

/// The parameters the Racket wrapper actually exposes: all of `method`'s params,
/// minus the trailing `NSError **` when it routes natively (the error crossing is
/// owned by the native entry). For every other method this is just `&method.params`.
fn visible_params<'a>(
    method: &'a Method,
    mapper: &dyn FfiTypeMapper,
    error_selectors: &std::collections::HashSet<String>,
) -> &'a [Param] {
    if method_routes_error_out(method, mapper, error_selectors) {
        &method.params[..method.params.len() - 1]
    } else {
        &method.params
    }
}

/// Collect class names that need predicate definitions in the generated file.
///
/// Includes:
/// - The class's own name, so the class-specific receiver contract (`<class>?`)
///   is always defined before the `provide/contract` block references it.
/// - Names referenced in return types of properties and methods, so return
///   contracts like `(or/c nsview? objc-nil?)` resolve correctly.
///
/// Returns a sorted, deduplicated `Vec` (BTreeSet dedup is automatic).
fn collect_predicate_class_names(
    own_class_name: &str,
    properties: &[&Property],
    init_methods: &[&Method],
    instance_methods: &[&Method],
    class_methods: &[&Method],
) -> Vec<String> {
    let mut names = std::collections::BTreeSet::new();
    names.insert(own_class_name.to_string());
    for p in properties {
        if let TypeRefKind::Class { name, .. } = &p.property_type.kind {
            names.insert(name.clone());
        }
    }
    let all_methods = init_methods
        .iter()
        .chain(instance_methods.iter())
        .chain(class_methods.iter());
    for m in all_methods {
        if let TypeRefKind::Class { name, .. } = &m.return_type.kind {
            names.insert(name.clone());
        }
    }
    names.into_iter().collect()
}

/// Emit inline predicate definitions for class-specific return contracts.
/// Each predicate is backed by `objc-instance-of?` from `objc-base.rkt`.
fn emit_class_predicates(w: &mut CodeWriter, class_names: &[String]) {
    if class_names.is_empty() {
        return;
    }
    w.blank_line();
    w.line(";; --- Class predicates ---");
    for name in class_names {
        let pred = make_class_predicate_name(name);
        write_line!(w, "(define ({pred} v) (objc-instance-of? v \"{name}\"))");
    }
}

/// Format an arrow contract: `(c-> param-contracts... return-contract)`.
///
/// Uses the locally-renamed `c->` instead of `->` to avoid colliding with
/// `ffi/unsafe`'s `->`, which is a literal in `(_fun ... -> ...)` FFI signatures.
/// The rename-in at the top of each generated file maps `racket/contract`'s `->`
/// to `c->`.
fn format_arrow_contract(params: &[String], return_contract: &str) -> String {
    if params.is_empty() {
        format!("(c-> {return_contract})")
    } else {
        format!("(c-> {} {return_contract})", params.join(" "))
    }
}

/// An exported symbol with its contract.
struct ExportContract {
    name: String,
    contract: String,
}

/// Collect all exported symbols and their contracts for a class.
#[allow(clippy::too_many_arguments)]
fn build_export_contracts(
    cls: &Class,
    properties: &[&Property],
    init_methods: &[&Method],
    instance_methods: &[&Method],
    class_methods: &[&Method],
    class_method_disambig: &std::collections::HashSet<String>,
    class_property_disambig: &std::collections::HashSet<String>,
    error_selectors: &std::collections::HashSet<String>,
    swift_default_ctor: bool,
) -> Vec<ExportContract> {
    let mut exports = Vec::new();
    let self_predicate = make_class_predicate_name(&cls.name);
    let mapper = RacketFfiTypeMapper;

    // Constructors: (-> param-contracts... cpointer?)
    for m in init_methods {
        if !is_supported_method(m) || m.selector == "init" {
            continue;
        }
        let name = make_unique_constructor_name(&cls.name, &m.selector);
        let param_contracts: Vec<String> = m
            .params
            .iter()
            .map(|p| map_param_contract(&p.param_type))
            .collect();
        let contract = format_arrow_contract(&param_contracts, "any/c");
        exports.push(ExportContract { name, contract });
    }

    // Synthesized default constructor: (-> any/c) when no explicit init in IR.
    // 73% of classes inherit -init from NSObject without overriding it; without
    // synthesis those classes have no constructor and callers must drop into
    // objc-interop's alloc+init escape hatch.
    if !has_explicit_constructor(init_methods) && !swift_default_ctor {
        let name = make_constructor_name(&cls.name);
        let contract = format_arrow_contract(&[], "any/c");
        exports.push(ExportContract { name, contract });
    }

    // Properties
    for p in properties {
        let disambig = p.class_property && class_property_disambig.contains(&p.name);
        // Getter
        let getter = if p.class_property {
            make_class_property_getter_name(&cls.name, &p.name, disambig)
        } else {
            make_property_getter_name(&cls.name, &p.name)
        };
        let return_contract = map_return_contract(&p.property_type);
        let contract = if p.class_property {
            format_arrow_contract(&[], &return_contract)
        } else {
            format_arrow_contract(std::slice::from_ref(&self_predicate), &return_contract)
        };
        exports.push(ExportContract {
            name: getter,
            contract,
        });

        // Setter (if not readonly)
        if !p.readonly {
            let setter = if p.class_property {
                make_class_property_setter_name(&cls.name, &p.name, disambig)
            } else {
                make_property_setter_name(&cls.name, &p.name)
            };
            let value_contract = map_param_contract(&p.property_type);
            let self_arg = if p.class_property {
                vec![]
            } else {
                vec![self_predicate.clone()]
            };
            let mut params = self_arg;
            params.push(value_contract);
            let contract = format_arrow_contract(&params, "void?");
            exports.push(ExportContract {
                name: setter,
                contract,
            });
        }
    }

    // Instance methods: (-> <class>? param-contracts... return-contract).
    // An NSError out-param method drops its trailing `NSError **` from the arity
    // and returns `(values result error)` (leaf 050/040).
    for m in instance_methods {
        if !is_supported_method(m) {
            continue;
        }
        let name = make_method_name(&cls.name, &m.selector);
        let vparams = visible_params(m, &mapper, error_selectors);
        let mut param_contracts = vec![self_predicate.clone()];
        param_contracts.extend(vparams.iter().map(|p| map_param_contract(&p.param_type)));
        let return_contract = method_return_contract(m, &mapper, error_selectors);
        let contract = format_arrow_contract(&param_contracts, &return_contract);
        exports.push(ExportContract { name, contract });
    }

    // Class methods: (-> param-contracts... return-contract)
    for m in class_methods {
        if !is_supported_method(m) {
            continue;
        }
        let name = make_class_method_name(
            &cls.name,
            &m.selector,
            class_method_disambig.contains(&m.selector),
        );
        let vparams = visible_params(m, &mapper, error_selectors);
        let param_contracts: Vec<String> = vparams
            .iter()
            .map(|p| map_param_contract(&p.param_type))
            .collect();
        let return_contract = method_return_contract(m, &mapper, error_selectors);
        let contract = format_arrow_contract(&param_contracts, &return_contract);
        exports.push(ExportContract { name, contract });
    }

    exports
}

/// The wrapper's return contract for a method: its normal return contract, or —
/// for an NSError out-param method — the `(values result error)` contract.
fn method_return_contract(
    method: &Method,
    mapper: &dyn FfiTypeMapper,
    error_selectors: &std::collections::HashSet<String>,
) -> String {
    let result = map_return_contract(&method.return_type);
    if method_routes_error_out(method, mapper, error_selectors) {
        format!("(values {result} {ERROR_VALUE_CONTRACT})")
    } else {
        result
    }
}

// --- Header ---

#[allow(clippy::too_many_arguments)]
fn emit_header(
    w: &mut CodeWriter,
    class_name: &str,
    framework: &str,
    needs_blocks: bool,
    needs_structs: bool,
    needs_native: bool,
    needs_trampoline: bool,
    needs_async_bridge: bool,
) {
    w.line("#lang racket/base");
    write_line!(w, ";; Generated binding for {} ({})", class_name, framework);
    w.line(";; Do not edit — regenerate from enriched IR");
    w.blank_line();

    if needs_native {
        // Native-dispatch (ADR-0013) header. ffi2 (via ffi2-dispatch.rkt) owns the
        // `->` arrow needed for the native binding arrow types; `ffi/unsafe`'s `->`
        // is dropped with `except-in` (the spike's `->` discipline — renaming on
        // ffi2's side breaks its nested-arrow parsing), so any retained
        // `get-ffi-obj` fallback uses `_cprocedure`, not `_fun`. `ffi/unsafe/objc`
        // stays for `import-class`/`tell`/`sel_registerName`; `racket/contract`'s
        // `->` is renamed to `c->`.
        w.line("(require \"../../runtime/ffi2-dispatch.rkt\"");
        w.raw("         (except-in ffi/unsafe ->)\n");
        w.raw("         ffi/unsafe/objc\n");
        w.raw("         (rename-in racket/contract [-> c->])\n");
        w.raw("         \"../../runtime/objc-base.rkt\"\n");
        w.raw("         \"../../runtime/coerce.rkt\"");
    } else {
        w.line("(require ffi/unsafe");
        w.raw("         ffi/unsafe/objc\n");
        // `racket/contract` and `ffi/unsafe` both export `->` with different
        // semantics (contract arrow vs `_fun` type arrow). Rename the contract
        // arrow to `c->` so both are usable in the same module.
        w.raw("         (rename-in racket/contract [-> c->])\n");
        w.raw("         \"../../runtime/objc-base.rkt\"\n");
        w.raw("         \"../../runtime/coerce.rkt\"");
    }
    if needs_blocks {
        w.raw("\n         \"../../runtime/block.rkt\"");
    }
    if needs_structs {
        w.raw("\n         \"../../runtime/type-mapping.rkt\"");
    }
    // Swift-native method/init trampolines (ADR-0030): `swift-trampoline.rkt` provides
    // `_aw-lib`/`aw-call/error`/`aw-string-*`; `async-bridge.rkt` provides
    // `aw-async-call`. The trampoline `_fun` arrows are spelled `aw->` so they survive
    // the native-dispatch header's `(except-in ffi/unsafe ->)` (`_fun` matches the
    // renamed arrow by binding identity) — the alias is imported regardless of native.
    if needs_trampoline {
        w.raw("\n         \"../../runtime/swift-trampoline.rkt\"");
        w.raw(&format!("\n         {AW_ARROW_REQUIRE}"));
        if needs_async_bridge {
            w.raw("\n         \"../../runtime/async-bridge.rkt\"");
        }
    }
    w.raw_line(")");
    w.blank_line();
    w.line(";; Load framework and ObjC runtime");
    write_line!(
        w,
        "(define _fw-lib (ffi-lib \"/System/Library/Frameworks/{0}.framework/{0}\"))",
        framework
    );
    w.line("(define _objc-lib (ffi-lib \"libobjc\"))");
    w.blank_line();
}

// --- Provide ---

fn emit_provide(w: &mut CodeWriter, class_name: &str, exports: &[ExportContract]) {
    // The class reference itself (bound by `import-class` below) is exported
    // via plain `provide` — it's a syntactic binding, not a value that can
    // carry a contract, and callers need it for raw `tell` on methods that
    // aren't generated or that bypass the wrappers.
    write_line!(w, "(provide {})", class_name);
    if exports.is_empty() {
        w.blank_line();
        return;
    }
    w.line("(provide/contract");
    for export in exports {
        write_line!(w, "  [{} {}]", export.name, export.contract);
    }
    w.line("  )");
    w.blank_line();
}

// --- Shared msgSend bindings ---

fn emit_shared_msg_bindings(
    w: &mut CodeWriter,
    native_sigs: &std::collections::BTreeSet<NativeSig>,
    sig_map: &SignatureMap,
    needs_native: bool,
) {
    if native_sigs.is_empty() && sig_map.is_empty() {
        w.blank_line();
        return;
    }

    w.blank_line();

    // Native dispatch bindings (ADR-0013): one thin ffi2 binding per routable
    // signature into the generated `aw_racket_msg_<code>` entry.
    if !native_sigs.is_empty() {
        w.line(";; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---");
        for sig in native_sigs {
            write_line!(
                w,
                "(define-aw-msg {} {})",
                sig.entry_name(),
                sig.ffi2_arrow()
            );
        }
    }

    // Retained `get-ffi-obj` fallbacks for the non-routable (struct / C-string)
    // signatures. In a native-dispatch file `ffi/unsafe`'s `->` is shadowed by
    // ffi2's, so the fallback uses `_cprocedure`; otherwise the historical `_fun`
    // form (byte-identical to pre-ADR-0013 output for non-native files).
    if !sig_map.is_empty() {
        w.line(";; --- Shared typed objc_msgSend bindings ---");
        for (key, id) in sig_map.iter_sorted() {
            let (param_str, ret_str) = SignatureMap::parse_key(key);
            let param_types: Vec<&str> = if param_str.is_empty() {
                vec![]
            } else {
                param_str.split(' ').collect()
            };

            if needs_native {
                // `_cprocedure` form (no `->` token).
                let mut comment = format!("(define _msg-{id}  ; (objc_msgSend _pointer _pointer");
                for pt in &param_types {
                    comment.push(' ');
                    comment.push_str(pt);
                }
                comment.push_str(&format!(" -> {ret_str})"));
                w.line(&comment);

                let mut binding = String::from(
                    "  (get-ffi-obj \"objc_msgSend\" _objc-lib (_cprocedure (list _pointer _pointer",
                );
                for pt in &param_types {
                    binding.push(' ');
                    binding.push_str(pt);
                }
                binding.push_str(&format!(") {ret_str})))"));
                w.line(&binding);
            } else {
                // Historical `_fun` form.
                let mut comment = format!("(define _msg-{id}  ; (_fun _pointer _pointer");
                for pt in &param_types {
                    comment.push(' ');
                    comment.push_str(pt);
                }
                comment.push_str(&format!(" -> {ret_str})"));
                w.line(&comment);

                let mut binding = String::from(
                    "  (get-ffi-obj \"objc_msgSend\" _objc-lib (_fun _pointer _pointer",
                );
                for pt in &param_types {
                    binding.push(' ');
                    binding.push_str(pt);
                }
                binding.push_str(&format!(" -> {ret_str})))"));
                w.line(&binding);
            }
        }
    }
    w.blank_line();
}

// --- Constructors ---

/// True when at least one init method in the IR would be emitted as an
/// explicit `make-<class>-<selector>` constructor. Bare `init` is excluded
/// because `emit_constructor` skips it; unsupported selectors (Swift parens,
/// variadic, etc.) are also excluded so the emit-time skip stays in sync.
fn has_explicit_constructor(init_methods: &[&Method]) -> bool {
    init_methods
        .iter()
        .any(|m| is_supported_method(m) && m.selector != "init")
}

/// Emit a synthesized default constructor for a class whose IR carries no
/// explicit init beyond bare `-init`. Calls the inherited NSObject
/// `[Class alloc] init]` and wraps with the +1-retained finalizer plumbing.
fn emit_default_constructor(w: &mut CodeWriter, class_name: &str) {
    let fn_name = make_constructor_name(class_name);
    write_line!(w, "(define ({fn_name})");
    w.line("  (wrap-objc-object");
    write_line!(w, "   (tell (tell {} alloc) init)", class_name);
    w.line("   #:retained #t))");
    w.blank_line();
}

fn emit_constructor(
    w: &mut CodeWriter,
    class_name: &str,
    method: &Method,
    notes: &EnrichmentNotes,
    sig_map: &SignatureMap,
    mapper: &dyn FfiTypeMapper,
    needs_native: bool,
) {
    // Swift-native inits (`objc_exposed == false`) are init *producers* — emitted by
    // the receiver-handle trampoline section, not the ObjC `alloc/init` path.
    if !method.objc_exposed {
        return;
    }
    if !is_supported_method(method) || method.selector == "init" {
        return;
    }

    emit_enrichment_notes(w, notes, &method.selector);

    let param_names: Vec<String> = method
        .params
        .iter()
        .map(|p| camel_to_kebab(&p.name))
        .collect();
    let fn_name = make_unique_constructor_name(class_name, &method.selector);

    // Function signature
    let mut sig = format!("(define ({fn_name}");
    for pn in &param_names {
        sig.push(' ');
        sig.push_str(pn);
    }
    sig.push(')');
    w.line(&sig);

    if all_params_are_object_type(&method.params, mapper) {
        // Tell path
        let tell_args = format_tell_args(&method.selector, &param_names, &method.params);
        w.line("  (wrap-objc-object");
        write_line!(w, "   (tell (tell {} alloc)", class_name);
        write_line!(w, "         {})", tell_args);
        w.line("   #:retained #t))");
    } else {
        // Typed objc_msgSend path
        emit_typed_constructor(
            w,
            class_name,
            method,
            &param_names,
            sig_map,
            mapper,
            needs_native,
        );
    }
    w.blank_line();
}

fn emit_typed_constructor(
    w: &mut CodeWriter,
    class_name: &str,
    method: &Method,
    param_names: &[String],
    sig_map: &SignatureMap,
    mapper: &dyn FfiTypeMapper,
    needs_native: bool,
) {
    let param_types: Vec<String> = method
        .params
        .iter()
        .map(|p| mapper.map_type(&p.param_type, false))
        .collect();

    let mut call_args: Vec<String> = param_names.to_vec();

    // Block wrapping
    emit_block_wrapping(w, &method.params, &mut call_args, mapper);

    // Coerce id-kind params
    coerce_id_params(&method.params, &mut call_args, mapper);

    // Coerce SEL-typed params (string → sel_registerName)
    coerce_sel_params(&method.params, &mut call_args);

    // Routable init signatures dispatch through the generated native entry
    // (ADR-0013); the receiver is `[Class alloc]`, the result a +1 `_id`.
    if let Some((entry, _arrow)) = native_dispatch_binding(&param_types, "_id") {
        let recv = format!("(tell {class_name} alloc)");
        let call = native_call_expr(&entry, &recv, &method.selector, &call_args, &param_types);
        w.line("  (wrap-objc-object");
        write_line!(w, "   (ffi2-ptr->id {})", call);
        w.line("   #:retained #t))");
        return;
    }

    let shared_name = sig_map.lookup(&param_types, "_id");
    match shared_name {
        Some(name) => {
            w.line("  (wrap-objc-object");
            write_line!(w, "   ({} (tell {} alloc)", name, class_name);
            w.raw(&format!(
                "       (sel_registerName \"{}\")",
                method.selector
            ));
            for arg in &call_args {
                w.raw(&format!("\n       {arg}"));
            }
            w.raw_line(")");
            w.line("   #:retained #t))");
        }
        None => {
            let inline_name = format!(
                "_msg-{}",
                apianyware_macos_emit::naming::selector_to_kebab_name(&method.selector)
                    .replace('-', "_")
            );
            write_line!(w, "  (let ([{}", inline_name);
            w.raw("         (get-ffi-obj \"objc_msgSend\" _objc-lib\n");
            if needs_native {
                w.raw("           (_cprocedure (list _pointer _pointer");
                for pt in &param_types {
                    w.raw(&format!(" {pt}"));
                }
                w.raw_line(") _id))]");
            } else {
                w.raw("           (_fun _pointer _pointer");
                for pt in &param_types {
                    w.raw(&format!(" {pt}"));
                }
                w.raw_line(" -> _id))]");
            }
            w.line("    (wrap-objc-object");
            write_line!(w, "     ({} (tell {} alloc)", inline_name, class_name);
            w.raw(&format!(
                "         (sel_registerName \"{}\")",
                method.selector
            ));
            for arg in &call_args {
                w.raw(&format!("\n         {arg}"));
            }
            w.raw_line(")");
            w.line("     #:retained #t))))");
        }
    }
}

// --- Properties ---

fn emit_property(
    w: &mut CodeWriter,
    class_name: &str,
    prop: &Property,
    disambiguate: bool,
    sig_map: &SignatureMap,
    mapper: &dyn FfiTypeMapper,
    needs_native: bool,
) {
    let getter_name = if prop.class_property {
        make_class_property_getter_name(class_name, &prop.name, disambiguate)
    } else {
        make_property_getter_name(class_name, &prop.name)
    };
    let ffi_type = mapper.map_type(&prop.property_type, false);

    // Getter. Property getters return autoreleased (+0) objects, so no #:retained.
    // Every routable shape (object + scalar) dispatches natively (ADR-0013) since
    // leaf 050/010; struct-typed getters stay on the `tell` get-ffi-obj path until
    // leaf 050/020 marshals structs natively.
    let getter_params = if prop.class_property { "" } else { " self" };
    let getter_recv = if prop.class_property {
        class_name.to_string()
    } else {
        "(coerce-arg self)".to_string()
    };
    if let Some((entry, _arrow)) = native_dispatch_binding(&[], &ffi_type) {
        write_line!(w, "(define ({}{})", getter_name, getter_params);
        if let Some(g) = GeoStruct::from_ffi_unsafe(&ffi_type) {
            // Struct-by-value getter (e.g. `frame`): native out-buffer, hand back
            // the cstruct (see `emit_method`'s struct-return branch).
            let cstruct = g.racket_cstruct();
            let call = native_call_expr_with_out(
                &entry,
                &getter_recv,
                &prop.name,
                &[],
                &[],
                Some("(cpointer->ptr_t buf)"),
            );
            write_line!(w, "  (let ([buf (malloc {cstruct})])");
            write_line!(w, "    {}", call);
            write_line!(w, "    (ptr-ref buf {cstruct})))");
        } else {
            let call = native_call_expr(&entry, &getter_recv, &prop.name, &[], &[]);
            if ffi_type == "_id" {
                w.line("  (wrap-objc-object");
                write_line!(w, "   (ffi2-ptr->id {})))", call);
            } else {
                write_line!(w, "  {})", native_scalar_result(&call, &ffi_type));
            }
        }
    } else if prop.class_property {
        write_line!(w, "(define ({})", getter_name);
        write_line!(
            w,
            "  (tell #:type {} {} {}))",
            ffi_type,
            class_name,
            prop.name
        );
    } else {
        write_line!(w, "(define ({} self)", getter_name);
        write_line!(
            w,
            "  (tell #:type {} (coerce-arg self) {}))",
            ffi_type,
            prop.name
        );
    }

    // Setter (if not readonly)
    if !prop.readonly {
        let first_char = prop.name.chars().next().unwrap_or('x');
        let setter_sel = format!(
            "set{}{}:",
            first_char.to_uppercase(),
            &prop.name[first_char.len_utf8()..]
        );
        let setter_name = if prop.class_property {
            make_class_property_setter_name(class_name, &prop.name, disambiguate)
        } else {
            make_property_setter_name(class_name, &prop.name)
        };

        // Class-method (static) property setters take no receiver — the
        // class metaobject is the target. Instance setters take `self`.
        // The provide/contract entry must mirror this arity exactly or
        // `provide/contract` rejects the binding at module load.
        let params = if prop.class_property { "" } else { " self" };
        let target = if prop.class_property {
            class_name.to_string()
        } else {
            "(coerce-arg self)".to_string()
        };

        // For SEL-typed property setters, wrap value with sel_registerName; `_id`
        // values coerce to the underlying object pointer before the ptr_t bridge.
        let is_sel_prop = matches!(prop.property_type.kind, TypeRefKind::Selector);
        let value_expr = if is_sel_prop {
            "(sel_registerName value)"
        } else if ffi_type == "_id" {
            "(coerce-arg value)"
        } else {
            "value"
        };

        if let Some((entry, _arrow)) =
            native_dispatch_binding(std::slice::from_ref(&ffi_type), "_void")
        {
            // Routable setter → native dispatch (ADR-0013). Includes `_id` values
            // since leaf 050/010; only struct-valued setters keep the fallback.
            write_line!(w, "(define ({}{} value)", setter_name, params);
            let value_arg = value_expr.to_string();
            let call = native_call_expr(
                &entry,
                &target,
                &setter_sel,
                std::slice::from_ref(&value_arg),
                std::slice::from_ref(&ffi_type),
            );
            write_line!(w, "  {})", call);
        } else {
            let shared_name = sig_map.lookup(std::slice::from_ref(&ffi_type), "_void");
            match shared_name {
                Some(name) => {
                    write_line!(w, "(define ({}{} value)", setter_name, params);
                    write_line!(
                        w,
                        "  ({} {} (sel_registerName \"{}\") {}))",
                        name,
                        target,
                        setter_sel,
                        value_expr
                    );
                }
                None => {
                    write_line!(w, "(define ({}{} value)", setter_name, params);
                    w.line("  (let ([msg (get-ffi-obj \"objc_msgSend\" _objc-lib");
                    if needs_native {
                        write_line!(
                            w,
                            "              (_cprocedure (list _pointer _pointer {}) _void))])",
                            ffi_type
                        );
                    } else {
                        write_line!(
                            w,
                            "              (_fun _pointer _pointer {} -> _void))])",
                            ffi_type
                        );
                    }
                    write_line!(
                        w,
                        "    (msg {} (sel_registerName \"{}\") {})))",
                        target,
                        setter_sel,
                        value_expr
                    );
                }
            }
        }
    }
}

// --- Methods ---

#[allow(clippy::too_many_arguments)]
fn emit_method(
    w: &mut CodeWriter,
    class_name: &str,
    method: &Method,
    is_class_method: bool,
    disambiguate: bool,
    notes: &EnrichmentNotes,
    sig_map: &SignatureMap,
    mapper: &dyn FfiTypeMapper,
    needs_native: bool,
    error_selectors: &std::collections::HashSet<String>,
    framework: &str,
    siblings: &[Method],
    value_structs: &HashSet<&str>,
) {
    // D4 (charter #4): a Swift-native method (`objc_exposed == false`) has NO
    // registered ObjC selector — dispatching it through `objc_msgSend` below would
    // crash with `doesNotRecognizeSelector:`, and `is_supported_method` (which
    // rejects the parenthesised Swift selector) would otherwise silently drop it.
    // So this branch runs **before** that filter: route the method to a
    // receiver-handle trampoline binding, or **suppress** it when deferred (the
    // global trampoline pass records + counts the deferral). Never fall through to
    // the broken msgSend. `classify_method` owns the variadic/generic/etc. gates so
    // the emitter and the global pass agree.
    // D4 (charter #4): Swift-native methods (`objc_exposed == false`) are emitted by
    // the dedicated receiver-handle trampoline section (`emit_swift_native_section`),
    // which owns naming, overload dedup, the requires, and the `aw->` arrow. They must
    // never fall through to the broken `objc_msgSend` path below, so skip here.
    let _ = (siblings, value_structs, framework);
    if !method.objc_exposed {
        return;
    }

    if !is_supported_method(method) {
        return;
    }

    emit_enrichment_notes(w, notes, &method.selector);

    // NSError out-param methods (leaf 050/040) drop the trailing `NSError **` from
    // the wrapper's arity — the native `…_e` entry owns the error cell — and return
    // `(values result error)`. `effective_params` is the visible parameter set.
    let routes_error = method_routes_error_out(method, mapper, error_selectors);
    let effective_params: &[Param] = visible_params(method, mapper, error_selectors);

    let param_names: Vec<String> = effective_params
        .iter()
        .map(|p| camel_to_kebab(&p.name))
        .collect();
    let fn_name = if is_class_method {
        make_class_method_name(class_name, &method.selector, disambiguate)
    } else {
        make_method_name(class_name, &method.selector)
    };
    let ret_is_id = returns_object_type(method, mapper);
    let ret_is_void = returns_void(method, mapper);

    // Function signature
    let mut sig = format!("(define ({fn_name}");
    if !is_class_method {
        sig.push_str(" self");
    }
    for pn in &param_names {
        sig.push(' ');
        sig.push_str(pn);
    }
    sig.push(')');
    w.line(&sig);

    let retained = method_returns_retained(method);

    let param_types: Vec<String> = effective_params
        .iter()
        .map(|p| mapper.map_type(&p.param_type, false))
        .collect();
    let ret_ffi_type = mapper.map_type(&method.return_type, true);
    let target_expr = if is_class_method {
        class_name.to_string()
    } else {
        "(coerce-arg self)".to_string()
    };

    let mut call_args: Vec<String> = param_names.clone();

    // Block wrapping
    emit_block_wrapping(w, effective_params, &mut call_args, mapper);

    // Coerce id-kind params
    coerce_id_params(effective_params, &mut call_args, mapper);

    // Coerce SEL-typed params (string → sel_registerName)
    coerce_sel_params(effective_params, &mut call_args);

    // NSError out-param routing (leaf 050/040): a single ffi2 call into the `…_e`
    // native entry with a caller-allocated error out-buffer, yielding
    // `(values result error)`. `routes_error` guarantees the binding exists.
    if routes_error {
        if let Some((entry, _arrow)) = native_dispatch_error_binding(&param_types, &ret_ffi_type) {
            emit_error_out_body(
                w,
                &entry,
                &target_expr,
                &method.selector,
                &call_args,
                &param_types,
                &ret_ffi_type,
                ret_is_id,
                ret_is_void,
                retained,
            );
            return;
        }
    }

    // Every routable signature dispatches through the generated native entry
    // (ADR-0013). Since leaf 050/010 this includes the all-object shapes that
    // previously used the in-Racket `tell` macro (`_id` collapses to `ptr_t`);
    // `tell`-for-dispatch is gone from emitted methods. Only the non-routable
    // struct-by-value / C-string remainder keeps the `get-ffi-obj` fallback.
    if let Some((entry, _arrow)) = native_dispatch_binding(&param_types, &ret_ffi_type) {
        // Struct-by-value return: allocate a cstruct out-buffer, let the native
        // entry write the arm64 struct result through it, hand back the cstruct
        // (the established `ffi/unsafe` rep — same as the old `tell #:type _NSRect`
        // path produced). Struct *params* are bridged inside `native_call_expr*`.
        if let Some(g) = GeoStruct::from_ffi_unsafe(&ret_ffi_type) {
            let cstruct = g.racket_cstruct();
            let call = native_call_expr_with_out(
                &entry,
                &target_expr,
                &method.selector,
                &call_args,
                &param_types,
                Some("(cpointer->ptr_t buf)"),
            );
            write_line!(w, "  (let ([buf (malloc {cstruct})])");
            write_line!(w, "    {}", call);
            write_line!(w, "    (ptr-ref buf {cstruct})))");
            return;
        }
        let call = native_call_expr(
            &entry,
            &target_expr,
            &method.selector,
            &call_args,
            &param_types,
        );
        if ret_is_id && !ret_is_void {
            w.line("  (wrap-objc-object");
            write_line!(w, "   (ffi2-ptr->id {})", call);
            if retained {
                w.line("   #:retained #t))");
            } else {
                w.raw_line("   ))");
            }
        } else if ret_is_void {
            write_line!(w, "  {})", call);
        } else {
            write_line!(w, "  {})", native_scalar_result(&call, &ret_ffi_type));
        }
        return;
    }

    let shared_name = sig_map.lookup(&param_types, &ret_ffi_type);
    match shared_name {
        Some(name) => {
            if ret_is_id && !ret_is_void {
                w.line("  (wrap-objc-object");
                w.raw(&format!(
                    "   ({} {} (sel_registerName \"{}\")",
                    name, target_expr, method.selector
                ));
                for arg in &call_args {
                    w.raw(&format!(" {arg}"));
                }
                w.raw_line(")");
                if retained {
                    w.line("   #:retained #t))");
                } else {
                    w.raw_line("   ))");
                }
            } else {
                w.raw(&format!(
                    "  ({} {} (sel_registerName \"{}\")",
                    name, target_expr, method.selector
                ));
                for arg in &call_args {
                    w.raw(&format!(" {arg}"));
                }
                w.raw_line("))");
            }
        }
        None => {
            emit_inline_fallback_open(w, &param_types, &ret_ffi_type, needs_native);
            if ret_is_id && !ret_is_void {
                w.line("    (wrap-objc-object");
                w.raw(&format!(
                    "     (msg {} (sel_registerName \"{}\")",
                    target_expr, method.selector
                ));
                for arg in &call_args {
                    w.raw(&format!(" {arg}"));
                }
                w.raw_line(")");
                if retained {
                    w.line("     #:retained #t))))");
                } else {
                    w.raw_line("     ))))");
                }
            } else {
                w.raw(&format!(
                    "    (msg {} (sel_registerName \"{}\")",
                    target_expr, method.selector
                ));
                for arg in &call_args {
                    w.raw(&format!(" {arg}"));
                }
                w.raw_line(")))");
            }
        }
    }
}

/// Open an inline `(let ([msg (get-ffi-obj … )])` for a single-use typed
/// objc_msgSend. Uses `_cprocedure` in a native-dispatch file (where ffi2 shadows
/// `ffi/unsafe`'s `->`) and the historical `_fun` form otherwise.
fn emit_inline_fallback_open(
    w: &mut CodeWriter,
    param_types: &[String],
    ret_ffi_type: &str,
    needs_native: bool,
) {
    w.line("  (let ([msg (get-ffi-obj \"objc_msgSend\" _objc-lib");
    if needs_native {
        w.raw("              (_cprocedure (list _pointer _pointer");
        for pt in param_types {
            w.raw(&format!(" {pt}"));
        }
        w.raw(&format!(") {ret_ffi_type}))])\n"));
    } else {
        w.raw("              (_fun _pointer _pointer");
        for pt in param_types {
            w.raw(&format!(" {pt}"));
        }
        w.raw(&format!(" -> {ret_ffi_type}))])\n"));
    }
}

// --- Helpers ---

/// Emit one `;; {note}` comment line per enrichment note for `selector`.
///
/// Methods with no notes produce no output, so unannotated methods stay
/// golden-stable. Call this immediately before the method's `(define ...)`.
fn emit_enrichment_notes(w: &mut CodeWriter, notes: &EnrichmentNotes, selector: &str) {
    for note in notes.notes_for(selector) {
        write_line!(w, ";; {}", note);
    }
}

/// Format tell arguments: "selector: (coerce-arg arg1) keyword: (coerce-arg arg2) ..."
fn format_tell_args(selector: &str, param_names: &[String], params: &[Param]) -> String {
    if param_names.is_empty() {
        return selector.to_string();
    }

    let keywords: Vec<&str> = selector.split(':').filter(|s| !s.is_empty()).collect();
    let mut parts = Vec::new();
    for (i, (kw, pn)) in keywords.iter().zip(param_names.iter()).enumerate() {
        let needs_coerce = i < params.len()
            && matches!(
                params[i].param_type.kind,
                TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype
            );
        if needs_coerce {
            parts.push(format!("{kw}: (coerce-arg {pn})"));
        } else {
            parts.push(format!("{kw}: {pn}"));
        }
    }
    parts.join(" ")
}

/// Emit block wrapping code for block-typed params.
fn emit_block_wrapping(
    w: &mut CodeWriter,
    params: &[Param],
    call_args: &mut [String],
    mapper: &dyn FfiTypeMapper,
) {
    for (i, p) in params.iter().enumerate() {
        if let TypeRefKind::Block {
            ref params,
            ref return_type,
        } = p.param_type.kind
        {
            let (bparam_strs, bret_str) = block_ffi_types(params, return_type, mapper);
            let blk_var = format!("_blk{i}");
            let blk_id_var = format!("_blk{i}-id");
            write_line!(w, "  (define-values ({} {})", blk_var, blk_id_var);
            write_line!(
                w,
                "    (make-objc-block {} (list {}) {}))",
                call_args[i],
                bparam_strs.join(" "),
                bret_str
            );
            call_args[i] = blk_var;
        }
    }
}

/// Wrap id-kind params (that aren't blocks) with coerce-arg.
fn coerce_id_params(params: &[Param], call_args: &mut [String], mapper: &dyn FfiTypeMapper) {
    for (i, p) in params.iter().enumerate() {
        if mapper.is_object_type(&p.param_type) && !mapper.is_block_type(&p.param_type) {
            call_args[i] = format!("(coerce-arg {})", call_args[i]);
        }
    }
}

/// Wrap SEL-typed params with sel_registerName so callers pass strings.
fn coerce_sel_params(params: &[Param], call_args: &mut [String]) {
    for (i, p) in params.iter().enumerate() {
        if matches!(p.param_type.kind, TypeRefKind::Selector) {
            call_args[i] = format!("(sel_registerName {})", call_args[i]);
        }
    }
}

// --- Native dispatch call construction (ADR-0013) ---

/// Bridge a pointer-typed expression (object / selector / block — all `cpointer`s
/// in the retained ffi/unsafe world) into a ffi2 `ptr_t` for a native dispatch
/// call. `id->ffi2-ptr` (runtime `ffi2-seam.rkt`) is `cpointer->ptr_t`, valid for
/// any cpointer regardless of `_id` tagging.
fn ffi2_ptr_in(expr: &str) -> String {
    format!("(id->ffi2-ptr {expr})")
}

/// Build a native dispatch call expression:
/// `(aw_racket_msg_<code> (id->ffi2-ptr <recv>) (id->ffi2-ptr (sel_registerName "sel")) <args…>)`.
/// `call_args` and `param_ffi_types` are parallel; pointer-typed args — and
/// struct-by-value args, whose cstruct value *is* a cpointer to the struct bytes —
/// take the `ptr_t` bridge, scalars pass through unchanged.
fn native_call_expr(
    entry: &str,
    recv_expr: &str,
    selector: &str,
    call_args: &[String],
    param_ffi_types: &[String],
) -> String {
    native_call_expr_with_out(entry, recv_expr, selector, call_args, param_ffi_types, None)
}

/// As [`native_call_expr`], with an optional trailing out-buffer argument (already
/// a `ptr_t` expression). Struct *returns* allocate a cstruct buffer and pass its
/// pointer here; the native entry writes the struct result through it.
fn native_call_expr_with_out(
    entry: &str,
    recv_expr: &str,
    selector: &str,
    call_args: &[String],
    param_ffi_types: &[String],
    out_buffer: Option<&str>,
) -> String {
    let mut parts = vec![
        ffi2_ptr_in(recv_expr),
        ffi2_ptr_in(&format!("(sel_registerName \"{selector}\")")),
    ];
    for (a, t) in call_args.iter().zip(param_ffi_types.iter()) {
        if t == "_id" || t == "_pointer" || GeoStruct::from_ffi_unsafe(t).is_some() {
            parts.push(ffi2_ptr_in(a));
        } else {
            parts.push(a.clone());
        }
    }
    if let Some(out) = out_buffer {
        parts.push(out.to_string());
    }
    format!("({entry} {})", parts.join(" "))
}

/// Convert a native dispatch call's `ptr_t` result back into the representation
/// the wrapper's contract expects, for non-object returns: a raw `_pointer`
/// return becomes a `cpointer` via `ptr_t->cpointer`. Object (`_id`) returns are
/// handled at the call site (they go through `ffi2-ptr->id` + `wrap-objc-object`);
/// scalar/void returns need no conversion. Returns the (possibly-wrapped) expr.
fn native_scalar_result(call: &str, ret_ffi_type: &str) -> String {
    if ret_ffi_type == "_pointer" {
        format!("(ptr_t->cpointer {call})")
    } else {
        call.to_string()
    }
}

/// Emit the body of an **NSError out-param** wrapper (leaf 050/040): allocate a
/// one-pointer error cell, make a single ffi2 call into the `…_e` native entry
/// (which writes the retained `NSError*`, or NULL, through the cell), and hand
/// back `(values result error)`. The `let`'s init expressions evaluate
/// left-to-right, so the call (which writes the cell) runs before the cell is
/// read. `error` is the wrapped `NSError` (already +1 from the native side, so
/// `#:retained #t`) or `#f` when the method reported none.
#[allow(clippy::too_many_arguments)]
fn emit_error_out_body(
    w: &mut CodeWriter,
    entry: &str,
    target_expr: &str,
    selector: &str,
    call_args: &[String],
    param_types: &[String],
    ret_ffi_type: &str,
    ret_is_id: bool,
    ret_is_void: bool,
    retained: bool,
) {
    let call = native_call_expr_with_out(
        entry,
        target_expr,
        selector,
        call_args,
        param_types,
        Some("(cpointer->ptr_t errbuf)"),
    );
    let err_value = "(if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))";
    w.line("  (let ([errbuf (malloc _pointer)])");
    if ret_is_void {
        // No result value: run the call (writing the error cell), then pair the
        // void result with the error.
        write_line!(w, "    {}", call);
        w.line("    (let ([err (ptr-ref errbuf _pointer)])");
        write_line!(w, "      (values (void) {err_value}))))");
    } else {
        let result_expr = if ret_is_id {
            if retained {
                "(wrap-objc-object (ffi2-ptr->id result) #:retained #t)".to_string()
            } else {
                "(wrap-objc-object (ffi2-ptr->id result))".to_string()
            }
        } else {
            // Scalar (incl. bool) passes through; a raw `_pointer` is re-tagged.
            native_scalar_result("result", ret_ffi_type)
        };
        write_line!(w, "    (let ([result {call}]");
        w.line("          [err (ptr-ref errbuf _pointer)])");
        write_line!(w, "      (values {result_expr} {err_value}))))");
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::Param;
    use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

    #[test]
    fn test_format_tell_args_no_params() {
        assert_eq!(format_tell_args("length", &[], &[]), "length");
    }

    #[test]
    fn test_format_tell_args_single_id_param() {
        let params = vec![Param {
            name: "object".into(),
            param_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Id,
            },
        }];
        assert_eq!(
            format_tell_args("addObject:", &["object".into()], &params),
            "addObject: (coerce-arg object)"
        );
    }

    #[test]
    fn test_format_tell_args_non_id_param() {
        let params = vec![Param {
            name: "index".into(),
            param_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "uint64".into(),
                },
            },
        }];
        assert_eq!(
            format_tell_args("objectAtIndex:", &["index".into()], &params),
            "objectAtIndex: index"
        );
    }

    #[test]
    fn test_is_family_match() {
        assert!(is_family_match("init", "init"));
        assert!(is_family_match("initWithString:", "init"));
        assert!(is_family_match("init(arrayLiteral:)", "init"));
        assert!(!is_family_match("initialize", "init"));
        assert!(is_family_match("copy", "copy"));
        assert!(is_family_match("copyWithZone:", "copy"));
        assert!(is_family_match("new", "new"));
        assert!(is_family_match("newValue", "new"));
    }

    #[test]
    fn test_method_returns_retained() {
        let make_method = |selector: &str, class_method: bool, retained: Option<bool>| Method {
            selector: selector.to_string(),
            class_method,
            init_method: !class_method && selector.starts_with("init"),
            params: vec![],
            return_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Id,
            },
            deprecated: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
            category: None,
            overrides: None,
            returns_retained: retained,
            satisfies_protocol: None,
            objc_exposed: true,
            swift_fn: None,
        };

        // IR value takes precedence
        assert!(method_returns_retained(&make_method(
            "foo",
            false,
            Some(true)
        )));
        assert!(!method_returns_retained(&make_method(
            "init",
            false,
            Some(false)
        )));

        // Heuristic fallback
        assert!(method_returns_retained(&make_method(
            "initWithString:",
            false,
            None
        )));
        assert!(method_returns_retained(&make_method("new", true, None)));
        assert!(method_returns_retained(&make_method("copy", false, None)));
        assert!(method_returns_retained(&make_method(
            "mutableCopy",
            false,
            None
        )));
        assert!(!method_returns_retained(&make_method(
            "description",
            false,
            None
        )));
    }

    #[test]
    fn test_generate_class_file_basic() {
        let cls = Class {
            name: "NSObject".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![Method {
                selector: "description".to_string(),
                class_method: false,
                init_method: false,
                params: vec![],
                return_type: TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Id,
                },
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
            }],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "Foundation", None);
        assert!(output.contains("#lang racket/base"));
        assert!(output.contains("(import-class NSObject)"));
        assert!(output.contains("(define (nsobject-description self)"));
        assert!(output.contains("wrap-objc-object"));
    }

    /// D4 (charter #4): a Swift-native method routes to a receiver-handle trampoline
    /// against `_aw-lib`, **not** the broken `objc_msgSend` path; a deferred
    /// Swift-native method is suppressed (no binding, and crucially no msgSend).
    #[test]
    fn swift_native_method_routes_to_trampoline_not_msgsend() {
        use apianyware_macos_types::ir::SwiftFnInfo;
        let swift_method = |selector: &str, info: SwiftFnInfo| Method {
            selector: selector.to_string(),
            class_method: false,
            init_method: false,
            params: vec![Param {
                name: "by".to_string(),
                param_type: TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Primitive {
                        name: "int64".to_string(),
                    },
                },
            }],
            return_type: TypeRef {
                nullable: false,
                kind: TypeRefKind::Primitive {
                    name: "int64".to_string(),
                },
            },
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
            objc_exposed: false,
            swift_fn: Some(info),
        };
        let cls = Class {
            name: "TKWidget".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                swift_method("scaled(by:)", SwiftFnInfo::default()),
                // Generic Swift-native method → deferred → suppressed.
                swift_method(
                    "mapped(by:)",
                    SwiftFnInfo {
                        is_generic: true,
                        ..Default::default()
                    },
                ),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let out = generate_class_file(&cls, "TestKit", None);
        // The bindable method routes to the content-addressed trampoline via _aw-lib.
        assert!(
            out.contains("aw_racket_swift_m_TestKit_TKWidget_scaled"),
            "trampoline entry missing:\n{out}"
        );
        assert!(
            out.contains("_aw-lib"),
            "binding not against _aw-lib:\n{out}"
        );
        assert!(
            out.contains("(coerce-arg self)"),
            "receiver not passed:\n{out}"
        );
        // The broken msgSend path must NOT be emitted for the Swift-native method.
        assert!(
            !out.contains("\"scaled:\"") && !out.contains("sel_registerName \"scaled"),
            "Swift-native method must not msgSend a synthesized selector:\n{out}"
        );
        // The deferred generic method is suppressed entirely (no binding, no msgSend).
        assert!(
            !out.contains("mapped"),
            "deferred Swift-native method should be suppressed:\n{out}"
        );
    }

    #[test]
    fn nserror_out_param_method_emits_values_wrapper() {
        use apianyware_macos_types::enrichment::{ClassSelectorEntry, EnrichmentData};

        // `-loadResource:error:` → BOOL, trailing `NSError **` (a Pointer named
        // "error"). The enrichment classifies it as an NSError out-param.
        let cls = Class {
            name: "TKManager".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "loadResource:error:",
                false,
                false,
                vec![
                    Param {
                        name: "name".into(),
                        param_type: TypeRef {
                            nullable: false,
                            kind: TypeRefKind::Class {
                                name: "NSString".into(),
                                framework: None,
                                params: vec![],
                            },
                        },
                    },
                    Param {
                        name: "error".into(),
                        param_type: TypeRef {
                            nullable: true,
                            kind: TypeRefKind::Pointer,
                        },
                    },
                ],
                TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Primitive {
                        name: "BOOL".into(),
                    },
                },
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let enrichment = EnrichmentData {
            convenience_error_methods: vec![ClassSelectorEntry {
                class: "TKManager".into(),
                selector: "loadResource:error:".into(),
            }],
            ..Default::default()
        };

        let output = generate_class_file(&cls, "TestKit", Some(&enrichment));

        // The wrapper drops the trailing `error` param from its arity…
        assert!(
            output.contains("(define (tkmanager-load-resource-error self name)"),
            "error param dropped from arity:\n{output}"
        );
        // …routes through the `…_e` native entry with an error out-buffer…
        assert!(
            output.contains(
                "(define-aw-msg aw_racket_msg_P_b_e (-> ptr_t ptr_t ptr_t ptr_t bool_t))"
            ),
            "error-out native binding:\n{output}"
        );
        assert!(
            output.contains("(let ([errbuf (malloc _pointer)])"),
            "allocates the error cell:\n{output}"
        );
        assert!(
            output.contains("(cpointer->ptr_t errbuf)"),
            "passes the error out-buffer:\n{output}"
        );
        // …and returns `(values result error)`.
        assert!(
            output.contains(
                "(values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t)))"
            ),
            "returns (values result error):\n{output}"
        );
        // The contract reflects the dropped param + the values return.
        assert!(
            output.contains(
                "[tkmanager-load-resource-error (c-> tkmanager? (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]"
            ),
            "values contract with dropped error param:\n{output}"
        );
    }

    // --- Contract tests ---

    fn make_test_method(
        selector: &str,
        class_method: bool,
        init_method: bool,
        params: Vec<Param>,
        return_type: TypeRef,
    ) -> Method {
        Method {
            selector: selector.to_string(),
            class_method,
            init_method,
            params,
            return_type,
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

    fn make_test_property(name: &str, kind: TypeRefKind, readonly: bool) -> Property {
        Property {
            name: name.to_string(),
            property_type: TypeRef {
                nullable: false,
                kind,
            },
            readonly,
            class_property: false,
            is_copy: false,
            deprecated: false,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
            objc_exposed: true,
        }
    }

    fn make_test_class_property(name: &str, kind: TypeRefKind, readonly: bool) -> Property {
        Property {
            name: name.to_string(),
            property_type: TypeRef {
                nullable: false,
                kind,
            },
            readonly,
            class_property: true,
            is_copy: false,
            deprecated: false,
            source: None,
            provenance: None,
            doc_refs: None,
            origin: None,
            objc_exposed: true,
        }
    }

    fn type_id() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Id,
        }
    }

    fn type_void() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "void".into(),
            },
        }
    }

    fn type_bool() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "bool".into(),
            },
        }
    }

    fn type_double() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "double".into(),
            },
        }
    }

    #[test]
    fn test_class_file_has_provide_contract() {
        let cls = Class {
            name: "NSObject".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "description",
                false,
                false,
                vec![],
                type_id(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "Foundation", None);
        assert!(
            output.contains("(provide/contract"),
            "Should use provide/contract"
        );
        assert!(
            output.contains("racket/contract"),
            "Should require racket/contract"
        );
    }

    #[test]
    fn test_instance_method_contract() {
        let cls = Class {
            name: "NSObject".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "description",
                false,
                false,
                vec![],
                type_id(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "Foundation", None);
        // Instance method: receiver uses the class-specific predicate, not the generic objc-object?
        assert!(
            output.contains("[nsobject-description (c-> nsobject? any/c)]"),
            "Instance method should use class-specific receiver predicate. Output:\n{output}"
        );
    }

    #[test]
    fn test_property_getter_contract() {
        let cls = Class {
            name: "TKView".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![
                make_test_property("title", TypeRefKind::Id, false),
                make_test_property(
                    "hidden",
                    TypeRefKind::Primitive {
                        name: "bool".into(),
                    },
                    true,
                ),
            ],
            methods: vec![],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", None);
        // Object getter: receiver uses class-specific predicate
        assert!(
            output.contains("[tkview-title (c-> tkview? any/c)]"),
            "Object property getter contract. Output:\n{output}"
        );
        // Bool getter: receiver uses class-specific predicate
        assert!(
            output.contains("[tkview-hidden (c-> tkview? boolean?)]"),
            "Bool property getter contract. Output:\n{output}"
        );
    }

    #[test]
    fn test_id_property_setter_routes_native() {
        // Since leaf 050/010 an `_id` setter dispatches through the generated
        // native entry (ADR-0013): `(_id) -> _void` is routable (`_id` collapses
        // to `ptr_t`). The value coerces to its underlying object pointer, then
        // the `ptr_t` bridge crosses it. No more in-Racket `tell` for dispatch.
        let cls = Class {
            name: "TKView".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![make_test_property("title", TypeRefKind::Id, false)],
            methods: vec![],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", None);
        assert!(
            output.contains(
                "  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) \
                 (id->ffi2-ptr (sel_registerName \"setTitle:\")) (id->ffi2-ptr (coerce-arg value))))"
            ),
            "_id setter body must route through native dispatch. Output:\n{output}"
        );
        assert!(
            !output.contains("(tell #:type _void"),
            "Setter body must not use the legacy `tell` dispatch form. Output:\n{output}"
        );
    }

    #[test]
    fn test_void_object_method_routes_native() {
        // All-object, void-returning method (`(_id) -> _void`) — previously the
        // `tell` macro path — now dispatches through the generated native entry
        // (ADR-0013), object arg coerced and bridged to `ptr_t`.
        let cls = Class {
            name: "TKView".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "addObject:",
                false,
                false,
                vec![Param {
                    name: "obj".to_string(),
                    param_type: type_id(),
                }],
                type_void(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", None);
        assert!(
            output.contains(
                "  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) \
                 (id->ffi2-ptr (sel_registerName \"addObject:\")) (id->ffi2-ptr (coerce-arg obj))))"
            ),
            "Void all-object method must route through native dispatch. Output:\n{output}"
        );
        assert!(
            // The synthesized default constructor still uses `(tell (tell … alloc) init)`;
            // only the method's *dispatch* must be native, not the `tell` token globally.
            !output.contains("addObject: (coerce-arg obj)"),
            "Method dispatch must not use the legacy `tell` keyword-arg form. Output:\n{output}"
        );
    }

    #[test]
    fn test_void_zero_arg_method_routes_native() {
        // Zero-arg void method (`() -> _void`) → native `aw_racket_msg_0_v`.
        let cls = Class {
            name: "TKView".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "dealloc",
                false,
                false,
                vec![],
                type_void(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", None);
        assert!(
            output.contains(
                "  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) \
                 (id->ffi2-ptr (sel_registerName \"dealloc\"))))"
            ),
            "Zero-arg void method must route through native dispatch. Output:\n{output}"
        );
    }

    #[test]
    fn test_property_setter_contract() {
        let cls = Class {
            name: "TKView".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![
                make_test_property("title", TypeRefKind::Id, false),
                make_test_property(
                    "tag",
                    TypeRefKind::Primitive {
                        name: "int64".into(),
                    },
                    false,
                ),
            ],
            methods: vec![],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", None);
        // Object setter: receiver uses class-specific predicate; value union stays as-is.
        assert!(
            output
                .contains("[tkview-set-title! (c-> tkview? (or/c string? objc-object? #f) void?)]"),
            "Object property setter contract. Output:\n{output}"
        );
        // Typed setter: receiver uses class-specific predicate.
        assert!(
            output.contains("[tkview-set-tag! (c-> tkview? exact-integer? void?)]"),
            "Typed property setter contract. Output:\n{output}"
        );
    }

    #[test]
    fn test_class_property_setter_impl_and_contract_agree() {
        // A class-method (static) property setter must emit an impl whose
        // arity matches its provide/contract. Prior bug: contract dropped
        // the receiver (correct for a class method) but the impl was still
        // emitted as `(define (setter self value) ...)`, so `provide/contract`
        // rejected the binding at module load with an arity mismatch.
        let cls = Class {
            name: "TKWindow".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![
                // Primitive class property: shared typed-msgSend setter path.
                make_test_class_property(
                    "allowsAutomaticWindowTabbing",
                    TypeRefKind::Primitive {
                        name: "bool".into(),
                    },
                    false,
                ),
                // `_id` class property: native-dispatch setter path (050/010).
                make_test_class_property("defaultTitle", TypeRefKind::Id, false),
            ],
            methods: vec![],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", None);

        // Contract: no receiver slot (class methods have no `self`).
        assert!(
            output.contains("[tkwindow-set-allows-automatic-window-tabbing! (c-> boolean? void?)]"),
            "Class-property primitive setter contract must omit receiver. Output:\n{output}"
        );
        assert!(
            output.contains(
                "[tkwindow-set-default-title! (c-> (or/c string? objc-object? #f) void?)]"
            ),
            "Class-property _id setter contract must omit receiver. Output:\n{output}"
        );

        // Impl: one-argument definition, no `self` parameter.
        assert!(
            output.contains("(define (tkwindow-set-allows-automatic-window-tabbing! value)"),
            "Class-property primitive setter impl must be single-arg. Output:\n{output}"
        );
        assert!(
            output.contains("(define (tkwindow-set-default-title! value)"),
            "Class-property _id setter impl must be single-arg. Output:\n{output}"
        );

        // Impl body must target the class metaobject, not `(coerce-arg self)`.
        assert!(
            !output.contains("(tkwindow-set-allows-automatic-window-tabbing! self value)")
                && !output.contains("(tkwindow-set-default-title! self value)"),
            "Class-property setter impls must not take `self`. Output:\n{output}"
        );
        assert!(
            output.contains(
                "(aw_racket_msg_P_v (id->ffi2-ptr TKWindow) \
                 (id->ffi2-ptr (sel_registerName \"setDefaultTitle:\")) (id->ffi2-ptr (coerce-arg value)))"
            ),
            "Class-property _id setter body must route native, targeting the class \
             metaobject directly. Output:\n{output}"
        );
    }

    #[test]
    fn test_class_property_getter_impl_and_contract_agree() {
        // Symmetry check for the getter: class-property getters already
        // emit correctly (0-arg impl + 0-arg contract) — lock it down so a
        // future refactor does not regress one side without the other.
        let cls = Class {
            name: "TKWindow".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![
                make_test_class_property(
                    "allowsAutomaticWindowTabbing",
                    TypeRefKind::Primitive {
                        name: "bool".into(),
                    },
                    true,
                ),
                make_test_class_property("defaultTitle", TypeRefKind::Id, true),
            ],
            methods: vec![],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", None);

        assert!(
            output.contains("[tkwindow-allows-automatic-window-tabbing (c-> boolean?)]"),
            "Class-property primitive getter contract must omit receiver. Output:\n{output}"
        );
        assert!(
            output.contains("[tkwindow-default-title (c-> any/c)]"),
            "Class-property _id getter contract must omit receiver. Output:\n{output}"
        );
        assert!(
            output.contains("(define (tkwindow-allows-automatic-window-tabbing)"),
            "Class-property primitive getter impl must be zero-arg. Output:\n{output}"
        );
        assert!(
            output.contains("(define (tkwindow-default-title)"),
            "Class-property _id getter impl must be zero-arg. Output:\n{output}"
        );
    }

    #[test]
    fn test_readonly_property_no_setter_contract() {
        let cls = Class {
            name: "TKView".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![make_test_property(
                "hidden",
                TypeRefKind::Primitive {
                    name: "bool".into(),
                },
                true,
            )],
            methods: vec![],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", None);
        assert!(
            !output.contains("set-hidden!"),
            "Readonly property should not have setter contract"
        );
    }

    #[test]
    fn test_method_with_typed_params_contract() {
        let cls = Class {
            name: "TKView".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "setTag:",
                false,
                false,
                vec![Param {
                    name: "tag".to_string(),
                    param_type: TypeRef {
                        nullable: false,
                        kind: TypeRefKind::Primitive {
                            name: "int64".into(),
                        },
                    },
                }],
                type_void(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", None);
        // Receiver uses class-specific predicate; typed param unchanged.
        assert!(
            output.contains("[tkview-set-tag! (c-> tkview? exact-integer? void?)]"),
            "Typed param method contract. Output:\n{output}"
        );
    }

    #[test]
    fn test_method_with_block_param_contract() {
        let cls = Class {
            name: "TKView".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "animateWithDuration:animations:",
                false,
                false,
                vec![
                    Param {
                        name: "duration".to_string(),
                        param_type: type_double(),
                    },
                    Param {
                        name: "animations".to_string(),
                        param_type: TypeRef {
                            nullable: false,
                            kind: TypeRefKind::Block {
                                params: vec![],
                                return_type: Box::new(type_void()),
                            },
                        },
                    },
                ],
                type_void(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", None);
        // Block param → (or/c procedure? #f); receiver uses class-specific predicate.
        assert!(
            output.contains("(c-> tkview? real? (or/c procedure? #f) void?)"),
            "Block param contract. Output:\n{output}"
        );
    }

    #[test]
    fn test_constructor_contract() {
        let cls = Class {
            name: "TKView".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "initWithFrame:",
                false,
                true,
                vec![Param {
                    name: "frame".to_string(),
                    param_type: TypeRef {
                        nullable: false,
                        kind: TypeRefKind::Alias {
                            name: "NSRect".into(),
                            framework: None,
                            underlying_primitive: None,
                        },
                    },
                }],
                type_id(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", None);
        // Constructor: (-> param-contracts... any/c) — returns wrapped object
        assert!(
            output.contains("[make-tkview-init-with-frame (c-> any/c any/c)]"),
            "Constructor contract. Output:\n{output}"
        );
    }

    #[test]
    fn test_default_constructor_synthesized_when_no_init_in_ir() {
        // Class with no init methods at all (e.g. NSAlert) should get a
        // synthesized default constructor make-<class> so callers don't
        // need to drop into objc-interop's alloc+init escape hatch.
        let cls = Class {
            name: "TKAlert".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "messageText",
                false,
                false,
                vec![],
                type_id(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", None);
        assert!(
            output.contains("(define (make-tkalert)"),
            "Default constructor definition. Output:\n{output}"
        );
        assert!(
            output.contains("(tell (tell TKAlert alloc) init)"),
            "Default constructor body. Output:\n{output}"
        );
        assert!(
            output.contains("[make-tkalert (c-> any/c)]"),
            "Default constructor contract. Output:\n{output}"
        );
    }

    #[test]
    fn test_default_constructor_synthesized_when_only_bare_init() {
        // Class with only the bare `init` selector in IR should get the
        // default constructor — `init` is currently skipped by the explicit
        // emit path, so without synthesis there'd be no constructor at all.
        let cls = Class {
            name: "TKBareInit".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method("init", false, true, vec![], type_id())],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", None);
        assert!(
            output.contains("(define (make-tkbareinit)"),
            "Default constructor synthesized for bare-init-only class. Output:\n{output}"
        );
        assert!(
            output.contains("[make-tkbareinit (c-> any/c)]"),
            "Default constructor contract. Output:\n{output}"
        );
    }

    #[test]
    fn test_default_constructor_suppressed_when_explicit_init_exists() {
        // Class with an explicit init (e.g. NSView's initWithFrame:) should
        // NOT get the synthesized default — the explicit init's signature is
        // the canonical construction path and bare alloc+init may be wrong.
        let cls = Class {
            name: "TKView".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "initWithFrame:",
                false,
                true,
                vec![Param {
                    name: "frame".to_string(),
                    param_type: TypeRef {
                        nullable: false,
                        kind: TypeRefKind::Alias {
                            name: "NSRect".into(),
                            framework: None,
                            underlying_primitive: None,
                        },
                    },
                }],
                type_id(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", None);
        assert!(
            !output.contains("(define (make-tkview)"),
            "Default constructor must NOT be emitted alongside explicit init. Output:\n{output}"
        );
        assert!(
            !output.contains("[make-tkview (c->"),
            "Default constructor contract must NOT be exported. Output:\n{output}"
        );
        // Explicit-init constructor still emitted as before
        assert!(
            output.contains("[make-tkview-init-with-frame (c-> any/c any/c)]"),
            "Explicit init constructor still emitted. Output:\n{output}"
        );
    }

    #[test]
    fn test_empty_class_provide() {
        // A class with no methods or properties still gets the synthesized
        // default constructor — `[Class alloc] init]` is always callable on
        // an ObjC class via the inherited NSObject -init. Therefore the
        // class name AND the default constructor are exported.
        let cls = Class {
            name: "TKEmpty".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", None);
        assert!(
            output.contains("(provide TKEmpty)"),
            "Empty class should export class name. Output:\n{output}"
        );
        assert!(
            output.contains("[make-tkempty (c-> any/c)]"),
            "Empty class still gets the default constructor. Output:\n{output}"
        );
    }

    #[test]
    fn test_map_param_contract_coercion() {
        // Non-nullable `Id` → union matching the opaque API surface
        // (string, objc-object — but not #f or cpointer).
        assert_eq!(
            map_param_contract(&type_id()),
            "(or/c string? objc-object? #f)"
        );
        // Block → procedure? or #f
        let block = TypeRef {
            nullable: false,
            kind: TypeRefKind::Block {
                params: vec![],
                return_type: Box::new(type_void()),
            },
        };
        assert_eq!(map_param_contract(&block), "(or/c procedure? #f)");
        // Primitive → delegates to map_contract
        assert_eq!(map_param_contract(&type_double()), "real?");
        assert_eq!(map_param_contract(&type_bool()), "boolean?");
    }

    #[test]
    fn test_map_param_contract_nullable_id() {
        let nullable_id = TypeRef {
            nullable: true,
            kind: TypeRefKind::Id,
        };
        assert_eq!(
            map_param_contract(&nullable_id),
            "(or/c string? objc-object? #f)"
        );
    }

    #[test]
    fn test_map_param_contract_class_types() {
        let non_null = TypeRef {
            nullable: false,
            kind: TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            },
        };
        assert_eq!(
            map_param_contract(&non_null),
            "(or/c string? objc-object? #f)"
        );

        let nullable = TypeRef {
            nullable: true,
            kind: TypeRefKind::Class {
                name: "NSString".into(),
                framework: None,
                params: vec![],
            },
        };
        assert_eq!(
            map_param_contract(&nullable),
            "(or/c string? objc-object? #f)"
        );
    }

    #[test]
    fn test_map_param_contract_instancetype() {
        let non_null = TypeRef {
            nullable: false,
            kind: TypeRefKind::Instancetype,
        };
        assert_eq!(
            map_param_contract(&non_null),
            "(or/c string? objc-object? #f)"
        );

        let nullable = TypeRef {
            nullable: true,
            kind: TypeRefKind::Instancetype,
        };
        assert_eq!(
            map_param_contract(&nullable),
            "(or/c string? objc-object? #f)"
        );
    }

    #[test]
    fn test_map_return_contract_wrapping() {
        // Object returns → any/c (wrap-objc-object returns opaque value)
        assert_eq!(map_return_contract(&type_id()), "any/c");
        // Void → void?
        assert_eq!(map_return_contract(&type_void()), "void?");
        // Primitive → delegates
        assert_eq!(map_return_contract(&type_bool()), "boolean?");
    }

    #[test]
    fn test_map_param_contract_selector_accepts_string() {
        let sel = TypeRef {
            nullable: false,
            kind: TypeRefKind::Selector,
        };
        assert_eq!(map_param_contract(&sel), "string?");
    }

    fn type_selector() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Selector,
        }
    }

    #[test]
    fn test_selector_param_wrapped_with_sel_register_name() {
        let cls = Class {
            name: "TKControl".to_string(),
            superclass: "TKObject".to_string(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "setAction:",
                false,
                false,
                vec![Param {
                    name: "action".to_string(),
                    param_type: type_selector(),
                }],
                type_void(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![make_test_method(
                "setAction:",
                false,
                false,
                vec![Param {
                    name: "action".to_string(),
                    param_type: type_selector(),
                }],
                type_void(),
            )],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", None);

        // Contract: SEL param accepts string
        assert!(
            output.contains("string?"),
            "SEL param contract should accept string?, got:\n{output}"
        );
        // Body: wrapper converts string to SEL via sel_registerName
        assert!(
            output.contains("(sel_registerName action)"),
            "SEL param should be wrapped with sel_registerName in body, got:\n{output}"
        );
    }

    // --- NSScreen duplicate property deduplication ---

    #[test]
    fn test_effective_properties_deduplicates_by_racket_name() {
        // ObjC extracts "CGDirectDisplayID", Swift extracts "cgDirectDisplayID"
        // Both map to the same Racket name "nsscreen-cg-direct-display-id"
        let cls = Class {
            name: "NSScreen".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![
                make_test_property(
                    "CGDirectDisplayID",
                    TypeRefKind::Primitive {
                        name: "uint32".into(),
                    },
                    true,
                ),
                make_test_property(
                    "cgDirectDisplayID",
                    TypeRefKind::Primitive {
                        name: "uint32".into(),
                    },
                    true,
                ),
            ],
            methods: vec![],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let props = effective_properties(&cls);
        assert_eq!(
            props.len(),
            1,
            "Properties with the same Racket name should be deduplicated, got: {:?}",
            props.iter().map(|p| &p.name).collect::<Vec<_>>()
        );
    }

    #[test]
    fn test_nsscreen_no_duplicate_define() {
        let cls = Class {
            name: "NSScreen".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![
                make_test_property(
                    "CGDirectDisplayID",
                    TypeRefKind::Primitive {
                        name: "uint32".into(),
                    },
                    true,
                ),
                make_test_property(
                    "cgDirectDisplayID",
                    TypeRefKind::Primitive {
                        name: "uint32".into(),
                    },
                    true,
                ),
            ],
            methods: vec![],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "AppKit", None);
        let count = output
            .matches("(define (nsscreen-cg-direct-display-id")
            .count();
        assert_eq!(
            count, 1,
            "Should have exactly one define for nsscreen-cg-direct-display-id, got {count}"
        );
    }

    // --- NSMenuItem class method vs instance property collision ---

    #[test]
    fn test_class_method_not_suppressed_by_instance_property() {
        // +separatorItem (class method returning NSMenuItem*) should NOT be
        // suppressed by the instance property "separatorItem" (bool)
        let cls = Class {
            name: "NSMenuItem".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![make_test_property(
                "separatorItem",
                TypeRefKind::Primitive {
                    name: "bool".into(),
                },
                true,
            )],
            methods: vec![
                make_test_method(
                    "separatorItem",
                    true, // class method
                    false,
                    vec![],
                    TypeRef {
                        nullable: false,
                        kind: TypeRefKind::Class {
                            name: "NSMenuItem".into(),
                            framework: None,
                            params: vec![],
                        },
                    },
                ),
                make_test_method(
                    "isSeparatorItem",
                    false, // instance method
                    false,
                    vec![],
                    TypeRef {
                        nullable: false,
                        kind: TypeRefKind::Primitive {
                            name: "bool".into(),
                        },
                    },
                ),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "AppKit", None);

        // The class method +separatorItem should be emitted (returns an object)
        assert!(
            output.contains("(define (nsmenuitem-separator-item)"),
            "Class method +separatorItem should be emitted as nsmenuitem-separator-item (no self param), got:\n{output}"
        );
        // The instance property getter should be suppressed (class method wins)
        assert!(
            !output.contains("(define (nsmenuitem-separator-item self)"),
            "Instance property getter should be suppressed when class method claims the same name, got:\n{output}"
        );
        // Exactly one define for the name
        let count = output.matches("(define (nsmenuitem-separator-item").count();
        assert_eq!(
            count, 1,
            "Should have exactly one define for nsmenuitem-separator-item, got {count}"
        );
        // The instance method isSeparatorItem should also be emitted
        assert!(
            output.contains("(define (nsmenuitem-is-separator-item self)"),
            "Instance method isSeparatorItem should be emitted, got:\n{output}"
        );
    }

    #[test]
    fn test_class_method_suppressed_by_class_property() {
        // A class method SHOULD still be suppressed if it collides with a class property
        let cls = Class {
            name: "NSFont".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![make_test_class_property(
                "systemFontSize",
                TypeRefKind::Primitive {
                    name: "double".into(),
                },
                true,
            )],
            methods: vec![make_test_method(
                "systemFontSize",
                true, // class method
                false,
                vec![],
                TypeRef {
                    nullable: false,
                    kind: TypeRefKind::Primitive {
                        name: "double".into(),
                    },
                },
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "AppKit", None);
        let count = output.matches("(define (nsfont-system-font-size").count();
        assert_eq!(
            count, 1,
            "Class property and class method with same name should produce only one define, got {count}"
        );
    }

    // --- Enrichment metadata comments ---

    fn type_block() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Block {
                params: vec![],
                return_type: Box::new(type_void()),
            },
        }
    }

    #[test]
    fn test_enrichment_async_block_note_precedes_define() {
        use apianyware_macos_types::enrichment::{BlockMethodEntry, EnrichmentData};

        let cls = Class {
            name: "TKLoader".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "loadWithHandler:",
                false,
                false,
                vec![Param {
                    name: "handler".to_string(),
                    param_type: type_block(),
                }],
                type_void(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let enrichment = EnrichmentData {
            async_block_methods: vec![BlockMethodEntry {
                class: "TKLoader".to_string(),
                selector: "loadWithHandler:".to_string(),
                param_index: 0,
            }],
            ..EnrichmentData::default()
        };
        let output = generate_class_file(&cls, "TestKit", Some(&enrichment));

        let note = ";; block param 0: async-copied (runtime-managed)";
        assert!(
            output.contains(note),
            "expected enrichment note in output, got:\n{output}"
        );
        // The note line must appear immediately before the method's `(define ...)`.
        let note_pos = output.find(note).expect("note present");
        let define_pos = output
            .find("(define (tkloader-load-with-handler self")
            .expect("method define present");
        assert!(
            note_pos < define_pos,
            "note must precede the method define, got:\n{output}"
        );
        let between = &output[note_pos + note.len()..define_pos];
        assert!(
            between.trim().is_empty(),
            "note must directly precede the define, found `{between}` between them"
        );
    }

    #[test]
    fn test_enrichment_unannotated_method_gets_no_note() {
        use apianyware_macos_types::enrichment::EnrichmentData;

        let cls = Class {
            name: "TKLoader".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "description",
                false,
                false,
                vec![],
                type_id(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let output = generate_class_file(&cls, "TestKit", Some(&EnrichmentData::default()));
        assert!(
            !output.contains(";; block param"),
            "unannotated method must get no metadata comment, got:\n{output}"
        );
    }

    #[test]
    fn test_enrichment_main_thread_header_comment() {
        use apianyware_macos_types::enrichment::EnrichmentData;

        let cls = Class {
            name: "TKView".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "description",
                false,
                false,
                vec![],
                type_id(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let enrichment = EnrichmentData {
            main_thread_classes: vec!["TKView".to_string()],
            ..EnrichmentData::default()
        };
        let output = generate_class_file(&cls, "TestKit", Some(&enrichment));
        assert!(
            output.contains(";; Threading: this class has main-thread-only methods."),
            "expected main-thread header comment, got:\n{output}"
        );

        // A class not in the main-thread set gets no threading comment.
        let plain = generate_class_file(&cls, "TestKit", Some(&EnrichmentData::default()));
        assert!(
            !plain.contains(";; Threading:"),
            "non-main-thread class must get no threading comment, got:\n{plain}"
        );
    }

    // --- Generated native dispatch routing (ADR-0013) ---

    fn type_u64() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "uint64".into(),
            },
        }
    }

    fn type_i64() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Primitive {
                name: "int64".into(),
            },
        }
    }

    fn type_instancetype() -> TypeRef {
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Instancetype,
        }
    }

    #[test]
    fn native_dispatch_scalar_return_method() {
        // A typed scalar method (int64 arg -> int64) routes through the generated
        // native entry: receiver + selector bridged to ptr_t, scalar arg direct.
        let cls = Class {
            name: "TKView".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "computeWithValue:",
                false,
                false,
                vec![Param {
                    name: "value".into(),
                    param_type: type_i64(),
                }],
                type_i64(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let out = generate_class_file(&cls, "TestKit", None);
        // ffi2 header + native binding + routed body.
        assert!(
            out.contains("\"../../runtime/ffi2-dispatch.rkt\""),
            "native header:\n{out}"
        );
        assert!(
            out.contains("(define-aw-msg aw_racket_msg_q_q (-> ptr_t ptr_t int64_t int64_t))"),
            "scalar binding:\n{out}"
        );
        assert!(
            out.contains("(aw_racket_msg_q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName \"computeWithValue:\")) value)"),
            "scalar routed body:\n{out}"
        );
    }

    #[test]
    fn native_dispatch_object_return_method() {
        // A typed object-returning method (uint64 arg -> id) routes natively and
        // re-tags the ptr_t result as _id for wrap-objc-object. Not retained.
        let cls = Class {
            name: "TKArray".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "objectAtIndex:",
                false,
                false,
                vec![Param {
                    name: "index".into(),
                    param_type: type_u64(),
                }],
                type_id(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let out = generate_class_file(&cls, "TestKit", None);
        assert!(
            out.contains("(define-aw-msg aw_racket_msg_Q_P (-> ptr_t ptr_t uint64_t ptr_t))"),
            "object binding:\n{out}"
        );
        assert!(
            out.contains("(ffi2-ptr->id (aw_racket_msg_Q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName \"objectAtIndex:\")) index))"),
            "object routed body:\n{out}"
        );
        assert!(out.contains("(wrap-objc-object"), "object wrap:\n{out}");
        // objectAtIndex: is not a +1 family → the wrap closes without a
        // #:retained finalizer (the `)) ` after the routed call, not `#:retained`).
        assert!(
            out.contains("\"objectAtIndex:\")) index))\n   ))"),
            "non-retained object return must close without #:retained:\n{out}"
        );
    }

    #[test]
    fn native_dispatch_typed_constructor() {
        // A typed init (uint64 -> instancetype) routes natively; receiver is
        // [Class alloc], result is the +1 owned object.
        let cls = Class {
            name: "TKArray".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "initWithCapacity:",
                false,
                true,
                vec![Param {
                    name: "capacity".into(),
                    param_type: type_u64(),
                }],
                type_instancetype(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let out = generate_class_file(&cls, "TestKit", None);
        assert!(
            out.contains("(ffi2-ptr->id (aw_racket_msg_Q_P (id->ffi2-ptr (tell TKArray alloc)) (id->ffi2-ptr (sel_registerName \"initWithCapacity:\")) capacity))"),
            "constructor routed body:\n{out}"
        );
        assert!(
            out.contains("#:retained #t"),
            "constructor +1 retained:\n{out}"
        );
    }

    fn type_nsrect() -> TypeRef {
        // libclang models geometry typedefs (NSRect/CGRect/…) as aliases; the FFI
        // mapper maps the alias to the `_NSRect` cstruct.
        TypeRef {
            nullable: false,
            kind: TypeRefKind::Alias {
                name: "NSRect".into(),
                framework: None,
                underlying_primitive: None,
            },
        }
    }

    #[test]
    fn native_dispatch_struct_return_and_param_property() {
        // A read-write struct-by-value property (`frame`) — the §3 8× headline.
        // Getter routes through the struct-return entry (out-buffer → cstruct);
        // setter routes through the struct-param entry (cstruct pointer → ptr_t).
        let cls = Class {
            name: "TKView".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![Property {
                name: "frame".into(),
                property_type: type_nsrect(),
                readonly: false,
                class_property: false,
                is_copy: false,
                deprecated: false,
                source: None,
                provenance: None,
                doc_refs: None,
                origin: None,
                objc_exposed: true,
            }],
            methods: vec![],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let out = generate_class_file(&cls, "TestKit", None);

        // Distinct content-addressed entries for the return vs param positions,
        // even though both cross ffi2 as an out-buffer/by-pointer ptr_t.
        assert!(
            out.contains("(define-aw-msg aw_racket_msg_0_R (-> ptr_t ptr_t ptr_t void_t))"),
            "struct-return binding (out-buffer + void result):\n{out}"
        );
        assert!(
            out.contains("(define-aw-msg aw_racket_msg_R_v (-> ptr_t ptr_t ptr_t void_t))"),
            "struct-param binding:\n{out}"
        );

        // Getter: allocate a cstruct out-buffer, write through it natively, hand
        // back the `_NSRect` cstruct (the established `ffi/unsafe` rep).
        assert!(
            out.contains("(let ([buf (malloc _NSRect)])"),
            "getter allocates cstruct out-buffer:\n{out}"
        );
        assert!(
            out.contains("(aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName \"frame\")) (cpointer->ptr_t buf))"),
            "getter passes out-buffer pointer to native entry:\n{out}"
        );
        assert!(
            out.contains("(ptr-ref buf _NSRect)))"),
            "getter hands back the cstruct:\n{out}"
        );

        // Setter: the cstruct value's pointer crosses as ptr_t.
        assert!(
            out.contains("(aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName \"setFrame:\")) (id->ffi2-ptr value))"),
            "setter bridges struct param by pointer:\n{out}"
        );

        // type-mapping.rkt require is present (for the cstruct + malloc/ptr-ref).
        assert!(
            out.contains("\"../../runtime/type-mapping.rkt\""),
            "struct file requires type-mapping.rkt:\n{out}"
        );
    }

    #[test]
    fn native_dispatch_struct_return_method() {
        // A struct-returning instance method (not a property) routes the same way.
        let cls = Class {
            name: "TKView".to_string(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_test_method(
                "convertedFrame",
                false,
                false,
                vec![],
                type_nsrect(),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        let out = generate_class_file(&cls, "TestKit", None);
        assert!(
            out.contains("(let ([buf (malloc _NSRect)])"),
            "struct-return method allocates out-buffer:\n{out}"
        );
        assert!(
            out.contains("(aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName \"convertedFrame\")) (cpointer->ptr_t buf))"),
            "struct-return method routes natively:\n{out}"
        );
        assert!(
            out.contains("(ptr-ref buf _NSRect)))"),
            "struct-return method hands back the cstruct:\n{out}"
        );
    }
}

//! Racket class file code generation.
//!
//! Produces a single `.rkt` file for an ObjC class, including:
//! - Module header (requires, framework loading)
//! - Shared typed objc_msgSend bindings
//! - Constructor wrappers (init methods)
//! - Property accessors (getters + setters)
//! - Method wrappers (instance + class methods)

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::ffi_type_mapping::{FfiTypeMapper, RacketFfiTypeMapper};
use apianyware_macos_emit::naming::{camel_to_kebab, class_name_to_lowercase};
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::{Class, Method, Param, Property};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

use crate::emit_functions::map_contract;
use crate::method_filter::{
    all_params_are_object_type, dispatch_strategy, is_supported_method, returns_object_type,
    returns_void, DispatchStrategy,
};
use crate::naming::{
    make_class_method_name, make_class_property_getter_name, make_class_property_setter_name,
    make_constructor_name, make_method_name, make_property_getter_name, make_property_setter_name,
    make_unique_constructor_name,
};
use crate::shared_signatures::{
    block_ffi_types, class_has_blocks, class_has_struct_types, collect_class_signatures,
    SignatureMap,
};

/// Generate a complete Racket class binding file.
pub fn generate_class_file(cls: &Class, framework: &str) -> String {
    let mapper = RacketFfiTypeMapper;
    let mut w = CodeWriter::new();

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

    // Separate method categories
    let init_methods: Vec<&Method> = methods.iter().filter(|m| m.init_method).copied().collect();
    let class_methods: Vec<&Method> = methods
        .iter()
        .filter(|m| {
            m.class_method
                && !m.init_method
                && !method_collides_with_property(&cls.name, m, &prop_names.class_property_names)
        })
        .copied()
        .collect();
    let instance_methods: Vec<&Method> = methods
        .iter()
        .filter(|m| {
            !m.class_method
                && !m.init_method
                && !method_collides_with_property(&cls.name, m, &prop_names.instance_property_names)
        })
        .copied()
        .collect();

    let needs_blocks = class_has_blocks(cls);
    let needs_structs = class_has_struct_types(cls, &mapper);
    let sig_map = collect_class_signatures(cls, &mapper);

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

    // Build export contracts
    let exports = build_export_contracts(
        cls,
        &properties,
        &init_methods,
        &instance_methods,
        &class_methods,
        &class_method_disambig,
        &class_property_disambig,
    );

    // Collect class names for return-type predicates (must be defined before
    // provide/contract references them)
    let return_class_names = collect_return_type_class_names(
        &properties,
        &init_methods,
        &instance_methods,
        &class_methods,
    );

    // Header
    emit_header(&mut w, &cls.name, framework, needs_blocks, needs_structs);

    // Class-specific return predicates (must precede provide/contract)
    emit_class_predicates(&mut w, &return_class_names);

    // Provide with contracts
    emit_provide(&mut w, &cls.name, &exports);

    // Class reference
    w.line(";; --- Class reference ---");
    write_line!(w, "(import-class {})", cls.name);

    // Shared msgSend bindings
    emit_shared_msg_bindings(&mut w, &sig_map);

    // Constructors
    let needs_default_constructor = !has_explicit_constructor(&init_methods);
    if !init_methods.is_empty() || needs_default_constructor {
        w.line(";; --- Constructors ---");
        for m in &init_methods {
            emit_constructor(&mut w, &cls.name, m, &sig_map, &mapper);
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
            emit_property(&mut w, &cls.name, p, disambig, &sig_map, &mapper);
        }
        w.blank_line();
    }

    // Instance methods
    if !instance_methods.is_empty() {
        w.line(";; --- Instance methods ---");
        for m in &instance_methods {
            emit_method(&mut w, &cls.name, m, false, false, &sig_map, &mapper);
        }
    }

    // Class methods
    if !class_methods.is_empty() {
        w.blank_line();
        w.line(";; --- Class methods ---");
        for m in &class_methods {
            let disambig = class_method_disambig.contains(&m.selector);
            emit_method(&mut w, &cls.name, m, true, disambig, &sig_map, &mapper);
        }
    }

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

/// Contract for the `self` parameter of instance-method wrappers, instance
/// property getters, and instance property setters.
///
/// `objc-object?` is the runtime's struct wrapping an ObjC `_id` pointer
/// with release-finalizer GC plumbing; it is what every constructor
/// returns via `wrap-objc-object`, so normal user code always has the
/// right shape. Tightening from `any/c` catches "you passed a number /
/// string / cpointer you got from somewhere else" at the wrapper's
/// contract boundary rather than deep inside `coerce-arg`'s cond dispatch.
/// `objc-object?` is in scope in every generated class wrapper because
/// the wrapper requires `coerce.rkt`, which re-exports everything from
/// `objc-base.rkt`.
const SELF_CONTRACT: &str = "objc-object?";

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

/// Collect class names referenced in return types of properties and methods.
/// Returns a sorted, deduplicated set of ObjC class names that need
/// predicate definitions in the generated file.
fn collect_return_type_class_names(
    properties: &[&Property],
    init_methods: &[&Method],
    instance_methods: &[&Method],
    class_methods: &[&Method],
) -> Vec<String> {
    let mut names = std::collections::BTreeSet::new();
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
fn build_export_contracts(
    cls: &Class,
    properties: &[&Property],
    init_methods: &[&Method],
    instance_methods: &[&Method],
    class_methods: &[&Method],
    class_method_disambig: &std::collections::HashSet<String>,
    class_property_disambig: &std::collections::HashSet<String>,
) -> Vec<ExportContract> {
    let mut exports = Vec::new();

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
    if !has_explicit_constructor(init_methods) {
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
            format_arrow_contract(&[SELF_CONTRACT.to_string()], &return_contract)
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
                vec![SELF_CONTRACT.to_string()]
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

    // Instance methods: (-> objc-object? param-contracts... return-contract)
    for m in instance_methods {
        if !is_supported_method(m) {
            continue;
        }
        let name = make_method_name(&cls.name, &m.selector);
        let mut param_contracts = vec![SELF_CONTRACT.to_string()];
        param_contracts.extend(m.params.iter().map(|p| map_param_contract(&p.param_type)));
        let return_contract = map_return_contract(&m.return_type);
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
        let param_contracts: Vec<String> = m
            .params
            .iter()
            .map(|p| map_param_contract(&p.param_type))
            .collect();
        let return_contract = map_return_contract(&m.return_type);
        let contract = format_arrow_contract(&param_contracts, &return_contract);
        exports.push(ExportContract { name, contract });
    }

    exports
}

// --- Header ---

fn emit_header(
    w: &mut CodeWriter,
    class_name: &str,
    framework: &str,
    needs_blocks: bool,
    needs_structs: bool,
) {
    w.line("#lang racket/base");
    write_line!(w, ";; Generated binding for {} ({})", class_name, framework);
    w.line(";; Do not edit — regenerate from enriched IR");
    w.blank_line();
    w.line("(require ffi/unsafe");
    w.raw("         ffi/unsafe/objc\n");
    // `racket/contract` and `ffi/unsafe` both export `->` with different
    // semantics (contract arrow vs `_fun` type arrow). Rename the contract
    // arrow to `c->` so both are usable in the same module.
    w.raw("         (rename-in racket/contract [-> c->])\n");
    w.raw("         \"../../../runtime/objc-base.rkt\"\n");
    w.raw("         \"../../../runtime/coerce.rkt\"");
    if needs_blocks {
        w.raw("\n         \"../../../runtime/block.rkt\"");
    }
    if needs_structs {
        w.raw("\n         \"../../../runtime/type-mapping.rkt\"");
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

fn emit_shared_msg_bindings(w: &mut CodeWriter, sig_map: &SignatureMap) {
    if sig_map.is_empty() {
        w.blank_line();
        return;
    }

    w.blank_line();
    w.line(";; --- Shared typed objc_msgSend bindings ---");
    for (key, id) in sig_map.iter_sorted() {
        let (param_str, ret_str) = SignatureMap::parse_key(key);
        let param_types: Vec<&str> = if param_str.is_empty() {
            vec![]
        } else {
            param_str.split(' ').collect()
        };

        // Comment showing the signature
        let mut comment = format!("(define _msg-{id}  ; (_fun _pointer _pointer");
        for pt in &param_types {
            comment.push(' ');
            comment.push_str(pt);
        }
        comment.push_str(&format!(" -> {ret_str})"));
        w.line(&comment);

        // Binding definition
        let mut binding =
            String::from("  (get-ffi-obj \"objc_msgSend\" _objc-lib (_fun _pointer _pointer");
        for pt in &param_types {
            binding.push(' ');
            binding.push_str(pt);
        }
        binding.push_str(&format!(" -> {ret_str})))"));
        w.line(&binding);
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
    sig_map: &SignatureMap,
    mapper: &dyn FfiTypeMapper,
) {
    if !is_supported_method(method) || method.selector == "init" {
        return;
    }

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
        emit_typed_constructor(w, class_name, method, &param_names, sig_map, mapper);
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
            w.raw("           (_fun _pointer _pointer");
            for pt in &param_types {
                w.raw(&format!(" {pt}"));
            }
            w.raw_line(" -> _id))]");
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
) {
    let getter_name = if prop.class_property {
        make_class_property_getter_name(class_name, &prop.name, disambiguate)
    } else {
        make_property_getter_name(class_name, &prop.name)
    };
    let ffi_type = mapper.map_type(&prop.property_type, false);

    // Getter
    // Property getters return autoreleased (+0) objects, so #:retained is #f (default).
    if prop.class_property && ffi_type == "_id" {
        write_line!(w, "(define ({})", getter_name);
        write_line!(w, "  (wrap-objc-object");
        write_line!(w, "   (tell {} {})))", class_name, prop.name);
    } else if ffi_type == "_id" {
        write_line!(w, "(define ({} self)", getter_name);
        write_line!(w, "  (wrap-objc-object");
        write_line!(w, "   (tell (coerce-arg self) {})))", prop.name);
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

        // For SEL-typed property setters, wrap value with sel_registerName
        let is_sel_prop = matches!(prop.property_type.kind, TypeRefKind::Selector);
        let value_expr = if is_sel_prop {
            "(sel_registerName value)"
        } else {
            "value"
        };

        if ffi_type == "_id" {
            write_line!(w, "(define ({}{} value)", setter_name, params);
            write_line!(
                w,
                "  (tell #:type _void {} {} (coerce-arg value)))",
                target,
                setter_sel
            );
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
                    write_line!(
                        w,
                        "              (_fun _pointer _pointer {} -> _void))])",
                        ffi_type
                    );
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

fn emit_method(
    w: &mut CodeWriter,
    class_name: &str,
    method: &Method,
    is_class_method: bool,
    disambiguate: bool,
    sig_map: &SignatureMap,
    mapper: &dyn FfiTypeMapper,
) {
    if !is_supported_method(method) {
        return;
    }

    let param_names: Vec<String> = method
        .params
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

    let strategy = dispatch_strategy(method, mapper);

    match strategy {
        DispatchStrategy::Tell => {
            let target = if is_class_method {
                class_name.to_string()
            } else {
                "(coerce-arg self)".to_string()
            };
            let tell_args = format_tell_args(&method.selector, &param_names, &method.params);
            if ret_is_id && !ret_is_void {
                w.line("  (wrap-objc-object");
                if retained {
                    write_line!(w, "   (tell {} {})", target, tell_args);
                    w.line("   #:retained #t))");
                } else {
                    write_line!(w, "   (tell {} {})))", target, tell_args);
                }
            } else if ret_is_void {
                // `#:type _void` ensures the underlying objc_msgSend binding
                // declares a void return, matching the C ABI. Without this,
                // `tell` defaults to `_id`-returning, which is a calling-
                // convention mismatch on arm64e (PAC) and reads garbage from
                // the return register on any platform.
                write_line!(w, "  (tell #:type _void {} {}))", target, tell_args);
            } else {
                write_line!(w, "  (tell {} {}))", target, tell_args);
            }
        }
        DispatchStrategy::TypedMsgSend => {
            let param_types: Vec<String> = method
                .params
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
            emit_block_wrapping(w, &method.params, &mut call_args, mapper);

            // Coerce id-kind params
            coerce_id_params(&method.params, &mut call_args, mapper);

            // Coerce SEL-typed params (string → sel_registerName)
            coerce_sel_params(&method.params, &mut call_args);

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
                    w.line("  (let ([msg (get-ffi-obj \"objc_msgSend\" _objc-lib");
                    w.raw("              (_fun _pointer _pointer");
                    for pt in &param_types {
                        w.raw(&format!(" {pt}"));
                    }
                    w.raw(&format!(" -> {ret_ffi_type}))])\n"));
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
    }
}

// --- Helpers ---

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
            }],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
        };
        let output = generate_class_file(&cls, "Foundation");
        assert!(output.contains("#lang racket/base"));
        assert!(output.contains("(import-class NSObject)"));
        assert!(output.contains("(define (nsobject-description self)"));
        assert!(output.contains("wrap-objc-object"));
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
        };
        let output = generate_class_file(&cls, "Foundation");
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
        };
        let output = generate_class_file(&cls, "Foundation");
        // Instance method: (-> objc-object? return-contract)
        assert!(
            output.contains("[nsobject-description (c-> objc-object? any/c)]"),
            "Instance method should have tightened self + return contract. Output:\n{output}"
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
        };
        let output = generate_class_file(&cls, "TestKit");
        // Object getter: (-> objc-object? any/c)
        assert!(
            output.contains("[tkview-title (c-> objc-object? any/c)]"),
            "Object property getter contract. Output:\n{output}"
        );
        // Bool getter: (-> objc-object? boolean?)
        assert!(
            output.contains("[tkview-hidden (c-> objc-object? boolean?)]"),
            "Bool property getter contract. Output:\n{output}"
        );
    }

    #[test]
    fn test_id_property_setter_body_uses_void_typed_tell() {
        // Setter must emit `(tell #:type _void ...)` so the underlying
        // objc_msgSend binding matches the C ABI. The older form
        // `(void (tell ...))` discarded the result at the Racket level but
        // left objc_msgSend bound as `_id`-returning — a calling-convention
        // mismatch that matters on arm64e PAC.
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
        };
        let output = generate_class_file(&cls, "TestKit");
        assert!(
            output
                .contains("  (tell #:type _void (coerce-arg self) setTitle: (coerce-arg value)))"),
            "_id setter body must use `tell #:type _void`. Output:\n{output}"
        );
        assert!(
            !output.contains("(void (tell"),
            "Setter body must not use legacy `(void (tell ...))` form. Output:\n{output}"
        );
    }

    #[test]
    fn test_void_method_tell_dispatch_uses_void_typed_tell() {
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
        };
        let output = generate_class_file(&cls, "TestKit");
        assert!(
            output.contains("  (tell #:type _void (coerce-arg self) addObject: (coerce-arg obj)))"),
            "Void Tell-dispatch method body must use `tell #:type _void`. Output:\n{output}"
        );
        assert!(
            !output.contains("(void (tell"),
            "Method body must not use legacy `(void (tell ...))` form. Output:\n{output}"
        );
    }

    #[test]
    fn test_void_zero_arg_tell_dispatch_uses_void_typed_tell() {
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
        };
        let output = generate_class_file(&cls, "TestKit");
        assert!(
            output.contains("  (tell #:type _void (coerce-arg self) dealloc))"),
            "Zero-arg void Tell-dispatch body must use `tell #:type _void`. Output:\n{output}"
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
        };
        let output = generate_class_file(&cls, "TestKit");
        // Object setter: self + coerce-arg-matched union for the value.
        assert!(
            output.contains(
                "[tkview-set-title! (c-> objc-object? (or/c string? objc-object? #f) void?)]"
            ),
            "Object property setter contract. Output:\n{output}"
        );
        // Typed setter: (-> objc-object? exact-integer? void?)
        assert!(
            output.contains("[tkview-set-tag! (c-> objc-object? exact-integer? void?)]"),
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
                // `_id` class property: tell-dispatch setter path.
                make_test_class_property("defaultTitle", TypeRefKind::Id, false),
            ],
            methods: vec![],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
        };
        let output = generate_class_file(&cls, "TestKit");

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
            output.contains("(tell #:type _void TKWindow setDefaultTitle: (coerce-arg value))"),
            "Class-property _id setter body must tell the class directly. Output:\n{output}"
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
        };
        let output = generate_class_file(&cls, "TestKit");

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
        };
        let output = generate_class_file(&cls, "TestKit");
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
        };
        let output = generate_class_file(&cls, "TestKit");
        // (-> objc-object? exact-integer? void?)
        assert!(
            output.contains("[tkview-set-tag! (c-> objc-object? exact-integer? void?)]"),
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
        };
        let output = generate_class_file(&cls, "TestKit");
        // Block param → (or/c procedure? #f); self is objc-object?
        assert!(
            output.contains("(c-> objc-object? real? (or/c procedure? #f) void?)"),
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
        };
        let output = generate_class_file(&cls, "TestKit");
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
        };
        let output = generate_class_file(&cls, "TestKit");
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
        };
        let output = generate_class_file(&cls, "TestKit");
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
        };
        let output = generate_class_file(&cls, "TestKit");
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
        };
        let output = generate_class_file(&cls, "TestKit");
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
        };
        let output = generate_class_file(&cls, "TestKit");

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
        };
        let output = generate_class_file(&cls, "AppKit");
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
        };
        let output = generate_class_file(&cls, "AppKit");

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
        };
        let output = generate_class_file(&cls, "AppKit");
        let count = output.matches("(define (nsfont-system-font-size").count();
        assert_eq!(
            count, 1,
            "Class property and class method with same name should produce only one define, got {count}"
        );
    }
}

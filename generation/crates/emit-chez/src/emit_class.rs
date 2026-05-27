//! Chez class file emission.
//!
//! Each ObjC class becomes a single Chez `library` whose body holds:
//!   - a `foreign-procedure` binding per emitted method's typed
//!     `objc_msgSend` signature
//!   - a cached selector pointer per method
//!   - a Scheme procedure wrapping each method, coercing args and
//!     wrapping `id`-typed returns through `wrap-objc-object`.
//!
//! The 070 scaffold deliberately keeps each call site self-contained —
//! shared-signature deduplication is leaf 080. The goal here is a working
//! Foundation surface; the surface only narrows the set of supported
//! methods (see `method_filter`) where leaf 080 will widen it.

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_emit::naming::class_name_to_lowercase;
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::{Class, Method, Param, Property};
use apianyware_macos_types::type_ref::TypeRefKind;

use crate::ffi_type_mapping::ChezFfiTypeMapper;
use crate::method_filter::{is_supported_method, returns_object_type, returns_void};
use crate::naming::{
    make_class_method_name, make_class_property_getter_name, make_class_property_setter_name,
    make_method_name, make_msgsend_binding_name, make_property_getter_name,
    make_property_setter_name, make_selector_binding_name, make_unique_constructor_name,
};

/// Generate the full `.sls` library text for one class.
pub fn generate_class_file(cls: &Class, framework: &str) -> String {
    let mapper = ChezFfiTypeMapper;
    let mut w = CodeWriter::new();

    let methods = effective_methods(cls);
    let mut properties = effective_properties(cls);

    // Names produced by each method category, so we can suppress whichever
    // side loses a collision. Mirrors the racket emitter's resolution:
    //   - class methods win over instance properties that share their name
    //   - instance/class properties win over instance/class methods that
    //     share their name (NSString.length is the canonical case: both a
    //     property and a method exist with that selector).
    let class_method_names: std::collections::HashSet<String> = methods
        .iter()
        .filter(|m| m.class_method && !m.init_method)
        .map(|m| make_method_name(&cls.name, &m.selector))
        .collect();

    // Drop instance properties whose getter name collides with a class
    // method — the factory method wins (e.g. +[NSMenuItem separatorItem]).
    properties.retain(|p| {
        if p.class_property {
            return true;
        }
        !class_method_names.contains(&make_property_getter_name(&cls.name, &p.name))
    });

    let instance_property_names: std::collections::HashSet<String> = properties
        .iter()
        .filter(|p| !p.class_property)
        .map(|p| make_property_getter_name(&cls.name, &p.name))
        .collect();
    let class_property_names: std::collections::HashSet<String> = properties
        .iter()
        .filter(|p| p.class_property)
        .map(|p| make_property_getter_name(&cls.name, &p.name))
        .collect();

    let init_methods: Vec<&Method> = methods.iter().filter(|m| m.init_method).copied().collect();
    let class_methods: Vec<&Method> = methods
        .iter()
        .filter(|m| {
            m.class_method
                && !m.init_method
                && !class_property_names.contains(&make_method_name(&cls.name, &m.selector))
        })
        .copied()
        .collect();
    let instance_methods: Vec<&Method> = methods
        .iter()
        .filter(|m| {
            !m.class_method
                && !m.init_method
                && !instance_property_names.contains(&make_method_name(&cls.name, &m.selector))
        })
        .copied()
        .collect();

    let exports = collect_exports(
        &cls.name,
        &properties,
        &init_methods,
        &instance_methods,
        &class_methods,
        &mapper,
    );

    emit_header(&mut w, cls, framework, &exports);

    if !init_methods.is_empty() {
        w.line(";; --- Constructors ---");
        for m in &init_methods {
            emit_constructor(&mut w, &cls.name, m, &mapper);
        }
        w.blank_line();
    }

    if !properties.is_empty() {
        w.line(";; --- Properties ---");
        for p in &properties {
            emit_property(&mut w, &cls.name, p, &mapper);
        }
        w.blank_line();
    }

    if !instance_methods.is_empty() {
        w.line(";; --- Instance methods ---");
        for m in &instance_methods {
            emit_method(&mut w, &cls.name, m, false, &mapper);
        }
        w.blank_line();
    }

    if !class_methods.is_empty() {
        w.line(";; --- Class methods ---");
        for m in &class_methods {
            emit_method(&mut w, &cls.name, m, true, &mapper);
        }
        w.blank_line();
    }

    // Close the (library ...) form.
    w.line(")");

    w.finish()
}

fn effective_methods(cls: &Class) -> Vec<&Method> {
    let methods: Vec<&Method> = if cls.all_methods.is_empty() {
        cls.methods.iter().collect()
    } else {
        cls.all_methods.iter().collect()
    };
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
    let mut seen = std::collections::HashSet::new();
    properties
        .into_iter()
        .filter(|p| seen.insert(make_property_getter_name("", &p.name)))
        .collect()
}

fn collect_exports(
    class_name: &str,
    properties: &[&Property],
    init_methods: &[&Method],
    instance_methods: &[&Method],
    class_methods: &[&Method],
    mapper: &dyn FfiTypeMapper,
) -> Vec<String> {
    let mut exports: Vec<String> = Vec::new();

    for m in init_methods {
        if !is_supported_method(m, mapper) || m.selector == "init" {
            continue;
        }
        exports.push(make_unique_constructor_name(class_name, &m.selector));
    }
    // Default constructor is always exported when there's no explicit init
    // suitable in the IR — mirrors emit-racket's synthesis behaviour. This
    // matches NSObject and any subclass that inherits `-init` unmodified.
    if !has_explicit_constructor(init_methods, mapper) {
        exports.push(format!("make-{}", class_name_to_lowercase(class_name)));
    }

    for p in properties {
        let getter = if p.class_property {
            make_class_property_getter_name(class_name, &p.name, false)
        } else {
            make_property_getter_name(class_name, &p.name)
        };
        exports.push(getter);
        if !p.readonly {
            let setter = if p.class_property {
                make_class_property_setter_name(class_name, &p.name, false)
            } else {
                make_property_setter_name(class_name, &p.name)
            };
            exports.push(setter);
        }
    }

    for m in instance_methods {
        if !is_supported_method(m, mapper) {
            continue;
        }
        exports.push(make_method_name(class_name, &m.selector));
    }

    for m in class_methods {
        if !is_supported_method(m, mapper) {
            continue;
        }
        exports.push(make_class_method_name(class_name, &m.selector, false));
    }

    exports.sort();
    exports.dedup();
    exports
}

fn has_explicit_constructor(init_methods: &[&Method], mapper: &dyn FfiTypeMapper) -> bool {
    init_methods
        .iter()
        .any(|m| is_supported_method(m, mapper) && m.selector != "init")
}

fn library_path_components(class_name: &str, framework: &str) -> (String, String) {
    let fw = framework.to_ascii_lowercase();
    let cls = class_name_to_lowercase(class_name);
    (fw, cls)
}

fn emit_header(w: &mut CodeWriter, cls: &Class, framework: &str, exports: &[String]) {
    let (fw, cls_low) = library_path_components(&cls.name, framework);
    write_line!(
        w,
        ";; Generated binding for {} ({}) — do not edit",
        cls.name,
        framework
    );
    write_line!(w, "(library (apianyware {} {})", fw, cls_low);

    if exports.is_empty() {
        w.line("  (export)");
    } else {
        w.line("  (export");
        for name in exports {
            write_line!(w, "    {}", name);
        }
        w.line("    )");
    }

    w.line("  (import (chezscheme)");
    w.line("          (apianyware runtime ffi)");
    w.line("          (apianyware runtime objc)");
    w.line("          (apianyware runtime types))");
    w.blank_line();
}

// --- emission helpers ----------------------------------------------------

fn emit_msg_binding(
    w: &mut CodeWriter,
    class_name: &str,
    method: &Method,
    mapper: &dyn FfiTypeMapper,
) -> (String, Vec<String>, String) {
    let binding = make_msgsend_binding_name(class_name, &method.selector);
    // objc_msgSend(receiver, selector, args...) — first two args are always void*.
    let mut arg_types: Vec<String> = vec!["void*".into(), "void*".into()];
    for p in &method.params {
        arg_types.push(mapper.map_type(&p.param_type, false));
    }
    let ret = mapper.map_type(&method.return_type, true);
    write_line!(
        w,
        "  (define {} (foreign-procedure \"objc_msgSend\" ({}) {}))",
        binding,
        arg_types.join(" "),
        ret
    );
    (binding, arg_types, ret)
}

fn emit_selector_cache(w: &mut CodeWriter, class_name: &str, selector: &str) -> String {
    let sel_var = make_selector_binding_name(class_name, selector);
    write_line!(
        w,
        "  (define {} (sel-register \"{}\"))",
        sel_var,
        selector
    );
    sel_var
}

fn coerce_arg_expr(param: &Param, var: &str) -> String {
    match &param.param_type.kind {
        TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => {
            format!("(coerce-arg {})", var)
        }
        TypeRefKind::Selector => format!("(sel-register {})", var),
        _ => var.to_string(),
    }
}

fn param_var_names(params: &[Param]) -> Vec<String> {
    params
        .iter()
        .enumerate()
        .map(|(i, p)| {
            let base = apianyware_macos_emit::naming::camel_to_kebab(&p.name);
            if base.is_empty() {
                format!("arg{}", i)
            } else {
                base
            }
        })
        .collect()
}

fn emit_method(
    w: &mut CodeWriter,
    class_name: &str,
    method: &Method,
    is_class_method: bool,
    mapper: &dyn FfiTypeMapper,
) {
    if !is_supported_method(method, mapper) {
        return;
    }
    let (binding, _, _) = emit_msg_binding(w, class_name, method, mapper);
    let sel_var = emit_selector_cache(w, class_name, &method.selector);

    let fn_name = if is_class_method {
        make_class_method_name(class_name, &method.selector, false)
    } else {
        make_method_name(class_name, &method.selector)
    };

    let param_vars = param_var_names(&method.params);
    let mut sig = format!("(define ({}", fn_name);
    if !is_class_method {
        sig.push_str(" self");
    }
    for v in &param_vars {
        sig.push(' ');
        sig.push_str(v);
    }
    sig.push(')');
    write_line!(w, "  {}", sig);

    let receiver_expr = if is_class_method {
        format!("(objc_getClass \"{}\")", class_name)
    } else {
        "(coerce-arg self)".to_string()
    };

    let coerced_args: Vec<String> = method
        .params
        .iter()
        .zip(param_vars.iter())
        .map(|(p, v)| coerce_arg_expr(p, v))
        .collect();

    let call = format!(
        "({} {} {}{}{})",
        binding,
        receiver_expr,
        sel_var,
        if coerced_args.is_empty() { "" } else { " " },
        coerced_args.join(" ")
    );

    if returns_void(method, mapper) {
        write_line!(w, "    {})", call);
    } else if returns_object_type(method, mapper) {
        let retained = method_returns_retained(method);
        if retained {
            write_line!(w, "    (wrap-objc-object {} #t))", call);
        } else {
            write_line!(w, "    (wrap-objc-object {}))", call);
        }
    } else {
        write_line!(w, "    {})", call);
    }
    w.blank_line();
}

fn emit_constructor(
    w: &mut CodeWriter,
    class_name: &str,
    method: &Method,
    mapper: &dyn FfiTypeMapper,
) {
    if !is_supported_method(method, mapper) || method.selector == "init" {
        return;
    }
    let (binding, _, _) = emit_msg_binding(w, class_name, method, mapper);
    let sel_var = emit_selector_cache(w, class_name, &method.selector);
    let alloc_sel = "%sel-alloc-shared";

    // Lazily define a shared `alloc` selector cache inside the library — one
    // per library, hidden via the `%` prefix. We emit the selector cache only
    // once per file. Caller pattern: every constructor uses the same alloc.
    // Implementation here just emits the symbol; we define it via a single
    // anchor at the top of the file (see `ensure_alloc_selector_anchor`),
    // but the easiest robust shape is per-call: still cheap, since
    // `sel-register` itself caches.

    let fn_name = make_unique_constructor_name(class_name, &method.selector);
    let param_vars = param_var_names(&method.params);

    let mut sig = format!("(define ({}", fn_name);
    for v in &param_vars {
        sig.push(' ');
        sig.push_str(v);
    }
    sig.push(')');
    write_line!(w, "  {}", sig);

    write_line!(
        w,
        "    (let ([{} (sel-register \"alloc\")])",
        alloc_sel
    );

    let coerced_args: Vec<String> = method
        .params
        .iter()
        .zip(param_vars.iter())
        .map(|(p, v)| coerce_arg_expr(p, v))
        .collect();

    let alloc_call = format!(
        "(objc_msgSend (objc_getClass \"{}\") {})",
        class_name, alloc_sel
    );
    let init_call = format!(
        "({} {} {}{}{})",
        binding,
        alloc_call,
        sel_var,
        if coerced_args.is_empty() { "" } else { " " },
        coerced_args.join(" ")
    );

    // alloc/init owns +1 — wrap as retained.
    write_line!(w, "      (wrap-objc-object {} #t)))", init_call);
    w.blank_line();
}

fn emit_property(
    w: &mut CodeWriter,
    class_name: &str,
    prop: &Property,
    mapper: &dyn FfiTypeMapper,
) {
    // Defer property bodies that need geometry struct-by-value handling.
    if mapper.is_struct_type(&prop.property_type)
        || matches!(prop.property_type.kind, TypeRefKind::Block { .. })
    {
        return;
    }
    let getter_name = if prop.class_property {
        make_class_property_getter_name(class_name, &prop.name, false)
    } else {
        make_property_getter_name(class_name, &prop.name)
    };

    let getter_binding = format!(
        "%msg-{}-{}-getter",
        class_name_to_lowercase(class_name),
        apianyware_macos_emit::naming::camel_to_kebab(&prop.name)
    );
    let getter_sel = format!(
        "%sel-{}-{}-getter",
        class_name_to_lowercase(class_name),
        apianyware_macos_emit::naming::camel_to_kebab(&prop.name)
    );

    let ret_ty = mapper.map_type(&prop.property_type, true);
    write_line!(
        w,
        "  (define {} (foreign-procedure \"objc_msgSend\" (void* void*) {}))",
        getter_binding,
        ret_ty
    );
    write_line!(w, "  (define {} (sel-register \"{}\"))", getter_sel, prop.name);

    let receiver_expr = if prop.class_property {
        format!("(objc_getClass \"{}\")", class_name)
    } else {
        "(coerce-arg self)".to_string()
    };
    let getter_arglist = if prop.class_property { String::new() } else { " self".into() };
    write_line!(w, "  (define ({}{})", getter_name, getter_arglist);
    let call = format!("({} {} {})", getter_binding, receiver_expr, getter_sel);
    if mapper.is_object_type(&prop.property_type) {
        write_line!(w, "    (wrap-objc-object {}))", call);
    } else if mapper.is_void(&prop.property_type) {
        write_line!(w, "    {})", call);
    } else {
        write_line!(w, "    {})", call);
    }

    if !prop.readonly {
        let setter_name = if prop.class_property {
            make_class_property_setter_name(class_name, &prop.name, false)
        } else {
            make_property_setter_name(class_name, &prop.name)
        };
        let value_ty = mapper.map_type(&prop.property_type, false);
        let setter_binding = format!(
            "%msg-{}-{}-setter",
            class_name_to_lowercase(class_name),
            apianyware_macos_emit::naming::camel_to_kebab(&prop.name)
        );
        let setter_sel = format!(
            "%sel-{}-{}-setter",
            class_name_to_lowercase(class_name),
            apianyware_macos_emit::naming::camel_to_kebab(&prop.name)
        );
        let setter_selector_str = setter_selector_for(&prop.name);
        write_line!(
            w,
            "  (define {} (foreign-procedure \"objc_msgSend\" (void* void* {}) void))",
            setter_binding,
            value_ty
        );
        write_line!(w, "  (define {} (sel-register \"{}\"))", setter_sel, setter_selector_str);

        let setter_arglist: &str = if prop.class_property { "value" } else { "self value" };
        write_line!(w, "  (define ({} {})", setter_name, setter_arglist);

        let value_expr = match &prop.property_type.kind {
            TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => {
                "(coerce-arg value)".to_string()
            }
            TypeRefKind::Selector => "(sel-register value)".to_string(),
            _ => "value".to_string(),
        };
        write_line!(
            w,
            "    ({} {} {} {}))",
            setter_binding,
            receiver_expr,
            setter_sel,
            value_expr
        );
    }
    w.blank_line();
}

fn setter_selector_for(prop_name: &str) -> String {
    let first = prop_name.chars().next().unwrap_or('x');
    format!(
        "set{}{}:",
        first.to_uppercase(),
        &prop_name[first.len_utf8()..]
    )
}

fn method_returns_retained(method: &Method) -> bool {
    if let Some(r) = method.returns_retained {
        return r;
    }
    let sel = &method.selector;
    if !method.class_method && is_family_match(sel, "init") {
        return true;
    }
    if method.class_method && is_family_match(sel, "new") {
        return true;
    }
    is_family_match(sel, "copy") || is_family_match(sel, "mutableCopy")
}

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

#[cfg(test)]
mod tests {
    use super::*;
    use apianyware_macos_types::ir::Method;
    use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef { nullable: false, kind }
    }

    fn make_method(sel: &str, class_method: bool, init: bool, ret: TypeRef) -> Method {
        Method {
            selector: sel.into(),
            class_method,
            init_method: init,
            params: vec![],
            return_type: ret,
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

    #[test]
    fn renders_library_form() {
        let cls = Class {
            name: "NSString".into(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_method("length", false, false, ty(TypeRefKind::Primitive { name: "uint64".into() }))],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
        };
        let output = generate_class_file(&cls, "Foundation");
        assert!(output.contains("(library (apianyware foundation nsstring)"));
        assert!(output.contains("(define (nsstring-length self)"));
        assert!(output.contains("foreign-procedure \"objc_msgSend\""));
        assert!(output.contains("sel-register \"length\""));
    }

    #[test]
    fn class_method_uses_objc_get_class() {
        let cls = Class {
            name: "NSString".into(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_method("string", true, false, ty(TypeRefKind::Id))],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
        };
        let output = generate_class_file(&cls, "Foundation");
        assert!(output.contains("(define (nsstring-string)"));
        assert!(output.contains("(objc_getClass \"NSString\")"));
        assert!(output.contains("wrap-objc-object"));
    }
}


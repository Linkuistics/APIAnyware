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
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

use crate::ffi_type_mapping::{
    block_make_expr, is_known_geometry_alias, return_needs_indirect_result, ChezFfiTypeMapper,
};
use crate::method_filter::{is_supported_method, returns_object_type, returns_void};
use crate::naming::{
    make_class_method_name, make_class_property_getter_name, make_class_property_setter_name,
    make_method_name, make_msgsend_binding_name, make_property_getter_name,
    make_property_setter_name, make_selector_binding_name, make_unique_constructor_name,
};
use crate::shared_signatures::framework_shared_object_arg;

/// Generate the full `.sls` library text for one class.
pub fn generate_class_file(cls: &Class, framework: &str) -> String {
    let (content, _exports) = generate_class_file_with_exports(cls, framework);
    content
}

/// Compute the exported names for one class, in sorted order, without
/// generating the file body. Used by `emit_framework` to assemble the
/// per-framework `main.sls` re-export list — Chez `library` forms need
/// explicit export names, no `all-from-out` shortcut.
pub fn class_exports(cls: &Class) -> Vec<String> {
    let mapper = ChezFfiTypeMapper;
    compute_class_exports(cls, &mapper)
}

/// Compute exports + render the class file in a single pass.
pub fn generate_class_file_with_exports(cls: &Class, framework: &str) -> (String, Vec<String>) {
    let mapper = ChezFfiTypeMapper;
    let mut w = CodeWriter::new();

    let plan = build_class_plan(cls, &mapper);

    let needs_dispatch = plan_uses_block_bridge(&plan, &mapper);
    emit_header(&mut w, cls, framework, &plan.exports, needs_dispatch);

    let needs_default_constructor =
        !has_explicit_constructor(&plan.init_methods.iter().collect::<Vec<&Method>>(), &mapper);

    if !plan.init_methods.is_empty() || needs_default_constructor {
        w.line(";; --- Constructors ---");
        if needs_default_constructor {
            emit_default_constructor(&mut w, &cls.name);
        }
        for m in &plan.init_methods {
            emit_constructor(&mut w, &cls.name, m, &mapper);
        }
        w.blank_line();
    }

    if !plan.properties.is_empty() {
        w.line(";; --- Properties ---");
        for p in &plan.properties {
            emit_property(&mut w, &cls.name, p, &mapper);
        }
        w.blank_line();
    }

    if !plan.instance_methods.is_empty() {
        w.line(";; --- Instance methods ---");
        for m in &plan.instance_methods {
            emit_method(&mut w, &cls.name, m, false, &mapper);
        }
        w.blank_line();
    }

    if !plan.class_methods.is_empty() {
        w.line(";; --- Class methods ---");
        for m in &plan.class_methods {
            emit_method(&mut w, &cls.name, m, true, &mapper);
        }
        w.blank_line();
    }
    let exports = plan.exports;

    // Close the (library ...) form.
    w.line(")");

    (w.finish(), exports)
}

fn compute_class_exports(cls: &Class, mapper: &dyn FfiTypeMapper) -> Vec<String> {
    build_class_plan(cls, mapper).exports
}

/// True when any *supported, emitted* method in the plan takes a block
/// parameter — meaning its wrapper body calls `make-objc-block` /
/// `objc-block-ptr` and the class library must import
/// `(apianyware runtime dispatch)`.
fn plan_uses_block_bridge(plan: &ClassPlan, mapper: &dyn FfiTypeMapper) -> bool {
    let any_block = |m: &Method| {
        is_supported_method(m, mapper)
            && m.params
                .iter()
                .any(|p| matches!(p.param_type.kind, TypeRefKind::Block { .. }))
    };
    plan.init_methods.iter().any(any_block)
        || plan.instance_methods.iter().any(any_block)
        || plan.class_methods.iter().any(any_block)
}

/// Cleaned-up emission plan for one class. Owns clones of the methods and
/// properties so both `generate_class_file_with_exports` and
/// `compute_class_exports` can drive emission from the same data.
struct ClassPlan {
    properties: Vec<Property>,
    init_methods: Vec<Method>,
    instance_methods: Vec<Method>,
    class_methods: Vec<Method>,
    exports: Vec<String>,
}

fn build_class_plan(cls: &Class, mapper: &dyn FfiTypeMapper) -> ClassPlan {
    let methods_owned: Vec<Method> = effective_methods(cls).into_iter().cloned().collect();
    let mut properties_owned: Vec<Property> = effective_properties(cls)
        .into_iter()
        .filter(|p| {
            // Block-typed and unsupported-struct property bodies are
            // deferred (the emitter has no code for them yet — see
            // `emit_property`). Geometry-aliased structs are supported
            // via `(& <ftype>)`. Without filtering deferred ones here,
            // their names land in the export list with no matching
            // `define` and chez rejects the library.
            !is_unsupported_struct_property(&p.property_type, mapper)
                && !matches!(p.property_type.kind, TypeRefKind::Block { .. })
        })
        .cloned()
        .collect();

    // Pre-compute every Scheme name a class method would produce, so we
    // can suppress instance-property collisions (e.g. NSMenuItem's
    // class method `separatorItem` wins over a same-named instance
    // property).
    let class_method_names: std::collections::HashSet<String> = methods_owned
        .iter()
        .filter(|m| m.class_method && !m.init_method)
        .map(|m| make_method_name(&cls.name, &m.selector))
        .collect();

    properties_owned.retain(|p| {
        if p.class_property {
            return true;
        }
        !class_method_names.contains(&make_property_getter_name(&cls.name, &p.name))
    });

    // The four "blocked" name sets cover both getter and setter sides of
    // each property kind. Without setter coverage, NSTask's `setArguments:`
    // method and `arguments` property both yield `nstask-set-arguments!`
    // and chez rejects the duplicate define.
    let instance_property_getter_names: std::collections::HashSet<String> = properties_owned
        .iter()
        .filter(|p| !p.class_property)
        .map(|p| make_property_getter_name(&cls.name, &p.name))
        .collect();
    let instance_property_setter_names: std::collections::HashSet<String> = properties_owned
        .iter()
        .filter(|p| !p.class_property && !p.readonly)
        .map(|p| make_property_setter_name(&cls.name, &p.name))
        .collect();
    let class_property_getter_names: std::collections::HashSet<String> = properties_owned
        .iter()
        .filter(|p| p.class_property)
        .map(|p| make_property_getter_name(&cls.name, &p.name))
        .collect();
    let class_property_setter_names: std::collections::HashSet<String> = properties_owned
        .iter()
        .filter(|p| p.class_property && !p.readonly)
        .map(|p| make_class_property_setter_name(&cls.name, &p.name, false))
        .collect();

    let init_methods: Vec<Method> = methods_owned
        .iter()
        .filter(|m| m.init_method)
        .cloned()
        .collect();

    let class_methods: Vec<Method> = methods_owned
        .iter()
        .filter(|m| {
            if !m.class_method || m.init_method {
                return false;
            }
            let n = make_method_name(&cls.name, &m.selector);
            !class_property_getter_names.contains(&n) && !class_property_setter_names.contains(&n)
        })
        .cloned()
        .collect();

    let instance_methods: Vec<Method> = methods_owned
        .iter()
        .filter(|m| {
            if m.class_method || m.init_method {
                return false;
            }
            let n = make_method_name(&cls.name, &m.selector);
            !instance_property_getter_names.contains(&n)
                && !instance_property_setter_names.contains(&n)
        })
        .cloned()
        .collect();

    // Safety-net dedup: if any name still appears twice across the four
    // emission categories (rare — e.g. two different selectors collapsing
    // to the same kebab name), keep the first occurrence per precedence
    // order constructor > property > instance method > class method.
    let init_refs: Vec<&Method> = init_methods.iter().collect();
    let instance_refs: Vec<&Method> = instance_methods.iter().collect();
    let class_refs: Vec<&Method> = class_methods.iter().collect();
    let property_refs: Vec<&Property> = properties_owned.iter().collect();

    let raw_exports = collect_exports(
        &cls.name,
        &property_refs,
        &init_refs,
        &instance_refs,
        &class_refs,
        mapper,
    );

    let (filtered_props, filtered_inst, filtered_class, exports) = dedupe_across_categories(
        cls,
        properties_owned,
        instance_methods,
        class_methods,
        raw_exports,
    );

    ClassPlan {
        properties: filtered_props,
        init_methods,
        instance_methods: filtered_inst,
        class_methods: filtered_class,
        exports,
    }
}

/// Final dedup pass: walk the emitted name set in precedence order and
/// drop any later occurrence of a name already taken by an earlier
/// category. The pre-pass collision logic eliminates the common cases;
/// this is the safety net for `setX:` selectors that don't pattern-match
/// the property-setter convention but still kebab to the same name.
fn dedupe_across_categories(
    cls: &Class,
    properties: Vec<Property>,
    instance_methods: Vec<Method>,
    class_methods: Vec<Method>,
    raw_exports: Vec<String>,
) -> (Vec<Property>, Vec<Method>, Vec<Method>, Vec<String>) {
    let mut seen: std::collections::HashSet<String> = std::collections::HashSet::new();

    // Property getters (and setters) are first in precedence.
    let mut kept_props = Vec::new();
    for p in properties {
        let getter = if p.class_property {
            make_class_property_getter_name(&cls.name, &p.name, false)
        } else {
            make_property_getter_name(&cls.name, &p.name)
        };
        if seen.contains(&getter) {
            continue;
        }
        seen.insert(getter.clone());
        if !p.readonly {
            let setter = if p.class_property {
                make_class_property_setter_name(&cls.name, &p.name, false)
            } else {
                make_property_setter_name(&cls.name, &p.name)
            };
            seen.insert(setter);
        }
        kept_props.push(p);
    }

    let mut kept_inst = Vec::new();
    for m in instance_methods {
        let n = make_method_name(&cls.name, &m.selector);
        if seen.insert(n) {
            kept_inst.push(m);
        }
    }

    let mut kept_class = Vec::new();
    for m in class_methods {
        let n = make_method_name(&cls.name, &m.selector);
        if seen.insert(n) {
            kept_class.push(m);
        }
    }

    // Keep only export names that landed in `seen`. Constructor names go
    // through unconditionally (they're emitted before the dedup walk
    // touches anything else).
    let exports: Vec<String> = raw_exports
        .into_iter()
        .filter(|n| n.starts_with("make-") || seen.contains(n))
        .collect();

    (kept_props, kept_inst, kept_class, exports)
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

fn emit_header(
    w: &mut CodeWriter,
    cls: &Class,
    framework: &str,
    exports: &[String],
    needs_dispatch: bool,
) {
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

    // `(apianyware runtime objc)` exports a Scheme `nserror` record
    // (the error half of `(values result error)`) whose accessor names
    // overlap with NSError's instance properties (`nserror-domain`,
    // `nserror-code`, …). Excepting them from the import lets every
    // generated class library freely define those names; the runtime
    // accessors are still reachable from sample-app code via direct
    // `(apianyware runtime objc)` import.
    w.line("  (import (chezscheme)");
    w.line("          (apianyware runtime ffi)");
    w.line(
        "          (except (apianyware runtime objc) \
make-nserror nserror? nserror-domain nserror-code \
nserror-localised-description nserror-userinfo)",
    );
    // Methods with block parameters box the user's Scheme procedure via
    // `make-objc-block` / `objc-block-ptr` from the dispatch runtime;
    // import it only for classes that emit such a wrapper.
    if needs_dispatch {
        w.line("          (apianyware runtime types)");
        w.line("          (apianyware runtime dispatch))");
    } else {
        w.line("          (apianyware runtime types))");
    }
    w.blank_line();

    // Load the framework dylib at library instantiation. Without this,
    // `objc_getClass` for any class declared in this framework returns
    // a null pointer until something else in the process maps the dylib
    // in. Mirrors emit-racket's `_fw-lib` binding; the chez version
    // hides it in a dummy `define` because R6RS library bodies require
    // definitions before expressions.
    write_line!(
        w,
        "  (define %fw-lib-loaded (begin (load-shared-object \"{}\") #t))",
        framework_shared_object_arg(framework)
    );
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
    write_line!(w, "  (define {} (sel-register \"{}\"))", sel_var, selector);
    sel_var
}

fn coerce_arg_expr(param: &Param, var: &str, mapper: &dyn FfiTypeMapper) -> String {
    match &param.param_type.kind {
        TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => {
            format!("(coerce-arg {})", var)
        }
        TypeRefKind::Selector => format!("(sel-register {})", var),
        // A bridgeable block param: the user passes a bare Scheme procedure;
        // the wrapper boxes it into an ObjC block via `make-objc-block` and
        // passes the block pointer. `is_supported_method` has already
        // rejected un-bridgeable blocks, so this always succeeds. The block
        // record itself is discarded — async APIs (Block_copy/dispose) own
        // its lifetime; the chez-side code object's bounded retention
        // mirrors emit-racket (see runtime/dispatch.sls).
        TypeRefKind::Block {
            params,
            return_type,
        } => block_make_expr(var, params, return_type, mapper),
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
        .map(|(p, v)| coerce_arg_expr(p, v, mapper))
        .collect();

    let indirect_ftype = return_needs_indirect_result(&method.return_type);
    let leading_arg = if indirect_ftype.is_some() {
        "%result-buf "
    } else {
        ""
    };

    let call = format!(
        "({} {}{} {}{}{})",
        binding,
        leading_arg,
        receiver_expr,
        sel_var,
        if coerced_args.is_empty() { "" } else { " " },
        coerced_args.join(" ")
    );

    let wrapped = if returns_void(method, mapper) {
        call
    } else if returns_object_type(method, mapper) {
        let retained = method_returns_retained(method);
        if retained {
            format!("(wrap-objc-object {} #t)", call)
        } else {
            format!("(wrap-objc-object {})", call)
        }
    } else {
        call
    };

    if let Some(ftype) = indirect_ftype {
        // Chez's `(& ftype)` return convention: caller supplies the
        // result buffer as a hidden leading arg; the foreign-procedure's
        // direct return value is unspecified, so the wrapper must yield
        // `%result-buf` itself as the result.
        write_line!(
            w,
            "    (let ([%result-buf (make-ftype-pointer {} (foreign-alloc (ftype-sizeof {})))])",
            ftype,
            ftype
        );
        write_line!(w, "      {}", wrapped);
        write_line!(w, "      %result-buf))");
    } else {
        write_line!(w, "    {})", wrapped);
    }
    w.blank_line();
}

/// Synthesize the default `make-<class>` constructor when the class has
/// no explicit `initX:` initializer. Mirrors what emit-racket synthesizes
/// via `(tell (tell <Class> alloc) init)`, but expressed against the chez
/// runtime's fixed-arity (id, SEL) `objc_msgSend` form.
fn emit_default_constructor(w: &mut CodeWriter, class_name: &str) {
    let fn_name = format!("make-{}", class_name_to_lowercase(class_name));
    write_line!(w, "  (define ({})", fn_name);
    write_line!(w, "    (let ([alloc-sel (sel-register \"alloc\")]");
    w.line("          [init-sel  (sel-register \"init\")])");
    write_line!(w, "      (wrap-objc-object",);
    write_line!(w, "        (objc_msgSend",);
    write_line!(
        w,
        "          (objc_msgSend (objc_getClass \"{}\") alloc-sel)",
        class_name
    );
    w.line("          init-sel)");
    w.line("        #t)))");
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

    write_line!(w, "    (let ([{} (sel-register \"alloc\")])", alloc_sel);

    let coerced_args: Vec<String> = method
        .params
        .iter()
        .zip(param_vars.iter())
        .map(|(p, v)| coerce_arg_expr(p, v, mapper))
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
    // Defer property bodies the emitter can't honour: non-geometry
    // struct-by-value (no ftype in `runtime/types.sls`) and block-typed
    // properties (need `make-objc-block`).
    if is_unsupported_struct_property(&prop.property_type, mapper)
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
    let indirect_ftype = return_needs_indirect_result(&prop.property_type);
    write_line!(
        w,
        "  (define {} (foreign-procedure \"objc_msgSend\" (void* void*) {}))",
        getter_binding,
        ret_ty
    );
    write_line!(
        w,
        "  (define {} (sel-register \"{}\"))",
        getter_sel,
        prop.name
    );

    let receiver_expr = if prop.class_property {
        format!("(objc_getClass \"{}\")", class_name)
    } else {
        "(coerce-arg self)".to_string()
    };
    let getter_arglist = if prop.class_property {
        String::new()
    } else {
        " self".into()
    };
    write_line!(w, "  (define ({}{})", getter_name, getter_arglist);
    let leading_arg = if indirect_ftype.is_some() {
        "%result-buf "
    } else {
        ""
    };
    let call = format!(
        "({} {}{} {})",
        getter_binding, leading_arg, receiver_expr, getter_sel
    );
    let wrapped = if mapper.is_object_type(&prop.property_type) {
        format!("(wrap-objc-object {})", call)
    } else {
        call
    };
    if let Some(ftype) = indirect_ftype {
        write_line!(
            w,
            "    (let ([%result-buf (make-ftype-pointer {} (foreign-alloc (ftype-sizeof {})))])",
            ftype,
            ftype
        );
        write_line!(w, "      {}", wrapped);
        write_line!(w, "      %result-buf))");
    } else {
        write_line!(w, "    {})", wrapped);
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
        write_line!(
            w,
            "  (define {} (sel-register \"{}\"))",
            setter_sel,
            setter_selector_str
        );

        let setter_arglist: &str = if prop.class_property {
            "value"
        } else {
            "self value"
        };
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

/// A property's value type is an unsupported struct-by-value: it is a
/// struct kind the IR mapper recognises, but it isn't one of the curated
/// geometry aliases the chez runtime defines as an ftype.
fn is_unsupported_struct_property(t: &TypeRef, mapper: &dyn FfiTypeMapper) -> bool {
    if !mapper.is_struct_type(t) {
        return false;
    }
    let name = match &t.kind {
        TypeRefKind::Struct { name } => name,
        TypeRefKind::Alias { name, .. } => name,
        _ => return true,
    };
    !is_known_geometry_alias(name)
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
        TypeRef {
            nullable: false,
            kind,
        }
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
            objc_exposed: true,
        }
    }

    #[test]
    fn renders_library_form() {
        let cls = Class {
            name: "NSString".into(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_method(
                "length",
                false,
                false,
                ty(TypeRefKind::Primitive {
                    name: "uint64".into(),
                }),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
        };
        let output = generate_class_file(&cls, "Foundation");
        assert!(output.contains("(library (apianyware foundation nsstring)"));
        assert!(output.contains("(define (nsstring-length self)"));
        assert!(output.contains("foreign-procedure \"objc_msgSend\""));
        assert!(output.contains("sel-register \"length\""));
    }

    #[test]
    fn class_file_loads_framework_dylib_at_instantiation() {
        let cls = Class {
            name: "NSString".into(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_method(
                "length",
                false,
                false,
                ty(TypeRefKind::Primitive {
                    name: "uint64".into(),
                }),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
        };
        let output = generate_class_file(&cls, "Foundation");
        assert!(output.contains(
            "(load-shared-object \"/System/Library/Frameworks/Foundation.framework/Foundation\")"
        ));
    }

    #[test]
    fn large_struct_method_return_emits_indirect_result_buffer() {
        // NSRect > 16 bytes: the foreign-procedure declaration must
        // prepend `(& NSRect)` and the wrapper must allocate the buffer.
        let cls = Class {
            name: "NSView".into(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_method(
                "centerOfMassRect",
                false,
                false,
                ty(TypeRefKind::Alias {
                    name: "NSRect".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
        };
        let output = generate_class_file(&cls, "AppKit");
        // Per Chez `foreign-procedure` docs (`(& ftype)` return), the
        // declared `param-types` list stays `(void* void*)` — the extra
        // `(* ftype)` buffer arg is *implicit*: callers pass it as a
        // leading actual before all declared params. Only the wrapper
        // body changes.
        assert!(
            output.contains("(foreign-procedure \"objc_msgSend\" (void* void*) (& NSRect))"),
            "foreign-procedure decl must keep `(void* void*)` even for large-struct returns\n{}",
            output
        );
        assert!(
            output.contains("(make-ftype-pointer NSRect (foreign-alloc (ftype-sizeof NSRect)))"),
            "expected wrapper to allocate result buffer\n{}",
            output
        );
        assert!(
            output.contains("%result-buf"),
            "expected wrapper to pass `%result-buf` as the implicit leading arg\n{}",
            output
        );
    }

    #[test]
    fn small_struct_method_return_emits_indirect_result_buffer() {
        // NSPoint = 16 bytes. Even though the arm64 C ABI returns it in
        // registers, Chez's `(& ftype)` *result* convention is uniform: the
        // foreign-procedure always takes the result buffer as a hidden
        // leading arg. Calling a `(& NSPoint)`-returning foreign-procedure
        // without the buffer fails at runtime ("incorrect number of
        // arguments"), which is what broke `drawing-canvas`'s
        // `locationInWindow` call before this fix.
        let cls = Class {
            name: "NSEvent".into(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![make_method(
                "locationInWindow",
                false,
                false,
                ty(TypeRefKind::Alias {
                    name: "NSPoint".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
        };
        let output = generate_class_file(&cls, "AppKit");
        // The declared `param-types` list stays `(void* void*)`; the buffer
        // arg is implicit in the `(& NSPoint)` result type.
        assert!(
            output.contains("(foreign-procedure \"objc_msgSend\" (void* void*) (& NSPoint))"),
            "foreign-procedure decl must keep `(void* void*)` for small-struct returns too\n{}",
            output
        );
        assert!(
            output.contains("(make-ftype-pointer NSPoint (foreign-alloc (ftype-sizeof NSPoint)))"),
            "expected wrapper to allocate an NSPoint result buffer\n{}",
            output
        );
        assert!(
            output.contains("%result-buf"),
            "expected wrapper to pass `%result-buf` as the implicit leading arg\n{}",
            output
        );
    }

    fn block(params: Vec<TypeRef>, ret: TypeRef) -> TypeRef {
        ty(TypeRefKind::Block {
            params,
            return_type: Box::new(ret),
        })
    }

    fn method_with_params(sel: &str, params: Vec<Param>, ret: TypeRef) -> Method {
        let mut m = make_method(sel, false, false, ret);
        m.params = params;
        m
    }

    #[test]
    fn bridgeable_block_param_boxes_via_make_objc_block() {
        // Mirrors NSSavePanel -beginSheetModalForWindow:completionHandler:
        // whose handler is `void (^)(NSModalResponse)` (NSInteger arg).
        let cls = Class {
            name: "NSSavePanel".into(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![method_with_params(
                "beginSheetModalForWindow:completionHandler:",
                vec![
                    Param {
                        name: "window".into(),
                        param_type: ty(TypeRefKind::Id),
                    },
                    Param {
                        name: "handler".into(),
                        param_type: block(
                            vec![ty(TypeRefKind::Primitive {
                                name: "int64".into(),
                            })],
                            ty(TypeRefKind::Primitive {
                                name: "void".into(),
                            }),
                        ),
                    },
                ],
                ty(TypeRefKind::Primitive {
                    name: "void".into(),
                }),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
        };
        let output = generate_class_file(&cls, "AppKit");
        // The method binds (not deferred) and its wrapper boxes the handler.
        assert!(
            output.contains(
                "(define (nssavepanel-begin-sheet-modal-for-window-completion-handler! self window handler)"
            ),
            "bridgeable block method must emit a wrapper\n{}",
            output
        );
        assert!(
            output.contains("(objc-block-ptr (make-objc-block handler (list 'integer-64) 'void))"),
            "block param must box the proc via make-objc-block\n{}",
            output
        );
        // The msgSend foreign-procedure declares the block arg as void*.
        assert!(
            output.contains("(foreign-procedure \"objc_msgSend\" (void* void* void* void*) void)"),
            "block param's FFI type must be void*\n{}",
            output
        );
        // The dispatch runtime import is pulled in.
        assert!(
            output.contains("(apianyware runtime dispatch))"),
            "block-bridging class must import the dispatch runtime\n{}",
            output
        );
    }

    #[test]
    fn unbridgeable_block_param_defers_method() {
        // A block taking a by-value NSRect can't be bridged → method deferred,
        // and no dispatch import is pulled in.
        let cls = Class {
            name: "NSView".into(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![method_with_params(
                "drawWithRectHandler:",
                vec![Param {
                    name: "handler".into(),
                    param_type: block(
                        vec![ty(TypeRefKind::Alias {
                            name: "NSRect".into(),
                            framework: None,
                            underlying_primitive: None,
                        })],
                        ty(TypeRefKind::Primitive {
                            name: "void".into(),
                        }),
                    ),
                }],
                ty(TypeRefKind::Primitive {
                    name: "void".into(),
                }),
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
        };
        let output = generate_class_file(&cls, "AppKit");
        assert!(
            !output.contains("draw-with-rect-handler"),
            "un-bridgeable block method must be deferred\n{}",
            output
        );
        assert!(
            !output.contains("(apianyware runtime dispatch))"),
            "class with no bridgeable block must not import dispatch\n{}",
            output
        );
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
            objc_exposed: true,
        };
        let output = generate_class_file(&cls, "Foundation");
        assert!(output.contains("(define (nsstring-string)"));
        assert!(output.contains("(objc_getClass \"NSString\")"));
        assert!(output.contains("wrap-objc-object"));
    }
}

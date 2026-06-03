//! Gerbil class module emission — the procedural binding (leaf 020/010).
//!
//! Each ObjC class becomes one Gerbil `.ss` module:
//!   - a single `begin-ffi` block holding **one inline-cast `objc_msgSend`
//!     `define-c-lambda` per distinct method ABI signature** (arm64 forbids a
//!     variadic `objc_msgSend`, so each call shape needs its own typed C cast —
//!     the compiled-FFI analogue of chez's per-selector `foreign-procedure`,
//!     but deduplicated by signature: ADR-0017, spike `01-reachability.ss`),
//!     plus `objc_getClass` / `sel_registerName`;
//!   - module-level selector caches (`sel_registerName` once at load);
//!   - the **procedural core** — one plain procedure per emitted method over the
//!     single `objc-obj` handle (ADR-0018), constructors, and properties.
//!
//! The opt-in `:std/generic` OO veneer and the `(values result error)` error
//! model for trailing-`NSError**` methods are sibling leaf 020 — this leaf emits
//! the complete *functional* binding only. Block-parameter methods stay deferred
//! exactly as [`crate::method_filter`] already defers them (the `make-objc-block`
//! boxing is 020's).
//!
//! The IR-shaping machinery (`build_class_plan`, `collect_exports`,
//! `dedupe_across_categories`, the property/class-method collision pre-pass) is
//! ported from `emit-chez/src/emit_class.rs` — it is target-neutral; only the
//! naming calls and the emitted source forms are Gerbil-specific.
//!
//! ## Runtime contract (names owned by leaf 050)
//!
//! Emitted against the runtime module `:gerbil-bindings/runtime/objc`:
//! `(defstruct objc-obj (ptr))` ⇒ `make-objc-obj` / `objc-obj-ptr` / `objc-obj?`;
//! `wrap-objc-obj` (raw `id` ptr → `objc-obj`, registers a Gambit will;
//! `(wrap-objc-obj ptr)` autoreleased, `(wrap-objc-obj ptr #t)` retained — mirrors
//! chez `wrap-objc-object`); `objc-obj->ptr` (coerce an `objc-obj` *or* `#f`/nil
//! to a raw pointer for an outbound `id` argument). Captured to 050's inbox.

use std::collections::HashSet;

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_emit::naming::{camel_to_kebab, class_name_to_lowercase};
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::{Class, Method, Param, Property};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

use crate::ffi_type_mapping::{is_known_geometry_alias, GerbilFfiTypeMapper, POINTER};
use crate::method_filter::{is_supported_method, returns_object_type, returns_void};
use crate::naming::{
    make_class_method_name, make_class_property_getter_name, make_class_property_setter_name,
    make_method_name, make_property_getter_name, make_property_setter_name,
    make_selector_binding_name, make_unique_constructor_name,
};

/// The runtime module the generated class binds against (objc-obj + lifetime).
const RUNTIME_OBJC_IMPORT: &str = ":gerbil-bindings/runtime/objc";

/// Generate the full `.ss` module text for one class.
pub fn generate_class_file(cls: &Class, framework: &str) -> String {
    generate_class_file_with_exports(cls, framework).0
}

/// Compute the exported names for one class, in sorted order, without rendering
/// the body. Used by `emit_framework` to build the facade re-export list.
pub fn class_exports(cls: &Class) -> Vec<String> {
    let mapper = GerbilFfiTypeMapper;
    build_class_plan(cls, &mapper).exports
}

/// Compute exports + render the class module in a single pass (mirrors chez's
/// `generate_class_file_with_exports` shape so `emit_framework` calls one fn).
pub fn generate_class_file_with_exports(cls: &Class, framework: &str) -> (String, Vec<String>) {
    let mapper = GerbilFfiTypeMapper;
    let plan = build_class_plan(cls, &mapper);
    let mut w = CodeWriter::new();

    let needs_default_constructor =
        !has_explicit_constructor(&plan.init_methods.iter().collect::<Vec<&Method>>(), &mapper);

    emit_header(&mut w, cls, framework, &plan.exports);
    emit_ffi_block(&mut w, cls, &plan, needs_default_constructor, &mapper);
    emit_selector_caches(&mut w, cls, &plan);

    if !plan.init_methods.is_empty() || needs_default_constructor {
        w.line(";; --- Constructors ---");
        if needs_default_constructor {
            emit_default_constructor(&mut w, &cls.name);
        }
        for m in &plan.init_methods {
            emit_constructor(&mut w, &cls.name, m, &mapper);
        }
    }

    if !plan.properties.is_empty() {
        w.line(";; --- Properties ---");
        for p in &plan.properties {
            emit_property(&mut w, &cls.name, p, &mapper);
        }
    }

    if !plan.instance_methods.is_empty() {
        w.line(";; --- Instance methods ---");
        for m in &plan.instance_methods {
            emit_method(&mut w, &cls.name, m, false, &mapper);
        }
    }

    if !plan.class_methods.is_empty() {
        w.line(";; --- Class methods ---");
        for m in &plan.class_methods {
            emit_method(&mut w, &cls.name, m, true, &mapper);
        }
    }

    (w.finish(), plan.exports)
}

// --- class plan (ported from emit-chez, target-neutral) -------------------

/// Cleaned-up emission plan for one class.
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
        // Block-typed and unsupported-struct property bodies are deferred (their
        // names would otherwise land in the export list with no matching define).
        .filter(|p| {
            !is_unsupported_struct_property(&p.property_type, mapper)
                && !matches!(p.property_type.kind, TypeRefKind::Block { .. })
        })
        .cloned()
        .collect();

    // Suppress instance-property collisions with same-named class methods
    // (e.g. NSMenuItem's class method `separatorItem` wins over a property).
    let class_method_names: HashSet<String> = methods_owned
        .iter()
        .filter(|m| m.class_method && !m.init_method)
        .map(|m| make_method_name(&cls.name, &m.selector))
        .collect();
    properties_owned.retain(|p| {
        p.class_property
            || !class_method_names.contains(&make_property_getter_name(&cls.name, &p.name))
    });

    // Names taken by properties (both getter + setter sides), to suppress
    // methods that kebab to the same name (e.g. NSTask `setArguments:`).
    let instance_property_getter_names: HashSet<String> = properties_owned
        .iter()
        .filter(|p| !p.class_property)
        .map(|p| make_property_getter_name(&cls.name, &p.name))
        .collect();
    let instance_property_setter_names: HashSet<String> = properties_owned
        .iter()
        .filter(|p| !p.class_property && !p.readonly)
        .map(|p| make_property_setter_name(&cls.name, &p.name))
        .collect();
    let class_property_getter_names: HashSet<String> = properties_owned
        .iter()
        .filter(|p| p.class_property)
        .map(|p| make_class_property_getter_name(&cls.name, &p.name, false))
        .collect();
    let class_property_setter_names: HashSet<String> = properties_owned
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

/// Final dedup pass (safety net for `setX:` selectors that kebab to a
/// property-setter name without matching the convention). Precedence:
/// property > instance method > class method; constructors pass through.
fn dedupe_across_categories(
    cls: &Class,
    properties: Vec<Property>,
    instance_methods: Vec<Method>,
    class_methods: Vec<Method>,
    raw_exports: Vec<String>,
) -> (Vec<Property>, Vec<Method>, Vec<Method>, Vec<String>) {
    let mut seen: HashSet<String> = HashSet::new();

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
        seen.insert(getter);
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
    let mut seen = HashSet::new();
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
    let mut seen = HashSet::new();
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

// --- signature collection / dispatch crossing -----------------------------

/// One distinct `objc_msgSend` ABI signature → one `define-c-lambda`. The
/// `binding` name is derived purely from the token shape, so any two call sites
/// with the same shape resolve to the same crossing (the per-signature dedup).
struct Signature {
    binding: String,
    /// Gambit FFI arg tokens, including the implicit leading `id` + `SEL`.
    arg_tokens: Vec<String>,
    /// Gambit FFI return token.
    ret_token: String,
}

/// The `%msg-…` binding name for a msgSend shape. Built from the *variable*
/// param tokens (the leading `id`/`SEL` never vary) and the return token, via a
/// short per-token code, so the name is stable, legible, and injective on the
/// token set: `(id,SEL)->NSUInteger` ⇒ `%msg-v->u64`, `(id,SEL,double)->id` ⇒
/// `%msg-d->p`.
fn signature_binding_name(param_tokens: &[String], ret_token: &str) -> String {
    let mut s = String::from("%msg-");
    if param_tokens.is_empty() {
        s.push('v');
    } else {
        let codes: Vec<String> = param_tokens.iter().map(|t| token_code(t)).collect();
        s.push_str(&codes.join("-"));
    }
    s.push_str("->");
    s.push_str(&token_code(ret_token));
    s
}

/// Short identifier code for a Gambit FFI token (used in `%msg-…` names).
fn token_code(token: &str) -> String {
    match token {
        "(pointer void)" => "p".into(),
        "char-string" => "str".into(),
        "void" => "v".into(),
        "bool" => "b".into(),
        "float" => "f".into(),
        "double" => "d".into(),
        "int8" => "i8".into(),
        "unsigned-int8" => "u8".into(),
        "int16" => "i16".into(),
        "unsigned-int16" => "u16".into(),
        "int32" => "i32".into(),
        "unsigned-int32" => "u32".into(),
        "int64" => "i64".into(),
        "unsigned-int64" => "u64".into(),
        // struct token (CGRect, …): lowercase, valid in an identifier.
        other => other.to_ascii_lowercase(),
    }
}

/// The C type spelling for a Gambit FFI token, used inside the inline
/// `objc_msgSend` function-pointer cast. The unit compiles `-x objective-c`, so
/// `id`/`SEL`/`BOOL` and the geometry struct tags are in scope; `<stdint.h>`
/// (C-safe) backs the fixed-width integers.
fn c_cast_type(token: &str) -> &str {
    match token {
        "(pointer void)" => "id",
        "void" => "void",
        "bool" => "BOOL",
        "char-string" => "const char*",
        "float" => "float",
        "double" => "double",
        "int8" => "int8_t",
        "unsigned-int8" => "uint8_t",
        "int16" => "int16_t",
        "unsigned-int16" => "uint16_t",
        "int32" => "int32_t",
        "unsigned-int32" => "uint32_t",
        "int64" => "int64_t",
        "unsigned-int64" => "uint64_t",
        // struct token: the c-define-type name doubles as the C type spelling.
        other => other,
    }
}

/// The inline-cast `objc_msgSend` C body for one signature (spike
/// `01-reachability.ss` shape). `arg_tokens` includes the leading `id`/`SEL`.
fn msgsend_body(arg_tokens: &[String], ret_token: &str) -> String {
    // Cast prototype: id, SEL, then each extra param's C type.
    let mut proto = vec!["id".to_string(), "SEL".to_string()];
    for t in &arg_tokens[2..] {
        proto.push(c_cast_type(t).to_string());
    }
    let proto = proto.join(", ");

    // Call actuals: ___arg1 (receiver), (SEL)___arg2, then ___arg3…
    let mut actuals = vec!["___arg1".to_string(), "(SEL)___arg2".to_string()];
    for i in 2..arg_tokens.len() {
        actuals.push(format!("___arg{}", i + 1));
    }
    let actuals = actuals.join(", ");

    if ret_token == "void" {
        format!("((void (*)({proto}))objc_msgSend)({actuals});")
    } else if ret_token == "char-string" {
        // const char* return → ___CAST off the const to avoid a cast-qual
        // warning (FINDINGS §1).
        format!("___return( ___CAST(char*, ((const char* (*)({proto}))objc_msgSend)({actuals})) );")
    } else {
        let cret = c_cast_type(ret_token);
        format!("___return( (({cret} (*)({proto}))objc_msgSend)({actuals}) );")
    }
}

/// Full Gambit arg-token list (with leading `id`+`SEL`) for a param list.
fn arg_tokens_for(params: &[Param], mapper: &dyn FfiTypeMapper) -> Vec<String> {
    let mut toks = vec![POINTER.to_string(), POINTER.to_string()];
    toks.extend(params.iter().map(|p| mapper.map_type(&p.param_type, false)));
    toks
}

/// Collect every distinct msgSend signature the class needs: methods,
/// constructors (init shapes + the shared `alloc` shape), and properties
/// (getter + setter). Deduplicated by binding name.
fn collect_signatures(
    cls: &Class,
    plan: &ClassPlan,
    needs_default_constructor: bool,
    mapper: &dyn FfiTypeMapper,
) -> Vec<Signature> {
    let mut by_name: std::collections::BTreeMap<String, Signature> =
        std::collections::BTreeMap::new();

    let mut add = |args: Vec<String>, ret: String| {
        let param_tokens = args[2..].to_vec();
        let binding = signature_binding_name(&param_tokens, &ret);
        by_name.entry(binding.clone()).or_insert(Signature {
            binding,
            arg_tokens: args,
            ret_token: ret,
        });
    };

    // Alloc shape `(id, SEL) -> id` is needed by every constructor.
    if needs_default_constructor || !plan.init_methods.is_empty() {
        add(vec![POINTER.into(), POINTER.into()], POINTER.into());
    }
    // Default ctor's `init` is the alloc shape; explicit ctors add their init.
    for m in &plan.init_methods {
        if !is_supported_method(m, mapper) || m.selector == "init" {
            continue;
        }
        add(arg_tokens_for(&m.params, mapper), POINTER.into());
    }

    for m in plan
        .instance_methods
        .iter()
        .chain(plan.class_methods.iter())
    {
        if !is_supported_method(m, mapper) {
            continue;
        }
        add(
            arg_tokens_for(&m.params, mapper),
            mapper.map_type(&m.return_type, true),
        );
    }

    for p in &plan.properties {
        // Getter: (id, SEL) -> prop-type.
        add(
            vec![POINTER.into(), POINTER.into()],
            mapper.map_type(&p.property_type, true),
        );
        if !p.readonly {
            // Setter: (id, SEL, prop-type) -> void.
            add(
                vec![
                    POINTER.into(),
                    POINTER.into(),
                    mapper.map_type(&p.property_type, false),
                ],
                "void".into(),
            );
        }
    }

    let _ = cls;
    by_name.into_values().collect()
}

/// Geometry struct tokens used anywhere in the class's signatures, with the C
/// struct tag + header each needs in the `begin-ffi` `c-declare` prelude.
fn geometry_decls(sigs: &[Signature]) -> Vec<(&'static str, &'static str, &'static str)> {
    let mut seen = HashSet::new();
    let mut out = Vec::new();
    for sig in sigs {
        for tok in sig.arg_tokens.iter().chain(std::iter::once(&sig.ret_token)) {
            if let Some(decl) = geometry_decl(tok) {
                if seen.insert(decl.0) {
                    out.push(decl);
                }
            }
        }
    }
    out
}

/// `(token, c-struct-tag, header)` for a by-value geometry struct token. The
/// CoreGraphics tokens are confident (spike §4); the NS-prefixed and affine ones
/// carry their best-known struct tag + header and are an inbox item for 050/070
/// (the `-x objective-c` unit makes the Foundation/QuartzCore tags available, but
/// the exact spelling wants a gsc-compile confirmation the VM-verify leaf gives).
fn geometry_decl(token: &str) -> Option<(&'static str, &'static str, &'static str)> {
    match token {
        "CGRect" => Some(("CGRect", "CGRect", "<CoreGraphics/CGGeometry.h>")),
        "CGPoint" => Some(("CGPoint", "CGPoint", "<CoreGraphics/CGGeometry.h>")),
        "CGSize" => Some(("CGSize", "CGSize", "<CoreGraphics/CGGeometry.h>")),
        "CGVector" => Some(("CGVector", "CGVector", "<CoreGraphics/CGGeometry.h>")),
        "CGAffineTransform" => Some((
            "CGAffineTransform",
            "CGAffineTransform",
            "<CoreGraphics/CGAffineTransform.h>",
        )),
        "NSRange" => Some(("NSRange", "_NSRange", "<Foundation/NSRange.h>")),
        "NSEdgeInsets" => Some(("NSEdgeInsets", "NSEdgeInsets", "<Foundation/NSGeometry.h>")),
        "NSDirectionalEdgeInsets" => Some((
            "NSDirectionalEdgeInsets",
            "NSDirectionalEdgeInsets",
            "<Foundation/NSGeometry.h>",
        )),
        "NSAffineTransformStruct" => Some((
            "NSAffineTransformStruct",
            "NSAffineTransformStruct",
            "<Foundation/NSAffineTransform.h>",
        )),
        _ => None,
    }
}

// --- emission -------------------------------------------------------------

fn emit_header(w: &mut CodeWriter, cls: &Class, framework: &str, exports: &[String]) {
    write_line!(
        w,
        ";;; Generated binding for {} ({}) — do not edit",
        cls.name,
        framework
    );
    w.line("(import :std/foreign");
    write_line!(w, "        {})", RUNTIME_OBJC_IMPORT);

    if exports.is_empty() {
        w.line("(export)");
    } else {
        w.line("(export");
        for name in exports {
            write_line!(w, "  {}", name);
        }
        w.line("  )");
    }
    w.blank_line();
}

fn emit_ffi_block(
    w: &mut CodeWriter,
    cls: &Class,
    plan: &ClassPlan,
    needs_default_constructor: bool,
    mapper: &dyn FfiTypeMapper,
) {
    let sigs = collect_signatures(cls, plan, needs_default_constructor, mapper);
    let geo = geometry_decls(&sigs);

    // begin-ffi export list: the FFI helpers + every crossing.
    w.line("(begin-ffi (objc_getClass sel_registerName");
    for sig in &sigs {
        write_line!(w, "            {}", sig.binding);
    }
    w.line("            )");

    w.line("  (c-declare \"#include <objc/runtime.h>\")");
    w.line("  (c-declare \"#include <objc/message.h>\")");
    w.line("  (c-declare \"#include <stdint.h>\")");
    for (_, _, header) in &geo {
        write_line!(w, "  (c-declare \"#include {}\")", header);
    }
    for (tok, tag, _) in &geo {
        write_line!(w, "  (c-define-type {} (struct \"{}\"))", tok, tag);
    }
    w.blank_line();

    w.line("  (define-c-lambda objc_getClass (char-string) (pointer void) \"objc_getClass\")");
    w.line(
        "  (define-c-lambda sel_registerName (char-string) (pointer void) \"sel_registerName\")",
    );

    for sig in &sigs {
        write_line!(
            w,
            "  (define-c-lambda {} ({}) {}",
            sig.binding,
            sig.arg_tokens.join(" "),
            sig.ret_token
        );
        write_line!(
            w,
            "    \"{}\")",
            msgsend_body(&sig.arg_tokens, &sig.ret_token)
        );
    }
    w.line("  )");
    w.blank_line();
}

/// Module-level `sel_registerName` caches, one per distinct selector used by an
/// emitted method or property (registered once at module load).
fn emit_selector_caches(w: &mut CodeWriter, cls: &Class, plan: &ClassPlan) {
    let mut seen = HashSet::new();
    let mut emit_sel = |w: &mut CodeWriter, selector: &str| {
        if seen.insert(selector.to_string()) {
            write_line!(
                w,
                "(define {} (sel_registerName \"{}\"))",
                make_selector_binding_name(&cls.name, selector),
                selector
            );
        }
    };

    let mapper = GerbilFfiTypeMapper;
    let mut any = false;
    // Explicit constructors cache their init selector (the default ctor inlines
    // alloc/init, so it needs no cache); `init` itself is the default-ctor shape.
    for m in &plan.init_methods {
        if is_supported_method(m, &mapper) && m.selector != "init" {
            emit_sel(w, &m.selector);
            any = true;
        }
    }
    for m in plan
        .instance_methods
        .iter()
        .chain(plan.class_methods.iter())
    {
        if is_supported_method(m, &mapper) {
            emit_sel(w, &m.selector);
            any = true;
        }
    }
    for p in &plan.properties {
        emit_sel(w, &p.name);
        any = true;
        if !p.readonly {
            emit_sel(w, &setter_selector_for(&p.name));
        }
    }
    if any {
        w.blank_line();
    }
}

fn emit_default_constructor(w: &mut CodeWriter, class_name: &str) {
    let fn_name = format!("make-{}", class_name_to_lowercase(class_name));
    let alloc = signature_binding_name(&[], POINTER);
    write_line!(w, "(define ({})", fn_name);
    w.line("  (wrap-objc-obj");
    write_line!(
        w,
        "    ({alloc} ({alloc} (objc_getClass \"{cls}\") (sel_registerName \"alloc\"))",
        alloc = alloc,
        cls = class_name
    );
    w.line("             (sel_registerName \"init\"))");
    w.line("    #t))");
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
    let fn_name = make_unique_constructor_name(class_name, &method.selector);
    let param_vars = param_var_names(&method.params);
    let alloc = signature_binding_name(&[], POINTER);
    let init = signature_binding_name(&arg_tokens_for(&method.params, mapper)[2..], POINTER);
    let sel_var = make_selector_binding_name(class_name, &method.selector);

    let mut sig = format!("(define ({fn_name}");
    for v in &param_vars {
        sig.push(' ');
        sig.push_str(v);
    }
    sig.push(')');
    write_line!(w, "{}", sig);

    let coerced: Vec<String> = method
        .params
        .iter()
        .zip(param_vars.iter())
        .map(|(p, v)| coerce_arg_expr(p, v))
        .collect();
    let alloc_call =
        format!("({alloc} (objc_getClass \"{class_name}\") (sel_registerName \"alloc\"))");
    write_line!(
        w,
        "  (wrap-objc-obj ({init} {alloc_call} {sel}{sp}{args}) #t))",
        init = init,
        alloc_call = alloc_call,
        sel = sel_var,
        sp = if coerced.is_empty() { "" } else { " " },
        args = coerced.join(" ")
    );
    w.blank_line();
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
    let fn_name = if is_class_method {
        make_class_method_name(class_name, &method.selector, false)
    } else {
        make_method_name(class_name, &method.selector)
    };
    let binding = signature_binding_name(
        &arg_tokens_for(&method.params, mapper)[2..],
        &mapper.map_type(&method.return_type, true),
    );
    let sel_var = make_selector_binding_name(class_name, &method.selector);
    let param_vars = param_var_names(&method.params);

    let mut sig = format!("(define ({fn_name}");
    if !is_class_method {
        sig.push_str(" self");
    }
    for v in &param_vars {
        sig.push(' ');
        sig.push_str(v);
    }
    sig.push(')');
    write_line!(w, "{}", sig);

    let receiver = if is_class_method {
        format!("(objc_getClass \"{class_name}\")")
    } else {
        "(objc-obj->ptr self)".to_string()
    };
    let coerced: Vec<String> = method
        .params
        .iter()
        .zip(param_vars.iter())
        .map(|(p, v)| coerce_arg_expr(p, v))
        .collect();
    let call = format!(
        "({binding} {receiver} {sel_var}{sp}{args})",
        sp = if coerced.is_empty() { "" } else { " " },
        args = coerced.join(" ")
    );
    write_line!(w, "  {})", wrap_return(method, &call, mapper));
    w.blank_line();
}

fn emit_property(
    w: &mut CodeWriter,
    class_name: &str,
    prop: &Property,
    mapper: &dyn FfiTypeMapper,
) {
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
    let getter_binding = signature_binding_name(&[], &mapper.map_type(&prop.property_type, true));
    let getter_sel = make_selector_binding_name(class_name, &prop.name);
    let receiver = if prop.class_property {
        format!("(objc_getClass \"{class_name}\")")
    } else {
        "(objc-obj->ptr self)".to_string()
    };

    let arglist = if prop.class_property { "" } else { " self" };
    write_line!(w, "(define ({getter_name}{arglist})");
    let call = format!("({getter_binding} {receiver} {getter_sel})");
    let wrapped = if mapper.is_object_type(&prop.property_type) {
        format!("(wrap-objc-obj {call})")
    } else {
        call
    };
    write_line!(w, "  {})", wrapped);

    if !prop.readonly {
        let setter_name = if prop.class_property {
            make_class_property_setter_name(class_name, &prop.name, false)
        } else {
            make_property_setter_name(class_name, &prop.name)
        };
        let value_tok = mapper.map_type(&prop.property_type, false);
        let setter_binding = signature_binding_name(&[value_tok], "void");
        let setter_sel = make_selector_binding_name(class_name, &setter_selector_for(&prop.name));
        let arglist = if prop.class_property {
            "value"
        } else {
            "self value"
        };
        write_line!(w, "(define ({setter_name} {arglist})");
        let value_expr = setter_value_expr(&prop.property_type);
        write_line!(
            w,
            "  ({setter_binding} {receiver} {setter_sel} {value_expr}))"
        );
    }
    w.blank_line();
}

// --- per-arg / per-return coercion ----------------------------------------

fn coerce_arg_expr(param: &Param, var: &str) -> String {
    match &param.param_type.kind {
        TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => {
            format!("(objc-obj->ptr {var})")
        }
        TypeRefKind::Selector => format!("(sel_registerName {var})"),
        _ => var.to_string(),
    }
}

fn setter_value_expr(t: &TypeRef) -> String {
    match &t.kind {
        TypeRefKind::Class { .. } | TypeRefKind::Id | TypeRefKind::Instancetype => {
            "(objc-obj->ptr value)".to_string()
        }
        TypeRefKind::Selector => "(sel_registerName value)".to_string(),
        _ => "value".to_string(),
    }
}

fn wrap_return(method: &Method, call: &str, mapper: &dyn FfiTypeMapper) -> String {
    if returns_void(method, mapper) {
        call.to_string()
    } else if returns_object_type(method, mapper) {
        if method_returns_retained(method) {
            format!("(wrap-objc-obj {call} #t)")
        } else {
            format!("(wrap-objc-obj {call})")
        }
    } else {
        call.to_string()
    }
}

fn param_var_names(params: &[Param]) -> Vec<String> {
    params
        .iter()
        .enumerate()
        .map(|(i, p)| {
            let base = camel_to_kebab(&p.name);
            if base.is_empty() {
                format!("arg{i}")
            } else {
                base
            }
        })
        .collect()
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
    use apianyware_macos_types::ir::{Method, Param};
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
        }
    }

    fn cls_with(name: &str, methods: Vec<Method>, properties: Vec<Property>) -> Class {
        Class {
            name: name.into(),
            superclass: String::new(),
            protocols: vec![],
            properties,
            methods,
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
        }
    }

    fn param(name: &str, kind: TypeRefKind) -> Param {
        Param {
            name: name.into(),
            param_type: ty(kind),
        }
    }

    fn prop(name: &str, kind: TypeRefKind, readonly: bool) -> Property {
        Property {
            name: name.into(),
            property_type: ty(kind),
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

    #[test]
    fn renders_module_with_ffi_block_and_proc() {
        let cls = cls_with(
            "NSString",
            vec![make_method(
                "length",
                false,
                false,
                ty(TypeRefKind::Primitive {
                    name: "uint64".into(),
                }),
            )],
            vec![],
        );
        let out = generate_class_file(&cls, "Foundation");
        assert!(out.contains(";;; Generated binding for NSString (Foundation)"));
        assert!(out.contains("(import :std/foreign"));
        assert!(out.contains(":gerbil-bindings/runtime/objc"));
        assert!(out.contains("(begin-ffi (objc_getClass sel_registerName"));
        // length is (id, SEL) -> NSUInteger → %msg-v->u64
        assert!(out.contains(
            "(define-c-lambda %msg-v->u64 ((pointer void) (pointer void)) unsigned-int64"
        ));
        assert!(out.contains("((uint64_t (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2)"));
        // proc core over objc-obj
        assert!(out.contains("(define (nsstring-length self)"));
        assert!(out.contains("(%msg-v->u64 (objc-obj->ptr self) %sel-nsstring-length)"));
        assert!(out.contains("(define %sel-nsstring-length (sel_registerName \"length\"))"));
    }

    #[test]
    fn per_signature_dedup_collapses_same_shape() {
        // -length and -count are both (id, SEL) -> NSUInteger → one crossing.
        let cls = cls_with(
            "NSArray",
            vec![
                make_method(
                    "count",
                    false,
                    false,
                    ty(TypeRefKind::Primitive {
                        name: "uint64".into(),
                    }),
                ),
                make_method(
                    "length",
                    false,
                    false,
                    ty(TypeRefKind::Primitive {
                        name: "nsuinteger".into(),
                    }),
                ),
            ],
            vec![],
        );
        let out = generate_class_file(&cls, "Foundation");
        assert_eq!(out.matches("(define-c-lambda %msg-v->u64").count(), 1);
        // but both procs exist, sharing the one crossing
        assert!(out.contains("(define (nsarray-count self)"));
        assert!(out.contains("(define (nsarray-length self)"));
    }

    #[test]
    fn struct_returning_method_uses_by_value_cgrect() {
        let cls = cls_with(
            "NSView",
            vec![make_method(
                "frame",
                false,
                false,
                ty(TypeRefKind::Alias {
                    name: "NSRect".into(),
                    framework: None,
                    underlying_primitive: None,
                }),
            )],
            vec![],
        );
        let out = generate_class_file(&cls, "AppKit");
        assert!(out.contains("(c-declare \"#include <CoreGraphics/CGGeometry.h>\")"));
        assert!(out.contains("(c-define-type CGRect (struct \"CGRect\"))"));
        // NSRect canonicalises to the CGRect by-value token
        assert!(
            out.contains("(define-c-lambda %msg-v->cgrect ((pointer void) (pointer void)) CGRect")
        );
        assert!(out.contains("((CGRect (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2)"));
        // a struct return is NOT object-wrapped
        assert!(out.contains("(define (nsview-frame self)"));
        assert!(out.contains("(%msg-v->cgrect (objc-obj->ptr self) %sel-nsview-frame)"));
    }

    #[test]
    fn object_return_is_wrapped() {
        let cls = cls_with(
            "NSString",
            vec![make_method(
                "description",
                false,
                false,
                ty(TypeRefKind::Id),
            )],
            vec![],
        );
        let out = generate_class_file(&cls, "Foundation");
        assert!(out.contains(
            "(wrap-objc-obj (%msg-v->p (objc-obj->ptr self) %sel-nsstring-description))"
        ));
    }

    #[test]
    fn default_constructor_allocs_and_inits_retained() {
        let cls = cls_with("NSObject", vec![], vec![]);
        let out = generate_class_file(&cls, "Foundation");
        assert!(out.contains(";; --- Constructors ---"));
        assert!(out.contains("(define (make-nsobject)"));
        assert!(out.contains("(objc_getClass \"NSObject\")"));
        assert!(out.contains("(sel_registerName \"alloc\")"));
        assert!(out.contains("(sel_registerName \"init\")"));
        assert!(out.contains("#t))"));
        assert!(out.contains("make-nsobject"));
    }

    #[test]
    fn explicit_constructor_threads_args() {
        let mut init = make_method(
            "initWithUTF8String:",
            false,
            true,
            ty(TypeRefKind::Instancetype),
        );
        init.params = vec![param("utf8", TypeRefKind::CString)];
        let cls = cls_with("NSString", vec![init], vec![]);
        let out = generate_class_file(&cls, "Foundation");
        assert!(out.contains("(define (make-nsstring-init-with-utf8-string utf8)"));
        // init shape (id, SEL, char-string) -> id → %msg-str->p; alloc → %msg-v->p
        assert!(out.contains("%msg-str->p"));
        assert!(out.contains("(wrap-objc-obj (%msg-str->p"));
        assert!(out.contains("#t))"));
        // the explicit init selector is cached at module load (not inlined)
        assert!(out
            .contains("(define %sel-nsstring-init-with-utf8-string (sel_registerName \"initWithUTF8String:\"))"));
        assert!(out.contains("%sel-nsstring-init-with-utf8-string utf8"));
        // no synthesized default ctor when an explicit initializer exists
        assert!(!out.contains("(define (make-nsstring)\n"));
    }

    #[test]
    fn property_getter_and_setter() {
        let cls = cls_with(
            "NSWindow",
            vec![],
            vec![prop("title", TypeRefKind::Id, false)],
        );
        let out = generate_class_file(&cls, "AppKit");
        assert!(out.contains(";; --- Properties ---"));
        assert!(out.contains("(define (nswindow-title self)"));
        assert!(
            out.contains("(wrap-objc-obj (%msg-v->p (objc-obj->ptr self) %sel-nswindow-title))")
        );
        // The proc name keeps the mutating `!`; the selector cache var is keyed
        // on the raw selector `setTitle:` (no `!`).
        assert!(out.contains("(define (nswindow-set-title! self value)"));
        assert!(out.contains(
            "(%msg-p->v (objc-obj->ptr self) %sel-nswindow-set-title (objc-obj->ptr value))"
        ));
        assert!(out.contains("(define %sel-nswindow-set-title (sel_registerName \"setTitle:\"))"));
    }

    #[test]
    fn class_method_uses_get_class_receiver() {
        let cls = cls_with(
            "NSString",
            vec![make_method("string", true, false, ty(TypeRefKind::Id))],
            vec![],
        );
        let out = generate_class_file(&cls, "Foundation");
        assert!(out.contains(";; --- Class methods ---"));
        assert!(out.contains("(define (nsstring-string)"));
        assert!(out.contains(
            "(wrap-objc-obj (%msg-v->p (objc_getClass \"NSString\") %sel-nsstring-string))"
        ));
    }

    #[test]
    fn char_string_return_casts_off_const() {
        let cls = cls_with(
            "NSString",
            vec![make_method(
                "UTF8String",
                false,
                false,
                ty(TypeRefKind::CString),
            )],
            vec![],
        );
        let out = generate_class_file(&cls, "Foundation");
        assert!(out
            .contains("(define-c-lambda %msg-v->str ((pointer void) (pointer void)) char-string"));
        assert!(out.contains("___CAST(char*, ((const char* (*)(id, SEL))objc_msgSend)"));
    }

    #[test]
    fn exports_are_sorted_and_complete() {
        let cls = cls_with(
            "NSString",
            vec![make_method(
                "length",
                false,
                false,
                ty(TypeRefKind::Primitive {
                    name: "uint64".into(),
                }),
            )],
            vec![],
        );
        let exports = class_exports(&cls);
        assert!(exports.contains(&"make-nsstring".to_string()));
        assert!(exports.contains(&"nsstring-length".to_string()));
        let mut sorted = exports.clone();
        sorted.sort();
        assert_eq!(exports, sorted);
    }
}

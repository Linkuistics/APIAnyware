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

use std::collections::HashSet;

use apianyware_macos_emit::code_writer::CodeWriter;
use apianyware_macos_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_macos_emit::naming::{camel_to_kebab, class_name_to_lowercase};
use apianyware_macos_emit::write_line;
use apianyware_macos_types::ir::{Class, Method, Param, Property, Struct};
use apianyware_macos_types::type_ref::{TypeRef, TypeRefKind};

use crate::chez_builtins::chezscheme_import_spec;
use crate::ffi_type_mapping::{
    block_make_expr, is_known_geometry_alias, return_needs_indirect_result, ChezFfiTypeMapper,
};
use crate::method_filter::{is_supported_method, returns_object_type, returns_void};
use crate::naming::{
    make_class_method_name, make_class_property_getter_name, make_class_property_setter_name,
    make_method_name, make_msgsend_binding_name, make_property_getter_name,
    make_property_setter_name, make_selector_binding_name, make_swift_init_name,
    make_swift_method_name, make_unique_constructor_name,
};
use crate::shared_signatures::framework_shared_object_arg;
use crate::trampoline::{classify_method, introduced_macos, MethodDisposition};

/// The rendered receiver-handle trampoline bindings (ADR-0030) for one type's
/// declared Swift-native methods/inits (`objc_exposed == false`), plus the import
/// flags they imply. Computed once so the header can pull the right runtime
/// libraries and the export list can carry the exact binding names. The chez
/// analogue of emit-racket's `SwiftNativeBindings`.
struct SwiftNativeBindings {
    /// One per emitted binding: (export name, rendered `(define …)`, is-async).
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
    fn is_empty(&self) -> bool {
        self.entries.is_empty()
    }
    /// Any trampoline present ⇒ the file imports `(apianyware runtime swift-trampoline)`
    /// (`aw-string-arg`/`aw-string-result`/`aw-call/error`/`aw-trampoline-lib-ready`)
    /// and emits the dylib-forcing reference (ADR-0028 §3).
    fn needs_trampoline(&self) -> bool {
        !self.entries.is_empty()
    }
    /// Any `async` method present ⇒ also imports `(apianyware runtime async-bridge)`
    /// (`aw-async-call`).
    fn needs_async_bridge(&self) -> bool {
        self.entries.iter().any(|e| e.is_async)
    }
    /// Drop bindings whose Scheme name collides with an already-bound ObjC name (the
    /// ObjC binding wins — same name in `(export …)` twice, or two `(define …)`s,
    /// makes Chez reject the whole library). The dropped Swift duplicate is a
    /// generation detail; the Swift-side trampoline residual is unchanged.
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
/// (`Unmanaged`) vs value (`AwChezValueBox`) receiver path; it MUST match the global
/// trampoline pass (`collect_trampolines`) so every emitted binding references an
/// entry the `@_cdecl` pass actually produces. Overloads that collapse to the same
/// Scheme name (distinct content-addressed entries, same base+labels) keep the
/// first — a generation detail, the Swift-side trampoline residual is unaffected.
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
                let mutating = m
                    .swift_fn
                    .as_ref()
                    .and_then(|i| i.self_kind.as_deref())
                    == Some("Mutating");
                let name = make_swift_method_name(owner, &m.selector, mutating);
                if !seen.insert(name.clone()) {
                    continue;
                }
                let param_names = swift_param_names(&m.params);
                entries.push(SwiftNativeBinding {
                    define: t.render_chez_method(&name, &param_names),
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
                    define: t.render_chez_init(&name, &param_names),
                    is_async: false,
                    name,
                });
            }
            MethodDisposition::Deferred(_) => {} // counted by the global trampoline pass
        }
    }
    SwiftNativeBindings { entries }
}

/// Emit the Swift-native trampoline section (methods + init producers) into a class
/// or struct library body, after the ObjC bindings. The dylib-forcing reference
/// (ADR-0028 §3) precedes the `foreign-procedure`s — chez instantiates a library
/// lazily, so a pure-scalar trampoline that touches no coercer would otherwise never
/// trigger the `libAPIAnywareChez` load and its entries would fail to resolve.
/// Idempotent on an empty set.
fn emit_swift_native_section(w: &mut CodeWriter, bindings: &SwiftNativeBindings) {
    if bindings.is_empty() {
        return;
    }
    w.line(";; --- Swift-native methods (receiver-handle trampolines, ADR-0030) ---");
    w.line("  (define %aw-lib-ready aw-trampoline-lib-ready)");
    for entry in &bindings.entries {
        for line in entry.define.lines() {
            write_line!(w, "  {}", line);
        }
    }
    w.blank_line();
}

/// Generate the full `.sls` library text for one class. Convenience wrapper for the
/// caller without the framework's value-struct set — equivalent to having no
/// in-framework Swift value structs (a value-struct **param** on a Swift-native
/// method then defers rather than binding, which only narrows the method frontier).
pub fn generate_class_file(cls: &Class, framework: &str) -> String {
    let (content, _exports) =
        generate_class_file_with_exports(cls, framework, &HashSet::new());
    content
}

/// Compute exports + render the class file in a single pass.
pub fn generate_class_file_with_exports(
    cls: &Class,
    framework: &str,
    value_structs: &HashSet<&str>,
) -> (String, Vec<String>) {
    let mapper = ChezFfiTypeMapper;
    let mut w = CodeWriter::new();

    let plan = build_class_plan(cls, &mapper, framework, value_structs);

    let needs_dispatch = plan_uses_block_bridge(&plan, &mapper);
    emit_header(
        &mut w,
        cls,
        framework,
        &plan.exports,
        needs_dispatch,
        plan.swift_native.needs_trampoline(),
        plan.swift_native.needs_async_bridge(),
    );

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
    // Swift-native methods/inits (`objc_exposed == false`) route to receiver-handle
    // trampolines (ADR-0030), not the broken `objc_msgSend` path (charter #4).
    emit_swift_native_section(&mut w, &plan.swift_native);

    let exports = plan.exports;

    // Close the (library ...) form.
    w.line(")");

    (w.finish(), exports)
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
/// properties so `generate_class_file_with_exports` can drive emission from the
/// same data, plus the rendered Swift-native trampoline bindings (charter #4).
struct ClassPlan {
    properties: Vec<Property>,
    init_methods: Vec<Method>,
    instance_methods: Vec<Method>,
    class_methods: Vec<Method>,
    swift_native: SwiftNativeBindings,
    exports: Vec<String>,
}

/// Generate a Chez binding library for a Swift-native **value struct** (population B,
/// D1/D3) — the receiver is a value handle (`AwChezValueBox`, `owner_is_class =
/// false`), init producers vend the handle, `mutating` methods write back. Returns
/// `None` (with no file written) when the struct has no bindable trampoline (a plain
/// C struct, or every method deferred), so no empty library is emitted. Unlike a
/// class library there is no ObjC substrate and no framework-dylib load — just the
/// runtime types (for `coerce-arg`), the trampoline coercers, and the bindings; the
/// `libAPIAnywareChez` load is forced by the trampoline runtime reference. Returns
/// the rendered library text and its export-name list (for the `main.sls` re-export).
///
/// `lib_low` is the lowercased final segment of the library name — Chez resolves
/// `(apianyware <fw> <lib_low>)` to `<fw>/<lib_low>.sls`, so the caller passes the
/// (possibly `-struct`-disambiguated) name it writes the file under, keeping the
/// library name and filename in lockstep.
pub fn generate_struct_file(
    st: &Struct,
    framework: &str,
    value_structs: &HashSet<&str>,
    lib_low: &str,
) -> Option<(String, Vec<String>)> {
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
    let fw = framework.to_ascii_lowercase();
    write_line!(
        w,
        ";; Generated binding for {} ({}) — Swift-native value struct (ADR-0030)",
        st.name,
        framework
    );
    write_line!(w, "(library (apianyware {} {})", fw, lib_low);

    let exports: Vec<String> = bindings.names().cloned().collect();
    w.line("  (export");
    for n in &exports {
        write_line!(w, "    {}", n);
    }
    w.line("    )");

    // No `(except … objc)` and no framework-dylib load: a value struct has no ObjC
    // substrate. `(apianyware runtime types)` supplies `coerce-arg` (+ transitively
    // loads `libAPIAnywareChez`); swift-trampoline supplies the coercers + the
    // forcing reference; async-bridge only when a method is `async`. Init producers
    // spell `make-<struct>`, which can collide with a `(chezscheme)` builtin
    // (`Date` → `make-date`); except the offenders so the local define wins.
    write_line!(w, "  (import {}", chezscheme_import_spec(&exports));
    w.line("          (apianyware runtime types)");
    if bindings.needs_async_bridge() {
        w.line("          (apianyware runtime swift-trampoline)");
        w.line("          (apianyware runtime async-bridge))");
    } else {
        w.line("          (apianyware runtime swift-trampoline))");
    }
    w.blank_line();

    emit_swift_native_section(&mut w, &bindings);

    // Close the (library ...) form.
    w.line(")");

    Some((w.finish(), exports))
}

fn build_class_plan(
    cls: &Class,
    mapper: &dyn FfiTypeMapper,
    framework: &str,
    value_structs: &HashSet<&str>,
) -> ClassPlan {
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
        .filter(|m| m.class_method && !m.init_method && m.objc_exposed)
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

    // Charter #4 (D4): only ObjC-exposed methods route through `objc_msgSend`.
    // Swift-native methods (`objc_exposed == false`) have no msgSend entry — binding
    // them there is a latent crash — so they are excluded here and routed to the
    // receiver-handle trampoline section (`swift_native`) below, or suppressed when
    // deferred (the global trampoline pass records + counts the deferral).
    let init_methods: Vec<Method> = methods_owned
        .iter()
        .filter(|m| m.init_method && m.objc_exposed)
        .cloned()
        .collect();

    let class_methods: Vec<Method> = methods_owned
        .iter()
        .filter(|m| {
            if !m.class_method || m.init_method || !m.objc_exposed {
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
            if m.class_method || m.init_method || !m.objc_exposed {
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

    let (filtered_props, filtered_inst, filtered_class, mut exports) = dedupe_across_categories(
        cls,
        properties_owned,
        instance_methods,
        class_methods,
        raw_exports,
    );

    // Swift-native methods/inits (`objc_exposed == false`) → receiver-handle
    // trampolines (ADR-0030, charter #4). A class is a reference receiver
    // (`owner_is_class = true`, `Unmanaged` path); a `Class` carries no provenance,
    // so the owner-availability fold (B3) is empty for class owners.
    // MUST use `cls.methods` (the *declared* methods), not `effective_methods`
    // (which prefers `all_methods` = inherited + category). The global trampoline
    // pass (`collect_trampolines` → `collect_type_methods`) emits `@_cdecl` entries
    // for `c.methods` only, so binding an inherited/category method here would
    // reference a content-addressed entry the Swift side never produced (the §6c
    // agreement). Inherited Swift-native methods bind under their declaring class.
    let mut swift_native = collect_swift_native_bindings(
        &cls.name,
        framework,
        &cls.methods,
        true,
        value_structs,
        None,
    );
    // The ObjC bindings win any name collision (Chez rejects a doubly-defined or
    // doubly-exported name). Drop Swift duplicates against the final ObjC export set.
    let objc_names: HashSet<String> = exports.iter().cloned().collect();
    swift_native.exclude(&objc_names);
    for name in swift_native.names() {
        exports.push(name.clone());
    }
    exports.sort();
    exports.dedup();

    ClassPlan {
        properties: filtered_props,
        init_methods,
        instance_methods: filtered_inst,
        class_methods: filtered_class,
        swift_native,
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
    needs_trampoline: bool,
    needs_async_bridge: bool,
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
    // `(apianyware runtime objc)` import. A Swift-native method/init binding name
    // can collide with a `(chezscheme)` builtin; except the offenders (strict R6RS
    // rejects a local define that shadows an import).
    write_line!(w, "  (import {}", chezscheme_import_spec(exports));
    w.line("          (apianyware runtime ffi)");
    w.line(
        "          (except (apianyware runtime objc) \
make-nserror nserror? nserror-domain nserror-code \
nserror-localised-description nserror-userinfo)",
    );
    // Build the remaining imports as an ordered list so the last one closes the
    // `(import …)` form. `(apianyware runtime types)` is always present (it exports
    // `coerce-arg` + the geometry ftypes). The Swift-native trampoline section
    // (ADR-0030) adds `(apianyware runtime swift-trampoline)` for the string/throws
    // coercers + the dylib-forcing reference, and `(apianyware runtime async-bridge)`
    // when any method is `async` (D5/R4). Methods with block parameters box the
    // user's Scheme procedure via the dispatch runtime — imported only when needed.
    let mut tail_imports: Vec<&str> = vec!["(apianyware runtime types)"];
    if needs_dispatch {
        tail_imports.push("(apianyware runtime dispatch)");
    }
    if needs_trampoline {
        tail_imports.push("(apianyware runtime swift-trampoline)");
    }
    if needs_async_bridge {
        tail_imports.push("(apianyware runtime async-bridge)");
    }
    let last = tail_imports.len() - 1;
    for (i, imp) in tail_imports.iter().enumerate() {
        if i == last {
            write_line!(w, "          {})", imp);
        } else {
            write_line!(w, "          {}", imp);
        }
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
            swift_fn: None,
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

    fn swift_method(selector: &str, init: bool, info: apianyware_macos_types::ir::SwiftFnInfo) -> Method {
        Method {
            selector: selector.into(),
            class_method: false,
            init_method: init,
            params: vec![Param {
                name: "by".into(),
                param_type: ty(TypeRefKind::Primitive {
                    name: "int64".into(),
                }),
            }],
            return_type: ty(TypeRefKind::Primitive {
                name: "int64".into(),
            }),
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
        }
    }

    /// D4 (charter #4): a Swift-native method (`objc_exposed == false`) routes to a
    /// receiver-handle trampoline `foreign-procedure` against its content-addressed
    /// `aw_chez_swift_*` entry, **not** the broken `objc_msgSend` path; a deferred
    /// Swift-native method is suppressed (no binding, and crucially no msgSend).
    #[test]
    fn swift_native_method_routes_to_trampoline_not_msgsend() {
        use apianyware_macos_types::ir::SwiftFnInfo;
        let cls = Class {
            name: "TKWidget".into(),
            superclass: String::new(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                swift_method("scaled(by:)", false, SwiftFnInfo::default()),
                // Generic Swift-native method → deferred → suppressed.
                swift_method(
                    "mapped(by:)",
                    false,
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
        };
        let out = generate_class_file(&cls, "TestKit");
        // The bindable method routes to its content-addressed trampoline entry.
        assert!(
            out.contains("aw_chez_swift_m_TestKit_TKWidget_scaled"),
            "trampoline entry missing:\n{out}"
        );
        // The receiver is passed through the value coercer, and the dylib-forcing
        // reference + trampoline runtime import are present.
        assert!(
            out.contains("(coerce-arg self)"),
            "receiver not passed:\n{out}"
        );
        assert!(
            out.contains("aw-trampoline-lib-ready"),
            "dylib-forcing reference missing:\n{out}"
        );
        assert!(
            out.contains("(apianyware runtime swift-trampoline)"),
            "trampoline runtime not imported:\n{out}"
        );
        // The broken msgSend path must NOT be emitted for the Swift-native method.
        assert!(
            !out.contains("sel-register \"scaled"),
            "Swift-native method must not msgSend a synthesized selector:\n{out}"
        );
        // The deferred generic method is suppressed entirely (no binding, no msgSend).
        assert!(
            !out.contains("mapped"),
            "deferred Swift-native method should be suppressed:\n{out}"
        );
    }

    /// Population B (D2/D3): a Swift-native value struct emits an `init` producer that
    /// vends a boxed handle and a `mutating` method that writes back, in its own
    /// library with no ObjC substrate and no framework-dylib load.
    #[test]
    fn swift_native_value_struct_emits_init_producer_and_mutating_method() {
        use apianyware_macos_types::ir::{Struct, SwiftFnInfo};
        let init = swift_method("init(value:)", true, SwiftFnInfo::default());
        let mut mutating = swift_method(
            "insert(_:)",
            false,
            SwiftFnInfo {
                self_kind: Some("Mutating".into()),
                ..Default::default()
            },
        );
        mutating.params[0].name = "_".into();
        mutating.return_type = ty(TypeRefKind::Primitive {
            name: "void".into(),
        });
        let st = Struct {
            name: "TKBox".into(),
            fields: vec![],
            methods: vec![init, mutating],
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: false,
        };
        let structs = vec![st.clone()];
        let vs = crate::trampoline::value_struct_names(&structs);
        let (out, exports) = generate_struct_file(&st, "TestKit", &vs, "tkbox")
            .expect("a bindable struct must produce a file");
        assert!(
            out.contains("(library (apianyware testkit tkbox)"),
            "struct library header wrong:\n{out}"
        );
        // Init producer (D2) named from the labels.
        assert!(
            out.contains("make-tkbox-value"),
            "init producer missing:\n{out}"
        );
        assert!(
            exports.contains(&"make-tkbox-value".to_string()),
            "init producer not exported:\n{exports:?}"
        );
        // Mutating method (D3) takes the `!` marker.
        assert!(
            out.contains("tkbox-insert!"),
            "mutating method missing:\n{out}"
        );
        // No ObjC substrate: a value struct never loads a framework dylib.
        assert!(
            !out.contains("load-shared-object"),
            "value struct must not load a framework dylib:\n{out}"
        );
        assert!(
            out.contains("(apianyware runtime swift-trampoline)"),
            "trampoline runtime not imported:\n{out}"
        );
    }
}

//! Free-function emission — each `objc_exposed` `Function` → an exported TS function whose
//! body is a coercion-free dispatch call into the addon (ADR-0054 §4). The **free-function
//! dual** of [`crate::emit_class`]'s method bodies: object args `__unwrap` to `bigint`
//! handles, scalars/enums/C-strings pass through, an object return wraps by ownership — the
//! same seam, minus the receiver and selector a method carries.
//!
//! ```ts
//! export function CGColorGetComponents(color: CGColor): bigint {
//!   return __dispatch.aw_ts_fn_CGColorGetComponents(__unwrap(color));
//! }
//! ```
//!
//! ## The dispatch entry is content-addressed by the symbol, not the signature
//!
//! A method multiplexes through one `objc_msgSend` recast per ABI signature, so its entry is
//! keyed on the signature codes ([`crate::native_dispatch::NativeSig::entry_name`]). A free C
//! function is a **distinct symbol**, so its entry is keyed on the **symbol name** —
//! `aw_ts_fn_<name>` ([`function_entry_name`]) — one `@_cdecl` wrapper per function calling
//! the symbol directly (the trampoline-elided limit for a named C export, ADR-0025). Pure
//! function of the name, shared byte-for-byte with the Step-4 Swift wrapper.
//!
//! ## Object-return ownership — CF Create Rule (C) vs always-+1 (residual)
//!
//! `Function` carries no `returns_retained` annotation (that rides methods). A **direct-bound C**
//! function's object return follows Core Foundation's ownership convention — a name containing
//! **`Create` or `Copy` returns +1 owned** (→ `__wrapOwned`), everything else +0 autoreleased
//! (→ `__wrapRetained`) — the well-known CF "Create Rule" ([`function_returns_retained`]). A
//! **Swift-native residual** object return is **always +1 owned** (→ `__wrapOwned`): its trampoline
//! `passRetained`s the bridged/returned object (ADR-0057 §4 / ADR-0061 §3, `object-bridged-returns-k55`),
//! so the CF-name heuristic does not apply. [`emit_body`] branches on [`Bound::residual`], and
//! [`object_return_wrap`] owns only the direct-C side.
//!
//! ## The two streams — direct-bound and Swift-native residual
//!
//! A **`objc_exposed`** function is direct-bound (`aw_ts_fn_<name>`, the block above), and its
//! TS surface is what [`TsFfiTypeMapper`] makes of its ObjC/C types. A **Swift-native**
//! (`objc_exposed == false`) function has no C symbol — it is reachable only across the Swift ABI
//! (ADR-0025) — so it binds to a call-by-name trampoline `aw_ts_swift_<Module>_<name>` (ADR-0061;
//! the classification + generated Swift live in [`crate::trampoline`]), and its TS surface comes
//! from **that classifier's plan**, not the mapper.
//!
//! The distinction is load-bearing, not stylistic. A `.swiftinterface`-sourced decl lowers every
//! Swift nominal type to `TypeRefKind::Class`, so `mapper.is_object_type` calls `CoreGraphics`'s
//! `CGFloat` an object — which would emit `__unwrap` on a number, `__wrapOwned` on a double, and
//! an `import { CGFloat }` no module exports. [`Bound`] carries the plan so the emitted call site,
//! its imports, and the generated napi callback all read one decision.
//!
//! ## Deferrals (no silent narrowing)
//!
//! - **Swift-native** functions still defer, recorded with a reason by [`crate::trampoline`], when
//!   they carry an **object/string param** (the ARC-on-bitcast / Object-ref frontier), a
//!   **non-bridged value-struct return**, a **Swift nominal return** with no ObjC identity (a
//!   tuple), a Swift **operator** name, or are `throws` / `async` / generic;
//! - **variadic** / **inline** functions ([`crate::method_filter::is_supported_function`]);
//! - **raw-pointer / block / non-geometry-struct** functions — a free-function `NSError**`
//!   out-param arrives as a raw [`TypeRefKind::Pointer`](apianyware_types::type_ref::TypeRefKind::Pointer)
//!   (the extractor keeps no NSError identity), so it defers with every other raw pointer; the
//!   `NSError**` → `Result<T>` channel is its own `error-model` leaf (ADR-0058).
//!
//! Deferred functions are not emitted (not counted). The runtime seam
//! (`__dispatch`/`__unwrap`/`__wrapRetained`/`__wrapOwned`) is the same [`crate::emit_class`]
//! defines; `.ts`/`.d.ts` co-generate through one [`bound_functions`] frontier and one
//! [`function_header`] (ADR-0055 §2).

use std::collections::{BTreeSet, HashSet};

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_emit::write_line;
use apianyware_types::ir::Function;
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

use crate::class_graph::{ClassModuleResolver, RUNTIME_MODULE};
use crate::class_surface::object_class_name;
use crate::emit_class::wrap_call;
use crate::enum_graph::EnumModuleResolver;
use crate::ffi_type_mapping::{pod_type_name, TsFfiTypeMapper};
use crate::imports::{
    class_type_imports, enum_type_imports, merge_type_imports, pod_type_imports,
    protocol_type_imports, render_import_blocks, render_type_import_blocks,
};
use crate::method_filter::is_supported_function;
use crate::naming::{is_valid_ts_identifier, module_specifier, param_identifier};
use crate::native_dispatch::function_entry_name;
use crate::protocol_binding::{self, id_surface_type};
use crate::protocol_graph::ProtocolModuleResolver;
use crate::ptr_value::PtrValue;
use crate::trampoline::{self, FnDisposition, FnTrampoline, ResidualReturn};

/// Render a framework's free functions as the **`functions.ts`** module — the banner, the
/// import preamble (class-type value imports + the merged runtime-seam block; enum type-only
/// imports), and one `export function NAME(params): ret { <dispatch body> }` per bound
/// function ([`bound_functions`]).
pub fn render_functions_module(
    functions: &[Function],
    framework: &str,
    resolver: &ClassModuleResolver<'_>,
    enum_resolver: &EnumModuleResolver<'_>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
) -> String {
    let mapper = surface_mapper(resolver, enum_resolver, protocol_resolver);
    let bound = bound_functions(functions, framework, &mapper);

    let mut w = CodeWriter::new();
    emit_banner(&mut w, framework, true);
    emit_imports(
        &mut w,
        &bound,
        &mapper,
        resolver,
        enum_resolver,
        protocol_resolver,
        true,
    );
    for (i, b) in bound.iter().enumerate() {
        if i > 0 {
            w.blank_line();
        }
        let names = unique_param_names(b.func);
        write_line!(w, "{} {{", function_header(b, &names, &mapper));
        w.indent();
        emit_body(&mut w, b, &names, &mapper);
        w.dedent();
        w.line("}");
    }
    w.finish()
}

/// Render the co-generated **`functions.d.ts`** — the declaration-only surface: the same
/// banner + imports (minus the `.ts`-only seam block) and one `;`-terminated
/// `export function NAME(params): ret;` per function, from the same [`bound_functions`]
/// frontier + [`function_header`] so the signatures cannot drift from `functions.ts`.
pub fn render_functions_dts(
    functions: &[Function],
    framework: &str,
    resolver: &ClassModuleResolver<'_>,
    enum_resolver: &EnumModuleResolver<'_>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
) -> String {
    let mapper = surface_mapper(resolver, enum_resolver, protocol_resolver);
    let bound = bound_functions(functions, framework, &mapper);

    let mut w = CodeWriter::new();
    emit_banner(&mut w, framework, false);
    emit_imports(
        &mut w,
        &bound,
        &mapper,
        resolver,
        enum_resolver,
        protocol_resolver,
        false,
    );
    for b in &bound {
        let names = unique_param_names(b.func);
        write_line!(w, "{};", function_header(b, &names, &mapper));
    }
    w.finish()
}

/// The three-set type-surface mapper both artifacts render from — the identical mapper
/// [`crate::emit_class`] and [`crate::emit_protocol`] build (enums, whole-program classes,
/// protocols). One mapper shape everywhere is what guarantees a given [`TypeRef`] renders as the
/// same token whichever emitter asks: a mapper missing a recognition set would quietly keep an
/// older surface, and two emitters disagreeing about one type is precisely the drift the
/// `class_binding` / `pod_type_name` / `protocol_binding` family exists to prevent.
fn surface_mapper(
    resolver: &ClassModuleResolver<'_>,
    enum_resolver: &EnumModuleResolver<'_>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
) -> TsFfiTypeMapper {
    TsFfiTypeMapper::with_known(
        enum_resolver.known_enums(),
        resolver.known_classes(),
        protocol_resolver.known_protocols(),
    )
}

/// The number of free functions this framework emits — those that are bindable
/// ([`bound_functions`]): direct-bound `objc_exposed` functions plus Swift-native scalar
/// residual functions. Drives the orchestrator's write decision, `EmitResult::functions_emitted`,
/// and the barrel re-export.
pub fn emitted_function_count(
    functions: &[Function],
    framework: &str,
    mapper: &TsFfiTypeMapper,
) -> usize {
    bound_functions(functions, framework, mapper).len()
}

/// A bound free function, plus — for a **Swift-native residual** — the trampoline plan that
/// determines its whole TS surface.
///
/// The two streams read their surface from different sources, and that is the point. A
/// **direct-bound C** function's params and return are ObjC/C types the [`TsFfiTypeMapper`]
/// renders faithfully. A **residual** function's are `.swiftinterface` types, which the IR spells
/// `TypeRefKind::Class` whatever they really are — so `mapper.is_object_type` would call `CGFloat`
/// an object and emit `__unwrap` on a number. The [`FnTrampoline`] plan is the authority there: it
/// already decided, in [`crate::trampoline::classify_function`], exactly what crosses the boundary,
/// and the generated napi callback is rendered from that same plan.
struct Bound<'a> {
    func: &'a Function,
    /// `Some` iff `!func.objc_exposed` — a bound residual's marshalling plan.
    residual: Option<FnTrampoline>,
}

impl Bound<'_> {
    /// The addon dispatch entry this function's body calls — `aw_ts_fn_<name>` for a direct-bound
    /// ObjC/C function ([`function_entry_name`]), or the residual plan's content-addressed
    /// `aw_ts_swift_<Module>_<name>` (ADR-0061). Both shared byte-for-byte with the native side.
    fn entry(&self) -> String {
        match &self.residual {
            Some(t) => t.entry.clone(),
            None => function_entry_name(&self.func.name),
        }
    }
}

/// The framework's bindable free functions, in IR order — the single frontier both artifacts
/// emit, so the `.d.ts` declares exactly the functions the `.ts` implements. Two streams: an
/// **`objc_exposed`** function within the supported type frontier ([`is_supported_function`])
/// binds directly to `aw_ts_fn_<name>`; a **Swift-native** (`objc_exposed == false`) residual
/// function binds to its call-by-name trampoline (ADR-0061) iff
/// [`crate::trampoline::classify_function`] plans one — the *same* call the collection pass makes,
/// which is what makes the generated table and the emitted call sites mirror each other exactly.
fn bound_functions<'a>(
    functions: &'a [Function],
    framework: &str,
    mapper: &TsFfiTypeMapper,
) -> Vec<Bound<'a>> {
    // The ObjC-class recognition set both streams gate on — the *same* whole-program set the
    // method frontier reads (`class_binding`), carried on the mapper since k66 rather than passed
    // beside it, so the two can no longer drift apart.
    let objc_classes = mapper.bound_classes();
    functions
        .iter()
        .filter_map(|f| {
            if f.objc_exposed {
                is_bound_direct_c(f, mapper).then_some(Bound {
                    func: f,
                    residual: None,
                })
            } else {
                // `classify_function` owns the residual admission decision whole — the TS-name
                // check included — so there is no second frontier to drift from.
                match trampoline::classify_function(framework, f, objc_classes) {
                    FnDisposition::Trampoline(t) => Some(Bound {
                        func: f,
                        residual: Some(t),
                    }),
                    FnDisposition::Deferred(_) => None,
                }
            }
        })
        .collect()
}

/// Whether an **`objc_exposed`** free function binds directly to `aw_ts_fn_<name>` — a valid TS
/// identifier within the supported type frontier, whose final gate is ABI routability
/// ([`is_supported_function`]).
///
/// The **one** admission predicate for the direct-C stream, shared with
/// [`crate::function_table`]'s collector: a function the emitter binds but the collector skips is
/// a JS `TypeError` at dispatch time, and one the collector keeps but the emitter skips is a dead
/// export. Two callers, one decision — that is what makes the mirror invariant exact.
pub(crate) fn is_bound_direct_c(f: &Function, mapper: &TsFfiTypeMapper) -> bool {
    debug_assert!(
        f.objc_exposed,
        "the residual stream admits through classify_function"
    );
    is_valid_ts_identifier(&f.name) && is_supported_function(f, mapper)
}

/// The `export function <name>(<params>): <ret>` signature header (no trailing `{`/`;` — the
/// caller appends the `.ts` body or the `.d.ts` `;`). `names` are the pre-computed unique
/// param formals ([`unique_param_names`]), so the header and the body reference the same
/// names. The one place param + return rendering lives, so the two artifacts move in lockstep.
///
/// A **residual** function's surface comes from its plan, not the mapper: only scalars bind, so
/// every param is a `number`, and the return is `void` / `number` / the object class.
fn function_header(b: &Bound<'_>, names: &[String], mapper: &TsFfiTypeMapper) -> String {
    let f = b.func;
    let params: Vec<String> = match &b.residual {
        Some(_) => names.iter().map(|name| format!("{name}: number")).collect(),
        None => f
            .params
            .iter()
            .zip(names)
            .map(|(p, name)| format!("{name}: {}", mapper.map_type(&p.param_type, false)))
            .collect(),
    };
    let ret = match &b.residual {
        Some(t) => match t.ts_return() {
            ResidualReturn::Void => "void".to_string(),
            ResidualReturn::Number => "number".to_string(),
            ResidualReturn::Object => {
                // A residual's return is a `.swiftinterface` `Class{…}`, so `wrap_class` always
                // names one (bound, or the degraded root) — it is never the class-less arm.
                let base = wrap_class(f, mapper).unwrap_or_else(|| "NSObject".to_string());
                if f.return_type.nullable {
                    format!("{base} | null")
                } else {
                    base
                }
            }
        },
        None => mapper.map_type(&f.return_type, true),
    };
    format!("export function {}({}): {ret}", f.name, params.join(", "))
}

/// Emit a function body — a coercion-free dispatch call plus result handling, the mirror of
/// [`crate::emit_class`]'s method body minus the receiver/selector. A direct-bound C function's
/// object args `__unwrap`, a proven enum return casts, and an object return wraps by the CF Create
/// Rule. A **residual** function's args are all scalars (they pass through untouched) and its
/// return follows [`ResidualReturn`]; an object return is always `__wrapOwned` (the trampoline's
/// own +1, ADR-0061 §3).
fn emit_body(w: &mut CodeWriter, b: &Bound<'_>, names: &[String], mapper: &TsFfiTypeMapper) {
    let f = b.func;
    let entry = b.entry();
    let args: Vec<String> = match &b.residual {
        Some(_) => names.to_vec(),
        None => f
            .params
            .iter()
            .zip(names)
            .map(|(p, name)| {
                if let Some(pv) = PtrValue::of(&p.param_type) {
                    pv.param_expr(name)
                } else if mapper.is_object_type(&p.param_type) {
                    format!("__unwrap({name})")
                } else {
                    name.clone()
                }
            })
            .collect(),
    };
    let call = format!("__dispatch.{entry}({})", args.join(", "));
    let bang = if f.return_type.nullable { "" } else { "!" };

    if let Some(t) = &b.residual {
        match t.ts_return() {
            ResidualReturn::Void => write_line!(w, "{call};"),
            ResidualReturn::Number => write_line!(w, "return {call};"),
            ResidualReturn::Object => {
                write_line!(w, "const __ret = {call};");
                write_line!(
                    w,
                    "return {}{bang};",
                    wrap_call("__wrapOwned", wrap_class(f, mapper), None, "__ret")
                );
            }
        }
    } else if mapper.is_void(&f.return_type) {
        write_line!(w, "{call};");
    } else if let Some(pv) = PtrValue::of(&f.return_type) {
        // A `SEL`/`Class` return converts back to its declared type — the method-family rule
        // (`emit_class`), identical here because the crossing is a property of the kind, not of the
        // callee. `NSClassFromString` / `NSSelectorFromString` are the flagship sites.
        write_line!(w, "return {}{bang};", pv.return_expr(&call));
    } else if mapper.is_object_type(&f.return_type) {
        write_line!(w, "const __ret = {call};");
        let wrap_fn = object_return_wrap(f);
        // The identical three-arm wrap `emit_class` renders (declared class / class-less / class-less
        // carrying a bound qualifier), so a function and a method wrap an object return one way.
        write_line!(
            w,
            "return {}{bang};",
            wrap_call(
                wrap_fn,
                wrap_class(f, mapper),
                id_surface_type(&f.return_type, mapper, true),
                "__ret"
            )
        );
    } else if let Some(enum_name) = mapper.known_enum_name(&f.return_type) {
        // A proven enum crosses as its underlying integer; a numeric TS enum is not
        // structurally `number`, so the coercion-free result is cast (the emit_class rule).
        write_line!(w, "return {call} as {enum_name};");
    } else {
        write_line!(w, "return {call};");
    }
}

/// The concrete TS class a wrap primitive instantiates for an object-returning function —
/// `Class{name}` → that class (or the degraded root), and **`None` when the IR names no class**: a
/// bare or protocol-qualified `id`. (A free function never returns `instancetype` — that is a
/// receiver-relative method concept.)
///
/// `None` renders the wrap primitive's **class-less arm** ([`crate::emit_class::wrap_call`]), which
/// resolves the object's real ObjC class through the ADR-0055 §5b ctor registry — the same rule
/// `dynamic-class-wrap-k88` gave methods. It is what makes a bound `id<P>` return honest here too:
/// the declared type promises `P`'s members, and only the dynamic wrap actually mints them.
fn wrap_class(f: &Function, mapper: &TsFfiTypeMapper) -> Option<String> {
    match &f.return_type.kind {
        TypeRefKind::Id { .. } => None,
        _ => object_class_name(&f.return_type, mapper, true),
    }
}

/// Whether a **direct-bound C** free function returns a +1 *owned* object, per the Core Foundation
/// **Create Rule**: a name containing `Create` or `Copy` transfers ownership. Only consulted for a
/// C function's object return ([`object_return_wrap`]); a Swift-native residual bypasses it.
///
/// Shared with [`crate::function_table`], which reads it to decide whether the generated napi
/// entry **folds an `objcRetain`** into the return: `__wrapRetained` (+0) expects the fold,
/// `__wrapOwned` (+1) must not get one. Wrap primitive and native fold are two halves of one
/// decision (ADR-0057 §4) and must never be computed twice.
pub(crate) fn function_returns_retained(f: &Function) -> bool {
    f.name.contains("Create") || f.name.contains("Copy")
}

/// The wrap primitive for a **direct-bound C** free function's object return, per the CF Create
/// Rule ([`function_returns_retained`]): `Create`/`Copy` → +1 owned (`__wrapOwned`), else +0
/// autoreleased (`__wrapRetained`).
///
/// A **Swift-native residual** never routes through here: its call-by-name trampoline hands JS a
/// **uniform +1** (`Unmanaged.passRetained`, ADR-0057 §4 / ADR-0061 §3), so its object return is
/// always `__wrapOwned` — the CF-name heuristic does not apply, because a Swift `String` or
/// factory return carries no `Create`/`Copy` convention. [`emit_body`] and [`seam_symbols`] both
/// branch on [`Bound::residual`] before reaching this, so the emitted call and its import agree.
fn object_return_wrap(f: &Function) -> &'static str {
    debug_assert!(f.objc_exposed, "a residual object return is a uniform +1");
    if function_returns_retained(f) {
        "__wrapOwned"
    } else {
        "__wrapRetained"
    }
}

/// Distinct, valid-identifier param formals for a free function — a C function's params may be
/// unnamed, reserved-word-named, or collide. An empty / non-identifier label becomes `argN` (by
/// index); a reserved word (`arguments`, `function`, …) escapes through [`param_identifier`],
/// the same total map [`crate::class_surface::render_params`] applies to a method's params; a
/// collision gets a numeric suffix. Deterministic (a pure function of `f`), so the `.ts` body and
/// the `.d.ts` signature compute the same names independently.
fn unique_param_names(f: &Function) -> Vec<String> {
    let mut seen: HashSet<String> = HashSet::new();
    let mut out: Vec<String> = Vec::with_capacity(f.params.len());
    for (i, p) in f.params.iter().enumerate() {
        let base = if is_valid_ts_identifier(&p.name) {
            param_identifier(&p.name)
        } else {
            format!("arg{i}")
        };
        let mut name = base.clone();
        let mut k = 1;
        while seen.contains(&name) {
            name = format!("{base}{k}");
            k += 1;
        }
        seen.insert(name.clone());
        out.push(name);
    }
    out
}

// --- header + imports ------------------------------------------------------------------

/// The generated-file banner — a `.ts` vs `.d.ts` variant.
fn emit_banner(w: &mut CodeWriter, framework: &str, is_ts: bool) {
    w.line("// Generated by apianyware emit-typescript — DO NOT EDIT.");
    if is_ts {
        write_line!(
            w,
            "// Functions: {framework} (module {})",
            module_specifier(framework)
        );
        w.line("//");
        w.line(
            "// Each free function is a coercion-free dispatch into the addon's per-symbol entry",
        );
        w.line(
            "// (ADR-0054): object args unwrap, scalars pass through, an object return wraps by",
        );
        w.line("// ownership (the CF Create Rule). A Swift-native scalar function binds its");
        w.line("// call-by-name trampoline (aw_ts_swift_*, ADR-0027); non-scalar/variadic defer.");
    } else {
        write_line!(w, "// Type surface: functions ({framework})");
        w.line("//");
        w.line("// Declaration-only .d.ts, co-generated with functions.ts from the same IR pass");
        w.line("// (ADR-0055 §2): the exported function signatures, no dispatch bodies.");
    }
    w.blank_line();
}

/// The per-module import blocks — class-type value imports (object param/return types, routed
/// through the `resolver`), with the `.ts`-only runtime-seam symbols merged into the runtime
/// block, then the type-only section: enum imports (routed through the `enum_resolver`) merged
/// with the referenced POD geometry types (runtime-owned, ADR-0055 §5 — the geometry free
/// functions `NSContainsRect`/`NSInsetRect`/… are the densest POD population in the corpus).
/// Identical grouping to [`crate::emit_class`], so the two artifacts cannot drift.
///
/// A **residual** function contributes at most one class reference — its object return. Its params
/// are scalars and its `CGFloat`-shaped types are `number`s, so asking the mapper about them would
/// import names no module exports; and its return alphabet ([`ResidualReturn`]) is
/// void/number/object — a value-struct return defers, so a residual never carries a POD either.
#[allow(clippy::too_many_arguments)]
fn emit_imports(
    w: &mut CodeWriter,
    bound: &[Bound<'_>],
    mapper: &TsFfiTypeMapper,
    resolver: &ClassModuleResolver<'_>,
    enum_resolver: &EnumModuleResolver<'_>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
    include_seam: bool,
) {
    let mut class_refs: BTreeSet<String> = BTreeSet::new();
    let mut enum_refs: BTreeSet<String> = BTreeSet::new();
    let mut pod_refs: BTreeSet<String> = BTreeSet::new();
    let mut protocol_types: Vec<&TypeRef> = Vec::new();
    for b in bound {
        let f = b.func;
        if let Some(t) = &b.residual {
            if t.ts_return() == ResidualReturn::Object {
                class_refs.extend(wrap_class(f, mapper));
            }
            continue;
        }
        for p in &f.params {
            if let Some(name) = object_class_name(&p.param_type, mapper, false) {
                class_refs.insert(name);
            }
            if let Some(name) = mapper.known_enum_name(&p.param_type) {
                enum_refs.insert(name.to_string());
            }
            if let Some(name) = pod_type_name(&p.param_type) {
                pod_refs.insert(name.to_string());
            }
            protocol_types.push(&p.param_type);
        }
        if let Some(name) = object_class_name(&f.return_type, mapper, true) {
            class_refs.insert(name);
        }
        if let Some(name) = mapper.known_enum_name(&f.return_type) {
            enum_refs.insert(name.to_string());
        }
        if let Some(name) = pod_type_name(&f.return_type) {
            pod_refs.insert(name.to_string());
        }
        protocol_types.push(&f.return_type);
    }

    let mut map = class_type_imports(&class_refs, resolver);
    if include_seam {
        let seam = seam_symbols(bound, mapper);
        if !seam.is_empty() {
            map.entry(RUNTIME_MODULE.to_string())
                .or_default()
                .extend(seam);
        }
    }
    // A bound `id<P>` qualifier on a free function's param/return types the slot by its interface,
    // exactly as on a method (`protocol_binding`, ADR-0055 §4b) — an `import type`, since an
    // interface is erased. The corpus population is **zero** today; the arm is here so the mapper's
    // answer stays a function of the IR rather than of which emitter asked. (A residual is skipped
    // for the same reason its class reference is: its `.swiftinterface` types are not ObjC types.)
    let protocol_refs = protocol_binding::referenced_protocol_types(protocol_types, mapper);
    let type_map = merge_type_imports(
        merge_type_imports(
            enum_type_imports(&enum_refs, enum_resolver),
            protocol_type_imports(&protocol_refs, protocol_resolver, mapper),
        ),
        pod_type_imports(&pod_refs),
    );

    render_import_blocks(&map, w);
    render_type_import_blocks(&type_map, w);
    if !map.is_empty() || !type_map.is_empty() {
        w.blank_line();
    }
}

/// The runtime-seam symbols the emitted `.ts` bodies call — `.ts`-only: `__dispatch` whenever
/// any function is bound, `__unwrap` for any object arg, `__sel`/`__classArg`/`__selName`/
/// `__classCtor` for a `SEL`/`Class` crossing ([`PtrValue`], the same decision [`emit_body`]
/// renders from), and `__wrapOwned`/`__wrapRetained` per an object return's ownership. Routes
/// through the same [`Bound`] discrimination [`emit_body`] uses, so the emitted call and its import
/// cannot disagree.
fn seam_symbols(bound: &[Bound<'_>], mapper: &TsFfiTypeMapper) -> BTreeSet<String> {
    let mut set: BTreeSet<String> = BTreeSet::new();
    if !bound.is_empty() {
        set.insert("__dispatch".to_string());
    }
    for b in bound {
        let f = b.func;
        if let Some(t) = &b.residual {
            // A residual's args are scalars (no `__unwrap`); its object return is a uniform +1.
            if t.ts_return() == ResidualReturn::Object {
                set.insert("__wrapOwned".to_string());
            }
            continue;
        }
        for p in &f.params {
            if let Some(pv) = PtrValue::of(&p.param_type) {
                set.insert(pv.param_symbol().to_string());
            } else if mapper.is_object_type(&p.param_type) {
                set.insert("__unwrap".to_string());
            }
        }
        if let Some(pv) = PtrValue::of(&f.return_type) {
            set.insert(pv.return_symbol().to_string());
        } else if mapper.is_object_type(&f.return_type) {
            set.insert(object_return_wrap(f).to_string());
        }
    }
    set
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::class_graph::ClassRegistry;
    use crate::enum_graph::EnumRegistry;
    use crate::protocol_graph::ProtocolRegistry;
    use apianyware_types::ir::{Param, SwiftFnInfo};
    use apianyware_types::type_ref::{TypeRef, TypeRefKind};
    use std::sync::Arc;

    fn ty(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: false,
            kind,
        }
    }

    fn nullable(kind: TypeRefKind) -> TypeRef {
        TypeRef {
            nullable: true,
            kind,
        }
    }

    fn param(name: &str, param_type: TypeRef) -> Param {
        Param {
            name: name.into(),
            param_type,
        }
    }

    fn func(name: &str, params: Vec<Param>, ret: TypeRef) -> Function {
        Function {
            name: name.into(),
            params,
            return_type: ret,
            inline: false,
            variadic: false,
            source: None,
            provenance: None,
            doc_refs: None,
            objc_exposed: true,
            swift_fn: None,
        }
    }

    /// The declared-class recognition set — `emit_framework` derives it from the registry ∪ the
    /// framework's own classes, and a free-function fixture declares none, so a test registry
    /// doubles as the recognition set. It settles both the residual classifier's object return
    /// (k65) and the direct-C stream's `Class{…}` surface (k66) — one set, so they cannot drift.
    fn known_classes(registry: &ClassRegistry) -> Arc<BTreeSet<String>> {
        Arc::new(registry.names())
    }

    fn render(
        functions: &[Function],
        fw: &str,
        registry: &ClassRegistry,
        known_enums: &[&str],
    ) -> (String, String) {
        let resolver = ClassModuleResolver::new(fw, registry, known_classes(registry));
        let enum_reg = EnumRegistry::new();
        let known: Arc<BTreeSet<String>> =
            Arc::new(known_enums.iter().map(|s| s.to_string()).collect());
        let enum_resolver = EnumModuleResolver::new(fw, &enum_reg, known);
        let proto_reg = ProtocolRegistry::new();
        let protocol_resolver =
            ProtocolModuleResolver::new(fw, &proto_reg, Arc::new(BTreeSet::new()));
        (
            render_functions_module(functions, fw, &resolver, &enum_resolver, &protocol_resolver),
            render_functions_dts(functions, fw, &resolver, &enum_resolver, &protocol_resolver),
        )
    }

    fn count(functions: &[Function], fw: &str, registry: &ClassRegistry) -> usize {
        emitted_function_count(
            functions,
            fw,
            &TsFfiTypeMapper::with_known_classes(known_classes(registry)),
        )
    }

    #[test]
    fn scalar_function_dispatches_through_the_per_symbol_entry() {
        let consts = vec![func(
            "TKComputeDistance",
            vec![
                param(
                    "x",
                    ty(TypeRefKind::Primitive {
                        name: "double".into(),
                    }),
                ),
                param(
                    "y",
                    ty(TypeRefKind::Primitive {
                        name: "double".into(),
                    }),
                ),
            ],
            ty(TypeRefKind::Primitive {
                name: "double".into(),
            }),
        )];
        let (ts, dts) = render(&consts, "TestKit", &ClassRegistry::new(), &[]);
        assert!(
            ts.contains("export function TKComputeDistance(x: number, y: number): number {"),
            "{ts}"
        );
        assert!(
            ts.contains("return __dispatch.aw_ts_fn_TKComputeDistance(x, y);"),
            "scalar args pass through, per-symbol entry:\n{ts}"
        );
        // Only __dispatch is needed (no unwrap, no wrap).
        assert!(
            ts.contains("import {\n  __dispatch,\n} from '@apianyware/runtime';"),
            "{ts}"
        );
        assert!(
            dts.contains("export function TKComputeDistance(x: number, y: number): number;"),
            "{dts}"
        );
        assert!(!dts.contains("__dispatch"), "{dts}");
    }

    #[test]
    fn object_arg_unwraps_and_plus0_object_return_wraps_retained() {
        // A plain (non-Create/Copy) object-returning function: +0 → __wrapRetained.
        let consts = vec![func(
            "TKWidgetForView",
            vec![param(
                "view",
                ty(TypeRefKind::Id {
                    protocols: Vec::new(),
                }),
            )],
            nullable(TypeRefKind::Class {
                name: "TKWidget".into(),
                framework: None,
                params: vec![],
            }),
        )];
        let mut reg = ClassRegistry::new();
        reg.insert("TKWidget", "testkit");
        let (ts, _) = render(&consts, "TestKit", &reg, &[]);
        assert!(
            ts.contains("export function TKWidgetForView(view: NSObject): TKWidget | null {"),
            "{ts}"
        );
        assert!(
            ts.contains("const __ret = __dispatch.aw_ts_fn_TKWidgetForView(__unwrap(view));"),
            "{ts}"
        );
        // +0 wrap, nullable → no bang.
        assert!(
            ts.contains("return __wrapRetained(TKWidget, __ret);"),
            "{ts}"
        );
        assert!(ts.contains("  __unwrap,\n"), "{ts}");
    }

    #[test]
    fn create_named_object_return_is_owned_plus1_and_non_null_asserts() {
        // The CF Create Rule: a `Create` in the name → +1 owned (__wrapOwned); non-null `!`.
        let consts = vec![func(
            "TKColorCreateGeneric",
            vec![param(
                "rgb",
                ty(TypeRefKind::Primitive {
                    name: "double".into(),
                }),
            )],
            ty(TypeRefKind::Class {
                name: "TKColor".into(),
                framework: None,
                params: vec![],
            }),
        )];
        let mut reg = ClassRegistry::new();
        reg.insert("TKColor", "testkit");
        let (ts, _) = render(&consts, "TestKit", &reg, &[]);
        assert!(ts.contains("return __wrapOwned(TKColor, __ret)!;"), "{ts}");
        assert!(ts.contains("  __wrapOwned,\n"), "{ts}");
    }

    #[test]
    fn void_function_is_a_bare_dispatch_statement() {
        let consts = vec![func("TKReset", vec![], TypeRef::void())];
        let (ts, _) = render(&consts, "TestKit", &ClassRegistry::new(), &[]);
        assert!(ts.contains("export function TKReset(): void {"), "{ts}");
        assert!(ts.contains("  __dispatch.aw_ts_fn_TKReset();"), "{ts}");
        // A void body is a bare dispatch statement — no `return`, no `__ret`, no wrap.
        assert!(!ts.contains("return __"), "{ts}");
        assert!(!ts.contains("__ret"), "{ts}");
    }

    #[test]
    fn enum_arg_passes_through_and_enum_return_casts_and_imports_type_only() {
        let enum_alias = |name: &str| {
            ty(TypeRefKind::Alias {
                name: name.into(),
                framework: None,
                underlying_primitive: Some("int64".into()),
            })
        };
        let consts = vec![func(
            "TKNormalizeAlignment",
            vec![param("a", enum_alias("TKAlignment"))],
            enum_alias("TKAlignment"),
        )];
        let (ts, dts) = render(&consts, "TestKit", &ClassRegistry::new(), &["TKAlignment"]);
        assert!(
            ts.contains("export function TKNormalizeAlignment(a: TKAlignment): TKAlignment {"),
            "{ts}"
        );
        // Enum arg crosses uncoerced; enum return casts.
        assert!(
            ts.contains("return __dispatch.aw_ts_fn_TKNormalizeAlignment(a) as TKAlignment;"),
            "{ts}"
        );
        assert!(
            ts.contains("import type {\n  TKAlignment,\n} from '@apianyware/testkit';"),
            "{ts}"
        );
        assert!(
            dts.contains("import type {\n  TKAlignment,\n} from '@apianyware/testkit';"),
            "{dts}"
        );
    }

    #[test]
    fn geometry_functions_type_import_their_pod_types_from_the_runtime() {
        // The literal defect `pod-struct-types-k73` names: `foundation/functions.ts` emitted
        // `NSContainsRect(aRect: CGRect, bRect: CGRect)` with `CGRect` in NO import block. The
        // geometry free functions are the densest POD population in the corpus, so this is the
        // arm that unblocks it — and the PODs route to the runtime, never to a framework barrel.
        let rect = || {
            ty(TypeRefKind::Struct {
                name: "NSRect".into(),
            })
        };
        let fns = vec![
            func(
                "NSContainsRect",
                vec![param("aRect", rect()), param("bRect", rect())],
                ty(TypeRefKind::Primitive {
                    name: "bool".into(),
                }),
            ),
            func(
                "NSInsetRect",
                vec![
                    param("aRect", rect()),
                    param(
                        "dX",
                        ty(TypeRefKind::Primitive {
                            name: "double".into(),
                        }),
                    ),
                ],
                rect(),
            ),
        ];
        let (ts, dts) = render(&fns, "Foundation", &ClassRegistry::new(), &[]);
        for out in [&ts, &dts] {
            assert!(
                out.contains("import type {\n  CGRect,\n} from '@apianyware/runtime';"),
                "the POD type-imports from the runtime, not from @apianyware/foundation:\n{out}"
            );
            assert!(
                out.contains("NSContainsRect(aRect: CGRect, bRect: CGRect): boolean"),
                "signature names the POD it imports:\n{out}"
            );
            assert!(
                out.contains("NSInsetRect(aRect: CGRect, dX: number): CGRect"),
                "a POD return too:\n{out}"
            );
        }
        // A POD crosses by value: straight through the dispatch entry, no wrap on either side.
        assert!(
            ts.contains("return __dispatch.aw_ts_fn_NSInsetRect(aRect, dX);"),
            "no coercion, no wrap:\n{ts}"
        );
    }

    #[test]
    fn cross_framework_object_types_route_to_owning_modules() {
        let mut reg = ClassRegistry::new();
        reg.insert("NSString", "foundation");
        let consts = vec![func(
            "TKDescribe",
            vec![param(
                "s",
                ty(TypeRefKind::Class {
                    name: "NSString".into(),
                    framework: None,
                    params: vec![],
                }),
            )],
            TypeRef::void(),
        )];
        let (ts, _) = render(&consts, "TestKit", &reg, &[]);
        assert!(
            ts.contains("import {\n  NSString,\n} from '@apianyware/foundation';"),
            "{ts}"
        );
    }

    #[test]
    fn swift_native_scalar_function_binds_its_call_by_name_trampoline() {
        // A Swift-native (objc_exposed == false) scalar free function binds to its call-by-name
        // trampoline `aw_ts_swift_<Module>_<name>` (ADR-0027) — NOT the plain-C `aw_ts_fn_`. The
        // body shape is the same scalar dispatch; only the entry differs.
        let mut swift_scalar = func(
            "TKSwiftScale",
            vec![param(
                "factor",
                ty(TypeRefKind::Primitive {
                    name: "double".into(),
                }),
            )],
            ty(TypeRefKind::Primitive {
                name: "double".into(),
            }),
        );
        swift_scalar.objc_exposed = false;
        let consts = vec![swift_scalar];
        assert_eq!(count(&consts, "TestKit", &ClassRegistry::new()), 1);
        let (ts, dts) = render(&consts, "TestKit", &ClassRegistry::new(), &[]);
        assert!(
            ts.contains("export function TKSwiftScale(factor: number): number {"),
            "{ts}"
        );
        // The Swift-native residual entry (module + symbol), not the plain-C aw_ts_fn_.
        assert!(
            ts.contains("return __dispatch.aw_ts_swift_TestKit_TKSwiftScale(factor);"),
            "{ts}"
        );
        assert!(!ts.contains("aw_ts_fn_TKSwiftScale"), "{ts}");
        assert!(
            dts.contains("export function TKSwiftScale(factor: number): number;"),
            "{dts}"
        );
    }

    #[test]
    fn swift_native_cgfloat_surface_is_a_number_not_an_object_handle() {
        // THE REAL-IR SHAPE (swift-residual-cli-pass-k65). A `.swiftinterface` decl lowers every
        // Swift nominal type to `TypeRefKind::Class`, so `CoreGraphics.hypot(CGFloat, CGFloat) ->
        // CGFloat` reaches the emitter as Class{CGFloat} in all three positions. The type mapper
        // would call that an object; the trampoline plan knows it is one C scalar. The `.ts` must
        // therefore be plain `number` — no `__unwrap` on a double, no `__wrapOwned`, and no value
        // import of `CGFloat` (which no module exports).
        let cgfloat = || {
            ty(TypeRefKind::Class {
                name: "CGFloat".into(),
                framework: Some("CoreGraphics".into()),
                params: vec![],
            })
        };
        let mut hypot = func(
            "hypot",
            vec![param("_", cgfloat()), param("_", cgfloat())],
            cgfloat(),
        );
        hypot.objc_exposed = false;
        hypot.swift_fn = Some(SwiftFnInfo::default());
        let consts = vec![hypot];
        assert_eq!(count(&consts, "CoreGraphics", &ClassRegistry::new()), 1);
        let (ts, dts) = render(&consts, "CoreGraphics", &ClassRegistry::new(), &[]);
        assert!(
            ts.contains("export function hypot(_: number, _1: number): number {"),
            "{ts}"
        );
        assert!(
            ts.contains("return __dispatch.aw_ts_swift_CoreGraphics_hypot(_, _1);"),
            "{ts}"
        );
        for forbidden in ["__unwrap", "__wrapOwned", "CGFloat"] {
            assert!(!ts.contains(forbidden), "{forbidden} in:\n{ts}");
            assert!(!dts.contains(forbidden), "{forbidden} in:\n{dts}");
        }
        assert!(
            dts.contains("export function hypot(_: number, _1: number): number;"),
            "{dts}"
        );
    }

    #[test]
    fn swift_native_tuple_return_defers_and_emits_nothing() {
        // `CoreGraphics.remquo(CGFloat, CGFloat) -> (CGFloat, Int)` reaches the emitter as a
        // Class{Tuple} return. `Tuple` is not a class the IR declares, so the residual defers
        // (DeferReason::SwiftNominalReturn) rather than bridging a Swift tuple through
        // `as AnyObject?` — and nothing is emitted, so no dangling `Tuple` import can appear.
        let mut remquo = func(
            "remquo",
            vec![],
            ty(TypeRefKind::Class {
                name: "Tuple".into(),
                framework: Some("CoreGraphics".into()),
                params: vec![],
            }),
        );
        remquo.objc_exposed = false;
        remquo.swift_fn = Some(SwiftFnInfo::default());
        let consts = vec![remquo];
        assert_eq!(count(&consts, "CoreGraphics", &ClassRegistry::new()), 0);
        let (ts, _) = render(&consts, "CoreGraphics", &ClassRegistry::new(), &[]);
        assert!(!ts.contains("remquo"), "{ts}");
        assert!(!ts.contains("Tuple"), "{ts}");
    }

    #[test]
    fn swift_native_object_return_binds_the_trampoline_and_is_always_wrapowned() {
        // A Swift-native (objc_exposed == false) function returning an object binds to its
        // call-by-name trampoline `aw_ts_swift_*`, and — because the trampoline hands a uniform +1
        // (`Unmanaged.passRetained`, ADR-0057 §4) — its object return is ALWAYS `__wrapOwned`,
        // regardless of the CF Create/Copy name rule (object-bridged-returns-k55, ADR-0061 §3).
        // `TKThing` must be a class the IR declares, or the return is a Swift nominal type and
        // defers — that registry check is what keeps `Tuple` out (see the test above).
        let mut swift_obj = func(
            "TKSwiftMakeThing", // no Create/Copy → a *C* function would pick __wrapRetained
            vec![],
            ty(TypeRefKind::Class {
                name: "TKThing".into(),
                framework: None,
                params: vec![],
            }),
        );
        swift_obj.objc_exposed = false;
        swift_obj.swift_fn = Some(SwiftFnInfo::default());
        let consts = vec![swift_obj];
        let mut reg = ClassRegistry::new();
        reg.insert("TKThing", "testkit");
        assert_eq!(count(&consts, "TestKit", &reg), 1);
        let (ts, dts) = render(&consts, "TestKit", &reg, &[]);
        assert!(
            ts.contains("export function TKSwiftMakeThing(): TKThing {"),
            "{ts}"
        );
        // The Swift-native residual entry (module + symbol), not the plain-C aw_ts_fn_.
        assert!(
            ts.contains("const __ret = __dispatch.aw_ts_swift_TestKit_TKSwiftMakeThing();"),
            "{ts}"
        );
        // Always __wrapOwned (the trampoline's +1), non-null return → the `!` assertion.
        assert!(ts.contains("return __wrapOwned(TKThing, __ret)!;"), "{ts}");
        assert!(
            !ts.contains("__wrapRetained"),
            "a Swift-native residual object return is a uniform +1 (never __wrapRetained):\n{ts}"
        );
        assert!(ts.contains("  __wrapOwned,\n"), "{ts}");
        assert!(
            dts.contains("export function TKSwiftMakeThing(): TKThing;"),
            "{dts}"
        );
    }

    #[test]
    fn variadic_inline_pointer_and_swift_native_object_param_functions_defer() {
        // A Swift-native function with an OBJECT PARAM still defers — object-bridged-returns-k55
        // binds object *returns* only; params are a later frontier (NonScalarParam).
        let mut swift_obj_param = func(
            "TKSwiftConsume",
            vec![param(
                "x",
                ty(TypeRefKind::Id {
                    protocols: Vec::new(),
                }),
            )],
            TypeRef::void(),
        );
        swift_obj_param.objc_exposed = false;
        swift_obj_param.swift_fn = Some(SwiftFnInfo::default());
        let mut variadic = func("TKFormat", vec![], TypeRef::void());
        variadic.variadic = true;
        let mut inline = func(
            "TKFastHash",
            vec![],
            ty(TypeRefKind::Primitive {
                name: "uint64".into(),
            }),
        );
        inline.inline = true;
        // A raw-pointer param (the NSError** shape) defers.
        let error_out = func(
            "TKReadInto",
            vec![param("err", ty(TypeRefKind::Pointer))],
            TypeRef::void(),
        );
        let consts = vec![swift_obj_param, variadic, inline, error_out];
        assert_eq!(count(&consts, "TestKit", &ClassRegistry::new()), 0);
        let (ts, _) = render(&consts, "TestKit", &ClassRegistry::new(), &[]);
        for name in ["TKSwiftConsume", "TKFormat", "TKFastHash", "TKReadInto"] {
            assert!(!ts.contains(name), "{name} should defer:\n{ts}");
        }
    }

    #[test]
    fn unnamed_and_colliding_params_get_distinct_formals() {
        let consts = vec![func(
            "TKPair",
            vec![
                param(
                    "",
                    ty(TypeRefKind::Primitive {
                        name: "double".into(),
                    }),
                ),
                param(
                    "value",
                    ty(TypeRefKind::Primitive {
                        name: "double".into(),
                    }),
                ),
                param(
                    "value",
                    ty(TypeRefKind::Primitive {
                        name: "double".into(),
                    }),
                ),
            ],
            TypeRef::void(),
        )];
        let (ts, _) = render(&consts, "TestKit", &ClassRegistry::new(), &[]);
        // Empty → arg0; the second `value` → value1.
        assert!(
            ts.contains(
                "export function TKPair(arg0: number, value: number, value1: number): void {"
            ),
            "{ts}"
        );
    }

    #[test]
    fn empty_functions_emit_only_a_banner() {
        let (ts, dts) = render(&[], "TestKit", &ClassRegistry::new(), &[]);
        assert!(ts.contains("// Functions: TestKit (module @apianyware/testkit)"));
        assert!(!ts.contains("export function"));
        assert!(dts.contains("// Type surface: functions (TestKit)"));
        assert_eq!(count(&[], "TestKit", &ClassRegistry::new()), 0);
    }
}

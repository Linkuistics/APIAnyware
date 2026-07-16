//! Per-class ES6 `.ts` body emission — the runtime half of ADR-0055's object model.
//!
//! Each bound ObjC class becomes one real
//!
//! ```ts
//! export class NSString extends NSObject {
//!   static readonly __cls: bigint = __class('NSString');
//!   static stringWithUTF8String_(s: string): NSString { … }
//!   length(): number { … }
//! }
//! ```
//!
//! - a true `extends` chain (`cls.superclass` via [`crate::naming::class_type_name`];
//!   empty/`NSObject` → the runtime-owned root `NSObject`);
//! - the **branded native handle**, the internal `constructor(handle)`, and the
//!   `[Symbol.dispose]` hook live on the runtime `NSObject` (ADR-0055 §6/§7,
//!   ADR-0057) — emitted subclasses **inherit** them and declare **nothing**, so
//!   `new NSString(id)` (used by the wrap primitives) works through the inherited ctor;
//! - each **method body** is a *coercion-free* call into the addon's per-signature
//!   dispatch entry ([`crate::native_dispatch`], ADR-0054 §4): object args and the
//!   receiver are `__unwrap`ped to `bigint` handles, scalars pass through, and an
//!   object result is wrapped by the ownership-driven primitive.
//!
//! ## The runtime seam this module *defines* (Step 3 provides it)
//!
//! Pure codegen (ADR-0011): the emitted `.ts` references primitives the **runtime
//! library** (Step 3) will provide, imported from `@apianyware/runtime`. This module
//! fixes that contract (the TS analogue of sbcl's baked "040→050 runtime seam"):
//!
//! - `NSObject` — the branded-handle root class (internal ctor + `[Symbol.dispose]`);
//! - `__unwrap(obj)` → the receiver/arg native handle (`0n` for `null`; throws
//!   `ObjectDisposedError` on a disposed handle, ADR-0057 §6);
//! - `__wrapRetained(Cls, id)` (+0 autoreleased) / `__wrapOwned(Cls, id)` (+1 owned)
//!   → the uniqued branded wrapper (`null` when `id` is `0n`); retain folds into the
//!   dispatch entry (ADR-0057 §2/§4). A **non-null** object return asserts the wrap
//!   with `!` (the API promised non-null); a nullable return keeps `Cls | null`;
//! - `__class(name)` → the ObjC `Class` handle (a static-factory receiver);
//!   `__sel(selector)` → the interned `SEL` handle;
//! - `__dispatch.aw_ts_msg_<codes>(recv, sel, …)` → the addon's dispatch entry.
//!
//! ## Scope — one class, plain object/scalar surface
//!
//! Emits a class's **own** declared methods (`cls.methods`, static + instance);
//! inheritance rides `extends`, so inherited methods are never re-emitted. `init…`
//! is a normal instance method returning the type (faithful `alloc`/`init` — `alloc`
//! itself is inherited from the runtime `NSObject`). Each referenced class type (the
//! superclass, an object param/return class) is imported from its **owning module** via
//! the injected [`ClassModuleResolver`] ([`crate::imports`]); the runtime-seam symbols
//! merge into the `@apianyware/runtime` block. The superclass-before-subclass load order
//! and the per-framework file/barrel orchestration are the orchestrator's job
//! ([`crate::emit_framework`]). C-string / by-value-geometry body marshalling and blocks
//! are later refinements (the method filter defers what the body cannot yet express).

use std::collections::{BTreeMap, BTreeSet, HashSet};

use apianyware_emit::code_writer::CodeWriter;
use apianyware_emit::ffi_type_mapping::FfiTypeMapper;
use apianyware_emit::write_line;
use apianyware_types::ir::{Class, Method};
use apianyware_types::type_ref::{TypeRef, TypeRefKind};

use crate::class_binding::surface_class_name;
use crate::class_graph::{ClassModuleResolver, RUNTIME_MODULE};
use crate::class_surface::{
    bound_methods, class_header, deprecation_doc, has_bindable_init, method_header,
    protocol_import_names, referenced_class_types, referenced_enum_types, referenced_pod_types,
    visible_params,
};
use crate::delegate_spec::{bound_slots, is_initializer, referenced_spec_types, spec_symbol};
use crate::enum_graph::EnumModuleResolver;
use crate::ffi_type_mapping::TsFfiTypeMapper;
use crate::imports::{
    class_type_imports, enum_type_imports, merge_type_imports, pod_type_imports,
    protocol_spec_imports, protocol_type_imports, render_import_blocks, render_type_import_blocks,
    runtime_overridable_type_import, runtime_result_type_import,
};
use crate::inbound_table::InboundSig;
use crate::method_filter::is_error_out_method;
use crate::naming::{class_type_name, param_identifier};
use crate::native_dispatch::{AbiType, NativeSig, RetainAxis};
use crate::override_widening::OverrideWidenings;
use crate::protocol_binding::id_surface_type;
use crate::protocol_graph::ProtocolModuleResolver;
use crate::ptr_value::PtrValue;
use crate::subclass_surface::{
    overridable_methods, overridable_seam_symbols, render_overridable_static, OverridableEntry,
};

/// Render one bound ObjC class as a self-contained ES6 `.ts` module string: the
/// import preamble (each referenced class type routed to its owning module via the
/// `resolver`, referenced enum types routed via the `enum_resolver` as type-only imports,
/// plus the runtime-seam block), the `export class … extends …` declaration, its
/// per-class `__cls`, and the static + instance method bodies. Pure codegen — the
/// resolvers place cross-module imports; the orchestrator ([`crate::emit_framework`])
/// supplies them per framework. The `enum_resolver` also carries the recognition set the
/// enum-aware [`TsFfiTypeMapper`] is built from (enum-alias-typing, ADR-0055 §6).
#[allow(clippy::too_many_arguments)]
pub fn render_class(
    cls: &Class,
    resolver: &ClassModuleResolver<'_>,
    enum_resolver: &EnumModuleResolver<'_>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
    error_selectors: &HashSet<String>,
    retaining: &HashSet<(String, usize)>,
    widenings: &OverrideWidenings,
    synthetic_init_blocklist: &BTreeSet<String>,
) -> String {
    // All three recognition sets: the framework's enums (an alias upgrades off `number`, ADR-0055
    // §6), the whole-program declared-class set (an unbound `Class{…}` degrades to the root, and a
    // `.swiftinterface` nominal type defers the member — `class_binding`, k66), and the protocol
    // recognition set (a bound `id<P>` qualifier types the slot by its interface — `protocol_binding`,
    // k89; it is the same set the `implements` clause is filtered on, which is what makes the two
    // admit the same calls).
    let mapper = TsFfiTypeMapper::with_known(
        enum_resolver.known_enums(),
        resolver.known_classes(),
        protocol_resolver.known_protocols(),
    );

    // The class's *own* bindable methods, split static / instance — the shared
    // frontier the paired `.d.ts` declares too, so the two cannot drift
    // ([`crate::class_surface`]). `init…` stays an instance method (faithful
    // `alloc`/`init` — ADR-0055 §6); inherited methods ride `extends`. A fallible
    // `…error:` method (its selector in `error_selectors`) is admitted here and emits a
    // `Result<T>` body (ADR-0058).
    let (class_methods, instance_methods) =
        bound_methods(cls, &mapper, error_selectors, protocol_resolver.registry());

    // Whether this class's real ancestry leaves it with no bindable plain `init` at all
    // (`nsobject-plain-init-surface-gap-k122`) — the true ObjC root's `-init` is never itself
    // extracted as a declared entity, so a class with no init-redeclaring ancestor has nothing
    // to inherit through `extends`. The `synthetic_init_blocklist` exception: a real descendant
    // somewhere in the corpus already has its own incompatible bare `init` override, so adding
    // one here would create a NEW TS override-compatibility error that did not exist before this
    // class had any `init` at all ([`crate::class_graph::synthetic_init_blocklist`]). The ONE
    // decision this render pass and the paired `.d.ts` ([`crate::emit_dts::render_dts`]) both
    // read, so the two cannot drift on whether the synthetic method exists.
    let needs_synthetic_init =
        !has_bindable_init(cls, &mapper, error_selectors) && !synthetic_init_blocklist.contains(&cls.name);

    // The class's OWN subclass-overridable instance methods (ADR-0059 §4) — a static data
    // catalogue, never accumulated (the runtime merges the ancestor chain at use,
    // [`crate::subclass_surface`] module doc). `deferred` (a signature outside the inbound
    // alphabet) is counted, not silently dropped — already surfaced by the identical-frontier
    // native inbound table's own pass log, so no second report is needed here.
    let (overridable, _deferred) =
        overridable_methods(cls, &mapper, error_selectors, protocol_resolver.registry());

    let mut w = CodeWriter::new();
    emit_header(
        &mut w,
        cls,
        &class_methods,
        &instance_methods,
        &overridable,
        &mapper,
        resolver,
        enum_resolver,
        protocol_resolver,
        error_selectors,
        retaining,
        widenings,
        needs_synthetic_init,
    );

    write_line!(w, "{} {{", class_header(cls, protocol_resolver, &mapper));
    w.indent();

    // Register this class under its ObjC runtime name, so a `Class` handle crossing OUT of ObjC
    // resolves back to this constructor (`__classCtor`, classes.ts — the gerbil ADR-0020 /
    // sbcl ADR-0034 registry convention). An ES2022 **static block**: it runs at class definition,
    // any bundler that keeps the class keeps it (unlike a bare top-level call, which a
    // `sideEffects: false` tree-shake could drop), and it does not appear in the `.d.ts` — so the
    // declaration surface stays free of dispatch internals (ADR-0055 §2).
    write_line!(
        w,
        "static {{ __registerClass('{}', {}); }}",
        cls.name,
        class_type_name(&cls.name)
    );

    // The overridable-method catalogue `super.ts`'s `__allocSubclass`/`this.$super` read
    // (ADR-0059 §4) — data only, like the registration block above; absent entirely when this
    // class has no overridable instance method (the `__cls` block's own convention, below).
    if !overridable.is_empty() {
        w.blank_line();
        render_overridable_static(&mut w, &overridable);
    }
    let mut first = false;

    // The per-class `Class` handle, the receiver for static factories. Only classes with at least
    // one static method need it — the *registry*, not this static, is what a `Class` **value**
    // crosses through, so a class with no static methods needs none.
    if !class_methods.is_empty() {
        w.blank_line();
        write_line!(
            w,
            "static readonly __cls: bigint = __class('{}');",
            cls.name
        );
    }
    // Statics first, then instance methods, each separated by one blank line.
    for m in class_methods.iter().chain(instance_methods.iter()) {
        if !first {
            w.blank_line();
        }
        first = false;
        emit_method(
            &mut w,
            cls,
            m,
            &mapper,
            error_selectors,
            retaining,
            widenings,
        );
    }

    // A class whose real ancestry never redeclares `-init` gets a synthetic plain initializer —
    // the instance-side dual of the runtime-inherited `alloc` (module doc; k122).
    if needs_synthetic_init {
        w.blank_line();
        emit_synthetic_init(&mut w);
    }

    w.dedent();
    w.line("}");
    w.finish()
}

/// The generated-file banner + the runtime-seam doc + the per-module import blocks
/// (each referenced class type routed to its owning module via the resolver; the
/// runtime-seam symbols merged into the `@apianyware/runtime` block), then the
/// **type-only** enum imports (each referenced enum routed via the `enum_resolver`).
#[allow(clippy::too_many_arguments)]
fn emit_header(
    w: &mut CodeWriter,
    cls: &Class,
    class_methods: &[&Method],
    instance_methods: &[&Method],
    overridable: &[OverridableEntry],
    mapper: &TsFfiTypeMapper,
    resolver: &ClassModuleResolver<'_>,
    enum_resolver: &EnumModuleResolver<'_>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
    error_selectors: &HashSet<String>,
    retaining: &HashSet<(String, usize)>,
    widenings: &OverrideWidenings,
    needs_synthetic_init: bool,
) {
    let has_fallible = class_methods
        .iter()
        .chain(instance_methods.iter())
        .any(|m| is_error_out_method(m, error_selectors));

    w.line("// Generated by apianyware emit-typescript — DO NOT EDIT.");
    write_line!(w, "// Class: {} ({})", cls.name, resolver.framework());
    w.line("//");
    w.line("// Runtime seam (Step 3 provides these from '@apianyware/runtime'; ADR-0055/0057):");
    w.line("//   NSObject — branded-handle root class; its internal ctor wraps a handle and hosts");
    w.line("//     [Symbol.dispose]. Emitted subclasses inherit both and declare neither.");
    w.line("//   __unwrap(obj) — obj's native handle (0n for null; throws on a disposed handle).");
    w.line("//   __wrapRetained(Cls, id) / __wrapOwned(Cls, id) — the +0 / +1 uniqued branded");
    w.line("//     wrapper (null when id is 0n; retain folds into the dispatch entry).");
    w.line("//   __class(name) — the Class handle; __sel(sel) — the interned SEL handle.");
    w.line(
        "//   __registerClass(name, cls) — registers this class so a Class RETURN resolves back",
    );
    w.line("//     to it; __classArg(cls) / __classCtor(id) — the Class value crossing, in / out;");
    w.line("//     __selName(sel) — a SEL handle back to its selector-name string.");
    w.line("//   __dispatch.aw_ts_msg_<codes>(recv, sel, …) — the addon's per-signature entry.");
    if has_fallible {
        w.line(
            "//   Result<T> / __resultRetained(Cls, r) / __resultOwned(Cls, r) / __resultScalar(r)",
        );
        w.line(
            "//     — the NSError** → Result<T> channel (ADR-0058): the addon's `…_e` entry keys",
        );
        w.line(
            "//     failure on the primary return + @catches, the runtime builds the discriminated",
        );
        w.line("//     union (ok:false carries the wrapped NSError).");
    }
    if needs_synthetic_init {
        w.line(
            "//   __init(obj) — the universal `-init` primitive for a class whose real ancestry",
        );
        w.line(
            "//     never redeclares it (k122): the same id -> id dispatch shape a real init() body",
        );
        w.line("//     calls, reused as one shared runtime primitive rather than a per-class copy.");
    }
    w.blank_line();

    // Value imports: the referenced class types (routed through the resolver) with the
    // runtime-seam symbols merged into the runtime block. Type-only imports: referenced enum
    // types (enum-alias-typing) merged with the class's protocol interfaces (an interface
    // reference is erased, so it is type-only), the referenced POD geometry types (runtime-owned
    // plain object types, ADR-0055 §5) and, for a class with a fallible `…error:` method, the
    // runtime `Result<T>` type (ADR-0058) — one combined `import type` section per module, so
    // same-framework enum/protocol and runtime POD/Result coalesce into a block apiece.
    let mut map = build_import_map(
        cls,
        class_methods,
        instance_methods,
        mapper,
        resolver,
        protocol_resolver,
        error_selectors,
        retaining,
        widenings,
    );
    // The synthetic `init(): this`'s one seam symbol (module doc on [`emit_synthetic_init`]) —
    // added here rather than threaded through [`build_import_map`]/[`seam_symbols`], since it
    // answers to `needs_synthetic_init` alone, not to any real method in `class_methods`/
    // `instance_methods`.
    if needs_synthetic_init {
        map.entry(RUNTIME_MODULE.to_string())
            .or_default()
            .insert("__init".to_string());
    }
    // The `ArgKind`/`RetKind` constants an emitted `__overridable` catalogue references — computed
    // from the SAME entries [`render_overridable_static`] renders, so the import block and the
    // literal it accompanies cannot drift (mirrors [`crate::delegate_spec::render_spec_imports`]).
    let overridable_seam = overridable_seam_symbols(overridable);
    if !overridable_seam.is_empty() {
        map.entry(RUNTIME_MODULE.to_string())
            .or_default()
            .extend(overridable_seam);
    }
    let enum_map = enum_type_imports(
        &referenced_enum_types(class_methods, instance_methods, mapper),
        enum_resolver,
    );
    // Two sources of the same import kind, unioned before grouping so a protocol that is both
    // conformed and referenced imports once: the class's **conformed** protocols (its `implements`
    // clause, ADR-0055 §4) and the protocols its signatures **name** through a bound `id<P>`
    // qualifier (ADR-0055 §4b). Both are gated on one recognition set, so the clause and the type
    // surface cannot admit different calls.
    let proto_map = protocol_type_imports(
        &protocol_import_names(
            cls,
            class_methods,
            instance_methods,
            mapper,
            protocol_resolver,
            widenings,
        ),
        protocol_resolver,
        mapper,
    );
    let pod_map = pod_type_imports(&referenced_pod_types(class_methods, instance_methods));
    let type_map = merge_type_imports(
        merge_type_imports(
            merge_type_imports(merge_type_imports(enum_map, proto_map), pod_map),
            runtime_result_type_import(has_fallible),
        ),
        runtime_overridable_type_import(!overridable.is_empty()),
    );
    render_import_blocks(&map, w);
    render_type_import_blocks(&type_map, w);
    if !map.is_empty() || !type_map.is_empty() {
        w.blank_line();
    }
}

/// The class's **value** imports grouped by owning module: the referenced class types routed
/// through the resolver ([`crate::imports::class_type_imports`], shared with the
/// `.d.ts`), the `SPEC_<P>` delegate specs its bound `id<P>` slots bridge through (routed by the
/// *protocol* resolver — a spec is runtime data, so unlike its interface it is a value import), and
/// the `.ts`-only runtime-seam symbols merged into the `@apianyware/runtime` block. Seam helpers
/// always import from the runtime; the `NSObject` root also resolves there, so the two coalesce into
/// a single block (the `NSObject`-rooted goldens stay byte-identical to the pre-resolver output).
#[allow(clippy::too_many_arguments)]
fn build_import_map(
    cls: &Class,
    class_methods: &[&Method],
    instance_methods: &[&Method],
    mapper: &TsFfiTypeMapper,
    resolver: &ClassModuleResolver<'_>,
    protocol_resolver: &ProtocolModuleResolver<'_>,
    error_selectors: &HashSet<String>,
    retaining: &HashSet<(String, usize)>,
    widenings: &OverrideWidenings,
) -> BTreeMap<String, BTreeSet<String>> {
    let referenced =
        referenced_class_types(cls, class_methods, instance_methods, mapper, widenings);
    let mut map = class_type_imports(&referenced, resolver);

    // The specs the bodies name. Collected from the same `bound_slots` predicate the bodies render
    // from, so an emitted `__protocolArg(…, SPEC_P, …)` always has its import and no unused one is
    // written.
    let methods: Vec<&Method> = class_methods
        .iter()
        .chain(instance_methods.iter())
        .copied()
        .collect();
    let specs = protocol_spec_imports(
        &referenced_spec_types(&methods, mapper, retaining),
        protocol_resolver,
    );
    for (module, names) in specs {
        map.entry(module).or_default().extend(names);
    }

    let seam = seam_symbols(
        class_methods,
        instance_methods,
        mapper,
        error_selectors,
        retaining,
    );
    if !seam.is_empty() {
        map.entry(RUNTIME_MODULE.to_string())
            .or_default()
            .extend(seam);
    }
    map
}

/// The `Result`-building helper for a fallible method's **non-object** primary
/// (ADR-0058, reconciled by `nonbool-fallible-scalar-result-k101`): a **BOOL** primary
/// carries no information beyond the flag itself, so `__resultScalar` hard-codes
/// `value: true`; any other admitted scalar (an integer width — float/double/struct/void
/// primaries all defer upstream, [`crate::method_filter::is_supported_method_ctx`]) has a
/// nonzero success value the caller actually wants (a byte count, e.g.
/// `NSJSONSerialization.writeJSONObject(_:toStream:options:) throws -> Int`), so it routes
/// through the value-carrying `__resultScalarValue` instead. Both key `ok:false` on a
/// zero/`NO` primary identically (ADR-0058's "check the return, not the error"); only the
/// success arm differs.
fn fallible_scalar_result_symbol(m: &Method) -> &'static str {
    if AbiType::from_type_ref(&m.return_type) == Some(AbiType::Bool) {
        "__resultScalar"
    } else {
        "__resultScalarValue"
    }
}

/// The inbound signature code (`InboundSig::code_string`, e.g. `"q_v"`) of a block-typed
/// param — the narrow `block-call-site-emission-k120` carve-out's crossing. Derived from
/// the IR at emit time (never hard-coded to one signature string): the admission gate
/// ([`crate::method_filter::is_supported_method`]) only lets an *admitted selector*
/// through, but the code here reads whatever block shape that selector's IR actually
/// carries, so a future corpus regeneration that changes the shape changes the emitted
/// signature too rather than silently mismatching a hard-coded one. `None` only if that
/// shape somehow falls outside the inbound alphabet — an invariant the filter is
/// responsible for upholding; the caller panics rather than emit a call site naming a
/// block-maker that does not exist.
fn block_signature_code(t: &TypeRef) -> Option<String> {
    match &t.kind {
        TypeRefKind::Block {
            params,
            return_type,
        } => InboundSig::from_block(params, return_type).map(|sig| sig.code_string()),
        _ => None,
    }
}

/// The runtime-seam **value** symbols the emitted bodies call — a `.ts`-only concern the
/// `.d.ts` never has. `__dispatch`/`__sel` whenever any method dispatches; `__class` for a
/// static-factory receiver; `__unwrap` for an instance receiver or any object arg;
/// `__wrapOwned`/`__wrapRetained` per an object return's +1/+0 ownership (ADR-0057). A
/// fallible `…error:` method (ADR-0058) instead routes its primary through the
/// `Result`-building helper: `__resultOwned`/`__resultRetained` for a +1/+0 object primary,
/// [`fallible_scalar_result_symbol`] for a scalar/BOOL primary. (`Result` itself is a
/// **type** — imported type-only in [`emit_header`], not a value symbol.)
fn seam_symbols(
    class_methods: &[&Method],
    instance_methods: &[&Method],
    mapper: &TsFfiTypeMapper,
    error_selectors: &HashSet<String>,
    retaining: &HashSet<(String, usize)>,
) -> BTreeSet<String> {
    let mut set: BTreeSet<String> = BTreeSet::new();
    // The bound-`id<P>` bridge (ADR-0055 §4b): every such slot routes through `__protocolArg`, and an
    // initializer's additionally through `__protocolAdopt`. Computed from the same `bound_slots` /
    // `is_initializer` predicates the bodies render from, so the import set and the bodies agree.
    for m in class_methods.iter().chain(instance_methods.iter()) {
        if bound_slots(m, mapper, retaining).is_empty() {
            continue;
        }
        set.insert("__protocolArg".to_string());
        if adopts_slots(m, mapper, error_selectors, retaining) {
            set.insert("__protocolAdopt".to_string());
        }
    }
    // Every class registers itself under its ObjC runtime name, so a `Class` handle crossing OUT of
    // ObjC resolves to this constructor (`__classCtor`, classes.ts). Unconditional — a class the
    // registry does not know can only degrade to a stand-in.
    set.insert("__registerClass".to_string());
    let has_any = !class_methods.is_empty() || !instance_methods.is_empty();
    if has_any {
        set.insert("__dispatch".to_string());
        set.insert("__sel".to_string());
    }
    if !class_methods.is_empty() {
        set.insert("__class".to_string());
    }
    if !instance_methods.is_empty() {
        set.insert("__unwrap".to_string()); // every instance body unwraps its receiver `this`
    }
    for m in class_methods.iter().chain(instance_methods.iter()) {
        let fallible = is_error_out_method(m, error_selectors);
        let slots = bound_slots(m, mapper, retaining);
        for (i, p) in visible_params(m, fallible).iter().enumerate() {
            // The param arm, single-sourced with `emit_body`'s rendering: a **bound `id<P>` slot**
            // bridges through `__protocolArg` (added above — it does its own unwrapping, so it needs
            // no `__unwrap` here); a **block** param (the narrow `block-call-site-emission-k120`
            // carve-out) bridges through `__makeEscapingBlock`; a `SEL`/`Class` param names its own
            // crossing helper ([`PtrValue`]); an object param `__unwrap`s; a scalar needs nothing.
            if slots.iter().any(|s| s.index == i) {
                continue;
            }
            if mapper.is_block_type(&p.param_type) {
                set.insert("__makeEscapingBlock".to_string());
            } else if let Some(pv) = PtrValue::of(&p.param_type) {
                set.insert(pv.param_symbol().to_string());
            } else if mapper.is_object_type(&p.param_type) {
                set.insert("__unwrap".to_string());
            }
        }
        // The return arm. A `SEL`/`Class` return converts (it is the `_n` axis, split by kind) and
        // is never fallible — [`is_supported_method_ctx`] defers a fallible `…error:` method with a
        // `SEL`/`Class` primary, since a raw handle cannot ride the `Result<T>` ok-branch. Every
        // other return reads the single retain-axis decision `emit_body` renders from (k70), so the
        // imported helper set and the rendered bodies cannot drift.
        if let Some(pv) = PtrValue::of(&m.return_type) {
            set.insert(pv.return_symbol().to_string());
            continue;
        }
        match (fallible, method_retain_axis(m, mapper)) {
            (true, Some(RetainAxis::Owned)) => {
                set.insert("__resultOwned".to_string());
            }
            (true, Some(RetainAxis::FoldRetain)) => {
                set.insert("__resultRetained".to_string());
            }
            (true, Some(RetainAxis::NoWrap) | None) => {
                set.insert(fallible_scalar_result_symbol(m).to_string());
            }
            (false, Some(RetainAxis::Owned)) => {
                set.insert("__wrapOwned".to_string());
            }
            (false, Some(RetainAxis::FoldRetain)) => {
                set.insert("__wrapRetained".to_string());
            }
            // A non-object pointer (`_n`) or scalar return needs no wrap helper.
            (false, Some(RetainAxis::NoWrap) | None) => {}
        }
    }
    set
}

/// Emit one method: `<static?> <name>(<params>): <ret> { <body> }`. The signature
/// header is the shared [`method_header`] — the same computation the paired `.d.ts`
/// declaration uses, so runtime and types cannot drift ([`crate::class_surface`]).
/// `error_selectors` routes a fallible `…error:` method to the `Result<T>` header + body
/// (ADR-0058).
fn emit_method(
    w: &mut CodeWriter,
    cls: &Class,
    m: &Method,
    mapper: &TsFfiTypeMapper,
    error_selectors: &HashSet<String>,
    retaining: &HashSet<(String, usize)>,
    widenings: &OverrideWidenings,
) {
    if let Some(doc) = deprecation_doc(m) {
        w.line(doc);
    }
    write_line!(
        w,
        "{} {{",
        method_header(cls, m, mapper, error_selectors, widenings)
    );
    w.indent();
    emit_body(w, cls, m, mapper, error_selectors, retaining);
    w.dedent();
    w.line("}");
}

/// The plain `init(): this` given to a class whose real ancestry never redeclares `-init`
/// ([`has_bindable_init`], `nsobject-plain-init-surface-gap-k122`) — one fixed, hand-written
/// body rather than a per-class generated copy, exactly as `alloc` is a single runtime
/// primitive rather than emitted per class ([`crate::class_graph`] module doc). `__init`
/// (`@apianyware/runtime`) wraps the same `id -> id` dispatch shape any real own-declared
/// `init()` body already calls; dynamic ObjC dispatch resolves the message send correctly
/// regardless of whether some ancestor overrides it — this is only a stand-in for a class
/// whose ancestry has none.
pub(crate) fn emit_synthetic_init(w: &mut CodeWriter) {
    w.line("init(): this {");
    w.indent();
    w.line("return __init(this);");
    w.dedent();
    w.line("}");
}

/// Emit a method body — a coercion-free dispatch call plus result handling. Void →
/// a bare statement; an object result → `__ret` + the ownership-driven wrap (with a
/// `!` non-null assertion for a non-null return); a scalar → a direct return. A fallible
/// `…error:` method (ADR-0058) drops the trailing `NSError**` cell from the args, calls the
/// `…_e` dispatch entry, and routes the primary through a `Result`-building helper.
///
/// A **bound `id<P>` param** (ADR-0055 §4b) does not `__unwrap`: it routes through `__protocolArg`,
/// which discriminates a wrapped ObjC object from a plain JS object and bridges the latter through
/// the protocol's generated `DelegateSpec` (`emitted-delegate-spec-k84`). Its `owner` is the very
/// receiver expression this body already computed — `__unwrap(this)`, or the class's `__cls` for a
/// static slot — **except** on an initializer, whose slot is owned by the object `init` *returns*
/// ([`is_initializer`]): there the arg is hoisted, handed over `+0`-autoreleased, and adopted onto
/// `__ret` once it exists.
fn emit_body(
    w: &mut CodeWriter,
    cls: &Class,
    m: &Method,
    mapper: &TsFfiTypeMapper,
    error_selectors: &HashSet<String>,
    retaining: &HashSet<(String, usize)>,
) {
    let fallible = is_error_out_method(m, error_selectors);
    let sig = if fallible {
        NativeSig::error_out_from_method(m)
    } else {
        NativeSig::from_method(m)
    };
    // The retain-convention axis (ADR-0057 §4): ONE decision — [`method_retain_axis`]
    // — picks both the entry-name suffix here and the wrap primitive below, so they
    // can never disagree. A +1 object return rides the non-folding `_o` sibling (no
    // double retain); a +0 object return keeps the bare folding entry; a non-object
    // pointer return (`SEL`/`Class`) rides the non-folding, non-wrapping `_n` sibling
    // (k70); a scalar has no axis.
    let axis = method_retain_axis(m, mapper);
    let entry = sig
        .expect("a supported method has a routable dispatch signature")
        .entry_name(axis);

    let receiver = if m.class_method {
        format!("{}.__cls", class_type_name(&cls.name))
    } else {
        "__unwrap(this)".to_string()
    };

    // The bound `id<P>` slots (if any) and who owns their keep-alive. An initializer's owner is its
    // *result*, which does not exist until the call returns — so its slots hoist. A **fallible**
    // initializer would have no raw `__ret` handle to adopt onto; there are none in the corpus, and
    // `delegate_spec::slot_report` counts them in the pass log rather than letting one pass silently.
    let slots = bound_slots(m, mapper, retaining);
    let hoist = adopts_slots(m, mapper, error_selectors, retaining);
    if hoist {
        for s in &slots {
            write_line!(
                w,
                "const __a{} = __protocolArg(0n, '{}', {}, {}, {});",
                s.index,
                s.key,
                param_identifier(&m.params[s.index].name),
                spec_symbol(&s.protocol),
                s.associate
            );
        }
    }

    let mut args = vec![receiver.clone(), format!("__sel('{}')", m.selector)];
    for (i, p) in visible_params(m, fallible).iter().enumerate() {
        // A bound `id<P>` slot bridges (above); a **block** param (the narrow
        // `block-call-site-emission-k120` carve-out) becomes a real escaping ObjC block via
        // `__makeEscapingBlock`, signature-coded from the IR (never hard-coded — a future
        // corpus regeneration that changed the shape would change this too); objects cross as
        // `bigint` handles (unwrapped); a `SEL`/`Class` — pointer-shaped but no object —
        // converts through its own crossing ([`PtrValue`]); scalars pass through uncoerced (the
        // coercion-free crossing, ADR-0054 §4). A fallible method's trailing `NSError**` cell is
        // not a visible arg (the runtime passes `&err`), and no bound slot ever sits in it.
        args.push(if let Some(s) = slots.iter().find(|s| s.index == i) {
            if hoist {
                format!("__a{}", s.index)
            } else {
                format!(
                    "__protocolArg({receiver}, '{}', {}, {}, {})",
                    s.key,
                    param_identifier(&p.name),
                    spec_symbol(&s.protocol),
                    s.associate
                )
            }
        } else if mapper.is_block_type(&p.param_type) {
            let code = block_signature_code(&p.param_type).expect(
                "an admitted completion-handler param has a routable inbound block signature",
            );
            format!(
                "__makeEscapingBlock({}, '{code}')",
                param_identifier(&p.name)
            )
        } else if let Some(pv) = PtrValue::of(&p.param_type) {
            pv.param_expr(&param_identifier(&p.name))
        } else if mapper.is_object_type(&p.param_type) {
            format!("__unwrap({})", param_identifier(&p.name))
        } else {
            param_identifier(&p.name)
        });
    }
    let call = format!("__dispatch.{entry}({})", args.join(", "));

    if hoist {
        // An initializer returns `+1` (the `init` family — [`method_returns_retained`]), so the object
        // arm below always applies; the handle is materialised early so the forwarders can be adopted
        // onto it before the wrapper is minted.
        write_line!(w, "const __ret = {call};");
        for s in &slots {
            write_line!(
                w,
                "__protocolAdopt(__ret, '{}', {}, __a{}, {});",
                s.key,
                param_identifier(&m.params[s.index].name),
                s.index,
                s.associate
            );
        }
        let wrap_fn = if axis == Some(RetainAxis::Owned) {
            "__wrapOwned"
        } else {
            "__wrapRetained"
        };
        let bang = if m.return_type.nullable { "" } else { "!" };
        let c = wrap_class(cls, m, mapper);
        let t = wrap_type_arg(m, mapper);
        write_line!(w, "return {}{bang};", wrap_call(wrap_fn, c, t, "__ret"));
        return;
    }

    if fallible {
        // The `…_e` entry returns a discriminant the Result helper reads: an object primary
        // wraps by its +1/+0 ownership (`__resultOwned`/`__resultRetained`), a scalar/BOOL
        // passes through (`__resultScalar`). The nil/`NO`-on-failure keying + the NSError wrap
        // live in the helper (mechanism native, policy runtime — ADR-0058).
        //
        // A `SEL`/`Class` primary cannot ride this channel — `__resultScalar` would put the raw
        // handle in the `Result<T>` ok-branch, under a declared `string`/`typeof NSObject`. Such a
        // method is DEFERRED upstream by [`is_supported_method_ctx`] (and counted), so it never
        // reaches here; the assertion pins that invariant to the one place it is relied upon.
        debug_assert!(
            PtrValue::of(&m.return_type).is_none(),
            "a fallible SEL/Class primary must be deferred by the method filter, not emitted"
        );
        match axis {
            Some(RetainAxis::Owned) => {
                let c = wrap_class(cls, m, mapper);
                let t = wrap_type_arg(m, mapper);
                write_line!(w, "return {};", wrap_call("__resultOwned", c, t, &call));
            }
            Some(RetainAxis::FoldRetain) => {
                let c = wrap_class(cls, m, mapper);
                let t = wrap_type_arg(m, mapper);
                write_line!(w, "return {};", wrap_call("__resultRetained", c, t, &call));
            }
            Some(RetainAxis::NoWrap) | None => {
                write_line!(w, "return {}({call});", fallible_scalar_result_symbol(m));
            }
        }
        return;
    }

    if mapper.is_void(&m.return_type) {
        write_line!(w, "{call};");
    } else if let Some(pv) = PtrValue::of(&m.return_type) {
        // The `_n` axis, split by kind: a raw `SEL`/`Class` handle converts back to the declared
        // type (a selector name / the bound constructor). Both helpers return `T | null` for the
        // nil handle, so a non-null-declared return takes the same `!` the object arms do.
        let bang = if m.return_type.nullable { "" } else { "!" };
        write_line!(w, "return {}{bang};", pv.return_expr(&call));
    } else if let Some(RetainAxis::FoldRetain | RetainAxis::Owned) = axis {
        write_line!(w, "const __ret = {call};");
        let wrap_fn = if axis == Some(RetainAxis::Owned) {
            "__wrapOwned"
        } else {
            "__wrapRetained"
        };
        let bang = if m.return_type.nullable { "" } else { "!" };
        let c = wrap_class(cls, m, mapper);
        let t = wrap_type_arg(m, mapper);
        write_line!(w, "return {}{bang};", wrap_call(wrap_fn, c, t, "__ret"));
    } else if let Some(enum_name) = mapper.known_enum_name(&m.return_type) {
        // A proven enum crosses the seam as its underlying integer, but a numeric TS
        // `enum` is not *structurally* `number` (`number` is not assignable to the enum
        // type), so the coercion-free result is cast to the enum type. The `as` erases at
        // emit — the ABI crossing stays scalar (enum-alias-typing, ADR-0055 §6).
        write_line!(w, "return {call} as {enum_name};");
    } else {
        // A scalar (`number`/`boolean`) crosses uncoerced — a direct return.
        write_line!(w, "return {call};");
    }
}

/// The concrete TS class the wrap primitive instantiates, or **`None` when the IR names no class**
/// for this return — a bare `id`, or an ObjC generic type param (`ObjectType`), both of which are
/// just `id` at the ABI.
///
/// `None` is the *fact*, not a default, and that is the whole of `dynamic-class-wrap-k88`. It renders
/// the wrap primitive's **class-less arm** (`__wrapRetained(__ret)`, one arg), which resolves the
/// object's **real** ObjC class through the ADR-0055 §5b ctor registry — so
/// `NSArray.array().objectAtIndex_(0)` yields a real `NSString` rather than a bare root object with
/// none of its methods. Previously this arm answered `"NSObject"`, and the lie it minted is what made
/// a protocol-qualified slot impossible to type honestly (`protocol-binding-surface-k89`).
///
/// A class the IR *does* name still wins, and deliberately: a **static factory**'s
/// `instancetype` → the receiver class (the receiver *is* the class); `Class{name}` →
/// whatever the surface renders it as ([`surface_class_name`] — that class, or the
/// degraded root when the IR declares no such class). The IR knows what the ObjC runtime
/// does not say — a declared `NSString` is really a `__NSCFString`, and no binding
/// declares *that*.
///
/// An **instance** method's `instancetype` takes the class-less arm too
/// (`override-signature-mismatch-k100`): unlike a named `Class{name}`, `instancetype`
/// *means* "whatever `self`'s real dynamic class is" — the class-less arm's ctor-registry
/// resolution is the faithful reading, not a fallback, and it is what lets the declared
/// return stay `this` ([`wrap_type_arg`]) rather than the concrete declaring class (which
/// a further JS subclass calling an *inherited* `init` would otherwise be wrapped as,
/// wrongly).
///
/// Routing through the **same** [`surface_class_name`] the declared return type and the import block
/// use is what keeps the three in lockstep: a method returning an unbound `CLLocation *` declares
/// `NSObject`, imports `NSObject`, and wraps `__wrapRetained(NSObject, …)`.
fn wrap_class(cls: &Class, m: &Method, mapper: &TsFfiTypeMapper) -> Option<String> {
    match &m.return_type.kind {
        TypeRefKind::Instancetype if m.class_method => Some(class_type_name(&cls.name)),
        TypeRefKind::Instancetype => None,
        TypeRefKind::Class { name, .. } => Some(surface_class_name(name, mapper)),
        _ => None,
    }
}

/// The **type argument** the class-less wrap arm carries, or `None` when it needs none — the
/// bound-protocol surface of a qualified `id` return (`protocol-binding-surface-k89`), or an
/// **instance** method's `instancetype` (`override-signature-mismatch-k100`).
///
/// k88's class-less arm resolves the object's *real* ObjC class at run time, so its declared return
/// is the widest thing it can promise statically: `NSObject | null`. An instance method's declared
/// return is `this | null` instead — and `NSObject` is not assignable to `this` (the same fact
/// TS2416 caught when the `.ts` used the concrete class). Explicitly instantiating the wrap's type
/// parameter with the literal `this` type needs no cast: `this` satisfies the primitive's `T extends
/// NSObject` bound, and the call's declared return becomes `this | null` — exactly the method's own
/// signature. A bound `id<P>` return is the analogous case one level less polymorphic: `P & NSObject`
/// is what the value *is* ([`id_surface_type`]), spelled where the value is produced so the wrap and
/// the type it satisfies are one string by construction — never two derivations of one fact.
fn wrap_type_arg(m: &Method, mapper: &TsFfiTypeMapper) -> Option<String> {
    if matches!(m.return_type.kind, TypeRefKind::Instancetype) && !m.class_method {
        return Some("this".to_string());
    }
    id_surface_type(&m.return_type, mapper, true)
}

/// Render a wrap/`Result` call. Three arms, spelled in **one** place so a body and its `Result`
/// sibling cannot drift:
///
/// - the IR names a class → `__wrapRetained(NSString, __ret)`;
/// - it names none, and no qualifier binds → `__wrapRetained(__ret)` (k88's dynamic arm);
/// - it names none but the qualifier binds → `__wrapRetained<P & NSObject>(__ret)` — the same
///   dynamic arm, carrying the declared conformance the signature promises ([`wrap_type_arg`]).
///
/// Shared with [`crate::emit_functions`], whose object-returning free functions wrap through the
/// very same three arms — one rule, one spelling.
pub(crate) fn wrap_call(
    wrap_fn: &str,
    class: Option<String>,
    type_arg: Option<String>,
    value: &str,
) -> String {
    match class {
        Some(name) => format!("{wrap_fn}({name}, {value})"),
        None => match type_arg {
            Some(t) => format!("{wrap_fn}<{t}>({value})"),
            None => format!("{wrap_fn}({value})"),
        },
    }
}

/// THE retain-axis decision — the one predicate the mirror discipline hangs on
/// (ADR-0057 §4, k70): [`emit_body`] picks the wrap primitive *and* the entry-name
/// suffix from this value, and [`crate::dispatch_table`]'s collection computes the
/// identical value, so a call site and its table entry can never disagree about the
/// fold. `Some` exactly when the return crosses as a pointer ([`AbiType::Ptr`]);
/// `None` for scalars/void/structs (no retain convention exists).
///
/// The gate reads the **wrap boundary**, never the ABI shape: an object return
/// (`is_object_type` — what the emitted `.ts` wraps) folds at +0 or rides `_o` at
/// +1, while a pointer that is *not* an object (`SEL`, the `Class` metatype — same
/// ABI shape, never wrapped) rides the non-folding, non-wrapping `_n` sibling —
/// retaining a class leaks, and `objc_retain` on a `SEL` is undefined behaviour.
pub(crate) fn method_retain_axis(m: &Method, mapper: &TsFfiTypeMapper) -> Option<RetainAxis> {
    if mapper.is_object_type(&m.return_type) {
        Some(if method_returns_retained(m) {
            RetainAxis::Owned
        } else {
            RetainAxis::FoldRetain
        })
    } else if AbiType::from_type_ref(&m.return_type) == Some(AbiType::Ptr) {
        Some(RetainAxis::NoWrap)
    } else {
        None
    }
}

/// Whether a method returns a +1 *owned* object (→ `__wrapOwned`) vs a +0
/// autoreleased one (→ `__wrapRetained`), per ADR-0057 §2. Prefers the IR's computed
/// `returns_retained`; falls back to the Cocoa naming families (the racket
/// `method_returns_retained` rule — `alloc` is runtime-provided, not emitted, so it
/// is not in the family set here). An input to [`method_retain_axis`] only
/// (meaningful only for an object return) — every table, the super-send one included
/// (k71), reads the axis predicate, never this input directly.
fn method_returns_retained(method: &Method) -> bool {
    if let Some(retained) = method.returns_retained {
        return retained;
    }
    let sel = &method.selector;
    if !method.class_method && is_init_family(sel) {
        return true;
    }
    if method.class_method && is_family_match(sel, "new") {
        return true;
    }
    is_family_match(sel, "copy") || is_family_match(sel, "mutableCopy")
}

/// Whether `selector` is in the Cocoa **`init`** family — the fact that makes a method's return `+1`
/// *and* the fact that makes the object it returns, not its receiver, the owner of any bound `id<P>`
/// slot it takes ([`crate::delegate_spec::is_initializer`]). One derivation, two readers.
pub(crate) fn is_init_family(selector: &str) -> bool {
    is_family_match(selector, "init")
}

/// Whether a method's bound `id<P>` slots are **hoisted and adopted onto its result** rather than
/// associated on its receiver — the initializer shape ([`emit_body`]). THE predicate: [`emit_body`]
/// renders from it and [`seam_symbols`] imports from it, so a body that calls `__protocolAdopt` and
/// the import block that names it cannot disagree.
///
/// It needs an object return to adopt onto, so a fallible initializer — whose body yields a
/// `Result<T>` and never materialises the raw handle — falls back to the receiver-owner arm. There is
/// no such method in the corpus, and [`crate::delegate_spec::slot_report`] counts one loudly if there
/// ever is.
fn adopts_slots(
    m: &Method,
    mapper: &TsFfiTypeMapper,
    error_selectors: &HashSet<String>,
    retaining: &HashSet<(String, usize)>,
) -> bool {
    !bound_slots(m, mapper, retaining).is_empty()
        && !is_error_out_method(m, error_selectors)
        && is_initializer(m)
        && matches!(
            method_retain_axis(m, mapper),
            Some(RetainAxis::Owned | RetainAxis::FoldRetain)
        )
}

/// Whether `selector` belongs to a Cocoa method family (`init`, `new`, `copy`,
/// `mutableCopy`): the family word exactly, or a prefix followed by an uppercase
/// letter / `:` / `(` (racket's `is_family_match`).
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
    use crate::class_graph::ClassRegistry;
    use crate::enum_graph::EnumRegistry;
    use crate::protocol_graph::ProtocolRegistry;
    use apianyware_types::ir::{Class, Method, Param};
    use apianyware_types::provenance::DeclarationSource;
    use apianyware_types::type_ref::TypeRef;
    use std::collections::BTreeSet;
    use std::sync::Arc;

    /// Render a class through a class resolver for framework `fw` backed by `registry` and
    /// an enum resolver aware of `known_enums` — the orchestrator's per-framework shape. An
    /// empty registry is the unconfigured single-framework case (every referenced class
    /// falls back to `fw` or the runtime). No conformed protocols (the common case here).
    fn render_with_enums(
        cls: &Class,
        fw: &str,
        registry: &ClassRegistry,
        known_enums: &[&str],
    ) -> String {
        render_full(
            cls,
            fw,
            registry,
            known_enums,
            &ProtocolRegistry::new(),
            &[],
        )
    }

    /// The full per-framework render: a class resolver (backed by `registry`), an enum
    /// resolver (aware of `known_enums`), and a protocol resolver (backed by `proto_reg`,
    /// recognising `known_protocols` — the class `implements` surface). No fallible methods.
    fn render_full(
        cls: &Class,
        fw: &str,
        registry: &ClassRegistry,
        known_enums: &[&str],
        proto_reg: &ProtocolRegistry,
        known_protocols: &[&str],
    ) -> String {
        render_full_errs(
            cls,
            fw,
            registry,
            known_enums,
            proto_reg,
            known_protocols,
            &[],
        )
    }

    /// [`render_full`] plus the class's NSError out-param selector set (`error_sels`) — the
    /// fallible-method surface (ADR-0058).
    #[allow(clippy::too_many_arguments)]
    fn render_full_errs(
        cls: &Class,
        fw: &str,
        registry: &ClassRegistry,
        known_enums: &[&str],
        proto_reg: &ProtocolRegistry,
        known_protocols: &[&str],
        error_sels: &[&str],
    ) -> String {
        let enum_reg = EnumRegistry::new();
        let known: Arc<BTreeSet<String>> =
            Arc::new(known_enums.iter().map(|s| s.to_string()).collect());
        let enum_resolver = EnumModuleResolver::new(fw, &enum_reg, known);
        let known_p: Arc<BTreeSet<String>> =
            Arc::new(known_protocols.iter().map(|s| s.to_string()).collect());
        let protocol_resolver = ProtocolModuleResolver::new(fw, proto_reg, known_p);
        let errs: HashSet<String> = error_sels.iter().map(|s| s.to_string()).collect();
        render_class(
            cls,
            &ClassModuleResolver::new(fw, registry, known_classes(cls, registry)),
            &enum_resolver,
            &protocol_resolver,
            &errs,
            // No declared-retaining slot: every bound `id<P>` slot takes ADR-0059 §6's
            // default-associate arm, which is what the corpus overwhelmingly does.
            &HashSet::new(),
            &OverrideWidenings::empty(),
            &BTreeSet::new(),
        )
    }

    /// The declared-class recognition set for a one-class render — the exact shape
    /// [`crate::emit_framework`] builds (`registry.names()` ∪ the framework's own classes),
    /// with `cls` standing in for the framework's class list. So a test that references
    /// **another** class must register it, precisely as the whole-program registry would: a
    /// `Class{name}` outside the set is not a class the emitter emits, and the k66 rule
    /// degrades it to `NSObject` (or defers the member). That is the point of the set, and
    /// keeping the test helper honest to production is what stops it hiding the bug.
    fn known_classes(cls: &Class, registry: &ClassRegistry) -> Arc<BTreeSet<String>> {
        let mut set = registry.names();
        set.insert(cls.name.clone());
        Arc::new(set)
    }

    /// Render a class with no known enums (the pre-enum-alias-typing surface).
    fn render(cls: &Class, fw: &str, registry: &ClassRegistry) -> String {
        render_with_enums(cls, fw, registry, &[])
    }

    /// The common case: render in framework `fw` with an empty registry.
    fn render_in(cls: &Class, fw: &str) -> String {
        render(cls, fw, &ClassRegistry::new())
    }

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

    fn method(
        selector: &str,
        class_method: bool,
        init_method: bool,
        params: Vec<Param>,
        return_type: TypeRef,
        returns_retained: Option<bool>,
    ) -> Method {
        Method {
            selector: selector.into(),
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
            returns_retained,
            satisfies_protocol: None,
            objc_exposed: true,
            swift_fn: None,
        }
    }

    /// A bare class carrying `methods` — for the fixtures that only need a method surface.
    fn class(name: &str, superclass: &str, methods: Vec<Method>) -> Class {
        Class {
            name: name.into(),
            superclass: superclass.into(),
            protocols: vec![],
            properties: vec![],
            methods,
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    /// A small hand-built fixture exercising the k18 surface: a static factory
    /// (+0, non-null instancetype), an `init` (+1, nullable instancetype), a scalar
    /// getter, a scalar-param + nullable-object return, and a void setter.
    fn widget() -> Class {
        Class {
            name: "Widget".into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                // + widgetWithName:(id)  -> instancetype (non-null; +0 convenience ctor)
                method(
                    "widgetWithName:",
                    true,
                    false,
                    vec![param(
                        "name",
                        ty(TypeRefKind::Id {
                            protocols: Vec::new(),
                        }),
                    )],
                    ty(TypeRefKind::Instancetype),
                    None,
                ),
                // - initWithName:(id)  -> instancetype (nullable; +1 owned)
                method(
                    "initWithName:",
                    false,
                    true,
                    vec![param(
                        "name",
                        ty(TypeRefKind::Id {
                            protocols: Vec::new(),
                        }),
                    )],
                    nullable(TypeRefKind::Instancetype),
                    Some(true),
                ),
                // - length  -> NSUInteger
                method(
                    "length",
                    false,
                    false,
                    vec![],
                    ty(TypeRefKind::Primitive {
                        name: "NSUInteger".into(),
                    }),
                    None,
                ),
                // - objectAtIndex:(NSUInteger)  -> id (nullable; +0)
                method(
                    "objectAtIndex:",
                    false,
                    false,
                    vec![param(
                        "index",
                        ty(TypeRefKind::Primitive {
                            name: "NSUInteger".into(),
                        }),
                    )],
                    nullable(TypeRefKind::Id {
                        protocols: Vec::new(),
                    }),
                    None,
                ),
                // - setLength:(NSUInteger)  -> void
                method(
                    "setLength:",
                    false,
                    false,
                    vec![param(
                        "length",
                        ty(TypeRefKind::Primitive {
                            name: "NSUInteger".into(),
                        }),
                    )],
                    TypeRef::void(),
                    None,
                ),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    /// The full emitted-`.ts` golden for the fixture — a regression lock over the
    /// exact idiom the behavioural tests below assert piecewise.
    const WIDGET_GOLDEN: &str = r#"// Generated by apianyware emit-typescript — DO NOT EDIT.
// Class: Widget (TestKit)
//
// Runtime seam (Step 3 provides these from '@apianyware/runtime'; ADR-0055/0057):
//   NSObject — branded-handle root class; its internal ctor wraps a handle and hosts
//     [Symbol.dispose]. Emitted subclasses inherit both and declare neither.
//   __unwrap(obj) — obj's native handle (0n for null; throws on a disposed handle).
//   __wrapRetained(Cls, id) / __wrapOwned(Cls, id) — the +0 / +1 uniqued branded
//     wrapper (null when id is 0n; retain folds into the dispatch entry).
//   __class(name) — the Class handle; __sel(sel) — the interned SEL handle.
//   __registerClass(name, cls) — registers this class so a Class RETURN resolves back
//     to it; __classArg(cls) / __classCtor(id) — the Class value crossing, in / out;
//     __selName(sel) — a SEL handle back to its selector-name string.
//   __dispatch.aw_ts_msg_<codes>(recv, sel, …) — the addon's per-signature entry.
//   __init(obj) — the universal `-init` primitive for a class whose real ancestry
//     never redeclares it (k122): the same id -> id dispatch shape a real init() body
//     calls, reused as one shared runtime primitive rather than a per-class copy.

import {
  NSObject,
  OBJ,
  RAW,
  RET_OBJ,
  RET_RAW,
  __class,
  __dispatch,
  __init,
  __registerClass,
  __sel,
  __unwrap,
  __wrapOwned,
  __wrapRetained,
} from '@apianyware/runtime';
import type {
  OverridableMethod,
} from '@apianyware/runtime';

export class Widget extends NSObject {
  static { __registerClass('Widget', Widget); }

  static readonly __overridable: readonly OverridableMethod[] = [
    { name: 'initWithName_', selector: 'initWithName:', encoding: '@@:@', superEntry: 'aw_ts_super_P_P_o', args: [OBJ], ret: RET_OBJ('owned') },
    { name: 'length', selector: 'length', encoding: 'Q@:', superEntry: 'aw_ts_super_0_Q', args: [], ret: RET_RAW },
    { name: 'objectAtIndex_', selector: 'objectAtIndex:', encoding: '@@:Q', superEntry: 'aw_ts_super_Q_P', args: [RAW], ret: RET_OBJ() },
    { name: 'setLength_', selector: 'setLength:', encoding: 'v@:Q', superEntry: 'aw_ts_super_Q_v', args: [RAW], ret: RET_RAW },
  ];

  static readonly __cls: bigint = __class('Widget');

  static widgetWithName_(name: NSObject): Widget {
    const __ret = __dispatch.aw_ts_msg_P_P(Widget.__cls, __sel('widgetWithName:'), __unwrap(name));
    return __wrapRetained(Widget, __ret)!;
  }

  initWithName_(name: NSObject): this | null {
    const __ret = __dispatch.aw_ts_msg_P_P_o(__unwrap(this), __sel('initWithName:'), __unwrap(name));
    return __wrapOwned<this>(__ret);
  }

  length(): number {
    return __dispatch.aw_ts_msg_0_Q(__unwrap(this), __sel('length'));
  }

  objectAtIndex_(index: number): NSObject | null {
    const __ret = __dispatch.aw_ts_msg_Q_P(__unwrap(this), __sel('objectAtIndex:'), index);
    return __wrapRetained(__ret);
  }

  setLength_(length: number): void {
    __dispatch.aw_ts_msg_Q_v(__unwrap(this), __sel('setLength:'), length);
  }

  init(): this {
    return __init(this);
  }
}
"#;

    #[test]
    fn widget_matches_full_golden() {
        assert_eq!(render_in(&widget(), "TestKit"), WIDGET_GOLDEN);
    }

    #[test]
    fn emits_real_es6_class_with_extends_and_per_class_cls() {
        let out = render_in(&widget(), "TestKit");
        assert!(
            out.contains("export class Widget extends NSObject {"),
            "real ES6 class with extends chain:\n{out}"
        );
        // The per-class Class handle for static-factory receivers.
        assert!(
            out.contains("static readonly __cls: bigint = __class('Widget');"),
            "per-class __cls:\n{out}"
        );
        // No re-declared handle/constructor — inherited from the runtime NSObject.
        assert!(
            !out.contains("constructor"),
            "must not re-declare the inherited constructor:\n{out}"
        );
    }

    /// The `hello-window` shape: `-[NSWindow initWithContentRect:styleMask:backing:defer:]` and
    /// `-frame`. The densest POD population in the corpus, and the Step-7 blocker
    /// `pod-struct-types-k73` closes.
    fn window() -> Class {
        Class {
            name: "Window".into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                method(
                    "initWithContentRect:defer:",
                    false,
                    true,
                    vec![
                        param(
                            "contentRect",
                            ty(TypeRefKind::Struct {
                                name: "NSRect".into(),
                            }),
                        ),
                        param(
                            "flag",
                            ty(TypeRefKind::Primitive {
                                name: "bool".into(),
                            }),
                        ),
                    ],
                    ty(TypeRefKind::Instancetype),
                    Some(true),
                ),
                method(
                    "frame",
                    false,
                    false,
                    vec![],
                    ty(TypeRefKind::Struct {
                        name: "CGRect".into(),
                    }),
                    None,
                ),
                method(
                    "setFrameOrigin:",
                    false,
                    false,
                    vec![param(
                        "point",
                        ty(TypeRefKind::Struct {
                            name: "NSPoint".into(),
                        }),
                    )],
                    TypeRef::void(),
                    None,
                ),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    #[test]
    fn a_geometry_carrying_class_type_imports_its_pod_types_from_the_runtime() {
        // The k73 defect: before this, the body rendered `contentRect: CGRect` and imported
        // nothing — every geometry-carrying method in the corpus referenced an undefined type.
        // The POD types are runtime-owned pure types, so they ride the **type-only** path (like
        // `Result<T>`), coalescing with the seam block's module into one `import type`.
        let out = render_in(&window(), "TestKit");
        // `OverridableMethod` rides the same type-only import block: `inbound-struct-arg-
        // surface-k123` widened struct PARAMS in, so `window()`'s own `initWithContentRect_
        // defer_`/`setFrameOrigin_` (both struct-param methods) now catalogue as overridable
        // too — additive to this test's original POD-import assertion, not a regression.
        assert!(
            out.contains(
                "import type {\n  CGPoint,\n  CGRect,\n  OverridableMethod,\n} from '@apianyware/runtime';"
            ),
            "the referenced PODs import type-only from the runtime, canonicalised \
             (NSRect→CGRect, NSPoint→CGPoint) and deduped:\n{out}"
        );
        // And they are what the signatures actually name — the import and the token are one
        // string (`pod_type_name`), so this pair cannot drift.
        assert!(
            out.contains("initWithContentRect_defer_(contentRect: CGRect, flag: boolean)"),
            "a rect param renders as the POD it imports:\n{out}"
        );
        assert!(out.contains("frame(): CGRect {"), "a rect return:\n{out}");
        assert!(
            out.contains("setFrameOrigin_(point: CGPoint): void {"),
            "a point param:\n{out}"
        );
        // A POD crosses by value — no wrap, no unwrap, no disposal (ADR-0055 §5): the arg goes
        // straight to the dispatch entry and the return comes straight back.
        assert!(
            out.contains("return __dispatch.aw_ts_msg_0_R(__unwrap(this), __sel('frame'));"),
            "a POD return is returned raw — not wrapped:\n{out}"
        );
        assert!(
            !out.contains("__wrapRetained(CGRect") && !out.contains("__wrapOwned(CGRect"),
            "a POD is never a branded handle:\n{out}"
        );
    }

    #[test]
    fn a_geometry_free_class_imports_no_pod_types() {
        // Empty in, empty out — the arm is inert for the rest of the corpus, which is why the
        // existing goldens are untouched by it. `widget()` still gets a type-only import for
        // `OverridableMethod` (ADR-0059 §4, unrelated to PODs — it has overridable instance
        // methods), so the assertion narrows to the POD names rather than "no import type at all".
        let out = render_in(&widget(), "TestKit");
        assert!(
            !out.contains("CGRect") && !out.contains("CGPoint") && !out.contains("NSRange"),
            "no POD geometry type for a geometry-free class:\n{out}"
        );
    }

    #[test]
    fn imports_only_the_seam_symbols_it_uses() {
        let out = render_in(&widget(), "TestKit");
        assert!(
            out.contains(&format!("}} from '{RUNTIME_MODULE}';")),
            "imports from the runtime module:\n{out}"
        );
        for sym in [
            "NSObject",
            "__class",
            "__dispatch",
            "__sel",
            "__unwrap",
            "__wrapOwned",
            "__wrapRetained",
        ] {
            assert!(out.contains(sym), "imports {sym}:\n{out}");
        }
    }

    #[test]
    fn static_factory_uses_class_receiver_plus0_wrap_and_concrete_instancetype() {
        let out = render_in(&widget(), "TestKit");
        // Static method: receiver is the Class handle; instancetype → concrete Widget;
        // non-null return asserts the +0 wrap with `!`.
        assert!(
            out.contains("static widgetWithName_(name: NSObject): Widget {"),
            "static factory signature, instancetype → concrete class:\n{out}"
        );
        assert!(
            out.contains(
                "__dispatch.aw_ts_msg_P_P(Widget.__cls, __sel('widgetWithName:'), __unwrap(name))"
            ),
            "coercion-free dispatch: Class receiver, __sel, unwrapped object arg:\n{out}"
        );
        assert!(
            out.contains("return __wrapRetained(Widget, __ret)!;"),
            "+0 → __wrapRetained; non-null → `!`:\n{out}"
        );
    }

    #[test]
    fn init_is_a_normal_instance_method_with_plus1_wrap() {
        let out = render_in(&widget(), "TestKit");
        // init is a normal instance method returning the (nullable) polymorphic `this`
        // (override-signature-mismatch-k100); +1 → owned, dynamically resolved.
        assert!(
            out.contains("initWithName_(name: NSObject): this | null {"),
            "faithful init as a normal instance method, nullable instancetype → this:\n{out}"
        );
        assert!(
            out.contains(
                "__dispatch.aw_ts_msg_P_P_o(__unwrap(this), __sel('initWithName:'), __unwrap(name))"
            ),
            "instance receiver is __unwrap(this); +1 routes to the non-folding `_o` entry:\n{out}"
        );
        assert!(
            out.contains("return __wrapOwned<this>(__ret);"),
            "+1 → __wrapOwned, class-less arm with an explicit `this` type argument; nullable → no `!`:\n{out}"
        );
    }

    #[test]
    fn scalar_method_is_a_direct_coercion_free_return() {
        let out = render_in(&widget(), "TestKit");
        assert!(
            out.contains("length(): number {"),
            "scalar return typed number:\n{out}"
        );
        // No wrap, no __ret — a direct scalar return.
        assert!(
            out.contains("return __dispatch.aw_ts_msg_0_Q(__unwrap(this), __sel('length'));"),
            "direct scalar dispatch, 0-arg entry:\n{out}"
        );
    }

    #[test]
    fn scalar_param_passes_through_and_nullable_object_return_wraps() {
        let out = render_in(&widget(), "TestKit");
        assert!(
            out.contains("objectAtIndex_(index: number): NSObject | null {"),
            "scalar param + nullable object (id → NSObject) return:\n{out}"
        );
        // The scalar param crosses directly (not unwrapped); id return → NSObject wrap.
        assert!(
            out.contains(
                "__dispatch.aw_ts_msg_Q_P(__unwrap(this), __sel('objectAtIndex:'), index)"
            ),
            "scalar arg passes through uncoerced:\n{out}"
        );
        // The k88 arm: the IR names NO class for an `id`, so the body takes the wrap primitive's
        // **class-less** arm and the runtime resolves the object's real ObjC class. It used to pass
        // `NSObject` — minting a root object with none of the real class's methods.
        assert!(
            out.contains("return __wrapRetained(__ret);"),
            "a class-less id return takes the class-less wrap arm:\n{out}"
        );
        assert!(
            !out.contains("__wrapRetained(NSObject, __ret)"),
            "an `id` must NOT be wrapped as the bare root — that is the k88 defect:\n{out}"
        );
    }

    #[test]
    fn void_method_has_no_return_and_no_wrap() {
        let out = render_in(&widget(), "TestKit");
        assert!(
            out.contains("setLength_(length: number): void {"),
            "void return:\n{out}"
        );
        assert!(
            out.contains(
                "    __dispatch.aw_ts_msg_Q_v(__unwrap(this), __sel('setLength:'), length);"
            ),
            "void body is a bare dispatch statement, no return/wrap:\n{out}"
        );
    }

    #[test]
    fn method_retain_axis_is_the_single_fold_gate() {
        // THE predicate of the mirror discipline (k70): emit_body's wrap primitive,
        // the entry-name suffix, and the dispatch-table collection all read this one
        // decision. It gates on the wrap boundary (`is_object_type`), never on the
        // ABI shape being `Ptr`.
        let mapper = TsFfiTypeMapper::new();
        let m =
            |ret: TypeRef, retained: Option<bool>| method("m", false, false, vec![], ret, retained);
        // A +0 object return folds (bare entry, `__wrapRetained`).
        assert_eq!(
            method_retain_axis(
                &m(
                    ty(TypeRefKind::Id {
                        protocols: Vec::new()
                    }),
                    None
                ),
                &mapper
            ),
            Some(RetainAxis::FoldRetain)
        );
        // A +1-convention object return rides the non-folding `_o` sibling.
        assert_eq!(
            method_retain_axis(&m(ty(TypeRefKind::Instancetype), Some(true)), &mapper),
            Some(RetainAxis::Owned)
        );
        // A pointer-shaped return that is NOT an object rides the non-folding,
        // non-wrapping `_n` sibling: `objc_retain` on a SEL is UB, a retained class
        // leaks.
        assert_eq!(
            method_retain_axis(&m(ty(TypeRefKind::Selector), None), &mapper),
            Some(RetainAxis::NoWrap)
        );
        assert_eq!(
            method_retain_axis(&m(ty(TypeRefKind::ClassRef), None), &mapper),
            Some(RetainAxis::NoWrap)
        );
        // A `returns_retained` fact on a non-object pointer changes nothing — the
        // axis reads the wrap boundary first (nothing wraps a SEL, so nothing owns it).
        assert_eq!(
            method_retain_axis(&m(ty(TypeRefKind::Selector), Some(true)), &mapper),
            Some(RetainAxis::NoWrap)
        );
        // Scalars, void and geometry structs carry no retain convention at all.
        for ret in [
            ty(TypeRefKind::Primitive {
                name: "NSUInteger".into(),
            }),
            TypeRef::void(),
            ty(TypeRefKind::Struct {
                name: "CGRect".into(),
            }),
        ] {
            assert_eq!(method_retain_axis(&m(ret, None), &mapper), None);
        }
    }

    /// The k70/k72 fixture: SEL- and Class-valued methods in **both** directions —
    /// pointer-shaped at the ABI (so they share the object entries and route to the `_n`
    /// no-wrap siblings, k70), but nothing like an object at the TS surface, so each end
    /// converts (k72). `setAction:` is the shape that made the defect concrete: a JS
    /// `string` passed raw reached `napiReadHandle` as `0` — a nil `SEL`.
    fn control() -> Class {
        Class {
            name: "Control".into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                // - action -> SEL  (the `-[NSControl action]` shape)
                method(
                    "action",
                    false,
                    false,
                    vec![],
                    ty(TypeRefKind::Selector),
                    None,
                ),
                // - setAction:(SEL) -> void  (the `-[NSControl setAction:]` shape)
                method(
                    "setAction:",
                    false,
                    false,
                    vec![param("action", ty(TypeRefKind::Selector))],
                    TypeRef::void(),
                    None,
                ),
                // + classForName:(id) -> Class  (the `migrationManagerClass` shape)
                method(
                    "classForName:",
                    true,
                    false,
                    vec![param(
                        "name",
                        ty(TypeRefKind::Id {
                            protocols: Vec::new(),
                        }),
                    )],
                    ty(TypeRefKind::ClassRef),
                    None,
                ),
                // - setCellClass:(Class) -> void  (the `+[NSControl setCellClass:]` shape)
                method(
                    "setCellClass:",
                    false,
                    false,
                    vec![param("factoryId", ty(TypeRefKind::ClassRef))],
                    TypeRef::void(),
                    None,
                ),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    #[test]
    fn sel_and_class_values_convert_at_both_ends_over_the_no_wrap_entry() {
        let out = render_in(&control(), "TestKit");

        // ── Returns: the raw `_n` handle converts back to the declared type (k72). ──
        // The `!` is the same non-null assertion every object return carries: both helpers
        // yield `T | null` for the nil handle, and the IR declares these returns non-null.
        assert!(
            out.contains(
                "return __selName(__dispatch.aw_ts_msg_0_P_n(__unwrap(this), __sel('action')))!;"
            ),
            "a SEL return converts back to its selector-name string:\n{out}"
        );
        assert!(
            out.contains(
                "return __classCtor(__dispatch.aw_ts_msg_P_P_n(Control.__cls, __sel('classForName:'), __unwrap(name)))!;"
            ),
            "a Class return resolves to the bound constructor:\n{out}"
        );

        // ── Params: the JS value converts INTO a handle (the setAction: defect). ──
        assert!(
            out.contains(
                "__dispatch.aw_ts_msg_P_v(__unwrap(this), __sel('setAction:'), __sel(action));"
            ),
            "a SEL param interns its name — never crosses as a raw JS string:\n{out}"
        );
        assert!(
            out.contains(
                "__dispatch.aw_ts_msg_P_v(__unwrap(this), __sel('setCellClass:'), __classArg(factoryId));"
            ),
            "a Class param resolves its constructor to a handle:\n{out}"
        );

        // ── The entry names are UNTOUCHED (k70's mirror invariant). ──
        // Both kinds are `AbiType::Ptr`, so conversion is purely `.ts`-side: the `_n`
        // no-wrap siblings still carry them, and the native table needs no change.
        assert!(
            out.contains("aw_ts_msg_0_P_n(") && out.contains("aw_ts_msg_P_P_n("),
            "SEL/Class returns still route to the non-folding, non-wrapping `_n` entry:\n{out}"
        );

        // Neither kind is an OBJECT, so nothing retains or wraps (ADR-0057 §4: `objc_retain`
        // on a SEL is UB, a retained Class leaks) — the wrap helpers stay unimported.
        assert!(
            !out.contains("  __wrapRetained,") && !out.contains("  __wrapOwned,"),
            "no wrap helper imported for `_n` returns:\n{out}"
        );
        assert!(
            !out.contains("return __wrap"),
            "no wrap call for `_n` returns:\n{out}"
        );

        // seam_symbols renders from the same `PtrValue` decision emit_body does, so every
        // helper the bodies call is imported — the property that keeps them from drifting.
        for symbol in [
            "  __classArg,",
            "  __classCtor,",
            "  __sel,",
            "  __selName,",
        ] {
            assert!(
                out.contains(symbol),
                "the crossing helper `{symbol}` the body calls must be imported:\n{out}"
            );
        }
    }

    /// The `-[NSApplication setDelegate:]` / `-delegate` pair — the shape the whole
    /// `inbound-value-surface-k74` node exists for. `id<AppDelegate>` in both directions, plus an
    /// `id<Marker>` whose protocol the emitter cannot emit (so it must degrade) and an `id<AppView>`
    /// naming a protocol a **class** also declares (the k90 collapse — binds, re-encoded).
    fn app() -> Class {
        Class {
            name: "App".into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                // - setDelegate:(id<AppDelegate>) -> void   [the param arm]
                method(
                    "setDelegate:",
                    false,
                    false,
                    vec![param("delegate", ty(qualified_id(&["AppDelegate"])))],
                    TypeRef::void(),
                    None,
                ),
                // - delegate -> id<AppDelegate> (nullable, +0)   [the return arm]
                method(
                    "delegate",
                    false,
                    false,
                    vec![],
                    nullable(qualified_id(&["AppDelegate"])),
                    None,
                ),
                // - setPair:(id<AppDelegate,AppSource>) -> void  [the intersection]
                method(
                    "setPair:",
                    false,
                    false,
                    vec![param(
                        "pair",
                        ty(qualified_id(&["AppDelegate", "AppSource"])),
                    )],
                    TypeRef::void(),
                    None,
                ),
                // - setMarker:(id<Marker>) -> void  [degrades: no emittable interface]
                method(
                    "setMarker:",
                    false,
                    false,
                    vec![param("marker", ty(qualified_id(&["Marker"])))],
                    TypeRef::void(),
                    None,
                ),
                // - setView:(id<AppView>) -> void  [binds as AppViewProtocol: also a class — k90]
                method(
                    "setView:",
                    false,
                    false,
                    vec![param("view", ty(qualified_id(&["AppView"])))],
                    TypeRef::void(),
                    None,
                ),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    fn qualified_id(protocols: &[&str]) -> TypeRefKind {
        TypeRefKind::Id {
            protocols: protocols.iter().map(|s| s.to_string()).collect(),
        }
    }

    /// Render `app()` with `AppDelegate`/`AppSource`/`AppView` recognised as emittable protocols and
    /// `App`/`AppView` as declared classes — the whole-program shape the orchestrator builds, in
    /// which `AppView` is the k90 two-namespace collision.
    fn render_app() -> String {
        let mut registry = ClassRegistry::new();
        registry.insert("AppView", "testkit");
        render_full(
            &app(),
            "TestKit",
            &registry,
            &[],
            &ProtocolRegistry::new(),
            &["AppDelegate", "AppSource", "AppView"],
        )
    }

    #[test]
    fn a_protocol_qualified_param_types_as_the_bare_interface() {
        // ADR-0055 §4b, the contravariant arm: the widest thing that satisfies the API. Typing it
        // `P` (not `P & NSObject`) is what lets a plain JS object literal be installed as a delegate
        // — the whole point of binding, and the reason `emitted-delegate-spec-k84` becomes possible.
        let out = render_app();
        assert!(
            out.contains("setDelegate_(delegate: AppDelegate): void {"),
            "the delegate slot types by its interface, not NSObject:\n{out}"
        );
        // `id<P1,P2>` is the intersection — both interfaces, both satisfied.
        assert!(
            out.contains("setPair_(pair: AppDelegate & AppSource): void {"),
            "a multi-qualifier types as the intersection:\n{out}"
        );
        // A bound slot no longer `__unwrap`s: it bridges (`emitted-delegate-spec-k84`). `__protocolArg`
        // discriminates a wrapped ObjC object (unwrap) from a plain JS object (mint a forwarder from
        // `SPEC_AppDelegate`), so both things the type admits actually work. The ABI is untouched —
        // what crosses is still one handle — but the value that produces it is no longer a lie.
        assert!(
            out.contains("__dispatch.aw_ts_msg_P_v(__unwrap(this), __sel('setDelegate:'), __protocolArg(__unwrap(this), 'setDelegate:#0', delegate, SPEC_AppDelegate, true));"),
            "a bound param bridges through its spec, owned by the receiver, keyed by the slot:\n{out}"
        );
        // `true` is ADR-0059 §6's default-associate arm: this fixture declares no ownership, and an
        // absent qualifier associates (under-holding a non-retaining slot dangles; over-holding a
        // retaining one merely over-retains).

        // A **multi-protocol** slot has no single forwarder class to synthesize — a forwarder conforms
        // to ONE ObjC `Protocol` — so it does not bridge, and says so in the pass log
        // (`slot_report.multi_protocol`) rather than guessing. Zero such params in the real corpus.
        assert!(
            out.contains(
                "__dispatch.aw_ts_msg_P_v(__unwrap(this), __sel('setPair:'), __unwrap(pair));"
            ),
            "a multi-qualifier slot defers the bridge rather than picking a protocol:\n{out}"
        );
    }

    #[test]
    fn a_protocol_qualified_return_intersects_the_object_root_and_carries_it_to_the_wrap() {
        // THE VARIANCE FACT (ADR-0055 §4b). A *yield* position promises what the value IS: after
        // `dynamic-class-wrap-k88` the wrapper is minted into the object's real ObjC class, so it
        // carries P's members AND the root's. Typing it bare `P` would be NARROWER than the value —
        // and would stop `arr.addObject_(app.delegate())` compiling, an `addObject:(id)` slot being
        // rendered `NSObject`.
        let out = render_app();
        assert!(
            out.contains("delegate(): AppDelegate & NSObject | null {"),
            "a bound return intersects the object root:\n{out}"
        );
        // The wrap takes the class-less arm (the IR names no class for an `id`) and carries the
        // declared conformance as its type argument — rendered from the SAME `id_surface_type` the
        // signature is, so the two are one string by construction.
        assert!(
            out.contains("return __wrapRetained<AppDelegate & NSObject>(__ret);"),
            "the class-less wrap carries the declared conformance:\n{out}"
        );
    }

    #[test]
    fn a_bound_protocol_imports_type_only_and_the_degraded_one_imports_nothing() {
        let out = render_app();
        // Interfaces are erased, so they ride the type-only path — no runtime edge, no barrel cycle.
        // `AppView` — the k90 class-name collision — binds too, but under its re-encoded identifier
        // (`protocol_type_name`): the same one its own declaration would use, so the import can
        // never dangle.
        assert!(
            out.contains(
                "import type {\n  AppDelegate,\n  AppSource,\n  AppViewProtocol,\n} from '@apianyware/testkit';"
            ),
            "bound protocols import type-only, the colliding one under its Protocol suffix:\n{out}"
        );
        // `Marker` alone degrades (no emittable interface) and imports nothing. Neither the bare
        // `AppView` identifier nor a `SPEC_AppView` for Marker ever appears.
        assert!(
            !out.contains("  Marker,\n") && !out.contains("  AppView,\n"),
            "the degraded qualifier contributes no import, and the renamed one never imports bare:\n{out}"
        );
        // `Marker` keeps the prior degrade-to-`NSObject` surface (no emittable interface at all —
        // degrading is always safe); `AppView` now types and bridges through its renamed interface.
        assert!(
            out.contains("setMarker_(marker: NSObject): void {"),
            "an unemittable qualifier keeps the NSObject surface:\n{out}"
        );
        assert!(
            out.contains("setView_(view: AppViewProtocol): void {"),
            "a class-name-colliding qualifier binds under its renamed interface, not NSObject:\n{out}"
        );
        assert!(
            out.contains(
                "__protocolArg(__unwrap(this), 'setView:#0', view, SPEC_AppView, true)"
            ),
            "it bridges through its spec — keyed by the RAW protocol name, unaffected by the type rename:\n{out}"
        );
    }

    #[test]
    fn a_fallible_sel_or_class_primary_defers_rather_than_lying_in_a_result() {
        // A `SEL`/`Class` primary is pointer-shaped, so the `…_e` error entry would happily
        // carry it — but the `Result<T>` helpers only wrap an object or pass a scalar through,
        // so `__resultScalar` would seat the RAW handle in the ok-branch under a declared
        // `string`/`typeof NSObject`: exactly the lie this leaf removes, reintroduced through
        // the ADR-0058 channel. The method filter defers it (corpus population today: zero).
        use crate::method_filter::is_supported_method_ctx;
        let mapper = TsFfiTypeMapper::new();
        let errs: HashSet<String> = ["classForName:error:".to_string()].into_iter().collect();
        let fallible_class = method(
            "classForName:error:",
            true,
            false,
            vec![
                param(
                    "name",
                    ty(TypeRefKind::Id {
                        protocols: Vec::new(),
                    }),
                ),
                param("error", ty(TypeRefKind::Pointer)),
            ],
            ty(TypeRefKind::ClassRef),
            None,
        );
        assert!(
            !is_supported_method_ctx(&fallible_class, &mapper, &errs),
            "a fallible Class primary must defer, not emit a Result<typeof NSObject> over a raw handle"
        );
        // Same for a SEL primary — the deferral is a property of the kind, not of Class alone.
        let mut fallible_sel = fallible_class.clone();
        fallible_sel.selector = "actionForName:error:".into();
        fallible_sel.return_type = ty(TypeRefKind::Selector);
        let sel_errs: HashSet<String> = ["actionForName:error:".to_string()].into_iter().collect();
        assert!(!is_supported_method_ctx(&fallible_sel, &mapper, &sel_errs));

        // The control: it is only the `Result` **seating** that cannot carry the handle — a
        // Class return with no error channel binds and converts normally (the `control()`
        // fixture's `classForName:` is exactly that, and it emits).
        let plain_class = method(
            "classForName:",
            true,
            false,
            vec![param(
                "name",
                ty(TypeRefKind::Id {
                    protocols: Vec::new(),
                }),
            )],
            ty(TypeRefKind::ClassRef),
            None,
        );
        assert!(is_supported_method_ctx(
            &plain_class,
            &mapper,
            &HashSet::new()
        ));
    }

    /// A subclass whose surface pulls in a same-framework superclass (`Widget`) and
    /// cross-framework param/return types (`NSColor`, `NSString`) — the multi-module
    /// import case the `NSObject`-only `Widget` fixture cannot exercise. Notably it does
    /// **not** reference `NSObject`, so the resolver-rerouted emitter must not import it.
    fn gadget() -> Class {
        Class {
            name: "Gadget".into(),
            superclass: "Widget".into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                // + gadgetWithColor:(NSColor) -> instancetype  (cross-fw object param)
                method(
                    "gadgetWithColor:",
                    true,
                    false,
                    vec![param(
                        "color",
                        ty(TypeRefKind::Class {
                            name: "NSColor".into(),
                            framework: None,
                            params: vec![],
                        }),
                    )],
                    ty(TypeRefKind::Instancetype),
                    None,
                ),
                // - title -> NSString | null  (cross-fw object return)
                method(
                    "title",
                    false,
                    false,
                    vec![],
                    nullable(TypeRefKind::Class {
                        name: "NSString".into(),
                        framework: None,
                        params: vec![],
                    }),
                    None,
                ),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    #[test]
    fn cross_class_imports_route_to_owning_modules() {
        // Populated registry (the CLI pre-pass shape): each referenced class imports
        // from its owning module, one `import { … } from '<mod>'` block per module,
        // sorted by specifier.
        let mut reg = ClassRegistry::new();
        reg.insert("NSColor", "appkit");
        reg.insert("NSString", "foundation");
        let out = render(&gadget(), "TestKit", &reg);
        assert!(
            out.contains("import {\n  NSColor,\n} from '@apianyware/appkit';"),
            "cross-fw param → its owning module:\n{out}"
        );
        assert!(
            out.contains("import {\n  NSString,\n} from '@apianyware/foundation';"),
            "cross-fw return → its owning module:\n{out}"
        );
        assert!(
            out.contains("import {\n  Widget,\n} from '@apianyware/testkit';"),
            "same-fw superclass → the current framework's package:\n{out}"
        );
        assert!(
            out.contains("export class Gadget extends Widget {"),
            "extends the same-framework superclass:\n{out}"
        );
        // The runtime block carries only the seam helpers the bodies use — and NOT
        // NSObject, which this class never references (the fixed unconditional import).
        assert!(
            out.contains("} from '@apianyware/runtime';"),
            "a runtime seam block for the dispatch helpers:\n{out}"
        );
        assert!(
            !out.contains("  NSObject,\n"),
            "NSObject must not be imported when unreferenced:\n{out}"
        );
    }

    #[test]
    fn an_undeclared_class_ref_degrades_to_the_root_instead_of_dangling() {
        // THE k66 DEFECT, at the emit level. Before this rule, an empty registry routed
        // `NSColor`/`NSString` — classes the IR declares nowhere — through the resolver's
        // same-framework fallback and emitted `import { NSColor } from '@apianyware/testkit'`:
        // a value import of a symbol that module does not export, i.e. a TS compile error, and
        // a body that wrapped the handle as a class nothing defines. The corpus carried 98 such
        // imports across 92 files.
        //
        // Now an undeclared name is not an object type this target binds, so the whole surface —
        // the declared param/return, the wrap primitive, and the import — degrades to the runtime
        // root in lockstep. The *superclass* is untouched: an unresolvable superclass is
        // synthesized as a bare node by the orchestrator (`build_class_graph`) and really is
        // exported from the barrel, so `Widget` still imports from `@apianyware/testkit`.
        let out = render_in(&gadget(), "TestKit");
        assert!(
            !out.contains("NSColor") && !out.contains("NSString"),
            "an undeclared class must not appear anywhere in the surface:\n{out}"
        );
        assert!(
            out.contains("import {\n  Widget,\n} from '@apianyware/testkit';"),
            "only the (bare-node-backed) superclass imports from the framework barrel:\n{out}"
        );
        assert!(
            out.contains("static gadgetWithColor_(color: NSObject): Gadget {"),
            "the undeclared param type degrades to the root:\n{out}"
        );
        assert!(
            out.contains("title(): NSObject | null {")
                && out.contains("return __wrapRetained(NSObject, __ret);"),
            "the declared return, the wrap class, and the import degrade together:\n{out}"
        );
        assert!(
            out.contains("export class Gadget extends Widget {"),
            "extends the same-framework superclass:\n{out}"
        );
    }

    #[test]
    fn a_declared_class_ref_binds_and_routes_to_its_owning_module() {
        // The other arm: once the whole-program registry knows the classes (the generate-CLI
        // shape), the very same fixture binds them by name and imports each from its owner. So
        // the degrade above is *absence of a declaration*, never a blanket downgrade.
        let mut reg = ClassRegistry::new();
        reg.insert("NSColor", "appkit");
        reg.insert("NSString", "foundation");
        reg.insert("Widget", "testkit");
        let out = render(&gadget(), "TestKit", &reg);
        assert!(
            out.contains("import {\n  NSColor,\n} from '@apianyware/appkit';")
                && out.contains("import {\n  NSString,\n} from '@apianyware/foundation';"),
            "each declared ref imports from its owning module:\n{out}"
        );
        assert!(
            out.contains("static gadgetWithColor_(color: NSColor): Gadget {")
                && out.contains("title(): NSString | null {")
                && out.contains("return __wrapRetained(NSString, __ret);"),
            "signature, wrap class and import all name the bound class:\n{out}"
        );
    }

    #[test]
    fn a_swift_nominal_return_defers_the_whole_method() {
        // `NEPacketTunnelFlow.readPackets()` in the committed corpus: a `.swiftinterface`-sourced
        // decl whose `Class{Tuple}` return is a Swift **tuple**, not an object. Degrading it to
        // `NSObject` would be a lie the runtime pays for — `objc_retain` on a tuple is UB — so
        // the method defers entirely, and nothing (no call site, no import, no `.d.ts` line)
        // mentions `Tuple`. Contrast the ObjC-sourced `CLLocation` above, which degrades.
        let mut swift_tuple = method(
            "readPackets",
            false,
            false,
            vec![],
            ty(TypeRefKind::Class {
                name: "Tuple".into(),
                framework: None,
                params: vec![],
            }),
            None,
        );
        swift_tuple.source = Some(DeclarationSource::SwiftInterface);
        // An ObjC-sourced sibling with the *same* undeclared return type still emits (degraded) —
        // the two arms differ only by the extractor that produced the decl.
        let mut objc_unbound = method(
            "location",
            false,
            false,
            vec![],
            ty(TypeRefKind::Class {
                name: "CLLocation".into(),
                framework: None,
                params: vec![],
            }),
            None,
        );
        objc_unbound.source = Some(DeclarationSource::ObjcHeader);
        let cls = class("TKFlow", "NSObject", vec![swift_tuple, objc_unbound]);
        let out = render_in(&cls, "TestKit");
        assert!(
            !out.contains("Tuple") && !out.contains("readPackets"),
            "a Swift nominal type defers the whole method — no call site, no import:\n{out}"
        );
        assert!(
            out.contains("location(): NSObject {"),
            "the ObjC-sourced sibling still emits, degraded:\n{out}"
        );
    }

    /// An `NS_ENUM` alias — a genuine enum typedef the mapper can prove (in the known set).
    fn enum_alias(name: &str) -> TypeRef {
        ty(TypeRefKind::Alias {
            name: name.into(),
            framework: None,
            underlying_primitive: Some("int64".into()),
        })
    }

    fn gauge() -> Class {
        Class {
            name: "Gauge".into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                // An enum-typed param (crosses as a number — no unwrap, no cast).
                method(
                    "setAlignment:",
                    false,
                    false,
                    vec![param("alignment", enum_alias("TKAlignment"))],
                    TypeRef::void(),
                    None,
                ),
                // An enum-typed return (crosses as a number — cast to the enum type).
                method(
                    "alignment",
                    false,
                    false,
                    vec![],
                    enum_alias("TKAlignment"),
                    None,
                ),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    #[test]
    fn proven_enum_alias_types_the_signature_imports_type_only_and_casts_the_return() {
        // The enum-alias-typing headline (ADR-0055 §6): a proven NS_ENUM alias renders as
        // the enum type name in the signature, imports type-only from the framework barrel,
        // and the enum-typed return is cast (a numeric enum is not structurally `number`).
        let out = render_with_enums(&gauge(), "TestKit", &ClassRegistry::new(), &["TKAlignment"]);
        assert!(
            out.contains("setAlignment_(alignment: TKAlignment): void {"),
            "enum param types the signature:\n{out}"
        );
        assert!(
            out.contains("alignment(): TKAlignment {"),
            "enum return types the signature:\n{out}"
        );
        // Type-only import from the same-framework barrel (no runtime cycle).
        assert!(
            out.contains("import type {\n  TKAlignment,\n} from '@apianyware/testkit';"),
            "enum imported type-only from its owning barrel:\n{out}"
        );
        // The enum param crosses uncoerced (enum → number is assignable — no unwrap/cast).
        assert!(
            out.contains(
                "__dispatch.aw_ts_msg_q_v(__unwrap(this), __sel('setAlignment:'), alignment);"
            ),
            "enum arg passes through as its number:\n{out}"
        );
        // The enum return is cast (number → enum needs an explicit `as`).
        assert!(
            out.contains("return __dispatch.aw_ts_msg_0_q(__unwrap(this), __sel('alignment')) as TKAlignment;"),
            "enum return cast to the enum type:\n{out}"
        );
    }

    #[test]
    fn unproven_alias_stays_number_no_type_import() {
        // The same class emitted with an EMPTY known set: the alias cannot be proven an
        // enum, so it stays `number` and there is no ENUM type-only import — the safe
        // fallback. `gauge()` still gets a type-only import for `OverridableMethod` (ADR-0059
        // §4, unrelated — it has overridable instance methods), so the assertion narrows to
        // the enum name rather than "no import type at all".
        let out = render_in(&gauge(), "TestKit");
        assert!(
            out.contains("setAlignment_(alignment: number): void {"),
            "unproven alias param → number:\n{out}"
        );
        assert!(
            out.contains("alignment(): number {"),
            "unproven alias return → number:\n{out}"
        );
        assert!(
            !out.contains("TKAlignment"),
            "no enum import or cast:\n{out}"
        );
    }

    /// A class with three fallible `…error:` methods (ADR-0058): a **static** object-returning
    /// factory (`+dataWithContentsOfFile:error:` → nullable NSData, +0), an **instance** BOOL
    /// writer (`-writeToFile:error:`), and an **instance** non-BOOL scalar writer
    /// (`-writeBytesToFile:error:` → `NSInteger`, the `NSJSONSerialization
    /// .writeJSONObject(_:toStream:options:error:)` shape `nonbool-fallible-scalar-result-k101`
    /// fixed). All three carry a trailing `NSError**` cell (a raw `Pointer`) the enrichment set
    /// flags.
    fn nsdata() -> Class {
        Class {
            name: "NSData".into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![
                method(
                    "dataWithContentsOfFile:error:",
                    true,
                    false,
                    vec![
                        param(
                            "path",
                            ty(TypeRefKind::Id {
                                protocols: Vec::new(),
                            }),
                        ),
                        param("error", ty(TypeRefKind::Pointer)),
                    ],
                    nullable(TypeRefKind::Class {
                        name: "NSData".into(),
                        framework: None,
                        params: vec![],
                    }),
                    None,
                ),
                method(
                    "writeToFile:error:",
                    false,
                    false,
                    vec![
                        param(
                            "path",
                            ty(TypeRefKind::Id {
                                protocols: Vec::new(),
                            }),
                        ),
                        param("error", ty(TypeRefKind::Pointer)),
                    ],
                    ty(TypeRefKind::Primitive {
                        name: "bool".into(),
                    }),
                    None,
                ),
                method(
                    "writeBytesToFile:error:",
                    false,
                    false,
                    vec![
                        param(
                            "path",
                            ty(TypeRefKind::Id {
                                protocols: Vec::new(),
                            }),
                        ),
                        param("error", ty(TypeRefKind::Pointer)),
                    ],
                    ty(TypeRefKind::Primitive {
                        name: "NSInteger".into(),
                    }),
                    None,
                ),
            ],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        }
    }

    #[test]
    fn fallible_object_and_scalar_methods_emit_result_bodies() {
        // ADR-0058: a fallible `…error:` method drops the trailing NSError** cell from the
        // JS args, dispatches through the `…_e` entry, and routes the primary through a
        // Result helper — object primary by ownership, BOOL primary passed through as a flag,
        // non-BOOL scalar primary passed through as its real value (k101).
        let out = render_full_errs(
            &nsdata(),
            "Foundation",
            &ClassRegistry::new(),
            &[],
            &ProtocolRegistry::new(),
            &[],
            &[
                "dataWithContentsOfFile:error:",
                "writeToFile:error:",
                "writeBytesToFile:error:",
            ],
        );
        // Static object factory: Result<NSData> (T non-null), out-param dropped, +0 wrap.
        assert!(
            out.contains("static dataWithContentsOfFile_error_(path: NSObject): Result<NSData> {"),
            "static fallible object factory returns Result<NSData>, out-param dropped:\n{out}"
        );
        assert!(
            out.contains(
                "return __resultRetained(NSData, __dispatch.aw_ts_msg_P_P_e(NSData.__cls, \
                 __sel('dataWithContentsOfFile:error:'), __unwrap(path)));"
            ),
            "object primary → __resultRetained over the `…_e` entry:\n{out}"
        );
        // Instance BOOL writer: Result<boolean>, scalar helper.
        assert!(
            out.contains("writeToFile_error_(path: NSObject): Result<boolean> {"),
            "instance fallible BOOL method returns Result<boolean>:\n{out}"
        );
        assert!(
            out.contains(
                "return __resultScalar(__dispatch.aw_ts_msg_P_b_e(__unwrap(this), \
                 __sel('writeToFile:error:'), __unwrap(path)));"
            ),
            "BOOL primary → __resultScalar over the `…_e` entry:\n{out}"
        );
        // Instance non-BOOL scalar writer: Result<number>, value-carrying helper (k101) — the
        // real primary (a byte count, e.g.) rides through instead of a hard-coded flag.
        assert!(
            out.contains("writeBytesToFile_error_(path: NSObject): Result<number> {"),
            "instance fallible non-BOOL scalar method returns Result<number>:\n{out}"
        );
        assert!(
            out.contains(
                "return __resultScalarValue(__dispatch.aw_ts_msg_P_q_e(__unwrap(this), \
                 __sel('writeBytesToFile:error:'), __unwrap(path)));"
            ),
            "non-BOOL scalar primary → __resultScalarValue over the `…_e` entry:\n{out}"
        );
        // Result is imported type-only from the runtime (coalescing with the class's own
        // `OverridableMethod` catalogue import, ADR-0059 §4 — `nsdata()` has an overridable
        // instance method too); the helpers are value imports.
        assert!(
            out.contains(
                "import type {\n  OverridableMethod,\n  Result,\n} from '@apianyware/runtime';"
            ),
            "Result imported type-only from the runtime seam:\n{out}"
        );
        for sym in ["__resultRetained", "__resultScalar", "__resultScalarValue"] {
            assert!(out.contains(sym), "value helper {sym} imported:\n{out}");
        }
        // The dropped NSError** cell never appears as a JS param or arg.
        assert!(
            !out.contains("error: "),
            "the NSError** out-param is never a visible JS param:\n{out}"
        );
    }

    /// A class conforming to a same-framework protocol (`TKRefreshing`) and a cross-framework
    /// one (`NSCopying`, owned by Foundation) — the `implements` surface (ADR-0055 §4).
    fn conforming() -> Class {
        let mut cls = Class {
            name: "TKView".into(),
            superclass: "NSObject".into(),
            protocols: vec![],
            properties: vec![],
            methods: vec![method(
                "refresh",
                false,
                false,
                vec![],
                TypeRef::void(),
                None,
            )],
            category_methods: vec![],
            swift_attributes: vec![],
            ancestors: vec![],
            all_methods: vec![],
            all_properties: vec![],
            objc_exposed: true,
            swift_name: None,
        };
        cls.protocols = vec!["TKRefreshing".into(), "NSCopying".into()];
        cls
    }

    #[test]
    fn implements_clause_emits_and_imports_interfaces_type_only() {
        // A cross-framework registry: NSCopying owned by Foundation, TKRefreshing recognised
        // as a same-framework interface (seeded from the framework's own protocols).
        let mut proto_reg = ProtocolRegistry::new();
        proto_reg.insert("NSCopying", "foundation");
        let out = render_full(
            &conforming(),
            "TestKit",
            &ClassRegistry::new(),
            &[],
            &proto_reg,
            &["TKRefreshing", "NSCopying"],
        );
        // The `implements` clause carries both conformances in IR order.
        assert!(
            out.contains(
                "export class TKView extends NSObject implements TKRefreshing, NSCopying {"
            ),
            "implements clause in the class header:\n{out}"
        );
        // The same-framework interface imports type-only from its own barrel; the
        // cross-framework one from its owner's — both `import type` (an interface is erased).
        assert!(
            out.contains("import type {\n  TKRefreshing,\n} from '@apianyware/testkit';"),
            "same-fw interface imported type-only from its own barrel:\n{out}"
        );
        assert!(
            out.contains("import type {\n  NSCopying,\n} from '@apianyware/foundation';"),
            "cross-fw interface imported type-only from its owner:\n{out}"
        );
    }

    #[test]
    fn a_carved_out_deprecated_conformance_member_renders_tagged() {
        // deprecated-protocol-member-policy-k111 (ADR-0055 §4b member-level rule): the class's
        // own deprecated `lock` is the sole source of the member `implements TKLocking`
        // promises — it renders, preceded by the JSDoc deprecation tag, so neither the
        // conformance promise nor the deprecation fact is erased.
        let mut cls = class("TKLocker", "NSObject", vec![]);
        cls.protocols = vec!["TKLocking".to_string()];
        cls.methods = vec![Method {
            deprecated: true,
            ..method("lock", false, false, vec![], TypeRef::void(), None)
        }];
        let mut proto_reg = ProtocolRegistry::new();
        proto_reg.insert("TKLocking", "testkit");
        proto_reg.insert_conformance("TKLocking", vec![], [("lock".to_string(), false)]);
        let out = render_full(
            &cls,
            "TestKit",
            &ClassRegistry::new(),
            &[],
            &proto_reg,
            &["TKLocking"],
        );
        assert!(
            out.contains("export class TKLocker extends NSObject implements TKLocking {"),
            "the conformance stays promised:\n{out}"
        );
        assert!(
            out.contains("/** @deprecated */\n  lock(): void {"),
            "the admitted member renders under the deprecation tag:\n{out}"
        );
    }

    #[test]
    fn unrecognised_conformance_is_dropped_from_implements() {
        // An unconfigured emitter (empty protocol registry, no known set): a conformance the
        // resolver cannot recognise contributes no `implements` and no import — the blessed
        // degradation.
        let out = render_full(
            &conforming(),
            "TestKit",
            &ClassRegistry::new(),
            &[],
            &ProtocolRegistry::new(),
            &[],
        );
        assert!(
            out.contains("export class TKView extends NSObject {"),
            "no implements clause when nothing is recognised:\n{out}"
        );
        // No PROTOCOL type import (the degradation this test targets) — `conforming()` still
        // gets a type-only `OverridableMethod` import (ADR-0059 §4, unrelated: `refresh()` is
        // an overridable instance method), so the assertion narrows to the protocol names.
        assert!(
            !out.contains("TKRefreshing") && !out.contains("NSCopying"),
            "no protocol type import:\n{out}"
        );
    }
}
